if (!is_host) {
    if (current_time - last_server_message_time > server_timeout_ms) {
        show_debug_message("Host tidak merespon, kembali ke menu.");
        global.net_status_message = "Terputus dari host (timeout).";
        room_goto(room_menu);
        exit;
    }
}

if (keyboard_check_pressed(vk_escape)) {
    if (is_host) {
        net_send_host_leaving(remote_players);
    }
    room_goto(room_menu);
    exit;
}

// --- Kirim posisi/broadcast state gameplay lewat UDP, di-throttle sesuai send_rate ---
send_timer += delta_time / 1000000;
if (send_timer >= send_interval) {
    send_timer -= send_interval;
    
    if (!is_host) {
        if (data_socket >= 0 && instance_exists(obj_player)) {
            pos_seq++;
            net_send_position(data_socket, host_ip, port, pos_seq, my_id, obj_player.x, obj_player.y, obj_player.anim_state);
        }
    } else {
        if (instance_exists(obj_player)) {
            state_seq++;
            net_broadcast_state(data_socket, state_seq, remote_players, obj_player.slot, obj_player.character_id, obj_player.anim_state, obj_player.x, obj_player.y);
        }
    }
}

// --- Client: kirim ping berkala ke host lewat UDP, buat ukur latency jalur data yang sesungguhnya ---
if (!is_host) {
    ping_timer += delta_time / 1000000;
    if (ping_timer >= 1.0) {
        ping_timer -= 1.0;
        net_send_ping(data_socket, host_ip, port, current_time);
    }
}

// --- Host: broadcast keberadaan room ke LAN secara berkala ---
if (is_host) {
    discovery_timer += delta_time / 1000000;
    if (discovery_timer >= DISC_BROADCAST_INTERVAL) {
        discovery_timer -= DISC_BROADCAST_INTERVAL;
        
        var _result = discovery_send_announce_broadcast(discovery_socket, room_name, room_password != "", 1 + ds_map_size(remote_players), port);
        
        if (_result < 0 && discovery_broadcast_ok) {
            discovery_broadcast_ok = false;
            show_debug_message("Broadcast berkala melaporkan error (multi-interface / pembatasan OS?). Tetap dicoba tiap interval; jalur balas-DISC_QUERY juga tetap aktif.");
        }
    }
}