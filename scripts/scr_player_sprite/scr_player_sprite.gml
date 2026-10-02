/// @function player_update_sprite(_character, _grounded, _moving, _crouching, _attacking, _attack_variant)
/// @description Pilih sprite sesuai KARAKTER & state saat ini
function player_update_sprite(_character, _grounded, _moving, _crouching, _attacking, _attack_variant) {
    var _target_sprite;
    
    if (_attacking) {
        switch (_attack_variant) {
            case 1: _target_sprite = _character.spr_attack_1; break;
            case 2: _target_sprite = _character.spr_attack_2; break;
            case 3: _target_sprite = _character.spr_attack_3; break;
            default: _target_sprite = _character.spr_attack_1; break;
        }
    } else if (!_grounded) {
        _target_sprite = _character.spr_jump;
    } else if (_crouching) {
        _target_sprite = _character.spr_crouch;
    } else if (_moving) {
        _target_sprite = _character.spr_run;
    } else {
        _target_sprite = _character.spr_idle;
    }
    
    if (sprite_index != _target_sprite) {
        sprite_index = _target_sprite;
        image_speed = 1;
    }
}