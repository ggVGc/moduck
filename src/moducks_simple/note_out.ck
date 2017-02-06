
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


public class NoteOut extends Moduck{
  MidiOut midOut;
  NoteOffSender offSender;
  int channel;
  dur minDur;
  dur maxDur;

  fun int handle(string tag, int v){
    /* <<< "NOTEOUT:" +tag +":"+v>>>; */
    MidiMsg msg;
    144 + channel => msg.data1; // NoteOn
    int note;
    if(tag == Pulse.Trigger()){
      // Only gate, use set note val
      getVal("note")  => note;
    }else{
      // Trigger with received note value
      v => note;
    }
    note => msg.data2;
    getVal("velocity") => msg.data3;
    getVal("durRatio") / 127.0 => float durMul;
    maxDur - minDur => dur deltaDur;
    minDur + deltaDur * durMul => dur duration;
    offSender.noteOff(note, duration);
    midOut.send(msg);
    return true;
  }


  fun static NoteOut make(int devicePort, int channel, dur minDur, dur maxDur){
    NoteOut ret;
    minDur => ret.minDur;
    maxDur => ret.maxDur;
    channel => ret.channel;
    ret.midOut.open(devicePort) => int success;
    if(!success){
      <<< "Error: Failed opening midi device: " + devicePort >>>;
    }
    ret.midOut @=> ret.offSender.out;
    channel => ret.offSender.channel;
    ret.setVal("velocity", 127);
    ret.setVal("note", 64);
    ret.setVal("durRatio", 63);
    ret.setVal("duration", Util.toSamples(300::ms));
    return ret;
  }
}
