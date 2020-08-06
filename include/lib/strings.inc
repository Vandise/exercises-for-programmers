;
; Function: string.append
; Arguments:
;   [PTR-RDI]    Destination buffer
;   [PTR-RSI]    Source buffer
;   [INT-RDX]    Number of bytes to read
;   [INT-RCX]    Offset
; Return:
;   [INT-RAX]    String length
;
string.append:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 32

  mov   [rbp-8], rdi
  mov   [rbp-16], rsi
  mov   [rbp-24], rdx
  mov   [rbp-32], rcx

  cld

  mov   rsi, [rbp-16]     ; source buffer
  mov   rdi, [rbp-8]      ; destination buffer
  add   rdi, [rbp-32]     ; offset to start writing to
  mov   rcx, [rbp-24]     ; number of bytes to read
  rep   movsb

  mov   rax, rcx          ; return the total size of the string

  mov   rsp, rbp
  pop   rbp

  ret

