`ifndef BUS_LAYER_CONFIG_SV
`define BUS_LAYER_CONFIG_SV

class bus_layer_config extends generic_env_config;
  `uvm_object_utils(bus_layer_config)
  
  // === 总线协议选择 ===
  string bus_protocol = "APB";           // 总线协议: APB, AXI, AHB
  int bus_data_width = 32;               // 数据位宽
  int bus_addr_width = 32;               // 地址位宽
  time bus_clock_period = 10ns;          // 总线时钟周期
  
  // === 总线代理配置 ===
  uvm_active_passive_enum bus_agent_active = UVM_ACTIVE;
  string bus_agent_type = "master";      // master/slive/monitor
  
  // === 具体协议配置 ===
 // apb_config apb_cfg;                    // APB具体配置
  
  // Constructor
  function new(string name = "bus_layer_config");
    super.new(name);
    // 默认创建APB配置
//    apb_cfg = apb_config::type_id::create("apb_cfg");
    bus_protocol = "APB";  // 默认协议
  endfunction
  
  // === 协议类型检查 ===
  virtual function bit is_apb();
    return (bus_protocol == "APB");
  endfunction
  
  virtual function bit is_axi();
    return (bus_protocol == "AXI");
  endfunction
  
  virtual function bit is_ahb();
    return (bus_protocol == "AHB");
  endfunction
  
  // === APB配置访问方法 ===
/*  virtual function apb_config get_apb_config();
    if(!is_apb()) begin
      `uvm_warning("BUS_CFG", "Requesting APB config but protocol is not APB")
    end
    return apb_cfg;
  endfunction
  
  virtual function void set_apb_config(apb_config cfg);
    apb_cfg = cfg;
    bus_protocol = "APB";  // 自动设置协议类型
    bus_clock_period = cfg.pclk_period;  // 同步时钟周期
  endfunction
*/  
  // === 总线特定验证 ===
  virtual function bit should_enable_bus_checks();
//    return enable_scb && (is_apb() ? apb_cfg.enable_protocol_checks : 1);
  endfunction
  
  virtual function bit should_enable_bus_coverage();
//    return enable_cov && (is_apb() ? apb_cfg.enable_apb_cov : 1);
  endfunction
  
  // 配置验证
  virtual function bit is_valid();
/*    if(!super.is_valid()) return 0;
    
    if(bus_data_width != 32 && bus_data_width != 64) begin
      `uvm_error("BUS_CFG", "Bus data width must be 32 or 64")
      return 0;
    end
    
    if(bus_clock_period <= 0) begin
      `uvm_error("BUS_CFG", "Bus clock period must be positive")
      return 0;
    end
    
    if(is_apb() && apb_cfg == null) begin
      `uvm_error("BUS_CFG", "APB configuration is null for APB protocol")
      return 0;
    end
  */  
    return 1;
  endfunction
  
  // 配置信息
  virtual function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("Bus Layer [%s]:\n", bus_protocol)};
    s = {s, $sformatf("  Data Width: %0d, Addr Width: %0d\n", bus_data_width, bus_addr_width)};
    s = {s, $sformatf("  Clock: %0t, Active: %0s\n", bus_clock_period, 
         (bus_agent_active == UVM_ACTIVE) ? "ACTIVE" : "PASSIVE")};
//    if(is_apb() && apb_cfg != null) begin
//      s = {s, "  ", apb_cfg.convert2string()};
//    end
    return s;
  endfunction

endclass

`endif
