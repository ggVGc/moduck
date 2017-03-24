include(macros.m4)

genHandler(GateHandler, P_Gate, 
    MidiOut midOut;
    null @=> IntRef lastVal;

    fun void init(){
      midOut.open(devicePort) => int success;
      if(!success){
        <<< "Error: Failed opening midi device: " + devicePort >>>;
      }
    }


    fun void sendNoteOff(int n){
      MidiMsg msg;
      128 + channel => msg.data1; // NoteOff
      n => msg.data2;
      midOut.send(msg);
    }


    HANDLE{
      if(NoteOut.enabled){
        if(null != v){
          // Note on

          if(null != lastVal){
            sendNoteOff(lastVal.i);
          }

          /* <<< "NOTEOUT:" +tag +":"+v>>>; */
          MidiMsg msg;
          144 + channel => msg.data1; // NoteOn

          /* if(tag == P_Trigger){ */
            // TODO: Implement again
            /* parent.getVal("note")  => note; */
          /* }else{ */
            // Trigger with received note value
            // v => note;
          /* } */

          int note;
          if(valueIsVelocity){
            parent.getVal("note") => note;
            v.i => msg.data3;
          }else{
            v.i => note;
            parent.getVal("velocity") => msg.data3;
          }

          IntRef.make(note) @=> lastVal;

          note => msg.data2;
          midOut.send(msg);
        }else{
          // Note off
          if(null != lastVal){
            sendNoteOff(lastVal.i);
          }
        }
      }
      parent.send(P_Gate, v);
  },
  int devicePort;
  int channel;
  int valueIsVelocity;
)



public class NoteOut extends Moduck{
  static int enabled;
  fun static NoteOut make(int devicePort, int channel, int valueIsVelocity){
    NoteOut ret;
    OUT(P_Gate);
    IN(GateHandler, (devicePort, channel, valueIsVelocity));

    ret.addVal("velocity", 110);
    ret.addVal("note", 64);

    return ret;
  }
  fun static NoteOut make(int devicePort, int channel, dur dummy1, dur dummy2, int valueIsVelocity){
    // TODO: Fix any call sites using this constructor
    Machine.crash();
  }

}

true => NoteOut.enabled;

