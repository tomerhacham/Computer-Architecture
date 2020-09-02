
section	.rodata							; we define (global) read-only variables in .rodata section
	;Defines for the Co-routine struct
	STKSIZE equ 16*1024
	CO_routine_struct_size equ 2*32
	CO_ID equ 0							;offest for the ID field
	CO_Stack_Add equ 32					;offest for the ID field

	;Defines for the Drone details struct
	Drone_detail_struct_size equ 7*32 			;drone struct size will be 161 bits
	ALIVE equ 0							;offset of the alive ()32 bit)              ;integer
	X equ 32							;offset of the X coordinate value (32 bit)  ;float
	Y equ 64							;offset of the Y coordinate value (32 bit)  ;float
	SPEED equ 96						;offset of the speed value (32 bit)         ;float
	ANGLE equ 128						;offset of the angle value (32 bit)         ;float
	TARGET_DOWN equ 160					;offset of the target value (32 bit)        ;integer
	ID equ 192							;offset of the target value (32 bit)        ;integer

	format_hex: db "%X", 10, 0      	; format to print the num in hex
	format_string: db "%s", 10, 0
	format_dec: db "%d", 10, 0
	format_winner: db "The Winner is drone: %d", 10, 0
	format_float: db "%f", 10, 0
	scale_msg: db "scaled number %f", 10, 0

section .data
	active: dd 1
	
section .text
	global schedule
	extern main.return
	extern active_Drone 
	extern printf
	extern K
	extern N
	extern return
	extern R
	extern CURR
	extern SPT
	extern SPMAIN
	extern co_routine_to_resume
	extern resume
	extern end_co
	extern do_resume
	extern getPointerToCo_routineStruct
	extern getPointerToDroneDetailsStruct
	extern mod
	extern isDroneActive
	extern findM
	extern TurnoffDroneWithM
	extern num_of_active_drones
	extern get_winner_drone

macros:
    %macro cmpfloat 2
        ;compare is argument 1 is bigger argument 2
        ;argument 1 is float
        ;argument 2 is integer
        finit
        mov dword [loader], %2
        fild dword [loader]	

        mov dword [loader], %1
        fld dword [loader]	
        fcomi       ;(compare big to small if )
        ffree
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

	%macro print_float_point 2
		pushad
		fld dword[%1]
		fstp qword[esp]
		push %2
		call printf
		add esp,4
		popad
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

	%macro print_winner 1
	;not supporting prints from memory
		pushad
		push %1
		push format_winner
		call printf
		add esp, 8
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
schedule:
	;main func of the scheduler
	.init:
	mov ecx, 0
	.loop:
	cmp dword [active], 0
	je .end
	call_func_2p mod, ecx, dword [N]
	mov eax, dword [return]
	call_func_1p isDroneActive, eax
	cmp dword [return], 0
	je .skip
	.drone_active:
	call_func_1p getPointerToDroneDetailsStruct, eax
	movdwm [active_Drone], [return]
	call_func_1p getPointerToCo_routineStruct, eax
	mov ebx, dword [return]
	call resume
	.skip:
	call_func_2p mod, ecx, dword [K]
	mov eax, dword [return]
	cmp eax, 0 
	jne .check_Rounds
	.printer:
	mov ebx, dword [N]
	add ebx,1
	call_func_1p getPointerToCo_routineStruct, ebx 
	mov ebx, dword [return]
	call resume
	.check_Rounds:
	mov edx,0
	mov eax, ecx 
	mov ebx, dword [N]
	div ebx 
	cmp eax, 0
	je .increment_i
	call_func_2p mod, eax, dword [R]
	mov ebx, dword [return]
	cmp ebx, 0
	jne .increment_i
	.Round_end:
	mov eax, ecx
	call_func_2p mod, eax, dword [N]
	mov ebx, dword [return]
	cmp ebx, 0
	jne .increment_i
	call_func_0p findM
	mov ebx, dword [return]
	call_func_1p TurnoffDroneWithM, ebx
	.increment_i:
	inc ecx
	call_func_0p num_of_active_drones
	mov ebx, dword [return]
	cmp ebx, 1
	je .finish_game
	jmp .loop
	.finish_game:
	mov dword [active], 0
	.end:
	call_func_0p get_winner_drone
	mov eax, dword [return]
	print_winner eax

	mov	esp, [SPMAIN]            ; Restore state of main code
	;popad
	;pop	ebp
	
	jmp main.return










