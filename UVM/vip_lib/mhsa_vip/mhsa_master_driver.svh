`ifndef MHSA_MASTER_DRIVER_SVH
`define MHSA_MASTER_DRIVER_SVH 

//`include "mhsa_master_driver.sv"
class mhsa_master_driver extends uvm_driver #(mhsa_base_seq_item);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  mhsa_mstr_agent_config  mhsa_mstr_agnt_cfg;
  uvm_analysis_port#(mhsa_base_seq_item) drv2scb;
  mhsa_base_seq_item item;
   typedef enum {QKV, MAC, MHSA} module_type_e;
   module_type_e module_type;

  `uvm_component_utils_begin(mhsa_master_driver)
    `uvm_field_enum(module_type_e, module_type, UVM_ALL_ON)
    `uvm_field_object(mhsa_mstr_agnt_cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new (string name="mhsa_master_driver", uvm_component parent);
  extern virtual function void build_phase (uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  virtual apb_interface apb_intf;

  extern protected task wr_data(input mhsa_base_seq_item item);

endclass
`endif 
