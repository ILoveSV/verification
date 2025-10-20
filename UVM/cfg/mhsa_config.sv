`ifndef MHSA_CONFIG_SV
`define MHSA_CONFIG_SV
class mhsa_cfg extends uvm_object;
  `uvm_object_utils(mhsa_cfg)

  // Configuration subcomponents
  apb_mstr_agent_config apb_mstr_agnt_cfg;

  // Constructor
  function new(string name="mhsa_cfg");
    super.new(name);
    apb_mstr_agnt_cfg=new("apb_mstr_agnt_cfg");
  endfunction:new

endclass
`endif // MHSA_CONFIG_SV
