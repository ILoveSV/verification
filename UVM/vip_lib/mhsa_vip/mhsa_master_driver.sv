`ifndef MHSA_MASTER_DRIVER
`define MHSA_MASTER_DRIVER

class mhsa_master_driver extends mhsa_driver;
   `uvm_component_utils(mhsa_master_driver)

   typedef enum {QKV, MAC, MHSA} module_type_e;
   module_type_e module_type;
  // Constructor
  function new(string name="mhsa_master_driver", uvm_component parent);
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
          case(item.module_type)
            MHSA: begin
              `uvm_info("driver", $psprintf("MHSA item calculate"), UVM_NONE)
                calculate_mhsa(
                 item.input_data,
                 item.weight_q,
                 item.weight_k,
                 item.weight_v,
                 item.weight_in,
                 item.result
               );
            end
            QKV: begin
              `uvm_info("driver", $psprintf("QKV item calculate"), UVM_NONE)
                calculate_QKV(
                  item.X_in,
                  item.WQ_in,
                  item.WK_in,
                  item.WV_in,
                  item.result_Q,
                  item.result_K,
                  item.result_V
                );
            end
            MAC: begin
              `uvm_info("driver", $psprintf("MAC item calculate"), UVM_NONE)
                calculate_QKT_32x16x16x32(
                  item.Q_32x16x16x32,
                  item.K_32x16x16x32,
                  item.QKT_32x16x16x32
                );
                calculate_QKT_32x32x32x16(
                  item.Q_32x32x32x16,
                  item.K_32x32x32x16,
                  item.QKT_32x32x32x16
                );
                calculate_QKT_32x128x128x128(
                  item.Q_32x128x128x128,
                  item.K_32x128x128x128,
                  item.QKT_32x128x128x128
                );
            end
          endcase

          drv2scb.write(item);
      seq_item_port.item_done();
      end
  endtask


  task wr_data(input mhsa_base_seq_item item);
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


endclass:mhsa_master_driver
`endif
