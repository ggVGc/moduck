include(aliases.m4)

/*
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
  
    fun static int getBpm(){
      return BPM;
    }
  
    fun static int getTicksPerBeat(){
      return TICKS_PER_BEAT;
    }
  }
  
  
  120 => Runner.BPM;
  32 => Runner.TICKS_PER_BEAT;
  
  Trigger.make("start") @=> Runner._startBang;
  ModuckP.make(Repeater.make()) @=> Runner.masterClock;
  
  Patch.connect(Runner.masterClock, Printer.make("master"));
  samp => now;
 */



include(aliases.m4)


public class Runner{
  static Trigger @ _startBang;
  static ModuckP @ masterClock;

  static int ticksPerBeat;

  fun static void start(){
    Patch.connect(_startBang, masterClock);
    // Patch.connect(masterClock, Printer.make("master"));
    samp  => now;
    _startBang.trigger(1);
    <<< "Playing">>>;

  }

  fun static void setBpm(float bpm){
    masterClock.setVal("delta", Util.toSamples(Util.bpmToDur(bpm*ticksPerBeat)));
  }

  fun static dur timePerBeat(){
    return (masterClock.getVal("delta")*ticksPerBeat)::samp;
  }

  fun static float getBpm(){
    masterClock.getVal("delta")::samp @=> dur d;
    return minute/(d*ticksPerBeat);
  }
}


32 => Runner.ticksPerBeat;


Trigger.make("start") @=> Runner._startBang;
ModuckP.make(ClockGen.make(120*Runner.ticksPerBeat)) @=> Runner.masterClock;

samp => now;
