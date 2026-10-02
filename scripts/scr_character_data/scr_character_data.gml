#macro PLAYER_DISPLAY_SIZE 64
#macro PLAYER_SPRITE_NATIVE_SIZE 250
#macro PLAYER_MAX_HP 100

/// @function character_data_init()
/// @description Isi global.character_list sekali di awal
function character_data_init() {
    global.character_list = [
        {
            icon: spr_gempa_icon,
            name: "Gempa",
            display_name: "Boboiboy Gempa",
            element: "EARTH",
            ui_color: $0953B4, // #b45309 amber tanah
            spr_idle: spr_gempa_idle,
            spr_run: spr_gempa_run,
            spr_jump: spr_gempa_jump,
            spr_jump_2: spr_gempa_jump_2,
            spr_crouch: spr_gempa_crouch,
            spr_hurt: spr_gempa_hurt,
            spr_death: spr_gempa_death,
            spr_attack_1: spr_gempa_attack_1,
            spr_attack_2: spr_gempa_attack_2,
            spr_attack_3: spr_gempa_attack_3,
        },
        {
            icon: spr_halilintar_icon,
            name: "Halilintar",
            display_name: "Boboiboy Halilintar",
            element: "LIGHTNING",
            ui_color: $ED3A7C, // #7c3aed ungu petir (sesuai referensi)
            spr_idle: spr_halilintar_idle,
            spr_run: spr_halilintar_run,
            spr_jump: spr_halilintar_jump,
            spr_jump_2: spr_halilintar_jump_2,
            spr_crouch: spr_halilintar_crouch,
            spr_hurt: spr_halilintar_hurt,
            spr_death: spr_halilintar_death,
            spr_attack_1: spr_halilintar_attack_1,
            spr_attack_2: spr_halilintar_attack_2,
            spr_attack_3: spr_halilintar_attack_3,
        },
        {
            icon: spr_topan_icon,
            name: "Topan",
            display_name: "Boboiboy Topan",
            element: "WIND",
            ui_color: $D4B606, // #06b6d4 cyan angin
            spr_idle: spr_topan_idle,
            spr_run: spr_topan_run,
            spr_jump: spr_topan_jump,
            spr_jump_2: spr_topan_jump_2,
            spr_crouch: spr_topan_crouch,
            spr_hurt: spr_topan_hurt,
            spr_death: spr_topan_death,
            spr_attack_1: spr_topan_attack_1,
            spr_attack_2: spr_topan_attack_2,
            spr_attack_3: spr_topan_attack_3,
        },
        
    ];
}

/// @function character_get(_id)
/// @description Ambil struct data karakter berdasarkan index
function character_get(_id) {
    if (!variable_global_exists("character_list")) {
        character_data_init();
    }
    var _count = array_length(global.character_list);
    if (_id < 0 || _id >= _count) {
        _id = 0;
    }
    return global.character_list[_id];
}

/// @function character_count()
/// @description Jumlah karakter yang tersedia saat ini
function character_count() {
    if (!variable_global_exists("character_list")) {
        character_data_init();
    }
    return array_length(global.character_list);
}