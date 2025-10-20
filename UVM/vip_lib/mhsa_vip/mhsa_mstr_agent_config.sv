
class apb_mstr_agent_config extends uvm_object;
  `uvm_object_utils(apb_mstr_agent_config)

  // Configuration subcomponents
  uvm_active_passive_enum is_active = UVM_PASSIVE;
  virtual apb_interface apb_intf;

  // Constructor
  function new(string name="apb_mstr_agent_config");
    super.new(name);
  endfunction

endclass:apb_mstr_agent_config

