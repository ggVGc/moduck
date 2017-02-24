

fun ModuckP triggerRiot(){
  4 => int gridSize;

  defl(sideOuts, makeOuts(gridSize));
  defl(bottomOuts, makeOuts(gridSize));

  defl(clockDivs, makeDivs(gridSize));
  defl(probabilities, mkMany(Probably, gridSize*gridSize, 100));
  defl(clockDelays, mkMany(PulseDelay, gridSize*gridSize, 0));
  defl(timeDelays, mkMany(Delay, gridSize*gridSize, 0::samp))
  defl(timeAttenuators, mkMany(Attenuator, gridSize*gridSize,0,100))


  string inKeys[0];
  string outKeys[0];

  inKeys << P_Trigger;

  for(0=>int i;i<gridSize*gridSize;++i){ 
  }
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
  def(mainOut, mk(Repeater, outKeys))


  def(clockDeltaTime, mk(Value, Util.toSamples(100::ms)))

  for(0=>int x;x<gridSize;++x){ 
    bottomOuts[x] => mainOut.to("bottom"+x).c;
    for(0=>int y;y<gridSize;++y){ 
      x+y*gridSize => int ind;

      clockDivs[ind] @=> ModuckP div;
      clockDelays[ind] @=> ModuckP dly;
      probabilities[ind] @=> ModuckP prob;
      timeDelays[ind] @=> ModuckP timeDly;
      timeAttenuators[ind] @=> ModuckP timeAttn;

      root
        .b(dly.fromTo("clockDelay"+x+""+y, "size"))
        .b(div.fromTo("div"+x+""+y, "divisor"))
        .b(prob.fromTo("prob"+x+""+y, "chance"))
        .b(timeAttn.fromTo("time"+x+""+y, "ratio"))
      ;

      timeAttn
        => mk(Delay, samp).from(recv("ratio")).c
        => clockDeltaTime.c
        => timeAttn.to(P_Trigger).c
      ;

      timeAttn => timeDly.to("delay").c;


      def(trigOut, root
        => div.listen(P_Trigger).c
        => prob.c
        => dly.c
        => timeDly.c
      );

      root => dly.to(P_Clock).c;

      trigOut
        .b(sideOuts[y])
        .b(bottomOuts[x])
      ;

      samp => now;
      clockDeltaTime.doHandle(P_Trigger, 0);


    }
  }

  for(0=>int y;y<gridSize;++y){ 
    sideOuts[y] => mainOut.to("side"+y).c;
  }

  samp => now;
  return mk(Wrapper, root, mainOut);
}



fun ModuckP[] makeDivs(int gridSize){
  ModuckP divs[gridSize*gridSize];

  for(0=>int x;x<gridSize;++x){
    for(0=>int y;y<gridSize;++y){
      mk(PulseDiv, 0) @=> divs[x+y*gridSize];
    }
  }
  return divs;
}

fun ModuckP[] makeOuts(int count){
  ModuckP ret[count];
  for(0=>int x;x<count;++x){
    mk(Repeater) @=> ret[x];
  }
  return ret;
}



