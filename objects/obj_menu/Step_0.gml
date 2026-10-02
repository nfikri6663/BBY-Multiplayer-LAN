display_sync_to_window();

var _l = menu_layout();

// Deteksi konfirmasi ketikan
var _kb_visible_now = keyboard_virtual_status();
var _keyboard_confirm_pressed = ui_keyboard_confirm_check()
    || keyboard_check_pressed(vk_enter)
    || (virtual_keyboard_was_visible && !_kb_visible_now);
virtual_keyboard_was_visible = _kb_visible_now;

// Overlay ketikan HP
var _overlay_modal = (input_focus != "" && _kb_visible_now);
if (_overlay_modal) {
    var _ov = ui_kbd_overlay_layout();
    if (ui_button_clicked_gui(_ov.btn_x1, _ov.btn_y1, _ov.btn_x2, _ov.btn_y2)) {
        _keyboard_confirm_pressed = true;
    }
}

// Sinkronkan field yang lagi fokus dari keyboard_string
switch (input_focus) {
    case "room_name":     room_name_input = keyboard_string; break;
    case "room_password": room_password_input = keyboard_string; break;
    case "join_password": join_password_input = keyboard_string; break;
}

// Routing konfirmasi, lepas fokus
if (_keyboard_confirm_pressed && input_focus != "") {
    var _finished_field = input_focus;
    ui_input_end();

    if (_finished_field == "room_name") {
        // Enter/OK di nama room -> langsung lanjut isi password, tidak perlu tap lagi
        // ui_input_begin("room_password", room_password_input);
    } else if (_finished_field == "join_password") {
        // Enter/OK di password join -> langsung coba connect
        net_start_join(selected_room_ip, selected_room_port, join_password_input);
    }
}

// Selama overlay ketik HP aktif, tap di area bawahnya tidak diteruskan ke tombol menu --
// mencegah salah pencet tombol yang kebetulan ada di balik keyboard/overlay
if (_overlay_modal) exit;

