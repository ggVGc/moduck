include(moduck_macros.m4)

class Responder extends MIDIFlowerPetal{
  Moduck parent;

  fun static Responder make(Moduck m){
    Responder ret;
    m @=> ret.parent;
    return ret;
  }


  0 => int ccCount;
  0 => int noteCount;


  function void noteOn(int key, int velocity){
    if(velocity == 0){
      _onNoteOff(key, velocity);
    }else{
      ++noteCount;
      parent.send("velocity", IntRef.make(velocity));
      samp => now;
      parent.send("note"+key, IntRef.make(velocity));
      parent.send("note", IntRef.make(key));
    }
  }


  function void controlChange(int controller, int value) {
    ccCount => int lastCount;
    if(value == 0){
      --ccCount;

      parent.send("ccValue", IntRef.make(0));
      samp => now;
      parent.send("cc", IntRef.make(controller));
      parent.send("cc"+controller, IntRef.make(value));
      samp => now;
      parent.send("cc"+controller, null);

    }else{
      ++ccCount;
      parent.send("ccValue", IntRef.make(value));
      samp => now;
      parent.send("cc", IntRef.make(controller));
      parent.send("cc"+controller, IntRef.make(value));
    }

    if(ccCount < 0 || lastCount < 0){
      WARNING("CC count less than 0. This is a bug.");
    }else if(ccCount == 0){
      parent.send("ccValue", null);
      samp => now;
      parent.send("cc", null);
    }
  }

  fun void _onNoteOff(int key, int velocity){
    noteCount => int lastCount;
    --noteCount;
    parent.send("note"+key, null);

    if(lastCount == 0 && noteCount>0){
      parent.send("note", IntRef.make(key));
    }else if(noteCount < 0 || lastCount < 0){
      WARNING("Note count less than 0. This is a bug.");
    }else if(noteCount == 0){
      parent.send("velocity", null);
      samp => now;
      parent.send("note", null);
    }
  }


  function void noteOff(int key, int velocity){
    this.events()[key].signal();
    _onNoteOff(key, velocity);
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
    for(0=>int i;i<128;++i){
      OUT("cc"+i);
      OUT("note"+i);
    }
    OUT("note");
    OUT("cc");
    OUT("program");
    OUT("channelPressure");
    OUT("keyPressure");
    OUT("ccValue");
    OUT("velocity");
    return ret;
  }
}
