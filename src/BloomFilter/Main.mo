import BloomFilter "./BloomFilter";

actor {

  var bloomFilter = BloomFilter.BloomFilter<Nat>(0, 0.001);

  public func bfAdd(item: Nat) {
    bloomFilter.add(item);
  };

  public func bfCheck(item: Nat) : async Bool {
    bloomFilter.check(item)
  };

};