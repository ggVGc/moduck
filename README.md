# moduck
Modular sequencing in ChucK

Everything is very much still a prototype and very evolving, and the choice of ChucK as the implementation platform was fairly arbitrary, although it's worked out okay so far.

For now, here's a somewhat complex example of what can be done so far.
```javascript
masterClock
  => mk(PulseDiv, Bar*2, 1) // Send pulse every 2 bars
      .map(P_Trigger, P_Reset).propagate(P_Trigger).c // Translate trigger pulse to Reset,
                        // and propagate incoming triggers from masterclock down the chain

  => seqDiv("0.12..", B4, B*3) // Note sequence, 1/4th note per step and 3 beats in total length 
      .propagate(P_Reset).listen([P_Reset, P_Trigger]).c // Propagate Reset pulses down the chain,
                                     // and listen to Triggers for playing notes and Reset pulses.
  
  // Alternate between 2 Offset chains and a blackhole, based on a meta-sequencer.
  => metaSeq("012.", B*3, B*9, [mk(Offset, -3), mk(Offset, 3), mk(Blackhole)])          
      .hook(masterClock.fromTo(P_Trigger, P_Clock)) // Hook up stepping of the meta-sequencer
                                               // to the masterclock, ignoring generated output
      .listen([P_Trigger, P_Reset]).c // Listen to Trigger for playing notes, and Reset pulses
  => octaves(4).c // Transpose 4 octaves
  => mkc(Printer, "out") // Print every output note
  => synth.c // Send to midi output

```
