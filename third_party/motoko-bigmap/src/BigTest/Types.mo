import List "mo:base/List";
import AssocList "mo:base/AssocList";
import Result "mo:base/Result";
import Buf "mo:base/Buf";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

module {

// calls to test: Specialized to BigMap actor (for now).
public type CallExp = {
  #put: (Exp, Exp);
  #get: Exp;
};

// when well-formed, each call expression resolves to call request.
public type CallReq = {
  #put: ([Nat8], [Nat8]);
  #get: [Nat8];
};

// ----- The rest of this module is generic, and not specific to BigMap's API.

// express the "high-level" testing logic with a Motoko DSL;
// expressions relate multiple Calls, and form tests around them.
public type Exp = {
  #call: CallExp;
  #arms: [Exp]; // one assert(false) permitted per "arm"
  #labell: (Text, ?Text, Exp); // (label, description, body) for reports, docs, and log output
  #equal: (Exp, Exp); // considers buffer ids, and ignores content
  #equiv: (Exp, Exp); // ignores buffer ids, and considers content
  #assertt: Exp; // assert false stops execution in this "arm"
  #varr: Text; // resolve vars introduced by #block
  #buf: [Exp]; // allocate a new buffer
  #range: (Nat, Nat); // buffer all numbers in given range
  #iterate: (Exp, Text, Exp); // (buffer, var, body)
  #block: [Decl];
  #opt: Exp;
  #value: Val;
};

public type Decl = (Text, Exp);

// lists are more inductive, and more useful for the stack rep
public type Decls = List.List<Decl>;

// In Exp, we use Motoko keywords as variant labels by adding an extra "last letter", which avoids Motoko lexing/parsing issues (e.g., #labell).  Rationale: Minimal effect on readability.

// "high-level" values in/out of the calls to test, and as helper data
public type Val = {
  #unit;
  #nulll;
  #bool: Bool;
  #nat: Nat;
  #text: Text; // remove? (currently unused)
  #buf: Nat;
  #opt: Val;
};

// Halt for call requests, assertion failures, other errors
public type Halt = {
  #callRequest: (Stack, CallReq);
  #assertFalse: Exp;
  #unboundVariable: (Env, Text);
  #iterateNonBuffer: Val;
  #assertNonBool: (Env, Exp, Val);
};

public type Env = AssocList.AssocList<Text, Val>;

public type Res = Result.Result<Val, Halt>;

public type Store = {
  bufs: Buf.Buf<Buf.Buf<Val>>;
};

// remaining work of an Exp to perform later, after a Call
public type Cont = {
  #labell: (Text, ?Text);
  #block: (Text, List.List<(Text, Exp)>);
  #iterate: (Nat, Nat, Text, Exp); // (buf, key, var, body)
  #arms: [Exp];
};

public type Frame = (Env, Cont);
public type Stack = List.List<Frame>;

// Info for inspecting expression evaluation via `peek`
public type DebugInfo = (Stack, Env, ?Exp);

public type State = {
  store: Store;
  var stack: Stack;
  var env: Env;
  var exp: ?Exp;
};

public module Init {
public func empStore() : Store {
  {
    bufs = Buf.Buf<Buf.Buf<Val>>(0);
  }
};

public func empStack() : Stack {
  List.nil<Frame>()
};

public func empEnv() : Env {
  List.nil<(Text, Val)>()
};

public func empState(_exp: ?Exp) : State {
  {
    store = empStore();
    var stack = empStack();
    var env   = empEnv();
    var exp   = _exp;
  }
};
};

public module Env {
public func update(env: Env, x:Text, v:Val) : Env {
  // remove shadowed variable, if any --- a simple form of GC in the DSL evaluation logic
  let (env2, _) = AssocList.replace<Text, Val>(env, x, func (x:Text, y:Text) : Bool { x == y }, null);
  ?((x, v), env2)
};
public func find(env: Env, x:Text) : ?Val {
  AssocList.find(env, x, func (x:Text, y:Text) : Bool { x == y })
};
};

public module Val {
public func equiv(store:Store, v1: Val, v2: Val) : Bool {
  switch (v1, v2) {
    case (#bool(b1), #bool(b2)) b1 == b2;
    case (#nat(n1), #nat(n2)) n1 == n2;
    case (#text(t1), #text(t2)) t1 == t2;
    case (#opt(v1), #opt(v2)) equiv(store, v1, v2);
    case (#buf(b1), #buf(b2)) {
           if (b1 == b2) {
             true
           } else {
             let buf1 = store.bufs.get(b1);
             let buf2 = store.bufs.get(b2);
             if (buf1.size() != buf2.size())
               false
             else {
               if (buf1.size() == 0) { true } else {
                 for (i in Iter.range(0, buf1.size() - 1)) {
                   let v1 = buf1.get(i);
                   let v2 = buf2.get(i);
                   if (equiv(store, v1, v2)) {
                     // continue
                   } else {
                     return false
                   }
                 };
                 true
               }
             }
           }
         };
    case (_, _) false;
  }
};
public func equal(v1: Val, v2: Val) : Bool {
  switch (v1, v2) {
    case (#bool(b1), #bool(b2)) b1 == b2;
    case (#nat(n1), #nat(n2)) n1 == n2;
    case (#text(t1), #text(t2)) t1 == t2;
    case (#buf(b1), #buf(b2)) b1 == b2;
    case (#opt(v1), #opt(v2)) equal(v1, v2);
    case (_, _) false;
  };
};
};
}
