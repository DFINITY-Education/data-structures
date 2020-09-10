import Iter "mo:base/Iter";
import Buf "mo:base/Buf";
import List "mo:base/List";

import Types "Types";
import Call "Call";

//import Debug "../DebugOff";
import Debug "mo:base/Debug";

import Log "mo:base/Debug";

module {

public type State = Types.State;
public type Store = Types.Store;
public type Stack = Types.Stack;
public type Env = Types.Env;
public type Cont = Types.Cont;
public type Frame = Types.Frame;
public type Exp = Types.Exp;
public type Res = Types.Res;
public type Val = Types.Val;
public type Decls = Types.Decls;

// evaluate all stack frames, or until we reach a call (then suspend), or an error
public func evalState(state: State) : Res {
  switch (state.exp) {
    case null { assert false; loop {}};
    case (?exp) {
           switch (eval(state.store, state.env, exp)) {
             case (#ok(v)) { evalStack(state.store, state.stack, v) };
             case (#err(#callRequest(stack, call))) {
                     let s = List.append(List.reverse(stack), state.stack);
                     #err(#callRequest(s, call))
                   };
             case (#err(e)) { #err(e) };
           }
         };
  }
};

// evaluate all stack frames, or until we reach a call (then suspend), or an error
public func evalStack(store: Store, stack:Stack, v: Val) : Res {
  switch stack {
  case null { #ok(v) };
  case (?(frame, stack)) {
         switch frame {
         case (env, (#labell(name, desc))) {
                Log.print ("BigTest.Eval.evalStack - Successful test, returning value " # (debug_show v));
                Log.print ("BigTest.Eval.evalStack - name = " # name);
                Log.print ("BigTest.Eval.evalStack - desc = " # (debug_show desc));
                evalStack(store, stack, v)
              };
         case (env, (#block(x, decls))) {
                Debug.print ("BigTest.Eval.evalStack - " # x # " := " # (debug_show v));
                let env2 = Types.Env.update(env, x, v);
                switch (evalBlock(store, env2, decls)) {
                  case (#err(#callRequest(stack2, call))) {
                         #err(#callRequest(List.append(List.reverse(stack2), stack), call))
                       };
                  case (#err(e)) #err(e);
                  case (#ok(#unit)) evalStack(store, stack, #unit);
                  case _ { assert false; loop { }};
                }
              };
         case (env, (#iterate(b, i, x, body))) {
                switch (evalIterate(store, env, b, i, x, body)) {
                  case (#err(#callRequest(stack2, call))) {
                         #err(#callRequest(List.append(List.reverse(stack2), stack), call))
                       };
                  case (#err(e)) #err(e);
                  case (#ok(#unit)) evalStack(store, stack, #unit);
                  case _ { assert false; loop { }};
                }
              };
         case _ {
                // to do -- finish missing cases
                assert false; loop { }
              };
         }
       };
  }
};

// evaluate expression, or until we reach a call (then suspend), or an error
public func eval(store: Store, env: Env, exp: Exp) : Res {
  switch exp {
    case (#value v) { #ok(v) };
    case (#opt e) {
           switch (eval(store, env, e)) {
             case (#ok(v)) { #ok(#opt(v)) };
             case (#err(e)) { #err(e) };
           }
         };
    case (#call(#put(e1, e2))) {
           let r1 = eval(store, env, e1);
           let r2 = eval(store, env, e2);
           switch (r1, r2) {
           case (#ok(v1), #ok(v2)) {
                  #err(
                    #callRequest(
                      Types.Init.empStack(),
                      Call.callRequest(
                        #put(#value(v1),
                             #value(v2)))))
                };
           case (#err(e1), _) #err(e1);
           case (_, #err(e2)) #err(e2);
           }
         };
    case (#call(#get(e))) {
           let r = eval(store, env, e);
           switch r {
           case (#ok(v)) {
                  #err(
                    #callRequest(
                      Types.Init.empStack(),
                      Call.callRequest(
                        #get(#value(v))
                      )))
                };
           case (#err(e)) #err(e);
           }
         };
    case (#varr x) {
           switch (Types.Env.find(env, x)) {
             case null #err(#unboundVariable(env, x));
             case (?v) { #ok(v) };
           }
         };
  case (#iterate(buf, x, body)) {
         switch (eval(store, env, buf)) {
           case (#ok(#buf(b))) {
                  evalIterate(store, env, b, 0, x, body)
                };
           case (#ok(v)) #err(#iterateNonBuffer(v));
           case (#err(e)) #err(e);
         };
       };
  case (#labell(name, desc, e)) {
         Log.print "BigTest.Eval.evalExp - Begin labeled test:";
         Log.print ("BigTest.Eval.evalExp - name = " # name);
         Log.print ("BigTest.Eval.evalExp - desc = " # (debug_show desc));
         switch (eval(store, env, e)) {
         case (#ok(v)) { #ok(v) };
         case (#err(#callRequest(stack, call))) {
                Log.print (
                  "BigTest.Eval.evalExp - Interrupting test " # name #
                  " for call request " # (debug_show call));
                let cont : Cont = #labell(name, desc);
                let frame : Frame = (env, cont);
                #err(#callRequest(?(frame, stack), call))
              };
         case (#err(e)) { #err(e) };
         }
       };
  case (#arms(es)) {
         // to do -- sort of like iterate
         assert false; loop { }
       };
  case (#buf(es)) {
         let buf = Buf.Buf<Val>(0);
         for (e in es.vals()) {
           switch (eval(store, env, e)) {
             case (#err(e)) return #err(e);
             case (#ok(v)) buf.add(v);
           }
         };
         let b = store.bufs.size();
         store.bufs.add(buf);
         #ok(#buf(b))
       };
  case (#assertt(e)) {
         switch (eval(store, env, e)) {
           case (#ok(#bool(b))) {
                  // in verbose mode, print all true assertions?
                  if b { #ok(#unit) } else {
                    // to do -- print error in log, but continue?
                    assert false; loop { }
                  }
                };
           case (#ok(v)) #err(#assertNonBool(env, e, v));
           case (#err(e)) #err(e);
         }
       };
  case (#equiv(e1, e2)) {
         let r1 = eval(store, env, e1);
         let r2 = eval(store, env, e2);
         switch (r1, r2) {
           case (#ok(v1), #ok(v2)) {
                  if (Types.Val.equiv(store, v1, v2))
                  #ok(#bool(true))
                  else
                  #ok(#bool(false))
                };
           case (#err(e1), _) #err(e1);
           case (_, #err(e2)) #err(e2);
         }
       };
  case (#equal(e1, e2)) {
         let r1 = eval(store, env, e1);
         let r2 = eval(store, env, e2);
         switch (r1, r2) {
           case (#ok(v1), #ok(v2)) {
                  if (Types.Val.equal(v1, v2))
                  #ok(#bool(true))
                  else
                  #ok(#bool(false))
                };
           case (#err(e1), _) #err(e1);
           case (_, #err(e2)) #err(e2);
         }
       };
  case (#block decls) {
         evalBlock(store, env, List.fromArray(decls))
       };
  case (#range (n, m)) {
         let r = Iter.range(n, m);
         let buf = Buf.Buf<Val>(0);
         for (i in r) {
           buf.add(#nat(i))
         };
         let b = store.bufs.size();
         store.bufs.add(buf);
         #ok(#buf(b))
       };
  }
};

public func evalIterate(store:Store, env:Env, b:Nat, pos:Nat, x:Text, body:Exp) : Res {
  let buf = store.bufs.get(b);
  Debug.print ("BigTest.Eval.evalIterate begin " # (debug_show (b, pos, x, body)));
  for (i in Iter.range(pos, buf.size() - 1)) {
    let v = buf.get(i);
    let env2 = Types.Env.update(env, x, v);
    switch (eval(store, env2, body)) {
    case (#err(#callRequest(stack, call))) {
           if (i < buf.size() - 1) {
             Debug.print "BigTest.Eval.evalIterate interrupted, saving unfinished iterations";
             let cont = #iterate(b, i + 1, x, body);
             let s = ?((env2, cont), stack);
             return #err(#callRequest(s, call))
           } else {
             Debug.print "BigTest.Eval.evalIterate interrupted on last iteration";
             return #err(#callRequest(stack, call))
           }
         };
    case (#err(e)) { return #err(e) };
    case (#ok(_v)) { };
    }
  };
  Debug.print "BigTest.Eval.evalIterate end";
  #ok(#unit)
};

public func evalBlock(store: Store, env: Env, decls: Decls) : Res {
  var env2 = env;
  var decls2 = decls;
  loop {
    switch decls2 {
    case null { return #ok(#unit) };
    case (?((x, e), rest)) {
           decls2 := rest;
           switch (eval(store, env2, e)) {
           case (#err(#callRequest(stack, call))) {
                  // save our place, for later:
                  let cont = #block(x, rest);
                  let frame = (env2, cont);
                  return #err(#callRequest(?(frame, stack), call))
                };
           case (#err(e)) {
                  return #err(e)
                };
           case (#ok(v)) {
                  Debug.print ("BigTest.Eval.evalBlock - " # x # " := " # (debug_show v));
                  env2 := Types.Env.update(env2, x, v)
                };
           };
         };
    }
  };
  #ok(#unit)
};

} // module
