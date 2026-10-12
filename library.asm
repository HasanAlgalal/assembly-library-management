; Library Management System in x86 Assembly (NASM)
; For CT073-3-2 Computer System Low Level Techniques Assignment
; Maintained educational version: validated input and bounded transaction log

section .data
    ; Messages and prompts
    welcome db "Welcome to Library Management System", 10, 0
    menu db 10, "===== LIBRARY MANAGEMENT SYSTEM =====", 10
         db "1. View All Books", 10
         db "2. Search for a Book", 10
         db "3. Borrow a Book", 10
         db "4. Return a Book", 10
         db "5. View Statistics", 10
         db "6. Exit", 10
         db "Enter your choice: ", 0
    goodbye db "Thank you for using Library Management System. Goodbye!", 10, 0

    ; Error messages
    err_log_full db "Transaction log is full (100 entries). Restart to reset this session.", 10, 0
    err_invalid db "Invalid choice. Please try again.", 10, 0
    err_book_id db "Invalid book ID. Please try again.", 10, 0
    err_unavail db "Sorry, this book is currently unavailable.", 10, 0
    err_not_borrow db "This book is not currently borrowed.", 10, 0
    book_not_found db "Sorry, we don't have a book with that ID.", 10, 0

    ; Success messages
    borrow_success db "Book successfully borrowed!", 10, 0
    return_success db "Book successfully returned!", 10, 0

    ; Prompts
    prompt_id db "Enter Book ID (1-10): ", 0
    prompt_enter db "Press Enter to continue...", 0

    ; Book list header/footer
    list_header db 10, "---------- LIBRARY BOOK LIST ----------", 10, 0
    list_footer db "--------------------------------------", 10, 0

    ; Book display parts
    id_prefix db "ID: ", 0
    title_prefix db "Title: ", 0
    author_prefix db "Author: ", 0
    status_prefix db "Status: ", 0
    separator db " | ", 0

    ; Status strings
    status_avail db "Available", 0
    status_borrow db "Borrowed", 0

    ; Statistics
    stat_header db 10, "---------- LIBRARY STATISTICS ----------", 10, 0
    stat_total db "Total Books: ", 0
    stat_borrowed db "Currently Borrowed: ", 0
    stat_transactions db "Total Transactions: ", 0

    ; Transaction history
    trans_header db 10, "---------- TRANSACTION HISTORY ----------", 10, 0
    trans_borrow db "Book ID: ", 0
    trans_borrow_suffix db " was borrowed", 10, 0
    trans_return db "Book ID: ", 0
    trans_return_suffix db " was returned", 10, 0

    ; Book details
    book1_id db 1
    book1_title db "The Art of Assembly", 0
    book1_author db "Randall Hyde", 0
    book1_status db 0

    book2_id db 2
    book2_title db "Programming from the Ground Up", 0
    book2_author db "Jonathan Bartlett", 0
    book2_status db 0

    book3_id db 3
    book3_title db "Clean Code", 0
    book3_author db "Robert C. Martin", 0
    book3_status db 0

    book4_id db 4
    book4_title db "Operating Systems: Three Easy Pieces", 0
    book4_author db "Remzi H. Arpaci-Dusseau", 0
    book4_status db 0

    book5_id db 5
    book5_title db "Computer Systems: A Programmer's Perspective", 0
    book5_author db "Randal Bryant & David O'Hallaron", 0
    book5_status db 0

    book6_id db 6
    book6_title db "The Pragmatic Programmer", 0
    book6_author db "Andrew Hunt & David Thomas", 0
    book6_status db 0

    book7_id db 7
    book7_title db "Introduction to Algorithms", 0
    book7_author db "Cormen, Leiserson, Rivest, Stein", 0
    book7_status db 0

    book8_id db 8
    book8_title db "Assembly Language Step-by-Step", 0
    book8_author db "Jeff Duntemann", 0
    book8_status db 0

    book9_id db 9
    book9_title db "The Mythical Man-Month", 0
    book9_author db "Frederick P. Brooks Jr.", 0
    book9_status db 0

    book10_id db 10
    book10_title db "Structure and Interpretation of Computer Programs", 0
    book10_author db "Harold Abelson & Gerald Jay Sussman", 0
    book10_status db 0

    ; System variables
    books_count db 10              ; Total number of books
    total_books db 10              ; Total number of books in library
    books_borrowed db 0            ; Current number of borrowed books

    ; Transaction log
    trans_log_ids times 100 db 0   ; Book IDs for transactions (up to 100)
    trans_log_ops times 100 db 0   ; 1=borrow, 2=return
    trans_count db 0               ; Number of transactions

    newline db 10, 0               ; Newline character

