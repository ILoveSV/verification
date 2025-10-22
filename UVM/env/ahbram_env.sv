`ifndef AHBRAM_ENV_SV
`define AHBRAM_ENV_SV

class ahbram_env extends uvm_env;
  `uvm_component_utils(ahbram_env);

  // Configuration subcomponents
  lvc_ahb_master_agent                     ahb_mst;
  ahbram_config                            cfg;
  ahbram_virtual_sequencer                 virt_sqr;

  ahbram_rgm                               rgm;
  uvm_reg_predictor #(lvc_ahb_transaction) predictor;
  ahbram_reg_adapter                       adapter;

  ahbram_cov                               cov;
  ahbram_scoreboard                        scb;


  // Constructor
  function new(string name="ahbram_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   // Set interface
   // Get configuration from test layer
   if(!uvm_config_db#(ahbram_config)::get(this,"","cfg",cfg))
     `uvm_fatal("ENV_CFG NOT FOUND ERROR",$psprintf("ahbram_config not found"))
   uvm_config_db#(ahbram_config)::set(this, "virt_sqr", "cfg", cfg);
   uvm_config_db#(ahbram_config)::set(this, "cov", "cfg", cfg);
   uvm_config_db#(ahbram_config)::set(this, "scb", "cfg", cfg);
   uvm_config_db#(lvc_ahb_agent_configuration)::set(this, "ahb_mst", "cfg", cfg.ahb_cfg);

   // Build components
   ahb_mst  = lvc_ahb_master_agent::type_id::create("ahb_mst", this);
   virt_sqr = ahbram_virtual_sequencer::type_id::create("virt_sqr", this);
   rgm      = cfg.rgm;

   uvm_config_db#(ahbram_rgm)::set(this,"*","rgm", rgm);
   adapter = ahbram_reg_adapter::type_id::create("adapter", this);
   predictor = uvm_reg_predictor#(lvc_ahb_transaction)::type_id::create("predictor", this);
   cov = ahbram_cov::type_id::create("cov", this);
   scb = ahbram_scoreboard::type_id::create("scb",this);   

 endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("CFG_START", "=== Configuration at Start of Simulation ===", UVM_LOW)
    `uvm_info("CFG_DETAILS", cfg.convert2string(), UVM_LOW)
  endfunction

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    virt_sqr.ahb_mst_sqr = ahb_mst.sequencer;   // attach vip sqr to env virtual sqr
    rgm.map.set_sequencer(ahb_mst.sequencer, adapter);
    predictor.map = rgm.map;
    predictor.adapter = adapter;
    ahb_mst.monitor.item_observed_port.connect(predictor.bus_in);
    ahb_mst.monitor.item_observed_port.connect(cov.ahb_trans_observed_imp);
    ahb_mst.monitor.item_observed_port.connect(scb.ahb_trans_observed_imp);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction



endclass:ahbram_env

`endif // AHBRAM_ENV_SV
