
class mhsa_env extends uvm_env;
  `uvm_component_utils(mhsa_env);

  // Configuration subcomponents
  apb_mstr_agent i_agt;
  mhsa_scb      scb;
  mhsa_cfg      w_cfg;

  uvm_tlm_analysis_fifo #(apb_seq_item) i_agt_drv_scb_fifo;
  uvm_tlm_analysis_fifo #(apb_seq_item) i_agt_mon_scb_fifo;


  // Constructor
  function new(string name="mhsa_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
   super.build_phase(phase);

   // Set interface
   if(!uvm_config_db#(mhsa_cfg)::get(this,"","APB_ENV_CFG",w_cfg))begin
     `uvm_fatal("ENV_CFG_NOT FOUND ERROR",$psprintf("mhsa_cfg not get found"))
   end
   uvm_config_db#(apb_mstr_agent_config)::set(null,"*","APB_MSTR_AGNT_CFG",w_cfg.apb_mstr_agnt_cfg);

   // Build components
   i_agt = apb_mstr_agent::type_id::create("i_agt",this);
   scb = mhsa_scb::type_id::create("scb",this);
   i_agt_drv_scb_fifo = new("i_agt_drv_scb_fifo",this);
   i_agt_mon_scb_fifo = new("i_agt_mon_scb_fifo",this);

 endfunction

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
   //mon2scb
    i_agt.apb_mntr.ap.connect(i_agt_mon_scb_fifo.analysis_export);
    scb.act_port.connect(i_agt_mon_scb_fifo.blocking_get_export);
    //drv2scb
    i_agt.apb_mstr_drvr.drv2scb.connect(i_agt_drv_scb_fifo.analysis_export);
    scb.exp_port.connect(i_agt_drv_scb_fifo.blocking_get_export);
  endfunction

endclass:mhsa_env
