open! Core
open! Async

let command =
  Command.group ~summary:"tcp"
    [ ("server", Tcp_server.command); ("client", Tcp_client.command) ]
