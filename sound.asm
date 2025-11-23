; Sound System for Void Drifter
; Copyright (c) 2025 Void Drifter 3D Contributors
; SPDX-License-Identifier: MIT


extern SDL_OpenAudioDevice
extern SDL_PauseAudioDevice
extern Mix_OpenAudio
extern Mix_LoadMUS
extern Mix_PlayMusic
extern Mix_Init
extern printf

section .bss
    audio_spec resb 32 ; SDL_AudioSpec
    music_handle dq 0
    
section .data
    dev_id dd 0
    
    ; Sound State
    global sound_timer
    sound_timer dd 0
    sound_freq dd 0
    phase dd 0.0
    
    music_file db "assets/terrariakoning.mp3", 0
    music_err_msg db "Failed to load music", 10, 0
    
section .text
    global InitSound
    global AudioCallback
    global AudioCallback
    global PlaySound
    global PlayBackgroundMusic

; InitSound()
InitSound:
    push rbp
    mov rbp, rsp
    
    ; Fill AudioSpec
    mov dword [audio_spec], 44100 ; freq
    mov word [audio_spec + 4], 0x8120 ; AUDIO_F32
    mov byte [audio_spec + 6], 1 ; channels
    mov word [audio_spec + 8], 4096 ; samples
    
    mov rax, AudioCallback
    mov [audio_spec + 16], rax ; callback
    
    ; Open Device
    mov rdi, 0 ; device name (NULL)
    mov rsi, 0 ; iscapture (0)
    mov rdx, audio_spec ; desired
    mov rcx, 0 ; obtained (NULL)
    mov r8, 0 ; allowed_changes (0)
    call SDL_OpenAudioDevice
    
    mov [dev_id], eax
    
    ; Unpause
    mov rdi, rax
    mov rsi, 0 ; pause_on (0)
    call SDL_PauseAudioDevice
    
    mov eax, 1
    pop rbp
    ret

PlayBackgroundMusic:
    push rbp
    mov rbp, rsp
    
    ; Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048)
    ; MIX_DEFAULT_FORMAT = 0x8010 (AUDIO_S16LSB)
    mov rdi, 44100
    mov rsi, 0x8010
    mov rdx, 2
    mov rcx, 2048
    call Mix_OpenAudio
    
    ; Load Music
    mov rdi, music_file
    call Mix_LoadMUS
    mov [music_handle], rax
    
    cmp rax, 0
    je .err
    
    ; Play Music (handle, loops=-1)
    mov rdi, rax
    mov rsi, -1
    call Mix_PlayMusic
    jmp .done
    
.err:
    ; mov rdi, music_err_msg
    ; xor rax, rax
    ; call printf
    
.done:
    pop rbp
    ret

; PlaySound(int type)
; 0 = Shoot (High pitch, short)
; 1 = Explosion (Low pitch, long)
PlaySound:
    push rbp
    mov rbp, rsp
    
    cmp rdi, 0
    je .shoot
    cmp rdi, 1
    je .explode
    jmp .done_play
    
.shoot:
    mov dword [sound_timer], 10000 ; Samples duration
    mov dword [sound_freq], 880
    jmp .done_play
    
.explode:
    mov dword [sound_timer], 20000
    mov dword [sound_freq], 110
    
.done_play:
    pop rbp
    ret

; AudioCallback(void* userdata, Uint8* stream, int len)
AudioCallback:
    push rbp
    mov rbp, rsp
    
    ; rsi = stream (float*)
    ; rdx = len (bytes) -> len/4 samples
    
    shr rdx, 2 ; len /= 4 (bytes to floats)
    mov rcx, 0
    
.loop:
    cmp rcx, rdx
    je .done
    
    ; Check timer
    cmp dword [sound_timer], 0
    jle .silence
    
    ; Generate Square Wave
    ; phase += freq / 44100
    
    movss xmm0, [phase]
    cvtsi2ss xmm1, [sound_freq]
    divss xmm1, [sample_rate]
    addss xmm0, xmm1
    
    ; Wrap phase 0..1
    movss xmm2, [one]
    ucomiss xmm0, xmm2
    jb .no_wrap
    subss xmm0, xmm2
.no_wrap:
    movss [phase], xmm0
    
    ; Output
    ; if phase < 0.5 -> 0.1, else -0.1
    movss xmm1, [half]
    ucomiss xmm0, xmm1
    jb .high
    
    movss xmm2, [vol_low]
    jmp .store
.high:
    movss xmm2, [vol_high]
.store:
    movss [rsi + rcx*4], xmm2
    
    dec dword [sound_timer]
    jmp .next
    
.silence:
    mov dword [rsi + rcx*4], 0
    
.next:
    inc rcx
    jmp .loop
    
.done:
    pop rbp
    ret

section .data
    sample_rate dd 44100.0
    one dd 1.0
    half dd 0.5
    vol_high dd 0.1
    vol_low dd -0.1
