`ifndef MHSA_CONFIG_SV
`define MHSA_CONFIG_SV

class mhsa_cfg extends functional_layer_config;
  `uvm_object_utils(mhsa_cfg)
  
  // === MHSA架构参数 ===
  int matrix_size = 8;                   // 矩阵大小 (N x N)
  int vector_length = 16;                // 向量长度
  int mac_units_count = 4;               // MAC单元数量
  int accumulator_depth = 32;            // 累加器深度
  
  // === 计算模式 ===
  bit enable_float_mode = 0;             // 浮点模式使能
  bit enable_fixed_point = 1;            // 定点模式使能
  int fixed_point_precision = 16;        // 定点精度(位宽)
  int fixed_point_fraction = 8;          // 定点小数部分位宽
  
  // === 功能使能 ===
  bit enable_mac_units = 1;              // MAC单元使能
  bit enable_accumulator = 1;            // 累加器使能
  bit enable_normalization = 0;          // 归一化使能
  bit enable_activation = 0;             // 激活函数使能
  bit enable_bias_addition = 0;          // 偏置加法使能
  
  // === 数据流控制 ===
  bit enable_pipeline_mode = 1;          // 流水线模式使能
  int pipeline_stages = 4;               // 流水线级数
  bit enable_data_reuse = 0;             // 数据重用使能
  int reuse_factor = 1;                  // 数据重用因子
  
  // === 性能监控 ===
  bit enable_perf_monitoring = 1;        // 性能监控使能
  int throughput_target = 100;           // 吞吐量目标(GOPS)
  int latency_target = 1000;             // 延迟目标(cycles)
  bit enable_latency_measurement = 1;    // 延迟测量使能
  bit enable_throughput_measurement = 1; // 吞吐量测量使能
  
  // === 测试模式 ===
  string test_scenario = "MATRIX_MULT";  // 测试场景
  bit enable_stress_test = 0;            // 压力测试使能
  bit enable_error_injection = 0;        // 错误注入使能
  bit enable_corner_case_test = 0;       // 边界情况测试使能
  
  // === 寄存器配置 ===
  bit [31:0] reg_base_addr = 32'h0000_0000;  // 寄存器基地址
  int reg_space_size = 1024;             // 寄存器空间大小
  bit [31:0] data_base_addr = 32'h1000_0000; // 数据内存基地址
  int data_space_size = 64 * 1024;       // 数据内存大小(64KB)
  
  // === 特定配置组件 ===
  mhsa_mstr_agent_config mhsa_mstr_agnt_cfg;  // MHSA主代理配置
  virtual apb_interface apb_intf;              // APB虚拟接口
  
  // === 覆盖率配置 ===
  bit enable_mhsa_coverage = 1;          // MHSA覆盖率使能
  bit enable_matrix_coverage = 1;        // 矩阵操作覆盖率
  bit enable_vector_coverage = 1;        // 向量操作覆盖率
  bit enable_mac_coverage = 1;           // MAC操作覆盖率
  bit enable_accumulator_coverage = 1;   // 累加器覆盖率

  // Constructor
  function new(string name = "mhsa_cfg");
    super.new(name);
    // 初始化配置组件
    mhsa_mstr_agnt_cfg = new("mhsa_mstr_agnt_cfg");
    
    // 设置MHSA特定的默认配置
    setup_mhsa_defaults();
  endfunction
  
  // 设置MHSA默认配置
  virtual function void setup_mhsa_defaults();
    // 确保使用APB协议
    bus_protocol = "APB";
/*    
    // 配置APB参数以适应MHSA
    if(apb_cfg != null) begin
      apb_cfg.min_addr = reg_base_addr;
      apb_cfg.max_addr = reg_base_addr + reg_space_size - 1;
      apb_cfg.pclk_period = 10ns;
      apb_cfg.idle_cycles_min = 1;
      apb_cfg.idle_cycles_max = 3;
      apb_cfg.enable_protocol_checks = 1;
      apb_cfg.enable_apb_cov = enable_cov;
    end*/
    
    // 配置功能层参数
    enable_data_path = 1;
    data_fifo_depth = matrix_size * 2;  // 适应矩阵大小
    max_packet_size = matrix_size * matrix_size * 4;  // 矩阵数据大小
    min_packet_size = vector_length * 4;  // 向量数据大小
    
    enable_control_path = 1;
    enable_interrupts = 1;
    interrupt_latency_max = 50;
    
    enable_performance_monitoring = 1;
    target_throughput_mbps = throughput_target * 10;  // 粗略转换
  endfunction
  
  // === MHSA特定计算方法 ===
  
  // 获取总操作数
  virtual function int get_total_operations();
    return matrix_size * matrix_size * vector_length;
  endfunction
  
  // 获取理论峰值性能
  virtual function real get_peak_performance();
    real clock_frequency = 1.0 / (bus_clock_period * 1e-9);  // Hz
    return real'(mac_units_count) * clock_frequency * 1e-9;  // GOPS
  endfunction
  
  // 检查矩阵向量维度兼容性
  virtual function bit is_dimension_compatible();
    if(matrix_size <= 0 || vector_length <= 0) return 0;
    if(enable_mac_units && mac_units_count <= 0) return 0;
    return 1;
  endfunction
  
  // 获取数据内存需求
  virtual function int get_memory_requirement();
    int matrix_mem = matrix_size * matrix_size * 4;  // 32-bit words
    int vector_mem = vector_length * 4;              // 32-bit words
    int result_mem = matrix_size * 4;                // 32-bit words
    return matrix_mem + vector_mem + result_mem;
  endfunction
  
  // === 配置验证方法 ===
  virtual function bit is_configuration_supported();
    if(!is_dimension_compatible()) begin
      `uvm_error("MHSA_CFG", "Matrix/vector dimensions are incompatible")
      return 0;
    end
    
    if(matrix_size > 64) begin
      `uvm_warning("MHSA_CFG", "Large matrix size may impact performance")
    end
    
    if(mac_units_count > 16) begin
      `uvm_error("MHSA_CFG", "Too many MAC units for current architecture")
      return 0;
    end
    
    if(enable_float_mode && enable_fixed_point) begin
      `uvm_error("MHSA_CFG", "Cannot enable both float and fixed point modes")
      return 0;
    end
    
    // 检查内存需求
    if(get_memory_requirement() > data_space_size) begin
      `uvm_error("MHSA_CFG", 
                 $sformatf("Memory requirement (%0d) exceeds available space (%0d)", 
                          get_memory_requirement(), data_space_size))
      return 0;
    end
    
    // 检查性能目标是否合理
    if(throughput_target > get_peak_performance()) begin
      `uvm_warning("MHSA_CFG", 
                   $sformatf("Throughput target (%0d GOPS) exceeds peak performance (%0.1f GOPS)", 
                            throughput_target, get_peak_performance()))
    end
    
    return 1;
  endfunction
  
  // === 配置验证 ===
  virtual function bit is_valid();
    if(!super.is_valid()) return 0;
    
    if(matrix_size <= 0 || vector_length <= 0) begin
      `uvm_error("MHSA_CFG", "Matrix size and vector length must be positive")
      return 0;
    end
    
    if(mac_units_count <= 0) begin
      `uvm_error("MHSA_CFG", "MAC units count must be positive")
      return 0;
    end
    
    if(accumulator_depth <= 0) begin
      `uvm_error("MHSA_CFG", "Accumulator depth must be positive")
      return 0;
    end
    
    if(!is_configuration_supported()) return 0;
    
    // 检查配置组件
    if(mhsa_mstr_agnt_cfg == null) begin
      `uvm_error("MHSA_CFG", "MHSA master agent configuration is null")
      return 0;
    end
    
    return 1;
  endfunction
  
  // === 测试场景设置 ===
  virtual function void set_test_scenario(string scenario);
    test_scenario = scenario;
    
    case(scenario)
      "MATRIX_MULT": begin
        matrix_size = 8;
        vector_length = 16;
        enable_mac_units = 1;
        enable_stress_test = 0;
      end
      "STRESS_TEST": begin
        matrix_size = 16;
        vector_length = 32;
        enable_stress_test = 1;
        enable_perf_monitoring = 1;
      end
      "CORNER_CASE": begin
        matrix_size = 2;
        vector_length = 2;
        enable_corner_case_test = 1;
      end
      "ERROR_TEST": begin
        enable_error_injection = 1;
        enable_stress_test = 1;
      end
      default: begin
        `uvm_warning("MHSA_CFG", $sformatf("Unknown test scenario: %s", scenario))
      end
    endcase
    
    // 更新相关配置
    setup_mhsa_defaults();
  endfunction
  
  // === 配置信息打印 ===
  virtual function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("MHSA Configuration [%s]:\n", test_scenario)};
    
    // 架构信息
    s = {s, $sformatf("  Architecture: %0dx%0d Matrix, %0d Vector\n", 
                      matrix_size, matrix_size, vector_length)};
    s = {s, $sformatf("  MAC Units: %0d, Accumulator Depth: %0d\n", 
                      mac_units_count, accumulator_depth)};
    
    // 计算模式
    s = {s, $sformatf("  Mode: %0s", enable_float_mode ? "FLOAT" : 
                     (enable_fixed_point ? $sformatf("FIXED(%0d.%0d)", 
                      fixed_point_precision - fixed_point_fraction, fixed_point_fraction) : "UNKNOWN"))};
    s = {s, $sformatf(", Pipeline: %0s (%0d stages)\n", 
                      enable_pipeline_mode ? "ENABLED" : "DISABLED", pipeline_stages)};
    
    // 功能使能
    s = {s, $sformatf("  Features: MAC=%0d, ACC=%0d, NORM=%0d, ACT=%0d, BIAS=%0d\n",
                      enable_mac_units, enable_accumulator, enable_normalization,
                      enable_activation, enable_bias_addition)};
    
    // 性能目标
    if(enable_perf_monitoring) begin
      s = {s, $sformatf("  Performance: Target %0d GOPS, Latency %0d cycles\n",
                        throughput_target, latency_target)};
      s = {s, $sformatf("  Peak Performance: %0.1f GOPS\n", get_peak_performance())};
    end
    
    // 内存配置
    s = {s, $sformatf("  Memory: Reg@%8h(%0d), Data@%8h(%0d)\n",
                      reg_base_addr, reg_space_size, data_base_addr, data_space_size)};
    s = {s, $sformatf("  Memory Requirement: %0d bytes\n", get_memory_requirement() * 4)};
    
    // 测试模式
    if(enable_stress_test) 
      s = {s, $sformatf("  Stress Testing: ENABLED\n")};
    if(enable_error_injection) 
      s = {s, $sformatf("  Error Injection: ENABLED\n")};
    if(enable_corner_case_test) 
      s = {s, $sformatf("  Corner Case Testing: ENABLED\n")};
    
    // 操作统计
    s = {s, $sformatf("  Total Operations: %0d\n", get_total_operations())};
    
    return s;
  endfunction
  
  // === 获取配置摘要 ===
  virtual function string get_config_summary();
    string summary = $sformatf("MHSA[%s|%0dx%0d|MAC%0d|%s|PERF%0d]",
                               test_scenario, matrix_size, matrix_size, 
                               mac_units_count,
                               enable_float_mode ? "FLOAT" : "FIXED",
                               enable_perf_monitoring);
    return summary;
  endfunction
 /* 
  // === 更新APB接口 ===
  virtual function void set_apb_interface(virtual apb_interface intf);
    apb_intf = intf;
    if(mhsa_mstr_agnt_cfg != null) begin
      mhsa_mstr_agnt_cfg.set_interface(intf);
    end
  endfunction
*/
endclass

`endif
