
fun dur bpmToDur(float bpm){
  return minute / bpm;
}

class VEvent extends Event{
  int val;
}

class SrcEvent extends Event{
  string tag;
  int val;
}

class IntRef{
  int i;
}


fun IntRef iref(int v){
  IntRef i;
  v => i.i;
  return i;
}


class Handler{
  IntRef values[10]; // Completely arbitrary
  fun int handle(string msg, int v){};

  SrcEvent out;

}


class ClockGen extends Handler{
  /* VEvent out; */
  bpmToDur(120) => dur delta;

  Shred @ looper;

  fun void loop(){
    while(true){
      delta => now;
      out.broadcast();
    }
  }

  fun int handle(string msg, int v){
    if(msg == "run"){
      if(looper != null){
        looper.exit();
        null @=> looper;
      }
      if(v){
        spork ~ loop() @=> looper;
      }
      return true;
    }
  }
}


class Delay extends Handler{
  /* VEvent out; */
  second => dur wait;
  Shred @ waiter;

  fun void doWait(int v){
    wait => now;
    v => out.val;
    out.broadcast();
  }

  fun int handle(string _, int v){
    if(waiter != null){
      waiter.exit();
      null @=> waiter;
    }
    spork ~ doWait(v) @=> waiter;
    return true;
  }
}

fun Delay mkDelay(dur wait){
  Delay d;
  wait => d.wait;
  return d;
}

class Sequencer extends Handler{
  int entries[];
  0 => int curStep;
  iref(true) @=> values["loop"];

  /* VEvent out; */

  fun int handle(string type, int v){
    if(type == "step"){
      step(v);
      return true;
    }
  }

  fun void step(int ignored){
    entries[curStep] => out.val;
    if(curStep == entries.size() - 1){
      if(values["loop"].i){
        0 => curStep;
        out.broadcast();
      }
    }else{
      curStep + 1 => curStep;
      out.broadcast();
    }
  }
}


fun Sequencer mkSeq(int entries[]){
  Sequencer s;
  entries @=> s.entries;
  return s;
}


class Printer extends Handler{
  "Printer" => string msg;

  fun void print(int v){
    <<< msg + "> " + v>>>;
  }

  fun int handle(string msg, int v){
    if(msg == "print"){
      print(v);
      return true;
    }
  }
}

fun Printer mkPrinter(string msg){
  Printer ret;
  msg => ret.msg;
  return ret;
}


class Value extends Handler{
  iref(0) @=> values["value"];

  /* VEvent out; */
  
  fun int handle(string _, int __){
    values["value"].i => out.val;
    out.broadcast();
    return true;
  }
}

fun Value mkVal(int v){
  Value ret;
  iref(v) @=> ret.values["value"];
  return ret;
}


fun void connectLoop(Handler src, string srcEventName, Handler target, string msg){
  while(true){
    src.out => now;
    if(srcEventName != null && srcEventName != "" && srcEventName != src.out.tag){
      <<<"Invalid source event: "+srcEventName+" - "+src>>>;
    }
    if(!target.handle(msg, src.out.val)){
      <<<"Invalid event: "+msg+" - "+target>>>;
    }
  }
}


fun void connectValLoop(Handler src, string srcEventName, Handler target, string valueName){
  while(true){
    src.out => now;
    if(srcEventName != null && srcEventName != "" && srcEventName != src.out.tag){
      <<<"Invalid source event: "+srcEventName+" - "+src>>>;
    }
    if(target.values[valueName] == null){
      <<<"Invalid value: "+valueName+" - "+target>>>;
    }
    iref(src.out.val) @=> target.values[valueName];
  }
}

fun Handler C(Handler src, string srcEventName, Handler target, string msg){
  spork ~ connectLoop(src, srcEventName, target, msg);
  return target;
}

fun Handler V(Handler src, string srcEventName, Handler target, string msg){
  spork ~ connectValLoop(src, srcEventName, target, msg);
  return target;
}

class Trigger extends Handler{
  fun void trigger(string tag, int v){
    tag => out.tag;
    v => out.val;
    out.broadcast();
  }
}


Trigger startBang;
ClockGen clock;
mkPrinter("Seq event") @=> Printer printer;
mkSeq([5,3,6,1]) @=> Sequencer seq;
mkDelay(2.4::second) @=> Delay delay;



// Start sequencer and delay
C(startBang, null, clock, "run");
C(startBang, null, delay, "delay");

// Step sequencer each clock
C(clock, null, seq, "step");

// Set sequencer loop to false when delay triggers
V(
  C(delay, null, mkVal(false), null)
  ,null, seq, "loop"
);

C(seq, null, printer, "print"); // Print each sequencer step


ms => now;
startBang.trigger("start", 1);
while(true){
  10::hour => now;
}

/* d.handle("", false); // trigger delay instantly */

