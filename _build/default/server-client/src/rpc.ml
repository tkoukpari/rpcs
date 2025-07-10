open! Core
open! Async

module Query = struct
  type t = unit [@@deriving bin_io]
end

module Response = struct
  type t = unit [@@deriving bin_io]
end
