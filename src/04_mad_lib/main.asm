; Executable name : main
; Version         : 0.1
; Author          : Benjamin J. Anderson
; Description     : Prompts the user for a: noun, verb, adjective, and adverb. Then outputs the madlib

%include "common.inc"
%include "lib/stdio.inc"
%include "lib/strings.inc"

%define INPUT_BUFFER_SIZE 100
%define OUTPUT_BUFFER_SIZE 250

section .bss
  noun_buffer            resb INPUT_BUFFER_SIZE
  verb_buffer            resb INPUT_BUFFER_SIZE
  adjective_buffer       resb INPUT_BUFFER_SIZE
  adverb_buffer          resb INPUT_BUFFER_SIZE
  output_buffer          resb OUTPUT_BUFFER_SIZE

section .data
  n_prompts:         dq  4
  n_outputs:         dq  8

  p_noun_msg:        db  "Enter a noun: "
  p_verb_msg:        db  "Enter a verb: "
  p_adjective_msg:   db  "Enter a adjective: "
  p_adverb_msg:      db  "Enter a adverb: "

  o_sp:              db  " "
  o_do:              db  "Do you"
  o_your:            db  "your"
  o_question:        db  "?"
  o_ending:          db  "That's hilarious!", 0xA

  prompt_array:       dq  p_noun_msg, p_verb_msg, p_adjective_msg, p_adverb_msg
  prompt_size_array:  dq  14, 14, 19, 16

  buffer_array:       dq  noun_buffer, verb_buffer, adjective_buffer, adverb_buffer
  buffer_size_array:  dq  0x00, 0x00, 0x00, 0x00

  output_array:       dq  o_do, verb_buffer, o_your, adjective_buffer, noun_buffer, adverb_buffer, o_question, o_ending
  output_sizes:       dq  6, -8, 4, -16, 0, -24, 1, 17

; rbx: number of iterations executed
; r10: number of prompts, outputs in .for_build_output
; r12: output offset/size

section .text
  global start

start:
  nop
  push    rbp
  mov     rbp, rsp

  mov     r10,  [n_prompts]
  xor     rbx,  rbx

.for_prompt:                             ; iterate through the prompts and get the input

  cmp      rbx, r10
  je       .end_for_prompt

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

.end_for_prompt:

  mov     r10,  [n_outputs]
  xor     r12,  r12
  xor     rbx,  rbx
  xor     rcx,  rcx

.for_build_output:
  cmp      rbx, r10
  je       .exit

  mov     rax,  output_array
  mov     rdi,  [rax+rbx*8]

  lea     rax,  output_sizes
  mov     rsi,  [rax+rbx*8]

  cmp      rsi, 0                        ; if not less than 0, we can jump to writing the output
  jnle     .write_output

  neg      rsi                           ; make the offset positive
  lea      rax, buffer_size_array        ; get the input size from the user buffer
  mov      rsi, [rax+rsi]                ; size in rsi

.write_output:

  call    stdio.write

  inc     rbx

  cmp     rbx, 10                        ; add a space if not the last output
  jl      .write_space

  jmp     .for_build_output

.write_space:
  mov     rdi,  o_sp
  mov     rsi,  1
  call    stdio.write
  jmp     .for_build_output

.exit:
  mov     rax,  SYS_EXIT
  mov     rdi,  0
  syscall