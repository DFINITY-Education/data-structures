import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";

// import BM "mo:Bigmap";

module {

  // TODO: enforce 0 < errorRate < 1
  // TODO: enfore capacity > 0
  public class AutoScalingBloomFilter<S>(capacity: Nat, errorRate: Float) {

    var filters: [BloomFilter<S>] = [];

    var count = 0;
    let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    let bitMapSize: Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
    // TODO: add hashfunctions here
    var hashFuncs: [(S) -> Nat] = [];

    public func add(item: S) {
      var filter = BloomFilter(bitMapSize, hashFuncs);
      if (not List.isNil<BloomFilter<S>>(List.fromArray<BloomFilter<S>>(filters))) {
        let last_filter = filters[filters.size() - 1];
        if (last_filter.numItems > capacity) {
          filter := last_filter;
        };
      };
      filter.add(item);
      filters := Array.append<BloomFilter<S>>(filters, [filter]);
    };

    public func check(item: S) : Bool {
      for (filter in Iter.fromArray(filters)) {
        if (filter.check(item)) { return true; };
      };
      false
    };

    // TODO: implement me
    func getHashFuncs(numBits: Nat) {};

  };

  public class BloomFilter<S>(bitMapSize: Nat, hashFuncs: [(S) -> Nat]) {

    public var numItems = 0;
    let bitMap: [var Bool] = Array.init<Bool>(bitMapSize, false);

    public func add(item: S) {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = f(item) % bitMapSize;
        bitMap[digest] := true;
      };
      numItems += 1;
    };

    public func check(item: S) : Bool {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = f(item) % bitMapSize;
        if (bitMap[digest] == true) return false;
      };
      true
    };

  };

};