net_id = -2;
slot = -1;
image_blend = c_white;

udp_ip = "";
udp_port = 0;

// Posisi ASLI terakhir yang diterima lewat jaringan 
net_x = x;
net_y = y;

snapshot_buffer = ds_list_create();

avg_snapshot_interval = 50;
last_snapshot_add_time = current_time;
interp_delay_ms = 150;
last_pos_seq_applied = -1;
last_state_seen_time = current_time;
recent_max_gap = 50;

extrap_vx = 0;
extrap_vy = 0;

character_id = 0;
character = character_get(character_id);

username = "";
hp = PLAYER_MAX_HP;
is_ready = false;

sprite_scale = PLAYER_DISPLAY_SIZE / PLAYER_SPRITE_NATIVE_SIZE;
image_xscale = sprite_scale;
image_yscale = sprite_scale;

sprite_index = character.spr_idle;
mask_index = spr_player_mask;

anim_state = ANIM_STATE_NORMAL;