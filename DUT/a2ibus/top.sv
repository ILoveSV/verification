//===================================================================== 
/// Description: 
// this is the top file of our dut, this module should never be changed
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 
/* don't change the signal */
module dut_top(
    //input bus
    icb_bus.slave icb_bus,
    //ouput bus
    apb_bus.master apb_bus_0,
    apb_bus.master apb_bus_1,
    apb_bus.master apb_bus_2,
    apb_bus.master apb_bus_3
);
    // 内部信号声明
    
    logic [63:0] key0;
    logic [63:0] encrypt_rdata;
    logic [63:0] decrypt_wdata;
    logic [63:0] decrypt_WFIFO;
    logic [63:0] encrypt_RFIFO;

    logic [5:0]  stat0;
    logic [0:0]  ctrl;
    logic [31:0] addr;

    logic [31:0] wdata_mask;
    logic [23:0] fifo_addr;
    logic [1:0]  apb_stat;

    logic [63:0] WFIFO_wdata;
    logic [0:0]  WFIFO_full;
    logic [0:0]  WFIFO_empty;
    logic [0:0]  WFIFO_wr_en;
    logic [0:0]  WFIFO_wr_en_decrypt;
    logic [0:0]  WFIFO_rd_en;
    logic [0:0]  WFIFO_cnt;

    logic [63:0] RFIFO_rdata;
    logic [0:0]  RFIFO_full;
    logic [0:0]  RFIFO_empty;
    logic [0:0]  RFIFO_wr_en;
    logic [0:0]  RFIFO_wr_en_encrypt;
    logic [0:0]  RFIFO_rd_en;


    // 实例化ICB从机模块
    icb_slave icb_slave_inst (
        .icb(icb_bus), 
        .decrypt_wdata(decrypt_wdata),
        .RFIFO_rdata(RFIFO_rdata),
        .key0(key0),
        .WFIFO_wr_en(WFIFO_wr_en),
        .RFIFO_rd_en(RFIFO_rd_en),

        .RFIFO_empty(RFIFO_empty),
        .RFIFO_full(RFIFO_full),
        .WFIFO_empty(WFIFO_empty),
        .WFIFO_full(WFIFO_full),
        .apb_stat(apb_stat)
    );

    // 实例化APB主模块
    apb_master apb_master_inst (
        .apb_bus_0(apb_bus_0),
        .apb_bus_1(apb_bus_1),
        .apb_bus_2(apb_bus_2),
        .apb_bus_3(apb_bus_3),
        .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),

        .rd_en(WFIFO_rd_en),
        .WFIFO_cnt(WFIFO_cnt),
        .apb_stat(apb_stat),
        .RFIFO_wr_en(RFIFO_wr_en),
        .WFIFO_empty(WFIFO_empty),
        .WFIFO_wdata(WFIFO_wdata),
        .encrypt_rdata(encrypt_rdata)
    );

    // 实例化加密模块
    encrypt_module encrypt_inst (
      .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),
        .encrypt_rdata(encrypt_rdata),
        .RFIFO_wr_en(RFIFO_wr_en),
       .RFIFO_wr_en_encrypt(RFIFO_wr_en_encrypt),
        .key(key0),
       .encrypt_RFIFO(encrypt_RFIFO)
   );

     //实例化解密模块
   decrypt_module decrypt_inst (
        .clk(icb_bus.clk),
     .rst_n(icb_bus.rst_n),
        .decrypt_wdata(decrypt_wdata),
        .WFIFO_wr_en(WFIFO_wr_en),
        .WFIFO_wr_en_decrypt(WFIFO_wr_en_decrypt),
        .key(key0),
        .decrypt_WFIFO(decrypt_WFIFO)
    );

    // 实例化FIFO模块
    decrypt_WFIFO wfifo_inst (
        .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),
        .WFIFO_wdata(WFIFO_wdata),
        .decrypt_WFIFO(decrypt_WFIFO),
        .rd_en(WFIFO_rd_en), 
        .wr_en(WFIFO_wr_en_decrypt),
        .WFIFO_empty(WFIFO_empty),
        .WFIFO_full(WFIFO_full),
        .fifo_cnt(WFIFO_cnt)
    );

    encrypt_RFIFO rfifo_inst (
        .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),
        .RFIFO_rdata(RFIFO_rdata),
        .encrypt_RFIFO(encrypt_RFIFO),
        .rd_en(RFIFO_rd_en), 
        .wr_en(RFIFO_wr_en_encrypt), 
        .RFIFO_full(RFIFO_full),
        .RFIFO_empty(RFIFO_empty),
        .fifo_cnt()
    );
    
/*
    DES_TOP en_DES(
        .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),
        .wr_en(RFIFO_wr_en),
        .wr_en_FIFO(RFIFO_wr_en_encrypt),
        .data(encrypt_rdata),
        .key(key0),
        .result(encrypt_RFIFO)
    );

    DES_TOP de_DES(
        .clk(icb_bus.clk),
        .rst_n(icb_bus.rst_n),
        .wr_en(WFIFO_wr_en),
        .wr_en_FIFO(WFIFO_wr_en_decrypt),
        .data(decrypt_wdata),
        .key(key0),
        .result(decrypt_WFIFO)
   );
*/

endmodule



