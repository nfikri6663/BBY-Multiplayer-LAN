/// @function ui_scale()
/// @description Skala UI global mengikuti resolusi GUI device
function ui_scale() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    return clamp(min(_gw / 800, _gh / 480), 0.8, 2.6);
}

/// @function ui_spaced(_str)
/// @description Sisipkan spasi antar huruf (efek letter-spacing untuk kicker & label)
function ui_spaced(_str) {
    var _out = "";
    for (var _i = 1; _i <= string_length(_str); _i++) {
        _out += string_char_at(_str, _i);
        if (_i < string_length(_str)) _out += " ";
    }
    return _out;
}

/// @function ui_text_c(_x, _y, _str, _scale, _col, _alpha)
/// @description Teks beranchor TENGAH (fa_center + fa_middle) -- helper teks utama
function ui_text_c(_x, _y, _str, _scale, _col, _alpha = 1) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_col);
    draw_set_alpha(_alpha);
    draw_text_transformed(_x, _y, _str, _scale, _scale, 0);
    draw_set_alpha(1);
    draw_set_colour(UI_COL_TEXT);
}

/// @function ui_icon_text_c(_cx, _cy, _icon, _icon_s, _text, _text_scale, _col, _alpha)
/// @description Pasangan IKON + TEKS sebagai SATU kesatuan beranchor tengah di (_cx,_cy)
function ui_icon_text_c(_cx, _cy, _icon, _icon_s, _text, _text_scale, _col, _alpha = 1) {
    draw_set_font(fnt_ui);
    var _tw = string_width(_text) * _text_scale;
    var _gap = 6 * ui_scale();
    var _total = _icon_s * 2 + _gap + _tw;
    if (!is_undefined(_icon)) {
        draw_set_alpha(_alpha);
        _icon(_cx - _total / 2 + _icon_s, _cy + 2, _icon_s, _col);
        draw_set_alpha(1);
    }
    ui_text_c(_cx - _total / 2 + _icon_s * 2 + _gap + _tw / 2, _cy, _text, _text_scale, _col, _alpha);
}

// ============================================================================
// PRIMITIF SPRITE
// ============================================================================

/// @function ui_nine(_spr, _x1, _y1, _x2, _y2, _col, _alpha)
/// @description Gambar sprite 9-slice memenuhi kotak (x1,y1)-(x2,y2) dengan tint & alpha
function ui_nine(_spr, _x1, _y1, _x2, _y2, _col, _alpha = 1) {
    draw_sprite_stretched_ext(_spr, 0, _x1, _y1, max(1, _x2 - _x1), max(1, _y2 - _y1), _col, _alpha);
}

/// @function ui_icon_sprite(_spr, _frame, _cx, _cy, _size, _col, _alpha)
/// @description Gambar ikon sehingga PUSAT gambarnya jatuh tepat di (cx,cy) apapun origin-nya
/// (dengan origin Middle Centre kompensasinya jadi nol -- pas), di-scale supaya sisi
/// terpanjangnya = _size, ditint _col.
function ui_icon_sprite(_spr, _frame, _cx, _cy, _size, _col, _alpha = 1) {
    if (!sprite_exists(_spr)) return;
    var _w = sprite_get_width(_spr);
    var _h = sprite_get_height(_spr);
    var _scale = _size / max(_w, _h);
    _frame = clamp(_frame, 0, sprite_get_number(_spr) - 1);
    draw_sprite_ext(_spr,
        _frame,
        _cx + (sprite_get_xoffset(_spr) - _w / 2) * _scale,
        _cy + (sprite_get_yoffset(_spr) - _h / 2) * _scale,
        _scale, _scale, 0, _col, _alpha);
}

