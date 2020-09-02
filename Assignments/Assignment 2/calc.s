	section	.rodata			; we define (global) read-only variables in .rodata section
	length equ 80
	format_hex: db "%X", 10, 0      ; format to print the num in hex
	format_reg: db "%s", 10, 0
	stack_size_msg: db "stack_size: %d", 10, 0      ; format to print the num in hex
	is_debug_msg: db "debug: %d", 10, 0      ; format to print the num in hex
	msg_overflow: db "Error Operand Stack Overflow", 10, 0
	msg_Insuff: db "Error Insufficient Number of Arguments on Stack", 10, 0
	debug_push_msg: db "Pushed: %p", 10, 0
	debug_pop_msg: db "Poped: %p", 10, 0
	DATA_msg: db "DATA: %X", 10, 0
	Next_msg: db "Next: %p", 10, 0
	Link_Address_msg: db "Link Address: %p", 10, 0
	arg1: db "arg1: %X", 10, 0
	arg2: db "arg2: %X", 10, 0
	format_operand: db "%X",0
	new_line: db 10, 0
	calc_msg: db "calc: ",0,0
	digit_format: db "%02X",0
	DATA equ 0	;offest inside the link itself
	NEXT equ 1  ;offest inside the link itself
	Link_size equ 5


section .data                       ; we define (global) initialized variables in .data section
    active_flag: dd 1
    even_flag: dd 0
    debug: dd 0               	
    count_operation: dd 0       ; store the numbers of operation
    count_num: dd 0             ; count the number of operand in the stack
    stack_size: dd 5			;default value 5
    string_size: dd 0

section .bss			; we define (global) uninitialized variables in .bss section
	return: resb 4		;functions as return register
	start_SPP: resb 4	;start of the allocated memry segm
	SPP: resb 4			;stack pointer to the operand stack
	SPP_main: resb 4 	;stack pointer of the main
	buffer: resb 80

section .text
    global main
	align 16
    global main
    extern printf
    extern fprintf 
    extern fflush
    extern malloc 
    extern calloc 
    extern free 
    extern getchar 
    extern fgets
	extern stderr
	extern stdin 

macros:
	%macro if_debug 1 
		cmp dword [debug],1
		jne %%end_if
		%1
		%%end_if:
	%endmacro
	
	%macro print2 2
	;not supporting prints from memory
		pushad
		push %1 
		push %2
		call printf
		add esp, 8
		popad
	%endmacro

	%macro print 1
	;not supporting prints from memory
		pushad
		push %1 
		call printf
		add esp, 4
		popad
	%endmacro

	%macro print_debug 2
	;not supporting prints from memory
		pushad
		push %1
		push %2
		push dword [stderr]
		call fprintf
		add esp, 12
		popad
	%endmacro

	%macro call_func_0p 1
		pushad
		call %1
		mov dword [return], eax
		popad
	%endmacro

	%macro call_func_1p 2
		pushad
		push %2
		call %1
		add esp, 4
		mov dword[return], eax
		popad
	%endmacro

	%macro call_func_2p 3
		pushad
		push %3
		push %2
		call %1
		add esp, 8
		mov dword [return], eax
		popad
	%endmacro


	%macro call_func_3p 4
		pushad
		push %4
		push %3
		push %2
		call %1
		add esp, 12
		mov dword [return], eax
		popad
	%endmacro

main:
	push    ebp             ;open new ctivation frame
	mov     ebp, esp
	pushad 
	pushfd
	mov ebx,dword [ebp+8]           ;ebx holds argc
	mov eax,dword [ebp+12]          ;eax hold pointer to argv
	mov ecx,dword [eax+4]			;argv[1]
	mov edx,dword [eax+8]			;argv[2]

	
        ; initilaize of the stack
	call_func_3p arguments,ebx,ecx,edx
	call_func_0p alloc_stack
	call_func_0p myCalc
	mov eax, dword [count_operation]
	print2 eax,format_hex
	popfd
	popad
	mov esp,ebp
	pop ebp
	ret

