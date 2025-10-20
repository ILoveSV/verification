class qkv_sequence extends apb_base_sequence;
    `uvm_object_utils_begin(qkv_sequence)
      `uvm_field_int(write_config, UVM_ALL_ON)
      `uvm_field_int(matrix_value, UVM_ALL_ON)
    `uvm_object_utils_end

  // Configuration subcomponents
    logic [7:0] matrix_value;
    logic [3:0] write_config;
    apb_seq_item item;
    localparam TEST_ALL_ONES      = 4'd1;
    localparam TEST_RANDOM        = 4'd2;
    localparam TEST_ZEROS         = 4'd3;
    localparam TEST_OVERFLOW      = 4'd4;
    localparam TEST_DIM_CROSS     = 4'd5;
    localparam TEST_SIGN_EXT      = 4'd6;

  // Constructor
  function new(string name="qkv_sequence");
    super.new(name);
  endfunction

  // Main Task
  virtual task body();
    item = apb_seq_item::type_id::create("item");
    
    if (!item.randomize()) begin
      `uvm_error("RAND_FAIL", "qkv item randomization failed")
    end

    item_set();
    
    start_item(item); 
    finish_item(item);
  endtask : body

  // Test case configuration
  function void item_set();
    `uvm_info("qkv_SEQ_CFG", $sformatf("Configuring test case: %0d", write_config), UVM_LOW)
    
    case(write_config)
      TEST_ALL_ONES:  configure_all_max();
      TEST_RANDOM:    configure_random();
      TEST_ZEROS:     configure_all_zeros();
      TEST_OVERFLOW:  configure_overflow();
      TEST_DIM_CROSS: configure_dim_cross();
      TEST_SIGN_EXT:  configure_sign_extension();
      default: `uvm_error("qkv_CFG_ERR", "Invalid test configuration")
    endcase
  endfunction : item_set

  // Test case implementations -------------------------------------------------
  
  // Test 1: Full precision stress test
  function void configure_all_max();
    set_all_matrices(8'h1);  // Max positive value for signed 8-bit
  endfunction

  // Test 2: Random value verification
  function void configure_random();
    // Randomize input matrices
    foreach(item.X_in[i,j])    item.X_in[i][j] = $urandom_range(0, 255);
    foreach(item.WQ_in[i,j])   item.WQ_in[i][j] = $urandom_range(0, 255);
    foreach(item.WK_in[i,j])   item.WK_in[i][j] = $urandom_range(0, 255);
    foreach(item.WV_in[i,j])   item.WV_in[i][j] = $urandom_range(0, 255);
  endfunction

  // Test 3: Zero input verification
  function void configure_all_zeros();
    set_all_matrices(8'h00);
  endfunction

  // Test 4: Overflow detection test
  function void configure_overflow();
    // Set matrices to max positive values
    foreach(item.X_in[i,j])    item.X_in[i][j] = 8'h7F;
    foreach(item.WQ_in[i,j])   item.WQ_in[i][j] = 8'h7F;
    foreach(item.WK_in[i,j])   item.WK_in[i][j] = 8'h7F;
    foreach(item.WV_in[i,j])   item.WV_in[i][j] = 8'h7F;
  endfunction

  // Test 5: Dimension cross verification
  function void configure_dim_cross();
    // X_in: 32x128 with row+col pattern
    for (int i=0; i<32; i++)
      for (int j=0; j<128; j++)
        item.X_in[i][j] = i + j;

    // WQ_in: Column index pattern
    for (int i=0; i<128; i++)
      for (int j=0; j<128; j++)
        item.WQ_in[i][j] = j;

    // WK_in: Identity matrix pattern
    foreach(item.WK_in[i,j])
      item.WK_in[i][j] = (i == j) ? 8'h01 : 8'h00;

    // WV_in: Block pattern
    for (int i=0; i<128; i++)
      for (int j=0; j<128; j++)
        item.WV_in[i][j] = (i < 64) ? 8'h01 : 8'hFF;
  endfunction

  // Test 6: Sign extension verification
  function void configure_sign_extension();
    // Set alternating positive/negative values
    foreach(item.X_in[i,j])    item.X_in[i][j] = (j%2) ? 8'h80 : 8'h7F;
    foreach(item.WQ_in[i,j])   item.WQ_in[i][j] = (i%2) ? 8'h80 : 8'h7F;
    foreach(item.WK_in[i,j])   item.WK_in[i][j] = (j%2) ? 8'h80 : 8'h7F;
    foreach(item.WV_in[i,j])   item.WV_in[i][j] = (i+j)%2 ? 8'h80 : 8'h7F;
  endfunction

  // Common utility functions ---------------------------------------------------
  
  function void set_all_matrices(byte val);
    // Set all input matrices to given value
    foreach(item.X_in[i,j])    item.X_in[i][j] = val;
    foreach(item.WQ_in[i,j])   item.WQ_in[i][j] = val;
    foreach(item.WK_in[i,j])   item.WK_in[i][j] = val;
    foreach(item.WV_in[i,j])   item.WV_in[i][j] = val;
  endfunction

endclass : qkv_sequence
