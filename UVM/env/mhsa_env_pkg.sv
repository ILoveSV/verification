`ifndef MHSA_ENV_PKG_SV
`define MHSA_ENV_PKG_SV
package mhsa_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import mhsa_pkg::*; // IMPORTANT!!!!!

  `include "mhsa_config.svh"
  `include "mhsa_scb.sv"
  `include "mhsa_virtual_sequencer.sv"
  `include "mhsa_env.sv"
  `include "mhsa_test.svh"

endpackage

`endif // MHSA_ENV_PKG_SV
