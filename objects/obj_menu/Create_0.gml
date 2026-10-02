network_set_config(network_config_use_non_blocking_socket, true);

display_apply_fullscreen();
display_sync_to_window();

menu_state = "main";

// Identitas default
if (!variable_global_exists("net_username")) {
    global.net_username = "Player" + string(irandom(999));
}
if (!variable_global_exists("net_character_id")) {
    global.net_character_id = 0;
}

// --- Nilai input pemain ---
room_name_input = "";
room_password_input = "";
join_password_input = "";
input_focus = "";
host_pass_visible = false;
join_pass_visible = false;
exit_confirm = false;

selected_room_ip = "";
selected_room_port = -1;
selected_room_name = "";

// --- Discovery & proses join ---
discovery_socket = -1;
discovered_rooms = ds_map_create();
discovery_failed = false;
discovery_query_timer = 0;

join_socket = -1;
join_target_ip = "";
join_target_port = TCP_PORT_BASE;
join_target_password = "";
join_timer = 0;
join_retry_timer = 0;
join_timeout_seconds = 5;

keyboard_string = "";
virtual_keyboard_was_visible = false;

// --- Toast pesan status ---
status_message = "";
status_message_time = -UI_TOAST_MS;

if (variable_global_exists("net_status_message") && global.net_status_message != "") {
    ui_toast(global.net_status_message);
    global.net_status_message = "";
}

