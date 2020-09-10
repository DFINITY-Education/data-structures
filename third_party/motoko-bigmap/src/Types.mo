import HashMap "mo:base/HashMap";

module {
  public type Key = [Word8];
  public type Val = [Word8];

  // SegKey type:
  // - compared to the (plaintext) Key type, these are hashed via the SHA256 package.
  // - the (unique) null key means "infinite hash value", always ending the ring.
  public type SegKey = ?[Word8];

  // SegKey intervals: [first included, last excluded)
  public type Interval = (SegKey, SegKey);

  // segment initialization cases, as data:
  public type SegmentInit = {
    // this is the first, initially-empty segment of the BigMap.
    #singleton : Nat;
    // this is an initially-empty segment of a multi-segment pool.
    #empty : (Nat, Interval);
    // this is a forked segment of some other one; it has existing content.
    #nonEmpty : (Nat, Interval, [(Key, SegKey, Val)])
    };

  // Exposed to the Main index canister (see app/Main)
  public type SegmentCanister = actor {
    init : SegmentInit -> async ();
    put : (SegKey, Val) -> async ();
    get : query SegKey -> async ?Val;
  };

  // config/diagnostic info
  public type CanisterInfo = (SegmentCanister, Interval);
}
