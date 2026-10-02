var _type = async_load[? "type"];

switch (_type) {
    case network_type_connect:
        net_handle_connect(async_load[? "socket"]);
        break;
        
    case network_type_disconnect:
        net_handle_disconnect(async_load[? "socket"]);
        break;
        
    case network_type_data:
        var _id = async_load[? "id"];
        var _buff = async_load[? "buffer"];
        var _msg_type = buffer_read(_buff, buffer_u8);
        
        if (!is_host) {
            last_server_message_time = current_time;
        }
        
        if (_id == data_socket) {
            // --- Jalur UDP data gameplay ---
            var _ip = async_load[? "ip"];
            var _port = async_load[? "port"];
            
            switch (_msg_type) {
                case MSG_POSITION:     net_handle_position_udp(_buff, _ip, _port); break;
                case MSG_STATE_UPDATE: net_handle_state_update(_buff); break;
                case MSG_PING:         net_handle_ping_udp(_buff, _ip, _port); break;
                case MSG_PONG:         net_handle_pong(_buff); break;
            }
        } else if (_id == discovery_socket) {
            if (is_host && _msg_type == DISC_QUERY) {
                var _ip = async_load[? "ip"];
                var _port = async_load[? "port"];
                show_debug_message("[DISC] Terima DISC_QUERY dari " + _ip + ":" + string(_port) + ", balas unicast.");
                discovery_send_announce(discovery_socket, room_name, room_password != "", 1 + ds_map_size(remote_players), port, _ip, _port);
            }
        } else {
            // --- Jalur TCP ---
            switch (_msg_type) {
                case MSG_HOST_LEAVING:  net_handle_host_leaving(); break;
                case MSG_PLAYER_LEFT:   net_handle_player_left(_buff); break;
                case MSG_JOIN_REQUEST:  net_handle_join_request(_buff, _id); break;
                case MSG_PLAYER_INFO:   net_handle_player_info(_buff); break;
                case MSG_PLAYER_HEALTH: net_handle_player_health(_buff); break;
                case MSG_PLAYER_UPDATE: net_handle_player_update(_buff, _id); break;
                case MSG_READY_SET:     net_handle_ready_set(_buff, _id); break;
                case MSG_READY_STATE:   net_handle_ready_state(_buff); break;
                case MSG_GAME_START:    net_handle_game_start(); break;
                case MSG_ROOM_INFO:     net_handle_room_info(_buff); break;
            }
        }
        break;
}