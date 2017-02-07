
fun void _body(Moduck clock){
  /* 
   noteDiddler(TIME_PER_BEAT/2
     ,[0,1,2,3]
     ,[70, 72, 74, 76]
     ,[B2, B2, B2, B4, B4, B4, B2]
     ,[1.0, .7, .6]
     ,null
   );
   */
}

fun void __body(Moduck clock){
  Scales.Major @=> int noteVals[];
  68 => int rootNote;

  /* 
   multi(clock, [
     X(noteDiddler(TIME_PER_BEAT/8
       ,[2]
       ,noteVals
       ,[B]
       ,[1.0]
       ,Offset.make(rootNote)
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[1]
       ,noteVals
       ,[B]
       ,[1.0]
       ,C(Offset.make(rootNote), Delay.make(30::ms))
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[3]
       ,noteVals
       ,[B, B4, 3 * B, B2, B4, B2]
       ,[1.0]
       ,Offset.make(rootNote-12)
     ))
     ,X(noteDiddler(TIME_PER_BEAT/8
       ,[1,3,2,5]
       ,noteVals
       ,[B2* 3]
       ,[.2, .3, .4, .5, .6, .8, .9, .1, .2]
       ,Offset.make(rootNote+14)
     ))
   ]);
   */
}


fun void scaleTest(Moduck clock){
  72 => int rootNote;
  C(clock, noteDiddler(0, TIME_PER_BEAT/4
    ,[-7, -9, -10, -11, -10, -9, -8, -7, -4, -2, 0,1,2,3,4,5,6,7,8, 9]
    ,Scales.MinorHarmonic
    ,[B]
    ,[1.0]
    ,C(Offset.make(rootNote), Printer.make(""))
  ));
}

fun void dualMelo(Moduck clock, NoteOut noteOut){
  // Connect two looping sequencers to a clock

  Sequencer.make([60, 58], true) @=> Sequencer s;

  multi(clock, [
     X(chain(PulseDiv.make(3, true),[ // Divide clock so this triggeres every third pulse
         X(Sequencer.make([66, 67, 69], true)) // Three notes, looping
         ,X(noteOut)
     ]))
     ,X(C2(s, Pulse.Stepped(), noteOut, null)) // Play note 60 every clock tick
    ]
  );

  C2(s, Pulse.Looped(), Printer.make("Looped"), null);

  chain(C(clock, PulseDiv.make(99999999, true)), [
    X(Delay.make(2::second))
    ,X(Value.make(50))
    ,X1(s, Pulse.Set())
    ,X2(Pulse.Set(), Delay.make(5::second), null) // will keep triggering, but doesn't matter
    ,X(Value.make(55))
    ,X1(s, Pulse.Set())
  ]);
}

fun void testConnectDouble(Moduck clock, NoteOut noteOut){
  Sequencer.make([60, 62], true) @=> Sequencer s;

  C(clock, s);


 chain(C(clock, PulseDiv.make(10000, true)), [
   X(Delay.make(2::second))
   ,X(Value.make(50))
   ,X1(s, Pulse.Set())
 ]);
}



fun void routerTest(Moduck clock, NoteOut noteOut){
  seq([68,65,63]) @=> Sequencer s1;
  seq([60,62,64]) @=> Sequencer s2;
  seq([0,1]) @=> Sequencer indexer;

  Router.make(1) @=> Router router;

  MUtil.combine([MUtil.mul2(s1, s2), MUtil.add2(s1, s2)]) @=> Moduck combined;
  C(combined, Printer.make("")) @=> Moduck mult;

  // Send router output to sequencers, and finally to noteOut
 chain(
   multi(router,[
     X2("0", s1, null) // Connect s1 to router index 0
     ,X2("1", s2, null) // Connect s2 to router index 1
   ])
   , [X(noteOut)]
 );

 multi(clock,[
   // Send pulses, divided by 6, to sequencer controlling router index
   X(chain(PulseDiv.make(6, false), [
       X(indexer)                    
       ,XV(router, "index")
     ]
   ))
   ,X( router ) // Send pulses to router to be forwarded to active sequencer
   ,X(combined)
 ]);
}
