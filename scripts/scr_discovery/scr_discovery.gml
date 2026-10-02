/// @function discovery_send_query(_socket)
/// @description Client: broadcast pertanyaan "ada host aktif?" ke SEMUA port di rentang discovery
function discovery_send_query(_socket) {
    var _buff = buffer_create(1, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, DISC_QUERY);
    
    for (var _i = 0; _i < DISCOVERY_PORT_RANGE; _i++) {
        network_send_broadcast(_socket, DISCOVERY_PORT + _i, _buff, buffer_get_size(_buff));
    }
    
    buffer_delete(_buff);
}

/// @function discovery_send_announce(_socket, _room_name, _has_password, _port, _target_ip, _target_port)
/// @description Host: balas SATU client yang baru saja mengirim DISC_QUERY, lewat UDP terarah
/// (unicast) langsung ke alamat asal query itu
function discovery_send_announce(_socket, _room_name, _has_password, _player_count, _port, _target_ip, _target_port) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, DISC_ANNOUNCE);
    buffer_write(_buff, buffer_u8, _has_password ? 1 : 0);
    buffer_write(_buff, buffer_u8, _player_count);
    buffer_write(_buff, buffer_u16, _port);
    buffer_write(_buff, buffer_string, _room_name);
    
    network_send_udp(_socket, _target_ip, _target_port, _buff, buffer_get_size(_buff));
    
    buffer_delete(_buff);
}

/// @function discovery_send_announce_broadcast(_socket, _room_name, _has_password, _player_count, _port)
/// @description Host: broadcast keberadaan room ke seluruh rentang port discovery
function discovery_send_announce_broadcast(_socket, _room_name, _has_password, _player_count, _port) {
    var _buff = buffer_create(64, buffer_grow, 1);
    buffer_write(_buff, buffer_u8, DISC_ANNOUNCE);
    buffer_write(_buff, buffer_u8, _has_password ? 1 : 0);
    buffer_write(_buff, buffer_u8, _player_count);
    buffer_write(_buff, buffer_u16, _port);
    buffer_write(_buff, buffer_string, _room_name);
    
    var _result = 0;
    for (var _i = 0; _i < DISCOVERY_PORT_RANGE; _i++) {
        var _r = network_send_broadcast(_socket, DISCOVERY_PORT + _i, _buff, buffer_get_size(_buff));
        if (_r < 0) _result = _r;
    }
    
    buffer_delete(_buff);
    
    return _result;
}

/// @function discovery_prune(_discovered_rooms)
/// @description Client: hapus room yang sudah lama tidak mengirim broadcast (dianggap sudah tidak aktif)
function discovery_prune(_discovered_rooms) {
    var _stale_ips = ds_list_create();
    var _key = ds_map_find_first(_discovered_rooms);
    repeat (ds_map_size(_discovered_rooms)) {
        var _room = _discovered_rooms[? _key];
        if (current_time - _room.last_seen > DISC_ROOM_TIMEOUT * 1000) {
            ds_list_add(_stale_ips, _key);
        }
        _key = ds_map_find_next(_discovered_rooms, _key);
    }
    
    for (var _i = 0; _i < ds_list_size(_stale_ips); _i++) {
        ds_map_delete(_discovered_rooms, _stale_ips[| _i]);
    }
    
    ds_list_destroy(_stale_ips);
}

/// @function net_discovery_start()
/// @description Client: buka socket UDP buat dengar broadcast room & kirim DISC_QUERY
function net_discovery_start() {
    if (discovery_socket >= 0) return;
    
    // Coba tiap port di rentang discovery -- kalau semua terpakai (banyak instance di satu
    // device), fallback ke port bebas: balasan unicast atas DISC_QUERY tetap jalan normal.
    for (var _i = 0; _i < DISCOVERY_PORT_RANGE; _i++) {
        discovery_socket = network_create_socket_ext(network_socket_udp, DISCOVERY_PORT + _i);
        if (discovery_socket >= 0) break;
    }
    if (discovery_socket < 0) {
        discovery_socket = network_create_socket(network_socket_udp);
    }
    
    ds_map_clear(discovered_rooms);
    discovery_query_timer = 0;
    
    discovery_failed = (discovery_socket < 0);
    if (discovery_failed) {
        show_debug_message("Gagal membuka socket pencarian room sama sekali.");
    }
}

/// @function net_discovery_stop()
/// @description Client: tutup socket UDP pencarian room & bersihkan daftar room yang ditemukan
function net_discovery_stop() {
    if (discovery_socket >= 0) {
        network_destroy(discovery_socket);
        discovery_socket = -1;
    }
    ds_map_clear(discovered_rooms);
    discovery_failed = false;
}