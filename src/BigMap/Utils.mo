import Array "mo:base/Array"; 
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

module {

  public func hash(filterData: [Bool]) : [Word8] {
    for (b in Iter.fromArray(filterData)) {
      data #= Nat.toText( switch(b) { case (true) { 1 }; case (false) { 0 }; } );
    };
    Text.hash(data)
  };

  public func unhash(hashedData: [Word8]) : [Bool] {

  }

}