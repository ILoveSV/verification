`ifndef RKV_I2C_TX_STATUS_VIRT_SEQ_SV
`define RKV_I2C_TX_STATUS_VIRT_SEQ_SV

class rkv_i2c_tx_status_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_tx_status_virt_seq)
  
  // 构造函数
  function new(string name = "rkv_i2c_tx_status_virt_seq");
    super.new(name);
  endfunction
  
  // 主体任务
  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED RX_OVER INTERRUPT TEST=====================", UVM_LOW)
    super.body();
    
    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    `uvm_do_on_with(apb_cfg_seq, 
                    p_sequencer.apb_mst_sqr,
                    {
                      SPEED == 2;                     
                      IC_10BITADDR_MASTER == 0;       
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS; 
                      IC_FS_SCL_HCNT == 200;          
                      IC_FS_SCL_LCNT ==200;        
                      ENABLE == 1;                    
                    })
        
    fork
      
    for(int i=0; i<8; i++) begin
        rgm.IC_DATA_CMD.DAT.set(i);
        rgm.IC_DATA_CMD.write(status, rgm.IC_DATA_CMD.get());
        rgm.IC_STATUS.mirror(status);
        if(rgm.IC_STATUS.TFNF.get() == 0) `uvm_info("TX_FULL","=====================TX_FULL=====================", UVM_LOW)
      end
     
    `uvm_do_on_with(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr,{nack_addr == 0; nack_data==0;})

    join
    // 8. 等待一段时间确保操作完成
    #10us;
    rgm.IC_STATUS.mirror(status);
          
    
  # 10us;
  `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)

  endtask

endclass

`endif // RKV_I2C_TX_STATUS_VIRT_SEQ_SV
