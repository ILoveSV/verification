/*`ifndef I2C_REG_ACCESS_VIRT_SEQ_SV
`define I2C_REG_ACCESS_VIRT_SEQ_SV
class i2c_reg_access_virt_seq extends i2c_base_virtual_sequence;

  `uvm_object_utils(i2c_reg_access_virt_seq)

  function new (string name = "i2c_reg_access_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);

    // TODO
    rgm.IC_CON.SPEED.set('h2);

    rgm.IC_TAR.IC_TAR.set(`LVC_I2C_SLAVE0_ADDRESS);
    // SCL_HCNT + SCL_LCNT = I2C baud clock T 
    // 2us + 2us -> 1000/4 = 250Kb/s
    rgm.IC_FS_SCL_HCNT.set(200); // 2us 

    rgm.IC_FS_SCL_LCNT.set(200); // 2us

    rgm.IC_ENABLE.ENABLE.set('h1);

    rgm.IC_DATA_CMD.DAT.set(8'b1100_1100);
    rgm.IC_DATA_CMD.CMD.set('h0); // WRITE=0, READ=1

    update_regs('{rgm.IC_CON, 
                  rgm.IC_TAR, 
                  rgm.IC_FS_SCL_HCNT, 
                  rgm.IC_FS_SCL_LCNT, 
                  rgm.IC_ENABLE, 
                  rgm.IC_DATA_CMD
                });

    rgm.IC_CON.mirror(status,UVM_CHECK);
    if(status!= UVM_IS_OK) `uvm_error("IC_CON","Actual value is not equal to mirror value") 

    rgm.IC_ENABLE.mirror(status, UVM_CHECK);
    if(status!= UVM_IS_OK) `uvm_error("IC_ENABLE","Actual value is not equal to mirror value")

    rgm.IC_FS_SCL_HCNT.mirror(status, UVM_CHECK);
    if(status!= UVM_IS_OK) `uvm_error("IC_FS_SCL_HCNT","Actual value is not equal to mirror value")

    rgm.IC_FS_SCL_LCNT.mirror(status, UVM_CHECK);
    if(status!= UVM_IS_OK) `uvm_error("IC_FS_SCL_LCNT","Actual value is not equal to mirror value")

    rgm.IC_DATA_CMD.mirror(status, UVM_CHECK);
    if(status!= UVM_IS_OK) `uvm_error("IC_DATA_CMD","Actual value is not equal to mirror value")
      

    // Attach element sequences below
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

endclass
`endif // I2C_REG_ACCESS_VIRT_SEQ_SV

*/
`ifndef I2C_REG_ACCESS_VIRT_SEQ_SV
`define I2C_REG_ACCESS_VIRT_SEQ_SV

class i2c_reg_access_virt_seq extends i2c_base_virtual_sequence;

  `uvm_object_utils(i2c_reg_access_virt_seq)

  function new (string name = "i2c_reg_access_virt_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "=====================STARTED=====================", UVM_LOW)
    super.body();
    vif.wait_rstn_release();
    vif.wait_apb(10);

    // Register reset sequence
    reg_access_seq = new();
    `uvm_info(get_type_name(), "Register reset sequence started", UVM_LOW)
    rgm.reset();
    reg_access_seq.model = rgm;
    reg_access_seq.start(m_sequencer);
    `uvm_info(get_type_name(), "Register reset sequence finished", UVM_LOW)

    // Enable I2C controller
    rgm.IC_ENABLE.ENABLE.set(1);
    rgm.IC_ENABLE.update(status);
    `uvm_info(get_type_name(), "I2C Controller Enabled", UVM_LOW)

    #10us;

    // Register access tests
    // 1. Single access sequence - test each register individually
    reg_single_access_seq = uvm_reg_single_access_seq::type_id::create("reg_single_access_seq");
    `uvm_info(get_type_name(), "Starting register single access sequence", UVM_LOW)
    reg_single_access_seq.model = rgm;
    reg_single_access_seq.start(m_sequencer);
    `uvm_info(get_type_name(), "Register single access sequence finished", UVM_LOW)

    #5us;

    // 2. Shared access sequence - test concurrent register access
    reg_shared_access_seq = uvm_reg_shared_access_seq::type_id::create("reg_shared_access_seq");
    `uvm_info(get_type_name(), "Starting register shared access sequence", UVM_LOW)
    reg_shared_access_seq.model = rgm;
    reg_shared_access_seq.start(m_sequencer);
    `uvm_info(get_type_name(), "Register shared access sequence finished", UVM_LOW)

    #5us;

    // 3. Single bit bash sequence - test each bit in registers
    reg_single_bit_bash_seq = uvm_reg_single_bit_bash_seq::type_id::create("reg_single_bit_bash_seq");
    `uvm_info(get_type_name(), "Starting register single bit bash sequence", UVM_LOW)
    reg_single_bit_bash_seq.model = rgm;
    reg_single_bit_bash_seq.start(m_sequencer);
    `uvm_info(get_type_name(), "Register single bit bash sequence finished", UVM_LOW)

    #5us;

    // 4. Bit bash sequence - comprehensive bit testing
    reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
    `uvm_info(get_type_name(), "Starting register bit bash sequence", UVM_LOW)
    reg_bit_bash_seq.model = rgm;
    reg_bit_bash_seq.start(m_sequencer);
    `uvm_info(get_type_name(), "Register bit bash sequence finished", UVM_LOW)

    #10us;

    // 5. Configure I2C controller through registers
