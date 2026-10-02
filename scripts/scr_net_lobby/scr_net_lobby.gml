/// @function net_lobby_set_identity(_username, _character_id)
/// @description Ganti username/karakter DIRI SENDIRI dari lobby
function net_lobby_set_identity(_username, _character_id) {
    global.net_username = _username;         // biar kepakai lagi kalau keluar-masuk room
    global.net_character_id = _character_id;
    
    if (instance_exists(obj_player)) {
        obj_player.username = _username;
        obj_player.character_id = _character_id;
        obj_player.character = character_get(_character_id);
        obj_player.sprite_index = obj_player.character.spr_idle;
    }
    
    if (is_host) {
        net_broadcast_player_info(remote_players, HOST_ID, obj_player.slot, _character_id, _username, obj_player.hp, obj_player.is_ready);
    } else {
        net_send_player_update(socket, _username, _character_id);
    }
}

/// @function net_send_player_update(_socket, _username, _character_id)
/// @description CLIENT -> HOST (TCP): ganti username/karakter
function net_send_player_update(_socket, _username, _character_id) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, MSG_PLAYER_UPDATE);
    buffer_write(_buff, buffer_string, _username);
    buffer_write(_buff, buffer_u8, _character_id);
    network_send_packet(_socket, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_player_update(_buff, _sock)
/// @description HOST: terapkan identitas baru client, lalu siarkan versi resminya ke semua client
function net_handle_player_update(_buff, _sock) {
    if (!is_host) return;
    if (!ds_map_exists(remote_players, _sock)) return;
    
    var _username = buffer_read(_buff, buffer_string);
    var _character_id = buffer_read(_buff, buffer_u8);
    
    var _inst = remote_players[? _sock];
    if (!instance_exists(_inst)) return;
    
    _inst.username = _username;
    _inst.character_id = _character_id;
    _inst.character = character_get(_character_id);
    _inst.sprite_index = _inst.character.spr_idle;
    
    net_broadcast_player_info(remote_players, _sock, _inst.slot, _character_id, _username, _inst.hp, _inst.is_ready);
}

/// @function net_lobby_set_ready(_ready)
/// @description Set status siap DIRI SENDIRI. Host: terapkan & siarkan. Client: terapkan lokal + lapor host.
function net_lobby_set_ready(_ready) {
    if (instance_exists(obj_player)) {
        obj_player.is_ready = _ready;
    }
    
    if (is_host) {
        net_broadcast_ready_state(remote_players, HOST_ID, _ready);
    } else {
        var _buff = buffer_create(2, buffer_fixed, 1);
        buffer_write(_buff, buffer_u8, MSG_READY_SET);
        buffer_write(_buff, buffer_u8, _ready ? 1 : 0);
        network_send_packet(socket, _buff, buffer_get_size(_buff));
        buffer_delete(_buff);
    }
}

/// @function net_handle_ready_set(_buff, _sock)
/// @description HOST: terima status siap dari satu client -> catat & siarkan ke semua client
function net_handle_ready_set(_buff, _sock) {
    if (!is_host) return;
    if (!ds_map_exists(remote_players, _sock)) return;
    
    var _ready = buffer_read(_buff, buffer_u8) == 1;
    
    var _inst = remote_players[? _sock];
    if (instance_exists(_inst)) {
        _inst.is_ready = _ready;
    }
    
    net_broadcast_ready_state(remote_players, _sock, _ready);
}

/// @function net_broadcast_ready_state(_remote_players, _net_id, _ready)
/// @description HOST -> SEMUA CLIENT (TCP): status siap resmi seorang pemain
function net_broadcast_ready_state(_remote_players, _net_id, _ready) {
    var _buff = buffer_create(6, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_READY_STATE);
    buffer_write(_buff, buffer_s32, _net_id);
    buffer_write(_buff, buffer_u8, _ready ? 1 : 0);
    
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        network_send_packet(_key, _buff, buffer_get_size(_buff));
        _key = ds_map_find_next(_remote_players, _key);
    }
    
    buffer_delete(_buff);
}

/// @function net_handle_ready_state(_buff)
/// @description CLIENT: terima status siap resmi seorang pemain
function net_handle_ready_state(_buff) {
    if (is_host) return;
    
    var _pid = buffer_read(_buff, buffer_s32);
    var _ready = buffer_read(_buff, buffer_u8) == 1;
    
    if (_pid == my_id) {
        if (instance_exists(obj_player)) {
            obj_player.is_ready = _ready;
        }
        return;
    }
    
    if (!ds_map_exists(remote_players, _pid)) return;
    var _inst = remote_players[? _pid];
    if (instance_exists(_inst)) {
        _inst.is_ready = _ready;
    }
}

/// @function net_lobby_all_ready()
/// @description HOST: true kalau SEMUA pemain siap -- termasuk host sendiri
function net_lobby_all_ready() {
    if (instance_exists(obj_player) && !obj_player.is_ready) return false;
    
    var _key = ds_map_find_first(remote_players);
    repeat (ds_map_size(remote_players)) {
        var _inst = remote_players[? _key];
        if (instance_exists(_inst) && !_inst.is_ready) return false;
        _key = ds_map_find_next(remote_players, _key);
    }
    return true;
}

/// @function net_lobby_start_game()
/// @description HOST: mulai game -- set fase lokal & siarkan MSG_GAME_START ke semua client
function net_lobby_start_game() {
    if (!is_host) return;
    
    game_started = true;
    
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_GAME_START);
    
    var _key = ds_map_find_first(remote_players);
    repeat (ds_map_size(remote_players)) {
        network_send_packet(_key, _buff, buffer_get_size(_buff));
        _key = ds_map_find_next(remote_players, _key);
    }
    
    buffer_delete(_buff);
}

/// @function net_handle_game_start()
/// @description CLIENT: host menekan mulai -> keluar dari fase lobby
function net_handle_game_start() {
    if (is_host) return;
    game_started = true;
}

/// @function net_send_room_info(_sock, _room_name, _room_password)
/// @description HOST -> SATU CLIENT (TCP): nama & password room, buat ditampilkan di lobby
function net_send_room_info(_sock, _room_name, _room_password) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, MSG_ROOM_INFO);
    buffer_write(_buff, buffer_string, _room_name);
    buffer_write(_buff, buffer_string, _room_password);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_room_info(_buff)
/// @description CLIENT: simpan nama & password room resmi dari host
function net_handle_room_info(_buff) {
    if (is_host) return;
    room_name = buffer_read(_buff, buffer_string);
    room_password = buffer_read(_buff, buffer_string);
}