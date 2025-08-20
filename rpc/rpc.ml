open! Core
open! Async

let command =
  Command.group ~summary:"rpc"
    [ ("server", Rpc_server.command); ("client", Rpc_client.command) ]
