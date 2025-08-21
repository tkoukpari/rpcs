open! Core
open! Async
module Client = Client

let inet_addr = Command.Param.(anon ("inet-addr" %: string))
let magic_number = Command.Param.(anon ("magic-number" %: int))

let command =
  Command.async ~summary:"client"
    (let%map.Command inet_addr = inet_addr and magic_number = magic_number in
     fun () ->
       let inet_addr = Core_unix.Inet_addr.of_string inet_addr in
       Client.query_server ~inet_addr ~magic_number >>| ok_exn)
