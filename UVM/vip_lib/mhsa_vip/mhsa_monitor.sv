/* import "DPI-C" function void export_2d_array8bit(
        inout logic signed [7:0] array[][],
        input string filename
    );
*/ 
class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  // Configuration subcomponents
  apb_mstr_agent_config   apb_mstr_agnt_cfg;
  virtual apb_interface   apb_intf;
  uvm_analysis_port#(apb_seq_item) ap;

  // Constructor
  function new(string name ="apb_monitor", uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // Main Task
  /*QKV
  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    super.run_phase(phase); 
     #45000;
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item=apb_seq_item::type_id::create("item"); 
         item.result_Q <= apb_intf.result_Q;
         item.result_K <= apb_intf.result_K;
         item.result_V <= apb_intf.result_V;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #200000;
        end
  endtask : run_phase
  */
  /*MAC
  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    super.run_phase(phase); 
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item=apb_seq_item::type_id::create("item"); 
         item.weight_in <= apb_intf.weight_in;
         item.QKT_32x16x16x32 <= apb_intf.QKT_32x16x16x32;
         item.QKT_32x32x32x16 <= apb_intf.QKT_32x32x32x16;
         item.QKT_32x128x128x128 <= apb_intf.QKT_32x128x128x128;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #20100;
        end
  endtask : run_phase
  */
  virtual task run_phase(uvm_phase phase);
    apb_seq_item item;
    super.run_phase(phase); 
     #187000;
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item=apb_seq_item::type_id::create("item"); 
         item.result <= apb_intf.result;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #200000;
        end
  endtask : run_phase

endclass : apb_monitor
