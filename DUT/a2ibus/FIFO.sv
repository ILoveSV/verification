module	decrypt_WFIFO
#(
	parameter DATA_WIDTH=64,
	parameter FIFO_DEPTH=16
)
(
	input wire clk,
	input wire rst_n,
	input wire wr_en,
	input wire rd_en,
	input wire [DATA_WIDTH-1:0] decrypt_WFIFO,
	output logic [DATA_WIDTH-1:0] WFIFO_wdata,
	output logic WFIFO_full,
	output logic WFIFO_empty,
	output logic [$clog2(FIFO_DEPTH):0] fifo_cnt
);
	logic [$clog2(FIFO_DEPTH)-1:0] wr_addr, rd_addr;
	logic [DATA_WIDTH-1:0] fifo_buffer[FIFO_DEPTH] ;
    logic write = 0;
    logic read = 0;
//写地址时序逻辑
	always_ff @(posedge clk or negedge rst_n) begin
        write <= 0;
		if(!rst_n) begin
			wr_addr <= 0;
		end
		else if(!WFIFO_full && wr_en && decrypt_WFIFO) begin //先读后写模式，所以写入的是加1前的wr_addr
			wr_addr <= wr_addr + 1'b1;
			fifo_buffer[wr_addr] <= decrypt_WFIFO;
            write <= 1;
		end
	end
//读时序逻辑
	always_ff @(posedge clk or negedge rst_n) begin
        read <= 0;
		if(!rst_n) begin
			rd_addr <= 0;
		end
		else if(!WFIFO_empty && rd_en) begin
			rd_addr <= rd_addr + 1'b1;
			WFIFO_wdata <= fifo_buffer[rd_addr];
            read <= 1;
		end
	end
//更新计数器
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			fifo_cnt <= 0;
		end
		else begin
			case ({wr_en,rd_en})
			2'b00: fifo_cnt <= fifo_cnt;
			2'b01: 
				if(fifo_cnt!=0)
					fifo_cnt <= fifo_cnt-1'b1;
			2'b10: 
				if(fifo_cnt!=FIFO_DEPTH)
					fifo_cnt <= fifo_cnt + 1'b1;
			2'b11: 
			begin 
				if(WFIFO_empty)
				//有写没有读
				   fifo_cnt <= fifo_cnt + 1'b1;
				else if(WFIFO_full) 
				//有读没有写
					fifo_cnt <= fifo_cnt - 1'b1;
				else
				   fifo_cnt <= fifo_cnt;  
			end 
			endcase
		end
	end



	assign WFIFO_full  = (fifo_cnt == FIFO_DEPTH) ? 1'b1 : 1'b0;		
	assign WFIFO_empty = (fifo_cnt == 0)? 1'b1 : 1'b0;				
 


 logic [DATA_WIDTH-1:0] prev_decrypt_WFIFO;



always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        prev_decrypt_WFIFO <= 0;
    else
        prev_decrypt_WFIFO <= decrypt_WFIFO;
end

 // Assertions

property wFIFO_not_full;
    @(posedge clk) disable iff(!rst_n)
    wr_en |-> !WFIFO_full;
endproperty

property wFIFO_not_empty;
    @(posedge clk) disable iff(!rst_n)
    rd_en |-> !WFIFO_empty;
endproperty

property data_wr_chk;
    @(posedge clk) disable iff(!rst_n)
    (write && wr_addr) |-> (fifo_buffer[wr_addr-1] == prev_decrypt_WFIFO);
endproperty

property read_data_integrity;
    @(posedge clk) disable iff(!rst_n)
    (read && rd_addr && 0) |-> (WFIFO_wdata == fifo_buffer[rd_addr-1]);
endproperty

check_wFIFO_not_full: assert property (wFIFO_not_full) else $error($stime, "\t\t FATAL: decrypt_WFIFO is full but write is enabled!\n");
check_wFIFO_not_empty: assert property (wFIFO_not_empty) else $error($stime, "\t\t FATAL: decrypt_WFIFO is empty but read is enabled!\n");
check_write_data_integrity: assert property (data_wr_chk) else $error($stime, "\t\t FATAL: Write data integrity check failed in decrypt_WFIFO!\n");
check_read_data_integrity: assert property (read_data_integrity) else $error($stime, "\t\t FATAL: Read data integrity check failed in decrypt_WFIFO!\n");


endmodule:decrypt_WFIFO



