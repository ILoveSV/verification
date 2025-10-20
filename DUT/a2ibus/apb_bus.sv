//===================================================================== 
/// Description: 
// the interface of apb
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 
/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface apb_bus(input logic clk,input logic rst_n);
    logic pwrite;
    logic psel;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic penable;
                                                     
    logic [31:0] prdata;
    logic pready;

    modport slave(
        clocking slv_cb,
        input pwrite,
        psel,
        paddr,
        pwdata,
        penable,
        clk,
        rst_n,
        output prdata,
        pready
        );
    modport master(
        clocking mst_cb,
        output pwrite,
        psel,
        paddr,
        pwdata,
        penable,
      input prdata,
      pready,
      clk,
      rst_n);
    modport others (
        input    clk,
        input    rst_n,
        input  psel,
        input  paddr,
        input  pwdata,
        input  pwrite,
        input  penable,
        input  pready,
        input  prdata
    );


    // Clocking block for the master side
    clocking mst_cb @(posedge clk);
    default input #0.25 output #0.25;
        output pwrite, psel, paddr, pwdata, penable;
        input prdata, pready;
    endclocking

    // Clocking block for the slave side
    clocking slv_cb @(posedge clk);
    default input #0.25 output #0.25;
        input pwrite, psel, paddr, pwdata, penable;
        output prdata, pready;
    endclocking
endinterface:apb_bus //apb    

