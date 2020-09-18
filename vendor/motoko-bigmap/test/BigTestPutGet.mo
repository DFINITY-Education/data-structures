import Prim "mo:prim";
import Buf "mo:base/Buffer";
import BigMap "canister:BigMap";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

import TestBatch "mo:bigtest/Batch";
import TestTypes "mo:bigtest/Types";
import TestCall "mo:bigtest/service/BigMap";

actor {

  // Test "PutGet" as a BigTest program (compare to test/PutGet.mo)
  func putGetTestExp(size : Nat) : TestTypes.Exp = {
    let s = (debug_show size);
    #labell(
      "PutGet",
      ?("range of (0, " # s # ") puts, followed by the same range of assert'ed gets"),
      #block(
        [
          ("buf", #range(0, size)),
          ("_", #iterate(#varr("buf"), "i",
                         #call(#put(#varr("i"), #varr("i")))
                )),
          ("_", #iterate(#varr("buf"), "i",
                         #block(
                           [
                             ("x", #call(#get(#varr("i")))),
                             ("_", #assertt(#equal(#opt(#varr("i")), #varr("x"))))
                           ])
                )),
        ]))
  };

  // ----- Boiler-plate testing code below

  // create a big batch of smaller batches
  func newBatches(sizes : [Nat]) : TestBatch.Batch {
    let batch = TestBatch.Batch();
    for (c in sizes.vals()) {
      batch.push(putGetTestExp(c));
    };
    batch
  };

  // some defaults
  var batch : TestBatch.Batch = newBatches([0, 1, 2, 4, 8, 128]);

  public func reset(sizes : [Nat]) : async () {
    batch := newBatches(sizes)
  };

  public func extend(sizes: [Nat]) {
    for (s in sizes.vals()) {
      batch.push(putGetTestExp(s));
    };
  };

  public query func peek() : async ?TestTypes.DebugInfo {
    batch.peek()
  };

  // false => no next call, otherwise returns true
  public func doNextCall() : async Bool {
    switch (batch.nextCallRequest()) {
    case null { false };
    case (?c) {
           Debug.print "doNextCall begin";
           Debug.print ("doNextCall - call = " # (debug_show c));
           Debug.print "doNextCall - awaiting result...";
           let r = await (TestCall.awaitt(c)());
           Debug.print ("doNextCall - result = " # (debug_show r));
           Debug.print "doNextCall - saving result...";
           batch.saveResult(r);
           Debug.print "doNextCall end";
           true
         }
    }
  };

  // Bonus:
  // For testing in an open, interactive world:
  // Use this to add other tests not-yet expressed above!
  public func pushExp(e: TestTypes.Exp) {
    batch.push(e)
  };

}
