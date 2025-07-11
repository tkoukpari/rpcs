open! Core
open! Async

module Query : sig
  type t = { magic_number : int } [@@deriving bin_io]
end

module Response : sig
  type t = unit [@@deriving bin_io]
end
