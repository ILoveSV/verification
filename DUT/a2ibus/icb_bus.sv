//===================================================================== 
/// Description: 
// the interface of icb
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 
/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface icb_bus(input logic clk,input logic rst_n);
    //command channel
    logic icb_cmd_valid;
    logic icb_cmd_ready;
    logic [63:0] icb_cmd_addr;
    logic icb_cmd_read;
    logic [63:0] icb_cmd_wdata;
    logic [7:0] icb_cmd_wmask;
    //response channel
    logic icb_rsp_valid;
    logic icb_rsp_ready;
    logic [63:0] icb_rsp_rdata;
    logic icb_rsp_err;

    logic [0:0]WFIFO_full;
    logic [0:0]WFIFO_empty;
    logic [0:0]RFIFO_full;
    logic [0:0]RFIFO_empty;

    modport slave(
      clocking slv_cb,
      input icb_cmd_valid, 
      icb_cmd_addr, 
      icb_cmd_read, 
      icb_cmd_wdata, 
      icb_cmd_wmask, 
      icb_rsp_ready, 
      clk, 
      rst_n,
      output icb_cmd_ready, 
      icb_rsp_valid, 
      icb_rsp_rdata, 
      icb_rsp_err,
      WFIFO_full,
      WFIFO_empty,
      RFIFO_full,
      RFIFO_empty
    );

    modport master(
      clocking mst_cb,
      output icb_cmd_valid, 
      icb_cmd_addr, 
      icb_cmd_read, 
      icb_cmd_wdata,
      icb_cmd_wmask, 
      icb_rsp_ready,
      input icb_cmd_ready, 
      icb_rsp_valid, 
      icb_rsp_rdata, 
      icb_rsp_err,  
      clk, 
      rst_n,
      WFIFO_full,
      WFIFO_empty,
      RFIFO_full,
      RFIFO_empty
    );

    modport others (
        input    clk,
        input    rst_n,
        
        input  icb_cmd_ready,
        input  icb_cmd_valid,
        input  icb_cmd_addr,
        input  icb_cmd_read,
        input  icb_cmd_wdata,
        input  icb_cmd_wmask,

        input  icb_rsp_ready,
        input  icb_rsp_valid,
        input  icb_rsp_rdata,
        input  icb_rsp_err,

        input WFIFO_full,
        input WFIFO_empty,
        input RFIFO_full,
        input RFIFO_empty
    );

     // Clocking block for the master side
    clocking mst_cb @(posedge clk);
  default input #0.25 output #0.25;
        output icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask;
        input icb_cmd_ready;
        output icb_rsp_ready;
        input icb_rsp_valid, icb_rsp_rdata, icb_rsp_err;
    endclocking


    // Clocking block for the slave side
    clocking slv_cb @(posedge clk);
  default input #0.25 output #0.25;
        input icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask;
        output icb_cmd_ready;
        input icb_rsp_ready;
        output icb_rsp_valid, icb_rsp_rdata, icb_rsp_err;
    endclocking

endinterface:icb_bus    

//===================================================================== 
/// Description: 
// The icb_slave module handles the interface communication for the ICB bus.
// It processes read and write commands, manages response signals, and updates
// internal registers based on the received commands.
// ==================================================================== 

