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

#### `BloomFilter.mo`

Let's begin by taking a look at `BloomFilter.mo`. You'll see two classes: `AutoScalingBloomFilter` and `BloomFilter`. We mentioned previously how the false-positive rate in Bloom filters increases as you store more elements in them. To enable our Bloom filter to maintain a consistent error rate, we will store a list of Bloom filters, where a new Bloom filter is created when an old filter reaches its maximum tolerated false-positive rate. `AutoScalingBloomFilter` manages our list of Bloom filters, deploys new Bloom filters, and searches through the list of filters when a user checks for membership. `BloomFilter` is the class used to create each individual Bloom filter - this is the part that you'll be finishing the implementation for.

The `AutoScalingBloomFilter` class accepts three parameters: a `capacity`, an `errorRate`, and `hashFuncs`. The `capacity` represents the number of elements you want the bitmap to store and the `errorRate` is the max false-positive rate the Bloom filter should allow. `hashFuncs` is a list of the hash functions used for all Bloom filters.

The first several lines of the `AutoScalingBloomFilter` class set up the optimal number (and size of) the slots in `BloomFilter`'s `bitMap`. `filters` maintains a list of all the Bloom filters, and `hashFuncs` contains all of the hash functions that will be used (the number of which also influences the false-positive error rate).

The `add` function adds an `item` to our data structure; this is where the auto-scaling occurs. If a given `BloomFilter` has reached its capacity, a new one is created with the `item` and appended to the list. Notice that we call `BloomFilter`'s own `add` function to add an `item` to that specific `BloomFilter`.

`check` runs though all of the Bloom filters in `filters` and calls each of their `check` class methods.

The `BloomFilter` class accepts two parameters: `bitMapSize` and `hashFuncs`. The `bitMapSize` is the size of our bitmap, as determined by the math in `AutoScalingBloomFilter`. You can see it used in creating our `bitMap`, which is implemented as an `Array` of booleans initialized to `false`. `BloomFilter` has no notion of `capacity` or `errorRate` - the `AutoScalingBloomFilter` class is responsible for managing those factors.

The `BloomFilter` takes advantage of **generic types**, represented by `S`, which allows the BloomFilter implementation to remain type agnostic. More specifically, this means that the `BloomFilter` and its related methods don't care if the items entered into it are of type `Text`, `Nat`, `Int`, etc. When you instantiate a new `BloomFilter` object, you specify a type that the `BloomFilter` will handle. All subsequent items must be of this same type.

#### `Main.mo`

`Main.mo` just sets up a `BloomFilter` and provides two functions, `bfAdd` and `bfCheck`, that you can use to test your implementation "on the go" using the command-line interface. Notice that these methods provide a specific type, `Nat`, that this specific instantiation of the `BloomFilter` will use.

### Specification

**Task:** Complete the implementation of the `add` and `check ` methods in `BloomFilter.mo`.

**`add`** simply adds an element to the `bitMap`

* `add` takes one argument, `item`, representing the item it be added to the Bloom Filter, and returns nothing.
* Remember that there will likely be more than one hash function stored in `hashFuncs`. You must apply each function in `hashFuncs` to the `item`, updating the boolean at the corresponding index of `bitMap` accordingly.

**`check`** determines if the element is in the `bitMap`

* `check` also takes one argument, `item`, representing the item to be checked for presence in the Bloom Filter, and returns `true` if it is contained and `false` otherwise. Remember that a `true` result isn't definitive - there is a chance of returning a false positive.
* You must again apply each function in `hashFuncs` to `item`. `check` returns `true` if and only if every of the resulting hashes indicate the existence of `item` in the Bloom filter.

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
