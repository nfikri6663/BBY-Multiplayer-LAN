is_host = variable_global_exists("net_is_host") ? global.net_is_host : true;
host_ip = variable_global_exists("net_host_ip") ? global.net_host_ip : "127.0.0.1";
room_name = variable_global_exists("net_room_name") ? global.net_room_name : "Room Host";
room_password = variable_global_exists("net_room_password") ? global.net_room_password : "";

max_players_total = 4;
max_client = max_players_total + 1;

socket = -1;
my_id = -1;
port = -1;
game_started = false;

remote_players = ds_map_create();

slot_used = array_create(max_players_total, false);
slot_used[0] = true;

last_server_message_time = current_time;
server_timeout_ms = 5000;

send_rate = 60;
send_interval = 1 / send_rate;
send_timer = 0;

ping_ms = 0;
ping_timer = 0;

pos_seq = 0;                  // client: dinaikkan tiap kirim posisi
state_seq = 0;                // host: dinaikkan tiap broadcast state
last_state_seq_applied = -1;  // client: buat buang state update yang nyasar telat

data_socket = -1;
discovery_socket = -1;
discovery_timer = 0;
discovery_broadcast_ok = true;

if (is_host) {
    port = TCP_PORT_BASE;
    socket = network_create_server(network_socket_tcp, port, max_client);
    
    var _attempts = 0;
    while (socket < 0 && _attempts < TCP_PORT_SCAN_RANGE) {
        _attempts++;
        port = TCP_PORT_BASE + _attempts;
        socket = network_create_server(network_socket_tcp, port, max_client);
    }
    
    if (socket < 0) {
        show_debug_message("Failed to create server di semua port yang dicoba.");
        global.net_status_message = "Gagal membuat room (semua port terpakai).";
        room_goto(room_menu);
        exit;
    }
    
    show_debug_message("Server created, listening on port " + string(port));
    
    // Coba tiap port di rentang discovery -- kalau semua terpakai (banyak instance di satu
    // device), fallback ke port bebas: balasan unicast atas DISC_QUERY tetap jalan normal.
    for (var _i = 0; _i < DISCOVERY_PORT_RANGE; _i++) {
        discovery_socket = network_create_socket_ext(network_socket_udp, DISCOVERY_PORT + _i);
        if (discovery_socket >= 0) break;
    }
    if (discovery_socket < 0) {
        show_debug_message("Port " + string(DISCOVERY_PORT) + " sedang dipakai (mis. instance lain di komputer ini), balas-DISC_QUERY tidak akan berfungsi untuk room ini; tetap coba broadcast berkala.");
        discovery_socket = network_create_socket(network_socket_udp);
    }
    
    // Socket UDP khusus data gameplay (posisi/state/ping)
    data_socket = network_create_socket_ext(network_socket_udp, port);
    
    if (data_socket < 0) {
        show_debug_message("Gagal membuat data_socket UDP di port " + string(port) + ".");
        global.net_status_message = "Gagal membuat koneksi data gameplay (UDP).";
        room_goto(room_menu);
        exit;
    }
} else {
    room_name = "Memuat info room...";
    room_password = "";
    
    // Socket TCP sudah tersambung & divalidasi host
    socket = variable_global_exists("net_established_socket") ? global.net_established_socket : -1;
    my_id = variable_global_exists("net_assigned_id") ? global.net_assigned_id : -1;
    var _my_slot = variable_global_exists("net_assigned_slot") ? global.net_assigned_slot : -1;
    port = variable_global_exists("net_host_port") ? global.net_host_port : TCP_PORT_BASE;
    
    if (socket < 0) {
        show_debug_message("Tidak ada koneksi yang sudah tersambung, kembali ke menu.");
        global.net_status_message = "Belum terhubung ke host.";
        room_goto(room_menu);
        exit;
    }
    
    show_debug_message("Mengambil alih koneksi yang sudah tersambung. my_id: " + string(my_id));
    
    // Socket UDP khusus data gameplay, dipakai kirim posisi & ping ke host
    data_socket = network_create_socket(network_socket_udp);
    
    if (data_socket < 0) {
        show_debug_message("Gagal membuat data_socket UDP client.");
        global.net_status_message = "Gagal membuat koneksi data gameplay (UDP).";
        room_goto(room_menu);
        exit;
    }
    
    // Proses info pemain
    if (variable_global_exists("net_pending_player_info")) {
        var _pending = global.net_pending_player_info;
        for (var _i = 0; _i < ds_list_size(_pending); _i++) {
            var _info = _pending[| _i];
            net_player_info_apply(_info.net_id, _info.slot, _info.character_id, _info.username, _info.hp, _info.ready);
        }
        
        ds_list_clear(_pending);
    }
    
    // Minta ulang info semua pemain
    var _my_character_id = variable_global_exists("net_character_id") ? global.net_character_id : 0;
    var _my_username = variable_global_exists("net_username") ? global.net_username : "Player";
    
    net_send_join_request(socket, "", _my_character_id, _my_username);
}