switch (menu_state) {
    case "main":
        if (ui_button_clicked_gui(_l.play_x1, _l.play_y1, _l.play_x2, _l.play_y2)) {
            exit_confirm = false;
            menu_state = "select";
        } else if (!exit_confirm) {
            if (ui_button_clicked_gui(_l.exit_x1, _l.exit_y1, _l.exit_x2, _l.exit_y2)) {
                exit_confirm = true;
            }
        } else {
            // Baris konfirmasi "Yakin keluar? Batal / Keluar"
            if (ui_button_clicked_gui(_l.batal_x1, _l.confirm_y1, _l.batal_x2, _l.confirm_y2)) {
                exit_confirm = false;
            } else if (ui_button_clicked_gui(_l.keluar_x1, _l.confirm_y1, _l.keluar_x2, _l.confirm_y2)) {
                game_end();
            }
        }
        
        if (ui_button_clicked_gui(_l.yt_x1, _l.yt_y1, _l.yt_x2, _l.yt_y2)) {
            // url_open(URL_YOUTUBE);
        } else if (ui_button_clicked_gui(_l.don_x1, _l.don_y1, _l.don_x2, _l.don_y2)) {
            // url_open(URL_DONATE);
        }
        break;
        
    case "select":
        if (ui_button_clicked_gui(_l.sel_host_x1, _l.sel_host_y1, _l.sel_host_x2, _l.sel_host_y2)) {
            menu_state = "host_setup";
            room_name_input = "";
            room_password_input = "";
            host_pass_visible = false;
            ui_input_end();
        } else if (ui_button_clicked_gui(_l.sel_join_x1, _l.sel_join_y1, _l.sel_join_x2, _l.sel_join_y2)) {
            menu_state = "browse_rooms";
            net_discovery_start();
        } else if (ui_button_clicked_gui(_l.sel_back_x1, _l.sel_back_y1, _l.sel_back_x2, _l.sel_back_y2)) {
            menu_state = "main";
            exit_confirm = false;
        }
        break;
        
    case "host_setup":
        if (ui_button_clicked_gui(_l.card_x1, _l.h_room_y1, _l.card_x2, _l.h_room_y2)) {
            ui_input_begin("room_name", room_name_input);
        } else if (ui_button_clicked_gui(_l.card_x2 - _l.eye_w, _l.h_pass_y1, _l.card_x2, _l.h_pass_y2)) {
            // Toggle "mata" di ujung kanan field password
            host_pass_visible = !host_pass_visible;
        } else if (ui_button_clicked_gui(_l.card_x1, _l.h_pass_y1, _l.card_x2 - _l.eye_w, _l.h_pass_y2)) {
            ui_input_begin("room_password", room_password_input);
        } else if (ui_button_clicked_gui(_l.card_x1 + _l.pad, _l.h_create_y1, _l.card_x2 - _l.pad, _l.h_create_y2)) {
            global.net_is_host = true;
            global.net_room_name = (string_trim(room_name_input) == "") ? ("Room " + string(irandom(999))) : room_name_input;
            global.net_room_password = room_password_input;
            room_goto(room_test);
        } else if (ui_button_clicked_gui(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2)) {
            ui_input_end();
            menu_state = "select";
        }
        break;
        
    case "browse_rooms":
        discovery_prune(discovered_rooms);

        discovery_query_timer += delta_time / 1000000;
        if (discovery_query_timer >= DISC_BROADCAST_INTERVAL) {
            discovery_query_timer -= DISC_BROADCAST_INTERVAL;
            discovery_send_query(discovery_socket);
        }
        
        // Tombol REFRESH -- kosongkan daftar & langsung kirim query tanpa nunggu timer
        if (ui_button_clicked_gui(_l.refresh_x1, _l.refresh_y1, _l.refresh_x2, _l.refresh_y2)) {
            if (discovery_socket >= 0) {
                ds_map_clear(discovered_rooms);
                discovery_send_query(discovery_socket);
            }
        }
        
        // Klik baris room -- room FULL tidak bisa diklik
        var _y = _l.list_y;
        var _key = ds_map_find_first(discovered_rooms);
        var _clicked_key = "";
        var _row_index = 0;
        repeat (ds_map_size(discovered_rooms)) {
            if (_row_index >= _l.rows_visible) break;
            var _room_check = discovered_rooms[? _key];
            var _is_full = (_room_check.player_count >= 4);
            if (!_is_full && ui_button_clicked_gui(_l.list_x1, _y, _l.list_x2, _y + _l.row_h)) {
                _clicked_key = _key;
            }
            _y += _l.row_h + _l.row_gap;
            _row_index++;
            _key = ds_map_find_next(discovered_rooms, _key);
        }
        
        if (_clicked_key != "") {
            var _room = discovered_rooms[? _clicked_key];
            selected_room_ip = _room.ip;
            selected_room_name = _room.room_name;
            selected_room_port = _room.port;
            
            if (_room.has_password) {
                menu_state = "enter_password";
                join_password_input = "";
                join_pass_visible = false;
                keyboard_string = "";
            } else {
                net_start_join(_room.ip, _room.port, "");
            }
        } else if (ui_button_clicked_gui(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2)) {
            net_discovery_stop();
            menu_state = "select";
        }
        break;
        
    case "enter_password":
        if (ui_button_clicked_gui(_l.card_x2 - _l.eye_w, _l.p_pass_y1, _l.card_x2, _l.p_pass_y2)) {
            join_pass_visible = !join_pass_visible;
        } else if (ui_button_clicked_gui(_l.card_x1, _l.p_pass_y1, _l.card_x2 - _l.eye_w, _l.p_pass_y2)) {
            ui_input_begin("join_password", join_password_input);
        } else if (ui_button_clicked_gui(_l.card_x1 + _l.pad, _l.p_join_y1, _l.card_x2 - _l.pad, _l.p_join_y2)) {
            ui_input_end();
            net_start_join(selected_room_ip, selected_room_port, join_password_input);
        } else if (ui_button_clicked_gui(_l.back_x1, _l.back_y1, _l.back_x2, _l.back_y2)) {
            ui_input_end();
            menu_state = "browse_rooms";
        }
        break;
        
    case "connecting":
        join_timer += delta_time / 1000000;
        join_retry_timer += delta_time / 1000000;
        
        if (join_timer >= join_timeout_seconds) {
            show_debug_message("[JOIN] Timeout habis (" + string(join_timeout_seconds) + " detik) tanpa respons.");
            net_join_fail("Host tidak merespon (timeout).");
        } else if (join_retry_timer >= 1.0) {
            join_retry_timer -= 1.0;
            show_debug_message("[JOIN] Belum ada balasan, kirim ulang join request.");
            var _my_character_id = variable_global_exists("net_character_id") ? global.net_character_id : 0;
            var _my_username = variable_global_exists("net_username") ? global.net_username : "Player";
            net_send_join_request(join_socket, join_target_password, _my_character_id, _my_username);
        }
        
        // Pemain bisa membatalkan tanpa harus menunggu timeout 5 detik
        if (ui_button_clicked_gui(_l.conn_cancel_x1, _l.conn_cancel_y1, _l.conn_cancel_x2, _l.conn_cancel_y2)) {
            net_join_fail("Koneksi dibatalkan.");
        }
        break;
}