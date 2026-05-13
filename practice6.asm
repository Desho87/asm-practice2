; practice6.asm
; Signed/Unsigned comparison

section .data
    prompt      db "Enter two numbers (a b): ", 0
    len_prompt  equ $ - prompt
    
    msg_signed  db "SIGNED: ", 0
    len_signed  equ $ - msg_signed
    
    msg_unsigned db "UNSIGNED: ", 0
    len_unsigned equ $ - msg_unsigned
    
    msg_max_signed db "max_signed: ", 0
    len_max_signed equ $ - msg_max_signed
    
    msg_max_unsigned db "max_unsigned: ", 0
    len_max_unsigned equ $ - msg_max_unsigned
    
    msg_less    db "a < b", 10, 0
    len_less    equ $ - msg_less
    
    msg_equal   db "a = b", 10, 0
    len_equal   equ $ - msg_equal
    
    msg_greater db "a > b", 10, 0
    len_greater equ $ - msg_greater
    
    newline     db 10, 0

section .bss
    buffer      resb 32
    a           resd 1
    b           resd 1
    temp        resd 1

section .text
    global _start

_start:
    ; I/O: prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, len_prompt
    int 0x80

    ; I/O: read numbers
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 32
    int 0x80

    ; parse: first number
    mov esi, buffer
    call parse_int
    mov [a], eax

    ; parse: second number
    mov esi, buffer
    call parse_int
    mov [b], eax

    ; LOGIC: signed comparison
    mov eax, [a]
    mov ebx, [b]
    
    cmp eax, ebx
    jl signed_less
    jg signed_greater
    
    mov ecx, msg_equal
    mov edx, len_equal
    jmp print_signed
    
signed_less:
    mov ecx, msg_less
    mov edx, len_less
    jmp print_signed
    
signed_greater:
    mov ecx, msg_greater
    mov edx, len_greater

print_signed:
    push ecx
    push edx
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_signed
    mov edx, len_signed
    int 0x80
    
    pop edx
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; LOGIC: unsigned comparison
    mov eax, [a]
    mov ebx, [b]
    
    cmp eax, ebx
    jb unsigned_less
    ja unsigned_greater
    
    mov ecx, msg_equal
    mov edx, len_equal
    jmp print_unsigned
    
unsigned_less:
    mov ecx, msg_less
    mov edx, len_less
    jmp print_unsigned
    
unsigned_greater:
    mov ecx, msg_greater
    mov edx, len_greater

print_unsigned:
    push ecx
    push edx
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_unsigned
    mov edx, len_unsigned
    int 0x80
    
    pop edx
    pop ecx
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; MATH: max_signed
    mov eax, [a]
    mov ebx, [b]
    
    cmp eax, ebx
    jg signed_a_is_max
    mov eax, ebx
signed_a_is_max:
    mov [temp], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max_signed
    mov edx, len_max_signed
    int 0x80
    
    mov eax, [temp]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; MATH: max_unsigned
    mov eax, [a]
    mov ebx, [b]
    
    cmp eax, ebx
    ja unsigned_a_is_max
    mov eax, ebx
unsigned_a_is_max:
    mov [temp], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max_unsigned
    mov edx, len_max_unsigned
    int 0x80
    
    mov eax, [temp]
    call print_int
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; I/O: exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

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