myCalc:
	push ebp
	mov ebp,esp
	.loop:
	cmp dword [active_flag],1
	jne .end
	print calc_msg
	call_func_0p get_input
	call_func_0p operator
	jmp .loop
	.end:
	;mov ebx,[start_SPP]
	mov ebx, [SPP]
	if_debug {print2 ebx, Link_Address_msg}
	call_func_1p free,ebx
	mov esp,ebp
	pop ebp
	ret

arguments:
	push ebp
	mov ebp,esp
	mov ebx, dword [ebp+8]
	mov ecx, dword [ebp+12]
	mov edx, dword [ebp+16]
	;assuming ebx hold argc
	;assuming ecx points to argv[1]
	;assuming edx points to argv[2]
        cmp ebx, 1    	; in case argc=1 meaning there is no any argument provided
        je .end  		
		cmp ebx, 2
		jne .debug_and_size 
	.debugOrSize:				;need to check if -d or number
		cmp word [ecx], '-d'
		jne .size
		inc dword [debug]
		jmp .end
	.size:						;only size argument provided
		call_func_1p calc_stack_size, ecx
		;push ecx
		;call calc_stack_size
		jmp .end
	.debug_and_size: 			;both argument has been provided
		inc dword [debug]
		call_func_1p calc_stack_size, ecx
		;push ecx
		;call calc_stack_size
		jmp .end
	.end:
		mov esp,ebp
		pop ebp
		;ret 12
		ret

calc_stack_size:
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8]
	;assuming ecx hold pointer to the first char of the string 
	;result will be store at [stack_size]
	.init:
		and ebx, 0
		and eax, 0
	.Adder:
		mov bl,byte [ecx]		;argv[1] char at ecx position		
		cmp bl, '9'
		ja .is_letter
		sub bl, 0x30 ;convert to numeric value from ASCII
		jmp .con_adder           
	.is_letter:
        sub bl, 0x37 ;convert to numeric value from ASCII
	.con_adder:
		add eax,ebx
		cmp byte [ecx+1], 0	;checks if the next char is null terminating
		je .end
		cmp byte [ecx+1],10	;checks if the next char is '\n'
        je .end
        mov ebx, 16
        mul ebx
		inc ecx
        jmp .Adder
	.end:
        mov byte [stack_size], al
		mov esp,ebp
		pop ebp
		;ret 4
		ret

alloc_stack:
	push ebp
	mov ebp,esp
	;assuming [size_stack] store the decimal value of how many operands the stach will store  
	and dword [SPP] ,0
	and eax,0
	mov eax ,dword [stack_size] ; number of operands
	mov ebx, 4 		; nnumber of bytes per number
	mul ebx
	mov edx, eax

	call_func_1p malloc, eax
	mov eax, dword [return]
	;mov [start_SPP], eax
	;add edx, eax
	;mov [SPP],edx ;get pointer to the begin of stack 
	mov dword [SPP], eax
	mov esp,ebp
	pop ebp
	ret

pop_operand:
	push ebp
	mov ebp,esp
	;the poped number will be stored at EAX
	cmp dword [count_num], 0
	je .pop_error
	;mov dword [SPP_main], esp 	;save ESP value
	;mov esp, dword [SPP] 		;point the stack to the operands stack
	;pop eax
	;mov dword [SPP], esp		;update the operand stacks pointer
	;mov esp, dword [SPP_main]	;restore ESP value
	sub dword [SPP], 4
	mov ebx, dword [SPP]
	mov eax, dword [ebx]
	dec dword [count_num]
	if_debug {print_debug eax , debug_pop_msg}
	jmp .end
	.pop_error:
	print msg_Insuff
	mov eax, -1
	.end:
	mov esp,ebp
	pop ebp
	ret

