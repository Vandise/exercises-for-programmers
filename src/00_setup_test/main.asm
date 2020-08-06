; Executable name : main
; Version         : 0.1
; Author          : Benjamin J. Anderson
; Description     : Runs SYS_EXIT with a status code of 2
; Example         :
;                     ./main
;                     echo $?

%include "common.inc"

section .data

section .bss

section .text
  global start

start:
  mov rax, SYS_EXIT
  mov rdi, 2
  syscall