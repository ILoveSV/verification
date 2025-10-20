module concat (
    input signed [7:0] in1 [0:31][0:15],
    input signed [7:0] in2 [0:31][0:15],
    input signed [7:0] in3 [0:31][0:15],
    input signed [7:0] in4 [0:31][0:15],
    input signed [7:0] in5 [0:31][0:15],
    input signed [7:0] in6 [0:31][0:15],
    input signed [7:0] in7 [0:31][0:15],
    input signed [7:0] in8 [0:31][0:15],
    output reg signed [7:0] out [0:31][0:127]
);
    always_comb begin
        for (int i = 0; i < 32; i++) begin
            for (int j = 0; j < 128; j++) begin
                if (j < 16) begin
                    out[i][j] = in1[i][j];
                end else if (j < 32) begin
                    out[i][j] = in2[i][j-16];
                end else if (j < 48) begin
                    out[i][j] = in3[i][j-32];
                end else if (j < 64) begin
                    out[i][j] = in4[i][j-48];
                end else if (j < 80) begin
                    out[i][j] = in5[i][j-64];
                end else if (j < 96) begin
                    out[i][j] = in6[i][j-80];
                end else if (j < 112) begin
                    out[i][j] = in7[i][j-96];
                end else if (j < 128) begin
                    out[i][j] = in8[i][j-112];
                end
            end
        end
    end


endmodule