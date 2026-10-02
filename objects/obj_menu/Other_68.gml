var _type = async_load[? "type"];

if (join_socket >= 0) {
    var _has_succeeded = ds_map_exists(async_load, "succeeded");
    show_debug_message("[JOIN] Async event masuk: type=" + string(_type) + ", id=" + string(async_load[? "id"]) + (_has_succeeded ? (", succeeded=" + string(async_load[? "succeeded"])) : ", (tanpa field succeeded)"));
}

// --- Broadcast pencarian room (UDP) ---
if (_type == network_type_data && async_load[? "id"] == discovery_socket) {
    var _buff = async_load[? "buffer"];
    var _msg_type = buffer_read(_buff, buffer_u8);
    
    if (_msg_type == DISC_ANNOUNCE) {
        var _has_password = buffer_read(_buff, buffer_u8) == 1;
        var _player_count = buffer_read(_buff, buffer_u8);
        var _port = buffer_read(_buff, buffer_u16);
        var _room_name = buffer_read(_buff, buffer_string);
        var _sender_ip = async_load[? "ip"];
        
        discovered_rooms[? _sender_ip + ":" + string(_port)] = {
            ip: _sender_ip,
            room_name: _room_name,
            has_password: _has_password,
            player_count: _player_count,
            port: _port,
            last_seen: current_time
        };
        
        show_debug_message("[DISC] Terima DISC_ANNOUNCE \"" + _room_name + "\" dari " + _sender_ip + ":" + string(_port));
    }
    exit;
}

if (_type == network_type_data) {
    var _peek_id = async_load[? "id"];
    var _known_socket = (join_socket >= 0) ? join_socket : (variable_global_exists("net_established_socket") ? global.net_established_socket : -1);
    
    if (_peek_id == _known_socket) {
        var _buff2 = async_load[? "buffer"];
        var _msg_type2 = buffer_peek(_buff2, 0, buffer_u8);
        
        if (_msg_type2 == MSG_PLAYER_INFO) {
            buffer_read(_buff2, buffer_u8); // lewati byte tipe pesan
            
            var _p_net_id = buffer_read(_buff2, buffer_s32);
            var _p_slot = buffer_read(_buff2, buffer_u8);
            var _p_character_id = buffer_read(_buff2, buffer_u8);
            var _p_username = buffer_read(_buff2, buffer_string);
            var _p_hp = buffer_read(_buff2, buffer_u8);
            var _p_ready = buffer_read(_buff2, buffer_u8) == 1;
            
            if (!variable_global_exists("net_pending_player_info")) {
                global.net_pending_player_info = ds_list_create();
            }
            ds_list_add(global.net_pending_player_info, {
                net_id: _p_net_id,
                slot: _p_slot,
                character_id: _p_character_id,
                username: _p_username,
                hp: _p_hp,
                ready: _p_ready
            });
            exit;
        }
    }
}

// --- Proses connecting ke host (TCP) ---
if (join_socket < 0) exit;

switch (_type) {
    case network_type_non_blocking_connect:
        if (async_load[? "succeeded"] != 1) {
            net_join_fail("Gagal konek ke host.");
        } else {
            // Tersambung -> langsung kirim join request.
            show_debug_message("[JOIN] TCP tersambung, kirim join request.");
            var _my_character_id = variable_global_exists("net_character_id") ? global.net_character_id : 0;
            var _my_username = variable_global_exists("net_username") ? global.net_username : "Player";
            net_send_join_request(join_socket, join_target_password, _my_character_id, _my_username);
        }
        break;
        
    case network_type_disconnect:
        net_join_fail("Host menolak koneksi.");
        break;
        
    case network_type_data:
        var _buff = async_load[? "buffer"];
        var _msg_type = buffer_read(_buff, buffer_u8);
        
        switch (_msg_type) {
            case MSG_ASSIGN_ID:
                var _my_id = buffer_read(_buff, buffer_s32);
                var _my_slot = buffer_read(_buff, buffer_u8);
                net_join_succeed(_my_id, _my_slot);
                break;
                
            case MSG_WRONG_PASSWORD:
                net_join_fail("Password salah, coba lagi.");
                break;
                
            case MSG_ROOM_FULL:
                net_join_fail("Room penuh, coba lagi nanti.");
                break;
                
            case MSG_GAME_STARTED:
                net_join_fail("Game sudah dimulai.");
                break;
        }
        break;
}