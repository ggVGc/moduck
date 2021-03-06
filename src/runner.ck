include(aliases.m4)
include(pulses.m4)


public class Runner extends RunnerBase{
  static Repeater @ masterClock;
  static ClockGen @ _masterClockGen;
  static int ticksPerBeat;
  static int isPlaying;
  static Event @ quitEvent;
  static Event @ bpmChanged;

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
    false => NoteOut.enabled;
    _preStartBang.broadcast();
    samp => now;
    true => NoteOut.enabled;
    _startBang.broadcast();
     Runner._masterClockGen.doHandle(P_Gate, IntRef.yes());
    true => isPlaying;
    <<< "Runner: Playing">>>;
    return true;
  }

  fun static void quit(){
    quitEvent.broadcast();
  }

  fun static void setBpm(int bpm){
    _masterClockGen.setBpm(bpm);
    bpmChanged.broadcast();
  }

  fun static int getBpm(){
    return _masterClockGen.getBpm()/Runner.ticksPerBeat;
  }


  fun static dur timePerTick(){
    return minute/_masterClockGen.getBpm();
  }

  fun static int samplesPerTick(){
    return Util.toSamples(timePerTick());
  }

  fun static dur timePerBeat(){
    return minute/getBpm();
  }

  fun static int samplesPerBeat(){
    return Util.toSamples(timePerBeat());
  }


  fun static int stop(){
    if(!isPlaying){
      return false;
    }
    _masterClockGen.doHandle(P_Gate, null);
    false => isPlaying;
    <<< "Runner: Stopped ">>>;
    return true;
  }

  fun static void skipForward(int ticks){
    samp => now;
    false => Printer.enabled;
    false => NoteOut.enabled;
    for(0=>int i;i<ticks;++i){
      masterClock.doHandle(P_Default, IntRef.make(0));
      samp => now;
    }
    true => Printer.enabled;
    true => NoteOut.enabled;
  }
}


Event xxx;
xxx @=> Runner.bpmChanged;

Event qe;
qe @=> Runner.quitEvent;

false => Runner.isPlaying;
4 => Runner.ticksPerBeat;

ClockGen.make(127*Runner.ticksPerBeat) @=> Runner._masterClockGen;
Repeater.make(P_Clock) @=> Runner.masterClock;
Patch.connect(Runner._masterClockGen, Runner.masterClock);
samp => now;
Runner.bpmChanged.broadcast();

Runner.quitEvent => now;
<<<"Runner quit">>>;
