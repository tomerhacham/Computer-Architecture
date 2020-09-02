section	.rodata							; we define (global) read-only variables in .rodata section
	;Defines for the Co-routine struct
	STKSIZE equ 16*1024
	CO_routine_struct_size equ 3*32
	CO_ID equ 0							;offest for the ID field
	CO_Stack_Add equ 32					;offest for the Stack address field
	co_original_allocated_memory equ 64

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
	Alloc_msg: db "Alloc Co_routine ID: %d", 10, 0
	stack_address: db "Stack address: %p", 10, 0
	co_routine_struct_address: db "co_routine structs address: %p", 10, 0
	drone_details_struct_address: db "drone details structs address: %p", 10, 0
	format_float: db "%f", 10, 0
	scale_msg: db "scaled number %f", 10, 0
	

section .data           ; we define (global) initialized variables in .data section
	co_num: dd 0
    debug: dd 0  
	co_routineArray: dd 0		;will hold the pointer for the co-routine array (size of N*routine_struct) co-routine[]
	drone_details_Array: dd 0	;drone_details[]
	active_Drone: dd 0			;will hold thdrone_details_Arraye start of the struct of the drone_detail

section .bss			; we define (global) uninitialized variables in .bss section
	align 16
	return: resb 4		;functions as return register
	N: resb 4			;global var for program argument
	R: resb 4			;global var for program argument
	K: resb 4			;global var for program argument
	d: resb 4			;global var for program argument
	seed: resb 4		;global var for program argument
	
	co_routine_to_resume: resb 4 	;pointer to co-init structure of of the active co-routine	
	CURR: resb 4					;pointer to co-init structure of the current co-routine
	SPT: resb 4 					; temporary stack pointer
	EBPsave: resb 4 					; temporary stack pointer
	SPMAIN: resb 4 					; stack pointer of main

	loader: resb 4
	LSFR_register: resb 2

	isFirst: resb 4

section .text
    global main
    global main.return
	global return
	global resume
	global do_resume
    extern printf
    extern fprintf 
    extern sscanf
    extern malloc 
    extern calloc 
    extern free 
	extern stderr
	extern stdin 
	global loader
	global resume
	global end_co
	global do_resume
	global getPointerToCo_routineStruct
	global getPointerToDroneDetailsStruct
	global mod
	global isDroneActive
	global findM
	global TurnoffDroneWithM
	global num_of_active_drones
	global get_winner_drone
	

	;arguments
	global N
	global R
	global K
	global d

	;co-routine
	global co_routine_to_resume
	global co_routineArray
	global CO_routine_struct_size
	global CO_ID
	global CO_Stack_Add
	extern Target_routine
	extern Play
	extern printBoard
	extern schedule
	global CURR
	global SPT
	global SPMAIN
	extern createTarget

	;drone details
	extern initDrone
	global drone_details_Array
	global active_Drone

	;functions
	global getRandomPosition
	global getRandomAngle
	global getRandomSpeed
	global Scale
	global random
	global convertDegreeToRadians
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

	%define MAXINT 0x0000FFFF

main:
	open_frame
	pushad 
	pushfd
	mov eax,dword [ebp+12]          ;eax hold pointer to argv
	call_func_1p arguments,eax  
	call_func_0p intializeDrones
	call_func_0p initializeTarget
	call_func_0p initializePrinter
	call_func_0p intializeScheduler
	.after_initialize:
	;pushad
	mov	[SPMAIN], esp             ; Save SP of main code
	mov ebx, dword [N]
	add ebx, 2
	call_func_1p getPointerToCo_routineStruct,ebx
	mov ebx, dword [return]
	jmp	do_resume
	.return:
	call_func_0p free_co_routines
	call_func_0p free_drone_details
	;call_func_0p createTarget
	;call_func_0p printBoard
	popfd
	popad
	close_frame

arguments:
	;function to prase the arguments which are globa; viarable
	;param1: pointer to the ARGV array
	open_frame
	mov eax, dword [ebp+8]
	call_func_3p sscanf,dword [eax+4],format_dec,N
	call_func_3p sscanf,dword [eax+8],format_dec,R
	call_func_3p sscanf,dword [eax+12],format_dec,K
	call_func_3p sscanf,dword [eax+16],format_float,d	;change to float
	call_func_3p sscanf,dword [eax+20],format_dec,seed
	mov ebx, dword [N]
	add ebx,3
	mov dword [co_num],ebx
	; printmem N,format_dec
	; printmem R,format_dec
	; printmem K,format_dec
	; print_float_point d, format_float
	; printmem seed,format_dec
	.after_print:
	movdwm [LSFR_register],[seed]
	close_frame

