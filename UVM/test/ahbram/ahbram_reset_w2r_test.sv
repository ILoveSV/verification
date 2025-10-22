`ifndef AHBRAM_RESET_W2R_TEST_SV
`define AHBRAM_RESET_W2R_TEST_SV

class ahbram_reset_w2r_test extends ahbram_base_test;
  `uvm_component_utils(ahbram_reset_w2r_test)

  // Constructor
  function new (string name = "ahbram_reset_w2r_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    ahbram_reset_w2r_virt_seq seq = ahbram_reset_w2r_virt_seq::type_id::create("seq");
    super.run_phase(phase);
    phase.raise_objection(this);
    seq.start(env.virt_sqr);
    phase.drop_objection(this);
  endtask

endclass

`endif // AHBRAM_RESET_W2R_TEST_SV
