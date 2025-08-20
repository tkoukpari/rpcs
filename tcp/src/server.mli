open! Core
open! Async

val start : print_state_every:Time_float.Span.t -> unit Deferred.t