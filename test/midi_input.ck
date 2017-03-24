include(song_macros.m4)
include(_all_parts.m4)


def(inp, mk(MidInp, MIDI_IN_OXYGEN, 0))

inp => mk(Printer, "").from("cc73").c;

Runner.setPlaying(1);

Util.runForever();