/// Layout dihitung tiap pemanggilan (ikut resolusi GUI terkini) --
menu_layout = function() {
    var _s = ui_scale();
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cx = _gw / 2;
    
    // ---------- MAIN ----------
    var _play_w = min(340 * _s, _gw - 48 * _s);
    var _play_y1 = _gh * 0.52;
    var _exit_y1 = _play_y1 + 64 * _s + 18 * _s;
    var _bar_y2 = _gh - 26 * _s;
    var _yt_w = 150 * _s;
    var _don_w = 140 * _s;
    var _bar_gap = 22 * _s;
    var _bar_total = _yt_w + _don_w + _bar_gap;
    
    // ---------- SELECT ----------
    var _sel_side_by_side = (_gw >= 620 * _s);
    var _sel_btn_w = _sel_side_by_side ? 250 * _s : min(340 * _s, _gw - 48 * _s);
    var _sel_btn_h = 58 * _s;
    var _sel_gap = 16 * _s;
    var _sel_y1 = _gh * 0.50;
    
    // ---------- KARTU (host / join / password) ----------
    var _card_w = min(_gw - 48 * _s, 440 * _s);
    var _card_x1 = _cx - _card_w / 2;
    var _card_x2 = _cx + _card_w / 2;
    var _pad = 22 * _s;
    var _label_h = 15 * _s;
    var _field_h = 42 * _s;
    var _fgap = 20 * _s;
    
    // host_setup: susunan isi kartu dihitung menurun dari card_y1
    var _hcard_y1 = _gh * 0.25;
    var _h_room_label_y = _hcard_y1 + _pad + _label_h;
    var _h_room_y1 = _h_room_label_y + 4 * _s;
    var _h_room_y2 = _h_room_y1 + _field_h;
    var _h_pass_label_y = _h_room_y2 + _fgap + _label_h;
    var _h_pass_y1 = _h_pass_label_y + 4 * _s;
    var _h_pass_y2 = _h_pass_y1 + _field_h;
    var _h_div_y = _h_pass_y2 + _fgap;
    var _h_create_y1 = _h_div_y + _fgap * 0.7;
    var _h_create_y2 = _h_create_y1 + 54 * _s;
    var _hcard_y2 = _h_create_y2 + _pad;
    
    // browse_rooms
    var _jcard_w = min(_gw - 48 * _s, 540 * _s);
    var _jcard_x1 = _cx - _jcard_w / 2;
    var _jcard_x2 = _cx + _jcard_w / 2;
    var _jcard_y1 = _gh * 0.25;
    var _jcard_y2 = _gh - 85 * _s;
    var _toolbar_h = 46 * _s;
    var _footer_h = 34 * _s;
    var _row_h = 46 * _s;
    var _row_gap = 8 * _s;
    var _list_y = _jcard_y1 + _toolbar_h + 10 * _s;
    var _list_y2 = _jcard_y2 - _footer_h - 6 * _s;
    var _rows_visible = max(1, floor((_list_y2 - _list_y) / (_row_h + _row_gap)));
    
    // enter_password
    var _pcard_y1 = _gh * 0.30;
    var _p_pass_label_y = _pcard_y1 + _pad + 26 * _s + _label_h;
    var _p_pass_y1 = _p_pass_label_y + 4 * _s;
    var _p_pass_y2 = _p_pass_y1 + _field_h;
    var _p_join_y1 = _p_pass_y2 + _fgap;
    var _p_join_y2 = _p_join_y1 + 52 * _s;
    var _pcard_y2 = _p_join_y2 + _pad;
    
    return {
        s: _s, gw: _gw, gh: _gh, cx: _cx,
        
        // MAIN
        badge_cy: _gh * 0.18,
        title_cy: _gh * 0.275,
        sub_cy: _gh * 0.28 + 44 * _s,
        play_x1: _cx - _play_w / 2, play_y1: _play_y1, play_x2: _cx + _play_w / 2, play_y2: _play_y1 + 64 * _s,
        exit_x1: _cx - 130 * _s, exit_y1: _exit_y1, exit_x2: _cx + 130 * _s, exit_y2: _exit_y1 + 40 * _s,
        confirm_x1: _cx - 160 * _s, confirm_y1: _exit_y1, confirm_x2: _cx + 160 * _s, confirm_y2: _exit_y1 + 44 * _s,
        batal_x1: _cx + 10 * _s, batal_x2: _cx + 75 * _s,
        keluar_x1: _cx + 85 * _s, keluar_x2: _cx + 155 * _s,
        yt_x1: _cx - _bar_total / 2, yt_y1: _bar_y2 - 44 * _s, yt_x2: _cx - _bar_total / 2 + _yt_w, yt_y2: _bar_y2,
        don_x1: _cx + _bar_total / 2 - _don_w, don_y1: _bar_y2 - 44 * _s, don_x2: _cx + _bar_total / 2, don_y2: _bar_y2,
        
        // SELECT
        sel_header_y: _gh * 0.14,
        sel_host_x1: _sel_side_by_side ? (_cx - _sel_btn_w - _sel_gap / 2) : (_cx - _sel_btn_w / 2),
        sel_host_y1: _sel_y1,
        sel_host_x2: _sel_side_by_side ? (_cx - _sel_gap / 2) : (_cx + _sel_btn_w / 2),
        sel_host_y2: _sel_y1 + _sel_btn_h,
        sel_join_x1: _sel_side_by_side ? (_cx + _sel_gap / 2) : (_cx - _sel_btn_w / 2),
        sel_join_y1: _sel_side_by_side ? _sel_y1 : (_sel_y1 + _sel_btn_h + _sel_gap),
        sel_join_x2: _sel_side_by_side ? (_cx + _sel_gap / 2 + _sel_btn_w) : (_cx + _sel_btn_w / 2),
        sel_join_y2: _sel_side_by_side ? (_sel_y1 + _sel_btn_h) : (_sel_y1 + _sel_btn_h * 2 + _sel_gap),
        sel_back_x1: _cx - 90 * _s, sel_back_y1: _gh * 0.76, sel_back_x2: _cx + 90 * _s, sel_back_y2: _gh * 0.76 + 44 * _s,
        
        // HEADER layar kartu
        header_y: _gh * 0.07,
        
        // HOST_SETUP
        card_x1: _card_x1, card_x2: _card_x2, pad: _pad,
        hcard_y1: _hcard_y1, hcard_y2: _hcard_y2,
        h_room_label_y: _h_room_label_y,
        h_room_y1: _h_room_y1, h_room_y2: _h_room_y2,
        h_pass_label_y: _h_pass_label_y,
        h_pass_y1: _h_pass_y1, h_pass_y2: _h_pass_y2,
        h_div_y: _h_div_y,
        h_create_y1: _h_create_y1, h_create_y2: _h_create_y2,
        eye_w: 44 * _s,
        
        // BROWSE_ROOMS
        jcard_x1: _jcard_x1, jcard_x2: _jcard_x2, jcard_y1: _jcard_y1, jcard_y2: _jcard_y2,
        toolbar_h: _toolbar_h, footer_h: _footer_h,
        refresh_x1: _jcard_x2 - 14 * _s - 118 * _s, refresh_y1: _jcard_y1 + 8 * _s,
        refresh_x2: _jcard_x2 - 14 * _s, refresh_y2: _jcard_y1 + 8 * _s + 32 * _s,
        list_x1: _jcard_x1 + 14 * _s, list_x2: _jcard_x2 - 14 * _s,
        list_y: _list_y, row_h: _row_h, row_gap: _row_gap, rows_visible: _rows_visible,
        
        // ENTER_PASSWORD
        pcard_y1: _pcard_y1, pcard_y2: _pcard_y2,
        p_pass_label_y: _p_pass_label_y,
        p_pass_y1: _p_pass_y1, p_pass_y2: _p_pass_y2,
        p_join_y1: _p_join_y1, p_join_y2: _p_join_y2,
        
        // CONNECTING
        conn_cancel_x1: _cx - 110 * _s, conn_cancel_y1: _gh * 0.72,
        conn_cancel_x2: _cx + 110 * _s, conn_cancel_y2: _gh * 0.72 + 46 * _s,
        
        // BACK (dipakai host_setup / browse / enter_password -- posisi seragam di bawah)
        back_x1: _cx - 90 * _s, back_y1: _gh - 66 * _s, back_x2: _cx + 90 * _s, back_y2: _gh - 22 * _s
    };
};