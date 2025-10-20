module encrypt_module (
    input logic clk,
    input logic rst_n,
    input logic [63:0] encrypt_rdata,
    input logic [63:0] key,
    input logic RFIFO_wr_en,
    output logic RFIFO_wr_en_encrypt,
    output logic [63:0] encrypt_RFIFO
);

    logic [63:0] rdata_reg;  // 加密数据寄存器
    logic [63:0] key_reg;    // 密钥寄存器
    logic [63:0] encrypted_rdata_reg;  // 解密数据寄存器

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_reg <= 64'd0;
            key_reg <= 64'd0;
            encrypted_rdata_reg <= 64'd0;
        end else if( RFIFO_wr_en )begin
            rdata_reg <= encrypt_rdata;
            key_reg <= key;
            encrypted_rdata_reg <= rdata_reg ^ key_reg;

        end
    end

    always_ff @(posedge clk) begin
            RFIFO_wr_en_encrypt <= RFIFO_wr_en;
    end

    assign encrypt_RFIFO = encrypted_rdata_reg;

endmodule:encrypt_module


module decrypt_module (
    input logic clk,
    input logic rst_n,
    input logic [63:0] decrypt_wdata,
    input logic [63:0] key,
    input logic WFIFO_wr_en,
    output logic WFIFO_wr_en_decrypt,
    output logic [63:0] decrypt_WFIFO
);

    logic [63:0] wdata_reg;  // 加密数据寄存器
    logic [63:0] key_reg;    // 密钥寄存器
    logic [63:0] decrypted_wdata_reg;  // 解密数据寄存器

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wdata_reg <= 64'd0;
            key_reg <= 64'd0;
            decrypted_wdata_reg <= 64'd0;
        end else if( WFIFO_wr_en )begin
            wdata_reg <= decrypt_wdata;
            key_reg <= key;
            decrypted_wdata_reg <= wdata_reg ^ key_reg;
       //     decrypted_wdata_reg <= wdata_reg ;
        
      end
    end

    always_ff @(posedge clk ) begin
            WFIFO_wr_en_decrypt <= WFIFO_wr_en;
    end

            assign decrypt_WFIFO = decrypted_wdata_reg;


endmodule:decrypt_module

