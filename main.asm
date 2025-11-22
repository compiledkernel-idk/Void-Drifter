; Void Drifter 3D - Main Game Loop
default rel

extern SDL_Init
extern SDL_CreateWindow
extern SDL_CreateRenderer
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderPresent
extern SDL_PollEvent
extern SDL_Quit
extern SDL_Delay
extern SDL_RenderDrawLine
extern SDL_GetTicks
extern rand
extern exit

extern Vec3_Add
extern Vec3_Sub
extern ProjectPoint
extern InitSound
extern PlaySound

extern ship_model
extern ship_vertex_count
extern enemy_model
extern enemy_vertex_count

section .data
    window_title db "Void Drifter 3D - ASM Engine", 0
    
    ; Constants
    SCREEN_WIDTH equ 800
    SCREEN_HEIGHT equ 600
    
    ; Game Settings
    PLAYER_SPEED dd 0.7
    ENEMY_SPEED dd 0.08
    BULLET_SPEED dd 1.2
    
    ; State
    running db 1
    game_state db 0 ; 0=Playing, 1=GameOver
    shoot_timer db 0
    spawn_timer db 0
    
    ; Game Stats
    score dd 0
    player_lives dd 5
    difficulty_level dd 0
    
    ; Camera
    cam_x dd 0.0
    cam_y dd 0.0
    cam_z dd -5.0
    
    ; Player (In 3D World)
    player_x dd 0.0
    player_y dd 0.0
    player_z dd 0.0
    
    ; Input
    key_w db 0
    key_s db 0
    key_a db 0
    key_d db 0
    key_space db 0
    key_r db 0
    
    ; Temp Projection Vars
    ; pt_out moved to bss
    
section .bss
    window resq 1
    renderer resq 1
    event resb 56
    pt_out resd 2
    
    ; Bullets: x, y, z, active (16 bytes)
    bullets resd 4 * 20
    
    ; Enemies: x, y, z, active (16 bytes)
    enemies resd 4 * 10
    
    ; Explosions: x, y, z, timer (16 bytes, timer counts down from 10)
    explosions resd 4 * 10

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16 ; Align stack
    
    ; Init SDL
    mov rdi, 0x20 ; SDL_INIT_VIDEO
    call SDL_Init
    test eax, eax
    js .quit
    
    ; Create Window
    lea rdi, [window_title]
    mov rsi, 0x1FFF0000
    mov rdx, 0x1FFF0000
    mov rcx, SCREEN_WIDTH
    mov r8, SCREEN_HEIGHT
    mov r9, 4 ; SHOWN
    call SDL_CreateWindow
    mov [window], rax
    test rax, rax
    jz .quit
    
    ; Create Renderer
    mov rdi, [window]
    mov rsi, -1
    mov rdx, 2 ; ACCELERATED
    call SDL_CreateRenderer
    mov [renderer], rax
    
    ; Init Sound
    call InitSound
    
    
.loop:
    cmp byte [running], 0
    je .cleanup

    call process_events
    
    ; Check for restart
    cmp byte [game_state], 1
    jne .normal_update
    cmp byte [key_r], 1
    jne .skip_update
    
    ; Reset game state
    mov byte [game_state], 0
    mov dword [score], 0
    mov dword [player_lives], 5
    mov dword [difficulty_level], 0
    mov byte [shoot_timer], 0
    mov byte [spawn_timer], 0
    mov byte [key_r], 0
    
    ; Reset player position
    mov dword [player_x], 0
    mov dword [player_y], 0
    mov dword [player_z], 0
    
    ; Clear all bullets
    mov rcx, 0
    lea rbx, [bullets]
.clear_bullets:
    cmp rcx, 20
    je .clear_enemies
    mov dword [rbx + 12], 0
    add rbx, 16
    inc rcx
    jmp .clear_bullets
    
    ; Clear all enemies
.clear_enemies:
    mov rcx, 0
    lea rbx, [enemies]
.clear_enemies_loop:
    cmp rcx, 10
    je .clear_explosions
    mov dword [rbx + 12], 0
    add rbx, 16
    inc rcx
    jmp .clear_enemies_loop
    
    ; Clear all explosions
.clear_explosions:
    mov rcx, 0
    lea rbx, [explosions]
.clear_explosions_loop:
    cmp rcx, 10
    je .normal_update
    mov dword [rbx + 12], 0
    add rbx, 16
    inc rcx
    jmp .clear_explosions_loop
    
