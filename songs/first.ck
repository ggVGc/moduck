


110 => BPM;
<<<B4>>>;


define(BASS_PORT, MIDI_OUT_MS_20)
define(MELO_PORT, 0)

TIME_PER_BEAT/8 => dur maxNoteLen;

Offset.make(-12) @=> Offset offsetter;

noteDiddler(MELO_PORT, maxNoteLen, 
  [1,3,5,3,4,2,6,4]
  ,[10]
  ,[B2]
  ,[1.0]
  ,C(offsetter, Offset.make(6))
) @=> Moduck melo;


noteDiddler(BASS_PORT, maxNoteLen, 
  [1,3,5,3,4,2,6,4]
  ,[10]
  ,[B4]
  ,[1.0]
  ,offsetter
) @=> Moduck bass;

chain(masterClock, [
  X(PulseDiv.make(B2*2, true))
  /* ,X(seq([-12, -12, -15, -9])) */
  ,X(seq([-12, -12, -12, -12, -10, -9, -7, -14]))
  ,XV(offsetter, "offset")
]);



C(multi(masterClock,[X(bass), X(melo)]), Printer.make(""));
