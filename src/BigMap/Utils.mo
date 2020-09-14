import Array "mo:base/Array"; 
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Word8 "mo:base/Word8";

module {

  public func hash(filterData: [Bool]) : [Word8] {
    Array.map(filterData, func (b: Bool) : Word8 { switch(b) { case (true) { 1 }; case (false) { 0 }; }} )
  };

  public func unhash(hashedData: [Word8]) : [Bool] {
    Array.map(hashedData, func (w: Word8) : Bool { switch(w) { case (1) { true }; case (_) { false }; }} )
  };

  public func convertNat8ToWord8(n: Nat8) : Word8 {
    Word8.fromNat(Nat8.toNat(n))
  };

  public func convertWord8ToNat8(w: Word8) : Nat8 {
    Nat8.fromNat(Word8.toNat(w))
  };

};