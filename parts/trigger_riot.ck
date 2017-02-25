

fun ModuckP makeKnob(int initialTicksPerBeat){
  def(speedClockDiv, mk(PulseDiv, initialTicksPerBeat))
  def(clockDiv, mk(PulseDiv,0))
  def(prob, mk(Probably, 100))
  def(clockDly, mk(PulseDelay, 0))
  def(timeDly, mk(Delay, 0::samp))
  def(timeAttn, mk(Attenuator,0,100))

  def(root, mk(Repeater, [P_Trigger, "delay", "div", "prob", "time", "speed"]).setName("riot_knobRoot"));
  def(clockPhaseDelta, mk(Subtract))

  clockDiv
    => clockPhaseDelta.fromTo(recv("divisor"), "a").c;

  clockDly
    => clockPhaseDelta.fromTo(recv("size"), "b").c;

  def(clockDeltaTime, mk(Value, 0))

  def(mul, mk(Multiplier, 2))
  clockPhaseDelta => mul.to("1").c;
  mul.setVal("0", Runner.samplesPerTick()*initialTicksPerBeat); // TODO: Use another multiplier here to get updated values for tickerPerBeat
  mul => clockDeltaTime.to("value").c;
  clockDeltaTime => clockDeltaTime.fromTo(recv("value"), P_Trigger).c;

  root
    .b(clockDly.fromTo("delay", "size"))
    .b(clockDiv.fromTo("div", "divisor"))
    .b(speedClockDiv.fromTo("speed", "divisor"))
    .b(prob.fromTo("prob", "chance"))
    .b(timeAttn.fromTo("time", "ratio"))
  ;

  timeAttn
    => mk(Delay, samp).from(recv("ratio")).c
    => clockDeltaTime.c
    => timeAttn.to(P_Trigger).c
  ;

  def(trigOut, root
    => speedClockDiv.c
    => clockDiv.c
    => prob.c
    => clockDly.c
    => timeDly.c
  );

  trigOut.setName("riot_knobOut");
  timeAttn => timeDly.to("delay").c;
  speedClockDiv => clockDly.to(P_Clock).c;
  samp => now;
  clockDiv.set("divisor", 0);
  return mk(Wrapper, root, trigOut);

}

fun ModuckP mulWith(int multVal){
  def(mult, mk(Multiplier, 2))
  mult.set("1", multVal);
  def(root, mk(Repeater))
  root => mult.to("0").c;

  return mk(Wrapper, root, mult);
}

fun ModuckP triggerRiot(int gridSize, int initialTicksPerBeat){
  defl(sideOuts, makeOuts(gridSize));
  defl(bottomOuts, makeOuts(gridSize));

  defl(knobs, makeKnobs(gridSize*gridSize, initialTicksPerBeat));
  defl(blockers, mkMany(Blocker, gridSize*gridSize));
  defl(blockerDelays, mkMany(Delay, gridSize*gridSize, 0::samp));

  string inKeys[0];
  string outKeys[0];

  inKeys << P_Trigger;


  for(0=>int x;x<gridSize;++x){ 
    for(0=>int y;y<gridSize;++y){ 
      outKeys << "side"+x;
      outKeys << "bottom"+x;
      inKeys << "div"+x+""+y;
      inKeys << "prob"+x+""+y;
      inKeys << "time"+x+""+y;
      inKeys << "delay"+x+""+y;
      inKeys << "speed"+x+""+y;
      inKeys << "width"+x+""+y;
    }
  }

  def(root, mk(Repeater, inKeys));
  def(mainOut, mk(Repeater, outKeys).setName("riot_mainOut"))


  for(0=>int x;x<gridSize;++x){ 
    bottomOuts[x] @=> ModuckP bottomSlot;
    for(0=>int y;y<gridSize;++y){ 
      x+y*gridSize => int ind;
      knobs[ind] @=> ModuckP knob;
      // (bottomSlot => blockers[ind].c) @=> bottomSlot;

      def(widthDly, blockerDelays[ind]);
      def(blocker, blockers[ind]);

      root
        .b(knob.listen(P_Trigger))
        .b(knob.fromTo("delay"+x+""+y, "delay"))
        .b(knob.fromTo("div"+x+""+y, "div"))
        .b(knob.fromTo("prob"+x+""+y, "prob"))
        .b(knob.fromTo("time"+x+""+y, "time"))
        .b(knob.fromTo("speed"+x+""+y, "speed"))
        .b((mulWith(Util.toSamples(ms)) => widthDly.to("delay").c).from("width"+x+""+y))
      ;

      widthDly => blocker.to("off").c;
      blocker => widthDly.from(recv("on")).c;


      knob
        .b(mk(Delay, samp) => blocker.to("on").c)
        .b(sideOuts[y])
        .b(bottomOuts[x])
      ;
    }
    bottomSlot => mainOut.to("bottom"+x).c;
  }

  for(0=>int y;y<gridSize;++y){ 
    sideOuts[y] @=> ModuckP sideSlot;
    // for(0=>int x;x<gridSize;++x){ 
    //   x+y*gridSize => int ind;
    //   (sideSlot => blockers[ind].c) @=> sideSlot;
    // }
    sideSlot => mainOut.to("side"+y).c;
  }

  samp => now;
  return mk(Wrapper, root, mainOut);
}



fun ModuckP[] makeKnobs(int count, int initialTicksPerBeat){
  ModuckP ret[count];

  for(0=>int i;i<count;++i){
    makeKnob(initialTicksPerBeat) @=> ret[i];
  }
  return ret;
}


fun ModuckP[] makeOuts(int count){
  ModuckP ret[count];
  for(0=>int x;x<count;++x){
    mk(Repeater) @=> ret[x];
  }
  return ret;
}

