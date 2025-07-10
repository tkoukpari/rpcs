open! Core
open! Async

module State = struct
  type t = { magic_number : int option } [@@deriving sexp_of]
end

let print_state_forever state ~how_often_should_i_print_state =
  Clock.every how_often_should_i_print_state (fun () ->
      Core.print_s [%message (state : State.t)]);
  Deferred.never ()

let param =
  Command.Param.(anon ("how-often-should-i-print-state-in-seconds" %: float))

let command =
  Command.async ~summary:""
    (let%map.Command how_often_should_i_print_state = param in
     fun () ->
       let state : State.t = { magic_number = None } in
       let how_often_should_i_print_state =
         Time_float.Span.of_sec how_often_should_i_print_state
       in
       print_state_forever state ~how_often_should_i_print_state)