module apb_master (
    apb_bus.master apb_bus_0,
    apb_bus.master apb_bus_1,
    apb_bus.master apb_bus_2,
    apb_bus.master apb_bus_3,
    input logic [63:0] WFIFO_wdata,
    input clk,rst_n,
    input WFIFO_empty,
    input WFIFO_cnt,
    output logic RFIFO_wr_en,
    output logic rd_en,
    output logic [63:0] encrypt_rdata,
    output logic [1:0]apb_stat
);
    parameter IDLE = 0,SETUP = 1,ACCESS = 2;
    logic [1:0] crnt_state = 0;
    logic [1:0] nxt_state = 0;
    logic [2:0] sel;
    logic [63:0] init = 0;

    always_ff @(posedge clk or negedge rst_n) begin  //状态机部分
         if (!rst_n) begin   //复位的情况
            sel <= 0;
            apb_bus_0.psel <= 0;
            apb_bus_0.penable <= 0;
            apb_bus_0.pwrite <= 0;
            apb_bus_0.paddr <= 0;
            apb_bus_0.pwdata <= 0;
             apb_bus_1.psel <= 0;
            apb_bus_1.penable <= 0;
            apb_bus_1.pwrite <= 0;
            apb_bus_1.paddr <= 0;
            apb_bus_1.pwdata <= 0;
             apb_bus_2.psel <= 0;
            apb_bus_2.penable <= 0;
            apb_bus_2.pwrite <= 0;
            apb_bus_2.paddr <= 0;
            apb_bus_2.pwdata <= 0;
             apb_bus_3.psel <= 0;
            apb_bus_3.penable <= 0;
            apb_bus_3.pwrite <= 0;
            apb_bus_3.paddr <= 0;
            apb_bus_3.pwdata <= 0;
            init <= 16;
            apb_stat <= 2'b00;
            rd_en <= 0;
        end            
        else begin          
            case (crnt_state)
                IDLE: begin
                    RFIFO_wr_en <= 0;
                    apb_stat <= 2'b00;
                    if(init)begin
                       init <= init - 1;
                    end else                    
                    if (!WFIFO_empty ) begin
                        rd_en <= 1;

                    end else begin

                    end
                end
                SETUP: begin
                    RFIFO_wr_en <= 0;
                        rd_en <= 0;
                    if(WFIFO_wdata[1])begin
                        apb_stat <= 2'b10;
                    end else begin
                        apb_stat <= 2'b01;
                    end

                end
                ACCESS: begin
                        rd_en <= 0;
                    if (apb_bus_0.pready) begin

                        apb_bus_0.psel<=0;
                        apb_bus_0.penable <= 0;
                        sel <= 0;
                    end else if (apb_bus_1.pready) begin

                        apb_bus_1.psel<=0;
                        apb_bus_1.penable <= 0;
                        sel <= 0;
                    end else if (apb_bus_2.pready) begin

                        apb_bus_2.psel<=0;
                        apb_bus_2.penable <= 0;
                        sel <= 0;
                    end else if (apb_bus_3.pready) begin

                        apb_bus_3.psel<=0;
                        apb_bus_3.penable <= 0;
                        sel <= 0;
                    end 
                    else begin

                    end
                end
            endcase
            crnt_state <= nxt_state;
        end

    end
        
    always_comb begin 
            case (crnt_state)
                IDLE: begin
               if(init)begin
               end else
                    if (!WFIFO_empty) begin

                        nxt_state <= SETUP;
                    end else begin
                        nxt_state <= IDLE;
                    end
                end
                SETUP: begin
                    if(sel != 0)begin
                        nxt_state <= ACCESS;
                    end else begin
                        nxt_state <= SETUP;
                    end
                end
                ACCESS: begin
                    if (apb_bus_0.pready) begin
                        nxt_state <= IDLE;

                    end else if (apb_bus_1.pready) begin
                        nxt_state <= IDLE;

                    end else if (apb_bus_2.pready) begin
                        nxt_state <= IDLE;

                    end else if (apb_bus_3.pready) begin
                        nxt_state <= IDLE;

                    end 
                    else begin
                        nxt_state <= ACCESS;
                    end
                end
            endcase
        end

        


    always_ff @(posedge clk ) begin //SETUP状态
        if(crnt_state == SETUP)begin
        case(WFIFO_wdata[7:2])          //仲裁部分
        6'b000001:begin 
            sel <= 1;
            apb_bus_0.psel<=1;

            apb_bus_0.pwrite <= WFIFO_wdata[1];
            apb_bus_0.paddr  <= {8'h00,WFIFO_wdata [31:8]}; 
            end
        6'b000010:begin
            sel <= 2;
            apb_bus_1.psel<=1;

            apb_bus_1.pwrite <= WFIFO_wdata[1];
            apb_bus_1.paddr  <= {8'h00,WFIFO_wdata [31:8]}; 
            end
        6'b000100:begin
            sel <= 3;
            apb_bus_2.psel<=1;

            apb_bus_2.pwrite <= WFIFO_wdata[1];
            apb_bus_2.paddr  <= {8'h00,WFIFO_wdata [31:8]}; 
            end
        6'b001000:begin
            sel <= 4;
            apb_bus_3.psel<=1;

            apb_bus_3.pwrite <= WFIFO_wdata[1];
            apb_bus_3.paddr  <= {8'h00,WFIFO_wdata [31:8]}; 
            end
        endcase

        end
    end
    always_ff @(posedge clk ) begin //ACCESS状态
        if(crnt_state == ACCESS)begin
           case(sel)
            1:begin 
                apb_bus_0.penable <= 1;
                if(WFIFO_wdata [1])begin                          //如果是写过程 
                apb_bus_0.pwdata <= WFIFO_wdata [63:32];           //数据是写入数据包（后32位）的部分
                end else begin                                  //如果是读过程
                RFIFO_wr_en <= 1;
                encrypt_rdata <= {32'h00,apb_bus_0.prdata};
                end
            end
            2:begin 
                apb_bus_1.penable <= 1;   
                if(WFIFO_wdata [1])begin                          //如果是写过程
                apb_bus_1.pwdata <= WFIFO_wdata [63:32];           //数据是写入数据包（后32位）的部分
                end else begin
                RFIFO_wr_en <= 1;   
                encrypt_rdata <= {32'h00,apb_bus_1.prdata};
                end
            end
            3:begin 
                apb_bus_2.penable <= 1;
                if(WFIFO_wdata [1])begin                          //如果是写过程
                apb_bus_2.pwdata <= WFIFO_wdata [63:32];           //数据是写入数据包（后32位）的部分
                end else begin
                RFIFO_wr_en <= 1;
                encrypt_rdata <= {32'h00,apb_bus_2.prdata};
                end
            end
            4:begin 
                apb_bus_3.penable <= 1;
                if(WFIFO_wdata [1])begin                          //如果是写过程
                apb_bus_3.pwdata <= WFIFO_wdata [63:32];           //数据是写入数据包（后32位）的部分
                end else begin
                RFIFO_wr_en <= 1;
                encrypt_rdata <= {32'h00,apb_bus_3.prdata};
                end
            end
            endcase
        end
    end

endmodule : apb_master


