# Module 4: Scaling Data Structures with `BigMap`

In this module, you will use Motko's `BigMap` to enable your implementation of the Bloom filter created in [Module 2](/module-2.md) to scale across Internet Computer canisters.

## Background

We briefly discussed Motoko's `BigMap` function in [Module 1](#module-1.md), which should provide you with a brief introduction to its high-level purpose and use cases. Given that Motoko canisters can only store roughly 4 GB of data, developers need a way to easily scale their data storage across multiple canisters. 

We should note that Bloom filters are often used for their extreme efficiency, allowing us to store large data sets with relatively little memory. As such, the chances of creating a Bloom filter that surpasses 4 GB in the real world are slim to none. That being said, this activity gives you the toolset to understand how you can use `BigMap` to expand data structures that you have already implemented. 

## Your Task

### Code Understanding

#### `BloomFilter.mo`

Let's start by taking a look at `BigMap/BloomFilter.mo`. The `BigMapBloomFilter` class maintains our `BigMap` extension of `BloomFilter`, and you should notice that much of the code in this class parallels the code in `BloomFilter/BloomFilter.mo` that we used in [Module 2](/module-2.md). Feel free to reference that module again for a more in-depth description of the `BloomFilter` implementation.

`add` and `check` are the two functions that you will implement for this module. They server the same general purpose as the parallel functions in `BloomFilter/BloomFilter.mo`, but this time they incorporate the `BigMap` extension.

#### `Utils.mo`

The `Utils.mo` file contains several helper functions that you may find useful in completing the implementations of `add` and `check`. 

`hash` takes in a list of booleans (corresponding to the `hashMap`) and hashes this to a list of 1s and 0s of type `Word8`, and `unhash` performs the reverse operation. The functionality of `convertNat8toWord8` and `convertWord8toNat8` is summarized by their name. Finally, `constructWithData` creates a new `BloomFilter` with the provided `data` (the `hashMap` of a `BloomFilter`), `bitMapSize`, and `hashFuncs`. Notice that this function utilizes the `setData` function from `BloomFilter/BloomFilter.mo`. The purpose of these functions will become apparent in the specification below.

#### `Main.mo`

`Main.mo` instantiates a `BigMapBloomFilter` object with a few pre-entered parameters and provides two functions, `add` and `check`. These functions are the public interface that allow you to call `add` and `check` within the `BigMapBloomFilter` from the command line interface (for testing) or from other canisters. The only significant different between this implementation and `BloomFilter/Main.mo` is that the two functions both require a `key` parameter. The `key` is what `BigMap` uses to index between canisters.

### Specification

**Task:** Complete the implementation of the `add` and `check ` methods in `BloomFilter.mo`.

**`add`** takes in a `key` and a `item` and adds that key, value pair to the `BloomFilter`

* 

**`check`** takes in a `key` and an `item` and checks if that `item` is contained in any of the `BloomFilters`

* 

### Testing

As you progress through your implementation of the `BigMapBloomFilter`, you can periodically self-test your work using the command line interface (CLI) after you've built and deployed the corresponding canisters.

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







