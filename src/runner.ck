include(aliases.m4)
include(pulses.m4)

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
  static Repeater @ masterClock;
  static ClockGen @ _masterClockGen;
  // static int tickCount;

  static int ticksPerBeat;

  static int isPlaying;

  /*
    fun static void tickCountLoop(){
      while(true){
        masterClock._outs[P_Clock] => now;
        1 +=> tickCount;
      }
    }
   */

  fun static int setPlaying(int v){
    if(v){
      return start();
    }else{
      return stop();
    }
  }

  fun static int start(){
    if(isPlaying){
      return false;
    }
    _startBang.trigger(1);
    true => isPlaying;
    <<< "Runner: Playing">>>;
    return true;
  }

  fun static void setBpm(float bpm){
    _masterClockGen.setVal("delta", Util.toSamples(Util.bpmToDur(bpm*ticksPerBeat)));
  }

  fun static dur timePerTick(){
    return _masterClockGen.getVal("delta")::samp;
  }
  fun static int samplesPerTick(){
    return Util.toSamples(timePerTick());
  }

  fun static dur timePerBeat(){
    return timePerTick()*ticksPerBeat;
  }

  fun static int samplesPerBeat(){
    return Util.toSamples(timePerBeat());
  }

  fun static float getBpm(){
    _masterClockGen.getVal("delta")::samp @=> dur d;
    return minute/(d*ticksPerBeat);
  }

  fun static int stop(){
    if(!isPlaying){
      return false;
    }
    _masterClockGen.stop();
    false => isPlaying;
    <<< "Runner: Stopped ">>>;
    return true;
  }

  fun static void skipForward(int ticks){
    samp => now;
    false => Printer.enabled;
    false => NoteOut.enabled;
    for(0=>int i;i<ticks;++i){
      masterClock.doHandle(P_Default, 0);
      samp => now;
    }
    true => Printer.enabled;
    true => NoteOut.enabled;
  }
}

false => Runner.isPlaying;

64 => Runner.ticksPerBeat;


Trigger.make("start") @=> Runner._startBang;
ClockGen.make(120*Runner.ticksPerBeat) @=> Runner._masterClockGen;
Repeater.make(P_Clock) @=> Runner.masterClock;


Patch.connect(Runner._startBang, Runner._masterClockGen);
Patch.connect(Runner._masterClockGen, Runner.masterClock);

// 0 => Runner.tickCount;
// spork ~ Runner.tickCountLoop();
samp => now;


Util.runForever(); // Keep connection alive
