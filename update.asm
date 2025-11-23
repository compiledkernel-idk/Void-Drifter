section .text

extern PlaySound
extern rand
extern difficulty_level
extern player_x
extern player_y
extern player_z
extern PLAYER_SPEED
extern key_w
extern key_s
extern key_a
extern key_d
extern key_space
extern shoot_timer
extern bullets
extern BULLET_SPEED
extern spawn_timer
extern enemies
extern diff_scale
extern one_float
extern ENEMY_SPEED
extern abs_mask
extern player_lives
extern game_state
extern score
extern explosions
extern spawn_explosion

global UpdatePlayer
global UpdateBullets
global UpdateEnemies
global UpdateExplosions
global init_stars
global spawn_explosion

extern stars
extern cam_z
extern rand

UpdatePlayer:
    push rbp
    mov rbp, rsp
    ; Move Player
    movss xmm0, [player_y]
    movss xmm1, [PLAYER_SPEED]
    
    cmp byte [key_w], 1
    jne .check_s
    addss xmm0, xmm1
.check_s:
    cmp byte [key_s], 1
    jne .check_a
    subss xmm0, xmm1
.check_a:
    movss [player_y], xmm0
    movss xmm0, [player_x]
    cmp byte [key_a], 1
    jne .check_d
    subss xmm0, xmm1
.check_d:
    cmp byte [key_d], 1
    jne .done_move
    addss xmm0, xmm1
.done_move:
    movss [player_x], xmm0
    
    ; Shooting
    cmp byte [shoot_timer], 0
    je .can_shoot
    dec byte [shoot_timer]
    jmp .done_player
.can_shoot:
    cmp byte [key_space], 1
    jne .done_player
    
    mov byte [shoot_timer], 8
    
    ; Spawn Bullet
    mov rcx, 0
    lea rbx, [bullets]
.find_bullet:
    cmp rcx, 20
    je .done_player
    cmp dword [rbx + 12], 0
    je .spawn_bullet
    add rbx, 16
    inc rcx
    jmp .find_bullet
    
.spawn_bullet:
    mov eax, [player_x]
    mov [rbx], eax
    mov eax, [player_y]
    mov [rbx + 4], eax
    mov eax, [player_z]
    mov [rbx + 8], eax
    mov dword [rbx + 12], 1
    
    ; Sound
    mov rdi, 0
    call PlaySound
    
.done_player:
    pop rbp
    ret

UpdateBullets:
    push rbp
    mov rbp, rsp
    mov rcx, 0
    lea rbx, [bullets]
.bullet_loop:
    cmp rcx, 20
    je .done_bullets
    cmp dword [rbx + 12], 1
    jne .next_bullet
    
    ; Move Bullet (Z+)
    movss xmm0, [rbx + 8]
    movss xmm1, [BULLET_SPEED]
    addss xmm0, xmm1
    movss [rbx + 8], xmm0
    
    ; Check Far Plane (50.0)
    mov eax, 50
    cvtsi2ss xmm1, eax
    ucomiss xmm0, xmm1
    jbe .next_bullet
    mov dword [rbx + 12], 0
    
.next_bullet:
    add rbx, 16
    inc rcx
    jmp .bullet_loop
.done_bullets:
    pop rbp
    ret

UpdateEnemies:
    push rbp
    mov rbp, rsp
    ; Spawn Enemies
    cmp byte [spawn_timer], 0
    je .do_spawn
    dec byte [spawn_timer]
    jmp .move_enemies
    
.do_spawn:
    ; Dynamic spawn rate: max(30, 60 - difficulty * 3)
    mov eax, [difficulty_level]
    imul eax, 3
    mov ecx, 60
    sub ecx, eax
    cmp ecx, 30
    jge .use_spawn_rate
    mov ecx, 30
.use_spawn_rate:
    mov [spawn_timer], cl
    
    mov rcx, 0
    lea rbx, [enemies]
.find_enemy:
    cmp rcx, 10
    je .move_enemies
    cmp dword [rbx + 12], 0
    je .spawn_enemy
    add rbx, 20
    inc rcx
    jmp .find_enemy
    
