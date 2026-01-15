
`ifndef RKV_APB_BASE_SEQUENCE_SV
`define RKV_APB_BASE_SEQUENCE_SV

virtual class rkv_apb_base_sequence extends uvm_sequence #(lvc_apb_transfer);

  ral_block_rkv_i2c rgm;
  
  // packet数组存储要传输的数据字节
  rand bit [7:0] packet[];
  // 中断标识符，用于标识特定的中断
  rand int intr_id = 0;

  // 默认值-1表示不强制设置，使用默认值
  rand int SPEED = -1;               
  rand int IC_10BITADDR_MASTER = -1; 
  rand int IC_TAR = -1;  
  rand int IC_SS_SCL_HCNT = -1;      
  rand int IC_SS_SCL_LCNT = -1;
  rand int IC_FS_SCL_HCNT = -1;      
  rand int IC_FS_SCL_LCNT = -1;      
  rand int IC_HS_SCL_HCNT = -1;
  rand int IC_HS_SCL_LCNT = -1;
  rand int ENABLE = -1;              
  rand int DAT = -1;                 
  rand int CMD = -1;                
  rand int IC_SAR = -1;              
  
  `uvm_declare_p_sequencer(lvc_apb_master_sequencer)

  // Register model variables:
  uvm_status_e status;
  rand uvm_reg_data_t data;

  function new (string name = "rkv_apb_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    // TODO
    // Attach element sequences below
    if(!uvm_config_db #(ral_block_rkv_i2c)::get(m_sequencer, "", "rgm", rgm)) begin
      // 如果获取失败，报告错误
      `uvm_error("body", "Unable to find ral_block_rkv_i2c in uvm_config_db")
    end
  endtask

  virtual task update_regs(uvm_reg regs[]);
    uvm_status_e status;
    foreach(regs[i]) regs[i].update(status);
  endtask
endclass

`endif // RKV_APB_BASE_SEQUENCE_SV