/// @function ui_rr_fill(_x1, _y1, _x2, _y2, _r, _col, _alpha)
/// @description Kotak rounded ISI -- spr_ui_card ditint (_r hanya untuk fallback)
function ui_rr_fill(_x1, _y1, _x2, _y2, _r, _col, _alpha = 1) {
    if (sprite_exists(spr_ui_card)) {
        ui_nine(spr_ui_card, _x1, _y1, _x2, _y2, _col, _alpha);
    } else {
        draw_set_colour(_col);
        draw_set_alpha(_alpha);
        draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, false);
        draw_set_alpha(1);
        draw_set_colour(UI_COL_TEXT);
    }
}

/// @function ui_rr_line(_x1, _y1, _x2, _y2, _r, _col, _alpha)
/// @description Kotak rounded GARIS TEPI -- spr_ui_card_line ditint
function ui_rr_line(_x1, _y1, _x2, _y2, _r, _col, _alpha = 1) {
    if (sprite_exists(spr_ui_card_line)) {
        ui_nine(spr_ui_card_line, _x1, _y1, _x2, _y2, _col, _alpha);
    } else {
        draw_set_colour(_col);
        draw_set_alpha(_alpha);
        draw_roundrect_ext(_x1, _y1, _x2, _y2, _r, _r, true);
        draw_set_alpha(1);
        draw_set_colour(UI_COL_TEXT);
    }
}

/// @function ui_glow_rr(_x1, _y1, _x2, _y2, _r, _col, _strength)
/// @description Glow di sekeliling kotak -- spr_ui_card_glow ditint, digambar sedikit lebih besar
function ui_glow_rr(_x1, _y1, _x2, _y2, _r, _col, _strength = 0.35) {
    if (sprite_exists(spr_ui_card_glow)) {
        var _g = 6 * ui_scale();
        ui_nine(spr_ui_card_glow, _x1 - _g, _y1 - _g, _x2 + _g, _y2 + _g, _col, _strength);
    } else {
        for (var _i = 1; _i <= 4; _i++) {
            ui_rr_line(_x1 - _i, _y1 - _i, _x2 + _i, _y2 + _i, _r + _i, _col, _strength / (_i * 1.6));
        }
    }
}

/// @function ui_dot(_cx, _cy, _r, _col)
/// @description Titik menyala -- spr_ui_glow_dot: halo besar redup + inti kecil terang
function ui_dot(_cx, _cy, _r, _col) {
    if (sprite_exists(spr_ui_glow_dot)) {
        ui_icon_sprite(spr_ui_glow_dot, 0, _cx, _cy, _r * 5, _col, 0.35);
        ui_icon_sprite(spr_ui_glow_dot, 0, _cx, _cy, _r * 2.4, _col, 1);
    } else {
        draw_set_colour(_col);
        draw_set_alpha(0.25);
        draw_circle(_cx, _cy, _r * 2, false);
        draw_set_alpha(1);
        draw_circle(_cx, _cy, _r, false);
        draw_set_colour(UI_COL_TEXT);
    }
}

// ============================================================================
// IKON -- signature: (_cx, _cy, _s, _col); _s = setengah ukuran, gambar = _s * 2
// ============================================================================

