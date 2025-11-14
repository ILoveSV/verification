`ifndef MHSA_MSTR_AGENT_SVH
`define MHSA_MSTR_AGENT_SVH

class mhsa_mstr_agent extends uvm_agent;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  // Configuration subcomponents
  mhsa_mstr_agent_config  mhsa_mstr_agnt_cfg;
  mhsa_master_driver      mhsa_mstr_drvr;
  mhsa_monitor            mhsa_mntr;
  mhsa_mstr_sequencer     mhsa_mstr_seqr;


  `uvm_component_utils_begin(mhsa_mstr_agent)
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name="mhsa_mstr_agent", uvm_component parent);

  // uvm build phase
  extern virtual function void build_phase(uvm_phase phase);

  // uvm connection phase
  extern virtual function void connect_phase(uvm_phase phase);
  
  // This method assigns the virtual interfaces to the agent's children

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////


endclass : mhsa_mstr_agent

`endif

