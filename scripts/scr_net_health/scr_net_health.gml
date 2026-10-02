/// @function net_send_player_health(_sock, _net_id, _hp)
/// @description HOST -> SATU CLIENT (TCP): HP terbaru satu pemain
function net_send_player_health(_sock, _net_id, _hp) {
    var _buff = buffer_create(6, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_PLAYER_HEALTH);
    buffer_write(_buff, buffer_s32, _net_id);
    buffer_write(_buff, buffer_u8, _hp);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_broadcast_player_health(_remote_players, _net_id, _hp)
/// @description HOST -> SEMUA CLIENT (TCP): siarkan HP terbaru satu pemain ke semua orang
function net_broadcast_player_health(_remote_players, _net_id, _hp) {
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        net_send_player_health(_key, _net_id, _hp);
        _key = ds_map_find_next(_remote_players, _key);
    }
}

/// @function net_handle_player_health(_buff)
/// @description CLIENT: terima HP terbaru satu pemain -> terapkan termasuk diri sendiri
function net_handle_player_health(_buff) {
    if (is_host) return;
    
    var _pid = buffer_read(_buff, buffer_s32);
    var _hp = buffer_read(_buff, buffer_u8);
    
    if (_pid == my_id) {
        if (instance_exists(obj_player)) {
            obj_player.hp = _hp;
        }
        return;
    }
    
    if (!ds_map_exists(remote_players, _pid)) return;
    
    var _inst = remote_players[? _pid];
    if (instance_exists(_inst)) {
        _inst.hp = _hp;
    }
}

/// @function net_health_set(_net_id, _new_hp)
/// @description HOST SAJA: patok HP seorang pemain ke nilai tertentu
function net_health_set(_net_id, _new_hp) {
    if (!is_host) return;
    
    _new_hp = clamp(_new_hp, 0, PLAYER_MAX_HP);
    
    if (_net_id == HOST_ID) {
        if (instance_exists(obj_player)) {
            obj_player.hp = _new_hp;
        }
    } else {
        if (!ds_map_exists(remote_players, _net_id)) return;
        var _inst = remote_players[? _net_id];
        if (instance_exists(_inst)) {
            _inst.hp = _new_hp;
        }
    }
    
    net_broadcast_player_health(remote_players, _net_id, _new_hp);
}

/// @function net_health_damage(_net_id, _amount)
/// @description HOST SAJA: kurangi HP pemain sebanyak _amount (nilai negatif = heal)
function net_health_damage(_net_id, _amount) {
    if (!is_host) return;
    
    var _current;
    if (_net_id == HOST_ID) {
        if (!instance_exists(obj_player)) return;
        _current = obj_player.hp;
    } else {
        if (!ds_map_exists(remote_players, _net_id)) return;
        _current = remote_players[? _net_id].hp;
    }
    
    net_health_set(_net_id, _current - _amount);
}