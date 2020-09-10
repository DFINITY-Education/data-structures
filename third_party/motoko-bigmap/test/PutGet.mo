import Prim "mo:prim";
import Buf "mo:base/Buf";
import BigMap "canister:BigMap";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

actor {
      public func go(count : Nat) : async () {

        // Cannot use Word8 because Candid type mismatch
        let buf = Buf.Buf<[Nat8]>(count);
        for (i in Iter.range(0, count - 1)) {
          let x : [Nat8] = [Prim.natToNat8(i)];
          buf.add(x)
        };

        Debug.print "Test: Doing puts...";
        for (i in buf.vals()) {
          Debug.print ("Test put key " # (debug_show i) # "...");
          await BigMap.put(i, i);
          Debug.print ("Test put key " # (debug_show i) # ": Done.")
        };

        Debug.print "Test: Doing gets...";
        for (i in buf.vals()) {
          Debug.print ("Test get key " # (debug_show i) # "...");
          let j = await BigMap.get(i);
          switch j {
            case null { assert false };
            case (?j) {
                   assert (j[0] == i[0]);
                 };
          };
          Debug.print ("Test put key " # (debug_show i) # ": Done.");
        };

        Debug.print "Test: Success."
      };
}
