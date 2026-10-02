if (!is_mobile) exit;
if (instance_exists(obj_network) && !obj_network.game_started) exit;

var _spr = spr_joystick_icons;
var _move_scale = layout_move_icon_size / sprite_get_width(_spr);
var _jump_scale = layout_jump_size / sprite_get_width(_spr);
var _skill_scale = layout_skill_size / sprite_get_width(_spr);

draw_sprite_ext(_spr, 0, layout_left_cx, layout_left_cy, _move_scale, _move_scale, 0, c_white, (move_left_touch_id != -1) ? 1 : 0.55);
draw_sprite_ext(_spr, 1, layout_right_cx, layout_right_cy, _move_scale, _move_scale, 0, c_white, (move_right_touch_id != -1) ? 1 : 0.55);
draw_sprite_ext(_spr, 2, layout_jump_cx, layout_jump_cy, _jump_scale, _jump_scale, 0, c_white, (jump_touch_id != -1) ? 1 : 0.55);
draw_sprite_ext(_spr, 3, layout_skill1_cx, layout_skill1_cy, _skill_scale, _skill_scale, 0, c_white, (skill1_touch_id != -1) ? 1 : 0.55);
draw_sprite_ext(_spr, 4, layout_skill2_cx, layout_skill2_cy, _skill_scale, _skill_scale, 0, c_white, (skill2_touch_id != -1) ? 1 : 0.55);
draw_sprite_ext(_spr, 5, layout_skill3_cx, layout_skill3_cy, _skill_scale, _skill_scale, 0, c_white, (skill3_touch_id != -1) ? 1 : 0.55);