push_operand:
	;param1-> pointer to the head of the list of the new Number
	push ebp
	mov ebp,esp
	mov eax, dword [ebp+8]

	call_func_1p check_zeros, eax
	mov eax, [return]
	cmp eax,0
	jne .con

	call_func_2p new_link,eax,0
	mov eax, [return]
	; mov [eax+NEXT], ebx
	; mov eax, dword [return]

	.con:
	mov ebx, dword [count_num]
	cmp ebx, dword [stack_size]
	je .push_error
	;mov dword [SPP_main], esp 	;save ESP value
	;mov esp, dword [SPP] 		;point the stack to the operands stack
	;push eax
	;mov dword [SPP], esp		;update the operand stacks pointer
	;mov esp, dword [SPP_main]	;restore ESP value
	mov ebx, dword [SPP]
	mov dword [ebx], eax
	add dword [SPP], 4
	inc dword [count_num]
	if_debug {print_debug eax,debug_push_msg}
	jmp .end
	.push_error:
	print msg_overflow
	mov eax, -1
	.end:
	mov esp,ebp
	pop ebp
	;ret 4
	ret

get_input:
	;return value will be store at [buffer]
	push ebp
	mov ebp,esp
	push dword [stdin]              ;fgets need 3 param
	push length                   ;max lenght
	push buffer               ;input buffer
	call fgets
	add esp, 12
	mov esp,ebp
	pop ebp
	ret

new_link:
	;param1: Data-> byte size 
	;param2: Next ->address of the the next Link
	;return the pointer to the new link (store in eax)
	push ebp
	mov ebp,esp
	mov ebx, dword [ebp+8] 	;DATA arg
	mov ecx, dword [ebp+12] 	;Next arg
	;if_debug {print2 ebx,arg1}
	;if_debug {print2 ecx,arg2}

	call_func_2p calloc, Link_size,1
	mov eax, dword [return]

	.break:
	mov byte [eax+DATA],bl
	mov dword [eax+NEXT],ecx
	;if_debug {call_func_1p print_link,eax}
	mov esp,ebp
	pop ebp
	;ret 8
	ret

str_len:
	;param1: char* ->byte size
	;return value stored at eax
	push ebp
	mov ebp,esp
	mov ebx,dword [ebp+8] ;pointer of the string
	mov ecx,0
	mov dword [string_size], 0
	.loop:
	cmp byte [ebx+ecx+1], 0	;checks if the next char is null terminating
	je .end
	cmp byte [ebx+ecx+1],10	;checks if the next char is '\n'
	je .end
	inc ecx
	jmp .loop
	.end:
	inc ecx
	mov dword [string_size],ecx
	mov esp,ebp
	pop ebp
	;ret 4
	ret

isEven:
	;param1: str_size ->
	;return value stored at eax
	push ebp
	mov ebp,esp
	mov eax,dword [ebp+8] ;arg 1
	and edx,0
	mov ebx, 2
	div ebx
	cmp edx, 0
	je .iseven
	.isodd:
	mov dword [even_flag],0
	jmp .end
	.iseven:
	mov dword [even_flag],1
	.end:
	mov esp,ebp
	pop ebp
	;ret 4
	ret

convertToInt:
	;param1:  dword size e.g  ['0','A']
	push ebp
	mov ebp,esp
	and ecx,0
	mov cx, word [ebp+8]
	mov edx,0
	.init:
		and ebx, 0
		and eax, 0
	.Adder:
		cmp edx,1
		je .second
		mov bl,ch		;argv[1] char at ecx position
		jmp .c	
		.second:
		mov bl,cl
		.c:	
		cmp bl, '9'
		ja .is_letter
		sub bl, 0x30 	;convert to numeric value from ASCII
		jmp .con_adder           
	.is_letter:
        sub bl, 0x37 	;convert to numeric value from ASCII
	.con_adder:
		add eax,ebx
		cmp edx, 1	;checks if the next char is null terminating
        je .end
        mov ebx, 16
        mul ebx
		inc edx
        jmp .Adder
	.end:
		if_debug{print_debug eax,is_debug_msg}
		mov esp,ebp
		pop ebp
		;ret 4
		ret

