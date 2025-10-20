//把多比特的有符号数变为8位有符号数
module Convert_S19_to_S8 (
    input  logic signed [18:0] in [0:31][0:31],
    output logic signed [7:0]  out  [0:31][0:31]
);

    // 定义8位有符号数的最大值和最小值
    localparam SIGNED_8_MAX = (2**(8-1)) - 1; //  127 ( 8'b01111111 )
    localparam SIGNED_8_MIN = -(2**(8-1));   // -128 ( 8'b10000000 )

    // 量化函数
    function automatic logic signed [7:0] quantize;
        input logic signed [18:0] in_val;
        begin
            if (in_val > SIGNED_8_MAX)
                quantize = SIGNED_8_MAX;
            else if (in_val < SIGNED_8_MIN)
                quantize = SIGNED_8_MIN;
            else
                quantize = in_val;
        end
    endfunction

    // 对矩阵中的每个元素进行转换
    genvar i, j;
    generate
        for (i = 0; i < 32; i = i + 1) begin : row_gen
            for (j = 0; j < 32; j = j + 1) begin : col_gen
                assign out[i][j] = quantize(in[i][j]);
            end
        end
    endgenerate

endmodule

module Convert_S21_to_S8 (
    input  logic signed [20:0] in [0:31][0:15],
    output logic signed [7:0]  out  [0:31][0:15]
);

    // 定义8位有符号数的最大值和最小值
    localparam SIGNED_8_MAX = (2**(8-1)) - 1; //  127 ( 8'b01111111 )
    localparam SIGNED_8_MIN = -(2**(8-1));   // -128 ( 8'b10000000 )

    // 量化函数
    function automatic logic signed [7:0] quantize;
        input logic signed [20:0] in_val;
        begin
            if (in_val > SIGNED_8_MAX)
                quantize = SIGNED_8_MAX;
            else if (in_val < SIGNED_8_MIN)
                quantize = SIGNED_8_MIN;
            else
                quantize = in_val;
        end
    endfunction

    // 对矩阵中的每个元素进行转换
    genvar i, j;
    generate
        for (i = 0; i < 32; i = i + 1) begin : row_gen
            for (j = 0; j < 16; j = j + 1) begin : col_gen
                assign out[i][j] = quantize(in[i][j]);
            end
        end
    endgenerate

endmodule

module Convert_S23_to_S8 (
    input  logic signed [22:0] in_s23 [0:31][0:127],
    output logic signed [7:0]  out_s8  [0:31][0:127]
);

    // 定义8位有符号数的最大值和最小值
    localparam SIGNED_8_MAX = (2**(8-1)) - 1; //  127 ( 8'b01111111 )
    localparam SIGNED_8_MIN = -(2**(8-1));   // -128 ( 8'b10000000 )
    
    // 量化函数
    function automatic logic signed [7:0] quantize;
        input logic signed [22:0] in_val;
        begin
            if (in_val > SIGNED_8_MAX)
                quantize = SIGNED_8_MAX;
            else if (in_val < SIGNED_8_MIN)
                quantize = SIGNED_8_MIN;
            else
                quantize = in_val;
        end
    endfunction

    // 对矩阵中的每个元素进行转换
    genvar i, j;
    generate
        for (i = 0; i < 32; i = i + 1) begin : row_gen
            for (j = 0; j < 128; j = j + 1) begin : col_gen
                assign out_s8[i][j] = quantize(in_s23[i][j]);
            end
        end
    endgenerate

endmodule   

