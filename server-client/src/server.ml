open! Core
open! Async

let param = Command.Param.(anon ("number" %: int))

let command =
  Command.async ~summary:"Print an integer"
    ~readme:(fun () -> "Accepts an integer and prints it")
    (Command.Param.map param ~f:(fun n () ->
         printf "Command received: %d\n" n;
         return ()))
