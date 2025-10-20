// bus_layer_config.sv
class bus_layer_config extends uvm_object;
  // 总线类型选择
  string bus_type = "APB";  // "APB", "AXI", "AHB", "TLM"
  
  // 通用总线参数
  rand int data_width = 32;
  rand int address_width = 32;
  rand int max_burst_size = 1;
  
  // 时序参数
  rand int clock_period_ps = 10_000;  // 100MHz
  rand int reset_duration_cycles = 10;
  
  // 协议特性
  rand bit support_burst = 0;
  rand bit support_out_of_order = 0;
  rand bit support_pipelining = 0;
  
  `uvm_object_utils_begin(bus_layer_config)
    `uvm_field_string(bus_type, UVM_ALL_ON)
    `uvm_field_int(data_width, UVM_ALL_ON)
    `uvm_field_int(address_width, UVM_ALL_ON)
    `uvm_field_int(clock_period_ps, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "bus_layer_config");
    super.new(name);
  endfunction
endclass
