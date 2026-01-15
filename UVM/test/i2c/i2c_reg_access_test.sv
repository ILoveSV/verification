
`ifndef I2C_REG_ACCESS_TEST_SV
`define I2C_REG_ACCESS_TEST_SV

class i2c_reg_access_test extends i2c_base_test;

  `uvm_component_utils(i2c_reg_access_test)

  function new(string name = "i2c_reg_access_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // TODO
    // modify components' configurations

  endfunction

  task run_phase(uvm_phase phase);
    i2c_reg_access_virt_seq seq = i2c_reg_access_virt_seq::type_id::create("seq");
    phase.raise_objection(this);
    `uvm_info("SEQ", "sequence starting", UVM_LOW)
    seq.start(env.sqr);
    `uvm_info("SEQ", "sequence finished", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass

`endif // I2C_REG_ACCESS_TEST_SV
