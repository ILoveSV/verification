// Project Name  : SoC_Project
// Author        : zy
// Last Modified : 2025/05/12
// File Name     : QKV.sv        // 注意扩展名改为 .sv
// Description   : QKV矩阵计算模块（纯多维数组优化版）
//----------------------------------------------------------------------------

module QKV (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    // 输入矩阵直接声明为二维数组 [32][128]
    input  wire signed [7:0]  X_in   [0:31][0:127], 
    input  wire signed [7:0]  WQ_in  [0:127][0:127],
    input  wire signed [7:0]  WK_in  [0:127][0:127],
    input  wire signed [7:0]  WV_in  [0:127][0:127],
    // 输出直接映射为二维数组 [32][128]
    output reg  signed [7:0] result_Q [0:31][0:127],
    output reg  signed [7:0] result_K [0:31][0:127],
    output reg  signed [7:0] result_V [0:31][0:127],
    output reg                done
);
    reg signed [22:0] Q_temp[0:31][0:127];
    reg signed [22:0] K_temp[0:31][0:127];
    reg signed [22:0] V_temp[0:31][0:127];
    wire finish1;
    wire finish2;
    wire finish3;
    reg [9:0] input_cnt;
    reg start_mac;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_cnt <= 0;
            start_mac <= 0;
        end else if (!start_mac) begin
            if (input_cnt == 1023)
                start_mac <= 1;
            else
                input_cnt <= input_cnt + 1;
        end
    end
    mac32x128x128x128 mac_inst1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mac),
        .Q(X_in),
        .K(WQ_in),
        .QKT(Q_temp),
        .finish(finish1)
    );
    mac32x128x128x128 mac_inst2 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mac),
        .Q(X_in),
        .K(WK_in),
        .QKT(K_temp),
        .finish(finish2)
    );
    mac32x128x128x128 mac_inst3 (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_mac),
        .Q(X_in),
        .K(WV_in),
        .QKT(V_temp),
        .finish(finish3)
    );
    Convert_S23_to_S8 convert_inst (
        .in_s23(Q_temp),
        .out_s8(result_Q)
    );
    Convert_S23_to_S8 convert_inst2 (
        .in_s23(K_temp),
        .out_s8(result_K)
    );
    Convert_S23_to_S8 convert_inst3 (
        .in_s23(V_temp),
        .out_s8(result_V)
    );
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 0;
        end else if (done) begin
            // 保持done为1
        end else begin
            if (finish1 && finish2 && finish3) begin
                done <= 1;
            end
        end
    end
endmodule
