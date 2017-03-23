include(macros.m4)

class NoteOffSender{
  MidiOut@ out;
  int channel;

  fun void _f(int n, dur d){
    MidiMsg msg;
    128 + channel => msg.data1; // NoteOff
    n => msg.data2;
    d => now;
    out.send(msg);
  }

  fun void noteOff(int noteNum, dur d){
    spork ~ _f(noteNum, d);
  }
}


genHandler(TrigHandler, P_Trigger, 
    MidiOut midOut;
    NoteOffSender offSender;

    fun void init(){
      channel => offSender.channel;
      midOut.open(devicePort) => int success;
      if(!success){
        <<< "Error: Failed opening midi device: " + devicePort >>>;
      }
      midOut @=> offSender.out;
    }

    HANDLE{
      if(NoteOut.enabled){
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
          v => msg.data3;
        }else{
          v => note;
          parent.getVal("velocity") => msg.data3;
        }

        note => msg.data2;
        parent.getVal("durRatio") / 127.0 => float durMul;
        maxDur - minDur => dur deltaDur;
        minDur + deltaDur * durMul => dur duration;
        offSender.noteOff(note, duration);
        midOut.send(msg);
      }
      parent.send(P_Trigger, v);
  },
  int devicePort;
  int channel;
  dur minDur;
  dur maxDur;
  int valueIsVelocity;
)



public class NoteOut extends Moduck{
  static int enabled;
  fun static NoteOut make(int devicePort, int channel, dur minDur, dur maxDur, int valueIsVelocity){
    NoteOut ret;
    OUT(P_Trigger);
    IN(TrigHandler, (devicePort, channel, minDur, maxDur, valueIsVelocity));

    ret.addVal("velocity", 110);
    ret.addVal("note", 64);
    ret.addVal("durRatio", 127);

    return ret;
  }
}

true => NoteOut.enabled;

