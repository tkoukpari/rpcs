open! Core
open! Async
module Inet_addr := Core_unix.Inet_addr

val query_server : inet_addr:Inet_addr.t -> magic_number:int -> unit Deferred.Or_error.t
