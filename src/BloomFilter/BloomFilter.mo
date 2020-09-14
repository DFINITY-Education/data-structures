import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Word "mo:base/Word32";

module {

  type Hash = Hash.Hash;

  // TODO: enforce 0 < errorRate < 1
  // TODO: enfore capacity > 0
  public class AutoScalingBloomFilter<S>(capacity: Nat, errorRate: Float, hashFunc: (S) -> Hash) {

    var filters: [BloomFilter<S>] = [];

    let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    let bitMapSize: Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
    var hashFuncs: [(S) -> Hash] = [hashFunc];

    // TODO: scenario where duplicate items are added?
    public func add(item: S) {
      var filter = BloomFilter(bitMapSize, hashFuncs);
      if (filters.size() > 0) {
        let last_filter = filters[filters.size() - 1];
        if (last_filter.getNumItems() < capacity) {
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

  };

  public class BloomFilter<S>(bitMapSize: Nat, hashFuncs: [(S) -> Hash]) {

    var numItems = 0;
    let bitMap: [var Bool] = Array.init<Bool>(bitMapSize, false);

    public func add(item: S) {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = Word.toNat(f(item)) % bitMapSize;
        bitMap[digest] := true;
      };
      numItems += 1;
    };

    public func check(item: S) : Bool {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = Word.toNat(f(item)) % bitMapSize;
        if (bitMap[digest] == true) return false;
      };
      true
    };

    public func getNumItems() : Nat {
      numItems
    };

    public func getBitMap() : [Bool] {
      Array.freeze(bitMap)
    };

    public func setData(data: [Bool]) {
      assert data.size() == bitMapSize;
      for (i in Iter.range(0, data.size())) {
        bitMap[i] := data[i];
      };
    };

  };

};