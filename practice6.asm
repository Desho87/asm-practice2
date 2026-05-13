section .data
    prompt db "Enter two numbers: ", 0
    msg_signed db "SIGNED: a > b", 10, 0
    msg_unsigned db "UNSIGNED: a > b", 10, 0
    msg_max_signed db "max_signed: ", 0
    msg_max_unsigned db "max_unsigned: ", 0

section .bss
    buffer resb 32
    a resd 1
    b resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 19
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 32
    int 0x80

    mov esi, buffer
    call parse_int
    mov [a], eax

    mov esi, buffer
    call parse_int
    mov [b], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_signed
    mov edx, 14
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_unsigned
    mov edx, 16
    int 0x80

    mov eax, [a]
    call print_int

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
    cmp dl, 32
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