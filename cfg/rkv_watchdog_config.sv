// rkv_watchdog_config.sv - 改进版
class rkv_watchdog_config extends generic_env_config;
  // 继承所有通用配置
  
  // watchdog特定参数
  rand int num_watchdogs = 1;
  rand int default_timeout_value = 1000;
  rand bit enable_interrupt_mode = 1;
  rand bit enable_reset_mode = 1;
  
  // 总线配置实例
  bus_layer_config bus_cfg;
  
  // 功能配置实例  
  functional_layer_config func_cfg;
  
  // 具体接口
  virtual rkv_watchdog_if vif;
  rkv_watchdog_rgm rgm;

  `uvm_object_utils_begin(rkv_watchdog_config)
    `uvm_field_int(num_watchdogs, UVM_ALL_ON)
    `uvm_field_int(default_timeout_value, UVM_ALL_ON)
    `uvm_field_object(bus_cfg, UVM_ALL_ON)
    `uvm_field_object(func_cfg, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "rkv_watchdog_config");
    super.new(name);
    bus_cfg = bus_layer_config::type_id::create("bus_cfg");
    func_cfg = functional_layer_config::type_id::create("func_cfg");
  endfunction
endclass
