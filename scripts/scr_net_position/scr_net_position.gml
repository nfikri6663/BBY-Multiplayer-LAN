/// @function net_send_position(_socket, _host_ip, _host_port, _seq, _my_id, _x, _y)
/// @description Client kirim posisi lokal ke host lewat UDP
function net_send_position(_socket, _host_ip, _host_port, _seq, _my_id, _x, _y, _anim_state) {
    var _buff = buffer_create(18, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_POSITION);
    buffer_write(_buff, buffer_u32, _seq);
    buffer_write(_buff, buffer_s32, _my_id);
    buffer_write(_buff, buffer_f32, _x);
    buffer_write(_buff, buffer_f32, _y);
    buffer_write(_buff, buffer_u8, _anim_state);
    network_send_udp(_socket, _host_ip, _host_port, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_position_udp(_buff, _ip, _port)
/// @description Host terima update posisi client lewat UDP -> buang kalau nyasar/telat, catat alamat UDP-nya, simpan ke buffer snapshot
function net_handle_position_udp(_buff, _ip, _port) {
    if (!is_host) return;
    
    var _seq = buffer_read(_buff, buffer_u32);
    var _sender_net_id = buffer_read(_buff, buffer_s32);
    var _x = buffer_read(_buff, buffer_f32);
    var _y = buffer_read(_buff, buffer_f32);
    var _anim_state = buffer_read(_buff, buffer_u8);
    
    if (!ds_map_exists(remote_players, _sender_net_id)) return;
    
    var _inst = remote_players[? _sender_net_id];
    if (!instance_exists(_inst)) return;
    
    if (_inst.last_pos_seq_applied != -1 && _seq <= _inst.last_pos_seq_applied) return;
    _inst.last_pos_seq_applied = _seq;
    
    _inst.udp_ip = _ip;
    _inst.udp_port = _port;
    _inst.net_x = _x;
    _inst.net_y = _y;
    _inst.anim_state = _anim_state;
    net_update_snapshot_timing(_inst);
    ds_list_add(_inst.snapshot_buffer, { time: current_time, x: _x, y: _y });
}

/// @function net_broadcast_state(_socket, _seq, _remote_players, _host_slot, _host_character_id, _host_x, _host_y)
/// @description Host broadcast posisi, slot, & karakter semua pemain lewat UDP
function net_broadcast_state(_socket, _seq, _remote_players, _host_slot, _host_character_id, _host_anim_state, _host_x, _host_y) {
    var _count = 1 + ds_map_size(_remote_players);
    var _buff = buffer_create(64, buffer_grow, 1);
    
    buffer_write(_buff, buffer_u8, MSG_STATE_UPDATE);
    buffer_write(_buff, buffer_u32, _seq);
    buffer_write(_buff, buffer_u8, _count);
    
    buffer_write(_buff, buffer_s32, HOST_ID);
    buffer_write(_buff, buffer_u8, _host_slot);
    buffer_write(_buff, buffer_u8, _host_character_id);
    buffer_write(_buff, buffer_u8, _host_anim_state);
    buffer_write(_buff, buffer_f32, _host_x);
    buffer_write(_buff, buffer_f32, _host_y);
    
    var _key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        var _inst = _remote_players[? _key];
        
        buffer_write(_buff, buffer_s32, _key);
        buffer_write(_buff, buffer_u8, _inst.slot);
        buffer_write(_buff, buffer_u8, _inst.character_id);
        buffer_write(_buff, buffer_u8, _inst.anim_state);
        buffer_write(_buff, buffer_f32, _inst.net_x);
        buffer_write(_buff, buffer_f32, _inst.net_y);
        
        _key = ds_map_find_next(_remote_players, _key);
    }
    
    var _send_key = ds_map_find_first(_remote_players);
    repeat (ds_map_size(_remote_players)) {
        var _inst = _remote_players[? _send_key];
        if (_inst.udp_ip != "") {
            network_send_udp(_socket, _inst.udp_ip, _inst.udp_port, _buff, buffer_get_size(_buff));
        }
        _send_key = ds_map_find_next(_remote_players, _send_key);
    }
    
    buffer_delete(_buff);
}

/// @function net_handle_state_update(_buff)
/// @description Client terima daftar posisi semua pemain lewat UDP -> buang kalau nyasar/telat,
/// lalu update tiap obj_player_remote YANG SUDAH DIKENAL
function net_handle_state_update(_buff) {
    if (is_host) return;
    
    var _seq = buffer_read(_buff, buffer_u32);
    
    if (last_state_seq_applied != -1 && _seq <= last_state_seq_applied) return;
    last_state_seq_applied = _seq;
    
    var _count = buffer_read(_buff, buffer_u8);
    
    repeat (_count) {
        var _pid = buffer_read(_buff, buffer_s32);
        var _pslot = buffer_read(_buff, buffer_u8);
        var _pcharacter_id = buffer_read(_buff, buffer_u8);
        var _panim_state = buffer_read(_buff, buffer_u8);
        var _px = buffer_read(_buff, buffer_f32);
        var _py = buffer_read(_buff, buffer_f32);
        
        if (_pid == my_id) continue;
        
        // pid yang belum dikenal DILEWATI
        if (!ds_map_exists(remote_players, _pid)) {
            show_debug_message("[DEBUG] State update: pid " + string(_pid) + " belum dikenal, dilewati (menunggu MSG_PLAYER_INFO).");
            continue;
        }
        
        var _inst = remote_players[? _pid];
        
        if (instance_exists(_inst)) {
            if (_inst.character_id != _pcharacter_id) {
                _inst.character_id = _pcharacter_id;
                _inst.character = character_get(_pcharacter_id);
                _inst.sprite_index = _inst.character.spr_idle;
            }
            _inst.anim_state = _panim_state;
            _inst.net_x = _px;
            _inst.net_y = _py;
            _inst.last_state_seen_time = current_time;
            net_update_snapshot_timing(_inst);
            ds_list_add(_inst.snapshot_buffer, { time: current_time, x: _px, y: _py });
        }
    }
    
    // Jaring pengaman: hapus pemain yang diam terus
    var _stale_ids = ds_list_create();
    var _key = ds_map_find_first(remote_players);
    repeat (ds_map_size(remote_players)) {
        var _check_inst = remote_players[? _key];
        if (!instance_exists(_check_inst) || current_time - _check_inst.last_state_seen_time > STATE_ABSENT_TIMEOUT_MS) {
            ds_list_add(_stale_ids, _key);
        }
        _key = ds_map_find_next(remote_players, _key);
    }
    
    for (var _i = 0; _i < ds_list_size(_stale_ids); _i++) {
        var _stale_id = _stale_ids[| _i];
        var _inst = remote_players[? _stale_id];
        if (instance_exists(_inst)) {
            instance_destroy(_inst);
        }
        ds_map_delete(remote_players, _stale_id);
    }
    
    ds_list_destroy(_stale_ids);
}

/// @function net_update_snapshot_timing(_inst)
/// @description Hitung ulang rata-rata jarak waktu antar update posisi buat instance ini, DAN lacak
/// gap terbesar yang baru-baru ini terjadi 
function net_update_snapshot_timing(_inst) {
    var _now = current_time;
    var _gap = _now - _inst.last_snapshot_add_time;
    _inst.last_snapshot_add_time = _now;
    
    if (_gap > 0 && _gap < 3000) {
        _inst.avg_snapshot_interval = lerp(_inst.avg_snapshot_interval, _gap, 0.15);
        _inst.recent_max_gap = max(_gap, lerp(_inst.recent_max_gap, _gap, 0.05));
    }
    
    var _delay_from_avg = _inst.avg_snapshot_interval * 2.5;
    var _delay_from_burst = _inst.recent_max_gap * 1.2;
    _inst.interp_delay_ms = clamp(max(_delay_from_avg, _delay_from_burst), 60, 600);
}