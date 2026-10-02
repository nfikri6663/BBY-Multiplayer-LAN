// --- TIPE PESAN ---
#macro MSG_POSITION 0
#macro MSG_ASSIGN_ID 1
#macro MSG_STATE_UPDATE 2
#macro MSG_HOST_LEAVING 3
#macro MSG_PLAYER_LEFT 4
#macro MSG_ROOM_FULL 5
#macro MSG_JOIN_REQUEST 6
#macro MSG_WRONG_PASSWORD 7
#macro MSG_PING 8
#macro MSG_PONG 9
#macro MSG_PLAYER_INFO 10
#macro MSG_PLAYER_HEALTH 11
#macro MSG_PLAYER_UPDATE 12 // client -> host: ganti username/karakter dari lobby
#macro MSG_READY_SET     13 // client -> host: set status siap diri sendiri
#macro MSG_READY_STATE   14 // host -> semua client: status siap seorang pemain
#macro MSG_GAME_START    15 // host -> semua client: lobby selesai, game dimulai
#macro MSG_ROOM_INFO     16 // host -> satu client: nama & password room
#macro MSG_GAME_STARTED  17

// ID tetap yang mewakili host di dalam daftar pemain
#macro HOST_ID -1

// --- PORT TCP GAMEPLAY ---
#macro TCP_PORT_BASE 6510
#macro TCP_PORT_SCAN_RANGE 10 // kalau port utama sudah dipakai, coba port berikutnya sampai batas ini

// --- KODE STATE ANIMASI (disinkron via posisi) ---
#macro ANIM_STATE_NORMAL 0
#macro ANIM_STATE_CROUCH 1
#macro ANIM_STATE_ATTACK_1 2
#macro ANIM_STATE_ATTACK_2 3
#macro ANIM_STATE_ATTACK_3 4

#macro STATE_ABSENT_TIMEOUT_MS 2000 // Client: pemain baru boleh dihapus kalau diam terus