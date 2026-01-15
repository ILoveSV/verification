`ifndef RKV_I2C_MASTER_TIMEOUT_CG_VIRT_SEQ_SV
`define RKV_I2C_MASTER_TIMEOUT_CG_VIRT_SEQ_SV

class rkv_i2c_master_timeout_cg_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_master_timeout_cg_virt_seq)

  rand bit [3:0] time_out_cnt;      
  
  constraint timeout_cstr {
    time_out_cnt inside {1,5,15};
  }

  function new (string name = "rkv_i2c_master_timeout_cg_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);

    repeat(10) begin  

      if (!this.randomize()) begin
        `uvm_error("RANDOMIZE", "Failed to randomize address parameters")
      end
      
      rgm.REG_TIMEOUT_RST.REG_TIMEOUT_RST_rw.set(time_out_cnt);
      rgm.REG_TIMEOUT_RST.update(status);

     `uvm_do_on_with(apb_cfg_seq, 
                    p_sequencer.apb_mst_sqr,
                    {SPEED == 2;
                    IC_10BITADDR_MASTER == 0;
                    IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                    IC_FS_SCL_HCNT == 200;
                    IC_FS_SCL_LCNT == 200;
                    ENABLE == 1;
                  })
 
      
  
  
    

    #10us;
   end
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)

  endtask

    

endclass
`endif //RKV_I2C_MASTER_TIMEOUT_CG_VIRT_SEQ_SV


