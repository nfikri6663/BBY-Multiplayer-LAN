/// @function display_apply_fullscreen()
/// @description Paksa full screen SEKALI di awal game
function display_apply_fullscreen() {
    if (variable_global_exists("display_fullscreen_applied") && global.display_fullscreen_applied) return;
    global.display_fullscreen_applied = true;
    
    if (os_type == os_windows || os_type == os_linux || os_type == os_macosx) {
        if (!window_get_fullscreen()) {
            window_set_fullscreen(true);
        }
    }
}

/// @function display_sync_to_window()
/// @description Samakan render surface & GUI dengan resolusi window/layar SAAT INI (full scale,
/// 1:1 pixel).
function display_sync_to_window() {
    var _w = window_get_width();
    var _h = window_get_height();
    if (_w <= 0 || _h <= 0) return false;
    
    if (surface_get_width(application_surface) != _w || surface_get_height(application_surface) != _h) {
        surface_resize(application_surface, _w, _h);
    }
    if (display_get_gui_width() != _w || display_get_gui_height() != _h) {
        display_set_gui_size(_w, _h);
    }
    return true;
}

/// @function camera_fit_to_screen()
/// @description Hitung ukuran view kamera OTOMATIS
function camera_fit_to_screen() {
    if (!display_sync_to_window()) return;
    
    var _screen_w = window_get_width();
    var _screen_h = window_get_height();
    var _aspect = _screen_w / _screen_h;
    
    var _view_h = room_height;
    var _view_w = _view_h * _aspect;
    
    if (_view_w > room_width) {
        _view_w = room_width;
        _view_h = _view_w / _aspect;
    }
    
    camera_set_view_size(view_camera[0], _view_w, _view_h);
    
    view_xport[0] = 0;
    view_yport[0] = 0;
    view_wport[0] = _screen_w;
    view_hport[0] = _screen_h;
}

/// @function camera_follow_target(_target_x, _target_y, _room_w, _room_h)
/// @description Posisikan kamera supaya _target_x/_target_y ada di tengah layar
function camera_follow_target(_target_x, _target_y, _room_w, _room_h) {
    var _cam = view_camera[0];
    var _view_w = camera_get_view_width(_cam);
    var _view_h = camera_get_view_height(_cam);
    
    var _cam_x, _cam_y;
    
    if (_view_w >= _room_w) {
        _cam_x = (_room_w - _view_w) / 2;
    } else {
        _cam_x = clamp(_target_x - _view_w / 2, 0, _room_w - _view_w);
    }
    
    if (_view_h >= _room_h) {
        _cam_y = (_room_h - _view_h) / 2;
    } else {
        _cam_y = clamp(_target_y - _view_h / 2, 0, _room_h - _view_h);
    }
    
    camera_set_view_pos(_cam, _cam_x, _cam_y);
}