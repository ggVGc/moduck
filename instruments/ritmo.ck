

fun ModuckP ritmo(ModuckP rhythms[]){
  def(root, mk(Repeater, [P_Trigger]));


  def(out, mk(Repeater, P_Trigger));

  return mk(Wrapper, root, out);
}
