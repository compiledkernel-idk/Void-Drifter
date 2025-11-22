; 3D Math Library for Void Drifter
; Copyright (c) 2025 Void Drifter 3D Contributors
; SPDX-License-Identifier: MIT

; Uses SSE for performance

section .text
    global Vec3_Add
    global Vec3_Sub
    global ProjectPoint

; Vec3_Add(float* out, float* a, float* b)
Vec3_Add:
    movups xmm0, [rsi]
    movups xmm1, [rdx]
    addps xmm0, xmm1
    movups [rdi], xmm0
    ret

; Vec3_Sub(float* out, float* a, float* b)
Vec3_Sub:
    movups xmm0, [rsi]
    movups xmm1, [rdx]
    subps xmm0, xmm1
    movups [rdi], xmm0
    ret

; ProjectPoint(float* out_2d, float* in_3d, float fov, float aspect)
; out_2d: [x, y]
; in_3d: [x, y, z]
; Simple perspective projection: x' = x/z, y' = y/z
ProjectPoint:
    ; Load Input
    movss xmm0, [rsi]     ; x
    movss xmm1, [rsi + 4] ; y
    movss xmm2, [rsi + 8] ; z
    
    ; Check Z > 0.1 to avoid div by zero or behind camera
    movss xmm3, [min_z]
    ucomiss xmm2, xmm3
    jbe .behind
    
    ; Perspective Divide
    divss xmm0, xmm2 ; x / z
    divss xmm1, xmm2 ; y / z
    
    ; Scale by FOV (approximate)
    ; Screen Scale = 400 (Half Width)
    mov eax, 400
    cvtsi2ss xmm3, eax
    mulss xmm0, xmm3
    mulss xmm1, xmm3
    
    ; Center on Screen (400, 300)
    addss xmm0, xmm3 ; x + 400
    
    mov eax, 300
    cvtsi2ss xmm4, eax
    addss xmm1, xmm4 ; y + 300
    
    ; Store (Convert to Int)
    cvtss2si eax, xmm0
    mov [rdi], eax
    cvtss2si eax, xmm1
    mov [rdi + 4], eax
    
    mov eax, 1 ; Visible
    ret
    
.behind:
    mov dword [rdi], 0
    mov dword [rdi+4], 0
    mov eax, 0 ; Not visible
    ret

section .data
    min_z dd 0.1
