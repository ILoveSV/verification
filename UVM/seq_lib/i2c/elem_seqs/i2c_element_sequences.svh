
`ifndef I2C_ELEMENT_SEQUENCES_SVH
`define I2C_ELEMENT_SEQUENCES_SVH

`include "apb_base_sequence.sv"
`include "apb_config_seq.sv"
`include "apb_write_packet_seq.sv"
`include "apb_read_packet_seq.sv"
`include "apb_wait_empty_seq.sv"
`include "apb_intr_enable_seq.sv"
`include "apb_intr_wait_seq.sv"
`include "apb_intr_clear_seq.sv"

`include "i2c_slave_base_sequence.sv"
`include "i2c_slave_write_response_seq.sv"
`include "i2c_slave_read_response_seq.sv"


`endif // I2C_ELEMENT_SEQUENCES_SVH
