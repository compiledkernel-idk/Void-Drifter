section .text

extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderDrawLine
extern SDL_RenderPresent

extern renderer
extern game_state
extern menu_selection
extern player_lives
extern score
extern stars
extern bullets
extern enemies
extern explosions
extern ship_model
extern player_x
extern player_y
extern player_z
extern cam_z
extern pt_out
extern ProjectPoint

global RenderMenu
global RenderAbout
global RenderGameplay
global RenderGameOver

RenderMenu:
    push rbp
    mov rbp, rsp
    ; Clear screen (Blue)
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 0
    mov rcx, 100
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear
    
    ; Title Box (250, 150, 300, 40)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    ; Top
    mov rdi, [renderer]
    mov rsi, 250
    mov rdx, 150
    mov rcx, 550
    mov r8, 150
    call SDL_RenderDrawLine
    ; Bottom
    mov rdi, [renderer]
    mov rsi, 250
    mov rdx, 190
    mov rcx, 550
    mov r8, 190
    call SDL_RenderDrawLine
    ; Left
    mov rdi, [renderer]
    mov rsi, 250
    mov rdx, 150
    mov rcx, 250
    mov r8, 190
    call SDL_RenderDrawLine
    ; Right
    mov rdi, [renderer]
    mov rsi, 550
    mov rdx, 150
    mov rcx, 550
    mov r8, 190
    call SDL_RenderDrawLine
    
    ; Play Option (300, 250, 200, 30)
    ; Color based on selection
    cmp byte [menu_selection], 0
    jne .play_unselected
    ; Selected (Green)
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    jmp .draw_play
.play_unselected:
    ; Unselected (White)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor
    
.draw_play:
    ; Top
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 250
    mov rcx, 500
    mov r8, 250
    call SDL_RenderDrawLine
    ; Bottom
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 280
    mov rcx, 500
    mov r8, 280
    call SDL_RenderDrawLine
    ; Left
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 250
    mov rcx, 300
    mov r8, 280
    call SDL_RenderDrawLine
    ; Right
    mov rdi, [renderer]
    mov rsi, 500
    mov rdx, 250
    mov rcx, 500
    mov r8, 280
    call SDL_RenderDrawLine
    
    ; Draw "PLAY" text
    call draw_text_play
    
    ; About Option (300, 300, 200, 30)
    cmp byte [menu_selection], 1
    jne .about_unselected
    ; Selected (Green)
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    jmp .draw_about_opt
.about_unselected:
    ; Unselected (White)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor

.draw_about_opt:
    ; Top
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 300
    mov rcx, 500
    mov r8, 300
    call SDL_RenderDrawLine
    ; Bottom
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 330
    mov rcx, 500
    mov r8, 330
    call SDL_RenderDrawLine
    ; Left
    mov rdi, [renderer]
    mov rsi, 300
    mov rdx, 300
    mov rcx, 300
    mov r8, 330
    call SDL_RenderDrawLine
    ; Right
    mov rdi, [renderer]
    mov rsi, 500
    mov rdx, 300
    mov rcx, 500
    mov r8, 330
    call SDL_RenderDrawLine

    ; Draw "ABOUT" text
    call draw_text_about

    mov rdi, [renderer]
    call SDL_RenderPresent
    pop rbp
    ret

RenderAbout:
    push rbp
    mov rbp, rsp
    ; Clear screen (Orange)
    mov rdi, [renderer]
    mov rsi, 200
    mov rdx, 100
    mov rcx, 50
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear
    
    ; Draw some lines as text placeholder
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    ; Line 1
    mov rdi, [renderer]
    mov rsi, 150
    mov rdx, 180
    mov rcx, 650
    mov r8, 180
    call SDL_RenderDrawLine
    
    ; Line 2
    mov rdi, [renderer]
    mov rsi, 150
    mov rdx, 210
    mov rcx, 650
    mov r8, 210
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    call SDL_RenderPresent
    pop rbp
    ret

RenderGameplay:
    push rbp
    mov rbp, rsp
    sub rsp, 128 ; Stack space

    ; Clear
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 0
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    mov rdi, [renderer]
    call SDL_RenderClear
    
    call RenderStars
    call RenderBullets
    call RenderEnemies
    call RenderExplosions
    call RenderShip
    call RenderHUD
    
    mov rdi, [renderer]
    call SDL_RenderPresent
    
    mov rsp, rbp
    pop rbp
    ret

