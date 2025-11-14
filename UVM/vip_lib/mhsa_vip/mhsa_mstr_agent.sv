
`ifndef MHSA_MSTR_AGENT_SV
`define MHSA_MSTR_AGENT_SV
  // Constructor
  function mhsa_mstr_agent::new(string name="mhsa_mstr_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Build Phase
  function void mhsa_mstr_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(mhsa_mstr_agent_config)::get(
        this, "", "MHSA_MSTR_AGNT_CFG", mhsa_mstr_agnt_cfg)) begin
      `uvm_fatal("AGENT_CFG_ERR", 
          "Failed to get mhsa_mstr_agnt_cfg from uvm_config_db")
    end

    mhsa_mntr = mhsa_monitor::type_id::create("mhsa_mntr", this);

    if (mhsa_mstr_agnt_cfg.is_active == UVM_ACTIVE) begin
      mhsa_mstr_drvr = mhsa_master_driver::type_id::create("mhsa_mstr_drvr", this);
      mhsa_mstr_seqr = mhsa_mstr_sequencer::type_id::create("mhsa_mstr_seqr", this);
    end
  endfunction : build_phase

  // Connect Phase
  function void mhsa_mstr_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (mhsa_mstr_agnt_cfg.is_active == UVM_ACTIVE) begin
      mhsa_mstr_drvr.mhsa_mstr_agnt_cfg = mhsa_mstr_agnt_cfg;
      mhsa_mstr_drvr.apb_intf          = mhsa_mstr_agnt_cfg.apb_intf;
      mhsa_mstr_drvr.seq_item_port.connect(mhsa_mstr_seqr.seq_item_export);
    end

    mhsa_mntr.apb_intf          = mhsa_mstr_agnt_cfg.apb_intf;
    mhsa_mntr.mhsa_mstr_agnt_cfg = mhsa_mstr_agnt_cfg;
  endfunction : connect_phase

`endif
