interface apb_interface(input PCLK);
    logic clk;
    logic rst_n;

// MHSA_TOP
    // input
    logic signed [7:0] input_data [0:31][0:127];
    logic signed [7:0] weight_q [0:127][0:127];
    logic signed [7:0] weight_k [0:127][0:127];
    logic signed [7:0] weight_v [0:127][0:127];
    logic signed [7:0] weight_in [0:127][0:127];
    // output
    logic signed [7:0] result [0:31][0:127];

// MACs 
    // input
    logic signed [7:0] Q_32x16x16x32 [0:31][0:15];
    logic signed [7:0] K_32x16x16x32 [0:15][0:31];
    logic signed [7:0] Q_32x32x32x16 [0:31][0:31];
    logic signed [7:0] K_32x32x32x16 [0:31][0:15];
    logic signed [7:0] Q_32x128x128x128 [0:31][0:127];
    logic signed [7:0] K_32x128x128x128 [0:127][0:127];

    // output
    logic signed [20:0] QKT_32x16x16x32 [0:31][0:31];
    logic signed [20:0] QKT_32x32x32x16 [0:31][0:15];  
    logic signed [22:0] QKT_32x128x128x128 [0:31][0:127];

// QKV
    // input
    logic signed [7:0] X_in [0:31][0:127];
    logic signed [7:0] WQ_in [0:127][0:127];
    logic signed [7:0] WK_in [0:127][0:127];
    logic signed [7:0] WV_in [0:127][0:127];


    // output
    logic signed [7:0] result_Q [0:31][0:127];
    logic signed [7:0] result_K [0:31][0:127];  
    logic signed [7:0] result_V [0:31][0:127];


clocking cb @(posedge PCLK);
    //default input #1ns; output #1ns;
    output clk;
    output rst_n;

// MHSA_TOP
    // input
    output input_data;
    output weight_q;
    output weight_k;
    output weight_v;
    output weight_in;

    // output
    input result;

 // MACs

 // input
        output Q_32x16x16x32;
        output K_32x16x16x32;
        output Q_32x32x32x16;
        output K_32x32x32x16;
        output Q_32x128x128x128;
        output K_32x128x128x128;

    // output 
        input QKT_32x16x16x32;
        input QKT_32x32x32x16;
        input QKT_32x128x128x128;
// QKV 
    // input
        output X_in;
        output WQ_in;
        output WK_in;
        output WV_in;

    // output 
        input result_Q;
        input result_K;
        input result_V;

  endclocking:cb

  task reset_intf();
    rst_n = 0;
      @(posedge PCLK);
    rst_n = 1;
      @(posedge PCLK);
  endtask

endinterface

