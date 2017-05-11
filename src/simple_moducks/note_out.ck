include(macros.m4)

fun void sendNoteOff(MidiOut device, MidiMsg @ msg, int n, int channel, int isCC){
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
    null @=> IntRef lastNote;
    HANDLE{
      if(lastNote != null){
        sendNoteOff(device, msg, lastNote.i, channel, false);
        null @=> lastNote;
      }
      if(v != null){
        sendNoteOn(device, msg, v.i, parent.getVal("velocity"), channel, false);
        v @=> lastNote;
      }
    },
    MidiOut device;
    MidiMsg msg;
    int channel;
)

class GateHandler extends EventHandler{
  MidiOut device;
  int channel;
  int noteNum;
  int isCC;
  MidiMsg @ msg;
  fun void handle(IntRef v){
    if(v != null){
      sendNoteOn(device, msg, noteNum, v.i, channel, isCC);
    }else{
      sendNoteOff(device, msg, noteNum, channel, isCC);
    }
  }

  fun static GateHandler make(MidiOut device, MidiMsg @ msg, int channel, int noteNum, int isCC){
    GateHandler ret;
    msg @=> ret.msg;
    channel => ret.channel;
    device @=> ret.device;
    noteNum => ret.noteNum;
    isCC => ret.isCC;
    return ret;
  }
}



public class NoteOut extends Moduck{
  static int enabled;
  fun static NoteOut make(MidiOut @ device, int channel){
    NoteOut ret;
    OUT(P_Gate);
    MidiMsg msg;
    IN(NoteHandler, (device, msg, channel));
    for(0=>int i;i<128;++i){
      ret.addIn("note"+i, GateHandler.make(device, msg, channel, i, false));
      ret.addIn("cc"+i, GateHandler.make(device, msg, channel, i, true));
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

