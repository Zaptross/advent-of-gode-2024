section     .text               ; Code section where program logic is written
global      _start              ; Mark _start as the entry point of the program

_start: 
    mov     rdi, example           ; Load the address of the message into the register
    call    _strlen
    ; mov     rdx, rax
    ; mov     rcx, example
    ; call     _print
    mov     r9, example
    call    _print_char_in_str

.exit:
    mov     eax, 1             ; Set the syscall number for 'exit' (1)
    int     0x80              ; Make the syscall to exit the program

_print:                         ; prints len (rdx) characters from str (rcx)
    mov     rbx, 1              ; Set the file descriptor to 1 (stdout)
    mov     rax, 4              ; Set the syscall number for 'write' (4)
    int     0x80                ; Make the syscall to print the message to the screen
    ret

_print_char_in_str:             ; prints each char in r9 with newlines
    push rcx        ; save and clear counter
    push r10
    xor rcx, rcx

_print_char_in_str_loop:
    cmp [r9], byte 0
    jz _print_char_in_str_end

    mov r10, rcx
    ; mov rdx, 2
    ; mov rcx, OFFSET r9+1
    ; mov rcx, byte ptr [rcx + 1]

    mov rcx, r9
    mov rdx, 1
    call _print

    cmp byte [r9], 'm'
    je _print_eq_m
_print_char_in_str_loop_eq_m_ret:

    ; mov rcx, nlc
    ; mov rdx, 1
    ; call _print
    mov rcx, r10
    inc rcx
    inc r9
    jmp _print_char_in_str_loop

_print_char_in_str_end:
    pop r10
    pop rcx        ; save and clear counter
    ret

_print_eq_m:
    push rcx
    push rdx

    mov rcx, eqm
    mov rdx, 6
    call _print

    pop rdx
    pop rcx
    jmp _print_char_in_str_loop_eq_m_ret

_strlen:
    push rcx        ; save and clear counter
    xor rcx, rcx

_strlen_next:
    cmp [rdi], byte 0   ; is this a null byte?
    jz  _strlen_null    ; if 0, end counting

    inc rcx             ; char is not null, increment counter to count it
    inc rdi             ; move to next character
    jmp _strlen_next

_strlen_null:
    mov rax, rcx        ; rcx = length, store in rax
    pop rcx             ; restore rcx
    ret                 ; jump back to where we were

section     .data               ; Data section where static data (like strings) is stored
msg     db  'abcde edcba', 0xa  ; Define the message to be printed with a newline at the end
nlc db 0xa
example incbin 'example.txt'
eqm db 0xa, "eq m", 0xa