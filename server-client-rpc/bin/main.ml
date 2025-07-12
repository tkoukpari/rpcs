open! Core
open! Async

let command =
  Command.group ~summary:"server-client-rpc"
    [ ("server", Server_lib.command); ("client", Client_lib.command) ]

let () = Command_unix.run command
