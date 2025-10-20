//矩阵乘法
module mac32x16x16x32 (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    input  wire               start,      // 新增启动信号
    input  wire signed [7:0] Q [0:31][0:15],
    input  wire signed [7:0] K [0:15][0:31],
    output reg  signed [20:0] QKT [0:31][0:31],
    output wire finish
);
    // 输入寄存器
    reg signed [7:0] Q_in [0:15];    
    reg signed [7:0] K_in [0:15];    
    
    // 乘法器输出和中间寄存器
    wire signed [15:0] QK_mult [0:15];  // 组合逻辑乘法器输出
    reg signed [15:0] QK_out [0:15];    // 时序逻辑寄存器
    
    // 控制信号
    integer row, col;
    reg finish_reg;
    assign finish = finish_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 16; i++) begin
                Q_in[i] <= 0;
                K_in[i] <= 0;
                row <= 0;
                col <= 0;
            end
            finish_reg <= 0;
        end
        else if (start && !finish_reg) begin
            if (row < 32) begin
                for (int i = 0; i < 16; i++) begin
                    Q_in[i] <= Q[row][i];
                    K_in[i] <= K[i][col];
                end
                col <= col + 1;
                if (col == 31) begin
                    col <= 0;
                    row <= row + 1;
                end
            end
            else begin
                row <= 0;
                col <= 0;
            end
        end
    end
    
    // 组合逻辑乘法器
    multiplier_16x16 mul1 (
        .a_in(Q_in),
        .b_in(K_in),
        .p_out(QK_mult)
    );

    // 乘法结果寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 16; i++) begin
                QK_out[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 16; i++) begin
                QK_out[i] <= QK_mult[i];
            end
        end
    end

    // MAC流水线寄存器
    reg signed [17:0] stage1_sum [0:3];  // 第一级4组4数相加
    reg signed [18:0] stage2_sum [0:1];   // 第二级：2组2数相加
    reg signed [19:0] mac;                // 最终结果

    // 第一级流水线：4组4数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 4; i++) begin
                stage1_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 4; i++) begin
                stage1_sum[i] <= QK_out[i*4] + QK_out[i*4+1] + QK_out[i*4+2] + QK_out[i*4+3];
            end
        end
    end

    // 第二级流水线：2组2数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 2; i++) begin
                stage2_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 2; i++) begin
                stage2_sum[i] <= stage1_sum[i*2] + stage1_sum[i*2+1];
            end
        end
    end

    // 第三级流水线：
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac <= 0;
        end
        else if (start && !finish_reg) begin
            mac <= stage2_sum[0] + stage2_sum[1];
        end
    end
    integer QKT_r, QKT_c;
    reg [2:0] delay_cnt;
    // 第四级流水线：把mac赋值到QK_out
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                for (int j = 0; j < 32; j++) begin
                    QKT[i][j] <= 0;
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                end
            end
        end
        else if (start && !finish_reg) begin
            if (delay_cnt < 5) begin
                delay_cnt <= delay_cnt + 1;
            end
            else begin
                if (QKT_r < 32) begin
                    QKT[QKT_r][QKT_c] <= mac;
                    QKT_c <= QKT_c + 1;
                    if (QKT_c == 31) begin
                        QKT_r <= QKT_r + 1;
                        QKT_c <= 0;
                    end
                end
                else begin
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                    finish_reg <= 1;
                end
            end
        end
    end

endmodule


module mac32x32x32x16 (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    input  wire               start,      // 新增启动信号
    input  wire signed [7:0] Q [0:31][0:31],
    input  wire signed [7:0] K [0:31][0:15],
    output reg  signed [20:0] QKT [0:31][0:15],
    output wire finish
);
    // 输入寄存器
    reg signed [7:0] Q_in [0:31];    
    reg signed [7:0] K_in [0:31];    
    
    // 乘法器输出和中间寄存器
    wire signed [15:0] QK_mult [0:31];  // 组合逻辑乘法器输出
    reg signed [15:0] QK_out [0:31];    // 时序逻辑寄存器
    
    // 控制信号
    integer row, col;
    reg finish_reg;
    assign finish = finish_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                Q_in[i] <= 0;
                K_in[i] <= 0;
                row <= 0;
                col <= 0;
            end
            finish_reg <= 0;
        end
        else if (start && !finish_reg) begin
            if (row < 32) begin
                Q_in <= Q[row];
                for (int i = 0; i < 32; i++) begin
                    K_in[i] <= K[i][col];
                end
                col <= col + 1;
                if (col == 15) begin
                    col <= 0;
                    row <= row + 1;
                end
            end
            else begin
                row <= 0;
                col <= 0;
            end
        end
    end
    
    // 组合逻辑乘法器
    multiplier_32x32 mul1 (
        .a_in(Q_in),
        .b_in(K_in),
        .p_out(QK_mult)
    );

    // 乘法结果寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                QK_out[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 32; i++) begin
                QK_out[i] <= QK_mult[i];
            end
        end
    end

    // MAC流水线寄存器
    reg signed [17:0] stage1_sum [0:7];  // 第一级：8组4数相加
    reg signed [18:0] stage2_sum [0:3];  // 第二级：4组2数相加
    reg signed [19:0] stage3_sum [0:1];  // 第三级：2组2数相加
    reg signed [20:0] mac;               // 最终结果

    // 第一级流水线：8组4数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 8; i++) begin
                stage1_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 8; i++) begin
                stage1_sum[i] <= QK_out[i*4] + QK_out[i*4+1] + QK_out[i*4+2] + QK_out[i*4+3];
            end
        end
    end

    // 第二级流水线：4组2数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 4; i++) begin
                stage2_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 4; i++) begin
                stage2_sum[i] <= stage1_sum[i*2] + stage1_sum[i*2+1];
            end
        end
    end

    // 第三级流水线：2组2数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 2; i++) begin
                stage3_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 2; i++) begin
                stage3_sum[i] <= stage2_sum[i*2] + stage2_sum[i*2+1];
            end
        end
    end

    // 第四级流水线：2数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac <= 0;
        end
        else if (start && !finish_reg) begin
            mac <= stage3_sum[0] + stage3_sum[1];
        end
    end

    integer QKT_r, QKT_c;
    reg [2:0] delay_cnt;
    // 把mac赋值到QK_out
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                for (int j = 0; j < 16; j++) begin
                    QKT[i][j] <= 0;
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                end
            end
        end
        else if (start && !finish_reg) begin
            if (delay_cnt < 6) begin
                delay_cnt <= delay_cnt + 1;
            end
            else begin
                if (QKT_r < 32) begin
                    QKT[QKT_r][QKT_c] <= mac;
                    QKT_c <= QKT_c + 1;
                    if (QKT_c == 15) begin
                        QKT_r <= QKT_r + 1;
                        QKT_c <= 0;
                    end
                end
                else begin
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                    finish_reg <= 1;
                end
            end
        end
    end