get_operand:
	push ebp
	mov ebp,esp
	;mov ecx, dword [ebp+8] 	;pointer to the buffer
	mov edx,0 				;hold the pointer for the 'next' link to be passed
	;call_func_0p get_input
	call_func_1p str_len, buffer
	.break:
	mov eax, dword [string_size]
	mov ecx,0
	call_func_1p isEven,eax
	cmp dword [even_flag],1
	je .even
	.odd:
	mov eax,0   
	mov ecx,0				;[0,0,0,0]
	mov eax , 0x00003000
	mov al, byte [buffer+ecx] 	;[0,0,0,'x']
	call_func_1p convertToInt,eax
	mov eax,[return]
	mov edx,0
	call_func_2p new_link,eax,edx
	mov edx,[return]
	;call_func_1p print_link,edx
	inc ecx
	.even:
	cmp byte [buffer+ecx],0
	je .end
	cmp byte [buffer+ecx],10
	je .end
	mov eax,0	
	mov ax, word [buffer+ecx]
	push ebx
	and ebx,0
	mov bl,ah
	mov bh,al
	mov eax,ebx
	pop ebx
	call_func_1p convertToInt,eax
	mov al, byte [return]
	and eax,0x00FF
	call_func_2p new_link,eax,edx
	mov edx,[return]
	;call_func_1p print_link,edx
	add ecx,2
	jmp .even
	.end:
	call_func_1p push_operand, edx
	mov esp,ebp
	pop ebp
	ret 

print_link:
	;param1: pointer to the link to be print
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8]	;pointer for the link
	if_debug {print_debug ecx , Link_Address_msg}
	and eax,0
	mov al ,byte [ecx+DATA]
	if_debug {print2 eax,DATA_msg}
	;print2 eax,DATA_msg
	mov eax, dword [ecx+NEXT]
	if_debug {print2 eax,Next_msg }
	if_debug {print new_line}
	;print2 eax, Next_msg
	mov esp,ebp
	pop ebp
	;ret 4
	ret

print_operand:
	;param1; pointer to the operand to print
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8] 	; pointer to the first Link of the operand 
	mov edx,0     			;counter to number of links
	.iterate:
	cmp ecx, 0  			; if curr==NULL?
	je .print_data
	and ebx, 0
	mov bl, byte [ecx+DATA]
	push ebx 				;where is the pop?
	inc edx
	mov eax, edx            ; copy to counter
	mov ecx, [ecx+NEXT]   	;pointer to next link curr=curr->next
	jmp .iterate
	.print_data:
	cmp edx, 0 
	je .end
	pop ebx
	cmp edx, eax
	jne .reg_print
	.special_print:
	print2 ebx, format_operand
	jmp .c
	.reg_print:
	print2 ebx,digit_format
	.c:
	dec edx
	jmp .print_data
	.end:
	print new_line     
	mov esp,ebp
	pop ebp
	ret 

free_operand:
	;param1: pointer to the link to be print
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8]	;pointer for the link
	mov edx, ecx
	.free:
	mov ebx, ecx
	mov ecx, [ecx+NEXT]
	call_func_1p free, ebx
	if_debug {print2 ebx, Link_Address_msg}

	cmp ecx, 0
	je .end
	jmp .free
	.end:
	mov edx, 0
	mov esp,ebp
	pop ebp
	;ret 4
	ret


