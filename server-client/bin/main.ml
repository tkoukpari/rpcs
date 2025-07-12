open! Core
open! Async

let command =
  Command.group ~summary:"server-client-rpc"
    [ ("server", Server_lib.Server.command) ]

let () = Command_unix.run command
