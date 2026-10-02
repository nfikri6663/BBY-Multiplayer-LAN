input_focus = "";
virtual_keyboard_was_visible = false;
username_edit = "";

/// Layout dihitung tiap pemanggilan (ikut resolusi GUI terkini), dipakai Step (klik) & Draw (render)
lobby_layout = function() {
    var _s = ui_scale();
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _cx = _gw / 2;
    
    var _w = min(_gw - 40 * _s, 720 * _s);
    var _x1 = _cx - _w / 2;
    var _x2 = _cx + _w / 2;
    var _pad = 20 * _s;
    
    // Header
    var _kicker_y = 16 * _s;
    var _title_y = _kicker_y + 26 * _s;
    var _sub_y = _title_y + 26 * _s;
    
    // Kartu utama
    var _panel_y1 = _sub_y + 22 * _s;
    
    // Baris kartu pemain (selalu 4 slot)
    var _slot_w = 100 * _s;
    var _slot_h = 80 * _s;
    var _slot_gap = 20 * _s;
    var _slots_total = _slot_w * 4 + _slot_gap * 3;
    var _slots_x1 = _cx - _slots_total / 2;
    var _slots_y1 = _panel_y1 + 34 * _s;
    var _uname_y = _slots_y1 + _slot_h + 16 * _s;
    
    var _div_y = _uname_y + 15 * _s;
    var _pick_label_y = _div_y + 15 * _s;
    
    // Grid karakter (jumlah ikut character_count, rata tengah)
    var _n = character_count();
    var _cell_gap = 10 * _s;
    var _cell_w = min(96 * _s, (_w - _pad * 2 - (_n - 1) * _cell_gap) / _n);
    var _cell_h = 80 * _s;
    var _grid_total = _cell_w * _n + _cell_gap * (_n - 1);
    var _grid_x1 = _cx - _grid_total / 2;
    var _grid_y1 = _pick_label_y + 20 * _s;
    
    var _char_name_y = _grid_y1 + _cell_h + 18 * _s;
    var _panel_y2 = _char_name_y + 20 * _s;
    
    // Bar tombol bawah
    var _btn_h = 46 * _s;
    var _btn_y1 = _gh - 22 * _s - _btn_h;
    var _ready_w = 150 * _s;
    var _play_w = 160 * _s;
    var _btn_gap = 12 * _s;
    
    return {
        s: _s, gw: _gw, gh: _gh, cx: _cx,
        panel_x1: _x1, panel_x2: _x2, pad: _pad,
        kicker_y: _kicker_y, title_y: _title_y, sub_y: _sub_y,
        panel_y1: _panel_y1, panel_y2: _panel_y2,
        slot_w: _slot_w, slot_h: _slot_h, slot_gap: _slot_gap,
        slots_x1: _slots_x1, slots_y1: _slots_y1, uname_y: _uname_y,
        div_y: _div_y, pick_label_y: _pick_label_y,
        cell_w: _cell_w, cell_h: _cell_h, cell_gap: _cell_gap,
        grid_x1: _grid_x1, grid_y1: _grid_y1,
        char_name_y: _char_name_y,
        leave_x1: _x1, leave_y1: _btn_y1, leave_x2: _x1 + 140 * _s, leave_y2: _btn_y1 + _btn_h,
        ready_x1: _x2 - _ready_w, ready_y1: _btn_y1, ready_x2: _x2, ready_y2: _btn_y1 + _btn_h,
        play_x1: _x2 - _ready_w - _btn_gap - _play_w, play_y1: _btn_y1,
        play_x2: _x2 - _ready_w - _btn_gap, play_y2: _btn_y1 + _btn_h
    };
};

/// Kumpulkan daftar pemain buat ditampilkan: DIRI SENDIRI selalu paling kiri
lobby_gather_players = function() {
    var _list = [];
    
    if (instance_exists(obj_player) && instance_exists(obj_network)) {
        array_push(_list, {
            slot: obj_player.slot,
            username: obj_player.username,
            character_id: obj_player.character_id,
            ready: obj_player.is_ready,
            is_self: true,
            is_host_player: obj_network.is_host
        });
        
        var _key = ds_map_find_first(obj_network.remote_players);
        repeat (ds_map_size(obj_network.remote_players)) {
            var _inst = obj_network.remote_players[? _key];
            if (instance_exists(_inst) && _inst.username != "") {
                array_push(_list, {
                    slot: _inst.slot,
                    username: _inst.username,
                    character_id: _inst.character_id,
                    ready: _inst.is_ready,
                    is_self: false,
                    is_host_player: (!obj_network.is_host && _key == HOST_ID)
                });
            }
            _key = ds_map_find_next(obj_network.remote_players, _key);
        }
    }
    
    // Urutkan: diri sendiri paling depan, sisanya berdasarkan slot
    array_sort(_list, function(_a, _b) {
        if (_a.is_self != _b.is_self) return _a.is_self ? -1 : 1;
        return _a.slot - _b.slot;
    });
    
    return _list;
};