operator:
	;param1: char which represent the symbol of the operator ('|','&','+','q','p','d','n' OR pointer to string)
	push ebp
	mov ebp,esp
	and ecx,0
	mov ecx, dword [buffer]
	cmp cl,'+'
	je .call_plus
	cmp cl, '|'
	je .call_or
	cmp cl,'&'
	je .call_and
	cmp cl,'q'
	je .call_quit
	cmp cl,'p'
	je .call_print
	cmp cl,'d'
	je .call_duplicate
	cmp cl,'n'
	je .call_numHex
	jne .call_get_opernad;; change to get_operand
	.call_plus:
	call_func_0p plus_f
	inc dword [count_operation]
	jmp .end
	.call_or:
	call_func_0p or_f
	inc dword [count_operation]
	jmp .end
	.call_and:
	call_func_0p and_f
	inc dword [count_operation]
	jmp .end
	.call_quit:
	call_func_0p quit_f
	jmp .end
	.call_print:
	call_func_0p print_f
	inc dword [count_operation]		
	jmp .end
	.call_duplicate:
	call_func_0p duplicate_f
	inc dword [count_operation]
	jmp .end
	.call_numHex:
	call_func_0p numhex_f
	inc dword [count_operation]
	jmp .end
	.call_get_opernad:
	call_func_0p get_operand
	jmp .end
	.end:	
	mov esp,ebp
	pop ebp
	;ret 4
	ret

plus_f:
	push ebp
	mov ebp,esp
	push eax
	call_func_0p check_if_two_operands
	mov eax, dword [return]
	cmp eax ,-1
	je .end
	pop eax 
	call_func_0p pop_operand
	mov ebx, dword [return]
	cmp ebx, -1
	je .end
	call_func_0p pop_operand
	mov ecx, dword [return]
	cmp ecx, -1
	je .end

	call_func_3p plus_rec,ebx,ecx,0
	mov eax, [return]
	call_func_1p free_operand, ebx
	call_func_1p free_operand, ecx
	call_func_1p push_operand ,eax

	.end:
	mov esp,ebp
	pop ebp
	ret

or_f:
	push ebp
	mov ebp,esp
	push eax
	call_func_0p check_if_two_operands
	mov eax, dword [return]
	cmp eax ,-1
	je .end
	pop eax 
	call_func_0p pop_operand
	mov ebx, dword [return]
	cmp ebx, -1
	je .end
	call_func_0p pop_operand
	mov ecx, dword [return]
	cmp ecx, -1
	je .end

	call_func_2p or_rec,ebx,ecx
	mov eax, [return]
	call_func_1p free_operand, ebx
	call_func_1p free_operand, ecx
	call_func_1p push_operand ,eax

	.end:
	mov esp,ebp
	pop ebp
	ret

and_f:
	push ebp
	mov ebp,esp
	push eax
	call_func_0p check_if_two_operands
	mov eax, dword [return]
	cmp eax ,-1
	je .end
	pop eax 
	call_func_0p pop_operand
	mov ebx, dword [return]
	cmp ebx, -1
	je .end
	call_func_0p pop_operand
	mov ecx, dword [return]
	cmp ecx, -1
	je .end

	call_func_2p and_rec,ebx,ecx
	mov eax, [return]
	call_func_1p free_operand, ebx
	call_func_1p free_operand, ecx
	call_func_1p push_operand ,eax

	.end:
	mov esp,ebp
	pop ebp
	ret

quit_f:
	push ebp
	mov ebp,esp
	.loop:
	cmp dword [count_num], 0
	je .end
	call_func_0p pop_operand
	mov eax, [return]
	call_func_1p free_operand, eax
	jmp .loop

	.end:
	mov dword [active_flag],0
	mov esp,ebp
	pop ebp
	ret
print_f:
	push ebp
	mov ebp,esp
	call_func_0p pop_operand ; get the pop operand in eax
	mov eax, dword [return]
	cmp eax, -1
	je .end
	call_func_1p print_operand, eax 
	call_func_1p free_operand, eax
	.end:
	mov esp,ebp
	pop ebp
	ret
duplicate_f:
	push ebp
	mov ebp,esp
	call_func_0p pop_operand ;pointer to operand in eax
	mov eax, dword [return]
	cmp eax, -1
	je .end
	push eax
	call_func_1p push_operand,eax
	pop eax
	call_func_1p duplicate_list,eax
	mov eax, dword [return]
    call_func_1p push_operand, eax
	.end:
	mov esp,ebp
	pop ebp
	ret

