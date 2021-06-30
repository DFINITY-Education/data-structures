import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Order "mo:base/Order";

import Types "./Types";

module {

    type Iter<X, Y> = Iter.Iter<(X, Y)>;
    type List<S> = List.List<S>;
    type Order = Order.Order;
    type Tree<X, Y> = Types.Tree<X, Y>;

    type IterRep<X, Y> = List.List<{ #tree: Tree<X, Y>; #kv: (X, Y); }>;

    /// Determines whether a given Tree is a valid BST.
    /// Args:
    ///   |t|   The Tree to be validated.
    /// Returns:
    ///   A boolean representing whether |t| is a valid BST.
    public func validate<X, Y>(t: Tree<X, Y>) : Bool {
        func validateAgainstChild<X, Y>(parentKey: X, child: Tree<X, Y>, expected: Order) : Bool {
            switch (child) {
                case (#leaf(_)) { true };
                case (#node(key, _, _, _, compareFunc)) {
                    compareFunc(key, parentKey) == expected
                };
            }
        };

        switch (t) {
            case (#leaf(_)) { true };
            case (#node(parentKey, _, leftChild, rightChild, compareFunc)) {
                validateAgainstChild(parentKey, leftChild, #less)
                    and validateAgainstChild(parentKey, leftChild, #greater)
                    and validate(leftChild)
                    and validate(rightChild)
            };
        }
    };

    /// Determines whether a given Tree is a valid BST.
    /// Args:
    ///   |t|     The Tree to be searched.
    ///   |key|   The key being serched for.
    /// Returns:
    ///   The value of the node in |t| that has key=|key|.
    ///   Null if there is no such node in |t|.
    public func get<X, Y>(t: Tree<X, Y>, key: X) : ?Y {
        switch (t) {
            case (#leaf(_)) { null };
            case (#node(parentKey, parentVal, leftChild, rightChild, compareFunc)) {
                switch (compareFunc(key, parentKey)) {
                    case (#equal) { ?parentVal };
                    case (#less) { get(leftChild, key) };
                    case (#greater) { get(rightChild, key) };
                }
            };
        }
    };

    /// Adds a new node to a tree.
    /// Args:
    ///   |t|             The Tree the node is added to.
    ///   |key|           The key of the new node.
    ///   |val|           The value of the new node.
    ///   |compareFunc|   The comparison function associated with the tree.
    /// Returns:
    ///   A Tree with the correct node added.
    public func put<X, Y>(t: Tree<X, Y>, key: X, val: Y, compareFunc: (X, X) -> Order) : Tree<X, Y> {
        switch (t) {
            case (#leaf) {
                #node(key, val, #leaf, #leaf, compareFunc);
            };
            case (#node(parentKey, parentVal, leftChild, rightChild, _)) {
                let newNode = #node(key, val, #leaf, #leaf, compareFunc);
                switch (compareFunc(key, parentKey)) {
                    case (#equal) { #node(key, val, leftChild, rightChild, compareFunc) };
                    case (#less) {
                        switch (leftChild) {
                            case (#leaf) {
                                #node(parentKey, parentVal, newNode, rightChild, compareFunc)
                            };
                            case (#node(k, v, l, r, _)) {
                                #node(
                                    parentKey,
                                    parentVal,
                                    put(
                                        #node(k, v, l, r, compareFunc),
                                        key,
                                        val,
                                        compareFunc
                                    ),
                                    rightChild,
                                    compareFunc
                                )
                            };
                        };
                    };
                    case (#greater) {
                        switch (rightChild) {
                            case (#leaf) {
                                #node(parentKey, parentVal, leftChild, newNode, compareFunc)
                            };
                            case (#node(k, v, l, r, _)) {
                                #node(
                                    parentKey,
                                    parentVal,
                                    leftChild,
                                    put(
                                        #node(k, v, l, r, compareFunc),
                                        key,
                                        val,
                                        compareFunc
                                    ),
                                    compareFunc
                                )
                            };
                        };
                    };
                };
            };
        };
    };

    /// Allows for iteration through the Tree nodes
    /// Args:
    ///   |t|             The Tree being iterated through.
    ///   |traversal|     The traversal type - see Types.mo.
    /// Returns:
    ///   An Iter object that outputs (key, value) pairs upon subsequent next() method calls.
    /// Just hollow out the next() function - leave everything above that for students to have a good base to start from
    public func iter<X, Y>(t: Tree<X, Y>, traversal: Types.Traversal) : Iter<X, Y> {
        object {
            var treeIter : IterRep<X, Y> = ?(#tree(t), null);
            public func next() : ?(X, Y) {
                switch (traversal, treeIter) {
                    case (_, null) { null };
                    case (_, ?(#tree(#leaf(_)), rest)) {
                        treeIter := rest;
                        next()
                    };
                    case (_, ?(#kv(k, v), rest)) {
                        treeIter := rest;
                        ?(k, v)
                    };
                    case (#preorder, ?(#tree(#node(k, v, l, r, _)), rest)) {
                        treeIter := ?(#kv(k, v), ?(#tree(l), ?(#tree(r), rest)));
                        next()
                    };
                    case (#inorder, ?(#tree(#node(k, v, l, r, _)), rest)) {
                        treeIter := ?(#tree(l), ?(#kv(k, v), ?(#tree(r), rest)));
                        next()
                    };
                    case (#postorder, ?(#tree(#node(k, v, l, r, _)), rest)) {
                        treeIter := ?(#tree(l), ?(#tree(r), ?(#kv(k, v), rest)));
                        next()
                    };
                }
            };
        }
    };

    public func height<X, Y>(t: Tree<X, Y>) : Nat {
        switch t {
            case (#leaf(_)) { 0 };
            case (#node(_, _, l, r, _)) {
                Nat.max(height(l), height(r)) + 1
            };
        }
    };

    public func size<X, Y>(t: Tree<X, Y>) : Nat {
        switch t {
            case (#leaf(_)) { 0 };
            case (#node(_, _, l, r, _)) {
                size(l) + size(r) + 1
            };
        }
    };

};
