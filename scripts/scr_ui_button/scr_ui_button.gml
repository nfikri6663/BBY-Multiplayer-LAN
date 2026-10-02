/// @function ui_keyboard_confirm_check()
/// @description Deteksi tombol OK/ceklis virtual keyboard
function ui_keyboard_confirm_check() {
    var _has_newline = (string_pos(chr(10), keyboard_string) > 0) || (string_pos(chr(13), keyboard_string) > 0);
    
    if (_has_newline) {
        keyboard_string = string_replace_all(keyboard_string, chr(13), "");
        keyboard_string = string_replace_all(keyboard_string, chr(10), "");
    }
    
    return _has_newline;
}

/// @function ui_input_begin(_field_id, _current_value)
/// @description Fokuskan satu field teks
function ui_input_begin(_field_id, _current_value) {
    input_focus = _field_id;
    keyboard_string = _current_value;
    
    if (os_type == os_android || os_type == os_ios) {
        keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
    }
}

/// @function ui_input_end()
/// @description Lepas fokus field & tutup virtual keyboard
function ui_input_end() {
    input_focus = "";
    
    if (keyboard_virtual_status()) {
        keyboard_virtual_hide();
    }
    virtual_keyboard_was_visible = false;
}

/// @function ui_input_label(_field_id)
/// @description Label
function ui_input_label(_field_id) {
    switch (_field_id) {
        case "username":      return "USERNAME";
        case "room_name":     return "ROOM NAME";
        case "room_password": return "PASSWORD (OPSIONAL)";
        case "join_password": return "PASSWORD";
    }
    return "";
}

/// @function ui_cursor_visible()
/// @description Kedip kursor ketik: nyala di paruh pertama tiap siklus
function ui_cursor_visible() {
    return (current_time mod UI_CURSOR_BLINK_MS) < (UI_CURSOR_BLINK_MS / 2);
}

/// @function ui_button_clicked(_x1, _y1, _x2, _y2)
/// @description True kalau klik/tap baru saja terjadi di area ini
function ui_button_clicked(_x1, _y1, _x2, _y2) {
    if (!device_mouse_check_button_pressed(0, mb_left)) return false;
    
    var _hit = point_in_rectangle(device_mouse_x(0), device_mouse_y(0), _x1, _y1, _x2, _y2);
    if (_hit) {
        audio_play_sound(sn_click, 1, false);
    }
    return _hit;
}

/// @function ui_button_clicked_gui(_x1, _y1, _x2, _y2)
/// @description True kalau klik/tap baru saja terjadi di area ini (GUI)
function ui_button_clicked_gui(_x1, _y1, _x2, _y2) {
    if (!device_mouse_check_button_pressed(0, mb_left)) return false;
    
    var _hit = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _x1, _y1, _x2, _y2);
    if (_hit) {
        audio_play_sound(sn_click, 1, false);
    }
    return _hit;
}

/// @function ui_toast(_message)
/// @description Tampilkan pesan status sebagai toast di atas layar
function ui_toast(_message) {
    status_message = _message;
    status_message_time = current_time;
}

/// @function ui_kbd_overlay_layout()
/// @description Hitung posisi panel overlay ketikan
function ui_kbd_overlay_layout() {
    var _s = ui_scale();
    var _gw = display_get_gui_width();
    var _pad = 14 * _s;
    var _w = min(_gw - _pad * 2, 560 * _s);
    var _x1 = (_gw - _w) / 2;
    var _x2 = _x1 + _w;
    var _y1 = _pad;
    var _label_h = 22 * _s;
    var _field_h = 44 * _s;
    var _btn_h = 40 * _s;
    var _gap = 10 * _s;
    
    var _field_y1 = _y1 + _pad + _label_h;
    var _btn_y1 = _field_y1 + _field_h + _gap;
    
    return {
        panel_x1: _x1, panel_y1: _y1, panel_x2: _x2, panel_y2: _btn_y1 + _btn_h + _pad,
        label_x: _x1 + _pad, label_y: _y1 + _pad,
        field_x1: _x1 + _pad, field_y1: _field_y1, field_x2: _x2 - _pad, field_y2: _field_y1 + _field_h,
        btn_x1: _x2 - _pad - 140 * _s, btn_y1: _btn_y1, btn_x2: _x2 - _pad, btn_y2: _btn_y1 + _btn_h
    };
}