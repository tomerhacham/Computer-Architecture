section .text
global _start
global system_call
global infector
global infection
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop

system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

infector:
  push    ebp             ; Save caller state
  mov     ebp, esp
  ;sub     esp, 4          ; Leave space for local var on stack
  pushad                  ; Save some more caller state

  .open_file:
  mov eax, 0x05           ;SYS_OPEN
  mov ebx, [ebp+8]        ;transfer the filename string pointer that came as argument
  mov ecx, 0x401          ; bitmask for APPEND  and WRITE mode
  mov edx, 0777            ;rwx,rwx,rwx permision
  int 0x80
  ;mov     [ebp-4], eax    ; Save returned value...
  ;popad                   ; Restore caller state (registers)
  ;mov     eax, [ebp-4]    ; place returned value where caller can see it
  .write_file:
  push eax
  mov ebx,eax                  ;get file descriptor from what returns from the prev system call
  mov eax, 0x04                ;SYS_WRITE
  mov ecx, code_start
  mov edx, code_end-code_start         ;rwx,rwx,rwx permision
  int 0x80

  .close_file:
  mov eax, 0x06         ;SYS_CLOSE
  pop ebx
  int 0x80

end_infector:
  popad                   ; Restore caller state (registers)
  ;mov     eax, [ebp-4]    ; place returned value where caller can see it
  ;add     esp, 4          ; Restore caller state
  mov esp,ebp
  pop     ebp             ; Restore caller state
  ret                     ; Back to caller

code_start:
  msg: db "Hello, Infected File",10, 0
  len: equ $-msg
infection:
  mov eax,4 ; system call for write
  mov ebx,1 ;file descriptor to stdout
  mov ecx, msg ;pointe to the string
  mov edx, len ; the length of the string
  int 0x80 ; signal the kernel there is system caller
code_end:
  end: db 'q'
