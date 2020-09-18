import Array "mo:base/Array"; 
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Word8 "mo:base/Word8";

import BloomFilter "../BloomFilter/BloomFilter";

module {

  type BloomFilter<S> = BloomFilter.BloomFilter<S>;
  type Hash = Hash.Hash;

  public func serialize(filterData: [Bool]) : [Word8] {
    Array.map(filterData, func (b: Bool) : Word8 { switch(b) { case (true) { 1 }; case (false) { 0 }; }} )
  };

  public func unserialize(serializedData: [Word8]) : [Bool] {
    Array.map(serializedData, func (w: Word8) : Bool { switch(w) { case (1) { true }; case (_) { false }; }} )
  };

  public func convertNat8ToWord8(n: Nat8) : Word8 {
    Word8.fromNat(Nat8.toNat(n))
  };

  public func convertWord8ToNat8(w: Word8) : Nat8 {
    Nat8.fromNat(Word8.toNat(w))
  };

  public func constructWithData<S>(bitMapSize: Nat, hashFuncs: [(S) -> Hash], data: [Bool]) : BloomFilter<S> {
    let filter = BloomFilter.BloomFilter<S>(bitMapSize, hashFuncs);
    filter.setData(data);
    filter
  };

};