.normal_update:
    cmp byte [game_state], 0
    jne .skip_update
    call update
.skip_update:

    call render
    
    mov rdi, 16
    call SDL_Delay
    jmp .loop

.cleanup:
    mov rdi, [renderer]
    call SDL_Quit
    
.quit:
    mov rdi, 0
    call exit

process_events:
    push rbp
    mov rbp, rsp
    
.poll:
    mov rdi, event
    call SDL_PollEvent
    test eax, eax
    jz .done
    
    mov eax, [event]
    cmp eax, 0x100 ; QUIT
    je .do_quit
    cmp eax, 0x300 ; KEYDOWN
    je .keydown
    cmp eax, 0x301 ; KEYUP
    je .keyup
    jmp .poll
    
.do_quit:
    mov byte [running], 0
    jmp .done

.keydown:
    mov eax, [event + 20]
    cmp eax, 119 ; w
    je .w_down
    cmp eax, 115 ; s
    je .s_down
    cmp eax, 97 ; a
    je .a_down
    cmp eax, 100 ; d
    je .d_down
    cmp eax, 32 ; SPACE
    je .space_down
    cmp eax, 114 ; r
    je .r_down
    cmp eax, 27 ; ESC
    je .do_quit
    jmp .poll
    
    .w_down: mov byte [key_w], 1
             jmp .poll
    .s_down: mov byte [key_s], 1
             jmp .poll
    .a_down: mov byte [key_a], 1
             jmp .poll
    .d_down: mov byte [key_d], 1
             jmp .poll
    .space_down: mov byte [key_space], 1
                 jmp .poll
    .r_down: mov byte [key_r], 1
             jmp .poll

.keyup:
    mov eax, [event + 20]
    cmp eax, 119
    je .w_up
    cmp eax, 115
    je .s_up
    cmp eax, 97
    je .a_up
    cmp eax, 100
    je .d_up
    cmp eax, 32
    je .space_up
    cmp eax, 114
    je .r_up
    jmp .poll



    .w_up: mov byte [key_w], 0
           jmp .poll
    .s_up: mov byte [key_s], 0
           jmp .poll
    .a_up: mov byte [key_a], 0
           jmp .poll
    .d_up: mov byte [key_d], 0
           jmp .poll
    .space_up: mov byte [key_space], 0
               jmp .poll
    .r_up: mov byte [key_r], 0
           jmp .poll

.done:
    pop rbp
    ret

update:
    push rbp
    mov rbp, rsp
    
    ; Update difficulty level based on score (difficulty = score / 10)
    mov eax, [score]
    mov ecx, 10
    xor edx, edx
    div ecx
    mov [difficulty_level], eax
    
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
    jmp .update_bullets
    
.can_shoot:
    cmp byte [key_space], 1
    jne .update_bullets
    
    mov byte [shoot_timer], 8
    
    ; Spawn Bullet
    mov rcx, 0
    lea rbx, [bullets]
.find_bullet:
    cmp rcx, 20
    je .update_bullets
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
    
.update_bullets:
    mov rcx, 0
    lea rbx, [bullets]
.bullet_loop:
    cmp rcx, 20
    je .update_enemies
    cmp dword [rbx + 12], 1
    jne .next_bullet
    
    ; Move Z+
    movss xmm0, [rbx + 8]
    addss xmm0, [BULLET_SPEED]
    movss [rbx + 8], xmm0
    
    ; Check Far Plane
    mov eax, 50
    cvtsi2ss xmm1, eax
    ucomiss xmm0, xmm1
    jbe .next_bullet
    mov dword [rbx + 12], 0
    
.next_bullet:
    add rbx, 16
    inc rcx
    jmp .bullet_loop
    
.update_enemies:
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
    add rbx, 16
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
    
.move_enemies:
    mov rcx, 0
    lea rbx, [enemies]
.enemy_loop:
    cmp rcx, 10
    je .done_update
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
    jmp .done_update
    
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
    
    ; Spawn explosion at enemy position
    push rcx
    push rdx
    push rbx
    call spawn_explosion
    pop rbx
    pop rdx
    pop rcx
    
    ; Score++
    inc dword [score]
    
    ; Sound
    mov rdi, 1
    call PlaySound
    
    jmp .end_col
    
.next_col:
    add rdx, 16
    inc rcx
    jmp .col_loop
    
