; Executable name : main
; Version         : 0.1
; Author          : Benjamin J. Anderson
; Description     : Props the user for their name and displays a greeting message
; Example         :
;                     ./main
;                     What is your name? Ben
;                     Hello, Ben, nice to meet you!

%include "common.inc"
%include "lib/stdio.inc"
%include "lib/strings.inc"

%define INPUT_BUFFER_SIZE 50
%define OUTPUT_BUFFER_SIZE 250

section .bss
  input_buffer  resb INPUT_BUFFER_SIZE
  output_buffer resb OUTPUT_BUFFER_SIZE

section .data
  prompt_text:    db "What is your name? "
  prompt_size:   equ $-prompt_text

  greet_start:    db "Hello, "
  greet_start_size:   equ $-greet_start

  greet_end:    db ", nice to meet you!", 0xA
  greet_end_size:   equ $-greet_end

section .text
  global start

start:
  nop
  push    rbp
  mov     rbp, rsp

  mov rbx, 0                  ; output message write index

  lea rdi, [prompt_text]      ; prompt the user for their name
  mov rsi, prompt_size
  mov rdx, input_buffer
  mov rcx, INPUT_BUFFER_SIZE
  call stdio.prompt

  dec rax                     ; remove newline character
  push rax

  mov rdi, output_buffer      ; build output message fragment "Hello, "
  lea rsi, [greet_start]
  mov rdx, greet_start_size
  mov rcx, rbx
  call string.append

  add rbx, greet_start_size   ; next output write index

  mov rdi, output_buffer      ; build output message fragment containing the prompted input
  lea rsi, [input_buffer]
  pop rdx
  mov rcx, rbx
  call string.append

  add rbx, rdx                ; next output write index

  mov rdi, output_buffer      ; build output message fragment ", nice to meet you!"
  lea rsi, [greet_end]
  mov rdx, greet_end_size
  mov rcx, rbx
  call string.append

  add rbx, greet_end_size     ; total size of the buffer for output

  lea rdi, output_buffer
  mov rsi, rbx
  call stdio.write

exit:
  mov rax,  SYS_EXIT
  mov rdi,  0
  syscall
