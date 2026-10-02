if (!is_mobile) exit;
if (instance_exists(obj_network) && !obj_network.game_started) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

var _move_w = _gui_h * 0.24;
var _move_h = _gui_h * 0.18;
var _move_margin = _gui_h * 0.07;
var _move_gap = _gui_h * 0.03;

var _left_x1 = _move_margin;
var _left_y1 = _gui_h - _move_margin - _move_h;
var _left_x2 = _left_x1 + _move_w;
var _left_y2 = _gui_h - _move_margin;
var _left_cx = (_left_x1 + _left_x2) * 0.5;
var _left_cy = (_left_y1 + _left_y2) * 0.5;

var _right_x1 = _left_x2 + _move_gap;
var _right_y1 = _left_y1;
var _right_x2 = _right_x1 + _move_w;
var _right_y2 = _left_y2;
var _right_cx = (_right_x1 + _right_x2) * 0.5;
var _right_cy = (_right_y1 + _right_y2) * 0.5;

var _jump_size = _gui_h * 0.25;
var _skill_size = _gui_h * 0.15;
var _cluster_margin = _gui_h * 0.07;
var _arc_gap = _gui_h * 0.045;

var _jump_r = _jump_size * 0.5;
var _skill_r = _skill_size * 0.5;
var _arc_radius = _jump_r + _skill_r + _arc_gap;

var _jump_cx = _gui_w - _cluster_margin - _jump_r;
var _jump_cy = _gui_h - _cluster_margin - _jump_r;

var _skill1_cx = _jump_cx + lengthdir_x(_arc_radius, 190); // paling bawah
var _skill1_cy = _jump_cy + lengthdir_y(_arc_radius, 190);
var _skill2_cx = _jump_cx + lengthdir_x(_arc_radius, 145); // tengah
var _skill2_cy = _jump_cy + lengthdir_y(_arc_radius, 145);
var _skill3_cx = _jump_cx + lengthdir_x(_arc_radius, 100); // paling atas
var _skill3_cy = _jump_cy + lengthdir_y(_arc_radius, 100);

layout_left_x1 = _left_x1;   layout_left_y1 = _left_y1;
layout_left_x2 = _left_x2;   layout_left_y2 = _left_y2;
layout_left_cx = _left_cx;   layout_left_cy = _left_cy;
layout_right_x1 = _right_x1; layout_right_y1 = _right_y1;
layout_right_x2 = _right_x2; layout_right_y2 = _right_y2;
layout_right_cx = _right_cx; layout_right_cy = _right_cy;
layout_move_icon_size = _move_h;

layout_jump_cx = _jump_cx;     layout_jump_cy = _jump_cy;
layout_skill1_cx = _skill1_cx; layout_skill1_cy = _skill1_cy;
layout_skill2_cx = _skill2_cx; layout_skill2_cy = _skill2_cy;
layout_skill3_cx = _skill3_cx; layout_skill3_cy = _skill3_cy;
layout_jump_size = _jump_size;
layout_skill_size = _skill_size;

input_jump_pressed = false;
input_skill1_pressed = false;
input_skill2_pressed = false;
input_skill3_pressed = false;

var _max_touch = 8;
var _left_down = false;
var _right_down = false;

for (var _i = 0; _i < _max_touch; _i++) {
    var _tx = device_mouse_x_to_gui(_i);
    var _ty = device_mouse_y_to_gui(_i);
    var _down = device_mouse_check_button(_i, mb_left);
    var _pressed = device_mouse_check_button_pressed(_i, mb_left);
    
    // -- Kiri --
    if (move_left_touch_id == _i) {
        if (_down) { _left_down = true; } else { move_left_touch_id = -1; }
    } else if (move_left_touch_id == -1 && _pressed && point_in_rectangle(_tx, _ty, _left_x1, _left_y1, _left_x2, _left_y2)) {
        move_left_touch_id = _i;
        _left_down = true;
    }
    
    // -- Kanan --
    if (move_right_touch_id == _i) {
        if (_down) { _right_down = true; } else { move_right_touch_id = -1; }
    } else if (move_right_touch_id == -1 && _pressed && point_in_rectangle(_tx, _ty, _right_x1, _right_y1, _right_x2, _right_y2)) {
        move_right_touch_id = _i;
        _right_down = true;
    }
    
    // -- Lompat --
    if (jump_touch_id == _i && !_down) {
        jump_touch_id = -1;
    } else if (jump_touch_id == -1 && _pressed && point_distance(_tx, _ty, _jump_cx, _jump_cy) <= _jump_r) {
        jump_touch_id = _i;
        input_jump_pressed = true;
    }
    
    // -- Skill 1/2/3 --
    if (skill1_touch_id == _i && !_down) {
        skill1_touch_id = -1;
    } else if (skill1_touch_id == -1 && _pressed && point_distance(_tx, _ty, _skill1_cx, _skill1_cy) <= _skill_r) {
        skill1_touch_id = _i;
        input_skill1_pressed = true;
    }
    
    if (skill2_touch_id == _i && !_down) {
        skill2_touch_id = -1;
    } else if (skill2_touch_id == -1 && _pressed && point_distance(_tx, _ty, _skill2_cx, _skill2_cy) <= _skill_r) {
        skill2_touch_id = _i;
        input_skill2_pressed = true;
    }
    
    if (skill3_touch_id == _i && !_down) {
        skill3_touch_id = -1;
    } else if (skill3_touch_id == -1 && _pressed && point_distance(_tx, _ty, _skill3_cx, _skill3_cy) <= _skill_r) {
        skill3_touch_id = _i;
        input_skill3_pressed = true;
    }
}

input_h = (_left_down && !_right_down) ? -1 : ((_right_down && !_left_down) ? 1 : 0);