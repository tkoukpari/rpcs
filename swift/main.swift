import Foundation

@_silgen_name("query_server") func query_server(_ inet_addr: UnsafePointer<CChar>, _ n: Int32) -> Void

let inet_addr = CommandLine.arguments[1]
let n = Int32(CommandLine.arguments[2])!

inet_addr.withCString { cString in
    query_server(cString, n)
}