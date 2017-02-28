import Foundation

let numArrays=Int(CommandLine.arguments[1])!
let before=mstats();
var base:NSMutableArray=["Hello World"]
for i in 1...numArrays {
    base=[base]
}
let b=base.description
let after=mstats();
print("memory used: \( after.bytes_used - before.bytes_used)")

