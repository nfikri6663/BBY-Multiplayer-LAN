var _render_time = current_time - interp_delay_ms;
var _count = ds_list_size(snapshot_buffer);

var _before = -1; // index snapshot terakhir yang waktunya <= _render_time
var _after = -1;  // index snapshot pertama yang waktunya > _render_time

for (var _i = 0; _i < _count; _i++) {
    var _snap = snapshot_buffer[| _i];
    if (_snap.time <= _render_time) {
        _before = _i;
    } else {
        _after = _i;
        break;
    }
}

// Batas maksimal extrapolasi -- lewat dari ini, diam saja di posisi extrapolasi terakhir
var _extrap_max_ms = 150;

if (_before != -1 && _after != -1) {
    // Kasus normal: interpolasi di antara 2 data asli yang mengapit waktu render
    var _snap_before = snapshot_buffer[| _before];
    var _snap_after = snapshot_buffer[| _after];
    var _span = _snap_after.time - _snap_before.time;
    var _t = (_span > 0) ? clamp((_render_time - _snap_before.time) / _span, 0, 1) : 1;
    x = lerp(_snap_before.x, _snap_after.x, _t);
    y = lerp(_snap_before.y, _snap_after.y, _t);
    
    // Simpan kecepatan asli (px/ms) dari sepasang data terbaru, buat modal extrapolasi
    if (_span > 0) {
        extrap_vx = (_snap_after.x - _snap_before.x) / _span;
        extrap_vy = (_snap_after.y - _snap_before.y) / _span;
    }
} else if (_before != -1) {
    // Belum ada data baru lagi (jaringan telat/stall) -> extrapolasi singkat pakai kecepatan
    // terakhir yang diketahui, dibatasi _extrap_max_ms biar tidak kebablasan.
    var _snap = snapshot_buffer[| _before];
    var _stall_time = clamp(_render_time - _snap.time, 0, _extrap_max_ms);
    x = _snap.x + extrap_vx * _stall_time;
    y = _snap.y + extrap_vy * _stall_time;
} else if (_after != -1) {
    // Baru mulai, belum ada data cukup lama -> pakai data pertama yang ada
    var _snap = snapshot_buffer[| _after];
    x = _snap.x;
    y = _snap.y;
}
// Kalau dua-duanya -1 (buffer masih kosong sama sekali), diam di posisi spawn

// Buang data lama yang sudah pasti tidak kepakai lagi
while (ds_list_size(snapshot_buffer) > 0 && _before > 0) {
    ds_list_delete(snapshot_buffer, 0);
    _before--;
}

if (x > xprevious) {
    image_xscale = sprite_scale;
} else if (x < xprevious) {
    image_xscale = -sprite_scale;
}

var _remote_crouching = (anim_state == ANIM_STATE_CROUCH);
var _remote_attacking = (anim_state >= ANIM_STATE_ATTACK_1);
var _remote_attack_variant = _remote_attacking ? (anim_state - ANIM_STATE_ATTACK_1 + 1) : 0;

var _grounded = place_meeting(x, y + 1, obj_wall);
player_update_sprite(character, _grounded, abs(x - xprevious) > 0.05, _remote_crouching, _remote_attacking, _remote_attack_variant);