/*
module DES_TOP(
    input  clk,
    input  rst_n,
    input logic [0:63]data,
    input logic [0:63] key,
    input logic wr_en,
    output logic [0:63]	result,
    output logic wr_en_FIFO
);
parameter SLEEP	=	6'b000001;
parameter PC_1 	=	6'b000010;
parameter PC_2		=	6'b000100;
parameter IP		=	6'b001000;
parameter CODING	=	6'b010000;
parameter DIP		=	6'b100000;

reg	[0:5] corrent_state;
reg	[0:5] next_state;

wire 	down_pc1,down_pc2,down_IP,down_DIP;
reg  	en_pc1,en_pc2,en_IP,en_DIP;
wire [1:16] down_f;
reg  [1:16] en_f;

wire [1:48] k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16;


always @(posedge clk or negedge rst_n)
    begin
        if(~rst_n) begin
            corrent_state <= SLEEP;
        end
        else begin
            corrent_state <= next_state;
        end
    end

always @(posedge clk or negedge rst_n)
    begin
        if(~rst_n) begin
            en_pc1<=1'b0;
            en_pc2<=1'b0;
            en_IP	<=1'b0;
            en_f[1]<=1'b0;
            en_DIP <=1'b0;
        end
        else begin
            case(corrent_state)
          6'b000010: begin
                                en_pc1<=1'b1;
                            end
          6'b000100: begin
                               en_pc2<=1'b1;
                            end
          6'b001000:begin
                                en_IP<=1'b1;
                            end
          6'b010000:begin
                                en_f[1]<=1'b1;
                            end
          6'b100000:begin
                                en_DIP<=1'b1;
                            end
            default:begin end
            endcase
        end
    end

always @(*)begin
        if(~rst_n) begin
            next_state = SLEEP;
        end
        else begin
        case(corrent_state)
            6'b000001: begin 
                if(wr_en)
                next_state = PC_1; 
                else
                next_state = SLEEP;
            end
            6'b000010: begin
                wr_en_FIFO <= 0;
                 if(down_pc1)	next_state = PC_2;
                end
            6'b000100: begin
                wr_en_FIFO <= 0;
                 if(down_pc2) next_state = IP;
                end
            6'b001000: begin
                wr_en_FIFO <= 0;
                 if(down_IP)	next_state = CODING;
                end
            6'b010000: begin
                wr_en_FIFO <= 0;
                 if(down_f[16]) next_state=DIP;
                end
            6'b100000: begin 
                wr_en_FIFO <= 1;
                if(down_DIP) next_state = next_state;
            end
            default  : begin
                wr_en_FIFO <= 0;
                next_state = SLEEP;
            end
        endcase
        end
end
wire [1:56] pc1_out;
wire [1:48*16]	pc2_out;
wire [0:63] IP_out;
wire [0:63] DIP_out;
key_pc1 key_pc1_u(clk,rst_n,key,pc1_out,down_pc1,en_pc1);

key_pc2 key_pc2_u(clk,rst_n,pc1_out,pc2_out,down_pc2,en_pc2);

IP		  IP_u	  (clk,rst_n,data,IP_out,down_IP,en_IP);
assign {k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16} = pc2_out;


//CODING连6'b100000:接&例化部分
wire [1:32] R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16;
wire [1:32] L0,L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16;
wire [1:32]	f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16;
assign {L0,R0}=IP_out;

assign R1 = L0^f1;assign L1 = R0;
assign R2 = L1^f2;assign L2 = R1;
assign R3 = L2^f3;assign L3 = R2;
assign R4 = L3^f4;assign L4 = R3;
assign R5 = L4^f5;assign L5 = R4;
assign R6 = L5^f6;assign L6 = R5;
assign R7 = L6^f7;assign L7 = R6;
assign R8 = L7^f8;assign L8 = R7;
assign R9 = L8^f9;assign L9 = R8;
assign R10 = L9^f10;assign L10 = R9;
assign R11 = L10^f11;assign L11 = R10;
assign R12 = L11^f12;assign L12 = R11;
assign R13 = L12^f13;assign L13 = R12;
assign R14 = L13^f14;assign L14 = R13;
assign R15 = L14^f15;assign L15 = R14;
assign R16 = L15^f16;assign L16 = R15;
genvar i;

generate 
    for(i=1;i<16;i=i+1)
    begin :en
        always@(*) begin en_f[i+1]=down_f[i];end
    end
endgenerate

f f_1(clk,rst_n,R0,k1,f1,down_f[1],en_f[1]);
f f_2(clk,rst_n,R1,k2,f2,down_f[2],en_f[2]);
f f_3(clk,rst_n,R2,k3,f3,down_f[3],en_f[3]);
f f_4(clk,rst_n,R3,k4,f4,down_f[4],en_f[4]);
f f_5(clk,rst_n,R4,k5,f5,down_f[5],en_f[5]);
f f_6(clk,rst_n,R5,k6,f6,down_f[6],en_f[6]);
f f_7(clk,rst_n,R6,k7,f7,down_f[7],en_f[7]);
f f_8(clk,rst_n,R7,k8,f8,down_f[8],en_f[8]);
f f_9(clk,rst_n,R8,k9,f9,down_f[9],en_f[9]);
f f_10(clk,rst_n,R9,k10,f10,down_f[10],en_f[10]);
f f_11(clk,rst_n,R10,k11,f11,down_f[11],en_f[11]);
f f_12(clk,rst_n,R11,k12,f12,down_f[12],en_f[12]);
f f_13(clk,rst_n,R12,k13,f13,down_f[13],en_f[13]);
f f_14(clk,rst_n,R13,k14,f14,down_f[14],en_f[14]);
f f_15(clk,rst_n,R14,k15,f15,down_f[15],en_f[15]);
f f_16(clk,rst_n,R15,k16,f16,down_f[16],en_f[16]);

DIP		  DIP_u	  (clk,rst_n,{R16,L16},DIP_out,down_DIP,en_DIP);

assign result = DIP_out;

endmodule
module key_pc1(
	input 					clk,
	input					   rst_n,
	input		   [1:64] 	key,
	
	output reg	[1:56]	out,
	output reg				down_pc1,
	input 					en_pc1
);
always @(posedge clk or negedge rst_n) 
	begin
		if(~rst_n)begin
			out <= 56'b0;
			down_pc1<=1'b0;
		end
		else begin
			if(en_pc1)begin
			out <={key[57],key[49],key[41],key[33],key[25],key[17],key[9],
					key[1],key[58],key[50],key[42],key[34],key[26],key[18],
					key[10],key[2],key[59],key[51],key[43],key[35],key[27],
					key[19],key[11],key[3],key[60],key[52],key[44],key[36],
					key[63],key[55],key[47],key[39],key[31],key[23],key[15],
					key[7],key[62],key[54],key[46],key[38],key[30],key[22],
					key[14],key[6],key[61],key[53],key[45],key[37],key[29],
					key[21],key[13],key[5],key[28],key[20],key[12],key[4]};
			down_pc1<=1'b1;
						end
			else begin
			out<= out;
			down_pc1<=down_pc1;
				end
		end
	end
endmodule
module key_pc2(
	input 				clk,
	input					rst_n,
	input		[1:56] 	key_1,
	
	output	   	[1:48*16]	out,
	output	reg					down_pc2,
	input							en_pc2
);
wire [0:27] C_T[16:0];
wire [0:27]	D_T[16:0];
wire [1:56] T[16:0];//左右拼接

reg [1:48] T_O[16:0];//PC-2置换后数值

assign C_T[0] = key_1[1:28];
assign D_T[0] = key_1[29:56];
assign T[0]	  = {C_T[0],D_T[0]};
assign out    = {T_O[1],T_O[2],T_O[3],T_O[4],T_O[5],T_O[6],T_O[7],T_O[8],T_O[9],T_O[10],T_O[11],T_O[12],T_O[13],T_O[14],T_O[15],T_O[16]};
genvar i;
generate 
	for(i=1;i<=2;i=i+1)
	begin :shift1_2
assign C_T[i] = {C_T[i-1][1:27],C_T[i-1][0]};
assign D_T[i] = {D_T[i-1][1:27],D_T[i-1][0]};
assign T[i]	  = {C_T[i],D_T[i]};
end
endgenerate

generate 
	for(i=3;i<=8;i=i+1)
	begin :shift3_8
assign C_T[i] = {C_T[i-1][2:27],C_T[i-1][0:1]};
assign D_T[i] = {D_T[i-1][2:27],D_T[i-1][0:1]};
assign T[i]	  = {C_T[i],D_T[i]};
end
endgenerate

generate 
	for(i=9;i<=9;i=i+1)
	begin :shift9
assign C_T[i] = {C_T[i-1][1:27],C_T[i-1][0]};
assign D_T[i] = {D_T[i-1][1:27],D_T[i-1][0]};
assign T[i]	  = {C_T[i],D_T[i]};
end
endgenerate

generate 
	for(i=10;i<=15;i=i+1)
	begin :shift10_15
assign C_T[i] = {C_T[i-1][2:27],C_T[i-1][0:1]};
assign D_T[i] = {D_T[i-1][2:27],D_T[i-1][0:1]};
assign T[i]	  = {C_T[i],D_T[i]};
end
endgenerate
generate 
	for(i=16;i<=16;i=i+1)
	begin :shift16
assign C_T[i] = {C_T[i-1][1:27],C_T[i-1][0]};
assign D_T[i] = {D_T[i-1][1:27],D_T[i-1][0]};
assign T[i]	  = {C_T[i],D_T[i]};
end
endgenerate

generate 
	for(i=1;i<=16;i=i+1)
	begin :pc2
always @(posedge clk or negedge rst_n) 
	begin
		if(~rst_n)	begin
			T_O[i] <= 48'b0;
			end
		else begin
			if(en_pc2)
			T_O[i] <= {T[i][14],T[i][17],T[i][11],T[i][24],T[i][1],T[i][5],
						  T[i][2],T[i][28],T[i][15],T[i][6],T[i][21],T[i][10],
						  T[i][23],T[i][19],T[i][12],T[i][3],T[i][26],T[i][8],
						  T[i][16],T[i][7],T[i][27],T[i][20],T[i][13],T[i][4],
						  T[i][41],T[i][52],T[i][31],T[i][37],T[i][47],T[i][55],
						  T[i][30],T[i][40],T[i][51],T[i][45],T[i][33],T[i][48],
						  T[i][44],T[i][49],T[i][39],T[i][56],T[i][34],T[i][53],
						  T[i][46],T[i][42],T[i][50],T[i][36],T[i][29],T[i][32]};
			else
			T_O[i] <= T_O[i];end
	end
	end
endgenerate

always @(posedge clk or negedge rst_n) 
	begin
		if(~rst_n)	begin
			down_pc2 <= 1'b0;
			end
		else begin
			if(en_pc2)
			down_pc2 <= 1'b1;
			else down_pc2<=down_pc2;
		end
	end
endmodule

module IP(
	input 					clk,
	input						rst_n,
	input			[1:64] 	data,
	
	output	reg [0:63]	out,
	output	reg			down_IP,
	input						en_IP
);
	always @(posedge clk or negedge rst_n) 
		begin
			if(~rst_n)begin
				out <= 64'b0;
				down_IP<= 1'b0;
			end
			else begin
				if(en_IP)begin
				out <={data[58],data[50],data[42],data[34],data[26],data[18],data[10],data[2],
						data[60],data[52],data[44],data[36],data[28],data[20],data[12],data[4],
						data[62],data[54],data[46],data[38],data[30],data[22],data[14],data[6],
						data[64],data[56],data[48],data[40],data[32],data[24],data[16],data[8],
						data[57],data[49],data[41],data[33],data[25],data[17],data[9],data[1],
						data[59],data[51],data[43],data[35],data[27],data[19],data[11],data[3],
						data[61],data[53],data[45],data[37],data[29],data[21],data[13],data[5],
						data[63],data[55],data[47],data[39],data[31],data[23],data[15],data[7]};
				down_IP<=1'b1;
						end
				else begin
				out <= out;
				down_IP<=down_IP;
						end
			end
		end
	endmodule
    module f(
        input 				clk,
        input					rst_n,
        input		[1:32] 	R,
        input 	[1:48]	key,
        
        output	reg	[1:32]	out,
        output						down_f,
        input							en_f
    );
    wire	[1:48] E;
    assign E={R[32],R[1:5],R[4:9],R[8:13],R[12:17],R[16:21],R[20:25],R[24:29],R[28:32],R[1]};
    reg	[1:32] S;
    reg	down_s,down_p;
    wire  [1:48] B;
    assign B=E^key;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n) begin
            S <= 32'b0;
            down_s<=1'b0;
            end
        else begin
            if(en_f) begin
            case(B[1:6])//S1
                 6'b000000 :    S[1:4] <=  4'd14;
              6'b000001 :    S[1:4] <=  4'd0;
              6'b000010 :    S[1:4] <=  4'd4;
              6'b000011 :    S[1:4] <=  4'd15;
              6'b000100 :    S[1:4] <=  4'd13;
              6'b000101 :    S[1:4] <=  4'd7;
              6'b000110 :    S[1:4] <=  4'd1;
              6'b000111 :    S[1:4] <=  4'd4;
              6'b001000 :    S[1:4] <=  4'd2;
              6'b001001 :    S[1:4] <=  4'd14;
              6'b001010 :    S[1:4] <=  4'd15;
              6'b001011 :    S[1:4] <=  4'd2;
              6'b001100 :    S[1:4] <=  4'd11;
              6'b001101 :    S[1:4] <=  4'd13;
              6'b001110 :    S[1:4] <=  4'd8;
              6'b001111 :    S[1:4] <=  4'd1;
              6'b010000 :    S[1:4] <=  4'd3;
              6'b010001 :    S[1:4] <=  4'd10;
              6'b010010 :    S[1:4] <=  4'd10;
              6'b010011 :    S[1:4] <=  4'd6;
              6'b010100 :    S[1:4] <=  4'd6;
              6'b010101 :    S[1:4] <=  4'd12;
              6'b010110 :    S[1:4] <=  4'd12;
              6'b010111 :    S[1:4] <=  4'd11;
              6'b011000 :    S[1:4] <=  4'd5;
              6'b011001 :    S[1:4] <=  4'd9;
              6'b011010 :    S[1:4] <=  4'd9;
              6'b011011 :    S[1:4] <=  4'd5;
              6'b011100 :    S[1:4] <=  4'd0;
              6'b011101 :    S[1:4] <=  4'd3;
              6'b011110 :    S[1:4] <=  4'd7;
              6'b011111 :    S[1:4] <=  4'd8;
              6'b100000 :    S[1:4] <=  4'd4;
              6'b100001 :    S[1:4] <=  4'd15;
              6'b100010 :    S[1:4] <=  4'd1;
              6'b100011 :    S[1:4] <=  4'd12;
              6'b100100 :    S[1:4] <=  4'd14;
              6'b100101 :    S[1:4] <=  4'd8;
              6'b100110 :    S[1:4] <=  4'd8;
              6'b100111 :    S[1:4] <=  4'd2;
              6'b101000 :    S[1:4] <=  4'd13;
              6'b101001 :    S[1:4] <=  4'd4;
              6'b101010 :    S[1:4] <=  4'd6;
              6'b101011 :    S[1:4] <=  4'd9;
              6'b101100 :    S[1:4] <=  4'd2;
              6'b101101 :    S[1:4] <=  4'd1;
              6'b101110 :    S[1:4] <=  4'd11;
              6'b101111 :    S[1:4] <=  4'd7;
              6'b110000 :    S[1:4] <=  4'd15;
              6'b110001 :    S[1:4] <=  4'd5;
              6'b110010 :    S[1:4] <=  4'd12;
              6'b110011 :    S[1:4] <=  4'd11;
              6'b110100 :    S[1:4] <=  4'd9;
              6'b110101 :    S[1:4] <=  4'd3;
              6'b110110 :    S[1:4] <=  4'd7;
              6'b110111 :    S[1:4] <=  4'd14;
              6'b111000 :    S[1:4] <=  4'd3;
              6'b111001 :    S[1:4] <=  4'd10;
              6'b111010 :    S[1:4] <=  4'd10;
              6'b111011 :    S[1:4] <=  4'd0;
              6'b111100 :    S[1:4] <=  4'd5;
              6'b111101 :    S[1:4] <=  4'd6;
              6'b111110 :    S[1:4] <=  4'd0;
              6'b111111 :    S[1:4] <=  4'd13;
             endcase
            case(B[7:12])//S2
              6'b000000 :    S[5:8] <=  4'd15;
              6'b000001 :    S[5:8] <=  4'd3;
              6'b000010 :    S[5:8] <=  4'd1;
              6'b000011 :    S[5:8] <=  4'd13;
              6'b000100 :    S[5:8] <=  4'd8;
              6'b000101 :    S[5:8] <=  4'd4;
              6'b000110 :    S[5:8] <=  4'd14;
              6'b000111 :    S[5:8] <=  4'd7;
              6'b001000 :    S[5:8] <=  4'd6;
              6'b001001 :    S[5:8] <=  4'd15;
              6'b001010 :    S[5:8] <=  4'd11;
              6'b001011 :    S[5:8] <=  4'd2;
              6'b001100 :    S[5:8] <=  4'd3;
              6'b001101 :    S[5:8] <=  4'd8;
              6'b001110 :    S[5:8] <=  4'd4;
              6'b001111 :    S[5:8] <=  4'd14;
              6'b010000 :    S[5:8] <=  4'd9;
              6'b010001 :    S[5:8] <=  4'd12;
              6'b010010 :    S[5:8] <=  4'd7;
              6'b010011 :    S[5:8] <=  4'd0;
              6'b010100 :    S[5:8] <=  4'd2;
              6'b010101 :    S[5:8] <=  4'd1;
              6'b010110 :    S[5:8] <=  4'd13;
              6'b010111 :    S[5:8] <=  4'd10;
              6'b011000 :    S[5:8] <=  4'd12;
              6'b011001 :    S[5:8] <=  4'd6;
              6'b011010 :    S[5:8] <=  4'd0;
              6'b011011 :    S[5:8] <=  4'd9;
              6'b011100 :    S[5:8] <=  4'd5;
              6'b011101 :    S[5:8] <=  4'd11;
              6'b011110 :    S[5:8] <=  4'd10;
              6'b011111 :    S[5:8] <=  4'd5;
              6'b100000 :    S[5:8] <=  4'd0;
              6'b100001 :    S[5:8] <=  4'd13;
              6'b100010 :    S[5:8] <=  4'd14;
              6'b100011 :    S[5:8] <=  4'd8;
              6'b100100 :    S[5:8] <=  4'd7;
              6'b100101 :    S[5:8] <=  4'd10;
              6'b100110 :    S[5:8] <=  4'd11;
              6'b100111 :    S[5:8] <=  4'd1;
              6'b101000 :    S[5:8] <=  4'd10;
              6'b101001 :    S[5:8] <=  4'd3;
              6'b101010 :    S[5:8] <=  4'd4;
              6'b101011 :    S[5:8] <=  4'd15;
              6'b101100 :    S[5:8] <=  4'd13;
              6'b101101 :    S[5:8] <=  4'd4;
              6'b101110 :    S[5:8] <=  4'd1;
              6'b101111 :    S[5:8] <=  4'd2;
              6'b110000 :    S[5:8] <=  4'd5;
              6'b110001 :    S[5:8] <=  4'd11;
              6'b110010 :    S[5:8] <=  4'd8;
              6'b110011 :    S[5:8] <=  4'd6;
              6'b110100 :    S[5:8] <=  4'd12;
              6'b110101 :    S[5:8] <=  4'd7;
              6'b110110 :    S[5:8] <=  4'd6;
              6'b110111 :    S[5:8] <=  4'd12;
              6'b111000 :    S[5:8] <=  4'd9;
              6'b111001 :    S[5:8] <=  4'd0;
              6'b111010 :    S[5:8] <=  4'd3;
              6'b111011 :    S[5:8] <=  4'd5;
              6'b111100 :    S[5:8] <=  4'd2;
              6'b111101 :    S[5:8] <=  4'd14;
              6'b111110 :    S[5:8] <=  4'd15;
              6'b111111 :    S[5:8] <=  4'd9;
             endcase
            case(B[13:18])//S3
                 6'b000000 :    S[9:12] <=  4'd10;
              6'b000001 :    S[9:12] <=  4'd13;
              6'b000010 :    S[9:12] <=  4'd0;
              6'b000011 :    S[9:12] <=  4'd7;
              6'b000100 :    S[9:12] <=  4'd9;
              6'b000101 :    S[9:12] <=  4'd0;
              6'b000110 :    S[9:12] <=  4'd14;
              6'b000111 :    S[9:12] <=  4'd9;
              6'b001000 :    S[9:12] <=  4'd6;
              6'b001001 :    S[9:12] <=  4'd3;
              6'b001010 :    S[9:12] <=  4'd3;
              6'b001011 :    S[9:12] <=  4'd4;
              6'b001100 :    S[9:12] <=  4'd15;
              6'b001101 :    S[9:12] <=  4'd6;
              6'b001110 :    S[9:12] <=  4'd5;
              6'b001111 :    S[9:12] <=  4'd10;
              6'b010000 :    S[9:12] <=  4'd1;
              6'b010001 :    S[9:12] <=  4'd2;
              6'b010010 :    S[9:12] <=  4'd13;
              6'b010011 :    S[9:12] <=  4'd8;
              6'b010100 :    S[9:12] <=  4'd12;
              6'b010101 :    S[9:12] <=  4'd5;
              6'b010110 :    S[9:12] <=  4'd7;
              6'b010111 :    S[9:12] <=  4'd14;
              6'b011000 :    S[9:12] <=  4'd11;
              6'b011001 :    S[9:12] <=  4'd12;
              6'b011010 :    S[9:12] <=  4'd4;
              6'b011011 :    S[9:12] <=  4'd11;
              6'b011100 :    S[9:12] <=  4'd2;
              6'b011101 :    S[9:12] <=  4'd15;
              6'b011110 :    S[9:12] <=  4'd8;
              6'b011111 :    S[9:12] <=  4'd1;
              6'b100000 :    S[9:12] <=  4'd13;
              6'b100001 :    S[9:12] <=  4'd1;
              6'b100010 :    S[9:12] <=  4'd6;
              6'b100011 :    S[9:12] <=  4'd10;
              6'b100100 :    S[9:12] <=  4'd4;
              6'b100101 :    S[9:12] <=  4'd13;
              6'b100110 :    S[9:12] <=  4'd9;
              6'b100111 :    S[9:12] <=  4'd0;
              6'b101000 :    S[9:12] <=  4'd8;
              6'b101001 :    S[9:12] <=  4'd6;
              6'b101010 :    S[9:12] <=  4'd15;
              6'b101011 :    S[9:12] <=  4'd9;
              6'b101100 :    S[9:12] <=  4'd3;
              6'b101101 :    S[9:12] <=  4'd8;
              6'b101110 :    S[9:12] <=  4'd0;
              6'b101111 :    S[9:12] <=  4'd7;
              6'b110000 :    S[9:12] <=  4'd11;
              6'b110001 :    S[9:12] <=  4'd4;
              6'b110010 :    S[9:12] <=  4'd1;
              6'b110011 :    S[9:12] <=  4'd15;
              6'b110100 :    S[9:12] <=  4'd2;
              6'b110101 :    S[9:12] <=  4'd14;
              6'b110110 :    S[9:12] <=  4'd12;
              6'b110111 :    S[9:12] <=  4'd3;
              6'b111000 :    S[9:12] <=  4'd5;
              6'b111001 :    S[9:12] <=  4'd11;
              6'b111010 :    S[9:12] <=  4'd10;
              6'b111011 :    S[9:12] <=  4'd5;
              6'b111100 :    S[9:12] <=  4'd14;
              6'b111101 :    S[9:12] <=  4'd2;
              6'b111110 :    S[9:12] <=  4'd7;
              6'b111111 :    S[9:12] <=  4'd12;
                endcase
            case(B[19:24])//S4
                 6'b000000 :    S[13:16] <=  4'd7;
              6'b000001 :    S[13:16] <=  4'd13;
              6'b000010 :    S[13:16] <=  4'd13;
              6'b000011 :    S[13:16] <=  4'd8;
              6'b000100 :    S[13:16] <=  4'd14;
              6'b000101 :    S[13:16] <=  4'd11;
              6'b000110 :    S[13:16] <=  4'd3;
              6'b000111 :    S[13:16] <=  4'd5;
              6'b001000 :    S[13:16] <=  4'd0;
              6'b001001 :    S[13:16] <=  4'd6;
              6'b001010 :    S[13:16] <=  4'd6;
                 6'b001011 :    S[13:16] <=  4'd15;
              6'b001100 :    S[13:16] <=  4'd9;
              6'b001101 :    S[13:16] <=  4'd0;
              6'b001110 :    S[13:16] <=  4'd10;
              6'b001111 :    S[13:16] <=  4'd3;
              6'b010000 :    S[13:16] <=  4'd1;
              6'b010001 :    S[13:16] <=  4'd4;
              6'b010010 :    S[13:16] <=  4'd2;
              6'b010011 :    S[13:16] <=  4'd7;
              6'b010100 :    S[13:16] <=  4'd8;
              6'b010101 :    S[13:16] <=  4'd2;
              6'b010110 :    S[13:16] <=  4'd5;
              6'b010111 :    S[13:16] <=  4'd12;
              6'b011000 :    S[13:16] <=  4'd11;
              6'b011001 :    S[13:16] <=  4'd1;
              6'b011010 :    S[13:16] <=  4'd12;
              6'b011011 :    S[13:16] <=  4'd10;
              6'b011100 :    S[13:16] <=  4'd4;
              6'b011101 :    S[13:16] <=  4'd14;
              6'b011110 :    S[13:16] <=  4'd15;
              6'b011111 :    S[13:16] <=  4'd9;
              6'b100000 :    S[13:16] <=  4'd10;
              6'b100001 :    S[13:16] <=  4'd3;
                 6'b100010 :    S[13:16] <=  4'd6;
              6'b100011 :    S[13:16] <=  4'd15;
              6'b100100 :    S[13:16] <=  4'd9;
              6'b100101 :    S[13:16] <=  4'd0;
              6'b100110 :    S[13:16] <=  4'd0;
              6'b100111 :    S[13:16] <=  4'd6;
              6'b101000 :    S[13:16] <=  4'd12;
              6'b101001 :    S[13:16] <=  4'd10;
              6'b101010 :    S[13:16] <=  4'd11;
              6'b101011 :    S[13:16] <=  4'd1;
              6'b101100 :    S[13:16] <=  4'd7;
              6'b101101 :    S[13:16] <=  4'd13;
              6'b101110 :    S[13:16] <=  4'd13;
              6'b101111 :    S[13:16] <=  4'd8;
              6'b110000 :    S[13:16] <=  4'd15;
              6'b110001 :    S[13:16] <=  4'd9;
              6'b110010 :    S[13:16] <=  4'd1;
              6'b110011 :    S[13:16] <=  4'd4;
              6'b110100 :    S[13:16] <=  4'd3;
              6'b110101 :    S[13:16] <=  4'd5;
              6'b110110 :    S[13:16] <=  4'd14;
              6'b110111 :    S[13:16] <=  4'd11;
              6'b111000 :    S[13:16] <=  4'd5;
              6'b111001 :    S[13:16] <=  4'd12;
              6'b111010 :    S[13:16] <=  4'd2;
              6'b111011 :    S[13:16] <=  4'd7;
              6'b111100 :    S[13:16] <=  4'd8;
              6'b111101 :    S[13:16] <=  4'd2;
              6'b111110 :    S[13:16] <=  4'd4;
              6'b111111 :    S[13:16] <=  4'd14;
                endcase
            case(B[25:30])//S5
                 6'b000000 :    S[17:20] <=  4'd2;
              6'b000001 :    S[17:20] <=  4'd14;
              6'b000010 :    S[17:20] <=  4'd12;
              6'b000011 :    S[17:20] <=  4'd11;
              6'b000100 :    S[17:20] <=  4'd4;
              6'b000101 :    S[17:20] <=  4'd2;
              6'b000110 :    S[17:20] <=  4'd1;
              6'b000111 :    S[17:20] <=  4'd12;
              6'b001000 :    S[17:20] <=  4'd7;
              6'b001001 :    S[17:20] <=  4'd4;
              6'b001010 :    S[17:20] <=  4'd10;
              6'b001011 :    S[17:20] <=  4'd7;
              6'b001100 :    S[17:20] <=  4'd11;
              6'b001101 :    S[17:20] <=  4'd13;
              6'b001110 :    S[17:20] <=  4'd6;
              6'b001111 :    S[17:20] <=  4'd1;
              6'b010000 :    S[17:20] <=  4'd8;
              6'b010001 :    S[17:20] <=  4'd5;
              6'b010010 :    S[17:20] <=  4'd5;
              6'b010011 :    S[17:20] <=  4'd0;
              6'b010100 :    S[17:20] <=  4'd3;
              6'b010101 :    S[17:20] <=  4'd15;
              6'b010110 :    S[17:20] <=  4'd15;
              6'b010111 :    S[17:20] <=  4'd10;
              6'b011000 :    S[17:20] <=  4'd13;
              6'b011001 :    S[17:20] <=  4'd3;
              6'b011010 :    S[17:20] <=  4'd0;
              6'b011011 :    S[17:20] <=  4'd9;
              6'b011100 :    S[17:20] <=  4'd14;
              6'b011101 :    S[17:20] <=  4'd8;
              6'b011110 :    S[17:20] <=  4'd9;
              6'b011111 :    S[17:20] <=  4'd6;
              6'b100000 :    S[17:20] <=  4'd4;
              6'b100001 :    S[17:20] <=  4'd11;
              6'b100010 :    S[17:20] <=  4'd2;
              6'b100011 :    S[17:20] <=  4'd8;
              6'b100100 :    S[17:20] <=  4'd1;
              6'b100101 :    S[17:20] <=  4'd12;
              6'b100110 :    S[17:20] <=  4'd11;
              6'b100111 :    S[17:20] <=  4'd7;
              6'b101000 :    S[17:20] <=  4'd10;
              6'b101001 :    S[17:20] <=  4'd1;
              6'b101010 :    S[17:20] <=  4'd13;
              6'b101011 :    S[17:20] <=  4'd14;
              6'b101100 :    S[17:20] <=  4'd7;
              6'b101101 :    S[17:20] <=  4'd2;
              6'b101110 :    S[17:20] <=  4'd8;
              6'b101111 :    S[17:20] <=  4'd13;
              6'b110000 :    S[17:20] <=  4'd15;
              6'b110001 :    S[17:20] <=  4'd6;
              6'b110010 :    S[17:20] <=  4'd9;
              6'b110011 :    S[17:20] <=  4'd15;
              6'b110100 :    S[17:20] <=  4'd12;
              6'b110101 :    S[17:20] <=  4'd0;
              6'b110110 :    S[17:20] <=  4'd5;
              6'b110111 :    S[17:20] <=  4'd9;
              6'b111000 :    S[17:20] <=  4'd6;
              6'b111001 :    S[17:20] <=  4'd10;
              6'b111010 :    S[17:20] <=  4'd3;
              6'b111011 :    S[17:20] <=  4'd4;
              6'b111100 :    S[17:20] <=  4'd0;
              6'b111101 :    S[17:20] <=  4'd5;
              6'b111110 :    S[17:20] <=  4'd14;
              6'b111111 :    S[17:20] <=  4'd3;
                endcase
            case(B[31:36])//S6
                 6'b000000 :    S[21:24] <=  4'd12;
              6'b000001 :    S[21:24] <=  4'd10;
              6'b000010 :    S[21:24] <=  4'd1;
              6'b000011 :    S[21:24] <=  4'd15;
              6'b000100 :    S[21:24] <=  4'd10;
              6'b000101 :    S[21:24] <=  4'd4;
              6'b000110 :    S[21:24] <=  4'd15;
              6'b000111 :    S[21:24] <=  4'd2;
              6'b001000 :    S[21:24] <=  4'd9;
              6'b001001 :    S[21:24] <=  4'd7;
              6'b001010 :    S[21:24] <=  4'd2;
              6'b001011 :    S[21:24] <=  4'd12;
              6'b001100 :    S[21:24] <=  4'd6;
              6'b001101 :    S[21:24] <=  4'd9;
              6'b001110 :    S[21:24] <=  4'd8;
              6'b001111 :    S[21:24] <=  4'd5;
              6'b010000 :    S[21:24] <=  4'd0;
              6'b010001 :    S[21:24] <=  4'd6;
              6'b010010 :    S[21:24] <=  4'd13;
              6'b010011 :    S[21:24] <=  4'd1;
              6'b010100 :    S[21:24] <=  4'd3;
              6'b010101 :    S[21:24] <=  4'd13;
              6'b010110 :    S[21:24] <=  4'd4;
              6'b010111 :    S[21:24] <=  4'd14;
              6'b011000 :    S[21:24] <=  4'd14;
              6'b011001 :    S[21:24] <=  4'd0;
              6'b011010 :    S[21:24] <=  4'd7;
              6'b011011 :    S[21:24] <=  4'd11;
              6'b011100 :    S[21:24] <=  4'd5;
              6'b011101 :    S[21:24] <=  4'd3;
              6'b011110 :    S[21:24] <=  4'd11;
              6'b011111 :    S[21:24] <=  4'd8;
              6'b100000 :    S[21:24] <=  4'd9;
              6'b100001 :    S[21:24] <=  4'd4;
              6'b100010 :    S[21:24] <=  4'd14;
              6'b100011 :    S[21:24] <=  4'd3;
              6'b100100 :    S[21:24] <=  4'd15;
              6'b100101 :    S[21:24] <=  4'd2;
              6'b100110 :    S[21:24] <=  4'd5;
              6'b100111 :    S[21:24] <=  4'd12;
              6'b101000 :    S[21:24] <=  4'd2;
              6'b101001 :    S[21:24] <=  4'd9;
              6'b101010 :    S[21:24] <=  4'd8;
              6'b101011 :    S[21:24] <=  4'd5;
              6'b101100 :    S[21:24] <=  4'd12;
              6'b101101 :    S[21:24] <=  4'd15;
              6'b101110 :    S[21:24] <=  4'd3;
              6'b101111 :    S[21:24] <=  4'd10;
              6'b110000 :    S[21:24] <=  4'd7;
              6'b110001 :    S[21:24] <=  4'd11;
              6'b110010 :    S[21:24] <=  4'd0;
              6'b110011 :    S[21:24] <=  4'd14;
              6'b110100 :    S[21:24] <=  4'd4;
              6'b110101 :    S[21:24] <=  4'd1;
              6'b110110 :    S[21:24] <=  4'd10;
              6'b110111 :    S[21:24] <=  4'd7;
              6'b111000 :    S[21:24] <=  4'd1;
              6'b111001 :    S[21:24] <=  4'd6;
              6'b111010 :    S[21:24] <=  4'd13;
              6'b111011 :    S[21:24] <=  4'd0;
              6'b111100 :    S[21:24] <=  4'd11;
              6'b111101 :    S[21:24] <=  4'd8;
              6'b111110 :    S[21:24] <=  4'd6;
              6'b111111 :    S[21:24] <=  4'd13;
                endcase
            case(B[37:42])//S7
              6'b000000 :    S[25:28] <=  4'd4;
              6'b000001 :    S[25:28] <=  4'd13;
              6'b000010 :    S[25:28] <=  4'd11;
              6'b000011 :    S[25:28] <=  4'd0;
              6'b000100 :    S[25:28] <=  4'd2;
              6'b000101 :    S[25:28] <=  4'd11;
              6'b000110 :    S[25:28] <=  4'd14;
              6'b000111 :    S[25:28] <=  4'd7;
              6'b001000 :    S[25:28] <=  4'd15;
              6'b001001 :    S[25:28] <=  4'd4;
              6'b001010 :    S[25:28] <=  4'd0;
              6'b001011 :    S[25:28] <=  4'd9;
              6'b001100 :    S[25:28] <=  4'd8;
              6'b001101 :    S[25:28] <=  4'd1;
              6'b001110 :    S[25:28] <=  4'd13;
              6'b001111 :    S[25:28] <=  4'd10;
              6'b010000 :    S[25:28] <=  4'd3;
              6'b010001 :    S[25:28] <=  4'd14;
              6'b010010 :    S[25:28] <=  4'd12;
              6'b010011 :    S[25:28] <=  4'd3;
              6'b010100 :    S[25:28] <=  4'd9;
              6'b010101 :    S[25:28] <=  4'd5;
              6'b010110 :    S[25:28] <=  4'd7;
              6'b010111 :    S[25:28] <=  4'd12;
              6'b011000 :    S[25:28] <=  4'd5;
              6'b011001 :    S[25:28] <=  4'd2;
              6'b011010 :    S[25:28] <=  4'd10;
              6'b011011 :    S[25:28] <=  4'd15;
              6'b011100 :    S[25:28] <=  4'd6;
              6'b011101 :    S[25:28] <=  4'd8;
              6'b011110 :    S[25:28] <=  4'd1;
              6'b011111 :    S[25:28] <=  4'd6;
              6'b100000 :    S[25:28] <=  4'd1;
              6'b100001 :    S[25:28] <=  4'd6;
              6'b100010 :    S[25:28] <=  4'd4;
              6'b100011 :    S[25:28] <=  4'd11;
              6'b100100 :    S[25:28] <=  4'd11;
              6'b100101 :    S[25:28] <=  4'd13;
              6'b100110 :    S[25:28] <=  4'd13;
              6'b100111 :    S[25:28] <=  4'd8;
              6'b101000 :    S[25:28] <=  4'd12;
              6'b101001 :    S[25:28] <=  4'd1;
              6'b101010 :    S[25:28] <=  4'd3;
              6'b101011 :    S[25:28] <=  4'd4;
              6'b101100 :    S[25:28] <=  4'd7;
              6'b101101 :    S[25:28] <=  4'd10;
              6'b101110 :    S[25:28] <=  4'd14;
              6'b101111 :    S[25:28] <=  4'd7;
              6'b110000 :    S[25:28] <=  4'd10;
              6'b110001 :    S[25:28] <=  4'd9;
              6'b110010 :    S[25:28] <=  4'd15;
              6'b110011 :    S[25:28] <=  4'd5;
              6'b110100 :    S[25:28] <=  4'd6;
              6'b110101 :    S[25:28] <=  4'd0;
              6'b110110 :    S[25:28] <=  4'd8;
              6'b110111 :    S[25:28] <=  4'd15;
              6'b111000 :    S[25:28] <=  4'd0;
              6'b111001 :    S[25:28] <=  4'd14;
              6'b111010 :    S[25:28] <=  4'd5;
              6'b111011 :    S[25:28] <=  4'd2;
              6'b111100 :    S[25:28] <=  4'd9;
              6'b111101 :    S[25:28] <=  4'd3;
              6'b111110 :    S[25:28] <=  4'd2;
              6'b111111 :    S[25:28] <=  4'd12;
                endcase
            case(B[43:48])//S8
                6'b000000 :    S[29:32] <=  4'd13;
              6'b000001 :    S[29:32] <=  4'd1;
              6'b000010 :    S[29:32] <=  4'd2;
              6'b000011 :    S[29:32] <=  4'd15;
              6'b000100 :    S[29:32] <=  4'd8;
              6'b000101 :    S[29:32] <=  4'd13;
              6'b000110 :    S[29:32] <=  4'd4;
              6'b000111 :    S[29:32] <=  4'd8;
              6'b001000 :    S[29:32] <=  4'd6;
              6'b001001 :    S[29:32] <=  4'd10;
              6'b001010 :    S[29:32] <=  4'd15;
              6'b001011 :    S[29:32] <=  4'd3;
              6'b001100 :    S[29:32] <=  4'd11;
              6'b001101 :    S[29:32] <=  4'd7;
              6'b001110 :    S[29:32] <=  4'd1;
              6'b001111 :    S[29:32] <=  4'd4;
              6'b010000 :    S[29:32] <=  4'd10;
              6'b010001 :    S[29:32] <=  4'd12;
              6'b010010 :    S[29:32] <=  4'd9;
              6'b010011 :    S[29:32] <=  4'd5;
              6'b010100 :    S[29:32] <=  4'd3;
              6'b010101 :    S[29:32] <=  4'd6;
              6'b010110 :    S[29:32] <=  4'd14;
              6'b010111 :    S[29:32] <=  4'd11;
              6'b011000 :    S[29:32] <=  4'd5;
              6'b011001 :    S[29:32] <=  4'd0;
              6'b011010 :    S[29:32] <=  4'd0;
              6'b011011 :    S[29:32] <=  4'd14;
              6'b011100 :    S[29:32] <=  4'd12;
              6'b011101 :    S[29:32] <=  4'd9;
              6'b011110 :    S[29:32] <=  4'd7;
              6'b011111 :    S[29:32] <=  4'd2;
              6'b100000 :    S[29:32] <=  4'd7;
              6'b100001 :    S[29:32] <=  4'd2;
              6'b100010 :    S[29:32] <=  4'd11;
              6'b100011 :    S[29:32] <=  4'd1;
              6'b100100 :    S[29:32] <=  4'd4;
              6'b100101 :    S[29:32] <=  4'd14;
              6'b100110 :    S[29:32] <=  4'd1;
              6'b100111 :    S[29:32] <=  4'd7;
              6'b101000 :    S[29:32] <=  4'd9;
              6'b101001 :    S[29:32] <=  4'd4;
              6'b101010 :    S[29:32] <=  4'd12;
              6'b101011 :    S[29:32] <=  4'd10;
              6'b101100 :    S[29:32] <=  4'd14;
              6'b101101 :    S[29:32] <=  4'd8;
              6'b101110 :    S[29:32] <=  4'd2;
              6'b101111 :    S[29:32] <=  4'd13;
              6'b110000 :    S[29:32] <=  4'd0;
              6'b110001 :    S[29:32] <=  4'd15;
              6'b110010 :    S[29:32] <=  4'd6;
              6'b110011 :    S[29:32] <=  4'd12;
              6'b110100 :    S[29:32] <=  4'd10;
              6'b110101 :    S[29:32] <=  4'd9;
              6'b110110 :    S[29:32] <=  4'd13;
              6'b110111 :    S[29:32] <=  4'd0;
              6'b111000 :    S[29:32] <=  4'd15;
              6'b111001 :    S[29:32] <=  4'd3;
              6'b111010 :    S[29:32] <=  4'd3;
              6'b111011 :    S[29:32] <=  4'd5;
              6'b111100 :    S[29:32] <=  4'd5;
              6'b111101 :    S[29:32] <=  4'd6;
              6'b111110 :    S[29:32] <=  4'd8;
              6'b111111 :    S[29:32] <=  4'd11;
                endcase
            down_s<=1'b1;
            end
            else
            down_s<=down_s;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            out <= 32'b0;
            down_p<=1'b0;
        end
        else begin
            if(down_s) begin
            out <={	S[16],S[7] ,S[20],S[21],
                   S[29],S[12],S[28],S[17],
                   S[1], S[15],S[23],S[26],
                   S[5], S[18],S[31],S[10],
                   S[2], S[8] ,S[24],S[14],
                   S[32],S[27],S[3] ,S[9],
                   S[19],S[13],S[30],S[6],
                   S[22],S[11],S[4] ,S[25]};
            down_p<=1'b1;
                        end
            else begin
            out <= out;
            down_p<=down_p;
                end
        end
    end
    assign down_f = down_p&down_s;
    endmodule
    module DIP(
        input 					clk,
        input						rst_n,
        input			[1:64] 	data,
        
        output	reg [0:63]	out,
        output	reg			down_DIP,
        input						en_DIP
    );
        always @(posedge clk or negedge rst_n) 
            begin
                if(~rst_n)begin
                    out <= 64'b0;
                    down_DIP<= 1'b0;
                end
                else begin
                    if(en_DIP)begin
                    out <={data[40],data[8],data[48],data[16],data[56],data[24],data[64],data[32],
                       data[39],data[7],data[47],data[15],data[55],data[23],data[63],data[31],
                       data[38],data[6],data[46],data[14],data[54],data[22],data[62],data[30],
                       data[37],data[5],data[45],data[13],data[53],data[21],data[61],data[29],
                       data[36],data[4],data[44],data[12],data[52],data[20],data[60],data[28],
                       data[35],data[3],data[43],data[11],data[51],data[19],data[59],data[27],
                       data[34],data[2],data[42],data[10],data[50],data[18],data[58],data[26],
                       data[33],data[1],data[41],data[9],data[49],data[17],data[57],data[25]};
    
                    down_DIP<=1'b1;
                            end
                    else begin
                    out <= out;
                    down_DIP<=down_DIP;
                            end
                end
            end
        endmodule
        
*/
