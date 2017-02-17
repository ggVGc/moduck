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


genHandler(TrigHandler, Pulse.Trigger(), 
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
      /* <<< "NOTEOUT:" +tag +":"+v>>>; */
      MidiMsg msg;
      144 + channel => msg.data1; // NoteOn
      int note;

      /* if(tag == Pulse.Trigger()){ */
        // TODO: Implement again
        /* parent.getVal("note")  => note; */
      /* }else{ */
        // Trigger with received note value
        v => note;
      /* } */


      note => msg.data2;
      parent.getVal("velocity") => msg.data3;
      parent.getVal("durRatio") / 127.0 => float durMul;
      maxDur - minDur => dur deltaDur;
      minDur + deltaDur * durMul => dur duration;
      offSender.noteOff(note, duration);
      midOut.send(msg);
      parent.send(Pulse.Trigger(), v);
  },
  int devicePort;
  int channel;
  dur minDur;
  dur maxDur;
)



public class NoteOut extends Moduck{
  fun static NoteOut make(int devicePort, int channel, dur minDur, dur maxDur){
    NoteOut ret;
    OUT(Pulse.Trigger());
    ret.setVal("velocity", 110);
    ret.setVal("note", 64);
    ret.setVal("durRatio", 127);
    IN(TrigHandler, (devicePort, channel, minDur, maxDur));
    return ret;
  }
}
