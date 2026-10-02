/// @description Gambar semua layar menu dengan sistem UI baru (panel, field berkursor, toast, spinner)

draw_sprite_stretched(spr_ui_bg, 0, 0, 0, room_width, room_height);
draw_set_font(fnt_ui);
draw_set_colour(UI_COL_TEXT);

// --- Judul game (semua layar) ---
draw_set_font(fnt_ui_title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(c_black);
draw_text(room_width / 2 + 2, 24 + 2, "MULTIPLAYER PLATFORMER"); // bayangan
draw_set_colour(UI_COL_TEXT);
draw_text(room_width / 2, 24, "MULTIPLAYER PLATFORMER");
draw_set_font(fnt_ui);

switch (menu_state) {
    case "select":
        draw_set_halign(fa_center);
        draw_set_colour(UI_COL_TEXT_DIM);
        draw_text(room_width / 2, btn_host_y1 - 20, "Username & karakter diatur di dalam lobby");
        
        ui_button_draw(btn_host_x1, btn_host_y1, btn_host_x2, btn_host_y2, "HOST GAME", true);
        ui_button_draw(btn_join_x1, btn_join_y1, btn_join_x2, btn_join_y2, "JOIN GAME");
        break;
        
    case "host_setup":
        draw_set_halign(fa_center);
        draw_set_colour(UI_COL_TEXT);
        draw_text(room_width / 2, 56, "BUAT ROOM BARU");
        
        ui_field_draw(btn_room_name_x1, btn_room_name_y1, btn_room_name_x2, btn_room_name_y2,
            room_name_input, "Nama room (kosong = acak)", input_focus == "room_name");
        ui_field_draw(btn_room_pass_x1, btn_room_pass_y1, btn_room_pass_x2, btn_room_pass_y2,
            room_password_input, "Password (opsional)", input_focus == "room_password");
        
        draw_set_halign(fa_center);
        draw_set_colour(UI_COL_TEXT_DIM);
        draw_text(room_width / 2, btn_room_pass_y2 + 12, "Room tanpa password bisa dimasuki siapa saja di jaringan");
        draw_set_colour(UI_COL_TEXT);
        
        ui_button_draw(btn_create_x1, btn_create_y1, btn_create_x2, btn_create_y2, "CREATE ROOM", true);
        ui_button_draw(btn_back_x1, btn_back_y1, btn_back_x2, btn_back_y2, "BACK");
        break;
        
    case "browse_rooms":
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_colour(UI_COL_TEXT);
        draw_text(col_x1, 57, "ROOM DI JARINGAN (" + string(ds_map_size(discovered_rooms)) + ")");
        draw_set_valign(fa_top);
        
        ui_button_draw(btn_refresh_x1, btn_refresh_y1, btn_refresh_x2, btn_refresh_y2, "CARI ULANG");
        
        if (discovery_failed) {
            draw_set_halign(fa_center);
            draw_set_colour(UI_COL_DANGER);
            draw_text(room_width / 2, browse_list_y_start + 20, "Gagal membuka pencarian room.");
            draw_text(room_width / 2, browse_list_y_start + 40, "Mungkin ada instance lain aktif di komputer ini.");
            draw_set_colour(UI_COL_TEXT);
        } else {
            var _y = browse_list_y_start;
            var _key = ds_map_find_first(discovered_rooms);
            repeat (ds_map_size(discovered_rooms)) {
                var _room = discovered_rooms[? _key];
                ui_room_card_draw(col_x1, _y, col_x2, _y + browse_row_height - 6,
                    _room.room_name, _room.has_password, _room.player_count);
                _y += browse_row_height;
                _key = ds_map_find_next(discovered_rooms, _key);
            }
            
            if (ds_map_size(discovered_rooms) == 0) {
                ui_spinner_draw(room_width / 2, _y + 26, 12);
                draw_set_halign(fa_center);
                draw_set_colour(UI_COL_TEXT_DIM);
                draw_text(room_width / 2, _y + 48, "Mencari room di jaringan...");
                draw_set_colour(UI_COL_TEXT);
            }
        }
        
        ui_button_draw(btn_back_x1, btn_back_y1, btn_back_x2, btn_back_y2, "BACK");
        break;
        
    case "enter_password":
        draw_set_halign(fa_center);
        draw_set_colour(UI_COL_TEXT);
        draw_text(room_width / 2, 62, "ROOM TERKUNCI");
        draw_set_colour(UI_COL_ACCENT);
        draw_text(room_width / 2, 80, selected_room_name);
        draw_set_colour(UI_COL_TEXT);
        
        // Password TIDAK disamarkan -- pemain bisa lihat & koreksi ketikannya sendiri
        ui_field_draw(btn_pass_input_x1, btn_pass_input_y1, btn_pass_input_x2, btn_pass_input_y2,
            join_password_input, "Ketuk untuk isi password...", input_focus == "join_password");
        
        ui_button_draw(btn_connect_x1, btn_connect_y1, btn_connect_x2, btn_connect_y2, "CONNECT", true);
        ui_button_draw(btn_back_x1, btn_back_y1, btn_back_x2, btn_back_y2, "BACK");
        break;
        
    case "connecting":
        ui_spinner_draw(room_width / 2, room_height / 2 - 30, 16);
        
        draw_set_halign(fa_center);
        draw_set_colour(UI_COL_TEXT);
        draw_text(room_width / 2, room_height / 2 + 4, "Menghubungkan ke " + selected_room_name + "...");
        draw_set_colour(UI_COL_TEXT_DIM);
        draw_text(room_width / 2, room_height / 2 + 24, "Mencoba selama " + string(join_timeout_seconds) + " detik");
        draw_set_colour(UI_COL_TEXT);
        
        ui_button_draw(btn_cancel_x1, btn_cancel_y1, btn_cancel_x2, btn_cancel_y2, "BATALKAN");
        break;
}

// --- Toast pesan status: banner di atas, memudar otomatis ---
var _toast_elapsed = current_time - status_message_time;
if (status_message != "" && _toast_elapsed < UI_TOAST_MS) {
    var _alpha = (_toast_elapsed > UI_TOAST_MS - UI_TOAST_FADE_MS)
        ? (UI_TOAST_MS - _toast_elapsed) / UI_TOAST_FADE_MS : 1;
    
    draw_set_alpha(_alpha * 0.85);
    draw_set_colour(c_black);
    var _tw = string_width(status_message) + 24;
    draw_rectangle(room_width / 2 - _tw / 2, 40, room_width / 2 + _tw / 2, 62, false);
    draw_set_alpha(_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(UI_COL_DANGER);
    draw_text(room_width / 2, 51, status_message);
    draw_set_alpha(1);
    draw_set_valign(fa_top);
    draw_set_colour(UI_COL_TEXT);
}

// Footer kecil
draw_set_halign(fa_left);
draw_set_colour(UI_COL_TEXT_DIM);
draw_text(6, room_height - 16, "LAN Multiplayer");
draw_set_colour(UI_COL_TEXT);