section .bss
    user_input resb 32             ; Buffer for user input
    input_len equ 32               ; Length of input buffer
    num_buffer resb 8              ; Buffer for number conversion
    input_size resd 1
    input_overflow resb 1
    read_char resb 1
    current_book_id resb 1         ; Store current book ID being processed

section .text
    global _start

_start:
    ; Display welcome message
    mov eax, welcome
    call print_string

main_loop:
    ; Display menu
    mov eax, menu
    call print_string

    ; Get user choice
    call read_input

    ; Check if input is valid
    call parse_number

    ; Check if choice is valid (1-6)
    cmp al, 1
    jl invalid_choice
    cmp al, 6
    jg invalid_choice

    ; Jump to appropriate handler
    cmp al, 1
    je view_books
    cmp al, 2
    je search_book
    cmp al, 3
    je borrow_book
    cmp al, 4
    je return_book
    cmp al, 5
    je view_stats
    cmp al, 6
    je exit_program

invalid_choice:
    mov eax, err_invalid
    call print_string
    jmp wait_input

;------------------------------------------------------------------------
; View all books function
;------------------------------------------------------------------------
view_books:
    ; Display header
    mov eax, list_header
    call print_string

    ; Call display_book for each book (1-10)
    mov byte [current_book_id], 1
    call display_book

    mov byte [current_book_id], 2
    call display_book

    mov byte [current_book_id], 3
    call display_book

    mov byte [current_book_id], 4
    call display_book

    mov byte [current_book_id], 5
    call display_book

    mov byte [current_book_id], 6
    call display_book

    mov byte [current_book_id], 7
    call display_book

    mov byte [current_book_id], 8
    call display_book

    mov byte [current_book_id], 9
    call display_book

    mov byte [current_book_id], 10
    call display_book

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

;------------------------------------------------------------------------
; Search for a book
;------------------------------------------------------------------------
search_book:
    ; Prompt for book ID
    mov eax, prompt_id
    call print_string

    ; Get user input
    call read_input

    ; Convert input to number
    call parse_number

    ; Validate book ID
    cmp al, 1
    jl invalid_book_id
    cmp al, [books_count]
    jg invalid_book_id

    ; Store the book ID to display
    mov [current_book_id], al

    ; Display header
    mov eax, list_header
    call print_string

    ; Display the book
    call display_book

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

invalid_book_id:
    mov eax, err_book_id
    call print_string
    mov eax, book_not_found
    call print_string
    jmp wait_input

;------------------------------------------------------------------------
; Borrow a book
;------------------------------------------------------------------------
borrow_book:
    ; Prompt for book ID
    mov eax, prompt_id
    call print_string

    ; Get user input
    call read_input

    ; Convert input to number
    call parse_number

    ; Validate book ID
    cmp al, 1
    jl invalid_book_id
    cmp al, [books_count]
    jg invalid_book_id

    ; Store the book ID
    mov [current_book_id], al

    ; Check book's status
    call check_book_status
    cmp al, 0
    jne book_already_borrowed

    cmp byte [trans_count], 100
    jae log_full

    ; Book is available, mark as borrowed
    call update_book_status_to_borrowed

    ; Record transaction
    mov al, [current_book_id]
    movzx ebx, byte [trans_count]
    mov [trans_log_ids + ebx], al
    mov byte [trans_log_ops + ebx], 1  ; 1 = borrow
    inc byte [trans_count]

    ; Update statistics
    inc byte [books_borrowed]

    ; Show success message
    mov eax, borrow_success
    call print_string

    ; Display header
    mov eax, list_header
    call print_string

    ; Display the borrowed book
    call display_book

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

log_full:
    mov eax, err_log_full
    call print_string
    jmp wait_input

book_already_borrowed:
    ; Display header
    mov eax, list_header
    call print_string

    ; Display the book
    call display_book

    ; Display unavailable message
    mov eax, err_unavail
    call print_string

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

