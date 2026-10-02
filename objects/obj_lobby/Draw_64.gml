if (!instance_exists(obj_network) || !instance_exists(obj_player)) exit;
if (obj_network.game_started) exit;

var _l = lobby_layout();
var _s = _l.s;
draw_set_font(fnt_ui);

// --- Latar penuh ---
ui_bg_draw(_l.gw, _l.gh);

// --- HEADER ---
var _player_list = lobby_gather_players();
var _total = array_length(_player_list);

ui_text_c(_l.cx, _l.kicker_y + 2 * _s, ui_spaced("BOBOIBOY MULTIPLAYER"), 0.8 * _s, UI_COL_PRIMARY_HI, 0.9);

draw_set_font(fnt_ui_title);
for (var _g = 3; _g >= 1; _g--) {
    ui_text_c(_l.cx, _l.title_y + 2 * _s, obj_network.room_name, 0.6 * _s, UI_COL_PRIMARY, 0.06 * _g);
}
ui_text_c(_l.cx, _l.title_y + 2 * _s, obj_network.room_name, 0.6 * _s, UI_COL_TEXT);
draw_set_font(fnt_ui);

var _sub_cy = _l.sub_y + 8 * _s;
var _pemain_txt = string(_total) + " / " + string(obj_network.max_players_total) + " Pemain";
var _pemain_tw = string_width(_pemain_txt) * 0.75 * _s;
if (obj_network.room_password != "") {
    var _pw_txt = obj_network.room_password;
    var _pw_tw = string_width(_pw_txt) * 0.75 * _s;
    
    var _row_total = 12 * _s + 4 * _s + _pw_tw + 16 * _s + 12 * _s + _pemain_tw;
    var _rx = _l.cx - _row_total / 2;
    ui_icon_lock(_rx + 6 * _s, _sub_cy + 2, 5 * _s, UI_COL_TEXT_DIM, true);
    ui_text_c(_rx + 12 * _s + 4 * _s + _pw_tw / 2, _sub_cy, _pw_txt, 0.75 * _s, UI_COL_TEXT_DIM);
    var _dot_x = _rx + 12 * _s + 4 * _s + _pw_tw + 16 * _s;
    ui_dot(_dot_x, _sub_cy + 2, 2.5 * _s, UI_COL_PRIMARY_HI);
    ui_text_c(_dot_x + 12 * _s + _pemain_tw / 2, _sub_cy, _pemain_txt, 0.75 * _s, UI_COL_TEXT_DIM);
} else {
    var _row_total2 = 5 * _s + 10 * _s + _pemain_tw;
    var _rx2 = _l.cx - _row_total2 / 2;
    ui_dot(_rx2 + 2.5 * _s, _sub_cy, 2.5 * _s, UI_COL_PRIMARY_HI);
    ui_text_c(_rx2 + 5 * _s + 10 * _s + _pemain_tw / 2, _sub_cy, _pemain_txt, 0.75 * _s, UI_COL_TEXT_DIM);
}

// --- KARTU UTAMA ---
ui_panel_draw(_l.panel_x1, _l.panel_y1, _l.panel_x2, _l.panel_y2);

// --- KARTU PEMAIN ---
for (var _i = 0; _i < obj_network.max_players_total; _i++) {
    var _sx1 = _l.slots_x1 + _i * (_l.slot_w + _l.slot_gap);
    var _sx2 = _sx1 + _l.slot_w;
    var _sy1 = _l.slots_y1;
    var _sy2 = _sy1 + _l.slot_h;
    var _scx = (_sx1 + _sx2) / 2;
    var _scy = _sy1 + (_l.slot_h / 2);
    
    if (_i < _total) {
        var _p = _player_list[_i];
        var _char = character_get(_p.character_id);
        var _col = _char.ui_color;
        
        ui_rr_fill(_sx1, _sy1, _sx2, _sy2, 12 * _s, _col, 0.15);
        ui_glow_rr(_sx1, _sy1, _sx2, _sy2, 12 * _s, _col, _p.is_self ? 0.6 : 0.35);
        ui_rr_line(_sx1, _sy1, _sx2, _sy2, 12 * _s, _col, 0.8);
        
        var _spr_scale = (_l.slot_h * 0.8) / PLAYER_SPRITE_NATIVE_SIZE;
        draw_sprite_ext(_char.icon, 0, _scx, _scy - 5 * _s, _spr_scale, _spr_scale, 0, c_white, 1);
        
        ui_text_c(_scx, _sy2 - 14 * _s, ui_spaced(_char.element), 0.6 * _s, _col);
        
        if (_p.is_host_player) {
            ui_badge_draw(_sx2 - 4 * _s, _sy1 - 2 * _s, "HOST", UI_COL_PRIMARY_HI);
        } else if (_p.ready) {
            ui_badge_draw(_sx2 - 4 * _s, _sy1 - 2 * _s, "READY", UI_COL_GREEN_HI);
        }
        
        // Username -- milik sendiri
        if (_p.is_self) {
            if (input_focus == "username") {
                var _draft = username_edit;
                ui_text_c(_scx, _l.uname_y, _draft, 0.8 * _s, UI_COL_TEXT);
                if (ui_cursor_visible()) {
                    var _cx2 = _scx + string_width(_draft) * 0.4 * _s + 3 * _s;
                    draw_set_colour(_col);
                    draw_line_width(_cx2, _l.uname_y - 8 * _s, _cx2, _l.uname_y + 8 * _s, 2);
                    draw_set_colour(UI_COL_TEXT);
                }
            } else {
                var _un_tw = string_width(_p.username) * 0.8 * _s;
                var _un_total = _un_tw + 6 * _s + 8 * _s;
                ui_text_c(_scx - _un_total / 2 + _un_tw / 2, _l.uname_y, _p.username, 0.8 * _s, UI_COL_TEXT);
                ui_icon_pencil(_scx - _un_total / 2 + _un_tw + 6 * _s + 4 * _s, _l.uname_y, 4 * _s, UI_COL_TEXT_DIM);
            }
        } else {
            ui_text_c(_scx, _l.uname_y, _p.username, 0.8 * _s, UI_COL_TEXT_SOFT);
        }
    } else {
        ui_rr_fill(_sx1, _sy1, _sx2, _sy2, 12 * _s, c_white, 0.03);
        ui_rr_line(_sx1, _sy1, _sx2, _sy2, 12 * _s, c_white, 0.06);
        ui_icon_person(_scx, _scy, 12 * _s, UI_COL_TEXT_FAINT);
        ui_text_c(_scx + 5, _l.uname_y, "Menunggu...", 0.75 * _s, UI_COL_TEXT_FAINT);
    }
}

