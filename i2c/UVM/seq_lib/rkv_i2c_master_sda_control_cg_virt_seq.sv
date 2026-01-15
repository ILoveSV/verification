`ifndef RKV_I2C_MASTER_SDA_CONTROL_CG_VIRT_SEQ_SV
`define RKV_I2C_MASTER_SDA_CONTROL_CG_VIRT_SEQ_SV

class rkv_i2c_master_sda_control_cg_virt_seq extends rkv_i2c_base_virtual_sequence;

  `uvm_object_utils(rkv_i2c_master_sda_control_cg_virt_seq)

  rand bit [7:0]  sda_rx_hold;      
  rand bit [15:0] sda_tx_hold;      
  rand bit [7:0]  sda_setup;
  rand bit        restart_en;
  constraint sda_cstr {
    sda_rx_hold inside {5,50,120};
    sda_tx_hold inside {5,50,120};
    sda_setup inside {5,50,120};
    restart_en inside {0,1};
  }

  function new (string name = "rkv_i2c_master_sda_control_cg_virt_seq");
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
      rgm.IC_CON.IC_RESTART_EN.set(restart_en);
      rgm.IC_CON.update(status);

      rgm.IC_SDA_HOLD.IC_SDA_RX_HOLD.set(sda_rx_hold);
      rgm.IC_SDA_HOLD.update(status);

      rgm.IC_SDA_HOLD.IC_SDA_TX_HOLD.set(sda_tx_hold);
      rgm.IC_SDA_HOLD.update(status);

      rgm.IC_SDA_SETUP.set(sda_setup);
      rgm.IC_SDA_SETUP.update(status);
      `uvm_do_on_with(apb_cfg_seq, 
                      p_sequencer.apb_mst_sqr,
                      {
                        SPEED == 2;                   
                        IC_10BITADDR_MASTER == 0;
                        IC_TAR == `LVC_I2C_SLAVE0_ADDRESS;
                        IC_FS_SCL_HCNT == 200;
                        IC_FS_SCL_LCNT == 200;
                        ENABLE == 1;
                                              })
    
      fork
      `uvm_do_on_with(apb_read_packet_seq, 
                      p_sequencer.apb_mst_sqr,
                     {packet.size() == 2; 
                     })
                    
      `uvm_do_on_with(i2c_slv_read_resp_seq, 
                      p_sequencer.i2c_slv_sqr,
                     {packet.size() == 2; 
                      packet[0] == 8'b1111_0000;
                      packet[1] == 8'b0101_0101;
                     })
    join

    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)

    #10us;

    `uvm_do_on_with(apb_write_packet_seq, 
                    p_sequencer.apb_mst_sqr,
                   {packet.size() == 2; 
                    packet[0] == 8'b1111_0000;
                    packet[1] == 8'b0101_0101;
                   })
                  
    `uvm_do_on(i2c_slv_write_resp_seq, p_sequencer.i2c_slv_sqr)

    `uvm_do_on(apb_wait_empty_seq, p_sequencer.apb_mst_sqr)
    #10us;
   end
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
    `uvm_info(get_type_name(), "=====================TEST CASE PASSED=====================", UVM_LOW)

  endtask

    

endclass
`endif //RKV_I2C_MASTER_ADDRESS_CG_VIRT_SEQ_SV

