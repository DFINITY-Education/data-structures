import Eval "Eval";
import Types "Types";
import Q "mo:base/Deque";
import List "mo:base/List";

//import Debug "../DebugOff";
import Debug "mo:base/Debug";

module {
public class Batch() {

  public type State = Types.State;

  var states : Q.Deque<State> = (null, null);

  public func push(e: Types.Exp) : () {
    let st = Types.Init.empState(?e);
    states := Q.pushBack<State>(states, st);
  };

  public func peek() : ?Types.DebugInfo {
    let s : ?State = Q.peekFront<State>(states);
    switch s {
      case null null;
      case (?s) ?(s.stack, s.env, s.exp);
    }
  };

  public func saveResult(res: Types.Res) {
      let state : State =
        switch (Q.peekFront<State>(states)) {
         case null { assert false; loop { } };
         case (?s) { s };
        };
      switch (res, state.exp) {
        case (#ok(v), null) {
               state.exp := ?#value(v)
             };
        case (#err(e), _) {
               assert false; loop { }
             };
        case (_, ?exp) {
               assert false; loop { }
             }
      };
  };

  public func nextCallRequest() : ?Types.CallReq {
    loop {
      let state : State =
        switch (Q.peekFront<State>(states)) {
         case null { return null }; // end loop
         case (?s) { s };
        };
      Debug.print ("BigTest.Batch.nextCallRequest - state.stack = " # (debug_show state.stack));
      Debug.print ("BigTest.Batch.nextCallRequest - state.env = " # (debug_show state.env));
      Debug.print ("BigTest.Batch.nextCallRequest - state.exp = " # (debug_show state.exp));
      Debug.print ("BigTest.Batch.nextCallRequest - begin evaluation ...");
      let r = Eval.evalState(state);
      Debug.print ("BigTest.Batch.nextCallRequest - end evaluation.");
      Debug.print ("BigTest.Batch.nextCallRequest - result=" # (debug_show r));
      switch r {
      case (#ok(v)) {

             Debug.print ("Batch.nextCallRequest - postEval - result=" # (debug_show r));
             states := Q.popFront<State>(states);
           };
      case (#err(#callRequest(stack, call))) {
             state.stack := stack;
             state.env := Types.Init.empEnv();
             state.exp := null;
             return ?call // end loop
           };
      case (#err(e)) {
             // to do -- report errror
             // continue?
             assert false; loop { }
           }
      };
    };
  }
}
}
