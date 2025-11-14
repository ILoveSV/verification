
`ifndef MHSA_MONITOR_SVH
`define MHSA_MONITOR_SVH

class mhsa_monitor extends uvm_monitor;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////

  mhsa_mstr_agent_config   mhsa_mstr_agnt_cfg;
  virtual apb_interface   apb_intf;
  uvm_analysis_port#(mhsa_base_seq_item) ap;

  mhsa_base_seq_item item;
  typedef enum {QKV, MAC, MHSA} module_type_e;
  module_type_e module_type;

  `uvm_component_utils_begin(mhsa_monitor)
    `uvm_field_enum(module_type_e, module_type, UVM_ALL_ON)
    `uvm_field_object(mhsa_mstr_agnt_cfg, UVM_ALL_ON)
  `uvm_component_utils_end
  extern function new(string name="mhsa_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);


  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////



endclass

`endif // MHSA_MONITOR_SVH

