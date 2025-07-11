open! Core
open! Async

module State = struct
  type t = { mutable magic_number : int } [@@deriving sexp_of]
end

let handle_magic_number_rpc (state : State.t)
    ({ magic_number } : Protocol.Query.t) =
  state.magic_number <- magic_number;
  return ()

let implementation state =
  Async.Rpc.Rpc.implement Protocol.rpc (fun () query ->
      handle_magic_number_rpc state query)

let serve state ~port =
  let implementations = [ implementation state ] in
  let server =
    Async.Rpc.Connection.serve
      ~implementations:
        (Async.Rpc.Implementations.create_exn ~implementations
           ~on_unknown_rpc:`Close_connection)
      ~initial_connection_state:(fun _ _ -> ())
      ~where_to_listen:(Tcp.Where_to_listen.of_port port)
      ()
  in
  printf "RPCs served on port %d\n" port;
  server

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
       let%bind _ = serve state ~port:8080 in
       print_state_forever state ~every:print_state_every)
