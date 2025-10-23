`ifndef MHSA_MSTR_SEQUENCER_SV
`define MHSA_MSTR_SEQUENCER_SV
class mhsa_mstr_sequencer extends mhsa_sequencer;
  `uvm_component_utils(mhsa_mstr_sequencer)

  // Constructor
  function new(string name="mhsa_mstr_sequencer",uvm_component parent);
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

endclass:mhsa_mstr_sequencer
`endif // MHSA_MSTR_SEQUENCER_SV
