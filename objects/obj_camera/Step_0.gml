var _screen_w = window_get_width();
var _screen_h = window_get_height();

if (_screen_w != last_screen_w || _screen_h != last_screen_h) {
    last_screen_w = _screen_w;
    last_screen_h = _screen_h;
    camera_fit_to_screen();
}

// Ikuti pemain LOKAL
if (instance_exists(obj_player)) {
    cam_x = lerp(cam_x, obj_player.x, follow_speed);
    cam_y = lerp(cam_y, obj_player.y, follow_speed);
    camera_follow_target(cam_x, cam_y, room_width, room_height);
}