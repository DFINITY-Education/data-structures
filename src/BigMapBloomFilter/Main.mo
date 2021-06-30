import Hash "mo:base/Hash";

import BigMapBloomFilter "./BigMapBloomFilter";

actor {

  var bloomFilter = BigMapBloomFilter.BigMapBloomFilter<Nat>(0, 0.001, [Hash.hash]);

    public func add(key: Nat8, item: Nat) : async () {
        await bloomFilter.add(key, item);
    };

    public func check(key: Nat8, item: Nat) : async (Bool) {
        await bloomFilter.check(key, item)
    };

};
