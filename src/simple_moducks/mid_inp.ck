include(macros.m4)

class Responder extends MIDIFlowerPetal{
  Moduck parent;

  fun static Responder make(Moduck m){
    Responder ret;
    m @=> ret.parent;
    return ret;
  }


  function void noteOn(int key, int velocity){
    parent.send("value", IntRef.make(velocity));
    samp => now;
    parent.send("note", IntRef.make(key));
  }

  0 => int ccCount;

  function void controlChange(int controller, int value) {
    ccCount => int lastCount;
    if(value == 0){
      ccCount-1 => ccCount;
      parent.send("value", null);
      samp => now;
      parent.send("cc"+controller, null);
    }else{
      ccCount+1 => ccCount;
      parent.send("value", IntRef.make(value));
      samp => now;
      parent.send("cc"+controller, IntRef.make(value));
    }

    if(lastCount == 0 && ccCount>0){
      parent.send("cc", IntRef.make(controller));
    }else if(ccCount < 0 || lastCount < 0){
      WARNING("CC count less than 0. This is a bug.");
    }else{
      parent.send("cc", null);
    }
  }


  function void noteOff(int key, int velocity){
    this.events()[key].signal();
    parent.send("value", null);
    samp => now;
    parent.send("note", null);
  }


  function void channelPressure(int pressure) {
    parent.send("channelPressure", IntRef.make(pressure));
  }


  function void keyPressure(int pressure) {
    parent.send("keyPressure", IntRef.make(pressure));
  }


  function void programChange(int program) {
    parent.send("program", IntRef.make(program));
  }

  /*
     function void system(MidiMsg @message) {
     <<<"system">>>;
     }
   */
}


public class MidInp extends Moduck{

  MIDIFlower @ flower;

  fun static MidInp make(int devicePort, int channel){
    MidInp ret;
    MIDIFlower.make(devicePort) @=> ret.flower;
    ret.flower.assign(Responder.make(ret), channel);
    OUT("note");
    for(0=>int i;i<128;++i){
      OUT("cc"+i);
    }
    OUT("cc");
    OUT("program");
    OUT("channelPressure");
    OUT("keyPressure");
    OUT("value");
    return ret;
  }
}
