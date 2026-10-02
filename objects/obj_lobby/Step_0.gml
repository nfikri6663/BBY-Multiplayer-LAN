if (!instance_exists(obj_network) || !instance_exists(obj_player)) exit;
if (obj_network.game_started) exit; // lobby selesai

var _l = lobby_layout();

// --- Konfirmasi ketikan username ---
var _kb_visible_now = keyboard_virtual_status();
var _confirm = ui_keyboard_confirm_check()
    || keyboard_check_pressed(vk_enter)
    || (virtual_keyboard_was_visible && !_kb_visible_now);
virtual_keyboard_was_visible = _kb_visible_now;

var _overlay_modal = (input_focus != "" && _kb_visible_now);
if (_overlay_modal) {
    var _ov = ui_kbd_overlay_layout();
    if (ui_button_clicked_gui(_ov.btn_x1, _ov.btn_y1, _ov.btn_x2, _ov.btn_y2)) {
        _confirm = true;
    }
}

if (input_focus == "username") {
    username_edit = keyboard_string;
    
    if (_confirm) {
        ui_input_end();
        var _new_name = (string_trim(username_edit) == "") ? obj_player.username : username_edit;
        with (obj_network) {
            net_lobby_set_identity(_new_name, obj_player.character_id);
        }
    }
}

if (_overlay_modal) exit; // jangan teruskan tap ke tombol di balik overlay ketik

// --- Klik username sendiri ---
var _self_cx = _l.slots_x1 + _l.slot_w / 2;
if (ui_button_clicked_gui(_self_cx - _l.slot_w / 2, _l.uname_y - 12 * _l.s, _self_cx + _l.slot_w / 2, _l.uname_y + 12 * _l.s)) {
    username_edit = obj_player.username;
    ui_input_begin("username", username_edit);
}

// --- Grid PILIH KARAKTER: klik kartu = langsung ganti karakter ---
var _n = character_count();
for (var _i = 0; _i < _n; _i++) {
    var _cx1 = _l.grid_x1 + _i * (_l.cell_w + _l.cell_gap);
    if (ui_button_clicked_gui(_cx1, _l.grid_y1, _cx1 + _l.cell_w, _l.grid_y1 + _l.cell_h)) {
        if (_i != obj_player.character_id) {
            var _picked = _i;
            with (obj_network) {
                net_lobby_set_identity(obj_player.username, _picked);
            }
        }
    }
}

// --- Tombol READY ---
if (ui_button_clicked_gui(_l.ready_x1, _l.ready_y1, _l.ready_x2, _l.ready_y2)) {
    with (obj_network) {
        net_lobby_set_ready(!obj_player.is_ready);
    }
}

// --- Tombol PLAY! (host saja, aktif kalau semua pemain siap) ---
if (obj_network.is_host && ui_button_clicked_gui(_l.play_x1, _l.play_y1, _l.play_x2, _l.play_y2)) {
    with (obj_network) {
        if (net_lobby_all_ready()) {
            net_lobby_start_game();
        }
    }
}

// --- Tombol LEAVE ---
if (ui_button_clicked_gui(_l.leave_x1, _l.leave_y1, _l.leave_x2, _l.leave_y2)) {
    with (obj_network) {
        if (is_host) {
            net_send_host_leaving(remote_players);
        }
    }
    room_goto(room_menu);
}