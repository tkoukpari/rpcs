open! Core
open! Async

let rpc_command =
  Command.group ~summary:"rpc"
    [ ("server", Rpc_server.command); ("client", Rpc_client.command) ]

let tcp_command =
  Command.group ~summary:"tcp"
    [ ("server", Tcp_server.command); ("client", Tcp_client.command) ]

let command = Command.group ~summary:"protocols" [ "rpc", rpc_command; "tcp", tcp_command ]

let () = Command_unix.run command
