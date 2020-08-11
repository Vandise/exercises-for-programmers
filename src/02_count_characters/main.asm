; Executable name : main
; Version         : 0.1
; Author          : Benjamin J. Anderson
; Description     : Prompts the user for a string a prints out the number of characters
; Example         :
;                     ./main
;                     What is the input string? Ben
;                     Ben has 3 characters.

%include "common.inc"
%include "lib/stdio.inc"
%include "lib/strings.inc"
%include "lib/integers.inc"

%define INPUT_COUNT_BUFFER_SIZE 19
%define INPUT_BUFFER_SIZE 100
%define OUTPUT_BUFFER_SIZE 150

section .bss
  input_buffer        resb INPUT_BUFFER_SIZE
  output_buffer       resb OUTPUT_BUFFER_SIZE
  input_count_buffer  resb INPUT_COUNT_BUFFER_SIZE

section .data
  prompt_text:    db "What is the input string? "
  prompt_size:   equ $-prompt_text

  has_txt:    db " has "
  has_txt_size:   equ $-has_txt

  message_end:    db " characters.", 0xA
  message_end_size:   equ $-message_end

section .text
  global start

start:
  nop
  push    rbp
  mov     rbp, rsp
  sub     rsp, 16
  mov     word [rbp-8], 0       ; number of string characters to print from input_count_buffer

  mov rbx, 0                    ; output message write index

  lea rdi, [prompt_text]        ; prompt the user for some text
  mov rsi, prompt_size
  mov rdx, input_buffer
  mov rcx, INPUT_BUFFER_SIZE
  call stdio.prompt

  dec rax                       ; remove newline character
  push rax

  mov rdi, rax                  ; convert the number of characters from the input to ascii
  lea rsi, [input_count_buffer]
  call integer.to_string
  mov [rbp-8], rax

  mov rdi, output_buffer        ; build output message fragment "<user input>"
  lea rsi, [input_buffer]
  pop rdx
  mov rcx, rbx
  call string.append

  add rbx, rdx                  ; output message write index

  lea rdi, output_buffer        ; build output message fragment " has "
  lea rsi, [has_txt]
  mov rdx, has_txt_size
  mov rcx, rbx
  call string.append

  add rbx, has_txt_size         ; output message write index

  mov rdi, output_buffer        ; build output message fragment " <number of characters> "
  lea rsi, [input_count_buffer]
  mov rdx, [rbp-8]
  mov rcx, rbx
  call string.append

  add rbx, [rbp-8]              ; output message write index

  mov rdi, output_buffer        ; build output message fragment " characters."
  lea rsi, [message_end]
  mov rdx, message_end_size
  mov rcx, rbx
  call string.append

  add rbx, message_end_size     ; total characters for output

  lea rdi, output_buffer        ; print the message
  mov rsi, rbx
  call stdio.write

exit:
  mov rax,  SYS_EXIT
  mov rdi,  0
  syscall