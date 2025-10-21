
import "DPI-C" function void calculate_QKV(
    input  logic signed [7:0] X_in[32][128], 
    input  logic signed [7:0] WQ_in[128][128],
    input  logic signed [7:0] WK_in[128][128],
    input  logic signed [7:0] WV_in[128][128],
    output logic signed [7:0] result_Q[32][128],
    output logic signed [7:0] result_K[32][128],
    output logic signed [7:0] result_V[32][128]
);
class qkv_driver extends mhsa_master_driver;
   `uvm_component_utils(qkv_driver)

  // Constructor
  function new(string name="qkv_driver", uvm_component parent);
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
    mhsa_base_seq_item item;
    apb_intf.reset_intf();

      forever begin
      @(apb_intf.cb);
      seq_item_port.get_next_item(item);
          wr_data(item);
          cal_qkv(item);
          drv2scb.write(item);
      seq_item_port.item_done();
      end
  endtask

  // Other Tasks
  task wr_data(input mhsa_base_seq_item item);
    @(apb_intf.cb);

    apb_intf.cb.X_in  <= item.X_in;
    apb_intf.cb.WQ_in  <= item.WQ_in;
    apb_intf.cb.WK_in  <= item.WK_in;
    apb_intf.cb.WV_in  <= item.WV_in;

  endtask



task cal_qkv(mhsa_base_seq_item item);

  calculate_QKV(
    item.X_in,
    item.WQ_in,
    item.WK_in,
    item.WV_in,
    item.result_Q,
    item.result_K,
    item.result_V
  );


endtask

endclass:qkv_driver

