section .rodata
	format_float: db "%f", 10, 0
	format_dec: db "%d", 10, 0
	less_msg: db "less", 10, 0
	above_msg: db "above", 10, 0
	format_target: db "%.2f , %.2f", 10, 0
	format_drone: db "%d , %.2f , %.2f , %.2f , %.2f , %d", 10, 0

section .data
	small: dd 5.4
	big: dd 533
    loader: dd 0
    ID: dd 1
    X: dd 13.43
    Y: dd 94.54
    ANGLE: dd 108.42
    SPEED: dd 54.54
    TARGET_DOWN: dd 10
	target_X: dd 19.01
	target_Y: dd 31.5
	d: dd 30
section .bss
    return: resb 4
section .text
    global main
    extern printf
    extern fprintf 
    extern stderr

	%macro printmem 2
		;support printing data from memory
		pushad
		mov eax, dword [%1]
		push eax
		push %2
		call printf
		add esp, 8
		popad
	%endmacro

	%macro movdwm 2
	;trasfer data from mem-to-mem
		push edx
		mov edx, dword %2
		mov dword %1, edx
		pop edx
	%endmacro

    %macro open_frame 0
        push ebp             
	    mov ebp, esp
    %endmacro

    %macro close_frame 0
    	mov esp,ebp
	    pop ebp
	    ret
    %endmacro

	%macro if_debug 1 
		cmp dword [debug],1
		jne %%end_if
		%1
		%%end_if:
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

	%macro print_float_point 2
		pushad
		fld dword[%1]
		fstp qword[esp]
		push %2
		call printf
		add esp,4
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


    %macro itf 1
        ; expect to get general purpose register as input
        ; convert integer stored in register to float and return to the same register
        finit
        mov dword [loader],%1
        fild dword [loader]
        fstp dword [loader]
        mov %1, dword [loader]
        ffree
    %endmacro


main:
    open_frame
    ; finit
    ; fld dword [small]
    ; ;fsin
    ; fild dword [big]				;store the result in EAX
    ; ;print_float_point loader, format_float
    ; fcomi       ;(compare big to small if )
    ; ja .above
    ; .less:
    ; print_debug less_msg
    ; jmp end
    ; .above:
    ; print_debug above_msg
    ; end:
    ; mov eax, dword [small] ;eax holds 5.4
    ; cmpfloat eax, 3
    ; ja .above
    ; .less:
    ; print_debug less_msg
    ; jmp end
    ; .above:
    ; print_debug above_msg
    ; end:
    ; mov eax,100
    ; itf eax
    ; mov dword [loader],eax
    ; fld dword [loader]  ;expect to get 100 in FPU
    ; mov eax, 29
    ; mov ebx, 7
    call_func_0p distroy_target
    mov eax,dword [return]
    print_debug eax, format_dec
    ;print_float_point2 X,Y
    ;print_float_point6 ID,X,Y,ANGLE,SPEED,TARGET_DOWN
    close_frame

mod:
	;preform i module k
	;param1 :i
	;param2: K o N
	open_frame
    mov edx,0
	mov eax, dword [ebp+8]
	mov ebx, dword [ebp+12]
	div ebx
	mov eax, edx
	close_frame

distroy_target:
	;checks if the distance between the drone coordinates to the traget coordinated is less then d global argument
    ;sqrt( (X-targetX)^2  + (Y-targetY)^2 )
	open_frame
    finit
    ; mov ebx, dword [active_Drone]
    fld dword [X]
    fld dword [target_X]
    fsubp
    fst st1
    fmulp

	fst dword [loader]
	mov eax, dword [loader] 

    fld dword [Y]
    fld dword [target_Y]
    fsubp
    fst st1
    fmulp

	mov dword [loader], eax
    fld dword [loader]

    faddp
    fsqrt
    fstp dword [loader]
    mov eax, dword [loader]

    ;NOT GOOD 2 foat to compare
    ;cmp eax, dword [d]

    ffree
	mov ebx, dword [d]
	itf ebx
	mov dword [loader],ebx
    fld dword [loader]	
    mov dword [loader], eax
    fld dword [loader]	
    fcomi   
    jb .return_true
    .return_false:
    mov eax,0
    jmp .end
    .return_true:
    ;mov eax,0
    mov eax,1
    .end:
    ffree
    close_frame