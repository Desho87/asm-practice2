section .bss
input resb 32
buf resb 16

section .data
msg_signed_less db "SIGNED: a < b",10
len_signed_less equ $-msg_signed_less
msg_signed_equal db "SIGNED: a = b",10
len_signed_equal equ $-msg_signed_equal
msg_signed_greater db "SIGNED: a > b",10
len_signed_greater equ $-msg_signed_greater

msg_unsigned_less db "UNSIGNED: a < b",10
len_unsigned_less equ $-msg_unsigned_less
msg_unsigned_equal db "UNSIGNED: a = b",10
len_unsigned_equal equ $-msg_unsigned_equal
msg_unsigned_greater db "UNSIGNED: a > b",10
len_unsigned_greater equ $-msg_unsigned_greater

section .text
global _start

_start:
; читаем строку с двумя числами
mov eax, 3
mov ebx, 0
mov ecx, input
mov edx, 32
int 0x80

; преобразуем первое число в eax
mov esi, input
xor eax, eax
xor ebx, ebx
parse_a:
mov bl, [esi]
cmp bl, ' '
je parse_b
cmp bl, 10
je parse_b
sub bl, '0'
imul eax, eax, 10
add eax, ebx
inc esi
jmp parse_a

parse_b:
mov edi, eax
inc esi
xor eax, eax
xor ebx, ebx
parse_loop_b:
mov bl, [esi]
cmp bl, 10
je parse_done
sub bl, '0'
imul eax, eax, 10
add eax, ebx
inc esi
jmp parse_loop_b

parse_done:
mov ebx, eax

; SIGNED comparison
mov eax, edi
mov ecx, ebx
cmp eax, ecx
jl signed_less
je signed_equal
jg signed_greater

signed_less:
mov esi, msg_signed_less
mov eax, 4
mov ebx, 1
mov edx, len_signed_less
int 0x80
jmp signed_done
signed_equal:
mov esi, msg_signed_equal
mov eax, 4
mov ebx, 1
mov edx, len_signed_equal
int 0x80
jmp signed_done
signed_greater:
mov esi, msg_signed_greater
mov eax, 4
mov ebx, 1
mov edx, len_signed_greater
int 0x80
signed_done:

; UNSIGNED comparison
mov eax, edi
mov ecx, ebx
cmp eax, ecx
jb unsigned_less
je unsigned_equal
ja unsigned_greater

unsigned_less:
mov esi, msg_unsigned_less
mov eax, 4
mov ebx, 1
mov edx, len_unsigned_less
int 0x80
jmp unsigned_done
unsigned_equal:
mov esi, msg_unsigned_equal
mov eax, 4
mov ebx, 1
mov edx, len_unsigned_equal
int 0x80
jmp unsigned_done
unsigned_greater:
mov esi, msg_unsigned_greater
mov eax, 4
mov ebx, 1
mov edx, len_unsigned_greater
int 0x80
unsigned_done:

; max_signed
mov eax, edi
mov ecx, ebx
cmp eax, ecx
jg max_signed_done
mov eax, ecx
max_signed_done:
call print_number

; max_unsigned
mov eax, edi
mov ecx, ebx
cmp eax, ecx
ja max_unsigned_done
mov eax, ecx
max_unsigned_done:
call print_number

; exit
mov eax, 1
xor ebx, ebx
int 0x80

; ----------------------
print_number:
; выводит число в eax
mov edx, 0
mov ecx, buf+15
mov bx, 10
mov esi, ecx
print_loop:
xor edx, edx
div bx
add dl, '0'
dec esi
mov [esi], dl
cmp eax, 0
jne print_loop
mov eax, 4
mov ebx, 1
mov edx, buf+15-esi
mov ecx, esi
int 0x80
retcd