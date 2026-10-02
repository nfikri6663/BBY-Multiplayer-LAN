/// @function net_handle_connect(_sock)
/// @description HOST: client baru konek secara TCP -> belum langsung diproses, tunggu MSG_JOIN_REQUEST
function net_handle_connect(_sock) {
    if (!is_host) return;
    show_debug_message("Client baru konek, menunggu join request. Socket id: " + string(_sock));
}

/// @function net_handle_disconnect(_sock)
/// @description HOST: client terputus -> bebaskan slot, hapus representasi pemainnya, kabari client lain
function net_handle_disconnect(_sock) {
    if (!is_host) return;
    if (!ds_map_exists(remote_players, _sock)) return;
    
    var _inst = remote_players[? _sock];
    if (instance_exists(_inst)) {
        net_slot_free(slot_used, _inst.slot);
        instance_destroy(_inst);
    }
    ds_map_delete(remote_players, _sock);
    
    net_send_player_left(remote_players, _sock);
}

/// @function net_send_join_request(_socket, _password, _character_id, _username)
/// @description CLIENT -> HOST (TCP): permintaan join berisi password, karakter, & username
function net_send_join_request(_socket, _password, _character_id, _username) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, MSG_JOIN_REQUEST);
    buffer_write(_buff, buffer_string, _password);
    buffer_write(_buff, buffer_u8, _character_id);
    buffer_write(_buff, buffer_string, _username);
    network_send_packet(_socket, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_join_request(_buff, _sock)
/// @description HOST: validasi password lalu kapasitas, baru kasih slot & ID resmi kalau lolos dua-duanya
function net_handle_join_request(_buff, _sock) {
    if (!is_host) return;
    
    var _password_attempt = buffer_read(_buff, buffer_string);
    var _character_id = buffer_read(_buff, buffer_u8);
    var _username = buffer_read(_buff, buffer_string);
    
    if (ds_map_exists(remote_players, _sock)) {
        var _existing = remote_players[? _sock];
        net_send_assign_id(_sock, _sock, _existing.slot);
        net_send_room_info(_sock, room_name, room_password);
        
        // Request dari socket yang sudah terdaftar = RETRY -> kirim ulang info HOST & client lain
        show_debug_message("[DEBUG] Join request RETRY dari socket " + string(_sock) + " -- kirim ulang info HOST & client lain juga.");
        net_send_player_info(_sock, HOST_ID, obj_player.slot, obj_player.character_id, obj_player.username, obj_player.hp, obj_player.is_ready);
        
        var _retry_key = ds_map_find_first(remote_players);
        repeat (ds_map_size(remote_players)) {
            if (_retry_key != _sock) {
                var _retry_inst = remote_players[? _retry_key];
                net_send_player_info(_sock, _retry_key, _retry_inst.slot, _retry_inst.character_id, _retry_inst.username, _retry_inst.hp, _retry_inst.is_ready);
            }
            _retry_key = ds_map_find_next(remote_players, _retry_key);
        }
        
        return;
    }
    
    if (room_password != "" && _password_attempt != room_password) {
        show_debug_message("Password salah dari client, ditolak.");
        net_send_wrong_password(_sock);
        return;
    }
    
    // Game sudah dimulai -> lobby tutup, tolak pemain baru
    if (game_started) {
        show_debug_message("Join ditolak: game sudah dimulai.");
        net_send_game_started(_sock);
        return;
    }
    
    var _slot = net_slot_allocate(slot_used);
    if (_slot == -1) {
        show_debug_message("Room penuh, menolak client baru.");
        net_send_room_full(_sock);
        return;
    }
    
    var _inst = instance_create_layer(x, y, layer, obj_player_remote);
    _inst.net_id = _sock;
    _inst.slot = _slot;
    _inst.character_id = _character_id;
    _inst.character = character_get(_character_id);
    _inst.sprite_index = _inst.character.spr_idle;
    _inst.username = _username;
    _inst.hp = PLAYER_MAX_HP;
    _inst.is_ready = false;
    
    ds_map_add(remote_players, _sock, _inst);
    
    net_send_assign_id(_sock, _sock, _slot);
    net_send_room_info(_sock, room_name, room_password);
    
    // Kabari semua client yang SUDAH ADA duluan soal pemain baru
    var _notify_key = ds_map_find_first(remote_players);
    repeat (ds_map_size(remote_players)) {
        if (_notify_key != _sock) {
            net_send_player_info(_notify_key, _sock, _slot, _character_id, _username, _inst.hp, _inst.is_ready);
        }
        _notify_key = ds_map_find_next(remote_players, _notify_key);
    }
    
    // Kabari pemain BARU soal HOST
    show_debug_message("[DEBUG] Kirim info HOST ke client baru -> username: \"" + obj_player.username + "\"");
    net_send_player_info(_sock, HOST_ID, obj_player.slot, obj_player.character_id, obj_player.username, obj_player.hp, obj_player.is_ready);
    
    // Kabari pemain BARU semua CLIENT lain yang sudah ada duluan
    var _existing_key = ds_map_find_first(remote_players);
    repeat (ds_map_size(remote_players)) {
        if (_existing_key != _sock) {
            var _existing_inst = remote_players[? _existing_key];
            net_send_player_info(_sock, _existing_key, _existing_inst.slot, _existing_inst.character_id, _existing_inst.username, _existing_inst.hp, _existing_inst.is_ready);
        }
        _existing_key = ds_map_find_next(remote_players, _existing_key);
    }
    
    show_debug_message("Client diterima: slot " + string(_slot) + ", karakter " + string(_character_id) + ", username \"" + _username + "\", socket " + string(_sock));
}

/// @function net_send_assign_id(_sock, _id, _slot)
/// @description HOST -> CLIENT (TCP): kirim ID resmi & slot ke client yang baru diterima
function net_send_assign_id(_sock, _id, _slot) {
    var _buff = buffer_create(6, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_ASSIGN_ID);
    buffer_write(_buff, buffer_s32, _id);
    buffer_write(_buff, buffer_u8, _slot);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_send_room_full(_sock)
/// @description HOST -> CLIENT (TCP): tolak koneksi baru karena room sudah penuh
function net_send_game_started(_sock) {
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_GAME_STARTED);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_send_room_full(_sock)
/// @description HOST -> CLIENT (TCP): tolak koneksi baru karena room sudah penuh
function net_send_room_full(_sock) {
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_ROOM_FULL);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_send_wrong_password(_sock)
/// @description HOST -> CLIENT (TCP): tolak client karena passwordnya salah
function net_send_wrong_password(_sock) {
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_WRONG_PASSWORD);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_send_host_leaving(_remote_players)
/// @description HOST -> SEMUA CLIENT (TCP): host mau keluar, semua client balik ke menu
function net_send_host_leaving(_remote_players) {
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_HOST_LEAVING);
    
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        network_send_packet(_key, _buff, buffer_get_size(_buff));
        _key = ds_map_find_next(_remote_players, _key);
    }
    
    buffer_delete(_buff);
}

