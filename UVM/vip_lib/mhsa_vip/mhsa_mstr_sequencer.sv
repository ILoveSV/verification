
class apb_mstr_sequencer extends uvm_sequencer#(apb_seq_item,apb_seq_item);
  `uvm_component_utils(apb_mstr_sequencer)

  // Constructor
  function new(string name="apb_mstr_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction:build_phase

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass:apb_mstr_sequencer