RenderStars:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    
    ; Draw Stars (white dots) - DISABLED FOR TESTING
    ; mov rdi, [renderer]
    ; mov rsi, 255
    ; mov rdx, 255
    ; mov rcx, 255
    ; mov r8, 255
    ; call SDL_SetRenderDrawColor
    ; 
    ; mov rcx, 0
    ; lea rbx, [stars]
;.draw_stars:
;    cmp rcx, 50
;    je .done_stars
;    
;    ; Project star
;    movss xmm0, [rbx]
;    movss xmm1, [rbx + 4]
;    movss xmm2, [rbx + 8]
;    subss xmm2, [cam_z]
;    
;    movss [rbp-32], xmm0
;    movss [rbp-32+4], xmm1
;    movss [rbp-32+8], xmm2
;    lea rdi, [pt_out]
;    lea rsi, [rbp-32]
;    call ProjectPoint
;    
;    cmp eax, 0
;    je .next_star
;    
;    ; Draw as small line (1 pixel)
;    mov edi, [pt_out]
;    mov esi, [pt_out + 4]
;    mov rdi, [renderer]
;    mov ecx, esi
;    mov r8d, esi
;    call SDL_RenderDrawLine
;    
;.next_star:
;    add rbx, 12
;    inc rcx
;    jmp .draw_stars
;.done_stars:
    mov rsp, rbp
    pop rbp
    ret

RenderBullets:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    ; Draw Bullets (Yellow Lines)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
    mov rcx, 0
    lea rbx, [bullets]
.bullet_loop:
    cmp rcx, 20
    je .done_bullets
    cmp dword [rbx + 12], 1
    jne .next_draw_bullet
    
    push rcx ; Save loop counter
    push rax ; Align stack
    
    ; Project Start
    movss xmm0, [rbx]
    movss xmm1, [rbx + 4]
    movss xmm2, [rbx + 8]
    subss xmm2, [cam_z]
    
    movss [rbp-32], xmm0
    movss [rbp-32+4], xmm1
    movss [rbp-32+8], xmm2
    lea rdi, [pt_out]
    lea rsi, [rbp-32]
    call ProjectPoint
    
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
    jmp .bullet_loop
.done_bullets:
    mov rsp, rbp
    pop rbp
    ret

RenderEnemies:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    ; Enemy colors will vary by type - set later per enemy
    mov rcx, 0
    lea rbx, [enemies]
.draw_enemy_loop:
    cmp rcx, 10
    je .done_enemies
    cmp dword [rbx + 12], 1
    jne .next_draw_enemy
    
    ; Set color based on type
    mov al, [rbx + 16]  ; Get type
    cmp al, 0           ; Scout?
    je .set_green
    cmp al, 2           ; Bomber?
    je .set_yellow
    
    ; Fighter (red)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 0
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    jmp .draw_this_enemy
    
.set_green:
    ; Scout (green)
    mov rdi, [renderer]
    mov rsi, 0
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    jmp .draw_this_enemy
    
.set_yellow:
    ; Bomber (yellow)
    mov rdi, [renderer]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 0
    mov r8, 255
    call SDL_SetRenderDrawColor
    
.draw_this_enemy:
    push rcx
    push rax
    
    ; Draw Cube (Just front face for speed)
    ; V0 (-1, -1, -1) + Pos
    
    movss xmm0, [rbx]
    subss xmm0, [one_float]
    movss xmm1, [rbx + 4]
    subss xmm1, [one_float]
    movss xmm2, [rbx + 8]
    subss xmm2, [one_float]
    subss xmm2, [cam_z]
    
    movss [rbp-32], xmm0
    movss [rbp-32+4], xmm1
    movss [rbp-32+8], xmm2
    
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
    addss xmm0, xmm3
    
    mov eax, 300
    cvtsi2ss xmm3, eax
    mulss xmm1, xmm3
    addss xmm1, xmm3
    
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
    
    cmp eax, 0
    je .skip_draw_enemy
    
    mov esi, [pt_out]
    mov edx, [pt_out + 4]
    
    push rcx
    push rax
    
    ; Get size based on type: Scout=10, Fighter=15, Bomber=25
    xor r12d, r12d
    mov r12b, [rbx + 16]
    cmp r12b, 0
    je .size_scout
    cmp r12b, 2
    je .size_bomber
    mov r12d, 15
    jmp .draw_square
