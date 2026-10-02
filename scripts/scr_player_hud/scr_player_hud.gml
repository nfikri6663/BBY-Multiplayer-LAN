/// @function player_hud_draw(_x, _top_y, _username, _hp)
/// @description Gambar username & bar HP di atas titik _top_y
function player_hud_draw(_x, _top_y, _username, _hp) {
    var _bar_w = 46;
    var _bar_h = 6;
    var _bx1 = _x - _bar_w / 2;
    var _by2 = _top_y - 6;
    var _by1 = _by2 - _bar_h;
    var _ratio = clamp(_hp / PLAYER_MAX_HP, 0, 1);
    
    // Latar bar
    draw_set_alpha(0.6);
    draw_set_colour(c_black);
    draw_rectangle(_bx1 - 1, _by1 - 1, _bx1 + _bar_w + 1, _by2 + 1, false);
    draw_set_alpha(1);
    
    // Isi bar: hijau saat penuh, memerah seiring darah berkurang
    if (_ratio > 0) {
        draw_set_colour(merge_colour(c_red, c_lime, _ratio));
        draw_rectangle(_bx1, _by1, _bx1 + _bar_w * _ratio, _by2, false);
    }
    
    // Username di atas bar
    if (_username != "") {
        draw_set_colour(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_text(_x, _by1 - 3, _username);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    
    draw_set_colour(c_white);
}