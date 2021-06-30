import T "Types";
import HashMap "mo:base/HashMap";
import SegKey "SegKey";
import Debug "DebugOff";
//import Debug "mo:base/Debug";
import P "mo:base/Prelude";
import List "mo:base/List";

module {
  public type Segments = List.List<Segment>;

  public type Interval = T.Interval;

  public type Init = T.SegmentInit;

  public func initId(init:Init) : Nat {
    switch init {
    case (#singleton(id)) id;
    case (#empty(id, _)) id;
    case (#nonEmpty(id, _, _)) id;
    };
  };

  // generate a list of segments, spaced uniformly in keyspace
  public func uniformSegments(numSegments:Nat) : Segments {
    let segKeys = SegKey.uniformSegments(numSegments);
    var segments : Segments = null;
    for (i in segKeys.keys()) {
      let first = segKeys[i];
      let last =
        if (i == segKeys.size() - 1)
          SegKey.inf()
        else
          segKeys[i + 1];
       segments := ?(Segment(#empty(i, (first, last))), segments);
    };
    List.reverse(segments) /*List.reverse(segments)*/
  };

  public class Segment(init : Init) = Self {

    type SegMap = {
      interval : T.Interval;
      map : HashMap.HashMap<T.SegKey, T.Val>;
    };

    public let id : Nat = initId(init);

    private var segMap : SegMap =
      switch init {
    case (#nonEmpty(_, interval_, data)) {
           let m = {
              interval = interval_;
              map = HashMap.HashMap<T.SegKey,T.Val>(0, SegKey.equals, SegKey.hash);
           };
           for ((_, k, v) in data.vals()) {
               m.map.put(k, v)
             };
             m
         };
    case (#empty(_, interval_)) {
           // one of many initially-empty segments, with the given first/last keys
           {interval = interval_;
           map = HashMap.HashMap<T.SegKey,T.Val>(0, SegKey.equals, SegKey.hash);}
         };
    case (#singleton _) {
           // initial segment has special first and last keys, and no content
           {interval = (SegKey.zero(), SegKey.inf());
           map = HashMap.HashMap<T.SegKey,T.Val>(0, SegKey.equals, SegKey.hash);}
         };
    };

    // segment's local size; does not aggregate other segments' sizes.
    public func size() : Nat =
      segMap.map.size();

    public func intervalContains(k:T.SegKey) : Bool =
      SegKey.intervalContains(segMap.interval, k);

    public func interval() : Interval {
      segMap.interval
    };

    public func get(k:T.Key) : ?T.Val {
      getSegKey(SegKey.ofKey(k));
    };

    public func getSegKey(k:T.SegKey) : ?T.Val  {
      assert (SegKey.intervalContains(segMap.interval, k));
      Debug.print "Segment getSegKey begin";
      Debug.print (" - id = " # (debug_show id));
      let v = segMap.map.get(k);
      Debug.print "Segment getSegKey end";
      v
    };

    public func put(k:T.Key, v:T.Val)  {
      putSegKey(SegKey.ofKey(k), v);
    };

    public func putSegKey(k:T.SegKey, v:T.Val)  {
      Debug.print "Segment put begin";
      Debug.print (" - id = " # (debug_show id));
      assert (SegKey.intervalContains(segMap.interval, k));
      segMap.map.put(k, v);
      Debug.print "Segment put end";
    };
  };
}
