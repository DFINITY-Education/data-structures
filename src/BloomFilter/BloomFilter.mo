import Array "mo:base/Array";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";

module {

  // TODO: enforce 0 < errorRate < 1
  // TODO: enfore capacity > 0
  public class BloomFilter<S>(capacity: Nat, errorRate: Float) {

    var count = 0;
    let numSlices = Float.ceil(Float.log(1.0 / errorRate));
    let bitsPerSlice = Float.ceil(
          (Float.fromInt(capacity) * Float.abs(Float.log(errorRate))) /
          (numSlices * (Float.log(2) ** 2)));
    let bitMapSize: Nat = Int.abs(Float.toInt(numSlices * bitsPerSlice));
    let bitMap: [var Bool] = Array.init<Bool>(bitMapSize, false);
    var hashFuncs: [(S) -> Nat] = [];

    public func add(item: S) {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = f(item) % bitMapSize;
        bitMap[digest] := true;
      };
    };

    public func check(item: S) : Bool {
      for (f in Iter.fromArray(hashFuncs)) {
        let digest = f(item) % bitMapSize;
        if (bitMap[digest] == true) return false;
      };
      true
    };

    // TODO: implement me
    func getHashFuncs(numBits: Nat) {}

  };

};