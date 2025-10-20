import "DPI-C" function void calculate_QKT_32x16x16x32(
    input  logic signed [7:0] Q_32x16x16x32 [32][16],
    input  logic signed [7:0] K_32x16x16x32 [16][32],
    output logic signed [20:0] QKT_32x16x16x32 [32][32]
);

import "DPI-C" function void calculate_QKT_32x32x32x16(
    input  logic signed [7:0] Q_32x32x32x16 [32][32],
    input  logic signed [7:0] K_32x32x32x16 [32][16],
    output logic signed [20:0] QKT_32x32x32x16 [32][16]
);

import "DPI-C" function void calculate_QKT_32x128x128x128(
    input  logic signed [7:0] Q_32x128x128x128 [32][127:0],  // 修正索引范围
    input  logic signed [7:0] K_32x128x128x128 [127:0][127:0],
    output logic signed [22:0] QKT_32x128x128x128 [32][127:0]
);
class mac_driver extends apb_master_driver;
   `uvm_component_utils(mac_driver)

  // Constructor
  function new(string name="mac_driver", uvm_component parent);
    super.new(name,parent);
  endfunction:new

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction:build_phase

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction:connect_phase
  
  // Run Phase
  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    apb_intf.reset_intf();

      forever begin
      @(apb_intf.cb);
      seq_item_port.get_next_item(item);
          wr_data(item);
          cal_mac(item);
          drv2scb.write(item);
      seq_item_port.item_done();
      end
  endtask

  // Other Tasks
  task wr_data(input apb_seq_item item);
    @(apb_intf.cb);

    apb_intf.cb.Q_32x16x16x32  <= item.Q_32x16x16x32;
    apb_intf.cb.K_32x16x16x32  <= item.K_32x16x16x32;
    apb_intf.cb.Q_32x32x32x16  <= item.Q_32x32x32x16;
    apb_intf.cb.K_32x32x32x16  <= item.K_32x32x32x16;
    apb_intf.cb.Q_32x128x128x128 <= item.Q_32x128x128x128;
    apb_intf.cb.K_32x128x128x128 <= item.K_32x128x128x128;
  endtask



task cal_mac(apb_seq_item mac_item);


  // 调用32x16x16x32计算
  calculate_QKT_32x16x16x32(
    mac_item.Q_32x16x16x32,
    mac_item.K_32x16x16x32,
    mac_item.QKT_32x16x16x32
  );
  // 调用32x32x32x16计算
  calculate_QKT_32x32x32x16(
    mac_item.Q_32x32x32x16,
    mac_item.K_32x32x32x16,
    mac_item.QKT_32x32x32x16
  );
  // 调用32x128x128x128计算
  calculate_QKT_32x128x128x128(
    mac_item.Q_32x128x128x128,
    mac_item.K_32x128x128x128,
    mac_item.QKT_32x128x128x128
  );


endtask

endclass:mac_driver

