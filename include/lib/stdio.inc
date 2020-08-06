;
; Function: stdio.write
; Arguments:
;   [String-RDI] Prompt message
;   [Int-RSI]    Prompt message length
;
stdio.write:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 32

  mov   [rbp-8], rdi
  mov   [rbp-16], rsi

  mov   rax, SYS_WRITE      ; Display message
  mov   rdi, STDOUT
  mov   rsi, [rbp-8]
  mov   rdx, [rbp-16]
  syscall

  mov   rsp, rbp
  pop   rbp

  ret

;
; Function: stdio.read
; Arguments:
;   [Int-RDI]    File descriptor
;   [Int-RSI]    Buffer ptr
;   [PTR-RDX]    Buffer size
; Return:
;   [INT-RAX]    Input length or -1 on error
stdio.read:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 32

  mov   [rbp-8], rdi
  mov   [rbp-16], rsi
  mov   [rbp-24], rdx

  mov   rax, SYS_READ      ; Display message
  mov   rdi, [rbp-8]
  mov   rsi, [rbp-16]
  mov   rdx, [rbp-24]
  syscall

  mov   rsp, rbp
  pop   rbp

  ret


;
; Function: stdio.prompt
; Arguments:
;   [String-RDI] Prompt message
;   [Int-RSI]    Prompt message length
;   [PTR-RDX]    Input buffer address
;   [PTR-RCX]    Input buffer length
; Return:
;   [INT-RAX]    Input length or -1 on error
;
stdio.prompt:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 32

  mov   [rbp-8], rdi
  mov   [rbp-16], rsi
  mov   [rbp-24], rdx
  mov   [rbp-32], rcx

  mov   rdi, [rbp-8]      ; write the prompt message to the screen
  mov   rsi, [rbp-16]
  call  stdio.write

  mov   rdi, STDIN        ; grab the user input
  mov   rsi, [rbp-24]     ; rax contains the input length or -1 if error
  mov   rdx, [rbp-32]
  call  stdio.read

  mov   rsp, rbp
  pop   rbp

  ret
