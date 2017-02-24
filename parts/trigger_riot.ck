

fun ModuckP triggerRiot(){
  4 => int gridSize;
  defl(divs, makeDivs(gridSize));

  defl(sideOuts, makeOuts(gridSize));
  defl(bottomOuts, makeOuts(gridSize));

  defl(probabilities, mkMany(Probably, gridSize*gridSize, 100));
  defl(clockDelays, mkMany(PulseDelay, gridSize*gridSize, 0));


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
      inKeys << "clockDelay"+x+""+y;
    }
  }

  def(root, mk(Repeater, inKeys));
  def(mainOut, mk(Repeater, outKeys))

  for(0=>int x;x<gridSize;++x){ 
    bottomOuts[x] => mainOut.to("bottom"+x).c;
    for(0=>int y;y<gridSize;++y){ 
      x+y*gridSize => int ind;

      clockDelays[ind] @=> ModuckP dly;

      probabilities[ind] @=> ModuckP prob;

      def(trigOut, root
        => divs[ind].listen(P_Trigger).c
        => prob.c
        => mkc(Printer, "TRI")
        => dly.c
      );

      root => dly.to(P_Clock).c;

      (trigOut => mkc(Printer, "out"))
        .b(sideOuts[y])
        .b(bottomOuts[x])
      ;


      root => clockDelays[ind].fromTo("clockDelay"+x+""+y, "size").c;
      root => divs[ind].fromTo("div"+x+""+y, "divisor").c;

      root => probabilities[ind].fromTo("prob"+x+""+y, "chance").c;
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



