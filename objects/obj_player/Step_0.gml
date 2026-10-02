if (instance_exists(obj_network) && !obj_network.game_started) exit; // Selama masih di lobby, pemain tidak bisa bergerak/menyerang

if (!attack_active) { // Menyerang
    var _attack_pressed_1 = keyboard_check_pressed(ord("Z")) || (instance_exists(obj_touch_controls) && obj_touch_controls.input_skill1_pressed);
    var _attack_pressed_2 = keyboard_check_pressed(ord("X")) || (instance_exists(obj_touch_controls) && obj_touch_controls.input_skill2_pressed);
    var _attack_pressed_3 = keyboard_check_pressed(ord("C")) || (instance_exists(obj_touch_controls) && obj_touch_controls.input_skill3_pressed);
    
    if (_attack_pressed_1) { attack_active = true; attack_variant = 1; attack_timer = attack_duration; }
    else if (_attack_pressed_2) { attack_active = true; attack_variant = 2; attack_timer = attack_duration; }
    else if (_attack_pressed_3) { attack_active = true; attack_variant = 3; attack_timer = attack_duration; }
} else {
    attack_timer -= delta_time / 1000000;
    if (attack_timer <= 0) {
        attack_active = false;
    }
}

// --- Jongkok -- cuma bisa dilakukan kalau tidak sedang serang, dan mengunci gerak horizontal ---
is_crouching = !attack_active && keyboard_check(vk_down);

// --- Horizontal input (dikunci kalau sedang serang atau jongkok) ---
var _kb_move = keyboard_check(vk_right) - keyboard_check(vk_left);
var _move = _kb_move;
if (_move == 0 && instance_exists(obj_touch_controls)) {
    _move = obj_touch_controls.input_h;
}
if (attack_active || is_crouching) {
    _move = 0;
}
hsp = _move * move_speed;

if (_move != 0) {
    image_xscale = sprite_scale * sign(_move);
}

// --- Horizontal collision & move ---
if (place_meeting(x + hsp, y, obj_wall)) {
    while (!place_meeting(x + sign(hsp), y, obj_wall)) {
        x += sign(hsp);
    }
    hsp = 0;
}
x += hsp;

// --- Lompat (tidak bisa sambil serang/jongkok) ---
var _grounded_for_jump = place_meeting(x, y + 1, obj_wall);
var _jump_pressed = keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_space)
    || (instance_exists(obj_touch_controls) && obj_touch_controls.input_jump_pressed);

if (_jump_pressed && _grounded_for_jump && !attack_active && !is_crouching) {
    vsp = jump_speed;
}

// --- Gravitasi ---
vsp += grav;

if (place_meeting(x, y + vsp, obj_wall)) {
    while (!place_meeting(x, y + sign(vsp), obj_wall)) {
        y += sign(vsp);
    }
    vsp = 0;
}
y += vsp;

// --- Simpan state animasi buat disinkron ke pemain lain (dibaca oleh obj_network) ---
anim_state = ANIM_STATE_NORMAL;
if (attack_active) {
    anim_state = ANIM_STATE_ATTACK_1 + (attack_variant - 1);
} else if (is_crouching) {
    anim_state = ANIM_STATE_CROUCH;
}

// --- Animasi ---
var _grounded = place_meeting(x, y + 1, obj_wall);
player_update_sprite(character, _grounded, hsp != 0, is_crouching, attack_active, attack_variant);