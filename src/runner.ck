include(aliases.m4)

public class Runner{
  static int BPM;
  static int TICKS_PER_BEAT;
  static Trigger @ _startBang;
  static ModuckP @ masterClock;

  fun static void start(){
    Patch.connect(
      Patch.connect(_startBang, ClockGen.make(Util.bpmToDur( BPM * TICKS_PER_BEAT)))
      ,masterClock
    );
    samp  => now;
    _startBang.trigger(1);
    <<< "Playing">>>;
  }
}


120 => Runner.BPM;
32 => Runner.TICKS_PER_BEAT;

Trigger.make("start") @=> Runner._startBang;
ModuckP.make(Repeater.make()) @=> Runner.masterClock;

Patch.connect(Runner.masterClock, Printer.make("master"));
samp => now;
