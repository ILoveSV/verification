class apb_mstr_agent extends uvm_agent;
  `uvm_component_utils(apb_mstr_agent)

  // Configuration subcomponents
  mhsa_mstr_agent_config  mhsa_mstr_agnt_cfg;
  apb_master_driver      apb_mstr_drvr;
  apb_monitor            apb_mntr;
  apb_mstr_sequencer     apb_mstr_seqr;

  // Constructor
  function new(string name="apb_mstr_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(mhsa_mstr_agent_config)::get(
        this, "", "APB_MSTR_AGNT_CFG", mhsa_mstr_agnt_cfg)) begin
      `uvm_fatal("AGENT_CFG_ERR", 
          "Failed to get mhsa_mstr_agnt_cfg from uvm_config_db")
    end

    apb_mntr = apb_monitor::type_id::create("apb_mntr", this);

    if (mhsa_mstr_agnt_cfg.is_active == UVM_ACTIVE) begin
      apb_mstr_drvr = apb_master_driver::type_id::create("apb_mstr_drvr", this);
      apb_mstr_seqr = apb_mstr_sequencer::type_id::create("apb_mstr_seqr", this);
    end
  endfunction : build_phase

  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (mhsa_mstr_agnt_cfg.is_active == UVM_ACTIVE) begin
      apb_mstr_drvr.mhsa_mstr_agnt_cfg = mhsa_mstr_agnt_cfg;
      apb_mstr_drvr.apb_intf          = mhsa_mstr_agnt_cfg.apb_intf;
      apb_mstr_drvr.seq_item_port.connect(apb_mstr_seqr.seq_item_export);
    end

    apb_mntr.apb_intf          = mhsa_mstr_agnt_cfg.apb_intf;
    apb_mntr.mhsa_mstr_agnt_cfg = mhsa_mstr_agnt_cfg;
  endfunction : connect_phase

endclass : apb_mstr_agent
