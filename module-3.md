# Module 3: Pure Data Structures: Binary Search Trees

In this module, you will implement a binary search tree, a pure data structure that allows you to efficiently store and search sortable items.

## Background

We briefly discussed **Binary Search Trees** (BST) in [Module 1](/module-1.md#binary-search-tree), which should provide a helpful (and necessary) foundation for this Module. Please re-read that section before continuing.

## Your Task

In this exercise, you will implement a binary search tree like the one described above. This data structure will be built entirely using pure, functional programing paradigms, unlike the object-oriented Bloom filter described in [Module 2](/module-2.md).

### Code Understanding

#### `Types.mo`

Let's start by looking at `Types.mo`. Here we've defined a `Tree` type, which can either be a `#node` or `#leaf`. This is the type that every element in your BST will be. Each `#node ` stores 5 values: a  `key`, `value`, `l`, `r`, and `compareFunc`:

* `key` is the value that the BST is sorted by. Therefore, all elements to the left of a `#node` should have a smaller key while all elements to the right of a `#node` should have a larger key.
* `value` is the actual value that's stored in a given element within your BST. Whereas the `key` is used solely to position the `#node` correctly amongst other `nodes`, the `value` is the "valuable" item that you want to store.
* `l` contains the `Tree` to the left of this given `node`
* `r` contains the `Tree` to the right of this given `node`
* `compareFunc` contains the function that will be used to compare `key`s and sort `nodes`. Every `node` in the tree will have an identical `compareFunc`. The reason for this, as opposed to simply storing the function somewhere else, is that we're using a pure programming style that doesn't contain mutable state. As a result, each node must "carry around" its `compareFunc`. An example of a comparison function is 

A `Tree` can also be a `#leaf`, which is essentially a `NULL` value in that it contains no useful information - it's just a placeholder. `#leaf`s will only exist at the bottom of the tree.

We will get to the `Traversal` type later once we've reviewed more code, but suffice to say that it can be either a `preorder`, `postorder`, or `inorder`. 

As is the case in [Module 2](/module-2.md#code-understanding)'s `BloomFilter`, the `Tree` type takes advantage of **generic types**, represented by `X` and `Y`, which allows the BST implementation to remain type agnostic. More specifically, this means that the `Tree` and its related functions don't care if the items entered into it are of type `Text`, `Nat`, `Int`, etc. When you create a new `BST`, you specify the two types that the `BST` will handle. In this case, `X` represents the type for `key`s while `Y` represents the type for `value`s. All subsequent keys and values must match these two types, respectively. See `Main.mo` for an example of how one fills in these generic types with more specific ones!

#### `BST.mo`  

In `BST.mo` we provide the actual implementation for our BST. Skip the `IterRep` type for now and turn your attention to `validate`. `validate` takes a `Tree` as an argument and returns a boolean indicating whether the given `Tree` is a valid BST - that is, it checks whether all of the left child nodes have `key`s less than their parent nodes and whether the right child nodes are greater. This function recursively checks the entire `Tree` using the helper function `validateAgainstChild`. Go though line by line until you fully understand this function - its general structure and recursive nature will help you think about how you can implement the other functions.

The rest of the functions are either simple (`height` and `size`) or ones that you will implement yourself. 

#### `Main.mo`

`Main.mo` just sets up a `BST` and provides a variety of functions that you can use to test your implementation "on the go" using the command-line interface.

### Specification

**Task:** Complete the implementation of `get`, `put`, and `iter` in `BST.mo`

**`get`** takes two arguments, `t` (the tree) and `key`, and returns the `value` of the `#node` in tree `t` with the given `key`

* Start by thinking about the two cases that exist for a `Tree` type. Which case indicates that you've reached the end of the tree without finding the node? If this happens, you should return `null` because the tree doesn't contain a `node` with this `key`.
* For a given `#node`, make sure to search the correct side of the tree depending on the output of applying `compareFunc` to `key` and the key of the current node being searched.

**`put`** takes a Tree type, `t`, as well as the `key`, `val`, and `compareFunc` corresponding to a new `#node` that you want to insert into the BST and returns the new Tree with this `#node` added in the correct location.

* If `t` is just a `#leaf`, then the new `#node` you add will be the only node in the Tree
* If `t ` is itself a `#node`, you must compare the given `key` to the `key` of that `#node` using the provided `compareFunc`. This is where the real thinking starts - you must place the new node into the correct position within the tree!
  * If the given `key` is equal to the node's key, then you should replace that node with the new node (remember to keep its left and right children, however).
  * If the given `key` is less than or greater than the node's key, then you must check the corresponding child (left or right depending on `compareFunc`'s result). Think about how you must handle the case in which the child is a `#leaf` vs the case where the child is a `#node` (one case will require calling `put` again).

**`iter`** takes two arguments, `t` (the tree) and `traversal` (a variant type indicating instructions for how to traverse the tree), and returns an `Iter` object that allows you to iterate through the tree in a specified order.

BSTs, unlike some linear data structures, can be traversed in several different ways. The three main ways are:

* **Inorder** traverses the tree in the following order: left child, root node, and right child

* **Preorder** traverses starting with the root node, then left child, then right child

* **Postorder** traverses the left child, then the right child, and then the root node

<div style="text-align:center"><img src="images/Binary_search_tree.svg" /></div>

Given the above tree, here's how each of these orders would traverse it:

* **Inorder:** 1, 3, 4, 6, 7, 8, 10, 13, 14
  * Just think of the following algorithm:
    1. Traverse the left subtree
    2. Visit the root
    3. Traverse the right subtree
* **Preorder:** 8, 3, 1, 6, 4, 7, 10, 14, 13
  * Use the following algorithm:
    1. Visit the root
    2. Traverse the left subtree
    3. Traverse the right subtree
* **Postorder:** 1, 4, 7, 6, 3, 13, 14, 10, 8
  * Use the following algorithm:
    1. Traverse the left subtree
    2. Traverse the right subtree
    3. Visit the root

Feel free to read more about this topic [here](https://www.geeksforgeeks.org/tree-traversals-inorder-preorder-and-postorder/). As we previously saw in `Main.mo`, the `Traversal` type has three variants: `#preorder`, `#postorder`, `#inorder` corresponding to the three aforementioned traversal strategies. 

**`iter` implementation details:**

* The `iter` function returns an object of type `Iter` ([Motoko SDK page](https://sdk.dfinity.org/docs/base-libraries/iter)) that can be iterated though by calling a `next` function.
* This object maintains an internal state, a `treeIter` of type `IterRep`, and therefore isn't pure. `treeIter` is a variant type that can either be a `#tree` or `#kv`, representing a `Tree` and key/value pair respectively. See the `IterRep` type definition at the top of the `BST.mo` file.
* Using the object returned from `iter`, you should be able to call the `next()` function (see `bstNext()` in `Main.mo` for an example of this) to iterate one step through the Tree and return the next (key, value) pair.

**Hints:**

* Take a look though `Main.mo` if you're still having trouble understanding how all the pieces of the BST relate. This can get a bit abstract, so it's helpful to see the concrete implementation of our BST using `Nat`s.
* Get familiar with `case` and `switch ` statements, because you'll be using them (sometimes multiple times) in all the functions you implement!
* Each of the three function you're implementing, `get`, `put`, and `iter`, are independent from each other and increase in difficulty. Start with `get` and then move through `put` and `iter`. If, however, you can't complete one function, you can still implement the others and get a partially functioning BST.

### Testing

As you progress through your implementation of the BST, you can periodically self-test your work using the command line interface (CLI) after you've built and deployed the corresponding canisters.

Inputing variant types into the CLI can be a bit unintuitive at first, so here is a quick guide to doing so. Image you have the following variant type:

```
type Custom = {
  #first;
  #second;
  #third;
}
```

and a method:

```
// canister: main
actor {
  func Foo(arg1: Custom) {...};
}
```

This is how you call it via the CLI:

```
dfx canister call main Foo '(variant { first })'
```

Using this method, you should be able to run some basic tests on your implementation to aid in debugging.

**----TO BE IMPLEMENTED----**