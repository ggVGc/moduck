include(macros.m4)

// TODO: This whole file is old, temporary and needs to be rewritten similar to MidInp


genHandler(GateHandler, P_Gate, 
    null @=> IntRef lastVal;

    fun void sendNoteOff(int n, ModuckBase parent){
      MidiMsg msg;
      if(parent.getVal("isCC")){
        176 + channel => msg.data1; // NoteOff
        n => msg.data2;
      }else{
        128 + channel => msg.data1; // NoteOff
        n => msg.data2;
      }
      0 => msg.data3;
      midOut.send(msg);
    }


    HANDLE{
      if(NoteOut.enabled){
        if(null != v){
          // Note on

          if(null != lastVal){
            sendNoteOff(lastVal.i, parent);
          }

          /* <<< "NOTEOUT:" +tag +":"+v>>>; */
          MidiMsg msg;
          if(parent.getVal("isCC")){
            176 + channel => msg.data1; // NoteOn
          }else{
            144 + channel => msg.data1; // NoteOn
          }

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
            sendNoteOff(lastVal.i, parent);
          }
        }
      }
      parent.send(P_Gate, v);
  },
  int channel;
  int valueIsVelocity;
  MidiOut @ midOut;
)



public class NoteOut extends Moduck{
  static int enabled;
  fun static NoteOut make(MidiOut @ device, int channel, int valueIsVelocity){
    NoteOut ret;
    OUT(P_Gate);
    IN(GateHandler, (channel, valueIsVelocity, device));

    ret.addVal("velocity", 110);
    ret.addVal("note", 64);

    ret.addVal("isCC", false);

    return ret;
  }
  fun static NoteOut make(int devicePort, int channel, dur dummy1, dur dummy2, int valueIsVelocity){
    // TODO: Fix any call sites using this constructor
    <<<"USING INCORRECT NOTEOUT CONSTRUCTOR!">>>;
    Machine.crash();
  }

}

true => NoteOut.enabled;

