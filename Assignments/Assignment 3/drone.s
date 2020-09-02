;initliaze
;update fields
;maydEstory
;destory target
;run (play) the actual function of the co-routine
;check if the drone is dead
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

	before_new_speed_msg: db "   Speed before cutoff %f", 10, 0
	after_new_speed_msg: db "   Speed after cutoff %f", 10, 0
	before_new_angle_msg: db "   Angle before wraparound %f", 10, 0
	after_new_angle_msg: db "   Angle after wraparound %f", 10, 0
	new_coordinate_msg: db "New coordinate %f", 10, 0

section .text
	extern return
    extern printf
    extern fprintf 
	extern stderr
	extern stdin 
	extern drone_details_Array
    global Play
    extern co_routineArray
    extern getPointerToCo_routineStruct
	extern co_routine_to_resume
    extern CURR
	extern SPT
	extern SPTMAIN
    extern loader
    extern N
    extern d
    extern resume

    ;functions
	extern getRandomPosition
	extern getRandomAngle
	extern getRandomSpeed
    extern convertDegreeToRadians

    ;self
    extern active_Drone
    global initDrone
    extern target_X
    extern target_Y
macros_drone:
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
initDrone:
    ;initialize drone values
    ;INV: active_drone hold pointer to the right struct
    open_frame
    mov edx, [ebp+8]                ;drone id
    inc edx
    mov ecx, dword [active_Drone]
    mov dword [ecx+ALIVE],1
    mov eax, 0
    itf eax
    mov dword [ecx+X],eax          ;float
    mov dword [ecx+Y],eax          ;float
    mov dword [ecx+SPEED],eax      ;float 
    mov dword [ecx+ANGLE],eax      ;float
    mov dword [ecx+TARGET_DOWN],0  ;integer
    mov dword [ecx+ID],edx

    call_func_0p updateAngle
    call_func_0p updateSpeed
    close_frame
updateSpeed:
    ;update the speed of the drone
    push ebp             
	mov ebp, esp
    call_func_0p getRandomSpeed
    finit
    ffree
    ;mov eax, dword [return]             ;eax=delta
    ;mov ebx, dword [active_Drone+SPEED] ;ebx=SPEED
    movdwm [loader], [return]
    fld dword [loader] 
    mov ebx, dword [active_Drone]
    movdwm [loader], [ebx+SPEED]
    fld dword [loader] 
    faddp
    fst dword [loader]				;store the result in EAX
    mov eax, dword [loader]
    ;print_float_point loader,before_new_speed_msg
    .compare:
    cmpfloat eax,100
    ;cmp eax, 100
    ja .maxspeed
    cmpfloat eax,0
    ;cmp eax,0
    jb .minspeed
    jmp .end
    .maxspeed:
    mov eax,100
    itf eax
    jmp .end
    .minspeed:
    mov eax,0
    itf eax
    .end:
    mov ebx, dword [active_Drone]
    mov dword [ebx+SPEED], eax
    ;print_float_point ebx+SPEED,after_new_speed_msg
    ffree
    mov esp,ebp
	pop ebp
    ;push 0x56556b2a
	ret
updateAngle:
    ;update the angle of the drone
    ;radian = 60 degrees
    open_frame
    call_func_0p getRandomAngle
    finit
    ffree
    ;angle=angle+delta
    ;if angle>360:
        ;angle=angle-360
    ;else if angle<0
        ;angle=angle+360
    movdwm [loader], [return]
    fld dword [loader]
    mov ebx, dword [active_Drone]
    movdwm [loader], [ebx+ANGLE]
    fld dword [loader] 
    faddp
    fst dword [loader]				;store the result in EAX
    mov eax, dword [loader]
    	
   ;print_float_point loader,before_new_angle_msg
    cmpfloat eax,360
    ;cmp eax, 360
    ja .over360
    cmpfloat eax,0
    ;cmp eax, 0
    jb .under0
    jmp .end
    .over360:
    ffree
    mov dword [loader], eax
    fld dword [loader]
    mov ebx, 360
    mov dword [loader], ebx
    fild dword [loader]
    fsubp
    fst dword [loader]
    mov eax, dword [loader]
    jmp .end

    .under0:
    ffree
    mov dword [loader], eax
    fld dword [loader]
    mov ebx, 360
    mov dword [loader], ebx
    fild dword [loader]
    faddp
    fst dword [loader]
    mov eax, dword [loader]
    .end:
    mov ebx, dword [active_Drone]
    mov dword [ebx+ANGLE], eax
    ;print_float_point ebx+ANGLE,after_new_angle_msg
    ffree
    close_frame

