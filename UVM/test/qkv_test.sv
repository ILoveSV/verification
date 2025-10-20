class qkv_test extends mhsa_base_test;
  `uvm_component_utils(qkv_test)

  // Constructor
  function new(string name="qkv_test",uvm_component parent);
     super.new(name,parent);
   endfunction

  // Build Phase
 virtual function void build_phase(uvm_phase phase);
   apb_master_driver::type_id::set_type_override(qkv_driver::get_type());
   apb_seq_item::type_id::set_type_override(qkv_seq_item::get_type());
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

   fork
      begin
       write_data(4'h2);
      end
      begin
        #50000;
      end
   join 

   phase.drop_objection(this);
 endtask

  // Other tasks
  task write_data(input logic [3:0] write_config);
   qkv_sequence wr_seq;
   wr_seq=qkv_sequence::type_id::create("wr_seq",this);
   wr_seq.write_config=write_config;
   wr_seq.start(env.i_agt.apb_mstr_seqr);
  endtask


 endclass