duplicate_list:
	;param1 - pointer of the source list
	;recurrsive function
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8]	;pointer for the head of the list
	cmp ecx, 0				; curr==NULL?
	je .end_ret
	jmp .con
	.end_ret:
	mov eax, 0				;return value 0
	jmp .end
	.con:
	push ecx
	mov ecx, [ecx+NEXT]
	call_func_1p duplicate_list,ecx
	pop ecx
	.copy:
	mov eax, dword [return]
	mov  bl, byte [ecx+DATA]
	mov ecx, dword [ecx+NEXT]   ; pointer to next link
	call_func_2p new_link,ebx,eax
	mov eax, dword [return]

	.end:
	mov esp,ebp
	pop ebp
	ret
numhex_f:
	push ebp
	mov ebp,esp
        mov ecx, 0 
	call_func_0p pop_operand
	mov eax, dword [return]
	cmp eax, -1
	je .end
	mov edx, eax ; pointer to pop operand
	and ecx,0
	.loop:
	mov ebx, eax
	mov eax, [eax+NEXT]    ; pointer to next link
	cmp eax, 0
	je .check_one_two    ;check if the last link is 2 number or 1
	add ecx, 2
	jmp .loop
	.check_one_two:
	cmp byte [ebx+DATA], 0x0F
	ja .two
	add ecx, 1
	jmp .create
	.two:
	add ecx,2 
	.create:                     ; create new dup link to push
	call_func_1p free_operand ,edx
	call_func_2p new_link, ecx, 0
	mov eax, dword [return]
	call_func_1p push_operand, eax
	.end:
	mov esp,ebp
	pop ebp
	ret

or_rec:
	push ebp
	mov ebp,esp
	mov ebx, dword [ebp+8]	;pointer of the first link
	mov ecx, dword [ebp+12]	;pointer of the second link
	;mov eax, dword [ebp+16]	;the pointer to the prev new link link

	.condition:
	mov edx, ebx
	or edx, ecx ; ebx and ecx are null so wee at the end of both numbers
	cmp edx, 0
	mov eax, 0
	je .end


	push ebx
	push ecx

	cmp ebx,0
	jne .ebx_ok_next
	jmp .con_ecx_next
	.ebx_ok_next:
	mov ebx, dword [ebx+NEXT]

	.con_ecx_next:
	cmp ecx,0
	jne .ecx_ok_next
	jmp .continue
	.ecx_ok_next:
	mov ecx, dword [ecx+NEXT]

	.continue:
	call_func_2p or_rec, ebx,ecx
	mov eax, dword [return]

	pop ecx
	pop ebx

	and edx, 0

	cmp ebx,0
	jne .ebx_ok_data
	mov dl,0
	jmp .con_ecx_data
	.ebx_ok_data:
	mov dl, byte [ebx+DATA]

	.con_ecx_data:
	cmp ecx,0
	jne .ecx_ok_data
	mov dh,0
	jmp .do_func
	.ecx_ok_data:
	mov dh, byte [ecx+DATA]

	.do_func:
	or dl, dh
	and edx ,0x000000FF
	call_func_2p new_link, edx, eax
	mov eax, dword [return]

	.end:
	mov esp,ebp
	pop ebp
	ret	

