include(macros.m4)


class Responder extends MIDIFlowerPetal{
  Moduck parent;


  fun static Responder make(Moduck m){
    Responder ret;
    m @=> ret.parent;
    return ret;
  }

  function void noteOn(int key, int velocity){
    parent.send("value", velocity);
    samp => now;
    parent.send("noteOn", key);
  }

 function void controlChange(int controller, int value) {
    parent.send("value", value);
    samp => now;
    parent.send("cc", controller);
 }

 function void noteOff(int key, int velocity){
      this.events()[key].signal();
      parent.send("value", velocity);
      samp => now;
      parent.send("noteOff", key);
    }


 function void channelPressure(int pressure) {
    parent.send("channelPressure", pressure);
 }
 function void keyPressure(int pressure) {
    parent.send("keyPressure", pressure);
 }

 function void programChange(int program) {
    parent.send("program", program);
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
    OUT("noteOn");
    OUT("noteOff");
    OUT("cc");
    OUT("program");
    OUT("channelPressure");
    OUT("keyPressure");
    OUT("value");
    return ret;
  }
}
