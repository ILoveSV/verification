
`ifndef MHSA_MONITOR_SV
`define MHSA_MONITOR_SV
  function mhsa_monitor::new(string name ="mhsa_monitor", uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  function void mhsa_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    item=mhsa_base_seq_item::type_id::create("item"); 
  endfunction

  task mhsa_monitor::run_phase(uvm_phase phase);

    super.run_phase(phase);

    case(item.module_type)
    MHSA: begin
     #187000;
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item.result <= apb_intf.result;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #200000;
        end
    end
    QKV: begin
     #45000;
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item.result_Q <= apb_intf.result_Q;
         item.result_K <= apb_intf.result_K;
         item.result_V <= apb_intf.result_V;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #200000;
        end
    end
    MAC: begin
     forever begin  
         @(apb_intf.cb);
         `uvm_info("mon",$psprintf("result monitored!"),UVM_NONE)
         item.weight_in <= apb_intf.weight_in;
         item.QKT_32x16x16x32 <= apb_intf.QKT_32x16x16x32;
         item.QKT_32x32x32x16 <= apb_intf.QKT_32x32x32x16;
         item.QKT_32x128x128x128 <= apb_intf.QKT_32x128x128x128;
         @(apb_intf.cb);
         ap.write(item);
         `uvm_info("mon",$psprintf("monitor ap write!"),UVM_NONE)
         #20100;
        end
    end
    endcase
  endtask

`endif // MHSA_MONITOR_SV
