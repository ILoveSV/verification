`ifndef AHBRAM_BASE_TEST_SV
`define AHBRAM_BASE_TEST_SV

virtual class ahbram_base_test extends uvm_test;
// no uvm utils?

  // Configuration subcomponents
  ahbram_config            cfg;
  ahbram_env               env;
  ahbram_rgm               rgm;
 
  // Constructor
  function new(string name="ahbram_base_test",uvm_component parent=null);
   super.new(name,parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   // Build
   env = ahbram_env::type_id::create("env",this);
   cfg = ahbram_config::type_id::create("cfg");
  
   rgm = ahbram_rgm::type_id::create("rgm");
   rgm.build();
   cfg.rgm = rgm;

   // Set Configuration


    // do parameter configuration
    cfg.addr_start = 32'h0;
    cfg.addr_end = 32'h0000_FFFF;

   // Set inteface
   if(!uvm_config_db#(virtual ahbram_if)::get(this,"","vif", cfg.vif))
     `uvm_fatal("GETCFG","cannot get virtual interface from config DB")


   // Send configuration to env
   uvm_config_db#(ahbram_config)::set(this, "env", "cfg", cfg);

  endfunction

  // Report Phase
  function void report_phase(uvm_phase phase);
    uvm_report_server server;
    int err_num;
    super.report_phase(phase);

    server = get_report_server();
    err_num = server.get_severity_count(UVM_ERROR);

    if(err_num != 0)begin
      $display("TEST CASE FAILED");
      end
      else begin
      $display("TEST CASE PASSED");
    end
  endfunction

endclass

`endif
