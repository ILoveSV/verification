// Project Name  : SoC_Project
// Author        : zy
// Last Modified : 2025/05/12
// File Name     : SDPA.sv        // 注意扩展名改为 .sv
// Description   : SDPA(scaled dot-product attention)模块
//----------------------------------------------------------------------------

module SDPA (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    input  wire               start,      // 新增外部使能信号
    input  wire signed [7:0] Q [0:31][0:15],
    input  wire signed [7:0] K [0:31][0:15],
    input  wire signed [7:0] V [0:31][0:15],
    output reg  signed [7:0] result_out [0:31][0:15]
);
    reg signed [20:0] QKT [0:31][0:31];
    wire finish1;
    wire finish2;
    // 内部延时计数，延迟256拍后拉高start_int
    reg [7:0] delay_cnt;
    reg start_int;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_cnt <= 0;
            start_int <= 0;
        end else if (start && !start_int) begin
            if (delay_cnt == 8'd255)
                start_int <= 1;
            else
                delay_cnt <= delay_cnt + 1;
        end
    end
    // 第二个start信号，延迟更长时间（如512拍）
    reg [9:0] delay_cnt2;
    reg start2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_cnt2 <= 0;
            start2 <= 0;
        end else if (start && !start2) begin
            if (delay_cnt2 == 10'd511)
                start2 <= 1;
            else
                delay_cnt2 <= delay_cnt2 + 1;
        end
    end
    // 转置K矩阵
    reg signed [7:0] K_T [0:15][0:31];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 16; i++) begin
                for (int j = 0; j < 32; j++) begin
                    K_T[i][j] <= 0;
                end
            end
        end
        else if (start && start_int) begin
            for (int i = 0; i < 16; i++) begin
                for (int j = 0; j < 32; j++) begin
                    K_T[i][j] <= K[j][i];
                end
            end
        end
    end
    mac32x16x16x32 mac_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && start_int),
        .Q(Q),
        .K(K_T),
        .QKT(QKT),
        .finish(finish1)
    );

    // 缩放QKT矩阵 (除以4)
    reg signed [18:0] scaled_QKT [0:31][0:31];
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                for (int j = 0; j < 32; j++) begin
                    scaled_QKT[i][j] <= 0;
                end
            end
        end
        else if (start && start_int) begin
            for (int i = 0; i < 32; i++) begin
                for (int j = 0; j < 32; j++) begin
                    scaled_QKT[i][j] <= QKT[i][j] >>> 2; // 算术右移2位相当于除以4
                end
            end
        end
    end

    reg signed [18:0] softmax_out [0:31][0:31];
    // 实例化softmax模块
    softmax softmax_inst (
        .in(scaled_QKT),
        .out(softmax_out)
    );

    reg signed [7:0] quant_out [0:31][0:31];
    // 实例化量化模块
    Convert_S19_to_S8 quantize_inst (
        .in(softmax_out),
        .out(quant_out)
    );
    
    reg signed [20:0] temp [0:31][0:15];
    mac32x32x32x16 mac_inst2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && start2),
        .Q(quant_out),
        .K(V),
        .QKT(temp),
        .finish(finish2)
    );

    Convert_S21_to_S8 quantize_inst2 (
        .in(temp),
        .out(result_out)
    );
    

endmodule