/// @function net_handle_host_leaving()
/// @description CLIENT: host sengaja keluar -> langsung balik ke menu tanpa nunggu timeout
function net_handle_host_leaving() {
    if (is_host) return;
    
    show_debug_message("Host meninggalkan game.");
    global.net_status_message = "Host mengakhiri game.";
    room_goto(room_menu);
}

/// @function net_send_player_left(_remote_players, _left_id)
/// @description HOST -> SEMUA CLIENT (TCP): satu pemain baru saja keluar
function net_send_player_left(_remote_players, _left_id) {
    var _buff = buffer_create(5, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_PLAYER_LEFT);
    buffer_write(_buff, buffer_s32, _left_id);
    
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        network_send_packet(_key, _buff, buffer_get_size(_buff));
        _key = ds_map_find_next(_remote_players, _key);
    }
    
    buffer_delete(_buff);
}

/// @function net_handle_player_left(_buff)
/// @description CLIENT: terima kabar ada pemain lain yang keluar -> hapus representasinya
function net_handle_player_left(_buff) {
    if (is_host) return;
    
    var _left_id = buffer_read(_buff, buffer_s32);
    
    if (!ds_map_exists(remote_players, _left_id)) return;
    
    var _inst = remote_players[? _left_id];
    if (instance_exists(_inst)) {
        instance_destroy(_inst);
    }
    ds_map_delete(remote_players, _left_id);
}