var _l = menu_layout();
var _s = _l.s;
draw_set_font(fnt_ui);

if (!variable_instance_exists(id, "batal_hover_t")) {
    batal_hover_t = 0;
    keluar_hover_t = 0;
}

ui_bg_draw(_l.gw, _l.gh);
ui_corner_deco_draw(_l.gw);

switch (menu_state) {
    case "main": {
        var _badge_txt = ui_spaced("FAN BASE GAME");
        var _btw = string_width(_badge_txt) * 0.75 * _s;
        var _bx1 = _l.cx - _btw / 2 - 18 * _s;
        var _bx2 = _l.cx + _btw / 2 + 18 * _s;
        var _by1 = _l.badge_cy - 14 * _s;
        var _by2 = _l.badge_cy + 14 * _s;
        if (sprite_exists(spr_ui_pill)) {
            ui_nine(spr_ui_pill, _bx1, _by1, _bx2, _by2, UI_COL_PRIMARY, 0.15);
        } else {
            ui_rr_fill(_bx1, _by1, _bx2, _by2, 14 * _s, UI_COL_PRIMARY, 0.1);
        }
        ui_rr_line(_bx1, _by1, _bx2, _by2, 14 * _s, UI_COL_PRIMARY, 0.25);
        ui_dot(_bx1 + 12 * _s, _l.badge_cy, 2.5 * _s, UI_COL_GREEN);
        ui_text_c(_l.cx + 5 * _s, _l.badge_cy, _badge_txt, 0.75 * _s, UI_COL_TEXT_DIM);
        
        draw_set_font(fnt_ui_title);
        var _tsc = _s;
        for (var _i = 4; _i >= 1; _i--) {
            ui_text_c(_l.cx, _l.title_cy, "BOBOIBOY", _tsc, UI_COL_PRIMARY, 0.06 * _i);
        }
        ui_text_c(_l.cx, _l.title_cy, "BOBOIBOY", _tsc, UI_COL_TEXT);
        draw_set_font(fnt_ui);
        
        var _sub_txt = ui_spaced("MULTIPLAYER");
        var _stw = string_width(_sub_txt) * 0.8 * _s;
        draw_set_colour(UI_COL_PRIMARY_HI);
        draw_set_alpha(0.5);
        draw_line_width(_l.cx - _stw / 2 - 70 * _s, _l.sub_cy, _l.cx - _stw / 2 - 12 * _s, _l.sub_cy, 1);
        draw_line_width(_l.cx + _stw / 2 + 12 * _s, _l.sub_cy, _l.cx + _stw / 2 + 70 * _s, _l.sub_cy, 1);
        draw_set_alpha(1);
        draw_set_colour(UI_COL_TEXT);
        ui_text_c(_l.cx, _l.sub_cy, _sub_txt, 0.8 * _s, UI_COL_PRIMARY_HI, 0.8);
        
        var _ring = (current_time mod 2400) / 2400;
        ui_rr_line(_l.play_x1 - _ring * 14 * _s, _l.play_y1 - _ring * 14 * _s,
                   _l.play_x2 + _ring * 14 * _s, _l.play_y2 + _ring * 14 * _s,
                   14 * _s, UI_COL_PRIMARY_HI, (1 - _ring) * 0.4);
        ui_btn_draw(_l.play_x1, _l.play_y1, _l.play_x2, _l.play_y2, "PLAY GAME", "primary");
        
        var _mxg = device_mouse_x_to_gui(0);
        var _myg = device_mouse_y_to_gui(0);
        var _hover_batal = exit_confirm && point_in_rectangle(_mxg, _myg, _l.batal_x1, _l.confirm_y1, _l.batal_x2, _l.confirm_y2);
        var _hover_keluar = exit_confirm && point_in_rectangle(_mxg, _myg, _l.keluar_x1, _l.confirm_y1, _l.keluar_x2, _l.confirm_y2);
        batal_hover_t = lerp(batal_hover_t, _hover_batal ? 1 : 0, 0.2);
        keluar_hover_t = lerp(keluar_hover_t, _hover_keluar ? 1 : 0, 0.2);
        
        if (!exit_confirm) {
            ui_btn_draw(_l.exit_x1, _l.exit_y1, _l.exit_x2, _l.exit_y2, "EXIT GAME", "danger_soft");
        } else {
            ui_rr_fill(_l.confirm_x1, _l.confirm_y1, _l.confirm_x2, _l.confirm_y2, 12 * _s, UI_COL_DANGER, 0.1);
            ui_rr_line(_l.confirm_x1, _l.confirm_y1, _l.confirm_x2, _l.confirm_y2, 12 * _s, UI_COL_DANGER, 0.3);
            var _ccy = (_l.confirm_y1 + _l.confirm_y2) / 2;
            
            var _q_cx = (_l.confirm_x1 + 14 * _s + _l.batal_x1) / 2;
            ui_text_c(_q_cx, _ccy, "Yakin keluar?", 0.8 * _s, UI_COL_DANGER);
            
            if (batal_hover_t > 0.02) {
                ui_rr_fill(_l.batal_x1, _l.confirm_y1 + 7 * _s, _l.batal_x2, _l.confirm_y2 - 7 * _s,
                    8 * _s, c_white, 0.12 * batal_hover_t);
            }
            ui_text_c((_l.batal_x1 + _l.batal_x2) / 2, _ccy, "Batal",
                0.8 * _s * (1 + 0.1 * batal_hover_t),
                merge_colour(UI_COL_TEXT_DIM, UI_COL_TEXT, batal_hover_t));
                
            if (keluar_hover_t > 0.02) {
                ui_rr_fill(_l.keluar_x1, _l.confirm_y1 + 7 * _s, _l.keluar_x2, _l.confirm_y2 - 7 * _s,
                    8 * _s, UI_COL_DANGER, 0.15 * keluar_hover_t);
            }
            ui_text_c((_l.keluar_x1 + _l.keluar_x2) / 2, _ccy, "Keluar",
                0.8 * _s * (1 + 0.1 * keluar_hover_t),
                merge_colour(UI_COL_DANGER, c_white, 0.3 * keluar_hover_t));
        }
        
        var _bar_cy = (_l.yt_y1 + _l.yt_y2) / 2;
        var _yt_hover = point_in_rectangle(_mxg, _myg, _l.yt_x1, _l.yt_y1, _l.yt_x2, _l.yt_y2);
        ui_rr_fill(_l.yt_x1, _l.yt_y1, _l.yt_x2, _l.yt_y2, 12 * _s, UI_COL_DANGER, _yt_hover ? 0.2 : 0.1);
        ui_rr_line(_l.yt_x1, _l.yt_y1, _l.yt_x2, _l.yt_y2, 12 * _s, UI_COL_DANGER, _yt_hover ? 0.4 : 0.2);
        ui_icon_text_c((_l.yt_x1 + _l.yt_x2) / 2, _bar_cy, ui_icon_youtube, 8 * _s, "YouTube", 0.85 * _s, UI_COL_DANGER);
        
        var _don_hover = point_in_rectangle(_mxg, _myg, _l.don_x1, _l.don_y1, _l.don_x2, _l.don_y2);
        ui_rr_fill(_l.don_x1, _l.don_y1, _l.don_x2, _l.don_y2, 12 * _s, UI_COL_GHOST, _don_hover ? 0.18 : 0.08);
        ui_rr_line(_l.don_x1, _l.don_y1, _l.don_x2, _l.don_y2, 12 * _s, UI_COL_GHOST, _don_hover ? 0.4 : 0.18);
        ui_icon_text_c((_l.don_x1 + _l.don_x2) / 2, _bar_cy, ui_icon_heart, 7 * _s, "Donate", 0.85 * _s, UI_COL_GHOST);
        break;
    }
    
    case "select": {
        ui_header_draw(_l.cx, _l.sel_header_y + 20 * _s, "MULTIPLAYER", "BOBOIBOY", 0.8 * _s);
        
        ui_btn_draw(_l.sel_host_x1, _l.sel_host_y1, _l.sel_host_x2, _l.sel_host_y2, "HOST GAME", "primary");
        ui_btn_draw(_l.sel_join_x1, _l.sel_join_y1, _l.sel_join_x2, _l.sel_join_y2, "JOIN GAME", "secondary");
        
        ui_divider_draw(_l.cx - 96 * _s, _l.cx + 96 * _s, _l.sel_back_y1 - 16 * _s);
        ui_btn_draw(_l.sel_back_x1, _l.sel_back_y1, _l.sel_back_x2, _l.sel_back_y2, "BACK", "ghost");
        break;
    }
    
    case "host_setup": {
        ui_header_draw(_l.cx, _l.header_y, "BOBOIBOY MULTIPLAYER", "HOST GAME", 0.8 * _s);
        
        ui_panel_draw(_l.card_x1, _l.hcard_y1, _l.card_x2, _l.hcard_y2);
        
        // ROOM NAME
        ui_field_label_draw(_l.cx, _l.h_room_label_y, "ROOM NAME", input_focus == "room_name");
        ui_field_draw(_l.card_x1 + _l.pad, _l.h_room_y1, _l.card_x2 - _l.pad, _l.h_room_y2,
            room_name_input, "NAMA ACAK JIKA KOSONG", input_focus == "room_name", false, ui_icon_layers);
            
        // PASSWORD
        var _pass_cx = (_l.card_x1 + _l.pad + _l.card_x2 - _l.pad - _l.eye_w) / 2;
        ui_field_label_draw(_l.cx, _l.h_pass_label_y, "PASSWORD", input_focus == "room_password", "(opsional)");
        ui_field_draw(_l.card_x1 + _l.pad, _l.h_pass_y1, _l.card_x2 - _l.pad, _l.h_pass_y2,
            room_password_input, "Kosongkan jika tanpa password", input_focus == "room_password", !host_pass_visible, ui_icon_lock);
        ui_icon_eye(_l.card_x2 - _l.pad - 14 * _s, (_l.h_pass_y1 + _l.h_pass_y2) / 2, 7 * _s, UI_COL_TEXT_DIM, host_pass_visible);
        
        ui_divider_draw(_l.card_x1 + _l.pad, _l.card_x2 - _l.pad, _l.h_div_y);
        
        ui_btn_draw(_l.card_x1 + _l.pad, _l.h_create_y1, _l.card_x2 - _l.pad, _l.h_create_y2, "CREATE ROOM", "primary", ui_icon_plus);
        
        ui_btn_draw(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2, "BACK", "ghost");
        break;
    }
    
    case "browse_rooms": {
        ui_header_draw(_l.cx, _l.header_y, "BOBOIBOY MULTIPLAYER", "JOIN GAME", 0.8 * _s);
        
        ui_panel_draw(_l.jcard_x1, _l.jcard_y1, _l.jcard_x2, _l.jcard_y2);
        
        // --- Toolbar: info pembaruan + tombol REFRESH ---
        var _tb_cy = _l.jcard_y1 + _l.toolbar_h / 2;
        
        var _newest = -1;
        var _sum_players = 0;
        var _rooms_open = 0;
        var _scan_key = ds_map_find_first(discovered_rooms);
        repeat (ds_map_size(discovered_rooms)) {
            var _scan_room = discovered_rooms[? _scan_key];
            _newest = max(_newest, _scan_room.last_seen);
            _sum_players += _scan_room.player_count;
            if (_scan_room.player_count < 4) _rooms_open++;
            _scan_key = ds_map_find_next(discovered_rooms, _scan_key);
        }
        var _upd_text;
        if (_newest < 0) {
            _upd_text = "Mencari room...";
        } else {
            var _ago = (current_time - _newest) / 1000;
            _upd_text = (_ago < 2) ? "Diperbarui baru saja" : ("Diperbarui " + string(floor(_ago)) + " dtk lalu");
        }
        
        var _upd_tw = string_width(_upd_text) * 0.75 * _s;
        var _upd_total = 12 * _s + 6 * _s + _upd_tw;
        ui_icon_text_c(_l.jcard_x1 + 16 * _s + _upd_total / 2, _tb_cy, ui_icon_clock, 6 * _s, _upd_text, 0.75 * _s, UI_COL_TEXT_DIM);
        
        // Tombol REFRESH
        var _rf_hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _l.refresh_x1, _l.refresh_y1, _l.refresh_x2, _l.refresh_y2);
        ui_rr_fill(_l.refresh_x1, _l.refresh_y1, _l.refresh_x2, _l.refresh_y2, 8 * _s, UI_COL_PRIMARY, _rf_hover ? 0.28 : 0.15);
        ui_rr_line(_l.refresh_x1, _l.refresh_y1, _l.refresh_x2, _l.refresh_y2, 8 * _s, UI_COL_PRIMARY, 0.25);
        ui_icon_text_c((_l.refresh_x1 + _l.refresh_x2) / 2, (_l.refresh_y1 + _l.refresh_y2) / 2,
            ui_icon_refresh, 6 * _s, ui_spaced("REFRESH"), 0.7 * _s, UI_COL_PRIMARY_HI);
            
        ui_divider_draw(_l.jcard_x1 + 10 * _s, _l.jcard_x2 - 10 * _s, _l.jcard_y1 + _l.toolbar_h);
        
        // --- Daftar room ---
        var _count = ds_map_size(discovered_rooms);
        if (_count == 0) {
            var _empty_cy = (_l.list_y + _l.jcard_y2 - _l.footer_h) / 2;
            if (discovery_failed) {
                ui_text_c(_l.cx, _empty_cy, "Pencarian room gagal dibuka.", 0.85 * _s, UI_COL_DANGER);
            } else {
                ui_spinner_draw(_l.cx, _empty_cy - 18 * _s, 14 * _s);
                ui_text_c(_l.cx, _empty_cy + 16 * _s, ui_spaced("MENCARI ROOM..."), 0.75 * _s, UI_COL_TEXT_DIM);
            }
        } else {
            var _y = _l.list_y;
            var _key = ds_map_find_first(discovered_rooms);
            var _row_index = 0;
            repeat (_count) {
                if (_row_index >= _l.rows_visible) break;
                var _room = discovered_rooms[? _key];
                var _full = (_room.player_count >= 4);
                var _hover = !_full && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _l.list_x1, _y, _l.list_x2, _y + _l.row_h);
                
                if (_full) draw_set_alpha(0.5);
                ui_rr_fill(_l.list_x1, _y, _l.list_x2, _y + _l.row_h, 10 * _s, _hover ? UI_COL_PRIMARY : c_white, _hover ? 0.12 : 0.03);
                ui_rr_line(_l.list_x1, _y, _l.list_x2, _y + _l.row_h, 10 * _s, _hover ? UI_COL_PRIMARY : c_white, _hover ? 0.35 : 0.06);
                
                var _rcy = _y + _l.row_h / 2;
                ui_icon_lock(_l.list_x1 + 20 * _s, _rcy, 6 * _s, UI_COL_TEXT_DIM, _room.has_password);
                
                // Nama room dipusatkan di area antara gembok & kotak jumlah pemain
                var _dots_x = _l.list_x2 - 118 * _s;
                var _name_cx = (_l.list_x1 + 36 * _s + _dots_x - 10 * _s) / 2;
                ui_text_c(_name_cx, _rcy, _room.room_name, 0.85 * _s, UI_COL_TEXT);
                
                // 4 kotak jumlah pemain
                for (var _d = 0; _d < 4; _d++) {
                    var _dx = _dots_x + _d * 9 * _s;
                    if (_d < _room.player_count) {
                        draw_set_colour(_full ? UI_COL_DANGER : UI_COL_PRIMARY_HI);
                        draw_set_alpha(0.9);
                    } else {
                        draw_set_colour(c_white);
                        draw_set_alpha(0.1);
                    }
                    draw_rectangle(_dx, _rcy - 3 * _s, _dx + 6 * _s, _rcy + 3 * _s, false);
                }
                draw_set_alpha(_full ? 0.5 : 1);
                draw_set_colour(UI_COL_TEXT);
                
                var _cnt_txt = string(_room.player_count) + "/4";
                var _cnt_tw = string_width(_cnt_txt) * 0.75 * _s;
                ui_text_c(_dots_x + 42 * _s + _cnt_tw / 2, _rcy, _cnt_txt, 0.75 * _s, _full ? UI_COL_DANGER : UI_COL_TEXT_DIM);
                
                var _age = current_time - _room.last_seen;
                var _sig_col = (_age < 1500) ? UI_COL_GREEN : ((_age < 2600) ? UI_COL_YELLOW : UI_COL_DANGER);
                if (_full) {
                    var _full_tw = string_width("FULL") * 0.75 * _s;
                    ui_text_c(_l.list_x2 - 12 * _s - _full_tw / 2, _rcy, "FULL", 0.75 * _s, UI_COL_DANGER);
                } else {
                    ui_dot(_l.list_x2 - 18 * _s, _rcy, 2.5 * _s, _sig_col);
                }
                
                draw_set_alpha(1);
                
                _y += _l.row_h + _l.row_gap;
                _row_index++;
                _key = ds_map_find_next(discovered_rooms, _key);
            }
            
            if (_count > _l.rows_visible) {
                ui_text_c(_l.cx, _y + 6 * _s, "+" + string(_count - _l.rows_visible) + " room lainnya", 0.7 * _s, UI_COL_TEXT_FAINT);
            }
        }
        
        // Footer: jumlah room & pemain
        ui_divider_draw(_l.jcard_x1 + 10 * _s, _l.jcard_x2 - 10 * _s, _l.jcard_y2 - _l.footer_h);
        var _ft_cy = _l.jcard_y2 - _l.footer_h / 2;
        var _ft_left = string(_rooms_open) + " room tersedia";
        var _ft_right = string(_sum_players) + " pemain online";
        var _ftl_tw = string_width(_ft_left) * 0.75 * _s;
        var _ftr_tw = string_width(_ft_right) * 0.75 * _s;
        ui_text_c(_l.jcard_x1 + 16 * _s + _ftl_tw / 2, _ft_cy, _ft_left, 0.75 * _s, UI_COL_TEXT_FAINT);
        ui_text_c(_l.jcard_x2 - 16 * _s - _ftr_tw / 2, _ft_cy, _ft_right, 0.75 * _s, UI_COL_TEXT_FAINT);
        
        ui_btn_draw(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2, "BACK", "ghost");
        break;
    }
    
    case "enter_password": {
        ui_header_draw(_l.cx, _l.header_y, "BOBOIBOY MULTIPLAYER", "JOIN GAME", 0.8 * _s);
        
        ui_panel_draw(_l.card_x1, _l.pcard_y1, _l.card_x2, _l.pcard_y2);
        
        // Nama room terpilih
        var _rn_y = _l.pcard_y1 + _l.pad + 6 * _s;
        ui_icon_text_c(_l.cx, _rn_y, ui_icon_lock, 6 * _s, selected_room_name, 0.9 * _s, UI_COL_TEXT);
        
        // PASSWORD
        ui_field_label_draw(_l.cx, _l.p_pass_label_y, "PASSWORD", input_focus == "join_password");
        ui_field_draw(_l.card_x1 + _l.pad, _l.p_pass_y1, _l.card_x2 - _l.pad, _l.p_pass_y2,
            join_password_input, "Masukkan password room", input_focus == "join_password", !join_pass_visible, ui_icon_lock);
        ui_icon_eye(_l.card_x2 - _l.pad - 14 * _s, (_l.p_pass_y1 + _l.p_pass_y2) / 2, 7 * _s, UI_COL_TEXT_DIM, join_pass_visible);
        
        ui_btn_draw(_l.card_x1 + _l.pad, _l.p_join_y1, _l.card_x2 - _l.pad, _l.p_join_y2, "JOIN GAME", "secondary", ui_icon_login);
        
        ui_btn_draw(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2, "BACK", "ghost");
        break;
    }
    
    case "connecting": {
        ui_header_draw(_l.cx, _l.header_y, "BOBOIBOY MULTIPLAYER", "JOIN GAME", 0.8 * _s);
        
        ui_spinner_draw(_l.cx, _l.gh * 0.45, 18 * _s);
        ui_text_c(_l.cx, _l.gh * 0.45 + 40 * _s, ui_spaced("MENYAMBUNGKAN..."), 0.85 * _s, UI_COL_TEXT_DIM);
        ui_text_c(_l.cx, _l.gh * 0.45 + 66 * _s, selected_room_name, 0.9 * _s, UI_COL_PRIMARY_SOFT);
        
        ui_btn_draw(_l.conn_cancel_x1, _l.conn_cancel_y1, _l.conn_cancel_x2, _l.conn_cancel_y2, "BATALKAN", "ghost");
        break;
    }
}