.size_scout:
    mov r12d, 10
    jmp .draw_square
.size_bomber:
    mov r12d, 25
    
.draw_square:
    ; Top line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, r12d
    mov r8d, edx
    sub r8d, r12d
    push rsi
    mov esi, ecx
    pop rcx
    lea ecx, [ecx + r12d * 2]
    call SDL_RenderDrawLine
    
    ; Bottom line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, r12d
    mov r8d, edx
    add r8d, r12d
    push rsi
    mov esi, ecx
    pop rcx
    lea ecx, [ecx + r12d * 2]
    call SDL_RenderDrawLine
    
    ; Left line
    mov rdi, [renderer]
    mov ecx, esi
    sub ecx, r12d
    mov r8d, edx
    sub r8d, r12d
    push rdx
    mov edx, r8d
    pop r8
    lea r8d, [r8d + r12d * 2]
    call SDL_RenderDrawLine
    
    ; Right line
    mov rdi, [renderer]
    mov ecx, esi
    add ecx, r12d
    mov r8d, edx
    sub r8d, r12d
    push rdx
    mov edx, r8d
    pop r8
    lea r8d, [r8d + r12d * 2]
    call SDL_RenderDrawLine
    
    pop rax
    pop rcx
    
.skip_draw_enemy:
    pop rax ; Align stack
    pop rcx ; Restore loop counter
    
.next_draw_enemy:
    add rbx, 20
    inc rcx
    jmp .draw_enemy_loop
.done_enemies:
    mov rsp, rbp
    pop rbp
    ret

RenderExplosions:
    push rbp
    mov rbp, rsp
    sub rsp, 128
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
    je .done_explosions
    cmp dword [rbx + 12], 0
    jle .next_explosion
    
    ; Project center
    movss xmm0, [rbx]
    movss xmm1, [rbx + 4]
    movss xmm2, [rbx + 8]
    subss xmm2, [cam_z]
    
    movss [rbp-32], xmm0
    movss [rbp-32+4], xmm1
    movss [rbp-32+8], xmm2
    lea rdi, [pt_out]
    lea rsi, [rbp-32]
    call ProjectPoint
    
    cmp eax, 0
    je .next_explosion
    
    mov esi, [pt_out]
    mov edx, [pt_out + 4]
    
    ; Draw 4 radiating lines (size based on timer)
    mov eax, [rbx + 12]
    imul eax, 3
    
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
.done_explosions:
    mov rsp, rbp
    pop rbp
    ret

RenderShip:
    push rbp
    mov rbp, rsp
    sub rsp, 128
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
    
    movss [rbp-32], xmm0
    movss [rbp-32+4], xmm1
    movss [rbp-32+8], xmm2
    
    lea rdi, [pt_out]
    lea rsi, [rbp-32]
    call ProjectPoint
    
    mov eax, [pt_out]
    mov [rbp - 32 + rcx*8], eax ; Using rbp for stack variables
    mov eax, [pt_out + 4],
    mov [rbp - 32 + rcx*8 + 4], eax ; Using rbp for stack variables
    
    inc rcx
    jmp .proj_loop
    
.draw_lines:
    ; mov rdi, msg_render_ship
    ; xor rax, rax
    ; call printf

    mov rdi, [renderer]
    mov esi, [rbp - 32] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 4] ; Using rbp for stack variables
    mov ecx, [rbp - 32 + 8] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 12] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 8] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 12] ; Using rbp for stack variables
    mov ecx, [rbp - 32 + 16] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 20] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 16] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 20] ; Using rbp for stack variables
    mov ecx, [rbp - 32] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 4] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 4] ; Using rbp for stack variables
    mov ecx, [rbp - 32 + 24] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 28] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 8] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 12] ; Using rbp for stack variables
    mov ecx, [rbp - 32 + 24] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 28] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rdi, [renderer]
    mov esi, [rbp - 32 + 16] ; Using rbp for stack variables
    mov edx, [rbp - 32 + 20] ; Using rbp for stack variables
    mov ecx, [rbp - 32 + 24] ; Using rbp for stack variables
    mov r8d, [rbp - 32 + 28] ; Using rbp for stack variables
    call SDL_RenderDrawLine
    
    mov rsp, rbp
    pop rbp
    ret

