`ifndef RKV_I2C_RX_STATUS_VIRT_SEQ_SV
`define RKV_I2C_RX_STATUS_VIRT_SEQ_SV

class rkv_i2c_rx_status_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_rx_status_virt_seq)
  
  // 构造函数
  function new(string name = "rkv_i2c_rx_status_virt_seq");
    super.new(name);
  endfunction
  
  // 主体任务
  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    

    vif.wait_rstn_release();
    vif.wait_apb(10);
    
    `uvm_do_on_with(apb_cfg_seq, 
                    p_sequencer.apb_mst_sqr,
                    {
                      SPEED == 3;                     
                      IC_10BITADDR_MASTER == 0;       
                      IC_TAR == `LVC_I2C_SLAVE0_ADDRESS; 
                      IC_HS_SCL_HCNT == 50;          
                      IC_HS_SCL_LCNT ==50;        
                      ENABLE == 1;                    
                    })
        
    fork
      begin
        for(int i= 0; i<8; i++) begin
          rgm.IC_DATA_CMD.CMD.set(RGM_READ); 
          rgm.IC_DATA_CMD.DAT.set(0); 
          rgm.IC_DATA_CMD.write(status, rgm.IC_DATA_CMD.get());
        end

        for(int i= 0; i<8; i++) begin
        // Wait until RX FIFO is not empty
          while(1) begin
            rgm.IC_STATUS.mirror(status);
            if(rgm.IC_STATUS.RFNE.get() == 1) break;
            repeat(100) #10ns;
          end
        end
      end

                    
      `uvm_do_on_with(i2c_slv_read_resp_seq, 
                      p_sequencer.i2c_slv_sqr,
                     {packet.size() == 8; 
                      packet[0] == 8'b1111_0000;
                      packet[1] == 8'b0101_0101;
                      packet[2] == 8'b1111_0000;
                      packet[3] == 8'b0101_0101;
                      packet[4] == 8'b1111_0000;
                      packet[5] == 8'b0101_0101;
                      packet[6] == 8'b1111_0000;
                      packet[7] == 8'b0101_0101;
                     })
    join

    rgm.IC_STATUS.mirror(status);
          
    
  # 10us;
  `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)

  endtask

endclass

`endif // RKV_I2C_RX_STATUS_VIRT_SEQ_SV
