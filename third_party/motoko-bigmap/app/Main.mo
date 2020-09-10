import BigMap "../src/BigMap";
import Segment "../src/Segment";
import SegKey "../src/SegKey";
import T "../src/Types";
import Debug "mo:base/Debug";

actor {
  private /*stable*/ var segCount = 1;
  private /*flexible*/ var bm = BigMap.BigMap(segCount);

  public func init(n : Nat) {
    Debug.print "BigMap init begin";
    Debug.print (" - Old segment count = " # (debug_show segCount));
    segCount := n;
    Debug.print (" - New segment count = " # (debug_show segCount));
    bm := BigMap.BigMap(segCount);
    Debug.print "BigMap init end";
  };

  // return whether an init was called or not
  public func initNext(id : Text) : async Bool {
    let c = actor (id) : actor {
      init : T.SegmentInit -> async ();
      put : (T.SegKey, T.Val) -> async ();
      get : query T.SegKey -> async ?T.Val;
    };
    switch (bm.initNext(c)) {
      case null { false };
      case (?f) { await f(); true };
    };
  };

  public query func isReady() : async Bool {
    bm.isReady()
  };

  public query func getReady() : async [T.CanisterInfo] {
    bm.getReady()
  };

  public func get(key : [Word8]) : async ?[Word8] {
    Debug.print "BigMap get begin";
    if (not (bm.isReady())) {
      Debug.print "Error: Not ready.";
      assert false; loop { }
    } else {
      assert bm.isReady();
      let k = SegKey.ofKey(key);
      let c = bm.getCanister(k);
      let v = await (c.get(k));
      Debug.print "BigMap get end";
      v
    }
  };

  public func put(key : [Word8], value : [Word8]) : async () {
    Debug.print "BigMap put begin";
    if (not (bm.isReady())) {
      Debug.print "Error: Not ready.";
      assert false
    } else {
      assert bm.isReady();
      let k = SegKey.ofKey(key);
      let c = bm.getCanister(k);
      await (c.put(k, value));
      Debug.print "BigMap put end";
    }
  };
};
