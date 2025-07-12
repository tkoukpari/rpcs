open! Core
open! Async

let param = Command.Param.(anon ("print-state-every" %: float))

let command =
  Command.async ~summary:"server"
    (let%map.Command print_state_every = param in
     fun () ->
       let print_state_every = Time_float.Span.of_sec print_state_every in
       Server.start ~print_state_every)