RenderHUD:
    push rbp
    mov rbp, rsp
    sub rsp, 128
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
    
    mov rsp, rbp
    pop rbp
    ret

RenderGameOver:
    push rbp
    mov rbp, rsp
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

    mov rdi, [renderer]
    call SDL_RenderPresent
    pop rbp
    ret

draw_text_play:
    ; Draw "PLAY" text inside (300, 250)
    ; P (320, 255)
    mov rdi, [renderer]
    mov rsi, 320
    mov rdx, 255
    mov rcx, 320
    mov r8, 275
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 320
    mov rdx, 255
    mov rcx, 330
    mov r8, 255
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 330
    mov rdx, 255
    mov rcx, 330
    mov r8, 265
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 330
    mov rdx, 265
    mov rcx, 320
    mov r8, 265
    call SDL_RenderDrawLine
    
    ; L (340, 255)
    mov rdi, [renderer]
    mov rsi, 340
    mov rdx, 255
    mov rcx, 340
    mov r8, 275
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 340
    mov rdx, 275
    mov rcx, 350
    mov r8, 275
    call SDL_RenderDrawLine
    
    ; A (360, 255)
    mov rdi, [renderer]
    mov rsi, 360
    mov rdx, 275
    mov rcx, 365
    mov r8, 255
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 365
    mov rdx, 255
    mov rcx, 370
    mov r8, 275
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 362
    mov rdx, 265
    mov rcx, 368
    mov r8, 265
    call SDL_RenderDrawLine
    
    ; Y (380, 255)
    mov rdi, [renderer]
    mov rsi, 380
    mov rdx, 255
    mov rcx, 385
    mov r8, 265
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 390
    mov rdx, 255
    mov rcx, 385
    mov r8, 265
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 385
    mov rdx, 265
    mov rcx, 385
    mov r8, 275
    call SDL_RenderDrawLine
    ret

draw_text_about:
    ; Draw "ABOUT" text inside (300, 300)
    ; A (320, 305)
    mov rdi, [renderer]
    mov rsi, 320
    mov rdx, 325
    mov rcx, 325
    mov r8, 305
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 325
    mov rdx, 305
    mov rcx, 330
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 322
    mov rdx, 315
    mov rcx, 328
    mov r8, 315
    call SDL_RenderDrawLine
    
    ; B (340, 305)
    mov rdi, [renderer]
    mov rsi, 340
    mov rdx, 305
    mov rcx, 340
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 340
    mov rdx, 305
    mov rcx, 350
    mov r8, 305
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 350
    mov rdx, 305
    mov rcx, 350
    mov r8, 315
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 350
    mov rdx, 315
    mov rcx, 340
    mov r8, 315
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 340
    mov rdx, 315
    mov rcx, 350
    mov r8, 315
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 350
    mov rdx, 315
    mov rcx, 350
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 350
    mov rdx, 325
    mov rcx, 340
    mov r8, 325
    call SDL_RenderDrawLine
    
    ; O (360, 305)
    mov rdi, [renderer]
    mov rsi, 360
    mov rdx, 305
    mov rcx, 370
    mov r8, 305
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 370
    mov rdx, 305
    mov rcx, 370
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 370
    mov rdx, 325
    mov rcx, 360
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 360
    mov rdx, 325
    mov rcx, 360
    mov r8, 305
    call SDL_RenderDrawLine
    
    ; U (380, 305)
    mov rdi, [renderer]
    mov rsi, 380
    mov rdx, 305
    mov rcx, 380
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 380
    mov rdx, 325
    mov rcx, 390
    mov r8, 325
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 390
    mov rdx, 325
    mov rcx, 390
    mov r8, 305
    call SDL_RenderDrawLine
    
    ; T (400, 305)
    mov rdi, [renderer]
    mov rsi, 400
    mov rdx, 305
    mov rcx, 410
    mov r8, 305
    call SDL_RenderDrawLine
    mov rdi, [renderer]
    mov rsi, 405
    mov rdx, 305
    mov rcx, 405
    mov r8, 325
    call SDL_RenderDrawLine
    ret

section .data
    one_float dd 1.0