;------------------------------------------------------------------------
; Return a book
;------------------------------------------------------------------------
return_book:
    ; Prompt for book ID
    mov eax, prompt_id
    call print_string

    ; Get user input
    call read_input

    ; Convert input to number
    call parse_number

    ; Validate book ID
    cmp al, 1
    jl invalid_book_id
    cmp al, [books_count]
    jg invalid_book_id

    ; Store the book ID
    mov [current_book_id], al

    ; Check book's status
    call check_book_status
    cmp al, 1
    jne book_not_borrowed

    cmp byte [trans_count], 100
    jae log_full

    ; Book is borrowed, mark as available
    call update_book_status_to_available

    ; Record transaction
    mov al, [current_book_id]
    movzx ebx, byte [trans_count]
    mov [trans_log_ids + ebx], al
    mov byte [trans_log_ops + ebx], 2  ; 2 = return
    inc byte [trans_count]

    ; Update statistics
    dec byte [books_borrowed]

    ; Show success message
    mov eax, return_success
    call print_string

    ; Display header
    mov eax, list_header
    call print_string

    ; Display the returned book
    call display_book

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

book_not_borrowed:
    ; Display header
    mov eax, list_header
    call print_string

    ; Display the book
    call display_book

    ; Display not borrowed message
    mov eax, err_not_borrow
    call print_string

    ; Display footer
    mov eax, list_footer
    call print_string
    jmp wait_input

;------------------------------------------------------------------------
; View statistics
;------------------------------------------------------------------------
view_stats:
    ; Display header
    mov eax, stat_header
    call print_string

    ; Display total books
    mov eax, stat_total
    call print_string

    movzx eax, byte [total_books]
    call print_number

    mov eax, newline
    call print_string

    ; Display borrowed books
    mov eax, stat_borrowed
    call print_string

    movzx eax, byte [books_borrowed]
    call print_number

    mov eax, newline
    call print_string

    ; Display total transactions
    mov eax, stat_transactions
    call print_string

    movzx eax, byte [trans_count]
    call print_number

    mov eax, newline
    call print_string

    ; Display transaction history
    mov eax, trans_header
    call print_string

    ; Check if there are any transactions
    cmp byte [trans_count], 0
    je no_transactions

    ; Display transaction history
    xor ecx, ecx    ; Transaction counter

trans_loop:
    ; Check if we've displayed all transactions
    cmp cl, [trans_count]
    jae trans_done

    ; Get transaction type
    mov al, [trans_log_ops + ecx]
    cmp al, 1
    je display_borrow_trans
    cmp al, 2
    je display_return_trans
    jmp next_trans  ; Skip invalid entries

display_borrow_trans:
    ; Display borrow transaction
    mov eax, trans_borrow
    call print_string

    ; Get and display book ID
    movzx eax, byte [trans_log_ids + ecx]
    call print_number

    mov eax, trans_borrow_suffix
    call print_string
    jmp next_trans

display_return_trans:
    ; Display return transaction
    mov eax, trans_return
    call print_string

    ; Get and display book ID
    movzx eax, byte [trans_log_ids + ecx]
    call print_number

    mov eax, trans_return_suffix
    call print_string

next_trans:
    inc ecx
    jmp trans_loop

no_transactions:
    ; Nothing to display
    mov eax, newline
    call print_string

trans_done:
    jmp wait_input

;------------------------------------------------------------------------
; Wait for Enter key
;------------------------------------------------------------------------
wait_input:
    mov eax, prompt_enter
    call print_string
    call read_input
    jmp main_loop

;------------------------------------------------------------------------
; Exit program
;------------------------------------------------------------------------
exit_program:
    mov eax, goodbye
    call print_string

    ; Exit syscall
    mov eax, 1                  ; sys_exit
    xor ebx, ebx                ; exit code 0
    int 0x80                    ; call kernel

;------------------------------------------------------------------------
; Helper functions
;------------------------------------------------------------------------

; Display book info based on current_book_id
display_book:
    ; Setup
    pushad

    ; Get book ID
    movzx ecx, byte [current_book_id]

    ; Print ID part
    mov eax, id_prefix
    call print_string

    movzx eax, byte [current_book_id]
    call print_number

    ; Print separator
    mov eax, separator
    call print_string

    ; Print title part
    mov eax, title_prefix
    call print_string

    ; Determine which book title to print based on ID
    mov eax, ecx
    call get_book_title
    call print_string

    ; Print separator
    mov eax, separator
    call print_string

    ; Print author part
    mov eax, author_prefix
    call print_string

    ; Determine which book author to print based on ID
    mov eax, ecx
    call get_book_author
    call print_string

    ; Print separator
    mov eax, separator
    call print_string

    ; Print status part
    mov eax, status_prefix
    call print_string

    ; Determine which book status to print based on ID
    call check_book_status
    cmp al, 0
    je .print_available

    ; Book is borrowed
    mov eax, status_borrow
    jmp .print_status

