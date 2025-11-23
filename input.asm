section .text

extern SDL_PollEvent
extern reset_game
extern printf

extern game_state
extern running
extern event
extern event_type
extern menu_selection
extern key_w
extern key_s
extern key_a
extern key_d
extern key_space
extern key_r

global process_events

process_events:
    push rbp
    mov rbp, rsp
    
    ; Check game state to decide which input loop to use
    mov al, [game_state]
    cmp al, 2  ; Menu?
    je .menu_input
    cmp al, 3  ; About?
    je .about_input
    
    ; Otherwise normal gameplay input
    jmp .normal_input
    
; ===== MENU INPUT =====
.menu_input:
.poll_menu:
    mov rdi, event
    call SDL_PollEvent
    test eax, eax
    jz .done
    
    mov eax, [event]
    cmp eax, 0x100 ; QUIT
    je .do_quit
    cmp eax, 0x300 ; KEYDOWN
    jne .poll_menu
    
    mov eax, [event + 20] ; sym
    cmp eax, 119 ; w
    je .menu_up
    cmp eax, 115 ; s
    je .menu_down
    cmp eax, 32  ; SPACE
    je .menu_select
    cmp eax, 13  ; ENTER
    je .menu_select
    cmp eax, 27  ; ESC
    je .do_quit
    jmp .poll_menu
    
.menu_up:
    mov byte [menu_selection], 0
    jmp .poll_menu
.menu_down:
    mov byte [menu_selection], 1
    jmp .poll_menu
.menu_select:
    ; Check selection: 0=Play, 1=About
    cmp byte [menu_selection], 0
    je .start_game
    mov byte [game_state], 3  ; Go to about
    jmp .poll_menu
.start_game:
    call reset_game
    mov byte [game_state], 0  ; Start playing
    jmp .poll_menu
    
; ===== ABOUT INPUT =====
.about_input:
.poll_about:
    mov rdi, event
    call SDL_PollEvent
    test eax, eax
    jz .done
    
    mov eax, [event]
    cmp eax, 0x100 ; QUIT
    je .do_quit
    cmp eax, 0x300  ; KEYDOWN
    jne .poll_about
    
    mov eax, [event + 20]
    cmp eax, 32  ; SPACE
    je .about_back
    cmp eax, 13  ; ENTER
    je .about_back
    cmp eax, 27  ; ESC
    je .about_back
    jmp .poll_about
    
.about_back:
    mov byte [game_state], 2  ; Back to menu
    jmp .poll_about

; ===== NORMAL GAMEPLAY INPUT =====
.normal_input:
.poll_loop:
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
    jmp .poll_loop
    
.do_quit:
    mov byte [running], 0
    jmp .done

.keydown:
    mov eax, [event + 20] ; sym
    
    cmp eax, 27 ; ESC
    je .esc_game
    
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
    jmp .poll_loop
    
.esc_game:
    mov byte [game_state], 2 ; Go to Menu
    jmp .done

.w_down: mov byte [key_w], 1
         jmp .poll_loop
.s_down: mov byte [key_s], 1
         jmp .poll_loop
.a_down: mov byte [key_a], 1
         jmp .poll_loop
.d_down: mov byte [key_d], 1
         jmp .poll_loop
.space_down: mov byte [key_space], 1
             jmp .poll_loop
.r_down: mov byte [key_r], 1
         jmp .poll_loop

.keyup:
    mov eax, [event + 20] ; sym
    
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
    jmp .poll_loop

.w_up: mov byte [key_w], 0
       jmp .poll_loop
.s_up: mov byte [key_s], 0
       jmp .poll_loop
.a_up: mov byte [key_a], 0
       jmp .poll_loop
.d_up: mov byte [key_d], 0
       jmp .poll_loop
.space_up: mov byte [key_space], 0
           jmp .poll_loop
.r_up: mov byte [key_r], 0
       jmp .poll_loop

.done:
    pop rbp
    ret