.end_col:
    pop rbx
    pop rcx
    
.next_enemy:
    add rbx, 16
    inc rcx
    jmp .enemy_loop
    
.done_update:
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

; spawn_explosion - spawns explosion at position in rbx
; Input: rbx = pointer to position (x, y, z)
spawn_explosion:
    push rbp
    mov rbp, rsp
    push rcx
    push rax
    push rbx
    
    mov rcx, 0
    lea rax, [explosions]
.find_slot:
    cmp rcx, 10
    je .no_slot
    cmp dword [rax + 12], 0
    jle .found_slot
    add rax, 16
    inc rcx
    jmp .find_slot
    
.found_slot:
    ; Copy position from enemy (rbx) to explosion (rax)
    mov edx, [rbx]
    mov [rax], edx
    mov edx, [rbx + 4]
    mov [rax + 4], edx
    mov edx, [rbx + 8]
    mov [rax + 8], edx
    mov dword [rax + 12], 10 ; Timer = 10 frames
    
.no_slot:
    pop rbx
    pop rax
    pop rcx
    pop rbp
    ret

section .data
    align 16
    abs_mask dd 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF
    one_float dd 1.0
    diff_scale dd 0.2

section .text

render:
    push rbp
    mov rbp, rsp
    sub rsp, 128 ; Stack space
    
    ; Check Game Over
    cmp byte [game_state], 1
    je .game_over_screen

    ; Clear
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 0
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear
    
    ; Draw Bullets (Yellow Lines)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    mov rcx, 0
    mov rcx, 0
    lea rbx, [bullets]
.draw_bullets:
    cmp rcx, 20
    je .draw_enemies
    cmp dword [rbx + 12], 1
    jne .next_draw_bullet
    
    push rcx ; Save loop counter
    push rax ; Align stack
    
    ; Project Start
    movss xmm0, [rbx]
    movss xmm1, [rbx + 4]
    movss xmm2, [rbx + 8]
    subss xmm2, [cam_z]
    
    sub rsp, 16
    movss [rsp], xmm0
    movss [rsp+4], xmm1
    movss [rsp+8], xmm2
    lea rdi, [pt_out]
    mov rsi, rsp
    call ProjectPoint
    add rsp, 16
    
    cmp eax, 0
    je .skip_draw_bullet
    
    mov esi, [pt_out]
    mov edx, [pt_out + 4]
    
    ; Draw longer line for better visibility
    mov rdi, [renderer]
    mov ecx, esi
    mov r8d, edx
    add r8d, 10 ; Length 10
    call SDL_RenderDrawLine
    
    ; Draw again +1 pixel for thickness
    mov rdi, [renderer]
    mov ecx, esi
    add ecx, 1
    mov r8d, edx
    add r8d, 10
    call SDL_RenderDrawLine
    
.skip_draw_bullet:
    pop rax ; Align stack
    pop rcx ; Restore loop counter
    
.next_draw_bullet:
    add rbx, 16
    inc rcx
    jmp .draw_bullets
    
.draw_enemies:
    ; Draw Enemies (Red Cubes)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 0
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    mov rcx, 0
    lea rbx, [enemies]
.draw_enemy_loop:
    cmp rcx, 10
    je .draw_ship
    cmp dword [rbx + 12], 1
    jne .next_draw_enemy
    
    push rcx ; Save loop counter
    push rax ; Align stack
    
    ; Draw Cube (Just front face for speed)
    ; V0 (-1, -1, -1) + Pos
    
    movss xmm0, [rbx]
    subss xmm0, [one_float]
    movss xmm1, [rbx + 4]
    subss xmm1, [one_float]
    movss xmm2, [rbx + 8]
    subss xmm2, [one_float]
    subss xmm2, [cam_z]
    
    sub rsp, 16
    movss [rsp], xmm0
    movss [rsp+4], xmm1
    movss [rsp+8], xmm2
    
    ; Inline ProjectPoint
    ; xmm0=x, xmm1=y, xmm2=z
    
    movss xmm3, [one_float]
    ucomiss xmm2, xmm3
    jbe .enemy_behind
    
    divss xmm0, xmm2
    divss xmm1, xmm2
    
    mov eax, 400
    cvtsi2ss xmm3, eax
    mulss xmm0, xmm3
    mulss xmm1, xmm3
    
    addss xmm0, xmm3
    mov eax, 300
    cvtsi2ss xmm4, eax
    addss xmm1, xmm4
    
    lea rdi, [pt_out]
    cvtss2si eax, xmm0
    mov [rdi], eax
    cvtss2si eax, xmm1
    mov [rdi+4], eax
    mov eax, 1
    jmp .enemy_visible
    
