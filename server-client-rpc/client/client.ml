open! Core
open! Async
module Protocol = Protocol_lib.Protocol

let query_server ~magic_number =
  let query : Protocol.Query.Latest.t = { magic_number } in
  let%bind connection =
    Rpc.Connection.client
      (Tcp.Where_to_connect.of_host_and_port
         (Host_and_port.create ~host:"localhost" ~port:8080))
    >>| Result.ok_exn
  in
  let%bind connection_with_menu =
    Versioned_rpc.Connection_with_menu.create connection >>| ok_exn
  in
  let%bind response = Protocol.dispatch connection_with_menu query in
  let%bind () = Rpc.Connection.close connection in
  print_s [%message (response : unit Or_error.t)];
  return ()
