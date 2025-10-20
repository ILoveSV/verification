class mhsa_seq_item extends apb_seq_item;
  `uvm_object_utils(mhsa_seq_item)

  // Constructor
  function new(string name = "mhsa_seq_item");
    super.new(name);
    `uvm_info("item", $psprintf("sequence item initialized"), UVM_NONE)
    foreach(input_data[i,j]) input_data[i][j] = 0;
    foreach(weight_q[i,j])   weight_q[i][j]   = 0;
    foreach(weight_k[i,j])   weight_k[i][j]   = 0;
    foreach(weight_v[i,j])   weight_v[i][j]   = 0;
    foreach(weight_in[i,j])  weight_in[i][j]  = 0;
    foreach(result[i,j])     result[i][j]     = 0;
  endfunction

  // UVM Standard Methods
  virtual function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    foreach(input_data[i,j]) packer.pack_field_int(input_data[i][j], 8);
    foreach(weight_q[i,j])   packer.pack_field_int(weight_q[i][j], 8);
    foreach(weight_k[i,j])   packer.pack_field_int(weight_k[i][j], 8);
    foreach(weight_v[i,j])   packer.pack_field_int(weight_v[i][j], 8);
    foreach(weight_in[i,j])  packer.pack_field_int(weight_in[i][j], 8);
    foreach(result[i,j])     packer.pack_field_int(result[i][j], 8);
  endfunction

  virtual function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
    foreach(input_data[i,j]) input_data[i][j] = signed'(packer.unpack_field(8));
    foreach(weight_q[i,j])   weight_q[i][j]   = signed'(packer.unpack_field(8));
    foreach(weight_k[i,j])   weight_k[i][j]   = signed'(packer.unpack_field(8));
    foreach(weight_v[i,j])   weight_v[i][j]   = signed'(packer.unpack_field(8));
    foreach(weight_in[i,j])  weight_in[i][j]  = signed'(packer.unpack_field(8));
    foreach(result[i,j])     result[i][j]     = signed'(packer.unpack_field(8));
  endfunction

  virtual function void do_copy(uvm_object rhs);
    mhsa_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("DO_COPY", "Cast failed");
      return;
    end
    super.do_copy(rhs);
    input_data = rhs_.input_data;
    weight_q   = rhs_.weight_q;
    weight_k   = rhs_.weight_k;
    weight_v   = rhs_.weight_v;
    weight_in  = rhs_.weight_in;
    result     = rhs_.result;
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    mhsa_seq_item rhs_;
    if (!$cast(rhs_, rhs)) return 0;
    return super.do_compare(rhs, comparer) && (result == rhs_.result);
  endfunction

virtual function void print_arrays(string prefix = "ITEM");
    `uvm_info(prefix, "Printing arrays contents:", UVM_MEDIUM)
/*    
    // 打印MHSA输入数据
    print_2d_array_8bit(input_data,  "input_data", prefix);
    print_2d_array_8bit(weight_q,  "weight_q", prefix);
    print_2d_array_8bit(weight_k,  "weight_k", prefix);
    print_2d_array_8bit(weight_v,  "weight_v", prefix);
    print_2d_array_8bit(weight_in, "weight_in", prefix);
*/ 
    // 打印MHSA输出结果
    print_2d_array_8x32x128(result, "result", prefix);

  endfunction

endclass : mhsa_seq_item