.enemy_behind:
    mov eax, 0
    
.enemy_visible:
    add rsp, 16
    
    cmp eax, 0
    je .skip_draw_enemy
    
    mov esi, [pt_out]
    mov edx, [pt_out + 4]
    
    ; Draw larger square outline (30x30)
    push rcx
    push rax
    
    ; Top line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, 15
    mov r8d, edx
    sub r8d, 15
    push rsi
    mov esi, ecx
    pop rcx
    add ecx, 30
    call SDL_RenderDrawLine
    
    ; Bottom line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, 15
    mov r8d, edx
    add r8d, 15
    push rsi
    mov esi, ecx
    pop rcx
    add ecx, 30
    call SDL_RenderDrawLine
    
    ; Left line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, 15
    mov r8d, edx
    sub r8d, 15
    push rdx
    mov edx, r8d
    pop r8
    add r8d, 30
    call SDL_RenderDrawLine
    
    ; Right line
    mov rdi, [renderer]
    mov ecx, esi
    add ecx, 15
    mov r8d, edx
    sub r8d, 15
    push rdx
    mov edx, r8d
    pop r8
    add r8d, 30
    call SDL_RenderDrawLine
    
    pop rax
    pop rcx
    
.skip_draw_enemy:
    pop rax ; Align stack
    pop rcx ; Restore loop counter
    
.next_draw_enemy:
    add rbx, 16
    inc rcx
    jmp .draw_enemy_loop
    
.draw_explosions:
    ; Draw Explosions (Orange/Yellow radiating lines)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 200
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    mov rcx, 0
    lea rbx, [explosions]
.draw_explosion_loop:
    cmp rcx, 10
    je .draw_ship
    cmp dword [rbx + 12], 0
    jle .next_explosion
    
    ; Project center
    movss xmm0, [rbx]
    movss xmm1, [rbx + 4]
    movss xmm2, [rbx + 8]
    subss xmm2, [cam_z]
    
    sub rsp, 16
    movss [rsp], xmm0
    movss [rsp+4], xmm1
    movss [rsp+8], xmm2
    lea rdi, [pt_out]
    mov rsi, rsp
    call ProjectPoint
    add rsp, 16
    
    cmp eax, 0
    je .next_explosion
    
    mov esi, [pt_out]
    mov edx, [pt_out + 4]
    
    ; Draw 4 radiating lines (size based on timer)
    mov eax, [rbx + 12]
    imul eax, 4 ; size = timer * 4 (larger explosions)
    
    push rcx
    push rax
    
    ; Line right
    mov rdi, [renderer]
    mov ecx, esi
    add ecx, eax
    mov r8d, edx
    call SDL_RenderDrawLine
    
    pop rax
    push rax
    
    ; Line left
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, eax
    mov r8d, edx
    call SDL_RenderDrawLine
    
    pop rax
    push rax
    
    ; Line down
    mov rdi, [renderer]
    mov ecx, esi
    mov r8d, edx
    add r8d, eax
    call SDL_RenderDrawLine
    
    pop rax
    
    ; Line up
    mov rdi, [renderer]
    mov ecx, esi
    mov r8d, edx
    sub r8d, eax
    call SDL_RenderDrawLine
    
    pop rcx
    
.next_explosion:
    add rbx, 16
    inc rcx
    jmp .draw_explosion_loop
    
.draw_ship:
    ; Set Color (Cyan)
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    ; Draw Ship
    mov rcx, 0
.proj_loop:
    cmp rcx, 4
    je .draw_lines
    
    mov rax, rcx
    imul rax, 12
    lea rsi, [ship_model + rax]
    
    movss xmm0, [rsi]
    addss xmm0, [player_x]
    movss xmm1, [rsi + 4]
    addss xmm1, [player_y]
    movss xmm2, [rsi + 8]
    addss xmm2, [player_z]
    subss xmm2, [cam_z]
    
    sub rsp, 16
    movss [rsp], xmm0
    movss [rsp+4], xmm1
    movss [rsp+8], xmm2
    
    lea rdi, [pt_out]
    mov rsi, rsp
    call ProjectPoint
    add rsp, 16
    
    mov eax, [pt_out]
    mov [rbp - 32 + rcx*8], eax
    mov eax, [pt_out + 4]
    mov [rbp - 32 + rcx*8 + 4], eax
    
    inc rcx
    jmp .proj_loop
    
