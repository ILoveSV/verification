class demo_test extends mhsa_base_test;
  `uvm_component_utils(demo_test)

  // Constructor
  function new(string name="demo_test",uvm_component parent);
     super.new(name,parent);
   endfunction

  // Build Phase
 virtual function void build_phase(uvm_phase phase);
   apb_master_driver::type_id::set_type_override(mhsa_driver::get_type());
   mhsa_base_seq_item::type_id::set_type_override(mhsa_seq_item::get_type());
   super.build_phase(phase);
  endfunction

  // Connect Phase
 virtual function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
 endfunction

  // Run Phase
 virtual task run_phase(uvm_phase phase);
   super.run_phase(phase);
   phase.raise_objection(this);
   `uvm_info("demo_test",$psprintf("test-run-phase-111"),UVM_NONE)
   fork
      begin
       write_data(4'h1);
       
    //   write_data(4'h2);
    //   #200000;
    //   write_data(4'h4);
    //   #200000;
    //   write_data(4'h5);
      end
      begin
        #190000;
      end

   join 
     `uvm_info("demo_test",$psprintf("test-run-phase-222"),UVM_NONE)

   phase.drop_objection(this);
 endtask

  // Other tasks
  task write_data(input logic [3:0] write_config);
   mhsa_sequence wr_seq;
   wr_seq=mhsa_sequence::type_id::create("wr_seq",this);
   wr_seq.write_config=write_config;
   wr_seq.start(env.i_agt.apb_mstr_seqr);
  endtask


 endclass
