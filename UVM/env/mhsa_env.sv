`ifndef MHSA_ENV_SV
`define MHSA_ENV_SV

class mhsa_env extends uvm_env;
  `uvm_component_utils(mhsa_env);

  // Configuration subcomponents
  mhsa_mstr_agent                      i_agt;
  mhsa_scb                             scb;
  mhsa_config                          w_cfg;
  mhsa_virtual_sequencer               virt_sqr;

  uvm_tlm_analysis_fifo #(mhsa_base_seq_item) i_agt_drv_scb_fifo;
  uvm_tlm_analysis_fifo #(mhsa_base_seq_item) i_agt_mon_scb_fifo;


  // Constructor
  function new(string name="mhsa_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   // Set interface
   // Get configuration from test layer
   if(!uvm_config_db#(mhsa_config)::get(this,"","MHSA_ENV_CFG",w_cfg))begin
     `uvm_fatal("ENV_CFG NOT FOUND ERROR",$psprintf("mhsa_config not found"))
   end
   uvm_config_db#(mhsa_mstr_agent_config)::set(null,"*","MHSA_MSTR_AGNT_CFG",w_cfg.mhsa_mstr_agnt_cfg);
   uvm_config_db#(mhsa_config)::set(this, "virt_sqr", "cfg", w_cfg);
//   uvm_config_db#(mhsa_config)::set(this, "cov", "cfg", cfg);
   uvm_config_db#(mhsa_config)::set(this, "scb", "cfg", w_cfg); //scb hasn't use this

   // Build components
   i_agt = mhsa_mstr_agent::type_id::create("i_agt",this);
   scb = mhsa_scb::type_id::create("scb",this);   
   virt_sqr = mhsa_virtual_sequencer::type_id::create("virt_sqr", this);
   i_agt_drv_scb_fifo = new("i_agt_drv_scb_fifo",this);
   i_agt_mon_scb_fifo = new("i_agt_mon_scb_fifo",this);

 endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("CFG_START", "=== Configuration at Start of Simulation ===", UVM_LOW)
    `uvm_info("CFG_DETAILS", w_cfg.convert2string(), UVM_LOW)
  endfunction

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
   //mon2scb
    i_agt.mhsa_mntr.ap.connect(i_agt_mon_scb_fifo.analysis_export);
    scb.act_port.connect(i_agt_mon_scb_fifo.blocking_get_export);
    //drv2scb
    i_agt.mhsa_mstr_drvr.drv2scb.connect(i_agt_drv_scb_fifo.analysis_export);
    scb.exp_port.connect(i_agt_drv_scb_fifo.blocking_get_export);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
  endfunction



endclass:mhsa_env

`endif // MHSA_ENV_SV
