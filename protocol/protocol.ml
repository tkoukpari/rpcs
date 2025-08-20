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
    ((((name magic-number-rpc) (version 2))
      (Rpc (query 854f3441ba97124b9ad37a22891aa3c9)
       (response 86ba5df747eec837f0b391dd49f33f9e)))
     (((name magic-number-rpc) (version 1))
      (Rpc (query 698cfa4093fe5e51523842d37b92aeac)
       (response 86ba5df747eec837f0b391dd49f33f9e))))
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
     ((magic-number-rpc
       ((1
         (Rpc (query 698cfa4093fe5e51523842d37b92aeac)
          (response 86ba5df747eec837f0b391dd49f33f9e)))
        (2
         (Rpc (query 854f3441ba97124b9ad37a22891aa3c9)
          (response 86ba5df747eec837f0b391dd49f33f9e)))))))
    |}];
  return ()

let dispatch = Babel.Caller.Rpc.dispatch_multi caller
let implement f = Babel.Callee.implement_multi_exn callee ~f
