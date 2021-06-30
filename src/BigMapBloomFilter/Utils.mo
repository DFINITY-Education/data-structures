import Array "mo:base/Array"; 
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";

import BloomFilter "../BloomFilter/BloomFilter";

module {

    type BloomFilter<S> = BloomFilter.BloomFilter<S>;
    type Hash = Hash.Hash;

    public func serialize(filterData: [Bool]) : [Nat8] {
        Array.map(filterData, func (b: Bool) : Nat8 { switch(b) { case (true) { 1 }; case (false) { 0 }; }} )
    };

    public func unserialize(serializedData: [Nat8]) : [Bool] {
        Array.map(serializedData, func (w: Nat8) : Bool { switch(w) { case (1) { true }; case (_) { false }; }} )
    };

    public func constructWithData<S>(bitMapSize: Nat32, hashFuncs: [(S) -> Hash], data: [Bool]) : BloomFilter<S> {
        let filter = BloomFilter.BloomFilter<S>(bitMapSize, hashFuncs);
        filter.setData(data);
        filter
    };

};
