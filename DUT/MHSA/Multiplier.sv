// Module: signed_multiplier_8x8_16
// Description: 完成16个数的相乘，并输出16位有符号乘积，适用于32*16*16*32的Q*KT
//的矩阵运算

module multiplier_16x16 (
    input reg signed  [7:0] a_in [0:15],    // 8位有符号输入操作数A
    input reg signed  [7:0] b_in [0:15],    // 8位有符号输入操作数B 
    output wire signed [15:0] p_out [0:15]   // 16位有符号乘积 P = A * B
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : mult_gen
            assign p_out[i] = a_in[i] * b_in[i];
        end
    endgenerate

endmodule

//Module: signed_multiplier_8x8_32
//Description: 完成32个数的相乘，并输出16位有符号乘积，适用于32*32*32*16的softmax(QKT/{/sqrt(d_k)})*V
//的矩阵运算

module multiplier_32x32 (
    input reg signed  [7:0] a_in [0:31],    // 8位有符号输入操作数A
    input reg signed  [7:0] b_in [0:31],    // 8位有符号输入操作数B 
    output wire signed [15:0] p_out [0:31]   // 16位有符号乘积 P = A * B
);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : mult_gen
            assign p_out[i] = a_in[i] * b_in[i];
        end
    endgenerate
endmodule

//Module: signed_multiplier_8x8_128
//Description: 完成128个数的相乘，并输出16位有符号乘积，适用于32*128*128*128的X*WK,X*WV,X*WQ
//的矩阵运算

module multiplier_128x128 (
    input reg signed  [7:0] a_in [0:127],    // 8位有符号输入操作数A
    input reg signed  [7:0] b_in [0:127],    // 8位有符号输入操作数B 
    output wire signed [15:0] p_out [0:127]   // 16位有符号乘积 P = A * B
);

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : mult_gen
            assign p_out[i] = a_in[i] * b_in[i];
        end
    endgenerate
endmodule