


120 => BPM;


define(BASS_PORT, MIDI_OUT_MS_20)
define(MELO_PORT, MIDI_OUT_SYSTEM_1)

TIME_PER_BEAT/2 => dur maxNoteLen;

Offset.make(2*12) @=> Offset offsetter;

noteDiddler(MIDI_OUT_SYSTEM_1, maxNoteLen, 
  [1,3,5,3,4,2,6,4]
  ,[10]
  ,[B]
  ,[1.0]
  ,C(offsetter, Offset.make(6))
) @=> Moduck bass;


multi(bass, [
  X(NoteOut.make(MIDI_OUT_MS_20, 0, 0::ms, maxNoteLen))
  ,X(C(Offset.make(3), NoteOut.make(MIDI_OUT_MICROBRUTE, 0, 0::ms, maxNoteLen)))
  ,X(C(Offset.make(6), NoteOut.make(MIDI_OUT_USB_MIDI, 0, 0::ms, maxNoteLen)))
]);



<<<<<<< HEAD

=======
>>>>>>> 59aca1b499f8027a3f7b760e6c61f0a94075aa42
multi(masterClock,[X(bass)]);
