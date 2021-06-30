import T "Types";
import Array "mo:base/Array";
import P "mo:base/Prelude";
import Order "Order"; // TEMP
import SHA256 "mo:sha256/SHA256";
import Prim "mo:prim";
import Debug "DebugOff";
//import Debug "mo:base/Debug";
import Buf "mo:base/Buffer";
import Iter "mo:base/Iter";

// zero vs inf: the ring is initially one segment, allocated all of keyspace: [zero, inf).
module {
  type SegKey = T.SegKey;

  public func ofKey(bytes : T.Key) : SegKey {
    let hashed = SHA256.sha256(bytes);
    ?hashed;
  };

  public func zero() : SegKey =
    ?Array.tabulate<Nat8>(32, func (_) = Prim.natToNat8(0));

  public func inf() : SegKey = null;

  public func equals(x : SegKey, y : SegKey ) : Bool {
    switch (compare(x, y)) {
    case (#equal) true;
    case _ false;
    }
  };

  public func hash(x : SegKey) : Nat32 {
    let blowup : Nat8 -> Nat32 = func (x) { Prim.natToNat32(Prim.nat8ToNat(x)) };
    switch x {
      case null { P.unreachable() };
      case (?x) {
             // to do -- use all bits in the final hash, not just the first ones
             blowup(x[0]) << 24 +
               blowup(x[1]) << 16 +
               blowup(x[2]) << 8 +
               blowup(x[3])
           }
    }
  };

  public func intervalContains(interval:(SegKey, SegKey), pt:SegKey) : Bool {
    switch (compare(interval.0, pt), compare(pt, interval.1)) {
      case (#less, #less) { true };
      case _ { false };
    }
  };

  // generate an array of segment keys, spaced uniformly in keyspace
  public func uniformSegments(n:Nat) : [SegKey] {
    assert (n < 255); // to do -- handle larger cases of n
    // 0000..00, 0100..00, 0200..00, ..., ff00..00
    let dist = Prim.natToNat8(255 / n);
    let keyData : [var Nat8] = Array.init<Nat8>(32, 0);
    let segKeys = Buf.Buffer<SegKey>(n);
    for (i in Iter.range(0, n - 1)) {
      segKeys.add(?Array.freeze(keyData));
      keyData[0] += dist;
    };
    segKeys.toArray()
  };

  public func compare(x : ?[Nat8], y : ?[Nat8]) : Order.Order {
    // null means 'infinity'
    Debug.print "SegKey SegKey";
    Debug.print ("SegKey compare bytes " # (debug_show (x, y)));
    switch (x, y) {
      case (null, null) { #equal };
      case (null, _) { #greater };
      case (_, null) { #less };
      case (?x, ?y) {
        Debug.print ("SegKey compare; lens " # (debug_show (x.size(), y.size())));
        assert(x.size() == 32);
        assert(y.size() == 32);
        for (i in x.keys()) {
          if (x[i] < y[i]) return #less
          else if (x[i] > y[i]) return #greater
          else { }
        };
        return #equal
     };
    }
  };
}
