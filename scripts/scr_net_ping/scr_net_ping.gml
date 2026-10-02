/// @function net_send_ping(_socket, _host_ip, _host_port, _send_time)
/// @description Client kirim ping ke host lewat UDP
function net_send_ping(_socket, _host_ip, _host_port, _send_time) {
    var _buff = buffer_create(9, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_PING);
    buffer_write(_buff, buffer_f64, _send_time);
    network_send_udp(_socket, _host_ip, _host_port, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_send_pong(_socket, _ip, _port, _send_time)
/// @description Host balas ping client lewat UDP, ke alamat asal ping itu
function net_send_pong(_socket, _ip, _port, _send_time) {
    var _buff = buffer_create(9, buffer_fixed, 1);
    buffer_write(_buff, buffer_u8, MSG_PONG);
    buffer_write(_buff, buffer_f64, _send_time);
    network_send_udp(_socket, _ip, _port, _buff, buffer_get_size(_buff));
    buffer_delete(_buff);
}

/// @function net_handle_ping_udp(_buff, _ip, _port)
/// @description Host terima ping dari client lewat UDP -> balas langsung ke alamat asalnya
function net_handle_ping_udp(_buff, _ip, _port) {
    if (!is_host) return;
    var _send_time = buffer_read(_buff, buffer_f64);
    net_send_pong(data_socket, _ip, _port, _send_time);
}

/// @function net_handle_pong(_buff)
/// @description Client terima balasan ping -> hitung round-trip time (ping_ms)
function net_handle_pong(_buff) {
    if (is_host) return;
    var _send_time = buffer_read(_buff, buffer_f64);
    ping_ms = current_time - _send_time;
}