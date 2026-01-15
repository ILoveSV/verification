`ifndef RKV_I2C_MASTER_HS_CNT_VIRT_SEQ_SV
`define RKV_I2C_MASTER_HS_CNT_VIRT_SEQ_SV

class rkv_i2c_master_hs_cnt_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_master_hs_cnt_virt_seq)

  rand int hs_scl_hcnt;
  rand int hs_scl_lcnt;
 
  constraint ss_cstr {
    hs_scl_hcnt inside{30,60};
    hs_scl_lcnt inside{30,60};
    hs_scl_lcnt + hs_scl_hcnt >= 90;
  }
 
  function new (string name = "rkv_i2c_master_hs_cnt_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);
   
    repeat(10) begin  
      if (!this.randomize()) begin
                `uvm_error("RANDOMIZE_FAILED", "Failed to randomize fs_scl_hcnt and fs_scl_lcnt")
      end
 
      `uvm_do_on_with(apb_cfg_seq, 
                      p_sequencer.apb_mst_sqr,
                      {
                        SPEED == 3;                   
                        IC_10BITADDR_MASTER == 0;
                        IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                        IC_HS_SCL_HCNT == hs_scl_hcnt;
                        IC_HS_SCL_LCNT == hs_scl_lcnt;
                        ENABLE == 1;
                      })
    
      `uvm_do_on_with(apb_write_packet_seq, 
                      p_sequencer.apb_mst_sqr,
                     {packet.size() == 2; 
                      packet[0] == 8'b1111_0000;
                      packet[1] == 8'b0101_0101;
                     })
                  
      `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)



    #10us;
   end
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)
  endtask
endclass
`endif