and_rec:
	push ebp
	mov ebp,esp
	mov ebx, dword [ebp+8]	;pointer of the first link
	mov ecx, dword [ebp+12]	;pointer of the second link
	;mov eax, dword [ebp+16]	;the pointer to the prev new link link

	.condition:
	mov edx, ebx
	or edx, ecx ; ebx and ecx are null so wee at the end of both numbers
	cmp edx, 0
	mov eax, 0
	je .end


	push ebx
	push ecx

	cmp ebx,0
	jne .ebx_ok_next
	jmp .con_ecx_next
	.ebx_ok_next:
	mov ebx, dword [ebx+NEXT]

	.con_ecx_next:
	cmp ecx,0
	jne .ecx_ok_next
	jmp .continue
	.ecx_ok_next:
	mov ecx, dword [ecx+NEXT]

	.continue:
	call_func_2p and_rec, ebx,ecx
	mov eax, dword [return]

	pop ecx
	pop ebx

	and edx, 0

	cmp ebx,0
	jne .ebx_ok_data
	mov dl,0x00
	jmp .con_ecx_data
	.ebx_ok_data:
	mov dl, byte [ebx+DATA]

	.con_ecx_data:
	cmp ecx,0
	jne .ecx_ok_data
	mov dh,0x00
	jmp .do_func
	.ecx_ok_data:
	mov dh, byte [ecx+DATA]

	.do_func:
	and dl, dh
	and edx ,0x000000FF
	call_func_2p new_link, edx, eax
	mov eax, dword [return]

	.end:
	mov esp,ebp
	pop ebp
	ret

plus_rec:
	push ebp
	mov ebp,esp
	mov ebx, dword [ebp+8]	;pointer of the first link
	mov ecx, dword [ebp+12]	;pointer of the second link
	mov eax, dword [ebp+16]	;eflags reg


	.condition:
	mov edx, ebx
	or edx, ecx ; ebx and ecx are null so wee at the end of both numbers
	cmp edx, 0
	je .end_ret

	;add
	cmp ebx,0
	jne .ebx_ok_data
	mov dl,0x00
	jmp .con_ecx_data
	.ebx_ok_data:
	mov dl, byte [ebx+DATA]
	.con_ecx_data:
	cmp ecx,0
	jne .ecx_ok_data
	mov dh,0x00
	jmp .do_func
	.ecx_ok_data:
	mov dh, byte [ecx+DATA]

	.do_func:
	push eax
	popfd
	adc dl, dh
	pushfd
	pop eax
	and edx ,0x000000FF

	;call to function
	;push ebx
	;push ecx

	cmp ebx,0
	jne .ebx_ok_next
	jmp .con_ecx_next
	.ebx_ok_next:
	mov ebx, dword [ebx+NEXT]
	.con_ecx_next:
	cmp ecx,0
	jne .ecx_ok_next
	jmp .continue
	.ecx_ok_next:
	mov ecx, dword [ecx+NEXT]
	.continue:
	call_func_3p plus_rec, ebx,ecx,eax
	mov eax, dword [return]

	;pop ecx
	;pop ebx
	
	;make new link
	call_func_2p new_link, edx, eax
	mov eax, dword [return]
	jmp .end

	.end_ret:
	push eax
	popfd
	jc .carry_link
	mov eax,0
	jmp .end
	.carry_link:
	call_func_2p new_link, 1,0
	mov eax, [return]
 	.end:
	mov esp,ebp
	pop ebp
	ret

check_zeros:
	;param1: pointer to the link to be print
	push ebp
	mov ebp,esp
	mov ecx, dword [ebp+8]	;pointer for the link

	.condition:
	cmp ecx, 0
	je .end_ret

	mov ebx, dword [ecx+NEXT]
	call_func_1p check_zeros,ebx
	mov ebx, [return]
	mov dword [ecx+NEXT], ebx
	
	.check:
	if_debug {call_func_1p print_link, ecx}
	mov eax,ecx
	mov ebx, dword [ecx+NEXT]
	cmp ebx,0
	jne .end
	and ebx,0
	mov bl, byte [ecx+DATA]
	cmp bl, 0
	jne .end
	call_func_1p free, ecx
	mov eax,0
	jmp .end

	.end_ret:
	mov eax,0

	.end:
	mov esp,ebp
	pop ebp
	;ret 4
	ret

check_if_two_operands:
	push ebp
	mov ebp,esp
	
	cmp dword [count_num],2
	jb .end_ret
	mov eax, 0
	jmp .end
	.end_ret:
	print msg_Insuff
	mov eax, -1
	.end:
	mov esp,ebp
	pop ebp
	ret


