section .bss
input resb 16
buf resb 16

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
xor ecx, ecx
xor edx, edx
mov esi, 0
mov edi, 0

sum_loop:
xor edx, edx
mov eax, ebx
mov ecx, 10
div ecx
add dl, '0'
mov [buf+edi], dl
inc edi
mov ebx, eax
cmp ebx, 0
jne sum_loop

mov eax, 4
mov ebx, 1
mov ecx, buf
mov edx, edi
int 0x80

mov eax, 1
mov ebx, 0
int 0x80