import "DPI-C" function void calculate_QKV(
    input  logic signed [7:0] X_in[32][128], 
    input  logic signed [7:0] WQ_in[128][128],
    input  logic signed [7:0] WK_in[128][128],
    input  logic signed [7:0] WV_in[128][128],
    output logic signed [7:0] result_Q[32][128],
    output logic signed [7:0] result_K[32][128],
    output logic signed [7:0] result_V[32][128]
);
class qkv_seq_item extends mhsa_base_seq_item;
  `uvm_object_utils(qkv_seq_item)

  function new(string name = "qkv_seq_item");
    super.new(name);
    // Initialize QKV arrays
    module_type = QKV;
    foreach(X_in[i,j])      X_in[i][j] = 0;
    foreach(WQ_in[i,j])     WQ_in[i][j] = 0;
    foreach(WK_in[i,j])     WK_in[i][j] = 0;
    foreach(WV_in[i,j])     WV_in[i][j] = 0;
    foreach(result_Q[i,j])  result_Q[i][j] = 0;
    foreach(result_K[i,j])  result_K[i][j] = 0;
    foreach(result_V[i,j])  result_V[i][j] = 0;
  endfunction

  virtual function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    // Pack inputs
    foreach(X_in[i,j])  packer.pack_field_int(X_in[i][j], 8);
    foreach(WQ_in[i,j]) packer.pack_field_int(WQ_in[i][j], 8);
    foreach(WK_in[i,j]) packer.pack_field_int(WK_in[i][j], 8);
    foreach(WV_in[i,j]) packer.pack_field_int(WV_in[i][j], 8);
    // Pack outputs
    foreach(result_Q[i,j]) packer.pack_field_int(result_Q[i][j], 8);
    foreach(result_K[i,j]) packer.pack_field_int(result_K[i][j], 8);
    foreach(result_V[i,j]) packer.pack_field_int(result_V[i][j], 8);
  endfunction

  virtual function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
    // Unpack inputs
    foreach(X_in[i,j])  X_in[i][j] = signed'(packer.unpack_field(8));
    foreach(WQ_in[i,j]) WQ_in[i][j] = signed'(packer.unpack_field(8));
    foreach(WK_in[i,j]) WK_in[i][j] = signed'(packer.unpack_field(8));
    foreach(WV_in[i,j]) WV_in[i][j] = signed'(packer.unpack_field(8));
    // Unpack outputs
    foreach(result_Q[i,j]) result_Q[i][j] = signed'(packer.unpack_field(8));
    foreach(result_K[i,j]) result_K[i][j] = signed'(packer.unpack_field(8));
    foreach(result_V[i,j]) result_V[i][j] = signed'(packer.unpack_field(8));
  endfunction

  virtual function void do_copy(uvm_object rhs);
    qkv_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("DO_COPY", "Cast failed")
      return;
    end
    super.do_copy(rhs);
    // Copy QKV data
    X_in      = rhs_.X_in;
    WQ_in     = rhs_.WQ_in;
    WK_in     = rhs_.WK_in;
    WV_in     = rhs_.WV_in;
    result_Q  = rhs_.result_Q;
    result_K  = rhs_.result_K;
    result_V  = rhs_.result_V;
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    qkv_seq_item rhs_;
    bit status = super.do_compare(rhs, comparer);
    
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("COMPARE", "Type mismatch in compare()")
      return 0;
    end

    // Compare output arrays
    foreach(result_Q[i,j]) begin
      if (result_Q[i][j] != rhs_.result_Q[i][j]) begin
        `uvm_info("COMPARE", $sformatf("result_Q[%0d][%0d] mismatch: 0x%0h vs 0x%0h", 
                  i, j, result_Q[i][j], rhs_.result_Q[i][j]), UVM_LOW)
        status = 0;
      end
    end

    foreach(result_K[i,j]) begin
      if (result_K[i][j] != rhs_.result_K[i][j]) begin
        `uvm_info("COMPARE", $sformatf("result_K[%0d][%0d] mismatch: 0x%0h vs 0x%0h", 
                  i, j, result_K[i][j], rhs_.result_K[i][j]), UVM_LOW)
        status = 0;
      end
    end

    foreach(result_V[i,j]) begin
      if (result_V[i][j] != rhs_.result_V[i][j]) begin
        `uvm_info("COMPARE", $sformatf("result_V[%0d][%0d] mismatch: 0x%0h vs 0x%0h", 
                  i, j, result_V[i][j], rhs_.result_V[i][j]), UVM_LOW)
        status = 0;
      end
    end

    return status;
  endfunction

  virtual function void print_arrays(string prefix = "ITEM");
    `uvm_info(prefix, "QKV Arrays Contents:", UVM_MEDIUM)
 //   print_2d_array_8x32x128(X_in,      "X_in",      prefix);
 //   print_2d_array_8x128x128(WQ_in,     "WQ_in",     prefix);
 //   print_2d_array_8x128x128(WK_in,     "WK_in",     prefix);
 //   print_2d_array_8x128x128(WV_in,     "WV_in",     prefix);
    print_2d_array_8x32x128(result_Q,  "result_Q",  prefix);
    print_2d_array_8x32x128(result_K,  "result_K",  prefix);
    print_2d_array_8x32x128(result_V,  "result_V",  prefix);
  endfunction

  protected function void print_qkv_array(logic signed [7:0] array[][], string name, string prefix);
    `uvm_info(prefix, $sformatf("Array: %s", name), UVM_MEDIUM)
    foreach(array[i,j]) begin
      `uvm_info(prefix, $sformatf("[%0d][%0d] = 0x%0h", i, j, array[i][j]), UVM_MEDIUM)
    end
  endfunction

  function void calculate_expected();

  endfunction
  
endclass : qkv_seq_item
