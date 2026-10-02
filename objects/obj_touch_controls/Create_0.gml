is_mobile = (os_type == os_android) || (os_type == os_ios);

move_left_touch_id = -1;
move_right_touch_id = -1;
input_h = 0;

jump_touch_id = -1;
skill1_touch_id = -1;
skill2_touch_id = -1;
skill3_touch_id = -1;

input_jump_pressed = false;
input_skill1_pressed = false;
input_skill2_pressed = false;
input_skill3_pressed = false;

layout_left_x1 = 0; layout_left_y1 = 0; layout_left_x2 = 0; layout_left_y2 = 0;
layout_left_cx = 0; layout_left_cy = 0;
layout_right_x1 = 0; layout_right_y1 = 0; layout_right_x2 = 0; layout_right_y2 = 0;
layout_right_cx = 0; layout_right_cy = 0;
layout_move_icon_size = 0;

layout_jump_cx = 0; layout_jump_cy = 0;
layout_skill1_cx = 0; layout_skill1_cy = 0;
layout_skill2_cx = 0; layout_skill2_cy = 0;
layout_skill3_cx = 0; layout_skill3_cy = 0;
layout_jump_size = 0;
layout_skill_size = 0;