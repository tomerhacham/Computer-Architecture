section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string
	values: db "0123456789ABCDEF"

section .data                    	; we define (global) initialized variables in .data section
	number: dd 0										; global variable ot hold the decimal value of the string that was typed as argument
	counter: dd 0										;count the number of push that has been preformed to the stack


section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 12			; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]

section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp
	pushad

	mov ecx, dword [ebp+8]	; get function argument (pointer to string)

	pushad
	call init_Adder
	popad

	pushad
	call init_Divide
	popad

	pushad
	push an
	push format_string
	call printf
	pop eax
	pop eax
	popad

	popad
	mov eax,an         			; return an (returned values are in eax)
	mov esp, ebp
	pop ebp
	ret

init_Adder:
		and eax, 0
		and edx, 0
		and ebx, 0
		mov byte [counter],0
Adder:
		mov bl, byte [ecx]
		sub bl, 0x30 				;convert to numeric value from ASCII
		add eax,ebx
		cmp byte [ecx+1], 0	;checks if the next char is null terminating
		je end_adder
		cmp byte [ecx+1],10	;checks if the next char is '\n'
		je end_adder
		mov ebx,10
		mul ebx							;multiply the incremeted number by 10 becuase there is another digit to read
		inc ecx
		jmp Adder
end_adder:
		mov dword [number], eax	;store the decimal value that was calculated
		ret

init_Divide:
	cmp dword [number],0
	je handle_only_zeros
	mov eax,dword [number]
	and ecx,0 ; ad i for the an array
	and ebx, 0
	push ebx
	inc dword [counter]
	and edx,0 ;reminder
Divide:
	cmp eax,0
	je end_divide
	mov ebx,0
	mov edx,0
	mov ebx,16	;divisor
	div ebx
	mov bl, byte [values+edx] ;get the ascii char
	and ebx, 0x00FF
	push ebx
	inc dword [counter]
	jmp Divide
end_divide:
	jmp init_set_string
	return_set_string:
	ret

init_set_string:
	mov ecx,0
	set_string:
	cmp ecx, dword [counter]
	je end_set_string
	pop eax
	mov byte [an+ecx], al
	inc ecx
	jmp set_string
	end_set_string:
	jmp return_set_string

handle_only_zeros:
	mov byte [an],48
	mov byte [an+1],0
	jmp return_set_string
