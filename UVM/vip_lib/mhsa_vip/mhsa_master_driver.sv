`ifndef MHSA_MASTER_DRIVER
`define MHSA_MASTER_DRIVER

  function mhsa_master_driver::new(string name="mhsa_master_driver", uvm_component parent);
    super.new(name,parent);
    drv2scb=new("drv2scb",this);
  endfunction

  function void mhsa_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task mhsa_master_driver::run_phase(uvm_phase phase);
    apb_intf.reset_intf();
      forever begin
      @(apb_intf.cb);
      seq_item_port.get_next_item(item);
          wr_data(item);
          item.calculate_expected();
          drv2scb.write(item);
      seq_item_port.item_done();
      end
  endtask


  task mhsa_master_driver::wr_data(input mhsa_base_seq_item item);
    @(apb_intf.cb);
    case(item.module_type)
    MHSA: begin
    `uvm_info("driver", $psprintf("MHSA item drove"), UVM_NONE)
    apb_intf.cb.input_data   <= item.input_data;
    apb_intf.cb.weight_q  <= item.weight_q;
    apb_intf.cb.weight_k  <= item.weight_k;
    apb_intf.cb.weight_v  <= item.weight_v;
    apb_intf.cb.weight_in <= item.weight_in;
    end
    QKV: begin
    `uvm_info("driver", $psprintf("QKV item drove"), UVM_NONE)
    apb_intf.cb.X_in  <= item.X_in;
    apb_intf.cb.WQ_in  <= item.WQ_in;
    apb_intf.cb.WK_in  <= item.WK_in;
    apb_intf.cb.WV_in  <= item.WV_in;
    end
    MAC: begin
    `uvm_info("driver", $psprintf("MAC item drove"), UVM_NONE)
    apb_intf.cb.Q_32x16x16x32  <= item.Q_32x16x16x32;
    apb_intf.cb.K_32x16x16x32  <= item.K_32x16x16x32;
    apb_intf.cb.Q_32x32x32x16  <= item.Q_32x32x32x16;
    apb_intf.cb.K_32x32x32x16  <= item.K_32x32x32x16;
    apb_intf.cb.Q_32x128x128x128 <= item.Q_32x128x128x128;
    apb_intf.cb.K_32x128x128x128 <= item.K_32x128x128x128;
    end
    endcase
  endtask


`endif