mayDestroy:
    ;checks if the distance between the drone coordinates to the traget coordinated is less then d global argument
    ;sqrt( (X-targetX)^2  + (Y-targetY)^2 )
    open_frame
    finit
    mov ebx, dword [active_Drone]
    fld dword [ebx+X]
    fld dword [target_X]
    fsubp
    fst st1
    fmulp

    fst dword [loader]
	mov eax, dword [loader] 

    fld dword [ebx+Y]
    fld dword [target_Y]
    fsubp
    fst st1
    fmulp

    mov dword [loader], eax
    fld dword [loader]

    faddp
    fsqrt
    fst dword [loader]
    mov eax, dword [loader]

    ;NOT GOOD 2 foat to compare
    ;cmp eax, dword [d]

    ffree
    fld dword [d]	
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

DestroyTarget:
    open_frame
    mov eax, dword [active_Drone]
    inc dword [eax+TARGET_DOWN]
    ;call_func_0p createTarget
    close_frame

Move_Axis:
    ;preform movment in the param-axis with wraparound the torus
    ;param1: offset for the axis (X|Y)
    open_frame
    mov edx, [ebp+8]
    ;get the degrees in radians
    mov ebx, dword [active_Drone]
    mov eax,  dword [ebx+ANGLE]
    call_func_1p convertDegreeToRadians,eax
    mov eax, dword [return]
    finit
    mov dword [loader], eax
    fld dword [loader]
    cmp edx,X
    jne .sin
    fcos
    jmp .con
    .sin:
    fsin
    .con:                                    ;cos(degree)
    fld dword [ebx+SPEED]          
    fmulp                                   ;cos(degree)*speed

    fld dword [ebx+edx]
    faddp
    fstp dword [loader]
    mov eax, dword [loader]
                                            ;if new_position>100
                                            ;   new_position=new_position-100
                                            ;else if new position<0
                                            ;   new_position=100+new_position
    cmpfloat eax,100
    ja .over100_onboard
    cmpfloat eax,0
    jb .under0_onboard
    jmp .end
    .over100_onboard:
    ffree
    mov dword [loader],eax
    fld dword [loader]
    mov dword [loader],100
    fild dword [loader]
    fsubp                    ;suppose do to eax-100
    fstp dword [loader]
    mov eax, dword [loader]
    jmp .end
    .under0_onboard:
    ffree
    mov dword [loader],eax
    fld dword [loader]
    mov dword [loader],100
    fild dword [loader]
    faddp                    ;suppose do to eax-100
    fstp dword [loader]
    mov eax, dword [loader]
    jmp .end
    .end:
    mov dword [ebx+edx], eax
    ;print_float_point ebx+edx,new_coordinate_msg
    ffree
    close_frame
Play:
    ;main function for the co-routine to enter
    ;open_frame
    .while_alive_loop:
        call_func_0p mayDestroy
        mov eax, dword [return]
        cmp eax,1
        jne .continue
        .destory:
        call_func_0p DestroyTarget

        mov ebx, dword [N]                          
        call_func_1p getPointerToCo_routineStruct,ebx   ;get pointer to the target co-routine
        mov ebx, dword [return]
        movdwm [co_routine_to_resume], [CURR]
        call resume                 ; call resume of target
        .continue:
        call_func_0p updateAngle
        call_func_0p updateSpeed
        ;mov eax, X
        call_func_1p Move_Axis,X
        ;mov eax, Y
        call_func_1p Move_Axis,Y

        mov ebx, dword [N]
        add ebx,2
        call_func_1p getPointerToCo_routineStruct,ebx       ;get pointer to the scheduler co-routine
        mov ebx, dword [return]
        call resume             ;call resume of scheduler
        jmp .while_alive_loop
    
    ;close_frame
