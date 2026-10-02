move_speed = 4;
hsp = 0;
vsp = 0;
grav = 0.4;
jump_speed = -10;

slot = obj_network.is_host ? 0 : (variable_global_exists("net_assigned_slot") ? global.net_assigned_slot : -1); // Slot pemain (0-3), host langsung dapat slot 0.
character_id = variable_global_exists("net_character_id") ? global.net_character_id : 0; // hasil pilihan di layar pilih-karakter
character = character_get(character_id);

username = variable_global_exists("net_username") ? global.net_username : "Player";
hp = PLAYER_MAX_HP;
is_ready = false;

sprite_scale = PLAYER_DISPLAY_SIZE / PLAYER_SPRITE_NATIVE_SIZE;
image_xscale = sprite_scale;
image_yscale = sprite_scale;

sprite_index = character.spr_idle;
mask_index = spr_player_mask;

is_crouching = false;
attack_active = false;
attack_variant = 0;
attack_timer = 0;
attack_duration = 0.4;
anim_state = ANIM_STATE_NORMAL;