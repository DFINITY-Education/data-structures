# Module 2: Object-Oriented Data Structure: Bloom Filters

In this Module, you will implement a bloom filter that allows users to determine if an item is present in a given set.

## Background

A **Bloom filter** is a probabilistic data structure designed to indicate, with high efficiency and low memory, if an element is contained in a set. It's **probabilistic** because although it can tell you with certainty that an element is not in the data structure, it can only tell you that an element *may be* in contained the structure. In other words, false negative results (indicating the element doesn't exist in the set when it actually does) won't occur, but false positive results (indicating the element exists when it doesn't) are possible. 

Such a data structure is especially useful in instances where we care more about ensuring that an element is definitely not in a set. For instance, when registering a new username, many services aim to quickly indicate whether a given name is already taken.  The cost of a false positive - indicating that a username is already taken when it is actually available - isn't high, so this tradeoff for increased efficiency is worthwhile.

Bloom filters use a **bitmap** as the base data structure. A bitmap is simply an array where each index contains either a 0 or a 1. The filter takes in the value that's being entered into the data structure, hashes it to multiple indices (ranging from 0 to the length - 1 of the bitmap) using several different hash functions, and stores a 1 at that particular index. The beauty of a bloom filter - and the aspect that makes it so space-efficient - is the fact that we don't need to actually store the given element in our set. We simply hash the element, go to the location in our bitmap that is hashes to, and insert a 1 into that spot (or multiple spots if using multiple hash functions).

**Example bitmap with values initialized to 0:**

| 0    | 0    | 0    | 0    | 0    | 0    | 0    | 0    | 0    | 0    |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 0    | 1    | 2    | 3    | 4    | 5    | 6    | 7    | 8    | 9    |

To test for membership in the set, the program hashes the value being searched using the same aforementioned hash functions. If the resulting values are not in the bitmap, then you know that the element is *not* in the set. If the values are in the bitmap, then all you can conclude is that the element *might be* in the set. You cannot determine if the item exists with certainly because there could be other combinations of different hashed values that overlap with the same bits. Naturally, as you enter more elements into data structure, the bitmap fills up and the probability of producing a false positive increases. [This interactive site](https://llimllib.github.io/bloomfilter-tutorial/) provides a great visual explanation of the mechanics behind bloom filters. 

## Your Task

In this exercise, you will implement a Bloom filter like the one described above. This data structure, built using object-oriented principles, will enable you to add elements to the structure and check if they are contained in the filter.

### Code Understanding

Let's begin by taking a look at `BloomFilter.mo`. You'll see the `BloomFilter` class, which accepts two parameters: a `capacity` and `errorRate`. The `capacity` represents the number of elements you want the bitmap to store **-----UPDATE-----** and the `errorRate` is the max false-positive rate the Bloom filter should allow. It will auto-scale to maintain a consistent error rate. 

The first several lines of the `BloomFilter` class setup the optimal number (and size of) the slots in the `bitMap`, implemented as an `Array` of booleans initialized to `false`. `hashFuncs` contains all of the hash functions that will be used (the number of which also influences the false-positive error rate).

The `BloomFilter` takes advantage of **generic types**, represented by `S`, which allows the BloomFilter implementation to remain type agnostic. More specifically, this means that the `BloomFilter` and its related methods don't care if the items entered into it are of type `Text`, `Nat`, `Int`, etc. When you instantiate a new `BloomFilter` object, you specify a type that the `BloomFilter` will handle. All subsequent items must be of this same type.

`Main.mo` just sets up a `BloomFilter` and provides two functions, `bfAdd` and `bfCheck`, that you can use to test your implementation "on the go" using the command-line interface. Notice that these methods provide a specific type, `Nat`, that this specific instantiation of the `BloomFilter` will use.

### Specification

**Task:** Complete the implementation of the `add` and `check ` methods in `BloomFilter.mo`.

`add` simply adds an element to the `bitMap`

* `add` takes one argument, `item`, representing the item it be added to the Bloom Filter, and returns nothing.
* Remember that there will likely be more than one hash function stored in `hashFuncs`. You must apply each function in `hashFuncs` to the `item`, updating the boolean at the corresponding index of `bitMap` accordingly.

`check` determines if the element is in the `bitMap`

* `check` also takes one argument, `item`, representing the item it be added to the Bloom Filter, and returns `true` if it is contained and `false` otherwise. Remember that a `true` result isn't definitive - there is a chance of returning a false positive.
* You must again apply each function in `hashFuncs` to `item`. `check` returns `true` if and only if none of the resulting hashes indicate the existence of `item` in the Bloom filter.

*Hint:* Both `add` and `check` only require 3-4 lines of code to implement fully - most of this is practice understanding the inner workings of a Bloom filter and Motoko syntax. 

### Testing

As you progress through your implementation of the Bloom filter, you can periodically self-test your work using the command line interface (CLI) after you've built and deployed the corresponding canisters.

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
// canister:main
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