module encrypt_RFIFO
#(
    parameter DATA_WIDTH = 64,
    parameter DATA_DEPTH = 16
)
(
    input   clk,
    input   rst_n, //低电平复位
    input   wire [DATA_WIDTH-1:0] encrypt_RFIFO,
    input   rd_en,
    input   wr_en,
    output logic RFIFO_full,
	output logic RFIFO_empty,
    output  logic [DATA_WIDTH-1:0] RFIFO_rdata,
    output  logic [$clog2(DATA_DEPTH):0] fifo_cnt//FIFO已写入的元素数量
);
logic [DATA_WIDTH-1:0] fifo_buffer[DATA_DEPTH]; //目前指针指向的数据
logic [$clog2(DATA_DEPTH)-1:0]   wr_addr;          //写指针
logic [$clog2(DATA_DEPTH)-1:0]   rd_addr;          //读指针
    logic write = 0;
    logic read = 0;
    logic [DATA_WIDTH-1:0] prev_encrypt_RFIFO;
//--------------------------读写的指针移动操作---------------------
always @(posedge clk or negedge rst_n)begin
    read <= 0;
    if(!rst_n)
        rd_addr <= 0;//如果复位，rd归为0
    else if (!RFIFO_empty && rd_en)begin  //读使能有效且非空时，读指针指向下一位
        rd_addr <= rd_addr + 1'd1;
        RFIFO_rdata <= fifo_buffer[rd_addr];
        read <= 1;
    end
end

always @ (posedge clk or negedge rst_n)begin
    write <= 0;
    if(!rst_n)
        wr_addr <= 0;
    else if (!RFIFO_full && wr_en )begin  //写使能有效且非满时，写指针指向下一位
        wr_addr <= wr_addr + 1'd1;
        fifo_buffer[wr_addr] <= encrypt_RFIFO;
        write <= 1;
    end
end

//--------------------------读写的深度标识更改操作---------------------
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			fifo_cnt <= 0;
		end
		else begin
			case ({wr_en,rd_en})
			2'b00: fifo_cnt <= fifo_cnt;
			2'b01: 
				if(fifo_cnt!=0)
					fifo_cnt <= fifo_cnt-1'b1;
			2'b10: 
				if(fifo_cnt!=DATA_DEPTH)
					fifo_cnt <= fifo_cnt + 1'b1;
			2'b11: 
			begin 
				if(RFIFO_empty)
				//有写没有读
				   fifo_cnt <= fifo_cnt + 1'b1;
				else if(RFIFO_full) 
				//有读没有写
					fifo_cnt <= fifo_cnt - 1'b1;
				else
				   fifo_cnt <= fifo_cnt;  
			end 
			endcase
		end
end
	assign RFIFO_full  = (fifo_cnt == DATA_DEPTH) ? 1'b1 : 1'b0;		
	assign RFIFO_empty = (fifo_cnt == 0)? 1'b1 : 1'b0;				
 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        prev_encrypt_RFIFO <= 0;
    else
        prev_encrypt_RFIFO <= encrypt_RFIFO;
end

// (1) FIFO空满信号判断的正确性
property rfIFO_not_full;
    @(posedge clk) disable iff(!rst_n)
    (wr_en) |-> (fifo_cnt != DATA_DEPTH);
endproperty

property rfIFO_not_empty;
    @(posedge clk) disable iff(!rst_n)
    (rd_en) |-> (fifo_cnt != 0);
endproperty

// (2) FIFO写入、读出功能的正确性
property write_data_integrity;
    @(posedge clk) disable iff(!rst_n)
    (write) |-> (fifo_buffer[wr_addr-1] == prev_encrypt_RFIFO);
endproperty

property read_data_integrity;
    @(posedge clk) disable iff(!rst_n)
    (read && wr_addr) |-> (RFIFO_rdata == fifo_buffer[rd_addr-1]);
endproperty

// Assertions
check_rfIFO_not_full: assert property (rfIFO_not_full) else $error($stime, "\t\t FATAL: encrypt_RFIFO is full but write is enabled!\n");
check_rfIFO_not_empty: assert property (rfIFO_not_empty) else $error($stime, "\t\t FATAL: encrypt_RFIFO is empty but read is enabled!\n");
check_write_data_integrity: assert property (write_data_integrity) else $error($stime, "\t\t FATAL: Write data integrity check failed in encrypt_RFIFO!\n");
check_read_data_integrity: assert property (read_data_integrity) else $error($stime, "\t\t FATAL: Read data integrity check failed in encrypt_RFIFO!\n");

endmodule:encrypt_RFIFO




