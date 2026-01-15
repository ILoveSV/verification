`ifndef RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV
`define RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV

class rkv_i2c_master_address_cg_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_master_address_cg_virt_seq)

  rand bit [9:0] tar_addr;      
  rand bit [9:0] sar_addr;      
  rand bit       tar_10bit_mode; 
  rand bit       sar_10bit_mode; 
  
  constraint addr_cstr {
    tar_addr != 0;
    sar_addr != 0;
    
    tar_addr < 1024;
    sar_addr < 1024;
    
    tar_10bit_mode dist {0:=50, 1:=50};  
    sar_10bit_mode dist {0:=50, 1:=50};
    if (tar_10bit_mode == 0) tar_addr[9:7] == 0 ;
    if (tar_10bit_mode == 0) sar_addr[9:7] == 0 ;
  }

  function new (string name = "rkv_i2c_master_address_cg_virt_seq");
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
      
      `uvm_info("ADDR_TEST", 
                $sformatf("Testing TAR=0x%03h (10bit=%0d), SAR=0x%03h (10bit=%0d)",
                          tar_addr, tar_10bit_mode, sar_addr, sar_10bit_mode),
                UVM_MEDIUM)
      
      `uvm_do_on_with(apb_cfg_seq, 
                      p_sequencer.apb_mst_sqr,
                      {
                        SPEED == 2;                   
                        IC_10BITADDR_MASTER == tar_10bit_mode;
                        if(tar_10bit_mode){
                          IC_TAR == tar_addr[9:0];
                        } else {
                          IC_TAR == tar_addr[6:0]; 
                        }
                        IC_FS_SCL_HCNT == 200;
                        IC_FS_SCL_LCNT == 200;
                        ENABLE == 1;
                        if(sar_10bit_mode){
                          IC_SAR == tar_addr[9:0];
                        }else{
                          IC_SAR == sar_addr[6:0];
                        }
                      })
    
      execute_address_test();

    #10us;
   end
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)

  endtask

  virtual task execute_address_test();

    fork
      `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)
    join_none
    
    `uvm_do_on_with(apb_write_packet_seq,
                    p_sequencer.apb_mst_sqr,
                   {
                    packet.size() == 1;
                    packet[0] == 8'hAA;
                   })
    

    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)


  endtask
  

endclass
`endif //RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV

