
`ifndef RKV_I2C_VIRTUAL_SEQUENCES_SVH
`define RKV_I2C_VIRTUAL_SEQUENCES_SVH

`include "rkv_i2c_base_virtual_sequence.sv" 
`include "rkv_i2c_quick_reg_access_virt_seq.sv" 
`include "rkv_i2c_reg_hw_reset_virt_seq.sv" 
`include "rkv_i2c_reg_bit_bash_virt_seq.sv" 
`include "rkv_i2c_reg_access_virt_seq.sv" 
`include "rkv_i2c_master_directed_interrupt_virt_seq.sv" 
`include "rkv_i2c_master_directed_write_packet_virt_seq.sv" 
`include "rkv_i2c_master_directed_read_packet_virt_seq.sv"  
`include "rkv_i2c_master_address_cg_virt_seq.sv"
`include "rkv_i2c_master_tx_status_virt_seq.sv"
`include "rkv_i2c_master_hs_cnt_virt_seq.sv"
`include "rkv_i2c_master_ss_cnt_virt_seq.sv"
`include "rkv_i2c_master_fs_cnt_virt_seq.sv"
`include "rkv_i2c_master_sda_control_cg_virt_seq.sv"
`include "rkv_i2c_master_timeout_cg_virt_seq.sv"
`include "rkv_i2c_master_rx_status_virt_seq.sv"
`endif // RKV_I2C_VIRTUAL_SEQUENCES_SVH

