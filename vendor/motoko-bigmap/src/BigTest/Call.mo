import BigMap "canister:BigMap";
import Prim "mo:prim";

//import Debug "../DebugOff";
import Debug "mo:base/Debug";

import Types "Types";

/** isolates logic specific to calling BigMap's service interface
    from within the (more general) DSL expression language. */
module {

  public func awaitt(c: Types.CallReq) : () -> async Types.Res {
    func () : async Types.Res = async {
      Debug.print ("BigTest.Call.awaitt " # (debug_show c));
      switch c {
      case (#put(k, v)) {
             await BigMap.put(k, v);
             #ok(#unit)
           };
      case (#get(k)) {
             let res = await BigMap.get(k);
             switch res {
               case null { #ok(#nulll) };
               case (?r) { #ok(#opt(fromNat8s(r))) };
             }
           };
      }
    }
  };

  // convert DSL-level arguments into Candid-level arguments
  public func callRequest(c: Types.CallExp) : Types.CallReq {
    switch c {
    case (#put(#value(k), #value(v))) {
           let wsk = intoNat8s(k);
           let wsv = intoNat8s(v);
           #put(wsk, wsv)
         };
    case (#get(#value(k))) {
           let wsk = intoNat8s(k);
           #get(wsk)
         };
    case _ {
           assert false; loop { }
         }
    }
  };

  public func intoNat8s(v:Types.Val) : [Nat8] {
    switch v {
    case (#nat(n)) { [Prim.natToNat8(n)] };
    case (_) {
           // todo -- handle more cases
           assert false; loop { }
         };
    }
  };

  public func fromNat8s(ws:[Nat8]) : Types.Val {
    assert (ws.size() == 1);
    #nat(Prim.nat8ToNat(ws[0]))
  };

}