function ui_icon_play(_cx, _cy, _s, _col)   { ui_icon_sprite(spr_ui_icon_play,   0, _cx, _cy, _s * 2, _col); }
function ui_icon_back(_cx, _cy, _s, _col)   { ui_icon_sprite(spr_ui_icon_back,   0, _cx, _cy, _s * 2, _col); }
function ui_icon_leave(_cx, _cy, _s, _col)  { ui_icon_sprite(spr_ui_icon_leave,  0, _cx, _cy, _s * 2, _col); }
function ui_icon_login(_cx, _cy, _s, _col)  { ui_icon_sprite(spr_ui_icon_login,  0, _cx, _cy, _s * 2, _col); }
function ui_icon_layers(_cx, _cy, _s, _col) { ui_icon_sprite(spr_ui_icon_layers, 0, _cx, _cy, _s * 2, _col); }
function ui_icon_refresh(_cx, _cy, _s, _col){ ui_icon_sprite(spr_ui_icon_refresh,0, _cx, _cy, _s * 2, _col); }
function ui_icon_heart(_cx, _cy, _s, _col)  { ui_icon_sprite(spr_ui_icon_heart,  0, _cx, _cy, _s * 2, _col); }
function ui_icon_youtube(_cx, _cy, _s, _col){ ui_icon_sprite(spr_ui_icon_youtube,0, _cx, _cy, _s * 2, _col); }
function ui_icon_person(_cx, _cy, _s, _col) { ui_icon_sprite(spr_ui_icon_person, 0, _cx, _cy, _s * 2, _col); }
function ui_icon_check(_cx, _cy, _s, _col)  { ui_icon_sprite(spr_ui_icon_check,  0, _cx, _cy, _s * 2, _col); }
function ui_icon_clock(_cx, _cy, _s, _col)  { ui_icon_sprite(spr_ui_icon_clock,  0, _cx, _cy, _s * 2, _col); }
function ui_icon_plus(_cx, _cy, _s, _col)   { ui_icon_sprite(spr_ui_icon_plus,   0, _cx, _cy, _s * 2, _col); }
function ui_icon_pencil(_cx, _cy, _s, _col) { ui_icon_sprite(spr_ui_icon_pencil, 0, _cx, _cy, _s * 2, _col); }

/// @function ui_icon_lock(_cx, _cy, _s, _col, _locked)
/// @description Frame 0 = terkunci, frame 1 = terbuka (di-clamp kalau frame-nya kurang)
function ui_icon_lock(_cx, _cy, _s, _col, _locked = true) {
    ui_icon_sprite(spr_ui_icon_lock, _locked ? 1 : 0, _cx, _cy, _s * 2, _col);
}

/// @function ui_icon_eye(_cx, _cy, _s, _col, _open)
/// @description Frame 0 = mata terbuka, frame 1 = mata dicoret
function ui_icon_eye(_cx, _cy, _s, _col, _open = true) {
    ui_icon_sprite(spr_ui_icon_eye, _open ? 1 : 0, _cx, _cy, _s * 2, _col);
}

// ============================================================================
// KOMPONEN
// ============================================================================

/// @function ui_bg_draw(_w, _h)
/// @description Latar tema: dasar gelap + grid tipis + bloom spr_ui_glow_dot ungu
function ui_bg_draw(_w, _h) {
    randomise()
    static _x_bg_start = -random(sprite_get_width(spr_bg_1))
    static _bg_offset1 = 0;
    static _bg_offset2 = 0;
    
    // Gerak ke kiri
    _bg_offset1 -= 0.20;
    _bg_offset2 -= 0.35;
    
    // Gambar layer background
    var _sprs = [spr_bg_1, spr_bg_2];
    
    for (var _i = 0; _i < array_length(_sprs); _i++) {
        var _spr = _sprs[_i];
        if (!sprite_exists(_spr)) continue;
        
        var _bg_offset = _i == 0 ? _bg_offset1 : _bg_offset2
        var _sw = sprite_get_width(_spr);
        var _sh = sprite_get_height(_spr);
        
        // Scale agar memenuhi tinggi area
        var _scale = _h / _sh;
        var _draw_w = _sw * _scale;
        
        // Loop offset agar seamless
        while (_bg_offset <= -_draw_w)
            _bg_offset += _draw_w;
        
        // Gambar berulang agar seamless
        for (var _x = _bg_offset; _x < _w + _draw_w; _x += _draw_w) {
            draw_sprite_ext(_spr, 0, _x, 0, _scale, _scale, 0, c_white, 1);
        }
    }
    
    static _grid_offset = 0;
    
    draw_set_alpha(0.9)
    draw_set_colour(UI_COL_BG);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(0.1)
    draw_set_colour(UI_COL_PRIMARY);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1)
    
    var _cell = 60 * ui_scale();
    
    // Kecepatan gerak grid
    _grid_offset += 1;
    if (_grid_offset >= _cell) _grid_offset -= _cell;
    
    draw_set_colour(UI_COL_GRID);
    draw_set_alpha(0.1);
    
    // Garis vertikal
    for (var _x = 0; _x <= _w; _x += _cell) {
        draw_line(_x, 0, _x, _h);
    }
    
    // Garis horizontal bergerak ke bawah terus
    for (var _y = -_cell + _grid_offset; _y <= _h + _cell; _y += _cell) {
        draw_line(0, _y, _w, _y);
    }
    
    draw_set_alpha(1);
    draw_set_colour(UI_COL_TEXT);
}

