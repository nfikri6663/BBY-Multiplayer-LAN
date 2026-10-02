if (discovery_socket >= 0) {
    network_destroy(discovery_socket);
}

if (join_socket >= 0) {
    network_destroy(join_socket);
}

ds_map_destroy(discovered_rooms);