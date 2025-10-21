`ifndef FUNCTIONAL_LAYER_CONFIG_SV
`define FUNCTIONAL_LAYER_CONFIG_SV

class functional_layer_config extends bus_layer_config;
  `uvm_object_utils(functional_layer_config)
  
  // === 数据通路配置 ===
  bit enable_data_path = 1;               // 数据通路使能
  int data_fifo_depth = 32;               // 数据FIFO深度
  int max_packet_size = 1024;             // 最大包大小
  int min_packet_size = 16;               // 最小包大小
  bit enable_data_integrity_check = 1;    // 数据完整性检查
  
  // === 控制通路配置 ===
  bit enable_control_path = 1;            // 控制通路使能
  bit enable_interrupts = 1;              // 中断使能
  int interrupt_latency_max = 100;        // 最大中断延迟(cycles)
  bit enable_register_access_check = 1;   // 寄存器访问检查
  
  // === 电源管理配置 ===
  bit enable_power_management = 0;        // 电源管理使能
  bit enable_clock_gating = 0;            // 时钟门控使能
  bit enable_power_gating = 0;            // 电源门控使能
  string power_mode = "NORMAL";           // 电源模式: NORMAL, LOW_POWER, ULTRA_LOW
  
  // === 性能配置 ===
  bit enable_performance_monitoring = 1;  // 性能监控使能
  int target_throughput_mbps = 1000;      // 目标吞吐量(Mbps)
  int max_latency_ns = 1000;              // 最大延迟(ns)
  bit enable_bandwidth_monitoring = 1;    // 带宽监控使能
  
  // === 功能覆盖配置 ===
  bit enable_data_coverage = 1;           // 数据覆盖使能
  bit enable_control_coverage = 1;        // 控制覆盖使能
  bit enable_interrupt_coverage = 1;      // 中断覆盖使能
  bit enable_error_coverage = 1;          // 错误覆盖使能
  bit enable_corner_case_coverage = 0;    // 边界情况覆盖使能
  
  // === 验证模式配置 ===
  string test_mode = "NORMAL";            // 测试模式: NORMAL, STRESS, CORNER, ERROR_INJECT
  bit enable_stress_testing = 0;          // 压力测试使能
  bit enable_error_injection = 0;         // 错误注入使能
  int error_injection_rate = 1;           // 错误注入率(百分比)
  
  // === 调试配置 ===
  bit enable_debug_tracing = 0;           // 调试跟踪使能
  int trace_depth = 100;                  // 跟踪深度
  bit enable_transaction_logging = 0;     // 事务日志使能
  string debug_level = "BASIC";           // 调试级别: BASIC, DETAILED, VERBOSE

  // Constructor
  function new(string name = "functional_layer_config");
    super.new(name);
  endfunction
  
  // === 功能模式检查 ===
  virtual function bit is_normal_mode();
    return (test_mode == "NORMAL");
  endfunction
  
  virtual function bit is_stress_mode();
    return (test_mode == "STRESS");
  endfunction
  
  virtual function bit is_corner_mode();
    return (test_mode == "CORNER");
  endfunction
  
  virtual function bit is_error_inject_mode();
    return (test_mode == "ERROR_INJECT");
  endfunction
  
  // === 数据通路方法 ===
  virtual function bit is_packet_size_valid(int size);
    return (size >= min_packet_size && size <= max_packet_size);
  endfunction
  
  virtual function int get_random_packet_size();
    if(min_packet_size == max_packet_size) 
      return min_packet_size;
    else
      return $urandom_range(min_packet_size, max_packet_size);
  endfunction
  
  // === 性能目标检查 ===
  virtual function bit is_performance_target_met(int actual_throughput, int actual_latency);
    return (actual_throughput >= target_throughput_mbps && 
            actual_latency <= max_latency_ns);
  endfunction
  
  // === 电源管理方法 ===
  virtual function bit is_low_power_mode();
    return (power_mode == "LOW_POWER" || power_mode == "ULTRA_LOW");
  endfunction
  
  virtual function bit should_enable_power_features();
    return enable_power_management && is_low_power_mode();
  endfunction
  
  // === 覆盖组使能检查 ===
  virtual function bit should_enable_data_coverage();
    return enable_cov && enable_data_coverage && enable_data_path;
  endfunction
  
  virtual function bit should_enable_control_coverage();
    return enable_cov && enable_control_coverage && enable_control_path;
  endfunction
  
  virtual function bit should_enable_interrupt_coverage();
    return enable_cov && enable_interrupt_coverage && enable_interrupts;
  endfunction
  
  virtual function bit should_enable_error_coverage();
    return enable_cov && enable_error_coverage && enable_error_injection;
  endfunction
  
  // === 配置验证 ===
  virtual function bit is_valid();
    if(!super.is_valid()) return 0;
    
    // 数据通路验证
    if(max_packet_size < min_packet_size) begin
      `uvm_error("FUNC_CFG", "Max packet size cannot be less than min packet size")
      return 0;
    end
    
    if(data_fifo_depth <= 0) begin
      `uvm_error("FUNC_CFG", "Data FIFO depth must be positive")
      return 0;
    end
    
    // 性能参数验证
    if(target_throughput_mbps <= 0) begin
      `uvm_error("FUNC_CFG", "Target throughput must be positive")
      return 0;
    end
    
    if(max_latency_ns <= 0) begin
      `uvm_error("FUNC_CFG", "Max latency must be positive")
      return 0;
    end
    
    // 错误注入验证
    if(enable_error_injection && (error_injection_rate <= 0 || error_injection_rate > 100)) begin
      `uvm_error("FUNC_CFG", "Error injection rate must be between 1 and 100")
      return 0;
    end
    
    // 中断验证
    if(enable_interrupts && interrupt_latency_max <= 0) begin
      `uvm_error("FUNC_CFG", "Interrupt latency must be positive")
      return 0;
    end
    
    return 1;
  endfunction
  
  // === 配置信息打印 ===
  virtual function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("Functional Layer [%s Mode]:\n", test_mode)};
    
    // 数据通路信息
    if(enable_data_path) begin
      s = {s, $sformatf("  Data Path: ENABLED\n")};
      s = {s, $sformatf("    FIFO Depth: %0d, Packet Size: [%0d-%0d]\n", 
           data_fifo_depth, min_packet_size, max_packet_size)};
    end else begin
      s = {s, $sformatf("  Data Path: DISABLED\n")};
    end
    
    // 控制通路信息
    if(enable_control_path) begin
      s = {s, $sformatf("  Control Path: ENABLED\n")};
      s = {s, $sformatf("    Interrupts: %s, Max Latency: %0d cycles\n",
           enable_interrupts ? "ENABLED" : "DISABLED", interrupt_latency_max)};
    end
    
    // 性能信息
    if(enable_performance_monitoring) begin
      s = {s, $sformatf("  Performance: Target %0d Mbps, Max Latency %0d ns\n",
           target_throughput_mbps, max_latency_ns)};
    end
    
    // 电源管理信息
    if(enable_power_management) begin
      s = {s, $sformatf("  Power Management: %s Mode\n", power_mode)};
      s = {s, $sformatf("    Clock Gating: %s, Power Gating: %s\n",
           enable_clock_gating ? "ON" : "OFF", enable_power_gating ? "ON" : "OFF")};
    end
    
    // 测试模式信息
    if(enable_stress_testing) begin
      s = {s, $sformatf("  Stress Testing: ENABLED\n")};
    end
    
    if(enable_error_injection) begin
      s = {s, $sformatf("  Error Injection: ENABLED (%0d%% rate)\n", error_injection_rate)};
    end
    
    // 覆盖组信息
    s = {s, $sformatf("  Coverage: Data=%0d, Control=%0d, Interrupt=%0d, Error=%0d\n",
         enable_data_coverage, enable_control_coverage, 
         enable_interrupt_coverage, enable_error_coverage)};
    
    return s;
  endfunction
  
  // === 获取配置摘要 ===
  virtual function string get_config_summary();
    string summary = $sformatf("Func[%s|DP=%0d|CP=%0d|INT=%0d|PERF=%0d|PWR=%0d]",
                               test_mode, enable_data_path, enable_control_path,
                               enable_interrupts, enable_performance_monitoring,
                               enable_power_management);
    return summary;
  endfunction

endclass

`endif