// --- Pemisah + PILIH KARAKTER ---
ui_divider_draw(_l.panel_x1 + _l.pad, _l.panel_x2 - _l.pad, _l.div_y);
ui_text_c(_l.cx, _l.pick_label_y, ui_spaced("PILIH KARAKTER"), 0.7 * _s, UI_COL_TEXT_FAINT);

var _n = character_count();
for (var _i = 0; _i < _n; _i++) {
    var _cx1 = _l.grid_x1 + _i * (_l.cell_w + _l.cell_gap);
    var _cx2 = _cx1 + _l.cell_w;
    var _cy1 = _l.grid_y1;
    var _cy2 = _cy1 + _l.cell_h;
    var _ccx = (_cx1 + _cx2) / 2;
    var _ccy = _cy1 + (_l.cell_h / 2);
    var _c = character_get(_i);
    var _selected = (_i == obj_player.character_id);
    var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _cx1, _cy1, _cx2, _cy2);
    
    if (_selected) {
        ui_rr_fill(_cx1, _cy1, _cx2, _cy2, 10 * _s, _c.ui_color, 0.18);
        ui_glow_rr(_cx1, _cy1, _cx2, _cy2, 10 * _s, _c.ui_color, 0.55);
        ui_rr_line(_cx1, _cy1, _cx2, _cy2, 10 * _s, _c.ui_color, 1);
    } else {
        ui_rr_fill(_cx1, _cy1, _cx2, _cy2, 10 * _s, c_white, _hover ? 0.07 : 0.03);
        ui_rr_line(_cx1, _cy1, _cx2, _cy2, 10 * _s, c_white, _hover ? 0.2 : 0.08);
    }
    
    var _cell_spr_scale = (_l.cell_h * 0.8) / PLAYER_SPRITE_NATIVE_SIZE;
    draw_sprite_ext(_c.icon, 0, _ccx, _ccy - 5 * _s, _cell_spr_scale, _cell_spr_scale, 0, c_white, 1);
    ui_text_c(_ccx, _cy2 - 14 * _s, ui_spaced(_c.element), 0.55 * _s, _selected ? _c.ui_color : UI_COL_TEXT_DIM);
}

// Nama panjang karakter terpilih
var _sel_char = character_get(obj_player.character_id);
ui_text_c(_l.cx, _l.char_name_y, _sel_char.display_name, 0.85 * _s, _sel_char.ui_color);

// --- BAR TOMBOL BAWAH ---
ui_btn_draw(_l.leave_x1, _l.leave_y1, _l.leave_x2, _l.leave_y2, "LEAVE", "ghost", ui_icon_leave);

if (obj_network.is_host) {
    var _all_ready = false;
    with (obj_network) { _all_ready = net_lobby_all_ready(); }
    
    ui_btn_draw(_l.play_x1, _l.play_y1, _l.play_x2, _l.play_y2, "PLAY!", "primary", ui_icon_play, _all_ready);
    if (!_all_ready) {
        ui_text_c((_l.play_x1 + _l.play_x2) / 2, _l.play_y1 - 12 * _s, "Menunggu semua siap...", 0.7 * _s, UI_COL_TEXT_DIM);
    }
}

if (obj_player.is_ready) {
    ui_btn_draw(_l.ready_x1, _l.ready_y1, _l.ready_x2, _l.ready_y2, "READY!", "secondary", ui_icon_check);
} else {
    ui_btn_draw(_l.ready_x1, _l.ready_y1, _l.ready_x2, _l.ready_y2, "READY", "default", ui_icon_clock);
}

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
    ui_field_draw(_ov.field_x1, _ov.field_y1, _ov.field_x2, _ov.field_y2, username_edit, "Ketik di sini...", true);
    ui_btn_draw(_ov.btn_x1, _ov.btn_y1, _ov.btn_x2, _ov.btn_y2, "SELESAI", "primary", ui_icon_check);
}