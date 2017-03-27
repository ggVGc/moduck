
include(song_macros.m4)
include(_all_instruments.m4)

def(out, mk(Repeater));



def(lpOut, mk(NoteOut, MIDI_OUT_LAUNCHPAD, 0, false));

def(circuit, mk(NoteOut, MIDI_OUT_CIRCUIT, 0, false));
out => circuit.c;


// MAPPINGS


def(launchpad, mk(MidInp, MIDI_IN_LAUNCHPAD, 0))
def(oxygen, mk(MidInp, MIDI_IN_OXYGEN, 0));
oxygen => lpOut.from("note").c;

oxygen=> out.from("note").c;


/* nanoktrl => mk(Printer, "nanoktrl note").from("note").c; */
/* nanoktrl => mk(Printer, "nanoktrl cc").from("cc").c; */
launchpad => mk(Printer, "note").from("note").c;
oxygen => mk(Printer, "oxygen cc").from("cc").c;


Runner.setPlaying(1);
Util.runForever();

