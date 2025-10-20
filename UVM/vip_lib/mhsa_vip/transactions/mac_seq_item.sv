class mac_seq_item extends apb_seq_item;
  `uvm_object_utils(mac_seq_item)

  // Constructor
  function new(string name = "mac_seq_item");
    super.new(name);
    `uvm_info("item", $psprintf("sequence item initialized"), UVM_NONE)
    foreach(Q_32x16x16x32[i,j])    Q_32x16x16x32[i][j] = 0;
    foreach(K_32x16x16x32[i,j])    K_32x16x16x32[i][j] = 0;
    foreach(Q_32x32x32x16[i,j])    Q_32x32x32x16[i][j] = 0;
    foreach(K_32x32x32x16[i,j])    K_32x32x32x16[i][j] = 0;
    foreach(Q_32x128x128x128[i,j]) Q_32x128x128x128[i][j] = 0;
    foreach(K_32x128x128x128[i,j]) K_32x128x128x128[i][j] = 0;
    
    foreach(QKT_32x16x16x32[i,j])    QKT_32x16x16x32[i][j] = 0;
    foreach(QKT_32x32x32x16[i,j])    QKT_32x32x32x16[i][j] = 0;
    foreach(QKT_32x128x128x128[i,j]) QKT_32x128x128x128[i][j] = 0;

  endfunction

  // UVM Standard Methods
  virtual function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    foreach(Q_32x16x16x32[i,j])    packer.pack_field_int(Q_32x16x16x32[i][j], 8);
    foreach(K_32x16x16x32[i,j])    packer.pack_field_int(K_32x16x16x32[i][j], 8);
    foreach(Q_32x32x32x16[i,j])    packer.pack_field_int(Q_32x32x32x16[i][j], 8);
    foreach(K_32x32x32x16[i,j])    packer.pack_field_int(K_32x32x32x16[i][j], 8);
    foreach(Q_32x128x128x128[i,j]) packer.pack_field_int(Q_32x128x128x128[i][j], 8);
    foreach(K_32x128x128x128[i,j]) packer.pack_field_int(K_32x128x128x128[i][j], 8);
    
    foreach(QKT_32x16x16x32[i,j])    packer.pack_field_int(QKT_32x16x16x32[i][j], 21);
    foreach(QKT_32x32x32x16[i,j])    packer.pack_field_int(QKT_32x32x32x16[i][j], 21);
    foreach(QKT_32x128x128x128[i,j]) packer.pack_field_int(QKT_32x128x128x128[i][j], 23);
  endfunction

  virtual function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
    foreach(Q_32x16x16x32[i,j])    Q_32x16x16x32[i][j] = signed'(packer.unpack_field(8));
    foreach(K_32x16x16x32[i,j])    K_32x16x16x32[i][j] = signed'(packer.unpack_field(8));
    foreach(Q_32x32x32x16[i,j])    Q_32x32x32x16[i][j] = signed'(packer.unpack_field(8));
    foreach(K_32x32x32x16[i,j])    K_32x32x32x16[i][j] = signed'(packer.unpack_field(8));
    foreach(Q_32x128x128x128[i,j]) Q_32x128x128x128[i][j] = signed'(packer.unpack_field(8));
    foreach(K_32x128x128x128[i,j]) K_32x128x128x128[i][j] = signed'(packer.unpack_field(8));
    
    foreach(QKT_32x16x16x32[i,j])    QKT_32x16x16x32[i][j] = signed'({packer.unpack_field(21)});
    foreach(QKT_32x32x32x16[i,j])    QKT_32x32x32x16[i][j] = signed'({packer.unpack_field(21)});
    foreach(QKT_32x128x128x128[i,j]) QKT_32x128x128x128[i][j] = signed'({packer.unpack_field(23)});
  endfunction

  virtual function void do_copy(uvm_object rhs);
    mac_seq_item rhs_;
    if (!$cast(rhs_, rhs)) begin
      `uvm_error("DO_COPY", "Cast failed")
      return;
    end
    super.do_copy(rhs);
    Q_32x16x16x32    = rhs_.Q_32x16x16x32;
    K_32x16x16x32    = rhs_.K_32x16x16x32;
    Q_32x32x32x16    = rhs_.Q_32x32x32x16;
    K_32x32x32x16    = rhs_.K_32x32x32x16;
    Q_32x128x128x128 = rhs_.Q_32x128x128x128;
    K_32x128x128x128 = rhs_.K_32x128x128x128;
    
    QKT_32x16x16x32    = rhs_.QKT_32x16x16x32;
    QKT_32x32x32x16    = rhs_.QKT_32x32x32x16;
    QKT_32x128x128x128 = rhs_.QKT_32x128x128x128;
  endfunction

virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  mac_seq_item rhs_;
  bit status = super.do_compare(rhs, comparer);  // 添加父类比较
  
  if (!$cast(rhs_, rhs)) begin
    `uvm_error("COMPARE", "Type mismatch in compare()")
    return 0;
  end

  // 比较第一个数组 QKT_32x16x16x32
  foreach(this.QKT_32x16x16x32[i,j]) begin
    if (this.QKT_32x16x16x32[i][j] != rhs_.QKT_32x16x16x32[i][j]) begin
      `uvm_info("COMPARE", $sformatf("QKT_32x16x16x32[%0d][%0d] mismatch: lhs=0x%0h vs rhs=0x%0h", 
                i, j, this.QKT_32x16x16x32[i][j], rhs_.QKT_32x16x16x32[i][j]), UVM_LOW)
      status = 0;
    end
  end

  // 比较第二个数组 QKT_32x32x32x16
  foreach(this.QKT_32x32x32x16[i,j]) begin
    if (this.QKT_32x32x32x16[i][j] != rhs_.QKT_32x32x32x16[i][j]) begin
      `uvm_info("COMPARE", $sformatf("QKT_32x32x32x16[%0d][%0d] mismatch: lhs=0x%0h vs rhs=0x%0h", 
                i, j, this.QKT_32x32x32x16[i][j], rhs_.QKT_32x32x32x16[i][j]), UVM_LOW)
      status = 0;
    end
  end

  // 比较第三个数组 QKT_32x128x128x128
  foreach(this.QKT_32x128x128x128[i,j]) begin
    if (this.QKT_32x128x128x128[i][j] != rhs_.QKT_32x128x128x128[i][j]) begin
      `uvm_info("COMPARE", $sformatf("QKT_32x128x128x128[%0d][%0d] mismatch: lhs=0x%0h vs rhs=0x%0h", 
                i, j, this.QKT_32x128x128x128[i][j], rhs_.QKT_32x128x128x128[i][j]), UVM_LOW)
      status = 0;
    end
  end

  return status;
endfunction

virtual function void print_arrays(string prefix = "ITEM");
    `uvm_info(prefix, "Printing arrays contents:", UVM_MEDIUM)
    // 打印MAC输出
    // print_2d_array_20b_32x32
    print_2d_array_20x32x32(QKT_32x16x16x32,  "QKT_32x16x16x32", prefix);
    print_2d_array_20x32x16(QKT_32x32x32x16, "QKT_32x32x32x16", prefix);
    print_2d_array_22x32x128(QKT_32x128x128x128, "QKT_32x128x128x128", prefix);
  endfunction



endclass : mac_seq_item
