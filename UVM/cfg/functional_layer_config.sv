// functional_layer_config.sv
class functional_layer_config extends uvm_object;
  // 验证策略
  string verification_strategy = "black_box"; // "white_box", "grey_box"
  
  // 测试场景控制
  rand bit enable_stress_testing = 0;
  rand bit enable_corner_cases = 1;
  rand bit enable_error_injection = 1;
  
  // 覆盖策略
  rand bit enable_functional_coverage = 1;
  rand bit enable_code_coverage = 0;
  rand int coverage_goal_percentage = 95;
  
  // 检查策略
  rand bit enable_assertions = 1;
  rand bit enable_protocol_checking = 1;
  rand bit enable_data_integrity_check = 1;
  
  `uvm_object_utils_begin(functional_layer_config)
    `uvm_field_string(verification_strategy, UVM_ALL_ON)
    `uvm_field_int(enable_stress_testing, UVM_ALL_ON)
    `uvm_field_int(coverage_goal_percentage, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "functional_layer_config");
    super.new(name);
  endfunction
endclass
