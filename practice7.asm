; practice7.asm
; Array generation, find min/max and their indices

section .data
    prompt      db "Enter n (5..50): ", 0
    len_prompt  equ $ - prompt
    
    msg_array   db "Array: ", 0
    len_array   equ $ - msg_array
    
    msg_min     db "min: ", 0
    len_min     equ $ - msg_min
    
    msg_max     db "max: ", 0
    len_max     equ $ - msg_max
    
    msg_index   db " at index ", 0
    len_index   equ $ - msg_index
    
    space       db " ", 0
    len_space   equ $ - space
    
    newline     db 10, 0
    len_newline equ $ - newline

section .bss
    n           resd 1
    array       resd 50
    buffer      resb 32
    min_val     resd 1
    min_idx     resd 1
    max_val     resd 1
    max_idx     resd 1

section .text
    global _start

_start:
    ; I/O: prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, len_prompt
    int 0x80

    ; I/O: read n
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 32
    int 0x80

    ; parse: convert n
    mov esi, buffer
    call parse_int
    mov [n], eax

    ; math: generate array (array[i] = i * 7 + 3)
    mov ecx, 0
    mov edx, [n]
    mov ebx, 7
    mov esi, 3

generate_loop:
    cmp ecx, edx
    jge generate_done
    
    mov eax, ecx
    imul eax, ebx
    add eax, esi
    
    mov [array + ecx*4], eax
    
    inc ecx
    jmp generate_loop
generate_done:

    ; I/O: print "Array: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_array
    mov edx, len_array
    int 0x80

    ; I/O: print array
    mov ecx, 0
    mov edx, [n]
    
print_array_loop:
    cmp ecx, edx
    jge print_array_done
    
    mov eax, [array + ecx*4]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, len_space
    int 0x80
    
    inc ecx
    jmp print_array_loop
print_array_done:

    ; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, len_newline
    int 0x80

    ; logic: find min and max
    mov eax, [array]
    mov [min_val], eax
    mov [max_val], eax
    mov dword [min_idx], 0
    mov dword [max_idx], 0
    
    mov ecx, 1
    mov edx, [n]
    
find_loop:
    cmp ecx, edx
    jge find_done
    
    mov eax, [array + ecx*4]
    
    cmp eax, [min_val]
    jge check_max
    mov [min_val], eax
    mov [min_idx], ecx
    jmp next_iter
    
check_max:
    cmp eax, [max_val]
    jle next_iter
    mov [max_val], eax
    mov [max_idx], ecx
    
next_iter:
    inc ecx
    jmp find_loop
find_done:

    ; I/O: print min
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, len_min
    int 0x80
    
    mov eax, [min_val]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_index
    mov edx, len_index
    int 0x80
    
    mov eax, [min_idx]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, len_newline
    int 0x80

    ; I/O: print max
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, len_max
    int 0x80
    
    mov eax, [max_val]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_index
    mov edx, len_index
    int 0x80
    
    mov eax, [max_idx]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, len_newline
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ========== parse: string to int ==========
parse_int:
    xor eax, eax
    xor ecx, ecx
    mov cl, 10
    
parse_loop:
    mov dl, [esi]
    cmp dl, 0
    je parse_done
    cmp dl, 10
    je parse_done
    cmp dl, 13
    je parse_done
    cmp dl, ' '
    je parse_done
    
    sub dl, '0'
    imul eax, ecx
    add eax, edx
    
    inc esi
    jmp parse_loop
    
parse_done:
    ret

; ========== I/O: print int ==========
print_int:
    pusha
    mov ecx, 10
    mov edi, buffer
    add edi, 31
    mov byte [edi], 0
    dec edi
    
    mov ebx, eax
    cmp ebx, 0
    jge print_loop
    neg ebx
    
print_loop:
    mov eax, ebx
    xor edx, edx
    div ecx
    mov ebx, eax
    add dl, '0'
    mov [edi], dl
    dec edi
    cmp ebx, 0
    jne print_loop
    
    inc edi
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buffer
    add edx, 31
    sub edx, edi
    inc edx
    int 0x80
    
    popa
    ret