module icb_slave(
  icb_bus.slave icb,
  output logic [63:0]decrypt_wdata,
         logic [63:0]key0,
         logic [0:0]WFIFO_wr_en,
         logic [0:0]RFIFO_rd_en,
   input logic [63:0]RFIFO_rdata,
         [1:0]apb_stat,
         [0:0]WFIFO_full,
         [0:0]WFIFO_empty,  
         [0:0]RFIFO_full,
         [0:0]RFIFO_empty
);

  logic [0:0]ctrl;
  logic [5:0]stat; // 00_00_00代表WFIFO,RFIFO,APB;FIFO:01代表空，00代表半空，10代表满；APB:00代表空闲，01代表读，10代表写
  logic [63:0]wdata;
  logic [63:0]key;
  logic [63:0]rdata;
  localparam  CTRL_ADDR = 32'h2000_0000;
  localparam  STAT_ADDR = 32'h2000_0008;
  localparam  WDATA_ADDR = 32'h2000_0010;
  localparam  RDATA_ADDR = 32'h2000_0018;
  localparam  KEY_ADDR = 32'h2000_0020;
  parameter IDLE = 0,REPLY = 1;
  logic [1:0] crnt_state;
  logic [1:0] nxt_state;

    always_ff @(posedge icb.clk or negedge icb.rst_n) begin  //状态机部分
         if (!icb.rst_n) begin   //复位的情况
            icb.icb_rsp_valid <= 0;
            icb.icb_rsp_err <= 0;
            icb.icb_rsp_rdata <= 0;
            icb.icb_cmd_ready <= 0;
            WFIFO_wr_en <= 0;
            RFIFO_rd_en <= 0;
            crnt_state <= IDLE;
            nxt_state <= IDLE;
            decrypt_wdata <= 0;
            key0  <= 0;
            key    <= 0;
            wdata  <= 0;
            rdata  <= 0;
            ctrl   <= 0;
            stat   <= 0;
        end else begin
            case (crnt_state)
                IDLE: begin
                    if (icb.icb_cmd_valid) begin
                        nxt_state <= REPLY;
                    end else begin
                        nxt_state <= IDLE;
                    end
                end
                REPLY: begin
                    if (icb.icb_cmd_valid) begin
                        nxt_state <= REPLY;
                    end else begin
                        nxt_state <= IDLE;
                    end
                end
            endcase

        end
    end

    always_ff @(posedge icb.clk) begin 

      if(nxt_state == REPLY)begin       
          if(icb.icb_cmd_read)begin
            case(icb.icb_cmd_addr)
              CTRL_ADDR: begin icb.icb_rsp_rdata <= {63'h000000000000000,ctrl};      end
              STAT_ADDR: begin icb.icb_rsp_rdata <= {58'h000_0000_0000_0000,stat};   end
              WDATA_ADDR:begin icb.icb_rsp_rdata <= wdata;                           end
              RDATA_ADDR:begin icb.icb_rsp_rdata <= rdata;                           end
              KEY_ADDR:  begin icb.icb_rsp_rdata <= key;                             end
              default    begin icb.icb_rsp_rdata <= 64'h0000_0000_0000_0000;         icb.icb_rsp_err   <= 1;  end
            endcase
              icb.icb_rsp_valid <= 1;
              icb.icb_cmd_ready <= 1; 

           end else begin

             case(icb.icb_cmd_addr)
           CTRL_ADDR: begin ctrl  <= icb.icb_cmd_wdata[0];          end
           STAT_ADDR: begin icb.icb_rsp_err   <= 1;                 end      //stat不可写
           WDATA_ADDR:begin
             WFIFO_wr_en <= 1;
             for(int i = 0,j = 0; i < 64 ; i = i + 1,j=i/8)begin
                 if(icb.icb_cmd_wmask[j])begin
                    wdata[i] <= 1'b0;                           //如果这8位对应的掩码为1，这些位变为0
                    decrypt_wdata[i] <= 1'b0;
                 end else begin
                    wdata[i] <= icb.icb_cmd_wdata[i];          //如果不对应1，则输入得到的数据
                    decrypt_wdata[i] <= icb.icb_cmd_wdata[i];
             end
            end
          end
          RDATA_ADDR:icb.icb_rsp_err   <= 1;     //rdata不可写
          KEY_ADDR:begin
             for(int i = 0,j = 0; i < 64 ; i = i + 1,j=$floor(i/8))begin
                 if(icb.icb_cmd_wmask[j])begin
                    key[i] <= 0;                              //如果这8位对应的掩码为1，这些位变为0
                    key0[i] <= 0;
                 end else begin
                    key[i] <= icb.icb_cmd_wdata[i];          //如果不对应1，则输入得到的数据
                    key0[i] <= icb.icb_cmd_wdata[i];
             end
           end
          end
           default    icb.icb_rsp_err   <= 1; 
           endcase
          icb.icb_rsp_valid <= 1;
          icb.icb_cmd_ready <= 1;
      end
      crnt_state <= nxt_state;
      end else begin
      end
    end

    always_ff @(posedge icb.clk) begin 
        if (crnt_state == REPLY && nxt_state == IDLE)begin
          icb.icb_rsp_valid <= 0;
          icb.icb_rsp_err <= 0;
          icb.icb_cmd_ready <= 1;
          WFIFO_wr_en <= 0;
       end
          crnt_state <= nxt_state;
    end


    always_ff @(posedge icb.clk) begin   //输入WFIFO、RFIFO、APB的状态
      stat <={WFIFO_full,WFIFO_empty,RFIFO_full,RFIFO_empty,apb_stat};
      icb.WFIFO_full<=WFIFO_full;
      icb.WFIFO_empty<=WFIFO_empty;
      icb.RFIFO_full<=RFIFO_full;
      icb.RFIFO_empty<=RFIFO_empty;
    end



    always_ff @(posedge icb.clk) begin 
     if(!RFIFO_empty && !RFIFO_rd_en)begin
        RFIFO_rd_en <= 1;
        rdata <= RFIFO_rdata;
     end else begin
      RFIFO_rd_en <= 0;
     end
    end

endmodule
