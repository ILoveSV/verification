class mhsa_sequence extends apb_base_sequence;
    `uvm_object_utils_begin(mhsa_sequence)
        `uvm_field_int(write_config, UVM_ALL_ON)
        `uvm_field_int(matrix_value, UVM_ALL_ON)
    `uvm_object_utils_end

  // Configuration subcomponents
    logic [7:0] matrix_value; 
    logic [3:0] write_config;
    apb_seq_item item;
    localparam TEST_ALL_ONES      = 4'd1;
    localparam TEST_RANDOM        = 4'd2;
    localparam INITIALIZATION     = 4'd3;
    localparam TEST_SCALE_FACTOR  = 4'd4;
    localparam TEST_HEAD_INDEP    = 4'd5;
    localparam TEST_SOFTMAX_SAT   = 4'd6;
    localparam TEST_NORM_STRESS   = 4'd7;

  // Constructor
  function new(string name="mhsa_sequence");
    super.new(name);
  endfunction : new

  // Main Task
  virtual task body();
    item = apb_seq_item::type_id::create("item");
    
    if (!item.randomize()) begin
      `uvm_error("RAND_FAIL", "Randomization failed for item")
    end

    item_set();
    
    start_item(item); 
    finish_item(item);
  endtask : body

  // Configuration Function
  function void item_set();
    `uvm_info("MHSA_SEQ_CFG", $sformatf("write_config=%0d", write_config), UVM_LOW)
    
    case(write_config)
      TEST_ALL_ONES:    configure_all_ones();
      TEST_RANDOM:      configure_random();
      INITIALIZATION:   configure_all_zero();
      TEST_SCALE_FACTOR:configure_scale_factor_test();
      TEST_HEAD_INDEP:  configure_head_independence();
      TEST_SOFTMAX_SAT: configure_softmax_saturation();
      TEST_NORM_STRESS: configure_norm_stress();
      default: `uvm_error("MHSA_SEQ_CFG_ERR", "Invalid write_config value")
    endcase
  endfunction : item_set

  // Test Configuration Functions
  
  // Test 1: All-ones matrix
  function void configure_all_ones();
    `uvm_info("MHSA_SEQ_CFG", "Configuring all-ones test", UVM_LOW)
    matrix_value = 1;
    set_all_matrices(matrix_value);
  endfunction : configure_all_ones

  // Test 2: Random values
  function void configure_random();
    `uvm_info("MHSA_SEQ_CFG", "Configuring random test", UVM_LOW)
    foreach(item.weight_q[i,j]) begin
      item.weight_q[i][j] = $urandom_range(0, 255);
    end
    foreach(item.weight_k[i,j]) begin
      item.weight_k[i][j] = $urandom_range(0, 255);
    end
    foreach(item.weight_v[i,j]) begin
      item.weight_v[i][j] = $urandom_range(0, 255);
    end
    foreach(item.weight_in[i,j]) begin
      item.weight_in[i][j] = $urandom_range(0, 255);
    end
    foreach(item.input_data[i,j]) begin
      item.input_data[i][j] = $urandom_range(0, 255);
    end
  endfunction : configure_random

  // Test 3: All-zero matrix
  function void configure_all_zero();
    `uvm_info("MHSA_SEQ_CFG", "Configuring all-zero test", UVM_LOW)
    matrix_value = 0;
    set_all_matrices(matrix_value);
  endfunction : configure_all_zero

  // Test 4: Scale factor verification
  function void configure_scale_factor_test();
    `uvm_info("MHSA_SEQ_CFG", "Configuring scale factor test", UVM_LOW)
    set_all_matrices(0);
    
    for (int i=0; i<32; i++) begin
      for (int j=0; j<16; j++) begin
        item.input_data[i][j] = 4;  // Q = 4
        item.weight_q[i][j]   = 1;
        item.weight_k[i][j]   = 1;
      end
    end
  endfunction : configure_scale_factor_test

  // Test 5: Multi-head independence
  function void configure_head_independence();
    `uvm_info("MHSA_SEQ_CFG", "Configuring head independence test", UVM_LOW)
    set_all_matrices(0);
    
    // Head 1
    for (int j=0; j<16; j++) begin
      item.input_data[0][j] = 1;
      item.weight_q[0][j]   = 1;
      item.weight_k[0][j]   = 1;
      item.weight_v[0][j]   = 1;
    end
    
    // Head 2
    for (int j=16; j<32; j++) begin
      item.input_data[0][j] = j-16;
      item.weight_q[0][j]   = (j-16)%8;
      item.weight_k[0][j]   = (j-16)%8;
      item.weight_v[0][j]   = (j-16)%8;
    end
  endfunction : configure_head_independence

  // Test 6: Softmax saturation
  function void configure_softmax_saturation();
    `uvm_info("MHSA_SEQ_CFG", "Configuring softmax saturation test", UVM_LOW)
    set_all_matrices(0);
    
    foreach(item.weight_q[i,j]) begin
      item.weight_q[i][j] = (i==0) ? 127 : 0;
    end
    foreach(item.weight_k[i,j]) begin
      item.weight_k[i][j] = 1;
    end
  endfunction : configure_softmax_saturation

  // Test 7: Normalization stress
  function void configure_norm_stress();
    `uvm_info("MHSA_SEQ_CFG", "Configuring normalization stress test", UVM_LOW)
    for (int i=0; i<32; i++) begin
      for (int j=0; j<128; j++) begin
        item.weight_q[i][j] = (j%2) ? 127 : 0;
        item.weight_k[i][j] = (j%2) ? 127 : 0;
      end
    end
  endfunction : configure_norm_stress

  // Other Functions
  function void set_all_matrices(byte val);
    foreach(item.input_data[i,j])  item.input_data[i][j]  = val;
    foreach(item.weight_q[i,j])    item.weight_q[i][j]    = val;
    foreach(item.weight_k[i,j])    item.weight_k[i][j]    = val;
    foreach(item.weight_v[i,j])    item.weight_v[i][j]    = val;
    foreach(item.weight_in[i,j])   item.weight_in[i][j]   = val;
  endfunction : set_all_matrices

endclass : mhsa_sequence
