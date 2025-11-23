; Void Drifter 3D - Main Game Loop
; Copyright (c) 2025 Void Drifter 3D Contributors
; SPDX-License-Identifier: MIT
; Am i Terry Davis? 
; code currently contains errors that will be fixed soon for playable version use tag v1.1.0 or download newest release from github

default rel

extern SDL_Init
extern SDL_CreateWindow
extern SDL_CreateRenderer
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderDrawLine
extern SDL_RenderDrawPoint
extern SDL_RenderPresent
extern SDL_RenderFillRect
extern SDL_PollEvent
extern SDL_Quit
extern SDL_Delay
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
extern RenderMenu
extern RenderAbout
extern RenderGameplay
extern RenderGameOver
extern UpdatePlayer
extern UpdateBullets
extern UpdateEnemies
extern UpdateExplosions
extern init_stars
extern spawn_explosion
extern PlayBackgroundMusic
extern process_events

section .data
    window_title db "Void Drifter 3D", 0
    msg_renderer_fail db "Failed to create renderer", 10, 0
    
    ; Constants
    SCREEN_WIDTH equ 800
    SCREEN_HEIGHT equ 600
    
    ; Game Settings
    PLAYER_SPEED dd 0.7
    ENEMY_SPEED dd 0.08
    BULLET_SPEED dd 1.2
    
    ; State
    running db 1
    game_state db 2  ; 0=playing, 1=game_over, 2=menu, 3=about
    menu_selection db 0  ; 0=Play, 1=About
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
    
    ; Enemies: x, y, z, active, type, health (20 bytes)
    ; type: 0=Scout(fast,small,2pts), 1=Fighter(normal,1pt), 2=Bomber(slow,large,5pts,2hp)
    enemies resd 5 * 10
    
    ; Explosions: x, y, z, timer (16 bytes, timer counts down from 10)
    explosions resd 4 * 10
    
    ; Stars: x, y, z (12 bytes, 50 stars for background)
    stars resd 3 * 50

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
    test rax, rax
    jz .renderer_fail
    
    ; Init Sound
    call InitSound
    
    ; Play Music
    call PlayBackgroundMusic
    
    ; Init Stars - DISABLED
    ; call init_stars
    
    
.loop:
    cmp byte [running], 0
    je .cleanup

    call process_events
    
    ; Check for restart
    cmp byte [game_state], 1
    jne .check_play
    cmp byte [key_r], 1
    jne .skip_update
    
    ; Reset game state - go to menu, not directly to game
    mov byte [game_state], 2  ; Back to menu
    mov dword [score], 0
    mov dword [player_lives], 5
    mov dword [difficulty_level], 0
    mov byte [shoot_timer], 0
    mov byte [spawn_timer], 0
    mov byte [key_r], 0
    jmp .skip_update
    
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
    add rbx, 20
    inc rcx
    jmp .clear_enemies_loop
    
    ; Clear all explosions
.clear_explosions:
    mov rcx, 0
    lea rbx, [explosions]
.clear_explosions_loop:
    cmp rcx, 10
    je .skip_update
    mov dword [rbx + 12], 0
    add rbx, 16
    inc rcx
    jmp .clear_explosions_loop
    
.check_play:
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

.renderer_fail:
    mov rdi, msg_renderer_fail
    xor rax, rax
    call printf
    jmp .quit



update:
    push rbp
    mov rbp, rsp
    
    ; Update difficulty level based on score (difficulty = score / 10)
    mov eax, [score]
    mov ecx, 10
    xor edx, edx
    div ecx
    mov [difficulty_level], eax ; Store the calculated difficulty
    
    call UpdatePlayer
    call UpdateBullets
    call UpdateEnemies
    call UpdateExplosions
    
.done_update:
    pop rbp
    ret

;    
;    ; Move star toward camera (z -= 0.5)
;    movss xmm0, [rbx + 8]
;    movss xmm1, [half_float]
;    subss xmm0, xmm1
;    
;    ; Wrap if behind camera (z < 0)
;    xorps xmm2, xmm2
;    ucomiss xmm0, xmm2
;    jb .reset_star
;    
;    movss [rbx + 8], xmm0
;    jmp .next_star
;    
;.reset_star:
;    ; Reset to far distance (40-60)
;    call rand
;    xor edx, edx
;    mov edi, 20
;    div edi
;    add edx, 40
;    cvtsi2ss xmm0, edx
;    movss [rbx + 8], xmm0
;    
;.next_star:
;    add rbx, 12
;    inc rcx
;    jmp .star_loop
;    
;.done_stars:
    pop rbp
    ret

extern init_stars
extern spawn_explosion

section .data
    abs_mask dd 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF
    one_float dd 1.0
    diff_scale dd 0.2
    half_float dd 0.5
section .text

render:
    push rbp
    mov rbp, rsp
    
    ; Check game state
    mov al, [game_state]
    cmp al, 1  ; Game Over
    je .do_game_over
    cmp al, 2
    je .do_menu
    cmp al, 3
    je .do_about
    
    ; State 0 - normal gameplay
    call RenderGameplay
    jmp .done

.do_game_over:
    call RenderGameOver
    jmp .done
.do_menu:
    call RenderMenu
    jmp .done
.do_about:
    call RenderAbout
    jmp .done

.done:
    pop rbp
    ret