/// @function ui_corner_deco_draw(_w)
/// @description Hiasan pojok atas
function ui_corner_deco_draw(_w) {
    var _s = ui_scale();
    draw_set_font(fnt_ui);
    
    // Label versi (kiri)
    var _ver_tw = string_width(UI_VERSION_LABEL) * 0.8 * _s;
    ui_text_c(16 * _s + _ver_tw / 2, 18 * _s, UI_VERSION_LABEL, 0.8 * _s, UI_COL_PRIMARY, 0.4);
}

/// @function ui_panel_draw(_x1, _y1, _x2, _y2)
/// @description Panel/kartu kaca gelap: bayangan + isi gelap + border ungu tipis
function ui_panel_draw(_x1, _y1, _x2, _y2) {
    var _r = 14 * ui_scale();
    ui_rr_fill(_x1 + 3, _y1 + 5, _x2 + 3, _y2 + 5, _r, c_black, 0.35);
    ui_rr_fill(_x1, _y1, _x2, _y2, _r, UI_COL_BG_PANEL, 0.92);
    ui_rr_line(_x1, _y1, _x2, _y2, _r, UI_COL_PRIMARY, 0.18);
}

/// @function ui_header_draw(_cx, _y, _kicker, _title, _title_scale)
/// @description Kepala layar: kicker + judul ber-glow + garis pendek
function ui_header_draw(_cx, _y, _kicker, _title, _title_scale) {
    var _s = ui_scale();
    draw_set_font(fnt_ui);
    ui_text_c(_cx, _y, ui_spaced(_kicker), 0.8 * _s, UI_COL_PRIMARY_HI, 0.9);
    
    var _ty = _y + 32 * _s;
    draw_set_font(fnt_ui_title);
    for (var _i = 3; _i >= 1; _i--) {
        ui_text_c(_cx, _ty, _title, _title_scale, UI_COL_PRIMARY, 0.06 * _i);
    }
    ui_text_c(_cx, _ty, _title, _title_scale, UI_COL_TEXT);
    draw_set_font(fnt_ui);
    
    var _ly = _ty + 20 * _s * _title_scale;
    var _lw = 70 * _s;
    draw_set_colour(UI_COL_PRIMARY_HI);
    draw_set_alpha(0.6);
    draw_line_width(_cx - _lw, _ly, _cx + _lw, _ly, 2);
    draw_set_alpha(1);
    draw_set_colour(UI_COL_TEXT);
    
    return _ly;
}

/// @function ui_badge_draw(_cx, _cy, _text, _col)
/// @description Badge pil (HOST / READY) -- spr_ui_pill ditint + glow + teks gelap
function ui_badge_draw(_cx, _cy, _text, _col) {
    var _s = ui_scale();
    draw_set_font(fnt_ui);
    var _tw = string_width(_text) * 0.7 * _s;
    var _x1 = _cx - _tw / 2 - 7 * _s;
    var _x2 = _cx + _tw / 2 + 7 * _s;
    var _y1 = _cy - 9 * _s;
    var _y2 = _cy + 9 * _s;
    ui_glow_rr(_x1, _y1, _x2, _y2, 9 * _s, _col, 0.4);
    if (sprite_exists(spr_ui_pill)) {
        ui_nine(spr_ui_pill, _x1, _y1, _x2, _y2, _col, 1);
    } else {
        ui_rr_fill(_x1, _y1, _x2, _y2, 9 * _s, _col);
    }
    ui_text_c(_cx, _cy, _text, 0.7 * _s, c_black);
}

