include(moduck_macros.m4)

fun void sendNoteOff(MidiOut device, MidiMsg @ msg, int n, int channel, int isCC, int zeroVelNoteOff){
  if(zeroVelNoteOff){
    sendNoteOn(device, msg, n, 0, channel, false);
  }else{
    if(isCC){
      176 + channel => msg.data1; // NoteOff
      n => msg.data2;
    }else{
      128 + channel => msg.data1; // NoteOff
      n => msg.data2;
    }
    0 => msg.data3;
    device.send(msg);
  }
}

fun void sendNoteOn(MidiOut device, MidiMsg @ msg, int n, int velocity, int channel, int isCC){
  if(isCC){
    176 + channel => msg.data1; // NoteOn
    n => msg.data2;
  }else{
    144 + channel => msg.data1; // NoteOn
    n => msg.data2;
  }
  velocity => msg.data3;
  device.send(msg);
}


genHandler(NoteHandler, "note", 
    MayInt lastNote;
    int lastNoteVal;
    HANDLE{
      if(lastNote.valid){
        sendNoteOff(device, msg, lastNote.i, channel, false, zeroVelNoteOff);
      }
      if(v != null){
        sendNoteOn(device, msg, v.i, parent.getVal("velocity"), channel, false);
        lastNote.set(v.i);
      }
    },
    MidiOut device;
    MidiMsg msg;
    int channel;
    int zeroVelNoteOff;
)

class GateHandler extends EventHandler{
  MidiOut device;
  int channel;
  int noteNum;
  int isCC;
  int zeroVelNoteOff;
  MidiMsg @ msg;
  fun void handle(IntRef v){
    if(v != null){
      sendNoteOn(device, msg, noteNum, v.i, channel, isCC);
    }else{
      sendNoteOff(device, msg, noteNum, channel, isCC, zeroVelNoteOff);
    }
  }

  fun static GateHandler make(MidiOut device, MidiMsg @ msg, int channel, int noteNum, int isCC, int zeroVelNoteOff){
    GateHandler ret;
    msg @=> ret.msg;
    channel => ret.channel;
    device @=> ret.device;
    noteNum => ret.noteNum;
    isCC => ret.isCC;
    zeroVelNoteOff => ret.zeroVelNoteOff;
    return ret;
  }
}



public class NoteOut extends Moduck{
  static int enabled;
  fun static NoteOut make(MidiOut @ device, int channel){
    return make(device, channel, false);
  }

  fun static NoteOut make(MidiOut @ device, int channel, int zeroVelNoteOff){
    NoteOut ret;
    OUT(P_Gate);
    MidiMsg msg;
    IN(NoteHandler, (device, msg, channel, zeroVelNoteOff));
    for(0=>int i;i<128;++i){
      ret.addIn("note"+i, GateHandler.make(device, msg, channel, i, false, zeroVelNoteOff));
      ret.addIn("cc"+i, GateHandler.make(device, msg, channel, i, true, zeroVelNoteOff));
    }
    ret.addVal("velocity", 127);
    return ret;
  }


  fun static NoteOut make(int devicePort, int channel, dur dummy1, dur dummy2, int valueIsVelocity){
    // TODO: Fix any call sites using this constructor
    <<<"USING INCORRECT NOTEOUT CONSTRUCTOR!">>>;
    Machine.crash();
  }

}

true => NoteOut.enabled;