.spawn_enemy:
    ; Random X/Y
    call rand
    and eax, 15
    sub eax, 8
    cvtsi2ss xmm0, eax
    movss [rbx], xmm0 ; X
    
    call rand
    and eax, 15
    sub eax, 8
    cvtsi2ss xmm0, eax
    movss [rbx + 4], xmm0 ; Y
    
    mov eax, 50
    cvtsi2ss xmm0, eax
    movss [rbx + 8], xmm0 ; Z = 50 (Far)
    
    mov dword [rbx + 12], 1
    
    ; Random enemy type (0-2)
    call rand
    xor edx, edx
    mov edi, 3
    div edi
    mov [rbx + 16], dl  ; type (byte)
    
    ; Set health based on type
    cmp dl, 2           ; Bomber?
    jne .not_bomber
    mov byte [rbx + 17], 2  ; 2 HP
    jmp .move_enemies
.not_bomber:
    mov byte [rbx + 17], 1  ; 1 HP
    
.move_enemies:
    mov rcx, 0
    lea rbx, [enemies]
.enemy_loop:
    cmp rcx, 10
    je .done_enemies
    cmp dword [rbx + 12], 1
    jne .next_enemy
    
    ; Move Z- with difficulty scaling
    ; Actual speed = ENEMY_SPEED * (1 + difficulty * 0.2)
    movss xmm0, [rbx + 8]
    
    ; Calculate speed multiplier: 1 + difficulty * 0.2
    mov eax, [difficulty_level]
    cvtsi2ss xmm2, eax
    movss xmm3, [diff_scale]
    mulss xmm2, xmm3
    movss xmm3, [one_float]
    addss xmm2, xmm3
    
    ; Apply scaled speed
    movss xmm1, [ENEMY_SPEED]
    mulss xmm1, xmm2
    subss xmm0, xmm1
    movss [rbx + 8], xmm0
    
    ; Check Near Plane
    xorps xmm1, xmm1
    ucomiss xmm0, xmm1
    ja .check_col
    mov dword [rbx + 12], 0
    jmp .next_enemy
    
.check_col:
    ; Collision with Player
    ; Player is at (player_x, player_y, player_z)
    ; Enemy is at (rbx, rbx+4, rbx+8)
    ; Simple box check: |dx| < 1.0, |dy| < 1.0, |dz| < 1.0
    
    movss xmm0, [rbx]
    subss xmm0, [player_x]
    andps xmm0, [abs_mask]
    movss xmm1, [one_float]
    ucomiss xmm0, xmm1
    ja .check_bullet_col
    
    movss xmm0, [rbx + 4]
    subss xmm0, [player_y]
    andps xmm0, [abs_mask]
    ucomiss xmm0, xmm1
    ja .check_bullet_col
    
    movss xmm0, [rbx + 8]
    subss xmm0, [player_z]
    andps xmm0, [abs_mask]
    ucomiss xmm0, xmm1
    ja .check_bullet_col
    
    ; Player Hit!
    mov dword [rbx + 12], 0 ; Destroy Enemy
    
    ; Spawn explosion at enemy position
    push rcx
    push rbx
    call spawn_explosion
    pop rbx
    pop rcx
    
    ; Sound
    mov rdi, 1
    call PlaySound
    
    dec dword [player_lives]
    cmp dword [player_lives], 0
    jg .check_bullet_col
    
    ; Game Over
    mov byte [game_state], 1
    jmp .done_enemies
    
.check_bullet_col:
    ; Collision with Bullets
    ; Simple Distance Check
    push rcx
    push rbx
    
    lea rdx, [bullets]
    mov rcx, 0
