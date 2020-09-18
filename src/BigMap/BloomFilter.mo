import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";

import BigMap "canister:BigMap";

import BloomFilter "../BloomFilter/BloomFilter";
import Utils "./Utils";

module {

  type BloomFilter<S> = BloomFilter.BloomFilter<S>;
  type Hash = Hash.Hash;

  /// Manages BloomFilters, deploys new BloomFilters, and checks for element membership across filters.
  /// Args:
  ///   |capacity|    The maximum number of elements a BlooomFilter may store.
  ///   |errorRate|   The maximum false positive rate a BloomFilter may maintain.
  ///   |hashFuncs|   The hash functions used to hash elements into the filter.
  public class BigMapBloomFilter<S>(capacity: Nat, errorRate: Float, hashFuncs: [(S) -> Hash]) {

    let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    let bitMapSize: Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));

    /// Adds an element to the BloomFilter's bitmap and deploys new BloomFilter if previous is at capacity.
    /// Args:
    ///   |key|    The key associated with the particular item (used with BigMap).
    ///   |item|   The item to be added.
    public func add(key: Word8, item: S) : async () {
      let filterOpt = await BigMap.get([Utils.convertWord8ToNat8(key)]);
      let filter = switch (filterOpt) {
        case (null) { BloomFilter.BloomFilter<S>(bitMapSize, hashFuncs) };
        case (?data) { Utils.constructWithData<S>(capacity, hashFuncs, Utils.unserialize(Array.map(data, Utils.convertNat8ToWord8))) };
      };
      filter.add(item);
      await BigMap.put([Utils.convertWord8ToNat8(key)], Array.map(Utils.serialize(filter.getBitMap()), Utils.convertWord8ToNat8));
    };

    /// Checks if an item is contained in any BloomFilters
    /// Args:
    ///   |key|    The key associated with the particular item (used with BigMap).
    ///   |item|   The item to be searched for.
    /// Returns:
    ///   A boolean indicating set membership.
    public func check(key: Word8, item: S) : async (Bool) {
      let filterOpt = await BigMap.get([Utils.convertWord8ToNat8(key)]);
      switch (filterOpt) {
        case (null) { false };
        case (?data) {
          let filter = Utils.constructWithData<S>(capacity, hashFuncs, Utils.unserialize(Array.map(data, Utils.convertNat8ToWord8)));
          if (filter.check(item)) { return true; };
          false
        };
      }
    };

  };

};