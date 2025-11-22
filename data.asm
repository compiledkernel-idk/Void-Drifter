; 3D Models for Void Drifter
; Copyright (c) 2025 Void Drifter 3D Contributors
; SPDX-License-Identifier: MIT


section .data
    global ship_model
    global ship_vertex_count
    global enemy_model
    global enemy_vertex_count

; Simple Ship Model (Triangle-ish) - Scaled up 2x
ship_vertex_count dd 4
ship_model:
    ; X, Y, Z
    dd 0.0, -2.0, 0.0  ; Nose
    dd -2.0, 2.0, 0.0  ; Left Wing
    dd 2.0, 2.0, 0.0   ; Right Wing
    dd 0.0, 1.0, -1.0  ; Top Fin

; Enemy Cube Model
enemy_vertex_count dd 8
enemy_model:
    ; Front Face
    dd -1.0, -1.0, -1.0
    dd 1.0, -1.0, -1.0
    dd 1.0, 1.0, -1.0
    dd -1.0, 1.0, -1.0
    ; Back Face
    dd -1.0, -1.0, 1.0
    dd 1.0, -1.0, 1.0
    dd 1.0, 1.0, 1.0
    dd -1.0, 1.0, 1.0
