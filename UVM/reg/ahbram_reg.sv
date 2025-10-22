`ifndef AHBRAM_REG_SV
`define AHBRAM_REG_SV

class ahbram_rgm extends uvm_reg_block;

  `uvm_object_utils(ahbram_rgm)

  uvm_reg_map map;
  function new(string name = "watchdog_rgm");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function build();
    map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);
    // TODO
    lock_model();
  endfunction


endclass


`endif
