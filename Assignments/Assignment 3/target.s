section .data           ; we define (global) initialized variables in .data section
	target_X: dd 0
	target_Y: dd 0

section .rodata
	format_x: db "target X: %f", 10, 0
	format_y: db "target Y: %f", 10, 0


section .text
    global Target_routine
	global createTarget
    extern printf
    extern fprintf 
	extern stderr
	extern stdin 
	extern getRandomPosition
	extern return
	extern resume
	extern active_Drone
	extern co_routine_to_resume
	extern CURR
	extern SPT
	extern SPTMAIN
	global target_X
	global target_Y
macros:
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

	%macro print_float_point 2
		pushad
		fld dword[%1]
		fstp qword[esp]
		push %2
		call printf
		add esp,4
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
Target_routine:
	;call_func_0p createTarget
	call_func_0p getRandomPosition
	movdwm [target_X],[return]
	;print_float_point target_X,format_x
	call_func_0p getRandomPosition
	movdwm [target_Y],[return]
	mov ebx, dword [co_routine_to_resume]
	call resume
	jmp Target_routine
createTarget:	
	;initalize random coordination for the target
	open_frame
	call_func_0p getRandomPosition
	movdwm [target_X],[return]
	;print_float_point target_X,format_x
	call_func_0p getRandomPosition
	movdwm [target_Y],[return]
	;print_float_point target_Y,format_y
	close_frame
	;do resume