import Hash "mo:base/Hash";

import BloomFilter "./BloomFilter";

actor {

    var bloomFilter = BloomFilter.AutoScalingBloomFilter<Nat>(0, 0.001, [Hash.hash]);

    public func add(item: Nat) {
        bloomFilter.add(item);
    };

    public func check(item: Nat) : async (Bool) {
        bloomFilter.check(item)
    };

};
