%macro import 1
  %push _import_

  %strcat filename "./", %{1}, ".inc"
  %defstr %$file filename
  %include filename

  %pop
%endmacro