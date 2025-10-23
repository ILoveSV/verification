`ifndef MHSA_SEQUENCER_SV
`define MHSA_SEQUENCER_SV

class mhsa_sequencer #(type REQ = mhsa_base_seq_item, type RSP = REQ) extends uvm_sequencer #(REQ, RSP);
  `uvm_component_utils(mhsa_sequencer)

  function new(string name = "mhsa_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass


`endif // MHSA_SEQUENCER_SV
