import uvm_pkg::*;
class mhsa_mstr_agent_config extends uvm_object;
  `uvm_object_utils(mhsa_mstr_agent_config)

  // Configuration subcomponents
  uvm_active_passive_enum is_active = UVM_PASSIVE;
  virtual apb_interface apb_intf;

  // Constructor
  function new(string name="mhsa_mstr_agent_config");
    super.new(name);
  endfunction

endclass:mhsa_mstr_agent_config

