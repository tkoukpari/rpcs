open! Core
open! Async

module Query = struct
  module V1 = struct
    type t = int [@@deriving bin_io]
  end

  module V2 = struct
    type t = { magic_number : int } [@@deriving bin_io]

    let of_v1 : V1.t -> t = fun magic_number -> { magic_number }
    let to_v1 : t -> V1.t = fun { magic_number } -> magic_number
  end

  module Latest = V2
end

module Response = struct
  module V1 = struct
    type t = unit [@@deriving bin_io]
  end

  module Latest = V1
end

let rpc version bin_query bin_response include_in_error_count =
  Rpc.Rpc.create ~name:"magic-number-rpc" ~version ~bin_query ~bin_response
    ~include_in_error_count

let v1 = rpc 1 Query.V1.bin_t Response.V1.bin_t Only_on_exn
and v2 = rpc 2 Query.V2.bin_t Response.V1.bin_t Only_on_exn

let caller =
  Babel.Caller.Rpc.singleton v1
  |> Babel.Caller.Rpc.map_query ~f:Query.V2.to_v1
  |> Babel.Caller.Rpc.add ~rpc:v2

let%expect_test _ =
  Babel.Caller.print_shapes caller;
  [%expect
    {|
    ((((name my-both-convert-rpc) (version 3))
      (Rpc (query 94d3b785da460869144daff623f170df)
       (response fe8c6d5d25e0c5ee905d672ed01b4a45)))
     (((name my-both-convert-rpc) (version 2))
      (Rpc (query 94d3b785da460869144daff623f170df)
       (response 0743bf7ccae7c4a9d44998836b0cb146)))
     (((name my-both-convert-rpc) (version 1))
      (Rpc (query fa9bd13df9b004418afde2225f5c7927)
       (response 0743bf7ccae7c4a9d44998836b0cb146))))
    |}];
  return ()

let callee =
  Babel.Callee.Rpc.singleton v1
  |> Babel.Callee.Rpc.map_query ~f:Query.V2.of_v1
  |> Babel.Callee.Rpc.add ~rpc:v2

let%expect_test _ =
  Babel.Callee.print_shapes callee;
  [%expect
    {|
      (Ok
       ((my-both-convert-rpc
         ((1
           (Rpc (query fa9bd13df9b004418afde2225f5c7927)
            (response 0743bf7ccae7c4a9d44998836b0cb146)))
          (2
           (Rpc (query 94d3b785da460869144daff623f170df)
            (response 0743bf7ccae7c4a9d44998836b0cb146)))
          (3
           (Rpc (query 94d3b785da460869144daff623f170df)
            (response fe8c6d5d25e0c5ee905d672ed01b4a45)))))))
      |}];
  return ()

let dispatch = Babel.Caller.Rpc.dispatch_multi caller
let implement f = Babel.Callee.implement_multi_exn callee ~f
