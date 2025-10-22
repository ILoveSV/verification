module top_tb;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import mhsa_env_pkg::*;

  // 时钟与复位声明
  reg clk;
  reg rst_n;
  // 接口实例化与DUT连接
  apb_interface u_mhsa_if(clk);
  
  // MHSA_TOP
  mhsa_top u_mhsa (
    .clk    (clk),
    .rst_n  (rst_n),
    .X_in   (u_mhsa_if.input_data),
    .WQ_in  (u_mhsa_if.weight_q),
    .WK_in  (u_mhsa_if.weight_k),
    .WV_in  (u_mhsa_if.weight_v),
    .W_in   (u_mhsa_if.weight_in),
    .out_s8 (u_mhsa_if.result)
  );
/*
  // MAC32x16x16x32 
  mac32x16x16x32 u_mac32x16x16x32(
    .clk  (clk),
    .rst_n(rst_n),
    .Q    (u_mhsa_if.Q_32x16x16x32),
    .K    (u_mhsa_if.K_32x16x16x32),
    .QKT  (u_mhsa_if.QKT_32x16x16x32)
  );

  // MAC32x32x32x16 
  mac32x32x32x16 u_mac32x32x32x16(
    .clk  (clk),
    .rst_n(rst_n),
    .Q    (u_mhsa_if.Q_32x32x32x16),
    .K    (u_mhsa_if.K_32x32x32x16),
    .QKT  (u_mhsa_if.QKT_32x32x32x16)
  );

  // MAC32x128x128x128 
  mac32x128x128x128 u_mac32x128x128x128(
    .clk  (clk),
    .rst_n(rst_n),
    .Q    (u_mhsa_if.Q_32x128x128x128),
    .K    (u_mhsa_if.K_32x128x128x128),
    .QKT  (u_mhsa_if.QKT_32x128x128x128)
  );

  // QKV
  QKV u_QKV(
    .clk  (clk),
    .rst_n(rst_n),
    .X_in (u_mhsa_if.X_in),
    .WQ_in(u_mhsa_if.WQ_in),
    .WK_in(u_mhsa_if.WK_in),
    .WV_in(u_mhsa_if.WV_in),
    .result_Q(u_mhsa_if.result_Q),
    .result_K(u_mhsa_if.result_K),
    .result_V(u_mhsa_if.result_V)
  );
*/

  // 时钟生成（100MHz）
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 5ns半周期
  end

  // 复位控制
  initial begin
    rst_n = 0;             // 初始复位
    #100 rst_n = 1;        // 100ns后释放
  end

  // UVM测试启动
  initial begin
    uvm_config_db#(virtual apb_interface)::set(null, "*", "APB_INTF", u_mhsa_if);
    run_test();
  end
  
  // 波形记录控制
  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, top_tb);  // 记录所有层级信号
    $fsdbDumpMDA();            // 记录多维数组
  end
endmodule : top_tb