intializeDrones:
	;initialize drones structs and stacks
	open_frame
	mov ecx, dword [N]
	add ecx, 3			; 1 for the printer, 1 for the schaduler and 1 for the target
	mov ebx, CO_routine_struct_size 
	call_func_2p calloc,ecx,ebx
	.afer_alloc_1:
	movdwm [co_routineArray] , [return]					;set the pointer Co-routineArray co-routine[]
	;printmem co_routineArray,co_routine_struct_address
	mov ecx, dword [N]
	mov ebx, Drone_detail_struct_size 
	call_func_2p calloc,ecx,ebx
	.afer_alloc_2:
	movdwm [drone_details_Array] , [return]				;set the pointer tDrone-details_array Drone_details[]
	;printmem drone_details_Array,drone_details_struct_address

	and ecx,0
	.loop:
		cmp ecx, dword [N]
		je .end

		call_func_1p getPointerToCo_routineStruct,ecx
		mov ebx, dword [return]

		.init_co_routine_struct:
		mov dword [ebx+CO_ID],ecx					;set routine ID
		call_func_2p calloc, 1,STKSIZE

		.afer_alloc_3:
		;might add STKSIZE to ebx to get to the end of the memory segment
		mov edx,dword [return]
		movdwm [ebx+co_original_allocated_memory],[return]
		add edx, STKSIZE
		mov dword [return], edx

		movdwm [ebx+CO_Stack_Add],[return]			;set the pointer to the allocated stack of co-routine
		; printmem ebx+CO_Stack_Add, stack_address
		mov eax, Play 								
		call_func_2p coInit,ebx,eax
		;print_debug ecx, Alloc_msg
	
		.init_drone_details_struct:

		call_func_1p getPointerToDroneDetailsStruct,ecx
		mov ebx,dword [return]
		mov dword [active_Drone], ebx
		call_func_1p initDrone,ecx
		inc ecx													; restore ESP value
		jmp .loop
	.end:
	close_frame
initializeTarget:
	;initalize co-routine struct for the printer
	open_frame
	mov ebx, dword [N]
	call_func_1p getPointerToCo_routineStruct,ebx
	mov ebx, dword [return]

	mov dword [ebx+CO_ID],eax					;set routine ID
	call_func_2p calloc, 1,STKSIZE
	.alloc_stack:
	movdwm [ebx+co_original_allocated_memory],[return]
	mov edx,dword [return]
	add edx, STKSIZE
	mov dword [return], edx
	movdwm [ebx+CO_Stack_Add],[return]			;set the pointer to the allocated stack of co-routine
	; printmem ebx+CO_Stack_Add, stack_address

	mov eax, Target_routine 								;(?) in the pratical season mov eax, [ebx+CODEP] meaning where to return when the co is finished
	call_func_2p coInit,ebx,eax
	mov ebx, dword [N]
	;print_debug ebx, Alloc_msg
	call_func_0p createTarget
	close_frame

initializePrinter:
	;initalize co-routine struct for the printer
	open_frame
	mov ebx, dword [N]
	add ebx,1
	call_func_1p getPointerToCo_routineStruct,ebx
	mov ebx, dword [return]

	mov dword [ebx+CO_ID],eax					;set routine ID
	call_func_2p calloc, 1,STKSIZE
	.alloc_stack:
	movdwm [ebx+co_original_allocated_memory],[return]
	mov edx,dword [return]
	add edx, STKSIZE
	mov dword [return], edx

	movdwm [ebx+CO_Stack_Add],[return]			;set the pointer to the allocated stack of co-routine
	; printmem ebx+CO_Stack_Add, stack_address
	mov eax, printBoard 								;(?) in the pratical season mov eax, [ebx+CODEP] meaning where to return when the co is finished
	call_func_2p coInit,ebx,eax	
	mov ebx, dword [N]
	add ebx,1
	;print_debug ebx, Alloc_msg
	close_frame

intializeScheduler:
	;initalize co-routine struct for the scheduler
	open_frame
	mov ebx, dword [N]
	add ebx, 2
	call_func_1p getPointerToCo_routineStruct,ebx
	mov ebx, dword [return]

	mov dword [ebx+CO_ID],eax					;set routine ID
	call_func_2p calloc, 1,STKSIZE
	.alloc_stack:
	movdwm [ebx+co_original_allocated_memory],[return]
	mov edx,dword [return]
	add edx, STKSIZE
	mov dword [return], edx

	movdwm [ebx+CO_Stack_Add],[return]			;set the pointer to the allocated stack of co-routine
	; printmem ebx+CO_Stack_Add, stack_address
	mov eax, schedule 								;(?) in the pratical season mov eax, [ebx+CODEP] meaning where to return when the co is finished
	call_func_2p coInit,ebx,eax
	mov ebx, dword [N]
	add ebx,2
	;print_debug ebx, Alloc_msg
	close_frame




