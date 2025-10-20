// Project Name  : SoC_Project
// Author        : zy
// Last Modified : 2025/05/12 (Refactored for sequential matrix multiplication)
// File Name     : mhsa_top.v
// Description   : Multi-Head Self-Attention (MHSA) accelerator 
//----------------------------------------------------------------------------

module mhsa_top (
    input               clk,
    input               rst_n,
    
    input  wire signed [7:0]  X_in   [0:31][0:127], 
    input  wire signed [7:0]  WQ_in  [0:127][0:127],
    input  wire signed [7:0]  WK_in  [0:127][0:127],
    input  wire signed [7:0]  WV_in  [0:127][0:127],

    input  wire signed [7:0]  W_in   [0:127][0:127],//最终线性变换的权重矩阵

    output signed      [7:0]  out_s8    [0:31][0:127]
);

    wire signed [7:0] Q [0:31][0:127];
    wire signed [7:0] K [0:31][0:127];
    wire signed [7:0] V [0:31][0:127];
    
    wire signed [7:0] out1 [0:31][0:15];
    wire signed [7:0] out2 [0:31][0:15];
    wire signed [7:0] out3 [0:31][0:15];
    wire signed [7:0] out4 [0:31][0:15];
    wire signed [7:0] out5 [0:31][0:15];
    wire signed [7:0] out6 [0:31][0:15];
    wire signed [7:0] out7 [0:31][0:15];
    wire signed [7:0] out8 [0:31][0:15];
    wire signed [7:0] out [0:31][0:127];

    // 创建中间数组来存储切片
    reg signed [7:0] Q1 [0:31][0:15];
    reg signed [7:0] K1 [0:31][0:15];
    reg signed [7:0] V1 [0:31][0:15];
    reg signed [7:0] Q2 [0:31][0:15];
    reg signed [7:0] K2 [0:31][0:15];
    reg signed [7:0] V2 [0:31][0:15];
    reg signed [7:0] Q3 [0:31][0:15];
    reg signed [7:0] K3 [0:31][0:15];
    reg signed [7:0] V3 [0:31][0:15];
    reg signed [7:0] Q4 [0:31][0:15];
    reg signed [7:0] K4 [0:31][0:15];
    reg signed [7:0] V4 [0:31][0:15];
    reg signed [7:0] Q5 [0:31][0:15];
    reg signed [7:0] K5 [0:31][0:15];
    reg signed [7:0] V5 [0:31][0:15];
    reg signed [7:0] Q6 [0:31][0:15];
    reg signed [7:0] K6 [0:31][0:15];
    reg signed [7:0] V6 [0:31][0:15];
    reg signed [7:0] Q7 [0:31][0:15];
    reg signed [7:0] K7 [0:31][0:15];
    reg signed [7:0] V7 [0:31][0:15];
    reg signed [7:0] Q8 [0:31][0:15];
    reg signed [7:0] K8 [0:31][0:15];
    reg signed [7:0] V8 [0:31][0:15];

    // 分配数组切片
    always_comb begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 16; j++) begin
                Q1[i][j] = Q[i][j];
                K1[i][j] = K[i][j];
                V1[i][j] = V[i][j];
                Q2[i][j] = Q[i][j+16];
                K2[i][j] = K[i][j+16];
                V2[i][j] = V[i][j+16];
                Q3[i][j] = Q[i][j+32];
                K3[i][j] = K[i][j+32];
                V3[i][j] = V[i][j+32];
                Q4[i][j] = Q[i][j+48];
                K4[i][j] = K[i][j+48];
                V4[i][j] = V[i][j+48];
                Q5[i][j] = Q[i][j+64];
                K5[i][j] = K[i][j+64];
                V5[i][j] = V[i][j+64];
                Q6[i][j] = Q[i][j+80];
                K6[i][j] = K[i][j+80];
                V6[i][j] = V[i][j+80];
                Q7[i][j] = Q[i][j+96];
                K7[i][j] = K[i][j+96];
                V7[i][j] = V[i][j+96];
                Q8[i][j] = Q[i][j+112];
                K8[i][j] = K[i][j+112];
                V8[i][j] = V[i][j+112];
            end
        end
    end

    wire qkv_done;
    reg  sdpa_start;
    QKV qkv_inst (
        .clk(clk),
        .rst_n(rst_n),
        .X_in(X_in),
        .WQ_in(WQ_in),
        .WK_in(WK_in),
        .WV_in(WV_in),
        .result_Q(Q),
        .result_K(K),
        .result_V(V),
        .done(qkv_done)
    );
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sdpa_start <= 0;
        else if (qkv_done)
            sdpa_start <= 1;
    end
    SDPA sdpa_inst1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q1),
        .K(K1),
        .V(V1),
        .result_out(out1)
    );
    SDPA sdpa_inst2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q2),
        .K(K2),
        .V(V2),
        .result_out(out2)
    );
    SDPA sdpa_inst3 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q3),
        .K(K3),
        .V(V3),
        .result_out(out3)
    );
    SDPA sdpa_inst4 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q4),
        .K(K4),
        .V(V4),
        .result_out(out4)
    );
    SDPA sdpa_inst5 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q5),
        .K(K5),
        .V(V5),
        .result_out(out5)
    );
    SDPA sdpa_inst6 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q6),
        .K(K6),
        .V(V6),
        .result_out(out6)
    );
    SDPA sdpa_inst7 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q7),
        .K(K7),
        .V(V7),
        .result_out(out7)
    );
    SDPA sdpa_inst8 (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .Q(Q8),
        .K(K8),
        .V(V8),
        .result_out(out8)
    );

    concat concat_inst (
        .in1(out1),
        .in2(out2),
        .in3(out3),
        .in4(out4),
        .in5(out5),
        .in6(out6),
        .in7(out7),
        .in8(out8),
        .out(out)
    );

    FinalLinear final_linear_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(sdpa_start),
        .X_in(out),
        .W_in(W_in),
        .out_s8(out_s8)
    );

endmodule