/// @function ui_btn_draw(_x1, _y1, _x2, _y2, _label, _variant, _icon, _enabled)
/// @description Tombol sprite tintable; label+ikon digambar sebagai pasangan beranchor tengah
function ui_btn_draw(_x1, _y1, _x2, _y2, _label, _variant = "default", _icon = undefined, _enabled = true) {
    var _s = ui_scale();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = _enabled && point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2);
    var _pressed = _hover && device_mouse_check_button(0, mb_left);
    var _oy = _pressed ? 2 * _s : 0;
    var _r = 12 * _s;
    var _dim = _enabled ? 1 : 0.45;
    
    switch (_variant) {
        case "primary": {
            var _fill = UI_COL_PRIMARY;
            if (_hover) _fill = merge_colour(UI_COL_PRIMARY_HI, c_white, 0.08);
            if (_pressed) _fill = merge_colour(UI_COL_PRIMARY, c_black, 0.2);
            if (_hover) ui_glow_rr(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_PRIMARY_HI, 0.5);
            ui_rr_fill(_x1, _y1 + _oy + 3, _x2, _y2 + _oy + 3, _r, c_black, 0.35 * _dim);
            ui_rr_fill(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, _fill, _dim);
            break;
        }
        
        case "secondary": {
            var _fill = _hover ? UI_COL_SECONDARY : UI_COL_SECONDARY_LO;
            if (_pressed) _fill = merge_colour(UI_COL_SECONDARY_LO, c_black, 0.2);
            if (_hover) ui_glow_rr(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_SECONDARY, 0.5);
            ui_rr_fill(_x1, _y1 + _oy + 3, _x2, _y2 + _oy + 3, _r, c_black, 0.35 * _dim);
            ui_rr_fill(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, _fill, _dim);
            break;
        }
        
        case "ghost":
            if (_hover) {
                ui_rr_fill(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_GHOST, 0.08);
                ui_glow_rr(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_GHOST, 0.3);
            }
            ui_rr_line(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, _hover ? UI_COL_GHOST : c_white, (_hover ? 0.6 : 0.15) * _dim);
            break;
            
        case "danger_soft":
            if (_hover) ui_rr_fill(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_DANGER, 0.08);
            break;
            
        default: // "default"
            if (_hover) ui_glow_rr(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, UI_COL_PRIMARY, 0.35);
            ui_rr_fill(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, _pressed ? merge_colour(UI_COL_BG_PANEL, c_black, 0.3) : UI_COL_BG_PANEL, 0.95 * _dim);
            ui_rr_line(_x1, _y1 + _oy, _x2, _y2 + _oy, _r, _hover ? UI_COL_PRIMARY : c_white, (_hover ? 0.5 : 0.1) * _dim);
            break;
    }
    
    var _text_col = (_variant == "danger_soft") ? UI_COL_DANGER
                  : ((_variant == "ghost") ? (_hover ? UI_COL_TEXT : UI_COL_TEXT_SOFT) : UI_COL_TEXT);
    var _cx = (_x1 + _x2) / 2;
    var _cy = (_y1 + _y2) / 2 + _oy;
    var _ts = 0.9 * _s;
    
    if (!is_undefined(_icon)) {
        draw_set_alpha(_dim);
        ui_icon_text_c(_cx, _cy, _icon, 7 * _s, _label, _ts, _text_col, _dim);
        draw_set_alpha(1);
    } else {
        ui_text_c(_cx, _cy, _label, _ts, _text_col, _dim);
    }
}

