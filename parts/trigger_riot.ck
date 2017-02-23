

fun ModuckP triggerRiot(){
  4 => int gridSize;
  defl(divs, makeDivs(gridSize));

  defl(sideOuts, makeOuts(gridSize));
  defl(bottomOuts, makeOuts(gridSize));

  defl(probabilities, makeProbabilities(gridSize*gridSize));

  string inKeys[0];
  string outKeys[0];

  inKeys << P_Trigger;

  for(0=>int i;i<gridSize*gridSize;++i){ 
    inKeys << "div"+i;
    inKeys << "prob"+i;
  }
  for(0=>int x;x<gridSize;++x){ 
    outKeys << "side"+x;
    outKeys << "bottom"+x;
  }

  def(root, mk(Repeater, inKeys));
  def(mainOut, mk(Repeater, outKeys))


  for(0=>int x;x<gridSize;++x){ 
    bottomOuts[x] => mainOut.to("bottom"+x).c;
    for(0=>int y;y<gridSize;++y){ 
      x+y*gridSize => int ind;

      root => divs[ind].listen(P_Trigger).c;
      divs[ind] => probabilities[ind].c;
      probabilities[ind] => sideOuts[y].c;
      probabilities[ind] => bottomOuts[x].c;

      root => divs[ind].fromTo("div"+ind, "divisor").c;
      divs[ind] => mk(Printer, "new divisor for div"+ind).from(recv("divisor")).c;
      root => probabilities[ind].fromTo("prob"+ind, "chance").c;
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


fun ModuckP[] makeProbabilities(int count){
  ModuckP ret[count];
  for(0=>int x;x<count;++x){
    mk(Probably, 100) @=> ret[x];
  }
  return ret;
}

