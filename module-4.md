# Module 4: Scaling Data Structures with `BigMap`

In this module, you will use Motko's `BigMap` to enable your implementation of the Bloom filter created in [Module 2](/module-2.md) to scale across Internet Computer canisters.

## Background

We briefly discussed Motoko's `BigMap` function in [Module 1](#module-1.md), which should provide you with a brief introduction to its high-level purpose and use cases. Given that Motoko canisters can only store roughly 4 GB of data, developers need a way to easily scale their data storage across multiple canisters.

We should note that Bloom filters are often used for their extreme efficiency, allowing us to store large data sets with relatively little memory. As such, the chances of creating a Bloom filter that surpasses 4 GB in the real world are slim to none. That being said, this activity gives you the toolset to understand how you can use `BigMap` to expand data structures that you have already implemented.

A `BigMap` canister instance has already been deployed for this exercise (check the `dfx.json` config for a list of all canisters deployed in a project).

## Your Task

### Code Understanding

#### `BloomFilter.mo`

Let's start by taking a look at `BigMapBloomFilter/BigMapBloomFilter.mo`. The `BigMapBloomFilter` class maintains our `BigMap`-extension of `BloomFilter`, and you should notice that much of the code in this class parallels the code in `BloomFilter/BloomFilter.mo` that we used in [Module 2](/module-2.md). Feel free to reference that module again for a more in-depth description of the `BigMapBloomFilter` implementation.

`add` and `check` are the two functions that you will implement for this module. They serve the same general purpose as the parallel functions in `BloomFilter/BloomFilter.mo`, but this time they incorporate the `BigMap` extension.

#### `Utils.mo`

The `Utils.mo` file contains several helper functions that you may find useful in completing the implementations of `add` and `check`. 

`serialize` takes in a list of booleans (corresponding to the `hashMap`) and converts it to a list of 1s and 0s of type `Nat8`. Unsurprisingly, `unserialize` performs the reverse operation. Finally, `constructWithData` creates a new `BloomFilter` with the provided `data` (the `hashMap` of a `BloomFilter`), `bitMapSize`, and `hashFuncs`. Notice that this function utilizes the `setData` function from `BloomFilter/BloomFilter.mo`. The purpose of these functions will become apparent in the specification below.

#### `Main.mo`

`Main.mo` instantiates a `BigMapBloomFilter` object with a few pre-entered parameters and provides two functions, `add` and `check`. These functions are the public interface that allow you to call `add` and `check` within the `BigMapBloomFilter` from the command line interface (for testing) or from other canisters. The only significant difference between this implementation and `BloomFilter/Main.mo` is that the two functions both require a `key` parameter. The `key` is what `BigMap` uses to index between canisters.

### Specification

**Task:** Complete the implementation of the `add` and `check ` methods in `BigMapBloomFilter.mo`.

**`add`** takes in a `key` and an `item` and adds that key, value pair to the `BigMapBloomFilter`

* Start by understanding the `BigMap` API: `put` and `get`. Their function signatures are as follows:
```
func get(key : [Nat8]) : async ?[Nat8]
```
```
func put(key : [Nat8], value : [Nat8]) : async ()
```
* Understand how the `un`/`serialize` data transformation functions from the `Utils` module can help "massage" Bloom filter data into the appropriate formats.
* Think through the similarities and differences in how to approach the implementation of `add` and `check` for `BigMapBloomFilter` and `AutoScalingBloomFilter`. Now that we receive a key as input, how do we retrieve data from `BigMap` and convert it into a format we can interact with? How do we store the updated data back into `BigMap`?
* Be sure to leverage other functions from the `Utils` module: `constructWithData`, etc. will come in handy!
* Remember to unwrap results from a BigMap query.

**`check`** takes in a `key` and an `item` and checks if that `item` is contained in any of the `BloomFilter`s

* As above, be sure to leverage functions from the `Utils` module.
* Similarly, remember to unwrap results from a BigMap query.

### Testing

As you progress through your implementation of the `BigMapBloomFilter`, you can periodically self-test your work using the command line interface (CLI) after you've built and deployed the corresponding canisters.

Inputting variant types into the CLI can be a bit unintuitive at first, so here is a quick guide to doing so. Imagine you have the following variant type:

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
