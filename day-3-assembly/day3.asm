section     .text           ; Code section where program logic is written
global      _start          ; Mark _start as the entry point of the program

_start: 
    mov r8, 12345

_print_num_in_r8:           ; author: Peter Cordes
                            ; src: https://stackoverflow.com/a/46301894/17708744
    mov     rax, r8         ; fill eax with number
    mov     rcx, 10         ; fill ecx with number 10
    push    rcx             ; put a newline on the stack as the last character
                            ; of the string
    mov     rsi, rsp
.to_ascii_digit:
    xor     rdx, rdx        ; clear out any junk in rdx
    div     rcx             ; divides rax by rxc and puts remainder into rdx

    add     rdx, 0x30       ; map into number char range
    dec     rsi             ; decrement the pointer
    mov     [rsi], dl

    test    rax, rax        ; performs a bitwise `and` and discards the result
                            ; is utilised here to check rax has digits left
    jnz     .to_ascii_digit

    mov rax, 1
    mov rdi, 1
    lea rdx, [rsp + 1]
    sub rdx, rsi
    syscall

_exit:
    push    rax
    mov     eax, 11
    mul     eax
    mov     ebx, eax
    pop     rax
    mov     eax, 1          ; Set the syscall number for 'exit' (1)
    int     0x80            ; Make the syscall to exit the program

_find_valid_mul:            ; r8 used for input str
    push    r12             ; borrow r12 for tracking position into search str
    push    r13             ; borrow r13 for tracking if storing digits
    mov     r12, srch       ; fill mov with srch, as ptr index

.comparison:
    cmp     byte [r8], byte [r12]   ; compare current characters
    je      .match
.next_char:
    inc     r8              ; move to next char of input
    inc     r12             ; move to next char of srch
    jmp     .comparison     ; try again on the next char

.match:
    cmp     byte [r12], '('
    jne     .next_char      ; if we haven't found the opening paren, continue
    inc     r8              ; if we do match the opening brace, increment r8 and r12 and try pushing a
    inc     r12
    
    ; digit. if digit okay, increment r8 only and try again
    ; if digit not okay, jump to .cleanup_mul
    ; if we match a comma, store the push digit result and jump to .comparison

.cleanup_mul:
    pop     r13             ; return r13
    pop     r12             ; return r12


                            ; owns [r11] to store accumulating number
                            ; uses [r10] for input digit
                            ; uses [r10] to return result state
                            ; 0 = OK    found and pushed digit
                            ; 1 = OK    found control character
                            ; 2 = ERR   found error character, abort
_push_digit_into_number:        ; multiplies any existing digits by 10, then bitwise or's the new number in
    push r15                    ; borrow r15 for storing actual number
    xor r15, r15                ; and clear it

    ; map input digit to number by moving the new number to r15
    ; then comparing the current digit to that number's character
    ; and executing _push_digit_into_number_found_equal if they match
    mov r15, 0
    cmp byte [r10], '0'
    je .digit_found
    mov r15, 1
    cmp byte [r10], '1'
    je .digit_found
    mov r15, 2
    cmp byte [r10], '2'
    je .digit_found
    mov r15, 3
    cmp byte [r10], '3'
    je .digit_found
    mov r15, 4
    cmp byte [r10], '4'
    je .digit_found
    mov r15, 5
    cmp byte [r10], '5'
    je .digit_found
    mov r15, 6
    cmp byte [r10], '6'
    je .digit_found
    mov r15, 7
    cmp byte [r10], '7'
    je .digit_found
    mov r15, 8
    cmp byte [r10], '8'
    je .digit_found
    mov r15, 9
    cmp byte [r10], '9'
    je .digit_found

    mov     r15, 9
    cmp     byte [r10], ','
    je      .control_chars
    mov     r15, 9
    cmp     byte [r10], ')'
    je      .control_chars

    mov     r10, 2          ; report found error char, exit
    jmp     .exit_push_digit

.control_chars
    mov     r10, 1          ; report found control char, exit

.exit_push_digit:           ; if we didn't find a digit, just fall back out
    pop     r15
    ret

.digit_found:
    push    rax                ; borrow rax as it is the multiplication register
    mov     rax, 10             ; fill it with 10

    mul     r11                 ; multiply the contents of rax by r11
    mov     r11, rax            ; move the result into r11
    add     r11, r15            ; add the new number
                            ; eg: r11 contains 12
                            ; eg: r15 contains 3
                            ; eg: 12 * 10 + 3 = 123
                            ; eg: r11 now contains 123

    mov     r10, 0          ; set r10 to report OK
    pop     rax
    jmp .exit_push_digit

;
;   scratchpad below
;


    ; push    rdx
    ; mov     rax, 1        ; write call number, __NR_write from unistd_64.h
    ; mov     edi, 1        ; write to stdout (int fd=1)
    ; mov     rsi, rsp      ; use char on stack
    ; mov     rdx, 1        ; size_t len = 1 char to write.
    ; syscall               ; call the kernel, it looks at registers to decide what to do
    ; add     rsp, 8        ; restore stack pointer

    ; mov     rcx, nlc
    ; mov     rdx, 1
    ; call     _print

    ; mov     rdi, example  ; Load the address of the message into the register
    ; call    _strlen
    ; mov     rdx, rax      ; move the length of the string into rdx for printing
    ; mov     rcx, example  ; move the string into rcx for printing
    ; call     _print
    ; mov     r9, example
    ; call    _print_char_in_str

_print:                     ; prints len (rdx) characters from str (rcx)
    mov     rbx, 1          ; Set the file descriptor to 1 (stdout)
    mov     rax, 4          ; Set the syscall number for 'write' (4)
    int     0x80            ; Make the syscall to print the message to the screen
    ret

_print_char_in_str:         ; prints each char in r9 with newlines
    push rcx                ; save and clear counter
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
    call _print_digit

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
    pop rcx                 ; save and clear counter
    ret

_print_digit:
    cmp byte [r9], '0'
    jl _print_digit_skip
    cmp byte [r9], '9'
    jg _print_digit_skip

    push rcx
    push rdx

    mov rcx, nlc
    mov rdx, 1
    call _print
    mov rcx, r9
    mov rdx, 1
    call _print
    mov rcx, digit
    mov rdx, 7
    call _print

    pop rdx
    pop rcx
_print_digit_skip:
    jmp _print_char_in_str_loop_eq_m_ret

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
    push rcx                ; save and clear counter
    xor rcx, rcx

_strlen_next:
    cmp [rdi], byte 0       ; is this a null byte?
    jz  _strlen_null        ; if 0, end counting

    inc rcx                 ; char is not null, increment counter to count it
    inc rdi                 ; move to next character
    jmp _strlen_next

_strlen_null:
    mov rax, rcx            ; rcx = length, store in rax
    pop rcx                 ; restore rcx
    ret                     ; jump back to where we were

section     .data           ; Data section where static data (like strings) is stored
msg     db  'abcde edcba', 0xa  ; Define the message to be printed with a newline at the end
nlc db 0xa
example incbin 'example.txt'
eqm db 0xa, "eq m", 0xa
digit db " digit", 0xa
srch db "mul(,)"