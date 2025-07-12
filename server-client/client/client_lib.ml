open! Core
open! Async

let param = Command.Param.(anon ("magic-number" %: int))

let command =
  Command.async ~summary:"client"
    (let%map.Command magic_number = param in
     fun () -> Client.query_server ~magic_number)
