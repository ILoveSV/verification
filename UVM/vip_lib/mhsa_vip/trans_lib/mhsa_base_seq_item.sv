
class mhsa_base_seq_item extends uvm_sequence_item;
  
   typedef enum {QKV, MAC, MHSA} module_type_e;
   module_type_e module_type;

  `uvm_object_utils_begin(mhsa_base_seq_item)
    `uvm_field_enum(module_type_e, module_type, UVM_ALL_ON)
  `uvm_object_utils_end

  //Signal Definition
  //MHSA
  // Input signals
  logic signed [7:0] input_data [0:31][0:127];
  logic signed [7:0] weight_q   [0:127][0:127];
  logic signed [7:0] weight_k   [0:127][0:127];
  logic signed [7:0] weight_v   [0:127][0:127];
  logic signed [7:0] weight_in  [0:127][0:127];
  // Output signals
  logic signed [7:0] result     [0:31][0:127];

  //MAC
  // Input signals
  logic signed [7:0] Q_32x16x16x32 [0:31][0:15];
  logic signed [7:0] K_32x16x16x32 [0:15][0:31];
  logic signed [7:0] Q_32x32x32x16 [0:31][0:31];
  logic signed [7:0] K_32x32x32x16 [0:31][0:15];
  logic signed [7:0] Q_32x128x128x128 [0:31][0:127];
  logic signed [7:0] K_32x128x128x128 [0:127][0:127];
  
  // Output signals
  logic signed [20:0] QKT_32x16x16x32 [0:31][0:31];
  logic signed [20:0] QKT_32x32x32x16 [0:31][0:15];
  logic signed [22:0] QKT_32x128x128x128 [0:31][0:127];

  //QKV
  // Input signals
    logic signed [7:0] X_in [0:31][0:127];
    logic signed [7:0] WQ_in [0:127][0:127];
    logic signed [7:0] WK_in [0:127][0:127];
    logic signed [7:0] WV_in [0:127][0:127];
  // Output signals
    logic signed [7:0] result_Q [0:31][0:127];
    logic signed [7:0] result_K [0:31][0:127];
    logic signed [7:0] result_V [0:31][0:127];

  // UVM Standard Methods
  function new(string name = "mhsa_base_seq_item");
    super.new(name);
  endfunction

  virtual function void do_pack(uvm_packer packer);
    super.do_pack(packer);
  endfunction

  virtual function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
  endfunction

  virtual function void do_copy(uvm_object rhs);
    super.do_copy(rhs);
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   return super.do_compare(rhs, comparer);
  endfunction

  virtual function void print_arrays(string prefix = "ITEM");
  endfunction

  virtual function void calculate_expected();
  endfunction

`define PRINT_2D_ARRAY(SUFFIX, BIT_WIDTH, ROWS, COLS, SEP_INTERVAL, FMT_WIDTH) \
virtual function void print_2d_array_``SUFFIX ( \
    logic signed [BIT_WIDTH-1:0] array[0:ROWS-1][0:COLS-1], \
    string array_name, \
    string prefix = "ITEM" \
); \
    string info_str = $sformatf("%s (%0dx%0d):", array_name, ROWS, COLS); \
    `uvm_info(prefix, info_str, UVM_MEDIUM) \
    for (int i = 0; i < ROWS; i++) begin \
      string line = $sformatf("Row %2d: ", i); \
      for (int j = 0; j < COLS; j++) begin \
        if (j > 0 && j % SEP_INTERVAL == 0) line = {line, "| "}; \
        line = {line, $sformatf($sformatf("%%%0dd ", FMT_WIDTH), $signed(array[i][j]))}; \
      end \
      `uvm_info(prefix, line, UVM_MEDIUM) \
    end \
endfunction

`PRINT_2D_ARRAY(20x32x32,21,32,32,8,8)
`PRINT_2D_ARRAY(20x32x16,21,32,16,8,8)
`PRINT_2D_ARRAY(22x32x128,23,32,128,8,9)

`PRINT_2D_ARRAY(8x32x128,8,32,128,8,8)
`PRINT_2D_ARRAY(8x128x128,8,128,128,8,8)

endclass