random:
	;randomize number using LSRF algorithem [11,13,14,16]
	open_frame
	.init:
	and eax,0		;[16]
	and ebx,0		;[14]
	and ecx,0		;[13]
	and edx,0		;[11]
	mov dx, word [LSFR_register]

	mov ax, dx
	shr ax,2
	mov cx,dx
	shr cx,3
	xor eax,ecx
	xor eax, edx
	mov ecx,edx
	shr cx,5
	xor eax,ecx

	shl eax, 15
	shr dx,1
	or eax, edx
	mov edx, eax
	
	mov word [LSFR_register], ax
	mov eax, 0
	mov ax,word [LSFR_register]  
	; mov bx,ax
	; mov cx,ax
	; mov dx,ax

	; shr bx,2
	; shr cx,3
	; shr dx,5

	; xor ax,bx
	; xor cx,dx
	; xor ax,cx	;result of xor in cx

	; and ax,0x01 ;get the leftmost of ax
	; cmp ax,0
	; je .set_0
	; mov eax,0
	; add ax, 32768
	; ;add ax, 1000000000000000b

	; .set_1:
	; and ebx,0
	; mov bx, word [LSFR_register]
	; rcr bx,1
	; add bx,ax		;final number
	; jmp .end

	; .set_0:
	; and ebx,0
	; mov bx, word [LSFR_register]
	; shr bx,1

	; .end:
	; and eax,0
	; ;shr bx,16 				;(?)
	; mov word [LSFR_register],bx
	; mov ax, word [LSFR_register]
	; ;print_debug eax,format_dec
	; ffree
	close_frame

Scale:
	;scale the random number the lower-upper bounds
	;param1: lower-bound
	;param2: upper bound
	;return: number in [lower,upper]
	open_frame
	mov ebx, dword [ebp+8]		;lower bound
	mov ecx, dword [ebp+12]		;upper bound
	call_func_0p random
	.after_random:
	mov eax, dword [return]		;x
	;movdwm [loader],[return]
	finit

	movdwm [loader],[return]
	fild dword [loader] 			;load X

	mov dword [loader], MAXINT
	fild dword [loader] 			;load MAXINT
	
	fdivp 							;x/MAXINT

	mov dword [loader], ebx
	fild dword [loader]				;load min

	mov dword [loader], ecx
	fild dword [loader]				;load max
	fsubp							;min-max
	fabs 							;|min-max|

	fmul							;(X/MAXINT) * |max-min|

	;fild ebx	
	mov dword [loader], ebx
	fild dword [loader]				;load min
	fabs							;|min|

	fsubp							;X-|min|
	fst dword [loader]				;store the result in EAX
	ffree
	mov eax, dword [loader]
	close_frame

getRandomSpeed:
	;return: number (float) in the range [-10,10]
	open_frame
	call_func_2p Scale,-10,10
	;print_float_point return,scale_msg
	mov eax, dword [return]
	close_frame

getRandomAngle:
	;return: number (float) in the range [-60,60]
	open_frame
	call_func_2p Scale,-60,60
	;print_float_point return,scale_msg
	mov eax, dword [return]
	close_frame

getRandomPosition:
	;return: number (float) in the range [0,100]
	open_frame
	call_func_2p Scale,0,100
	;print_float_point return,scale_msg
	mov eax, dword [return]
	close_frame

convertDegreeToRadians:
	;convert degrees to radians
	;param1: number of degrees (float)
	;return: number of radians (float)
	open_frame
	mov eax, dword [ebp+8]	
	finit
	fldpi
	mov dword [loader], 180
	fild dword [loader]
	fdivp				;pi/180

	mov dword [loader], eax
	fld dword [loader]
	fmulp
	fst dword [loader]
	ffree
	mov eax ,dword [loader]
	close_frame

resume:
	; EBX is pointer to co-init structure of co-routine to be resumed
	; CURR holds a pointer to co-init structure of the curent co-routine
	pushf				; Save state of caller
	pusha
	mov	edx, [CURR]
	mov	[edx+CO_Stack_Add],esp	; Save current SP
do_resume:
	mov	esp, [ebx+CO_Stack_Add]  ; Load SP for resumed co-routine
	mov	[CURR], ebx
	popa				; Restore resumed co-routine state
	popf
	ret                     ; "return" to resumed co-routine!
end_co:
	; pushad
	; mov	[SPMAIN], esp             ; Save SP of main code
	; End co-routine mechanism, back to C main
	mov	esp, [SPMAIN]            ; Restore state of main code
	;popad
	;pop	ebp
	ret
getPointerToCo_routineStruct:
	;param1: number of the co_routine in the array
	;return pointer to the co_coutine[param1]
	open_frame
	mov eax, [ebp+8]
	mov ebx, CO_routine_struct_size
	mul ebx
	add eax, dword [co_routineArray]
	close_frame

