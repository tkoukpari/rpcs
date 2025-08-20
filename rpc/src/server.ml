open! Core
open! Async
module Protocol = Protocol_lib.Protocol

module State = struct
  type t = { mutable magic_number : int } [@@deriving sexp_of]
end

let handle_magic_number_rpc (state : State.t)
    ({ magic_number } : Protocol.Query.Latest.t) =
  state.magic_number <- magic_number;
  return ()

let implementations state =
  Protocol.implement (fun () (_ : Rpc.Description.t) query ->
      handle_magic_number_rpc state query)

let serve state ~port =
  let implementations = implementations state in
  let%bind _ =
    Rpc.Connection.serve
      ~implementations:
        (Rpc.Implementations.create_exn ~implementations
           ~on_unknown_rpc:`Close_connection)
      ~initial_connection_state:(fun _ _ -> ())
      ~where_to_listen:(Tcp.Where_to_listen.of_port port)
      ~auth:(fun addr ->
        addr |> Socket.Address.Inet.sexp_of_t |> print_s ~mach:();
        true)
      ()
  in
  print_s [%message "RPC served on port" (port : int)];
  return ()

let print_state_forever state ~every =
  Clock.every every (fun () -> print_s [%message (state : State.t)]);
  Deferred.never ()

let start ~print_state_every =
  let state : State.t =
    { magic_number = Random.State.int Random.State.default 42 }
  in
  let%bind () = serve state ~port:8080 in
  print_state_forever state ~every:print_state_every