.col_loop:
    cmp rcx, 20
    je .end_col
    cmp dword [rdx + 12], 1
    jne .next_col
    
    ; Dist check (X, Y, Z)
    ; |dx| < 1.0, |dy| < 1.0, |dz| < 1.0
    
    movss xmm0, [rbx]
    subss xmm0, [rdx]
    andps xmm0, [abs_mask] ; Abs
    movss xmm1, [one_float]
    ucomiss xmm0, xmm1
    ja .next_col
    
    movss xmm0, [rbx + 4]
    subss xmm0, [rdx + 4]
    andps xmm0, [abs_mask]
    ucomiss xmm0, xmm1
    ja .next_col
    
    movss xmm0, [rbx + 8]
    subss xmm0, [rdx + 8]
    andps xmm0, [abs_mask]
    ucomiss xmm0, xmm1
    ja .next_col
    
    ; Hit
    mov dword [rbx + 12], 0
    mov dword [rdx + 12], 0
    
    ; Spawn explosion
    push rcx
    push rbx
    push rdx
    call spawn_explosion
    pop rdx
    pop rbx
    pop rcx
    
    ; Sound
    push rcx
    push rdx
    mov rdi, 1
    call PlaySound
    pop rdx
    pop rcx
    
    ; Score
    inc dword [score]
    
    ; Increase difficulty every 10 points
    mov eax, [score]
    xor edx, edx
    mov ecx, 10
    div ecx
    mov [difficulty_level], eax
    
    jmp .end_col
    
.next_col:
    add rdx, 16
    inc rcx
    jmp .col_loop
    
.end_col:
    pop rbx
    pop rcx
    
.next_enemy:
    add rbx, 20
    inc rcx
    jmp .enemy_loop
.done_enemies:
    pop rbp
    ret

UpdateExplosions:
    push rbp
    mov rbp, rsp
    ; Update explosions
    mov rcx, 0
    lea rbx, [explosions]
.explosion_loop:
    cmp rcx, 10
    je .done_explosions
    cmp dword [rbx + 12], 0
    jle .next_explosion
    
    dec dword [rbx + 12]
    
.next_explosion:
    add rbx, 16
    inc rcx
    jmp .explosion_loop
.done_explosions:
    pop rbp
    ret

init_stars:
    push rbp
    mov rbp, rsp
    
    mov rcx, 0
    lea rbx, [stars]
.init_loop:
    cmp rcx, 50
    je .done_init
    
    ; Random X (-100 to 100)
    call rand
    and eax, 255
    sub eax, 128
    cvtsi2ss xmm0, eax
    movss [rbx], xmm0
    
    ; Random Y (-100 to 100)
    call rand
    and eax, 255
    sub eax, 128
    cvtsi2ss xmm0, eax
    movss [rbx + 4], xmm0
    
    ; Random Z (0 to 100)
    call rand
    and eax, 127
    cvtsi2ss xmm0, eax
    movss [rbx + 8], xmm0
    
    add rbx, 12
    inc rcx
    jmp .init_loop
.done_init:
    pop rbp
    ret

spawn_explosion:
    ; Args: None (uses stack or registers? No, just finds slot)
    ; Input: rbx (enemy/bullet pos) or just spawn at location?
    ; Let's assume caller pushed X, Y, Z or we just use a fixed location for now?
    ; Actually the caller pushed rcx, rbx etc.
    ; But wait, the caller in UpdateEnemies did:
    ; push rcx, push rbx, call spawn_explosion
    ; So we need to read from [rbx].
    ; But [rbx] is the ENEMY pointer.
    
    push rbp
    mov rbp, rsp
    
    ; Find free explosion slot
    mov rcx, 0
    lea rdx, [explosions]
.find_slot:
    cmp rcx, 10
    je .no_slot
    cmp dword [rdx + 12], 0
    jle .found_slot
    add rdx, 16
    inc rcx
    jmp .find_slot
    
.found_slot:
    ; Copy Pos from [rbx] (Enemy/Bullet)
    ; rbx is preserved by caller? Yes.
    ; But wait, rbx in UpdateEnemies points to the enemy struct.
    ; We need to access it.
    ; The caller pushed rcx, rbx.
    ; We can just use rbx if it's valid.
    ; Yes, rbx is valid here.
    
    mov eax, [rbx]
    mov [rdx], eax
    mov eax, [rbx + 4],
    mov [rdx + 4], eax
    mov eax, [rbx + 8]
    mov [rdx + 8], eax
    
    mov dword [rdx + 12], 20 ; Duration
    
.no_slot:
    pop rbp
    ret