//    configure_i2c_registers();
    
    // 6. Verify configuration by reading back registers
 //   verify_i2c_configuration();
    
    `uvm_info(get_type_name(), "=====================FINISHED=====================", UVM_LOW)
  endtask

  virtual task configure_i2c_registers();
    `uvm_info(get_type_name(), "Configuring I2C registers", UVM_LOW)
    
    // Configure IC_CON register
    rgm.IC_CON.SPEED.set(2'b10);        // Standard speed (100 kbit/s)
    rgm.IC_CON.MASTER_MODE.set(1);      // Master mode
    rgm.IC_CON.IC_SLAVE_DISABLE.set(1); // Disable slave mode
    rgm.IC_CON.IC_RESTART_EN.set(1);    // Enable restart
    rgm.IC_CON.TX_EMPTY_CTRL.set(0);    // TX_EMPTY interrupt control
    rgm.IC_CON.update(status);
    
    // Configure IC_TAR (Target address)
    rgm.IC_TAR.IC_TAR.set(8'h55);       // Set target address to 0x55
    rgm.IC_TAR.update(status);
    
    // Configure IC_SS_SCL_HCNT and IC_SS_SCL_LCNT for standard speed
    rgm.IC_SS_SCL_HCNT.IC_SS_SCL_HCNT.set(16'd500);  // High count
    rgm.IC_SS_SCL_HCNT.update(status);
    rgm.IC_SS_SCL_LCNT.IC_SS_SCL_LCNT.set(16'd500);  // Low count
    rgm.IC_SS_SCL_LCNT.update(status);
    
    // Configure IC_FS_SCL_HCNT and IC_FS_SCL_LCNT for fast speed (if needed)
    rgm.IC_FS_SCL_HCNT.IC_FS_SCL_HCNT.set(16'd100);  // Fast mode high count
    rgm.IC_FS_SCL_HCNT.update(status);
    rgm.IC_FS_SCL_LCNT.IC_FS_SCL_LCNT.set(16'd100);  // Fast mode low count
    rgm.IC_FS_SCL_LCNT.update(status);
    
    // Configure IC_RX_TL (RX FIFO threshold)
//    rgm.IC_RX_TL.IC_RX_TL.set(8'h0F);   // Set threshold to 15
//    rgm.IC_RX_TL.update(status);
    
    // Configure IC_TX_TL (TX FIFO threshold)
//    rgm.IC_TX_TL.IC_TX_TL.set(8'h07);   // Set threshold to 7
//    rgm.IC_TX_TL.update(status);
    
    `uvm_info(get_type_name(), "I2C registers configuration completed", UVM_LOW)
  endtask

  virtual task verify_i2c_configuration();
    uvm_reg_data_t read_data;
    bit verification_passed = 1;
    
    `uvm_info(get_type_name(), "Verifying I2C register configuration", UVM_LOW)
    
    // Verify IC_ENABLE register
    rgm.IC_ENABLE.ENABLE.read(status, read_data);
    if (!diff_value(read_data, 1'b1, "IC_ENABLE.ENABLE")) 
      verification_passed = 0;
    
    // Verify IC_CON register
    rgm.IC_CON.read(status, read_data);
    if (!diff_value(read_data[1:0], 2'b10, "IC_CON.SPEED"))
      verification_passed = 0;
    if (!diff_value(read_data[5], 1'b1, "IC_CON.MASTER_MODE"))
      verification_passed = 0;
    
    // Verify IC_TAR register
    rgm.IC_TAR.IC_TAR.read(status, read_data);
    if (!diff_value(read_data, 8'h55, "IC_TAR.IC_TAR"))
      verification_passed = 0;
    
    // Verify IC_SS_SCL_HCNT register
    rgm.IC_SS_SCL_HCNT.IC_SS_SCL_HCNT.read(status, read_data);
    if (!diff_value(read_data, 16'd500, "IC_SS_SCL_HCNT"))
      verification_passed = 0;
    
    // Verify IC_RX_TL register
//    rgm.IC_RX_TL.IC_RX_TL.read(status, read_data);
//    if (!diff_value(read_data, 8'h0F, "IC_RX_TL.IC_RX_TL"))
//      verification_passed = 0;
    
    if (verification_passed) begin
      `uvm_info(get_type_name(), "I2C register verification PASSED", UVM_HIGH)
    end else begin
      `uvm_error(get_type_name(), "I2C register verification FAILED")
    end
    
    `uvm_info(get_type_name(), "I2C register verification completed", UVM_LOW)
  endtask

endclass

`endif // I2C_REG_ACCESS_VIRT_SEQ_SV

