`ifndef MHSA_VIRTUAL_SEQUENCER_SV
`define MHSA_VIRTUAL_SEQUENCER_SV

class mhsa_virtual_sequencer extends uvm_sequencer;

  // Configuration and sub-sequencer handles
  mhsa_config cfg;
//  apb_master_sequencer apb_mst_sqr;
//  mhsa_mstr_sequencer mhsa_sqr;

  `uvm_component_utils(mhsa_virtual_sequencer)

  function new(string name = "mhsa_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get configuration from test layer
    if(!uvm_config_db#(mhsa_config)::get(this, "", "cfg", cfg)) begin
      `uvm_fatal("GETCFG", "cannot get mhsa_config object from config DB")
    end
  endfunction

endclass

`endif
