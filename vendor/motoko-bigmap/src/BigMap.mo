import T "Types";
import SegKey "SegKey";
import Seg "Segment";
//import Debug "DebugOff";
import Debug "mo:base/Debug";
import List "mo:base/List";
import P "mo:base/Prelude";

module {

  public class BigMap(
    numSegments : Nat
  ) = Self {

    type Segments = Seg.Segments;
    type Segment = Seg.Segment;

    type SegmentCanister = T.SegmentCanister;
    type CanisterInfo = T.CanisterInfo;
    type Canisters = List.List<CanisterInfo>;

    private var segments : Segments =
      Seg.uniformSegments(numSegments);

    private var canisters : Canisters = null;

    // null means all segment canisters "fully initialized"
    public func initNext(sc : SegmentCanister) : ?(() -> async ()) {
      switch segments {
        case null null;
        case (?(segment, rest)) {
          segments := rest;
          canisters := ?((sc, segment.interval()), canisters);
          let init = #empty(segment.id, segment.interval());
          let doit = ?(func () : async () = async { await sc.init(init) });          
          doit
        };
      }
    };

    public func getReady() : [CanisterInfo] {
      List.toArray(canisters)
    };

    public func getCanister(k : T.SegKey) : SegmentCanister {
      getCanisterInfo(k).0
    };

    public func getInterval(k : T.SegKey) : T.Interval {
      getCanisterInfo(k).1
    };

    public func getCanisterInfo(k : T.SegKey) : CanisterInfo {
      func getRec(s : Canisters) : CanisterInfo {
        switch s {
        case (?((sc, interval), s)) {
               if (SegKey.intervalContains(interval, k)) {
                 (sc, interval)
               } else {
                 getRec(s)
               }
             };
        case null {
               Debug.print ("Invariant error: key not contained in any segment"
               # (debug_show k));
               P.unreachable()
             };
        }
      };
      assert (isReady());
      getRec(canisters)
    };

    public func isReady() : Bool {
      switch segments {
        case null true;
        case _ false;
      }
    };
  };
}
