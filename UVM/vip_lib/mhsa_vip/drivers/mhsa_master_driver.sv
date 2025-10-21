
class mhsa_master_driver extends uvm_driver#(mhsa_base_seq_item);
  `uvm_component_utils(mhsa_master_driver)
  
  // Configuration subcomponents
  mhsa_mstr_agent_config  mhsa_mstr_agnt_cfg;
  virtual apb_interface apb_intf;
  uvm_analysis_port#(mhsa_base_seq_item) drv2scb;

  // Constructor
  function new(string name="mhsa_master_driver", uvm_component parent = null);
    super.new(name,parent);
    drv2scb=new("drv2scb",this);
  endfunction:new

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction:build_phase

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction:connect_phase


endclass:mhsa_master_driver

