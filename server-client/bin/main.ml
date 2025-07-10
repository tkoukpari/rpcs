open! Core
open! Async

let () = Command_unix.run Server_client.Server.command
