`ifndef I2C_PKG_SV
`define I2C_PKG_SV

package i2c_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import lvc_apb_pkg::*;
  import lvc_i2c_pkg::*;
  `include "i2c_defines.svh"

  `include "ral_i2c.sv"
  `include "i2c_configs.svh"
  `include "i2c_master_scoreboard.sv"
  `include "i2c_cgm.sv"
  `include "i2c_virtual_sequencer.sv"
  `include "i2c_env.sv"
  `include "i2c_element_sequences.svh"
//  `include "i2c_user_element_sequences.svh"
  `include "i2c_virtual_sequences.svh"
//  `include "i2c_user_virtual_sequences.svh"
  `include "i2c_tests.svh"
//  `include "i2c_user_tests.svh"

endpackage

`endif // I2C_PKG_SV
