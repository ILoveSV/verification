`ifndef GENERIC_ENV_CONFIG_SV
`define GENERIC_ENV_CONFIG_SV

class generic_env_config extends uvm_object;
  `uvm_object_utils(generic_env_config)
  
  // === 通用验证控制 ===
  bit enable_cov = 1;                    // 覆盖率使能
  bit enable_scb = 1;                    // 记分板使能
  bit enable_reg_prediction = 1;         // 寄存器预测使能
  bit enable_reg_adapter = 1;            // 寄存器适配器使能
  
  // === 通用统计 ===
  int check_count = 0;                   // 检查计数
  int error_count = 0;                   // 错误计数
  int warning_count = 0;                 // 警告计数
  
  // === 超时控制 ===
  time timeout_ns = 10_000_000;          // 10ms默认超时
  bit enable_timeout = 1;                // 超时检查使能
  
  // === 报告控制 ===
  uvm_verbosity report_verbosity = UVM_MEDIUM;  // 报告详细程度
  bit enable_transaction_reporting = 0;  // 事务报告使能
  
  // === 序列控制 ===
  int default_sequence_count = 100;      // 默认序列次数
  string default_sequence_type = "base"; // 默认序列类型
  
  // Constructor
  function new(string name = "generic_env_config");
    super.new(name);
  endfunction
  
  // 配置验证
  virtual function bit is_valid();
    if(timeout_ns <= 0) begin
      `uvm_error("CFG_ERR", "Timeout must be positive")
      return 0;
    end
    if(default_sequence_count <= 0) begin
      `uvm_error("CFG_ERR", "Sequence count must be positive")
      return 0;
    end
    return 1;
  endfunction
  
  // 配置信息打印
  virtual function string convert2string();
    string s = $sformatf("Generic Config [%s]:\n", get_name());
    s = {s, $sformatf("  enable_cov: %0d, enable_scb: %0d\n", enable_cov, enable_scb)};
    s = {s, $sformatf("  timeout_ns: %0t, checks: %0d, errors: %0d\n", timeout_ns, check_count, error_count)};
    return s;
  endfunction

endclass

`endif
