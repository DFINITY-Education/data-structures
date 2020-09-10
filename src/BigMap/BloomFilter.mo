import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";

import BigMap "canister:BigMap";

import BloomFilter "../BloomFilter/BloomFilter";
import Utils "./Utils";

module {

  type BloomFilter<S> = BloomFilter.BloomFilter<S>;
  type Hash = Hash.Hash;

  public class BigMapBloomFilter<S>(capacity: Nat, errorRate: Float, hashFunc: (S) -> Hash) {

    var count = 0;
    let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    let bitMapSize: Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
    // TODO: add hashfunctions here
    var hashFuncs: [(S) -> Hash] = [hashFunc];

    public func add(key: Word8, item: S) : async () {
      let filterOpt = await BigMap.get(key);
      let filter = switch (filterOpt) {
        case (null) { BloomFilter.BloomFilter<S>(bitMapSize, hashFuncs) };
        case (?data) { BloomFilter.constructWithData<S>(capacity, errorRate, data) };
      };
      filter.add(item);
      await BigMap.put(filter.hash());
    };

    public func check(key: Word8, item: S) : async Bool {
      let filterOpt = await BigMap.get(key);
      switch (filterOpt) {
        case (null) { false };
        case (?data) {
          let filter = BloomFilter.constructWithData<S>(capacity, errorRate, data);
          if (filter.check(item)) { return true; };
          false
        };
      }
    };

  };

};