
import "DPI-C" function void calculate_mhsa(
    input  logic signed [7:0] X_in[32][128], 
    input  logic signed [7:0] WQ_in[128][128],
    input  logic signed [7:0] WK_in[128][128],
    input  logic signed [7:0] WV_in[128][128],
    input  logic signed [7:0] W_in[128][128],
    output logic signed [7:0] out_s8[32][128]
);
class mhsa_driver extends apb_master_driver;
   `uvm_component_utils(mhsa_driver)

  // Constructor
  function new(string name="mhsa_driver", uvm_component parent);
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
          cal_mhsa(item);
          drv2scb.write(item);
      seq_item_port.item_done();
      end
  endtask

  // Other Tasks
  task wr_data(input apb_seq_item item);
    @(apb_intf.cb);

    apb_intf.cb.input_data   <= item.input_data;
    apb_intf.cb.weight_q  <= item.weight_q;
    apb_intf.cb.weight_k  <= item.weight_k;
    apb_intf.cb.weight_v  <= item.weight_v;
    apb_intf.cb.weight_in <= item.weight_in;
    
  endtask

  task cal_mhsa(apb_seq_item item);

    calculate_mhsa(
      item.input_data,
      item.weight_q,
      item.weight_k,
      item.weight_v,
      item.weight_in,
      item.result
    );

  endtask 


endclass:mhsa_driver

