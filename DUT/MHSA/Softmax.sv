module softmax (
    input  wire signed [18:0] in [0:31][0:31],
    output reg  signed [18:0] out [0:31][0:31]
);

    integer i, j, max_idx;
    reg signed [18:0] max_val;

    always_comb begin
        for (i = 0; i < 32; i = i + 1) begin
            // 找到最大值及其下标
            max_val = in[i][0];
            max_idx = 0;
            for (j = 1; j < 32; j = j + 1) begin
                if (in[i][j] > max_val) begin
                    max_val = in[i][j];
                    max_idx = j;
                end
            end
            // one-hot输出
            for (j = 0; j < 32; j = j + 1) begin
                if (j == max_idx)
                    out[i][j] = 19'sd1;
                else
                    out[i][j] = 19'sd0;
            end
        end
    end

endmodule
