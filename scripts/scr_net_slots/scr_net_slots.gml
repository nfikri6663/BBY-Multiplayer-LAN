/// @function net_slot_allocate(_slot_used)
/// @description Cari & tandai slot kosong dengan nomor terkecil. Return -1 kalau penuh
function net_slot_allocate(_slot_used) {
    for (var _i = 0; _i < array_length(_slot_used); _i++) {
        
        if (!_slot_used[_i]) {
            _slot_used[_i] = true;
            return _i;
        }
    }
    
    return -1;
}

/// @function net_slot_free(_slot_used, _slot)
/// @description Tandai slot sebagai kosong lagi supaya bisa dipakai client berikutnya
function net_slot_free(_slot_used, _slot) {
    if (_slot >= 0 && _slot < array_length(_slot_used)) {
        _slot_used[_slot] = false;
    }
}