endmodule


module mac32x128x128x128 (
    input  wire               clk,        // 时钟
    input  wire               rst_n,      // 异步低电平复位
    input  wire               start,      // 新增启动信号
    input  wire signed [7:0] Q [0:31][0:127],
    input  wire signed [7:0] K [0:127][0:127],
    output reg  signed [22:0] QKT [0:31][0:127],
    output wire finish
);
    // 输入寄存器
    reg signed [7:0] Q_in [0:127];    
    reg signed [7:0] K_in [0:127];    
    
    // 乘法器输出和中间寄存器
    wire signed [15:0] QK_mult [0:127];  // 组合逻辑乘法器输出
    reg signed [15:0] QK_out [0:127];    // 时序逻辑寄存器
    
    // 控制信号
    integer row, col;
    reg finish_reg;
    assign finish = finish_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 128; i++) begin
                Q_in[i] <= 0;
                K_in[i] <= 0;
                row <= 0;
                col <= 0;
            end
            finish_reg <= 0;
        end
        else if (start && !finish_reg) begin
            if (row < 32) begin
                Q_in <= Q[row];
                for (int i = 0; i < 128; i++) begin
                    K_in[i] <= K[i][col];
                end
                col <= col + 1;
                if (col == 127) begin
                    col <= 0;
                    row <= row + 1;
                end
            end
            else begin
                row <= 0;
                col <= 0;
            end
        end
    end
    
    // 组合逻辑乘法器
    multiplier_128x128 mul1 (
        .a_in(Q_in),
        .b_in(K_in),
        .p_out(QK_mult)
    );

    // 乘法结果寄存
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 128; i++) begin
                QK_out[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 128; i++) begin
                QK_out[i] <= QK_mult[i];
            end
        end
    end

    // MAC流水线寄存器
    reg signed [17:0] stage1_sum [0:31];  // 第一级：32组4数相加
    reg signed [19:0] stage2_sum [0:7];   // 第二级：8组4数相加
    reg signed [21:0] stage3_sum [0:1];   // 第三级：2组4数相加
    reg signed [22:0] mac;                // 最终结果

    // 第一级流水线：32组4数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                stage1_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 32; i++) begin
                stage1_sum[i] <= QK_out[i*4] + QK_out[i*4+1] + QK_out[i*4+2] + QK_out[i*4+3];
            end
        end
    end

    // 第二级流水线：8组4数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 8; i++) begin
                stage2_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 8; i++) begin
                stage2_sum[i] <= stage1_sum[i*4] + stage1_sum[i*4+1] + stage1_sum[i*4+2] + stage1_sum[i*4+3];
            end
        end
    end

    // 第三级流水线：2组4数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 2; i++) begin
                stage3_sum[i] <= 0;
            end
        end
        else if (start && !finish_reg) begin
            for (int i = 0; i < 2; i++) begin
                stage3_sum[i] <= stage2_sum[i*4] + stage2_sum[i*4+1] + stage2_sum[i*4+2] + stage2_sum[i*4+3];
            end
        end
    end

    // 第四级流水线：2数相加
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac <= 0;
        end
        else if (start && !finish_reg) begin
            mac <= stage3_sum[0] + stage3_sum[1];
        end
    end

    integer QKT_r, QKT_c;
    reg [2:0] delay_cnt;
    // 把mac赋值到QK_out
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 128; i++) begin
                for (int j = 0; j < 128; j++) begin
                    QKT[i][j] <= 0;
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                end
            end
        end
        else if (start && !finish_reg) begin
            if (delay_cnt < 6) begin
                delay_cnt <= delay_cnt + 1;
            end
            else begin
                if (QKT_r < 32) begin
                    QKT[QKT_r][QKT_c] <= mac;
                    QKT_c <= QKT_c + 1;
                    if (QKT_c == 127) begin
                        QKT_r <= QKT_r + 1;
                        QKT_c <= 0;
                    end
                end
                else begin
                    QKT_r <= 0;
                    QKT_c <= 0;
                    delay_cnt <= 0;
                    finish_reg <= 1;
                end
            end
        end
    end

endmodule

