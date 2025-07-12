open! Core
open! Async

module Query = struct
  type t = { magic_number : int } [@@deriving bin_io]
end

module Response = struct
  type t = unit [@@deriving bin_io]
end

let rpc =
  Rpc.Rpc.create ~name:"magic_number_rpc" ~version:1
    ~include_in_error_count:Only_on_exn ~bin_query:Query.bin_t
    ~bin_response:Response.bin_t
