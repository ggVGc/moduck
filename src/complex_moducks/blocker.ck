
include(macros.m4)
include(song_macros.m4)

public class Blocker{
  maker0(Moduck){
    def(root, mk(Repeater, [P_Trigger, "on", "off"]))
    def(router, mk(Router, 0).multi([
      mk(Repeater).from("0")
      ,mk(Blackhole).from("1")
    ]))

    def(blockerOff, mk(Value, 0) => router.to("index").c);
    def(blockerOn, mk(Value, 1) => router.to("index").c);

    root => router.listen(P_Trigger).c;
    root => blockerOn.from("on").c;
    root => blockerOff.from("off").c;

    def(out, mk(Repeater, P_Trigger))
    router => out.listen(P_Trigger).c;

    return Wrapper.make(root, out);
  }
}
