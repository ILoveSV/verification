`ifndef AHBRAM_ENV_PKG_SV
`define AHBRAM_ENV_PKG_SV
package ahbram_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import lvc_ahb_pkg::*;


  `include "ahbram_reg.sv"
  `include "ahbram_reg_adapter.sv"
  
  `include "ahbram_config.svh"

  `include "ahbram_virtual_sequencer.sv"
  `include "ahbram_subscriber.sv"
  `include "ahbram_scoreboard.sv"
  `include "ahbram_cov.sv"
  `include "ahbram_env.sv"

  `include "ahbram_seq_lib.svh"
  `include "ahbram_tests.svh"

endpackage

`endif // AHBRAM_ENV_PKG_SV
