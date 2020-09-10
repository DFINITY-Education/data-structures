import T "../src/Types";
import Debug "mo:base/Debug";
import Segment "../src/Segment";

actor {
  private flexible var seg
    : Segment.Segment
    = Segment.Segment(#singleton(0));

  public func init(init : Segment.Init) {
    Debug.print "BigMapSegCan init begin";
    Debug.print (" - id    = " # (debug_show Segment.initId(init)));
    Debug.print (" - init = " # (debug_show init));
    seg := Segment.Segment(init);
    Debug.print "BigMapSegCan init end";
  };

  public query func get(sk : T.SegKey) : async ?T.Val {
    Debug.print "BigMapSegCan get begin";
    Debug.print (" - id = " # (debug_show seg.id));
    Debug.print (" - segKey = " # (debug_show sk));
    let v = seg.getSegKey(sk);
    Debug.print "BigMapSegCan get end";
    v
  };

  public func put(sk : T.SegKey, v : T.Val) {
    Debug.print "BigMapSegCan put begin";
    Debug.print (" - id = " # (debug_show seg.id));
    Debug.print (" - segKey = " # (debug_show sk));
    seg.putSegKey(sk, v);
    Debug.print "BigMapSegCan put end";
  };

};
