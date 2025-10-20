class mac_sequence extends apb_base_sequence;
    `uvm_object_utils_begin(mac_sequence)
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
  function new(string name="mac_sequence");
    super.new(name);
  endfunction

  // Main Task
  virtual task body();
    item = apb_seq_item::type_id::create("item");
    
    if (!item.randomize()) begin
      `uvm_error("RAND_FAIL", "MAC item randomization failed")
    end

    item_set();
    
    start_item(item); 
    finish_item(item);
  endtask : body

  // Test case configuration
  function void item_set();
    `uvm_info("MAC_SEQ_CFG", $sformatf("Configuring test case: %0d", write_config), UVM_LOW)
    
    case(write_config)
      TEST_ALL_ONES:  configure_all_max();
      TEST_RANDOM:    configure_random();
      TEST_ZEROS:     configure_all_zeros();
      TEST_OVERFLOW:  configure_overflow();
      TEST_DIM_CROSS: configure_dim_cross();
      TEST_SIGN_EXT:  configure_sign_extension();
      default: `uvm_error("MAC_CFG_ERR", "Invalid test configuration")
    endcase
  endfunction : item_set

  // Test case implementations -------------------------------------------------
  
  // Test 1: Full precision stress test
  function void configure_all_max();
    set_all_matrices(8'h1);  // Max positive value
  endfunction

  // Test 2: Random value verification
  function void configure_random();
    foreach(item.Q_32x16x16x32[i,j]) begin
      item.Q_32x16x16x32[i][j] = $urandom_range(0, 255);
      item.K_32x16x16x32[j][i] = $urandom_range(0, 255);  // Transposed
    end
    
    foreach(item.Q_32x32x32x16[i,j]) begin
      item.Q_32x32x32x16[i][j] = $urandom_range(0, 255);
      item.K_32x32x32x16[i][j] = $urandom_range(0, 255);
    end

    foreach(item.Q_32x128x128x128[i,j]) begin
      item.Q_32x128x128x128[i][j] = $urandom_range(0, 255);
      item.K_32x128x128x128[j][i] = $urandom_range(0, 255);  // Transposed
    end
  endfunction

  // Test 3: Zero input verification
  function void configure_all_zeros();
    set_all_matrices(8'h00);
  endfunction

  // Test 4: Overflow detection test
  function void configure_overflow();
    // 32x16 & 16x32 matrix
    foreach(item.Q_32x16x16x32[i,j]) begin
      item.Q_32x16x16x32[i][j] = 8'h7F;
      item.K_32x16x16x32[j][i] = 8'h7F;
    end
    
    // 32x32 & 32x16 matrix
    foreach(item.Q_32x32x32x16[i,j]) begin
      item.Q_32x32x32x16[i][j] = 8'h7F;
      item.K_32x32x32x16[i][j] = 8'h7F;
    end
  endfunction

  // Test 5: Dimension cross verification
  function void configure_dim_cross();
    // Pattern for 32x16 & 16x32
    for (int i=0; i<32; i++) begin
      for (int j=0; j<16; j++) begin
        item.Q_32x16x16x32[i][j] = i + j;
        item.K_32x16x16x32[j][i] = (i << 4) | j;
      end
    end

    // Pattern for 32x32 & 32x16
    for (int i=0; i<32; i++) begin
      for (int j=0; j<32; j++) begin
        item.Q_32x32x32x16[i][j] = (i == j) ? 8'h01 : 8'h00;
      end
      for (int j=0; j<16; j++) begin
        item.K_32x32x32x16[i][j] = (i < 16) ? 8'h01 : 8'hFF;
      end
    end
  endfunction

  // Test 6: Sign extension verification
  function void configure_sign_extension();
    // Set negative values for signed matrices
    foreach(item.Q_32x128x128x128[i,j]) begin
      item.Q_32x128x128x128[i][j] = (j%2) ? 8'h80 : 8'h7F;
      item.K_32x128x128x128[j][i] = (i%2) ? 8'h80 : 8'h7F;
    end
  endfunction

  // Common utility functions ---------------------------------------------------
  
  function void set_all_matrices(byte val);
    // Set all Q/K matrices
    foreach(item.Q_32x16x16x32[i,j])    item.Q_32x16x16x32[i][j] = val;
    foreach(item.K_32x16x16x32[i,j])    item.K_32x16x16x32[i][j] = val;
    foreach(item.Q_32x32x32x16[i,j])    item.Q_32x32x32x16[i][j] = val;
    foreach(item.K_32x32x32x16[i,j])    item.K_32x32x32x16[i][j] = val;
    foreach(item.Q_32x128x128x128[i,j]) item.Q_32x128x128x128[i][j] = val;
    foreach(item.K_32x128x128x128[i,j]) item.K_32x128x128x128[i][j] = val;
  endfunction

endclass : mac_sequence
