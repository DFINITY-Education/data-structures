import Hash "mo:base/Hash";

import BloomFilter "./BloomFilter";

actor {

  var bloomFilter = BloomFilter.BigMapBloomFilter<Nat>(0, 0.001, Hash.hash);

  public func add(key: Word8, item: Nat) : async () {
    await bloomFilter.add(key, item);
  };

  public func check(key: Word8, item: Nat) : async (Bool) {
    await bloomFilter.check(key, item)
  };

};