.print_available:
    mov eax, status_avail

.print_status:
    call print_string

    ; Print newline
    mov eax, newline
    call print_string

    ; Cleanup and return
    popad
    ret

; Get book title address in EAX based on book ID in EAX
get_book_title:
    cmp eax, 1
    je .book1
    cmp eax, 2
    je .book2
    cmp eax, 3
    je .book3
    cmp eax, 4
    je .book4
    cmp eax, 5
    je .book5
    cmp eax, 6
    je .book6
    cmp eax, 7
    je .book7
    cmp eax, 8
    je .book8
    cmp eax, 9
    je .book9
    cmp eax, 10
    je .book10

.book1:
    mov eax, book1_title
    ret
.book2:
    mov eax, book2_title
    ret
.book3:
    mov eax, book3_title
    ret
.book4:
    mov eax, book4_title
    ret
.book5:
    mov eax, book5_title
    ret
.book6:
    mov eax, book6_title
    ret
.book7:
    mov eax, book7_title
    ret
.book8:
    mov eax, book8_title
    ret
.book9:
    mov eax, book9_title
    ret
.book10:
    mov eax, book10_title
    ret

; Get book author address in EAX based on book ID in EAX
get_book_author:
    cmp eax, 1
    je .book1
    cmp eax, 2
    je .book2
    cmp eax, 3
    je .book3
    cmp eax, 4
    je .book4
    cmp eax, 5
    je .book5
    cmp eax, 6
    je .book6
    cmp eax, 7
    je .book7
    cmp eax, 8
    je .book8
    cmp eax, 9
    je .book9
    cmp eax, 10
    je .book10

.book1:
    mov eax, book1_author
    ret
.book2:
    mov eax, book2_author
    ret
.book3:
    mov eax, book3_author
    ret
.book4:
    mov eax, book4_author
    ret
.book5:
    mov eax, book5_author
    ret
.book6:
    mov eax, book6_author
    ret
.book7:
    mov eax, book7_author
    ret
.book8:
    mov eax, book8_author
    ret
.book9:
    mov eax, book9_author
    ret
.book10:
    mov eax, book10_author
    ret

; Check book status (0=Available, 1=Borrowed)
; Returns status in AL
check_book_status:
    ; Get book ID
    movzx ecx, byte [current_book_id]

    ; Check ID and return status
    cmp ecx, 1
    je .book1
    cmp ecx, 2
    je .book2
    cmp ecx, 3
    je .book3
    cmp ecx, 4
    je .book4
    cmp ecx, 5
    je .book5
    cmp ecx, 6
    je .book6
    cmp ecx, 7
    je .book7
    cmp ecx, 8
    je .book8
    cmp ecx, 9
    je .book9
    cmp ecx, 10
    je .book10

    ; Default return 0
    xor al, al
    ret

.book1:
    mov al, [book1_status]
    ret
.book2:
    mov al, [book2_status]
    ret
.book3:
    mov al, [book3_status]
    ret
.book4:
    mov al, [book4_status]
    ret
.book5:
    mov al, [book5_status]
    ret
.book6:
    mov al, [book6_status]
    ret
.book7:
    mov al, [book7_status]
    ret
.book8:
    mov al, [book8_status]
    ret
.book9:
    mov al, [book9_status]
    ret
.book10:
    mov al, [book10_status]
    ret

; Update book status to borrowed (1)
update_book_status_to_borrowed:
    ; Get book ID
    movzx ecx, byte [current_book_id]

    ; Check ID and update status
    cmp ecx, 1
    je .book1
    cmp ecx, 2
    je .book2
    cmp ecx, 3
    je .book3
    cmp ecx, 4
    je .book4
    cmp ecx, 5
    je .book5
    cmp ecx, 6
    je .book6
    cmp ecx, 7
    je .book7
    cmp ecx, 8
    je .book8
    cmp ecx, 9
    je .book9
    cmp ecx, 10
    je .book10
    ret

.book1:
    mov byte [book1_status], 1
    ret
.book2:
    mov byte [book2_status], 1
    ret
.book3:
    mov byte [book3_status], 1
    ret
.book4:
    mov byte [book4_status], 1
    ret
.book5:
    mov byte [book5_status], 1
    ret
.book6:
    mov byte [book6_status], 1
    ret
.book7:
    mov byte [book7_status], 1
    ret
.book8:
    mov byte [book8_status], 1
    ret
.book9:
    mov byte [book9_status], 1
    ret
.book10:
    mov byte [book10_status], 1
    ret

