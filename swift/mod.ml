open! Core
open! Async

let query_server inet_addr magic_number =
  let f () =
    Rpc_client.Client.query_server
      ~inet_addr:(Core_unix.Inet_addr.of_string inet_addr)
      ~magic_number
    >>| [%sexp_of: unit Or_error.t] >>| print_s
  in
  Thread_safe.block_on_async_exn f

let _ = Callback.register "query_server" query_server
