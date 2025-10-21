
class mhsa_base_sequence extends uvm_sequence#(mhsa_base_seq_item,mhsa_base_seq_item);
  `uvm_object_utils(mhsa_base_sequence)

  // Constructor
  function new(string name="mhsa_base_sequence");
    super.new(name);
  endfunction

endclass

