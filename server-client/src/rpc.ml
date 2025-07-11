open! Core
open! Async

module Query = struct
  type t = { magic_number : int } [@@deriving bin_io]
end

module Response = struct
  type t = unit [@@deriving bin_io]
end
