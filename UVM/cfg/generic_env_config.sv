// generic_env_config.sv
class generic_env_config extends uvm_object;
  // 通用验证参数
  rand bit enable_coverage = 1;
  rand bit enable_scoreboard = 1;
  rand bit enable_checkers = 1;
  rand bit enable_logging = 1;
  
  // 性能参数
  rand int simulation_timeout_ns = 1_000_000;
  rand int max_transaction_count = 10_000;
  
  // 随机化控制
  rand bit enable_random_stimulus = 1;
  rand int random_seed = 0;
  
  // 报告控制
  uvm_verbosity report_verbosity = UVM_MEDIUM;
  
  `uvm_object_utils_begin(generic_env_config)
    `uvm_field_int(enable_coverage, UVM_ALL_ON)
    `uvm_field_int(enable_scoreboard, UVM_ALL_ON)
    `uvm_field_int(simulation_timeout_ns, UVM_ALL_ON)
    `uvm_field_int(max_transaction_count, UVM_ALL_ON)
    `uvm_field_enum(uvm_verbosity, report_verbosity, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "generic_env_config");
    super.new(name);
  endfunction
endclass
