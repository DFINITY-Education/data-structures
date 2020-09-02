import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

import BST "./BST";
import Types "./Types";

actor {

  type Iter<X, Y> = Iter.Iter<(X, Y)>;
  type Tree<X, Y> = Types.Tree<X, Y>;

  var bst: Tree<Nat, Nat> = #leaf;
  var bstIterator = BST.iter<Nat, Nat>(bst, #inorder);
  let compareFunc = Nat.compare;

  public func bstValidate() : async Bool {
    BST.validate(bst)
  };

  public func bstget(key: Nat) : async ?Nat {
    BST.get(bst, key)
  };

  public func bstPut(key: Nat, value: Nat) {
    bst := BST.put<Nat, Nat>(bst, key, value, compareFunc);
  };

  public func bstIter(traversal: Types.Traversal) {
    bstIterator := BST.iter<Nat, Nat>(bst, traversal);
  };

  public func bstNext() : async ?(Nat, Nat) {
    bstIterator.next()
  };

  public func bstHeight() : async Nat {
    BST.height<Nat, Nat>(bst)
  };

  public func bstSize() : async Nat {
    BST.size<Nat, Nat>(bst)
  };

  public func bstReset() {
    bst := #leaf;
    bstIterator := BST.iter<Nat, Nat>(bst, #inorder);
  }

};