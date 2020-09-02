; print all the baord status
section .data           ; we define (global) initialized variables in .data section
	id: dd 0

section .rodata
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

	format_target: db "%.2f , %.2f", 10, 0
	format_drone: db "%d , %.2f , %.2f , %.2f , %.2f , %d", 10, 0
section .text
    global printBoard
	extern return
    extern printf
    extern fprintf 
	extern stderr
	extern stdin
    extern loader
    extern co_routineArray
	extern CURR
	extern SPT
	extern SPTMAIN
	extern co_routine_to_resume
	extern getPointerToDroneDetailsStruct
	extern drone_details_Array
    extern N
	extern getPointerToCo_routineStruct
	extern resume
    extern target_X
    extern target_Y
macros:
    %macro print_float_point2 2
        pushad
        sub esp,8
        fld dword [%2]
        fstp qword[esp]

        sub esp,8
        fld dword [%1]
        fstp qword[esp]

        push format_target
        call printf
        add esp,20
        popad
    %endmacro

    %macro print_float_point6 6
        pushad
        push dword [%6]     ;ID

        sub esp,8         	;X
        fld dword [%5]
        fstp qword[esp]

        sub esp,8           ;Y
        fld dword [%4]
        fstp qword[esp]

        sub esp,8           ;ANGLE
        fld dword [%3]
        fstp qword[esp]

        sub esp,8           ;SPEED
        fld dword [%2]
        fstp qword[esp]

        push dword [%1]     ;TARGET_DOWN

        push format_drone
        call printf
        add esp,44
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

    %macro open_frame 0
        push ebp             
	    mov ebp, esp
    %endmacro

    %macro close_frame 0
    	mov esp,ebp
	    pop ebp
	    ret
    %endmacro
printBoard:
    print_float_point2 target_X,target_Y
    .init:
    mov ecx,0
    ;calculate pointer to the drone_detail struct in the array
    .loop_print:
    cmp ecx, dword [N]
    je .end
    ;mov dword [id],ecx
    ;inc dword [id]

	call_func_1p getPointerToDroneDetailsStruct,ecx
	mov ebx, dword [return]
    print_float_point6 ebx+ID,ebx+X,ebx+Y,ebx+ANGLE,ebx+SPEED,ebx+TARGET_DOWN
    inc ecx
    jmp .loop_print
    .end:
	mov ebx, dword [N]
	add ebx,2
	call_func_1p getPointerToCo_routineStruct,ebx       ;get pointer to the scheduler co-routine
	mov ebx, dword [return]
	call resume
	jmp printBoard  
