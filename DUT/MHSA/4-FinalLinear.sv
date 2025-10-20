module FinalLinear (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    input  wire signed [7:0]  X_in [0:31][0:127],
    input  wire signed [7:0]  W_in [0:127][0:127],
    input  wire               start,      // 新增外部使能信号
    output wire signed [7:0]  out_s8 [0:31][0:127]
);
    reg signed [22:0] out_reg [0:31][0:127];

    reg [20:0] delay_cnt;
    reg start_int;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delay_cnt <= 0;
            start_int <= 0;
        end else if (start && !start_int) begin
            if (delay_cnt == 20'd1300)
                start_int <= 1;
            else
                delay_cnt <= delay_cnt + 1;
        end
    end
    mac32x128x128x128 mac_inst_final (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_int),
        .Q(X_in),
        .K(W_in),
        .QKT(out_reg)
    );
    Convert_S23_to_S8 convert_inst (
        .in_s23(out_reg),
        .out_s8(out_s8)
    );

endmodule
    