.draw_lines:
    ; mov rdi, msg_render_ship
    ; xor rax, rax
    ; call printf

    mov rdi, [renderer]
    mov esi, [rbp - 32]
    mov edx, [rbp - 32 + 4]
    mov ecx, [rbp - 32 + 8]
    mov r8d, [rbp - 32 + 12]
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 8]
    mov edx, [rbp - 32 + 12]
    mov ecx, [rbp - 32 + 16]
    mov r8d, [rbp - 32 + 20]
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 16]
    mov edx, [rbp - 32 + 20]
    mov ecx, [rbp - 32]
    mov r8d, [rbp - 32 + 4]
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32]
    mov edx, [rbp - 32 + 4]
    mov ecx, [rbp - 32 + 24]
    mov r8d, [rbp - 32 + 28]
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 8]
    mov edx, [rbp - 32 + 12]
    mov ecx, [rbp - 32 + 24]
    mov r8d, [rbp - 32 + 28]
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 16]
    mov edx, [rbp - 32 + 20]
    mov ecx, [rbp - 32 + 24]
    mov r8d, [rbp - 32 + 28]
    call SDL_RenderDrawLine
    
    ; Draw HUD
    ; Lives (Triangles at top left)
    mov rcx, 0
    mov eax, [player_lives]
.draw_lives:
    cmp ecx, eax
    je .draw_score
    
    ; Draw Triangle at (20 + i*30, 20)
    ; V1: (20+i*30, 20)
    ; V2: (30+i*30, 40)
    ; V3: (10+i*30, 40)
    
    push rax
    push rcx
    
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    pop rcx
    pop rax
    
    ; Calc Offset X
    mov rbx, rcx
    imul rbx, 30
    add rbx, 20
    
    push rax
    push rcx
    push rbx
    push rax ; Align stack
    
    ; Line 1
    mov rdi, [renderer]
    mov rsi, rbx ; x1
    mov rdx, 20  ; y1
    mov rcx, rbx ; x2
    add rcx, 10
    mov r8, 40   ; y2
    call SDL_RenderDrawLine
    
    pop rbx
    push rbx
    
    ; Line 2
    mov rdi, [renderer]
    mov rsi, rbx
    add rsi, 10
    mov rdx, 40
    mov rcx, rbx
    sub rcx, 10
    mov r8, 40
    call SDL_RenderDrawLine
    
    pop rbx
    push rbx
    
    ; Line 3
    mov rdi, [renderer]
    mov rsi, rbx
    sub rsi, 10
    mov rdx, 40
    mov rcx, rbx
    mov r8, 20
    call SDL_RenderDrawLine
    
    pop rax ; Align stack
    pop rbx
    pop rcx
    pop rax
    
    inc rcx
    jmp .draw_lives
    
.draw_score:
    ; Score Bar (Top Right)
    ; Length = score * 5
    mov eax, [score]
    imul eax, 5
    
    ; Draw Line from (780, 20) to (780-len, 20)
    push rax
    push rax ; Align stack
    
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 255
    mov r8, 20
    call SDL_SetRenderDrawColor
    
    pop rax ; Align stack
    pop rax
    
    mov rdi, [renderer]
    mov rsi, 780
    mov rdx, 20
    mov rcx, 780
    sub rcx, rax
    mov r8, 20
    call SDL_RenderDrawLine
    
    ; Thicken it
    mov rdi, [renderer]
    mov rsi, 780
    mov rdx, 21
    mov rcx, 780
    sub rcx, rax
    mov r8, 21
    call SDL_RenderDrawLine
    
    jmp .present

.game_over_screen:
    ; Clear Red
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 0
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear
    
    ; Draw "X"
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    mov rdi, [renderer]
    mov rsi, 100
    mov rdx, 100
    mov rcx, 700
    mov r8, 500
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov rsi, 700
    mov rdx, 100
    mov rcx, 100
    mov r8, 500
    call SDL_RenderDrawLine

.present:
    mov rdi, [renderer]
    call SDL_RenderPresent
    
    add rsp, 128
    pop rbp
    ret
