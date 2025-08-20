open! Core
open! Async

module Query : sig
  module V1 : sig
    type t = int [@@deriving bin_io]
  end

  module V2 : sig
    type t = { magic_number : int } [@@deriving bin_io]
  end

  module Latest = V2
end

module Response : sig
  module V1 : sig
    type t = unit [@@deriving bin_io]
  end

  module Latest = V1
end

val dispatch
  :  Versioned_rpc.Connection_with_menu.t
  -> Query.Latest.t
  -> Response.Latest.t Deferred.Or_error.t

val implement
  :  ('a -> Rpc.Description.t -> Query.Latest.t -> Response.Latest.t Deferred.t)
  -> 'a Rpc.Implementation.t list
