open! Core

let command =
  Async.Command.group ~summary:"protocols"
    [ ("rpc", Rpc.command); ("tcp", Tcp.command) ]

let () = Command_unix.run command
