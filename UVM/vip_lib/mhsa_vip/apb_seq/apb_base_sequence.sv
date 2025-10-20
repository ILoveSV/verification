
class apb_base_sequence extends uvm_sequence#(apb_seq_item,apb_seq_item);
  `uvm_object_utils(apb_base_sequence)

  // Constructor
  function new(string name="apb_base_sequence");
    super.new(name);
  endfunction


endclass

