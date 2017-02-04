
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


public class NoteOut extends Handler{
  MidiOut midOut;
  NoteOffSender offSender;
  int channel;

  fun int handle(string tag, int v){
    MidiMsg msg;
    144 + channel => msg.data1; // NoteOn
    int note;
    if(tag != null && tag == "note"){
      // Trigger with received note value
      v => note;
    }else{
      // Only gate, use set note val
      getVal("note")  => note;
    }
    note => msg.data2;
    getVal("velocity") => msg.data3;
    offSender.noteOff(note, getVal("duration")::samp);
    midOut.send(msg);
    return true;
  }

  fun static NoteOut make(int devicePort, int channel){
    NoteOut ret;
    channel => ret.channel;
    ret.midOut.open(devicePort) => int check;
    <<<check>>>;
    ret.midOut @=> ret.offSender.out;
    channel => ret.offSender.channel;
    Util.setVal(ret, "velocity", 127);
    Util.setVal(ret, "note", 64);
    Util.setValRef(ret, "duration", Util.toSamples(300::ms));
    return ret;
  }
}
