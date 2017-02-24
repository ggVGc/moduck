

fun ModuckP makeKnob(){
  def(clockDiv, mk(PulseDiv,0))
  def(prob, mk(Probably, 100))
  def(clockDly, mk(PulseDelay, 0))
  def(timeDly, mk(Delay, 0::samp))
  def(timeAttn, mk(Attenuator,0,100))

  def(root, mk(Repeater, [P_Trigger, "clockDelay", "div", "prob", "time"]).setName("riot_knobRoot"));

  def(clockPhaseDelta, mk(Subtract))


  clockDiv
    => clockPhaseDelta.fromTo(recv("divisor"), "a").c;

  clockDly
    => clockPhaseDelta.fromTo(recv("size"), "b").c;


  def(clockDeltaTime, mk(Value, 0))

  def(mul, mk(Multiplier, 2))
  clockPhaseDelta => mul.to("1").c;
  mul.setVal("0", Runner.samplesPerTick());
  mul => clockDeltaTime.to("value").c;

  clockDeltaTime => clockDeltaTime.fromTo(recv("value"), P_Trigger).c;

  root
    .b(clockDly.fromTo("clockDelay", "size"))
    .b(clockDiv.fromTo("div", "divisor"))
    .b(prob.fromTo("prob", "chance"))
    .b(timeAttn.fromTo("time", "ratio"))
  ;


  timeAttn
    => mk(Delay, samp).from(recv("ratio")).c
    => clockDeltaTime.c
    => timeAttn.to(P_Trigger).c
  ;


  def(trigOut, root
    => clockDiv.listen(P_Trigger).c
    => prob.c
    => clockDly.c
    => timeDly.c
  );

  trigOut.setName("riot_knobOut");

  timeAttn => timeDly.to("delay").c;

  root => clockDly.to(P_Clock).c;

  samp => now;

  clockDiv.set("divisor", 0);

  return mk(Wrapper, root, trigOut);

}

fun ModuckP triggerRiot(){
  4 => int gridSize;

  defl(sideOuts, makeOuts(gridSize));
  defl(bottomOuts, makeOuts(gridSize));

  defl(knobs, makeKnobs(gridSize*gridSize));

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
      inKeys << "clockDelay"+x+""+y;
    }
  }

  def(root, mk(Repeater, inKeys));
  def(mainOut, mk(Repeater, outKeys).setName("riot_mainOut"))


  for(0=>int x;x<gridSize;++x){ 
    bottomOuts[x] => mainOut.to("bottom"+x).c;
    for(0=>int y;y<gridSize;++y){ 
      x+y*gridSize => int ind;
      knobs[ind] @=> ModuckP knob;

      root
        .b(knob.listen(P_Trigger))
        .b(knob.fromTo("clockDelay"+x+""+y, "clockDelay"))
        .b(knob.fromTo("div"+x+""+y, "div"))
        .b(knob.fromTo("prob"+x+""+y, "prob"))
        .b(knob.fromTo("time"+x+""+y, "time"))
      ;

      knob
        .b(sideOuts[y])
        .b(bottomOuts[x])
      ;
    }
  }

  for(0=>int y;y<gridSize;++y){ 
    sideOuts[y] => mainOut.to("side"+y).c;
  }

  samp => now;
  return mk(Wrapper, root, mainOut);
}



fun ModuckP[] makeKnobs(int count){
  ModuckP ret[count];

  for(0=>int i;i<count;++i){
    makeKnob() @=> ret[i];
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

