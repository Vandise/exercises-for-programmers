; Executable name : main
; Version         : 0.1
; Author          : Benjamin J. Anderson
; Description     : Prompts the user for a quote and who said it
; Example         :
;                     ./main
;                     What is the quote? Bender is great.
;                     Who said it? Bender
;                     Bender says, "Bender is great."

%include "common.inc"
%include "lib/stdio.inc"
%include "lib/strings.inc"

%define INPUT_BUFFER_SIZE 100
%define OUTPUT_BUFFER_SIZE 250

section .bss
  quote_buffer        resb INPUT_BUFFER_SIZE
  author_buffer       resb INPUT_BUFFER_SIZE
  output_buffer       resb OUTPUT_BUFFER_SIZE

section .data
  n_prompts:          dq  2

  quote_prompt_msg:   db  "What is the quote? "
  author_prompt_msg:  db  "Who said it? "

  prompt_array:       dq  quote_prompt_msg, author_prompt_msg
  prompt_size_array:  dq  0x13, 0x0D

  buffer_array:       dq  quote_buffer, author_buffer
  buffer_size_array:  dq  0x00, 0x00

  quote:              db '"'
  quote_size:        equ $-quote

  says_txt:           db " says, "
  says_txt_size:     equ $-says_txt

section .text
  global start

; rbx: number of iterations executed
; r10: number of prompts

start:
  nop
  push    rbp
  mov     rbp, rsp

  mov     r10,  [n_prompts]
  xor     rbx,  rbx

.for_prompt:                             ; iterate through the prompts and get the input

  cmp      rbx, r10
  je       .print_message

  lea	     rax,	prompt_array             ; pointer to quote prompt buffer array
  mov	     rdi,	[rax+rbx*8]              ; get the prompt message in RDI

  lea	     rax,	prompt_size_array        ; pointer to quote prompt sizes
  mov	     rsi, [rax+rbx*8]

  lea      rax, buffer_array             ; pointer to buffer array
  mov      rdx, [rax+rbx*8]              ; output buffer
  mov      rcx, INPUT_BUFFER_SIZE

  call     stdio.prompt

  dec      rax                           ; remove newline char
  lea      rcx, buffer_size_array        ; save the size of the user input
  mov      [rcx+rbx*8], rax

  inc      rbx

  jmp      .for_prompt

;
; Rather than string.append, rep stosq can reduce the number of instructions
; however, longer initialization time
;
.print_message:

  xor      rbx, rbx                      ; output buffer offset

  nop                                    ; <author name>
  mov      rdi, output_buffer            ; buffer to write to
  lea      rax, buffer_array
  mov      rsi, [rax+8]                  ; buffer to read bytes from
  lea      rax, buffer_size_array
  mov      rdx, [rax+8]                  ; number of bytes to read/write
  mov      rcx, 0                        ; offset to write to
  call     string.append

  add      rbx, rdx                      ; offset for next output buffer write

  nop                                    ; " says, "
  mov      rdi, output_buffer            ; buffer to write to
  lea      rsi, [says_txt]
  mov      rdx, says_txt_size
  mov      rcx, rbx
  call     string.append

  add      rbx, says_txt_size            ; offset for next output buffer write

  nop                                    ; quote text " <quote> "
  mov      rdi, output_buffer            ; buffer to write to
  lea      rsi, [quote]
  mov      rdx, quote_size
  mov      rcx, rbx
  call     string.append  

  add      rbx, quote_size               ; offset for next output buffer write

  nop                                    ; <author quote>
  mov      rdi, output_buffer            ; buffer to write to
  lea      rax, buffer_array
  mov      rsi, [rax]                    ; buffer to read bytes from
  lea      rax, buffer_size_array
  mov      rdx, [rax]                    ; number of bytes to read/write
  mov      rcx, rbx                      ; offset to write to
  call     string.append

  add      rbx, rdx                      ; offset for next output buffer write

  nop                                    ; quote text " <quote> "
  mov      rdi, output_buffer            ; buffer to write to
  lea      rsi, [quote]
  mov      rdx, quote_size
  mov      rcx, rbx
  call     string.append  

  add      rbx, quote_size               ; offset for next output buffer write

  lea      rdi, output_buffer            ; print the message
  mov      rsi, rbx
  call     stdio.write

.exit:
  mov rax,  SYS_EXIT
  mov rdi,  0
  syscall