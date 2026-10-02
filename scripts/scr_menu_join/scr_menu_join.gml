/// @function net_start_join(_ip, _port, _password)
/// @description Mulai proses konek TCP ke host yang dipilih, dipanggil dari obj_menu
function net_start_join(_ip, _port, _password) {
    net_discovery_stop();
    
    join_target_ip = _ip;
    join_target_port = _port;
    join_target_password = _password;
    join_timer = 0;
    join_retry_timer = 0;
    
    join_socket = network_create_socket(network_socket_tcp);
    show_debug_message("[JOIN] Mulai connect ke " + _ip + ":" + string(_port) + ", join_socket=" + string(join_socket));
    
    var _result = network_connect(join_socket, _ip, _port);
    show_debug_message("[JOIN] network_connect() return value: " + string(_result));
    
    if (_result < 0) {
        net_join_fail("Gagal memulai koneksi.");
        return;
    }
    
    var _my_character_id = variable_global_exists("net_character_id") ? global.net_character_id : 0;
    var _my_username = variable_global_exists("net_username") ? global.net_username : "Player";
    net_send_join_request(join_socket, _password, _my_character_id, _my_username);
    
    menu_state = "connecting";
}

/// @function net_join_fail(_message)
/// @description Batalkan proses connecting, tutup socket, tampilkan pesan, balik ke daftar room
function net_join_fail(_message) {
    show_debug_message("[JOIN] GAGAL: " + _message);
    
    if (join_socket >= 0) {
        network_destroy(join_socket);
        join_socket = -1;
    }
    ui_toast(_message);
    menu_state = "browse_rooms";
    net_discovery_start();
}

/// @function net_join_succeed(_my_id, _my_slot)
/// @description Join diterima host -> serahkan socket yang sudah tersambung ke obj_network, lalu masuk room
function net_join_succeed(_my_id, _my_slot) {
    show_debug_message("[JOIN] BERHASIL: my_id=" + string(_my_id) + ", slot=" + string(_my_slot));
    
    global.net_is_host = false;
    global.net_host_ip = join_target_ip;
    global.net_established_socket = join_socket;
    global.net_assigned_id = _my_id;
    global.net_assigned_slot = _my_slot;
    global.net_host_port = join_target_port;
    
    join_socket = -1;
    room_goto(room_test);
}