/// @function ui_field_draw(_x1, _y1, _x2, _y2, _value, _placeholder, _focused, _masked, _icon)
/// @description Field input dengan isi/placeholder BERANCHOR TENGAH di area teksnya
function ui_field_draw(_x1, _y1, _x2, _y2, _value, _placeholder, _focused, _masked = false, _icon = undefined) {
    var _s = ui_scale();
    var _r = 10 * _s;
    ui_rr_fill(_x1, _y1, _x2, _y2, _r, c_white, 0.05);
    if (_focused) {
        ui_glow_rr(_x1, _y1, _x2, _y2, _r, UI_COL_PRIMARY_HI, 0.35);
        ui_rr_line(_x1, _y1, _x2, _y2, _r, UI_COL_PRIMARY_HI, 0.7);
    } else {
        ui_rr_line(_x1, _y1, _x2, _y2, _r, c_white, 0.1);
    }
    
    var _pad = 12 * _s;
    var _cy = (_y1 + _y2) / 2;
    var _left = _x1 + _pad;
    
    if (!is_undefined(_icon)) {
        _icon(_left + 4 * _s, _cy, 6 * _s, UI_COL_TEXT_DIM);
        // _left += 20 * _s;
    }
    
    // Titik tengah area teks (setelah ikon, sebelum tepi kanan)
    var _tcx = (_left + _x2 - _pad) / 2;
    var _show = _masked ? string_repeat("*", string_length(_value)) : _value;
    var _ts = 0.9 * _s;
    draw_set_font(fnt_ui);
    
    if (_value == "" && !_focused) {
        ui_text_c(_tcx, _cy, _placeholder, _ts, UI_COL_TEXT_DIM, 0.7);
    } else {
        ui_text_c(_tcx, _cy, _show, _ts, UI_COL_TEXT);
        if (_focused && ui_cursor_visible()) {
            var _cx2 = _tcx + string_width(_show) * _ts / 2 + 2;
            draw_set_colour(UI_COL_PRIMARY_HI);
            draw_line_width(_cx2, _y1 + 8 * _s, _cx2, _y2 - 8 * _s, 2);
            draw_set_colour(UI_COL_TEXT);
        }
    }
    
    if (_focused) {
        var _pulse = 0.5 + 0.5 * sin(current_time / 250);
        draw_set_alpha(0.35 + 0.65 * _pulse);
        draw_set_colour(UI_COL_PRIMARY_HI);
        draw_line_width(_x1 + _pad, _y2 - 2, _x2 - _pad, _y2 - 2, 2);
        draw_set_alpha(1);
        draw_set_colour(UI_COL_TEXT);
    }
}

/// @function ui_field_label_draw(_cx, _y, _text, _focused, _suffix_dim)
/// @description Label kecil di atas field
function ui_field_label_draw(_cx, _y, _text, _focused, _suffix_dim = "") {
    var _s = ui_scale();
    draw_set_font(fnt_ui);
    var _main = ui_spaced(_text);
    var _tw1 = string_width(_main) * 0.75 * _s;
    var _tw2 = (_suffix_dim != "") ? string_width(_suffix_dim) * 0.75 * _s : 0;
    var _gap = (_suffix_dim != "") ? 8 * _s : 0;
    var _total = _tw1 + _gap + _tw2;
    var _ly = _y - 8 * _s;
    
    ui_text_c(_cx - _total / 2 + _tw1 / 2, _ly, _main, 0.75 * _s, _focused ? UI_COL_PRIMARY_HI : UI_COL_TEXT_DIM);
    if (_suffix_dim != "") {
        ui_text_c(_cx - _total / 2 + _tw1 + _gap + _tw2 / 2, _ly, _suffix_dim, 0.75 * _s, UI_COL_TEXT_FAINT);
    }
}

/// @function ui_divider_draw(_x1, _x2, _y)
/// @description Garis pemisah tipis
function ui_divider_draw(_x1, _x2, _y) {
    draw_set_colour(c_white);
    draw_set_alpha(0.06);
    draw_line_width(_x1, _y, _x2, _y, 1);
    draw_set_alpha(1);
    draw_set_colour(UI_COL_TEXT);
}

