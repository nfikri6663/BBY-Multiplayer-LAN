/// @function net_send_player_info(_sock, _net_id, _slot, _character_id, _username, _hp)
/// @description HOST -> SATU CLIENT (TCP): info lengkap satu pemain
function net_send_player_info(_sock, _net_id, _slot, _character_id, _username, _hp, _ready) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, MSG_PLAYER_INFO);
    buffer_write(_buff, buffer_s32, _net_id);
    buffer_write(_buff, buffer_u8, _slot);
    buffer_write(_buff, buffer_u8, _character_id);
    buffer_write(_buff, buffer_string, _username);
    buffer_write(_buff, buffer_u8, _hp);
    buffer_write(_buff, buffer_u8, _ready ? 1 : 0);
    network_send_packet(_sock, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_player_info(_buff)
/// @description CLIENT: terima info satu pemain dari host -> terapkan lewat net_player_info_apply
function net_handle_player_info(_buff) {
    if (is_host) return;
    
    var _pid = buffer_read(_buff, buffer_s32);
    var _pslot = buffer_read(_buff, buffer_u8);
    var _pcharacter_id = buffer_read(_buff, buffer_u8);
    var _pusername = buffer_read(_buff, buffer_string);
    var _php = buffer_read(_buff, buffer_u8);
    var _pready = buffer_read(_buff, buffer_u8) == 1;
    
    show_debug_message("[DEBUG] Client terima MSG_PLAYER_INFO -> pid: " + string(_pid) + ", username: \"" + _pusername + "\", hp: " + string(_php));
    
    net_player_info_apply(_pid, _pslot, _pcharacter_id, _pusername, _php, _pready);
}

/// @function net_player_info_apply(_pid, _pslot, _pcharacter_id, _pusername, _php)
/// @description CLIENT: terapkan info pemain ke instance yang sesuai
function net_player_info_apply(_pid, _pslot, _pcharacter_id, _pusername, _php, _pready) {
    if (_pslot < 0 || _pslot >= max_players_total || _pcharacter_id >= character_count()) {
        show_debug_message("[DEBUG] MSG_PLAYER_INFO ditolak (data korup?) -> pid: " + string(_pid)
            + ", slot: " + string(_pslot) + ", char: " + string(_pcharacter_id) + ", username: \"" + _pusername + "\"");
        return;
    }
    
    // Bersihkan karakter kontrol yang mungkin nyelip di username
    var _clean = "";
    for (var _i = 1; _i <= string_length(_pusername); _i++) {
        var _c = string_char_at(_pusername, _i);
        if (ord(_c) >= 32) {
            _clean += _c;
        }
    }
    _pusername = _clean;
    
    if (_pid == my_id) {
        if (instance_exists(obj_player)) {
            obj_player.hp = _php;
            obj_player.is_ready = _pready;
        }
        return;
    }
    
    var _inst;
    if (ds_map_exists(remote_players, _pid)) {
        _inst = remote_players[? _pid];
    } else {
        _inst = instance_create_layer(x, y, layer, obj_player_remote);
        _inst.net_id = _pid;
        _inst.slot = _pslot;
        ds_map_add(remote_players, _pid, _inst);
    }
    
    if (instance_exists(_inst)) {
        _inst.character_id = _pcharacter_id;
        _inst.character = character_get(_pcharacter_id);
        _inst.sprite_index = _inst.character.spr_idle;
        _inst.username = _pusername;
        _inst.hp = _php;
        _inst.is_ready = _pready;
    }
}

/// @function net_broadcast_player_info(_remote_players, _net_id, _slot, _character_id, _username, _hp, _ready)
/// @description HOST -> SEMUA CLIENT (TCP): siarkan ulang info lengkap satu pemain
function net_broadcast_player_info(_remote_players, _net_id, _slot, _character_id, _username, _hp, _ready) {
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        net_send_player_info(_key, _net_id, _slot, _character_id, _username, _hp, _ready);
        _key = ds_map_find_next(_remote_players, _key);
    }
}