getPointerToDroneDetailsStruct:
	;param1: number of the co_routine in the array
	;return pointer to the co_coutine[param1]
	open_frame
	mov eax, [ebp+8]
	mov ebx, Drone_detail_struct_size
	mul ebx
	add eax, dword [drone_details_Array]
	close_frame

coInit:
	;initalize the stack of the co-routine
	;param1: pointer to the co_routine struct
	;param2: address of the Function of the co-routine
	push ebp             
	mov ebp, esp

	mov ebx, [ebp+8]							;hold pointer of the struct of the co-routine
	mov eax, [ebp+12]							;hold the address of the function

	mov dword [SPT], esp								; save ESP value
	mov dword [EBPsave], ebp								; save ESP value
	mov esp ,dword [ebx+CO_Stack_Add] 			; get initial ESP value – pointer to COi stack
	mov ebp,esp
	push eax 									; push initial “return” address
	pushfd 										; push flags
	pushad 										; push all other registers
	mov dword [ebx+CO_Stack_Add] , esp 			; save new SPi value (after all the pushes)
	mov ebp, dword [EBPsave]
	mov esp, dword [SPT] 				;somewhere here

	mov esp,ebp
	pop ebp
	ret

isDroneActive:
	;checks if the drone at param1 is active
	;param1 id of the drone
	;return 1 if is and 0 if not
	open_frame
	mov eax, [ebp+8]		;id of the drone
	call_func_1p getPointerToDroneDetailsStruct,eax
	mov eax, dword [return]
	cmp dword [eax+ALIVE], 1
	je .return_true
	.return_false:
	mov eax,0
	jmp .end
	.return_true:
	mov eax,1
	.end:
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

findM:
	;the lowest number of targets destroyed, between all of the active drones
	;no params
	;return the id for the lowest drone  (integer)
	open_frame
	.init:
	mov dword [isFirst],1
	mov ecx,0
	mov edx,0 
	.loop:
	cmp ecx, dword [N]
	je .end
	call_func_1p isDroneActive,ecx
	mov eax, dword [return]
	cmp eax,1
	jne .skip
	call_func_1p getPointerToDroneDetailsStruct,ecx
	mov ebx, dword [return]
	cmp dword [isFirst],1
	je .set_isFirst_to_0
	cmp edx, dword [ebx+TARGET_DOWN]
	jb .skip
	jmp .update_M
	.set_isFirst_to_0:
	mov dword [isFirst],0
	.update_M:
	mov edx, dword [ebx+TARGET_DOWN]
	.skip:
	inc ecx
	jmp .loop
	.end:
	mov eax, edx
	close_frame

TurnoffDroneWithM:
	;deactive drone with M target
	;param1: M - the lowest number of Target down
	open_frame
	mov eax, dword[ebp+8]
	.init:
	mov ecx,0
	.loop:
	cmp ecx, dword [N]
	je .end
	call_func_1p isDroneActive, ecx
	mov ebx, dword [return]
	cmp ebx,1 
	jne .skip
	call_func_1p getPointerToDroneDetailsStruct, ecx
	mov ebx, dword [return]
	cmp dword [ebx+TARGET_DOWN], eax
	je .turn_off
	.skip:
	inc ecx 
	jmp .loop
	.turn_off:
	mov dword [ebx+ALIVE], 0
	.end:
	close_frame

num_of_active_drones:
	;return the number of active drones
	;no parms
	open_frame
	.init:
	mov ecx, 0
	mov eax,0
	.loop:
	cmp ecx, dword [N]
	je .end
	call_func_1p isDroneActive, ecx
	cmp dword [return], 1
	jne .skip
	inc eax
	.skip:
	inc ecx 
	jmp .loop
	.end:
	close_frame

get_winner_drone:
	;get the id of the winner drone
	open_frame
	.init:
	mov ecx, 0
	.loop:
	cmp ecx, dword [N]
	je .end
	call_func_1p isDroneActive, ecx
	cmp dword [return], 1
	jne .skip
	.winner:
	inc ecx
	mov eax,ecx
	jmp .end 
	.skip:
	inc ecx 
	jmp .loop
	.end:
	close_frame

free_co_routines:
	;free all the allocated memory for the co_routines
	open_frame
	.init:
	mov ecx,0
	.loop:
	cmp ecx, dword [co_num]
	je .end
	call_func_1p getPointerToCo_routineStruct,ecx
	mov eax,dword [return]
	mov edx, dword [eax+co_original_allocated_memory]
	;sub edx, STKSIZE
	.free_stack:
	call_func_1p free, edx
	inc ecx
	jmp .loop
	.end:
	mov eax, dword [co_routineArray]
	call_func_1p free, eax
	close_frame

free_drone_details:
	;free the allocated memory for the drones details struct
	open_frame
	mov eax, dword [drone_details_Array]
	call_func_1p free,eax
	close_frame