/// @function ui_spinner_draw(_cx, _cy, _r)
/// @description Spinner: ikon refresh berputar
function ui_spinner_draw(_cx, _cy, _r) {
    var _use_icon = false;
    if (sprite_exists(spr_ui_icon_refresh)) {
        var _w = sprite_get_width(spr_ui_icon_refresh);
        var _h = sprite_get_height(spr_ui_icon_refresh);
        _use_icon = (abs(sprite_get_xoffset(spr_ui_icon_refresh) - _w / 2) <= 1)
                 && (abs(sprite_get_yoffset(spr_ui_icon_refresh) - _h / 2) <= 1);
    }
    
    if (_use_icon) {
        var _size = _r * 2.4;
        var _scale = _size / max(sprite_get_width(spr_ui_icon_refresh), sprite_get_height(spr_ui_icon_refresh));
        var _ang = -((current_time / 4) mod 360);
        draw_sprite_ext(spr_ui_icon_refresh, 0, _cx, _cy, _scale, _scale, _ang, UI_COL_PRIMARY_HI, 1);
    } else {
        var _dots = 8;
        for (var _i = 0; _i < _dots; _i++) {
            var _phase = ((current_time / 90) - _i) mod _dots;
            if (_phase < 0) _phase += _dots;
            var _px = _cx + lengthdir_x(_r, -_i * (360 / _dots) + 90);
            var _py = _cy + lengthdir_y(_r, -_i * (360 / _dots) + 90);
            if (sprite_exists(spr_ui_glow_dot)) {
                ui_icon_sprite(spr_ui_glow_dot, 0, _px, _py, 7 * ui_scale(), UI_COL_PRIMARY_HI, 0.15 + 0.85 * (1 - _phase / _dots));
            } else {
                draw_set_alpha(0.15 + 0.85 * (1 - _phase / _dots));
                draw_set_colour(UI_COL_PRIMARY_HI);
                draw_circle(_px, _py, 3 * ui_scale(), false);
            }
        }
        draw_set_alpha(1);
        draw_set_colour(UI_COL_TEXT);
    }
}

/// @function ui_toast_draw(_message, _shown_time, _gw)
/// @description Toast pil di tengah-atas layar, memudar otomatis
function ui_toast_draw(_message, _shown_time, _gw) {
    if (_message == "") return;
    var _elapsed = current_time - _shown_time;
    if (_elapsed > UI_TOAST_MS) return;
    
    var _alpha = 1;
    if (_elapsed > UI_TOAST_MS - UI_TOAST_FADE_MS) {
        _alpha = (UI_TOAST_MS - _elapsed) / UI_TOAST_FADE_MS;
    }
    
    var _s = ui_scale();
    draw_set_font(fnt_ui);
    var _ts = 0.85 * _s;
    var _tw = string_width(_message) * _ts;
    var _cx = _gw / 2;
    var _y1 = 14 * _s;
    var _y2 = _y1 + 34 * _s;
    var _x1 = _cx - _tw / 2 - 18 * _s;
    var _x2 = _cx + _tw / 2 + 18 * _s;
    
    if (sprite_exists(spr_ui_pill)) {
        ui_nine(spr_ui_pill, _x1, _y1, _x2, _y2, UI_COL_BG_PANEL, 0.95 * _alpha);
    } else {
        ui_rr_fill(_x1, _y1, _x2, _y2, 17 * _s, UI_COL_BG_PANEL, 0.95 * _alpha);
    }
    ui_rr_line(_x1, _y1, _x2, _y2, 17 * _s, UI_COL_DANGER, 0.5 * _alpha);
    ui_text_c(_cx, (_y1 + _y2) / 2, _message, _ts, UI_COL_TEXT, _alpha);
    draw_set_alpha(1);
}