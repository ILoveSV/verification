`ifndef MY_BASE_ENV_SV
`define MY_BASE_ENV_SV

class my_base_env extends uvm_env;
  `uvm_component_utils(my_base_env);

  // Configuration subcomponents
  my_base_agent      i_agt;
  my_base_scb        scb;  
  my_base_cfg        cfg;
  
  uvm_tlm_analysis_fifo #(uvm_sequence_item) mon2scb_fifo;
  uvm_tlm_analysis_fifo #(uvm_sequence_item) drv2scb_fifo;
  
  uvm_sequencer #(uvm_sequence_item) virt_sqr;

  // Constructor
  function new(string name="my_base_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
   // Set interface
   // Get configuration from test layer
    if(!uvm_config_db#(my_base_cfg)::get(this, "", "BASE_ENV_CFG", cfg)) begin
      `uvm_fatal("BASE_CFG_NOT_FOUND", "my_base_cfg not found in config DB")
    end
    
    // 创建通用组件
    i_agt = my_base_agent::type_id::create("i_agt", this);
    scb = my_base_scb::type_id::create("scb", this);
    virt_sqr = uvm_sequencer#(uvm_sequence_item)::type_id::create("virt_sqr", this);
    
    // 创建通用FIFOs
    mon2scb_fifo = new("mon2scb_fifo", this);
    drv2scb_fifo = new("drv2scb_fifo", this);
    
    // 调用子类特定的构建方法
    do_build_phase();
  endfunction

  // Connect Phase - 通用连接逻辑  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // 通用连接：monitor → scoreboard
    i_agt.monitor.ap.connect(mon2scb_fifo.analysis_export);
    scb.act_port.connect(mon2scb_fifo.blocking_get_export);
    
    // 通用连接：driver → scoreboard  
    i_agt.driver.drv2scb.connect(drv2scb_fifo.analysis_export);
    scb.exp_port.connect(drv2scb_fifo.blocking_get_export);
    
    // 调用子类特定的连接方法
    do_connect_phase();
  endfunction

  // 子类可重写的虚方法
  virtual function void do_build_phase();
    // 空实现，子类重写
  endfunction

  virtual function void do_connect_phase();
    // 空实现，子类重写  
  endfunction

  // 通用报告方法
  virtual function void report_phase(uvm_phase phase);
    string report_msg;
    super.report_phase(phase);
    
    report_msg = $sformatf("\n=== %s Verification Summary ===", get_type_name());
    report_msg = {report_msg, $sformatf("\nScoreboard Checks: %0d", cfg.scb_check_count)};
    report_msg = {report_msg, $sformatf("\nScoreboard Errors: %0d", cfg.scb_check_error)};
    report_msg = {report_msg, $sformatf("\nCoverage Enabled: %0d", cfg.enable_cov)};
    report_msg = {report_msg, $sformatf("\n====================================\n")};
    
    `uvm_info("ENV_REPORT", report_msg, UVM_LOW)
  endfunction

endclass : my_base_env

`endif
