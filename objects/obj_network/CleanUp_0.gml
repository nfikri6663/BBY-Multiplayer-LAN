if (socket >= 0) {
    network_destroy(socket);
}

if (discovery_socket >= 0) {
    network_destroy(discovery_socket);
}

if (data_socket >= 0) {
    network_destroy(data_socket);
}

ds_map_destroy(remote_players);