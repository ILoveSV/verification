`ifndef AHBRAM_HADDR_WORD_UNALIGNED_TEST_SV
`define AHBRAM_HADDR_WORD_UNALIGNED_TEST_SV

class ahbram_haddr_word_unaligned_test extends ahbram_base_test;
  `uvm_component_utils(ahbram_haddr_word_unaligned_test)

  // Constructor
  function new (string name = "ahbram_haddr_word_unaligned_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    ahbram_haddr_word_unaligned_virt_seq seq = ahbram_haddr_word_unaligned_virt_seq::type_id::create("seq");
    super.run_phase(phase);
    phase.raise_objection(this);
    seq.start(env.virt_sqr);
    phase.drop_objection(this);
  endtask

endclass

`endif // AHBRAM_HADDR_WORD_UNALIGNED_TEST_SV
