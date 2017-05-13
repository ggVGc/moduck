include(moduck_macros.m4)

genHandler(TrigHandler, P_Trigger,
  HANDLE{
    FileIO fout;
    fout.open(fileName, FileIO.WRITE );

    // test
    if(!fout.good()){
      cherr <= "can't open file for writing...: "+fileName <= IO.newline();
      me.exit();
    }

    // write some stuff
    fout <= v;

    // close the thing
    fout.close();

    parent.send(P_Trigger, v);
  },
  string fileName;
)


public class Persistent extends PersistentBase{
  string fileName;

  static PersistentBase @ all[];

  fun static void restoreAll(){
    for(0=>int i;i<all.size();++i){
      all[i].restore();
    }
  }

  fun void restore(){
    FileIO fio;

    // open a file
    fio.open( fileName, FileIO.READ );

    // ensure it's ok
    if( !fio.good() ){
        cherr <= "can't open file: " <= fileName <= " for reading..." <= IO.newline();
    }else{
      // variable to read into
      int val;

      // loop until end
      fio => val;
      <<< "restore", val >>>;

      doHandle(P_Trigger, val);
    }
  }

  fun static Persistent make(string fileName){
    Persistent ret;
    "../vals/"+fileName @=> fileName;
    fileName @=> ret.fileName;
    OUT(P_Trigger);
    IN(TrigHandler, (fileName));
    ret.addVal("value", 0);
    all << ret;
    return ret;
  }
}

PersistentBase b[0];
b @=> Persistent.all;
