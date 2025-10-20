class mhsa_base_test extends uvm_test;
 `uvm_component_utils(mhsa_base_test)

  // Configuration subcomponents
 mhsa_env  env;
 mhsa_cfg  w_cfg;
 apb_mstr_agent_config apb_cfg;

  // Constructor
  function new(string name="mhsa_base_test",uvm_component parent=null);
   super.new(name,parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   // Build
   env=mhsa_env::type_id::create("env",this);
   apb_cfg=apb_mstr_agent_config::type_id::create("apb_cfg",this);
   w_cfg=mhsa_cfg::type_id::create("w_cfg",this);

   // Set interface
   if(!uvm_config_db#(virtual apb_interface)::get(this,"","APB_INTF",w_cfg.apb_mstr_agnt_cfg.apb_intf))begin
     `uvm_fatal("INTERFACE NOT FOUND ERROR",$psprintf("apb_interface not get"))
   end
   w_cfg.apb_mstr_agnt_cfg.is_active=UVM_ACTIVE;
   uvm_config_db#(mhsa_cfg)::set(null,"","APB_ENV_CFG",w_cfg);

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
