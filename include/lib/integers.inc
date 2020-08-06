;
; Function: integer.to_string
; Arguments:
;   [PTR-RDI]    Integer to convert
;   [PTR-RSI]    Output buffer
; Return:
;   [INT-RAX]    Buffer size
;
integer.to_string:
  push  rbp
  mov   rbp, rsp
  sub   rsp, 32

  mov   [rbp-8], rdi
  mov   [rbp-16], rsi
  mov   word [rbp-24], 0

  mov   rax, [rbp-8]                  ; integer to convert
  mov   rdi, [rbp-16]                 ; output buffer

  xor   rbx, rbx

.integer.to_string.convert:           ; convert an integer to ASCII
  xor   rdx, rdx
  mov   rcx, 10
  div   rcx                           ; get the remainder of rax/rcx
  add   rdx, 0x30                     ; add 0x30 to convert to ASCII
  push  rdx                           ; push to stack
  inc   rbx                           ; counter for number of characters
  test  rax, rax                      ; check if 0
  jnz   .integer.to_string.convert

  mov   [rbp-24], rbx                 ; preserve char count to return

.integer.to_string.push:              ; write the character to the buffer stored in rdi
  pop   rax
  stosb
  dec   rbx
  cmp   rbx, 0
  jg    .integer.to_string.push

  mov   rax, [rbp-24]                 ; return the number of characters written to the buffer

  mov   rsp, rbp
  pop   rbp

  ret