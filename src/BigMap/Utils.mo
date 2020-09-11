import Array "mo:base/Array"; 
import Nat "mo:base/Nat";
import Text "mo:base/Text";

module {

  public func hash(filterData: [Bool]) : [Word8] {
    Array.map(filterData, func (b: Bool) : Word8 { switch(b) { case (true) { 1 }; case (false) { 0 }; }} )
  };

  public func unhash(hashedData: [Word8]) : [Bool] {
    Array.map(hashedData, func (w: Word8) : Bool { switch(w) { case (1) { true }; case (_) { false }; }} )
  };

};