; Update book status to available (0)
update_book_status_to_available:
    ; Get book ID
    movzx ecx, byte [current_book_id]

    ; Check ID and update status
    cmp ecx, 1
    je .book1
    cmp ecx, 2
    je .book2
    cmp ecx, 3
    je .book3
    cmp ecx, 4
    je .book4
    cmp ecx, 5
    je .book5
    cmp ecx, 6
    je .book6
    cmp ecx, 7
    je .book7
    cmp ecx, 8
    je .book8
    cmp ecx, 9
    je .book9
    cmp ecx, 10
    je .book10
    ret

.book1:
    mov byte [book1_status], 0
    ret
.book2:
    mov byte [book2_status], 0
    ret
.book3:
    mov byte [book3_status], 0
    ret
.book4:
    mov byte [book4_status], 0
    ret
.book5:
    mov byte [book5_status], 0
    ret
.book6:
    mov byte [book6_status], 0
    ret
.book7:
    mov byte [book7_status], 0
    ret
.book8:
    mov byte [book8_status], 0
    ret
.book9:
    mov byte [book9_status], 0
    ret
.book10:
    mov byte [book10_status], 0
    ret

; Print a string - expects string address in EAX
print_string:
    push ebx                    ; Save registers
    push ecx
    push edx

    ; Find string length
    mov ecx, eax
    mov edx, 0

.count_loop:
    cmp byte [ecx + edx], 0
    je .done_count
    inc edx
    jmp .count_loop

.done_count:
    ; Write to stdout
    mov ebx, 1                  ; stdout
    mov eax, 4                  ; sys_write
    int 0x80

    pop edx                     ; Restore registers
    pop ecx
    pop ebx
    ret

; Read one complete line, draining oversized input and handling EOF.
; Reading one byte at a time also supports redirected/piped input reliably.
read_input:
    pushad
    mov dword [input_size], 0
    mov byte [input_overflow], 0
.next:
    mov eax, 3
    xor ebx, ebx
    mov ecx, read_char
    mov edx, 1
    int 0x80
    cmp eax, -4                 ; Retry interrupted reads (EINTR).
    je .next
    cmp eax, 0
    jl .finish_error
    je .eof
    mov al, [read_char]
    cmp al, 10
    je .finish
    cmp al, 13                  ; Accept CRLF input too.
    je .next
    mov edi, [input_size]
    cmp edi, input_len - 1
    jae .overflow
    mov [user_input + edi], al
    inc dword [input_size]
    jmp .next
.overflow:
    mov byte [input_overflow], 1
    jmp .next                   ; Drain the rest of this line.
.eof:
    cmp dword [input_size], 0
    jne .finish
    popad
    jmp exit_program
.finish_error:
    popad
    jmp exit_program
.finish:
    mov edi, [input_size]
    mov byte [user_input + edi], 0
    popad
    ret

; Return an integer 1..10 in AL, or zero for invalid input.
; Validate every character, reject blank/oversized lines and values >10.
parse_number:
    push ecx
    push edx
    push esi
    xor eax, eax
    cmp byte [input_overflow], 0
    jne .invalid
    mov ecx, [input_size]
    test ecx, ecx
    jz .invalid
    xor esi, esi
.digit:
    movzx edx, byte [user_input + esi]
    sub edx, '0'
    cmp edx, 9
    ja .invalid
    imul eax, eax, 10
    add eax, edx
    cmp eax, 10
    ja .invalid
    inc esi
    cmp esi, ecx
    jb .digit
    jmp .done
.invalid:
    xor eax, eax
.done:
    pop esi
    pop edx
    pop ecx
    ret

; Print a number in EAX
print_number:
    push eax                    ; Save registers
    push ebx
    push ecx
    push edx

    ; Convert number to ASCII
    mov ecx, num_buffer
    add ecx, 7                  ; Start from end of buffer
    mov byte [ecx], 0           ; Null terminator

    mov ebx, 10                 ; Divisor

.convert_loop:
    dec ecx                     ; Move to next position
    xor edx, edx                ; Clear EDX for division
    div ebx                     ; Divide EAX by 10, remainder in EDX
    add dl, '0'                 ; Convert remainder to ASCII
    mov [ecx], dl               ; Store in buffer

    test eax, eax               ; Check if quotient is zero
    jnz .convert_loop           ; If not, continue

    ; Print the number string
    mov eax, ecx
    call print_string

    pop edx                     ; Restore registers
    pop ecx
    pop ebx
    pop eax
    ret
