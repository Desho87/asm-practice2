section .bss
input resb 16
output resb 16

section .text
global _start

_start:
mov eax, 3
mov ebx, 0
mov ecx, input
mov edx, 16
int 0x80

mov esi, input
xor eax, eax
xor ebx, ebx

parse_loop:
mov bl, [esi]
cmp bl, 10
je convert_done
cmp bl, '0'
jb convert_done
cmp bl, '9'
ja convert_done
sub bl, '0'
imul eax, eax, 10
add eax, ebx
inc esi
jmp parse_loop

convert_done:
mov ebx, eax
lea edi, [output+15]
mov ecx, 0

convert_loop:
xor edx, edx
mov eax, ebx
mov ebp, 10
div ebp
add dl, '0'
mov [edi], dl
dec edi
inc ecx
mov ebx, eax
cmp ebx, 0
jne convert_loop

inc edi
mov eax, 4
mov ebx, 1
mov edx, ecx
mov ecx, edi
int 0x80

mov eax, 1
mov ebx, 0
int 0x80