// --- Toast pesan status ---
ui_toast_draw(status_message, status_message_time, _l.gw);

// --- Overlay ketik saat virtual keyboard HP muncul ---
if (input_focus != "" && keyboard_virtual_status()) {
    var _ov = ui_kbd_overlay_layout();
    
    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _l.gw, _l.gh, false);
    draw_set_alpha(1);
    draw_set_colour(UI_COL_TEXT);
    
    ui_panel_draw(_ov.panel_x1, _ov.panel_y1, _ov.panel_x2, _ov.panel_y2);
    // Label overlay dipusatkan di tengah field overlay
    ui_field_label_draw((_ov.field_x1 + _ov.field_x2) / 2, _ov.label_y + 16 * _s, ui_input_label(input_focus), true);
    
    var _value = "";
    var _masked = false;
    switch (input_focus) {
        case "room_name":     _value = room_name_input; break;
        case "room_password": _value = room_password_input; _masked = !host_pass_visible; break;
        case "join_password": _value = join_password_input; _masked = !join_pass_visible; break;
    }
    
    ui_field_draw(_ov.field_x1, _ov.field_y1, _ov.field_x2, _ov.field_y2, _value, "Ketik di sini...", true, _masked);
    ui_btn_draw(_ov.btn_x1, _ov.btn_y1, _ov.btn_x2, _ov.btn_y2, "SELESAI", "primary", ui_icon_check);
}