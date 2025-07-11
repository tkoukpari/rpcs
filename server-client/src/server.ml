open! Core
open! Async

module State = struct
  type t = { magic_number : int } [@@deriving sexp_of]
end

let print_state_forever state ~every =
  Clock.every every (fun () -> Core.print_s [%message (state : State.t)]);
  Deferred.never ()

let param = Command.Param.(anon ("print-state-every" %: float))

let command =
  Command.async ~summary:""
    (let%map.Command print_state_every = param in
     fun () ->
       let state : State.t =
         { magic_number = Random.State.int Random.State.default 42 }
       in
       let print_state_every = Time_float.Span.of_sec print_state_every in
       print_state_forever state ~every:print_state_every)
