//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #1 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_regs.v#1 $ 
//
//
// File    : DW_apb_i2c_regs.v
//
//
// Author  : Madhusudhan Prabhu
// Created : Thu Nov 05 00:47:12 IST 2015
// Abstract: The register module used for registering the signals. This is used for
//           avoiding the scenario in which the same file has the logic corresponding 
//           to two clocks i.e. pclk and ic_clk.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_regs (
    clk,
    resetn,
    data_in,
    data_r_out
);

parameter DATA_WIDTH = 1;

input                   clk;
input                   resetn;
input  [DATA_WIDTH-1:0] data_in;
output [DATA_WIDTH-1:0] data_r_out;

  reg  [DATA_WIDTH-1:0]  data_r;


  always @(posedge clk or negedge resetn)
  begin : i2c_reg_PROC
    if (resetn == 1'b0) begin
      data_r <= {(DATA_WIDTH){1'b0}};
    end else begin
      data_r <= data_in;
    end
  end

  assign data_r_out = data_r; 

endmodule



//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm99.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm99.v#3 $
// Author      : Liming SU    06/19/15
// Description : DW_apb_i2c_bcm99.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: ace7615a
//
////////////////////////////////////////////////////////////////////////////////

module DW_apb_i2c_bcm99 (
  clk_d,
  rst_d_n,
  data_s,
  data_d
);

parameter ACCURATE_MISSAMPLING = 0; // RANGE 0 to 1

input  clk_d;      // clock input from destination domain
input  rst_d_n;    // active low asynchronous reset from destination domain
input  data_s;     // data to be synchronized from source domain
output data_d;     // data synchronized to destination domain

`ifdef SYNTHESIS
//######################### NOTE ABOUT TECHNOLOGY CELL MAPPING ############################
// Replace code between "DOUBLE FF SYNCHRONIZER BEGIN" and "DOUBLE FF SYNCHRONIZER END"
// with one of the following two options of customized register cell(s):
//   Option 1: One instance of a 2-FF cell
//     Macro cell must have an instance name of "sample_meta".
//
//     Example: (TECH_SYNC_2FF is example name of a synchronizer macro cell found in a technology library)
//         TECH_SYNC_2FF sample_meta ( .D(data_s), .CP(clk_d), .RSTN(rst_d_n), .Q(data_d) );
//     
//   Option 2: Two instances of single-FF cells connected serially 
//     The first stage synchronizer cell must have an instance name of "sample_meta".
//     The second stage synchronizer cell must have an instance name of "sample_syncl".
//
//     Example: (in GTECH)
//         wire n9;
//         GTECH_FD2 sample_meta ( .D(data_s), .CP(clk_d), .CD(rst_d_n), .Q(n9) );
//         GTECH_FD2 sample_syncl ( .D(n9), .CP(clk_d), .CD(rst_d_n), .Q(data_d) );
//
//####################### END NOTE ABOUT TECHNOLOGY CELL MAPPING ##########################
// DOUBLE FF SYNCHRONIZER BEGIN
  reg sample_meta;
  reg sample_syncl;
  always @(posedge clk_d or negedge rst_d_n) begin : a1000_PROC
    if (!rst_d_n) begin
      sample_meta <= 1'b0;
      sample_syncl <= 1'b0;
    end else begin
      sample_meta <= data_s;
      sample_syncl <= sample_meta;
    end
  end
  assign data_d = sample_syncl;
// DOUBLE FF SYNCHRONIZER END
`else
  `ifndef DW_MODEL_MISSAMPLES
//#####################################################################################
// NOTE: This section is for zero-time delay functional simulation
//#####################################################################################
  reg sample_meta;
  reg sample_syncl;
  always @(posedge clk_d or negedge rst_d_n) begin : a1001_PROC
    if (!rst_d_n) begin
      sample_meta <= 1'b0;
      sample_syncl <= 1'b0;
    end else begin
      sample_meta <= data_s;
      sample_syncl <= sample_meta;
    end
  end
  assign data_d = sample_syncl;
  `else
  localparam WIDTH = 1;


  `ifdef DW_MODEL_MISSAMPLES


// { START Latency Accurate modeling
  initial begin : set_setup_hold_delay_PROC
    `ifndef DW_HOLD_MUX_DELAY
      `define DW_HOLD_MUX_DELAY  1
      if (ACCURATE_MISSAMPLING == 1)
        $display("Information: %m: *** Warning: `DW_HOLD_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_HOLD_MUX_DELAY);
    `endif

    `ifndef DW_SETUP_MUX_DELAY
      `define DW_SETUP_MUX_DELAY  1
      if (ACCURATE_MISSAMPLING == 1)
        $display("Information: %m: *** Warning: `DW_SETUP_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_SETUP_MUX_DELAY);
    `endif
  end // set_setup_hold_delay_PROC


  reg [WIDTH-1:0] setup_mux_ctrl, hold_mux_ctrl;
  initial setup_mux_ctrl = {WIDTH{1'b0}};
  initial hold_mux_ctrl  = {WIDTH{1'b0}};
  
  wire [WIDTH-1:0] data_s_q;
  reg clk_d_q;
  initial clk_d_q = 1'b0;
  reg [WIDTH-1:0] setup_mux_out, d_muxout;
  reg [WIDTH-1:0] d_ff1, d_ff2;
  integer i,j,k;
  
  
  //Delay the destination clock
  always @ (posedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b1;

  always @ (negedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b0;
  
  //Delay the source data
  assign #`DW_SETUP_MUX_DELAY data_s_q = (!rst_d_n) ? {WIDTH{1'b0}}:data_s;

  //setup_mux_ctrl controls the data entering the flip flop 
  always @ (data_s or data_s_q or setup_mux_ctrl) begin
    for (i=0;i<=WIDTH-1;i=i+1) begin
      if (setup_mux_ctrl[i])
        setup_mux_out[i] = data_s_q[i];
      else
        setup_mux_out[i] = data_s;
    end
  end

  always @ (posedge clk_d_q or negedge rst_d_n) begin
    if (rst_d_n == 1'b0)
      d_ff2 <= {WIDTH{1'b0}};
    else
      d_ff2 <= setup_mux_out;
  end

  always @ (posedge clk_d or negedge rst_d_n) begin
    if (rst_d_n == 1'b0) begin
      d_ff1          <= {WIDTH{1'b0}};
      setup_mux_ctrl <= {WIDTH{1'b0}};
      hold_mux_ctrl  <= {WIDTH{1'b0}};
    end
    else begin
      d_ff1          <= setup_mux_out;
    `ifdef DWC_BCM_SV
      setup_mux_ctrl <= $urandom;  //randomize mux_ctrl
      hold_mux_ctrl  <= $urandom;  //randomize mux_ctrl
    `else
      setup_mux_ctrl <= $random;  //randomize mux_ctrl
      hold_mux_ctrl  <= $random;  //randomize mux_ctrl
    `endif
    end
  end


//hold_mux_ctrl decides the clock triggering the flip-flop
always @(hold_mux_ctrl or d_ff2 or d_ff1) begin
      for (k=0;k<=WIDTH-1;k=k+1) begin
        if (hold_mux_ctrl[k])
          d_muxout[k] = d_ff2[k];
        else
          d_muxout[k] = d_ff1[k];
      end
end
// END Latency Accurate modeling }


 //Assertions
`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS
generate if (ACCURATE_MISSAMPLING==1) begin : GEN_ASSERT_FST2_VE5
  sequence p_num_d_chng;
  @ (posedge clk_d) 1'b1 ##0 (data_s != d_ff1); //Number of times input data changed
  endsequence
  
  sequence p_num_d_chng_hmux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))); //Number of times hold_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_num_d_chng_smux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))); //Number of times setup_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_hold_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(hold_mux_ctrl & (data_s ^ d_ff1))) ##1 ((data_d & temp_var1) == (temp_var & temp_var1));
          //Number of times output data was advanced due to hold violation
  endsequence
  
  sequence p_setup_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(setup_mux_ctrl & (data_s ^ d_ff1))) ##2 ((data_d & temp_var1) != (temp_var & temp_var1));
          //Number of times output data was delayed due to setup violation
  endsequence

  cp_num_d_chng           : cover property  (p_num_d_chng);    
  cp_num_d_chng_hld_mux1  : cover property  (p_num_d_chng_hmux1);
  cp_num_d_chng_set_mux1  : cover property  (p_num_d_chng_smux1);
  cp_hold_vio             : cover property  (p_hold_vio);
  cp_setup_vio            : cover property  (p_setup_vio);        
 end
endgenerate
`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

  `endif

  generate if (ACCURATE_MISSAMPLING == 1) begin : GEN_DATA_PRE_AM_EQ_1
    reg sample_syncl;
    always @(posedge clk_d or negedge rst_d_n) begin : a1002_PROC
      if (!rst_d_n)
        sample_syncl <= 1'b0;
      else
        sample_syncl <= d_muxout;
    end
    assign data_d = sample_syncl;
  end else begin : GEN_DATA_PRE_AM_EQ_0
    reg sample_meta;
    reg sample_syncl;
    always @(posedge clk_d or negedge rst_d_n) begin : a1003_PROC
      if (!rst_d_n) begin
        sample_meta  <= 1'b0;
        sample_syncl <= 1'b0;
      end else begin
        sample_meta  <= data_s;
        sample_syncl <= sample_meta;
      end
    end
    assign data_d = sample_syncl;
  end endgenerate
  `endif
`endif

endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #10 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_dma.v#10 $ 
//
//
// File    : DW_apb_i2c_dma.v
//
//
// Abstract: DMA interface for DW_apb_i2c macrocell.
//
//        1: Generates DMA requests and controls all DMA signals 
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

module DW_apb_i2c_dma (
   pclk,
   presetn,
   ic_enable,
   tx_full,
   rx_empty,
   ic_txflr,
   ic_rxflr,
   ic_dma_cr,
   ic_dma_tdlr,
   ic_dma_rdlr,
   tx_fifo_rst_n,
   dma_tx_ack,
   dma_rx_ack,
   dma_tx_req,
   dma_rx_req,
   dma_tx_single,
   dma_rx_single
);


  input                           pclk;          // APB clock
  input                           presetn;       // APB async reset
  input                           tx_full;       // tx fifo full
  input                           rx_empty;      // tx fifo empty
  input               [`TX_ABW:0] ic_txflr;         // tx fifo level
  input               [`RX_ABW:0] ic_rxflr;         // rx fifo level
  input                           dma_tx_ack;    // end of tx dma burst
  input                           dma_rx_ack;    // end of rx dma burst
  input                     [1:0] ic_dma_cr;     // dma control register
  input             [`TX_ABW-1:0] ic_dma_tdlr;   // dma tx data level register
  input             [`RX_ABW-1:0] ic_dma_rdlr;   // dma rx data level register
  input       [`IC_ENABLE_RS_INT-1:0] ic_enable;     // Nothing can happen until block is enabled
  input                           tx_fifo_rst_n; // Tx FIFO Reset

  output                          dma_tx_req;    // tx dma request
  output                          dma_rx_req;    // rx dma request
  output                          dma_tx_single; // tx dma single status
  output                          dma_rx_single; // rx dma single status

  // ------------------------------------------------------
  // -- local registers and wires
  // ------------------------------------------------------
  wire                            set_rx_req;
  wire                            set_tx_req;
  wire                            ic_enable_0;
  wire                            ic_dma_cr_0;
  wire                            ic_dma_cr_1;
 
  reg                             dma_tx_req;
  reg                             dma_rx_req;
  reg                             dma_tx_single;
  reg                             dma_rx_single;
  reg                             clear_rx, clear_tx;

  // --------------------------------------------------------
  // -- DMA single status output generation
  //
  // -- output control for 'dma_tx_single' & 'dma_rx_single'
  // --------------------------------------------------------

//#
//# clear_rx and clear_tx are used to clear the request lines
//# The rules of clearing the request lines are as follows
//#   1. Whenever the module is not enabled there should be no requests
//#   2. Whenever the relevant control register bit is not set there should be no corresponding request
//#   3. Whenever there is a corresponding acknowledge, the request should pulse.
//#
  
  assign ic_enable_0 = ic_enable[0];
  assign ic_dma_cr_0 = ic_dma_cr[0];
  assign ic_dma_cr_1 = ic_dma_cr[1];

  always @(ic_enable_0 or ic_dma_cr_0 or dma_rx_ack)
  begin : CLEAR_RX_PROC
    if (ic_enable_0 == 1'b0) begin
      clear_rx = 1'b1;
    end else begin
      if (ic_dma_cr_0 == 1'b0) begin
        clear_rx = 1'b1;
      end else begin
        clear_rx = dma_rx_ack;
      end
    end
  end
   
  always @(ic_enable_0 or ic_dma_cr_1 or dma_tx_ack)
  begin : CLEAR_TX_PROC
    if (ic_enable_0 == 1'b0) begin
      clear_tx = 1'b1;
    end else begin
      if (ic_dma_cr_1 == 1'b0) begin
        clear_tx = 1'b1;
      end else begin
        clear_tx = dma_tx_ack;
      end
    end
  end

//#
//# The single rx request is active provided there is an entry in the rx-fifo which can be read by DMA.
//# The single tx request is active provided there is a location availale in the tx-fifo for another DMA transmit character.
//#

  always @(posedge pclk or negedge presetn) begin : DMA_SINGLE_R_PROC
    if(presetn == 1'b0) begin
      dma_tx_single <= 1'b0;
      dma_rx_single <= 1'b0;
    end else begin
      if (clear_rx == 1'b1) begin
        dma_rx_single <= 1'b0;
      end else begin
        if (rx_empty == 1'b0) begin
          dma_rx_single <= 1'b1;
        end
      end
      
      if (clear_tx == 1'b1) begin
        dma_tx_single <= 1'b0;
      end else begin
        if (tx_full == 1'b0) begin
          dma_tx_single <= 1'b1;
        end
      end
    end
  end

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression present in the design.
//SJ:  This Self Determined Expression is as per the design requirement. 
//     There will not be any functional issue.
//#
//# The same method is used for clearing the requests.
//# The setting of the request depends on the thresholds matching.
//# When a request is active a block of writes will be performed.
//#
  assign set_rx_req = (ic_rxflr >= ({1'b0,ic_dma_rdlr} + {{(`RX_ABW){1'b0}},1'b1}));
  //assign set_tx_req = (ic_txflr <= ic_dma_tdlr);
  // CRM_9000530770
  assign set_tx_req = (ic_txflr <= {1'b0,ic_dma_tdlr}) & tx_fifo_rst_n & (~ic_enable[`IC_ENABLE_RS_INT-1]);
//spyglass enable_block SelfDeterminedExpr-ML

//#
//# DMA channel request output generation for 'dma_tx_req' & 'dma_rx_req'
//#
  always @(posedge pclk or negedge presetn) begin : DMA_REQ_R_PROC
    if(presetn == 1'b0) begin
      dma_tx_req <= 1'b0;
      dma_rx_req <= 1'b0;
    end else begin
      if(clear_rx == 1'b1) begin
        dma_rx_req <= 1'b0;
      end else begin
        if(set_rx_req == 1'b1) begin
          dma_rx_req <= 1'b1;
        end
      end
      
      if(clear_tx == 1'b1) begin
        dma_tx_req <= 1'b0;
      end else begin
        if(set_tx_req == 1'b1) begin
          dma_tx_req <= 1'b1;
        end
      end
    end
  end
   
endmodule

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm47.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm47.v#5 $
// Author      : Bruce Dean      May 01, 2004
// Description : DW_apb_i2c_bcm47.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: ddf794e1
//
////////////////////////////////////////////////////////////////////////////////
module DW_apb_i2c_bcm47 (
     clk,         
     rst_n,       
     init_n,      
     enable,      
     drain,       
     ld_crc_n,    
     data_in,     
     crc_in,      
     draining,    
     drain_done,  
     crc_ok,      
     data_out,    
     crc_out     
    );
    
parameter DATA_WIDTH = 16;
parameter POLY_SIZE  = 16;
parameter CRC_CFG    = 7;
parameter BIT_ORDER  = 3;
parameter POLY_COEF0 = 4129;
parameter POLY_COEF1 = 0;
parameter POLY_COEF2 = 0;
parameter POLY_COEF3 = 0;

localparam              ODD_WIDTH_OFFSET = ((DATA_WIDTH & 1) == 1)? DATA_WIDTH : 0;
localparam              POLY_2_DATA_RATIO = POLY_SIZE/DATA_WIDTH;
localparam [ 4 : 0]     INITIAL_POINTER   = POLY_SIZE/DATA_WIDTH;

localparam [63 : 0] tp =                ((POLY_COEF3 & 65535) << 48) +
                                        ((POLY_COEF2 & 65535) << 32) +
                                        ((POLY_COEF1 & 65535) << 16) +
                                         (POLY_COEF0 & 65535);

   
input                  clk;       
input                  rst_n;     
input                  init_n;    
input                  enable;    
input                  drain;     
input                  ld_crc_n; 
input [DATA_WIDTH-1:0] data_in;  
input [POLY_SIZE-1:0]  crc_in;   
   
output                  draining;     
output                  drain_done;   
output                  crc_ok;
output [DATA_WIDTH-1:0] data_out;
output [POLY_SIZE-1:0]  crc_out;

reg [4:0]   data_pointer;

reg                   drain_done_next;
reg                   crc_ok_int;
reg                   drain_done_int;
reg                   draining_status;
reg                   draining_status_next;

reg  [DATA_WIDTH-1:0] data_out_next;
reg  [DATA_WIDTH-1:0] data_out_int;

wire [POLY_SIZE-1:0]  crc_out_int;
reg  [POLY_SIZE-1:0]  crc_out_rg;
reg  [POLY_SIZE-1:0]  crc_out_next;
reg  [POLY_SIZE-1:0]  crc_out_temp;

wire                  crc_ok_result;

wire [4:0]   data_pointer_next;
wire [3:0]   data_pointer_minus_1;

wire [DATA_WIDTH-1:0] crc_drn_dat;
wire [DATA_WIDTH-1:0] data_in_ro;
wire [DATA_WIDTH-1:0] crc_xor_res;
wire [DATA_WIDTH-1:0] crc_ins_mask;
wire [DATA_WIDTH-1:0] crc_xord_swaped; 

wire [POLY_SIZE-1:0]  crc_result;
wire [POLY_SIZE-1:0]  crc_out_next_shifted;
wire [POLY_SIZE-1:0]  crc_ok_remn;
wire [POLY_SIZE-1:0]  crc_xor_constant;
wire [POLY_SIZE-1:0]  reset_crc_reg;

  // This function generates the remainder
  // to be used in the crc ok generation
  function [POLY_SIZE-1:0] gen_crc_rem;
   input [POLY_SIZE-1:0]  crc_xor_constant;
   begin : FUNC_CRC_OK_NFO 
    reg [POLY_SIZE-1:0]  int_ok_calc;
    reg                  xor_or_not;
    integer              i;
    int_ok_calc = crc_xor_constant;
    for(i = 0; i < POLY_SIZE; i = i + 1) begin 
      xor_or_not  = int_ok_calc[(POLY_SIZE-1)];
      int_ok_calc = { int_ok_calc[((POLY_SIZE-1)- 1):0], 1'b0};
      if(xor_or_not == 1'b1)
       int_ok_calc = (int_ok_calc ^ tp[POLY_SIZE-1:0]);
     end
     
     gen_crc_rem = int_ok_calc;
    end
   endfunction


   // This function caculates the crc on a data word sized chunk
   // by checking if the msb is a one, and iff then xor the data
   // with the crc polynomial from the parameters
   function [POLY_SIZE-1:0] fcalc_crc;
    input [DATA_WIDTH-1:0] data_ro_in;
    input [POLY_SIZE-1:0]  crc_fb_data;
    input                  draining_status;
    begin : FUNC_CALC_CRC
     reg [DATA_WIDTH-1:0] fdata_in;
     reg [POLY_SIZE-1:0]  crc_data;
     reg                  xor_or_not;
     integer              i;
     crc_data  = crc_fb_data ;
     fdata_in  = data_ro_in;
     for (i = 0;i < DATA_WIDTH; i = i + 1 ) begin 
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
       xor_or_not = !draining_status & (fdata_in[(DATA_WIDTH-1) - i]
                                       ^ crc_data[(POLY_SIZE-1)]);
// spyglass enable_block SelfDeterminedExpr-ML
       if(xor_or_not == 1'b1)
        crc_data = ({crc_data [((POLY_SIZE-1)-1):0],1'b0 } ^ tp[POLY_SIZE-1:0]);
       else
        crc_data   = {crc_data [((POLY_SIZE-1)-1):0],1'b0 };
      end
      fcalc_crc = crc_data ;
     end
   endfunction


   // This function re-orders the bits/bytes of data according
   // to the parameters passed through.
   function [DATA_WIDTH-1:0] fdata_ro0;
    input [DATA_WIDTH-1:0] data_ro_in;
    begin : FUNC_REORDER_DATA
     reg   [DATA_WIDTH-1:0] data_ro_out;
     integer             i;

      for (i = 0; i < DATA_WIDTH; i = i+1) begin
        data_ro_out[i] = data_ro_in[i];
      end
      fdata_ro0 = data_ro_out;
     end
   endfunction


   // This function directly reverse ordering of bits of data according
   // to the parameters passed through.
   function [DATA_WIDTH-1:0] fdata_ro1;
    input [DATA_WIDTH-1:0] data_ro_in;
    begin : FUNC_REORDER_DATA
     reg   [DATA_WIDTH-1:0] data_ro_out;
     integer             i,j;

      for (i = 0; i < DATA_WIDTH; i = i+1) begin
          j              = DATA_WIDTH - 1 - i;
          data_ro_out[i] = data_ro_in[j];
      end
      fdata_ro1 = data_ro_out;
     end
   endfunction


   // This function re-orders the bits/bytes of data according
   // to the parameters passed through using:
   // byte reverse, bit forward ordering
   function [DATA_WIDTH-1:0] fdata_ro2;
    input [DATA_WIDTH-1:0] data_ro_in;
    begin : FUNC_REORDER_DATA
     reg   [DATA_WIDTH-1:0] data_ro_out;
     integer             i,j;

      for (i = 0; i < DATA_WIDTH; i = i+1) begin
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
          j              = (i & 7) + (((DATA_WIDTH>>3)-1 - (i>>3))<<3);
// spyglass enable_block SelfDeterminedExpr-ML
          data_ro_out[i] = data_ro_in[j];
      end
      fdata_ro2 = data_ro_out;
     end
   endfunction


   // This function re-orders the bits/bytes of data according
   // to the parameter passed through using:
   // byte forward, bit reverse ordering
   function [DATA_WIDTH-1:0] fdata_ro3;
    input [DATA_WIDTH-1:0] data_ro_in;
    begin : FUNC_REORDER_DATA
     reg   [DATA_WIDTH-1:0] data_ro_out;
     integer             i,j;

      for (i = 0; i < DATA_WIDTH; i = i+1) begin
          j              = (i | 7)-(i & 7);
          data_ro_out[j] = data_ro_in[i];
      end
      fdata_ro3 = data_ro_out;
     end
   endfunction


  // This function will left-shift the input data by a number of bits
  // that specified by the parameter.
  function [POLY_SIZE-1:0] fshift_crc_nxt;
   input  [POLY_SIZE-1:0] crc_out_fnc;
    begin : FSHIFT_CRC_NXT
     reg [POLY_SIZE-1:0] shifted_data;
     integer             i;
     shifted_data = crc_out_fnc;
     for (i = 0;i < DATA_WIDTH; i = i + 1)
       shifted_data = shifted_data << 1'b1; 

      fshift_crc_nxt =  shifted_data;
    end
  endfunction



generate
  if ((CRC_CFG & 6) == 0) begin : GEN_cfg_00x
    assign crc_xor_constant = {POLY_SIZE{1'b0}};
  end

  if (((CRC_CFG & 6) == 2) && ((POLY_SIZE & 1) == 0)) begin : GEN_cfg_01x_evn_ps
    assign crc_xor_constant = {(POLY_SIZE / 2){2'b01}} ;
  end

  if (((CRC_CFG & 6) == 2) && ((POLY_SIZE & 1) == 1)) begin : GEN_cfg_01x_odd_ps
    assign crc_xor_constant = {1'b1,{((POLY_SIZE-1)/2){2'b01}}};
  end

  if (((CRC_CFG & 6) == 4) && ((POLY_SIZE & 1) == 0)) begin : GEN_cfg_10x_evn_ps
    assign crc_xor_constant = {(POLY_SIZE / 2){2'b10}} ;
  end

  if (((CRC_CFG & 6) == 4) && ((POLY_SIZE & 1) == 1)) begin : GEN_cfg_10x_odd_ps
    assign crc_xor_constant = {1'b0,{((POLY_SIZE-1)/2){2'b10}}};
  end

  if ((CRC_CFG & 6) == 6) begin : GEN_cfg_11x
    assign crc_xor_constant = {POLY_SIZE{1'b1}};
  end
endgenerate

generate
  if ((CRC_CFG & 1) == 0) begin : GEN_crc_rst_zeros
    assign reset_crc_reg    = {POLY_SIZE{1'b0}};
  end

  if ((CRC_CFG & 1) == 1) begin : GEN_crc_rst_ones
    assign reset_crc_reg    = {POLY_SIZE{1'b1}};
  end
endgenerate


  assign crc_ok_remn      = gen_crc_rem(crc_xor_constant);

generate
  if (BIT_ORDER <= 0) begin : GEN_ORDER0
    assign data_in_ro           = fdata_ro0(data_in);
    assign crc_xord_swaped      = fdata_ro0 (crc_xor_res);
  end

  if (BIT_ORDER == 1) begin : GEN_ORDER1
    assign data_in_ro           = fdata_ro1(data_in);
    assign crc_xord_swaped      = fdata_ro1 (crc_xor_res);
  end

  if (BIT_ORDER == 2) begin : GEN_ORDER2
    assign data_in_ro           = fdata_ro2(data_in);
    assign crc_xord_swaped      = fdata_ro2 (crc_xor_res);
  end

  if (BIT_ORDER >= 3) begin : GEN_ORDER3
    assign data_in_ro           = fdata_ro3(data_in);
    assign crc_xord_swaped      = fdata_ro3 (crc_xor_res);
  end
endgenerate

  assign crc_out_next_shifted = fshift_crc_nxt(crc_out_int);
  assign crc_result           = fcalc_crc (data_in_ro, crc_out_int,
                                           draining_status_next);

generate
  if ((POLY_2_DATA_RATIO > 1) && ((DATA_WIDTH & 1) == 1)) begin : GEN_odd_ptrn
    assign crc_ins_mask         = (data_pointer_next[0] == 1'b0) ?
                                   crc_xor_constant[DATA_WIDTH*2-1:DATA_WIDTH]
                                   : crc_xor_constant[DATA_WIDTH-1:0];           
  end else                                               begin : GEN_reg_ptrn
    assign crc_ins_mask         = crc_xor_constant[DATA_WIDTH-1:0];              
  end
endgenerate
                                 
  assign crc_xor_res          = (crc_out_int[POLY_SIZE-1:POLY_SIZE-DATA_WIDTH]
                                 ^ crc_ins_mask);
  assign crc_drn_dat          = crc_xord_swaped;
  assign crc_ok_result        = (crc_out_temp == crc_ok_remn);
  assign data_pointer_minus_1 = data_pointer[3:0] - 4'b1;
  assign data_pointer_next    = ((draining & enable)==1'b1) ?
                                        ((data_pointer == 5'b0) ? 5'b0 : {1'b0, data_pointer_minus_1})
                                        : data_pointer;


  always @ (draining_status  or drain_done_int or data_pointer_next
            or crc_drn_dat or crc_out_next_shifted or drain
            or data_in or crc_result ) begin : gen_next_states_PROC
    if(draining_status == 1'b0) begin
      if((drain & (~drain_done_int)) == 1'b1) begin
        draining_status_next = 1'b1;
        data_out_next        = crc_drn_dat;
        crc_out_next         = crc_out_next_shifted;
        drain_done_next      = drain_done_int;
      end  
      else begin
        draining_status_next = 1'b0;
        data_out_next        = data_in ;
        crc_out_next         = crc_result;
        drain_done_next      = drain_done_int;
      end  
    end
    else begin 
      if(data_pointer_next == 5'b0) begin 
        draining_status_next = 1'b0 ;
        data_out_next        = data_in ;
        crc_out_next         = crc_result;
        drain_done_next      = 1'b1;
      end
      else begin
        draining_status_next = 1'b1 ;
        data_out_next        = crc_drn_dat ;
        crc_out_next         = crc_out_next_shifted;
        drain_done_next      = drain_done_int;
      end   
    end
    
   end

  always @ (crc_in or crc_out_next or ld_crc_n) begin : gen_crc_out_temp_PROC
    if(ld_crc_n == 1'b0) begin
      crc_out_temp      = crc_in;
    end
    else begin
      crc_out_temp      = crc_out_next;
    end    
   end
                                     
  always @ (posedge clk or negedge rst_n) begin : DW_crc_s_PROC
    if(rst_n == 1'b0) begin 
      data_pointer    <= INITIAL_POINTER ;
      crc_out_rg      <= {POLY_SIZE{1'b0}} ;
      data_out_int    <= {DATA_WIDTH{1'b0}} ;
      draining_status <= 1'b0 ;
      drain_done_int  <= 1'b0 ;
      crc_ok_int      <= 1'b0;
     end 
    else if(init_n == 1'b0) begin 
      data_pointer    <= INITIAL_POINTER ;
      crc_out_rg      <= {POLY_SIZE{1'b0}} ;
      data_out_int    <= {DATA_WIDTH{1'b0}} ;
      draining_status <= 1'b0 ;
      drain_done_int  <= 1'b0 ;
      crc_ok_int      <= 1'b0;
     end 
    else if(enable == 1'b1) begin
      draining_status <= draining_status_next;
      data_pointer    <= data_pointer_next ;
      data_out_int    <= data_out_next ;
      crc_out_rg      <= crc_out_temp ^ reset_crc_reg ;
      drain_done_int  <= drain_done_next ;
      crc_ok_int      <= crc_ok_result;
    end
   end


   assign crc_out_int = crc_out_rg ^ reset_crc_reg ;


   assign crc_out    = crc_out_int;
   assign draining   = draining_status;
   assign data_out   = data_out_int;
   assign crc_ok     = crc_ok_int;
   assign drain_done = drain_done_int;

   
   
endmodule

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm06.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm06.v#11 $
// Author      : Rick Kelly          04/14/04
// Description : DW_apb_i2c_bcm06.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: 20c6641c
//
////////////////////////////////////////////////////////////////////////////////

module DW_apb_i2c_bcm06 (
    clk,
    rst_n,
    init_n,
    push_req_n,
    pop_req_n,
    ae_level,
    af_thresh,
    we_n,
    empty,
    almost_empty,
    half_full,
    almost_full,
    full,
    error,
    wr_addr,
    rd_addr,
    wrd_count,
    nxt_empty_n,
    nxt_full,
    nxt_error
    );

parameter DEPTH  = 4;           // RANGE 2 to 16777216
parameter ERR_MODE  =  0 ;      // RANGE 0 to 2
parameter ADDR_WIDTH = 2;       // RANGE 1 to 24

input                   clk;            // Input Clock (pos edge)
input                   rst_n;          // Async reset (active low)
input                   init_n;         // Sync reset (active low) (FIFO clear/flush)
input                   push_req_n;     // Push request (active low)
input                   pop_req_n;      // Pop Request (active low)
input  [ADDR_WIDTH-1:0] ae_level;       // Almost empty level input bus
input  [ADDR_WIDTH-1:0] af_thresh;      // Almost full threshold input bus
output                  we_n;           // RAM Write Enable output (active low)
output                  empty;          // FIFO Empty flag output (active high)
output                  almost_empty;   // FIFO Almost Empty flag output (active high)
output                  half_full;      // FIFO Half Full flag output (active high)
output                  almost_full;    // FIFO almost Full flag output (active high)
output                  full;           // FIFO full flag output (active high)
output                  error;          // FIFO Error flag output (active high)
output [ADDR_WIDTH-1:0] wr_addr;        // RAM Write Address output bus
output [ADDR_WIDTH-1:0] rd_addr;        // RAM Read Address output bus
output [ADDR_WIDTH-1:0] wrd_count;      // Words in FIFO (not always accurate at full)
output                  nxt_empty_n;    // Look ahead empty flag (active low)
output                  nxt_full;       // Look ahead full flag
output                  nxt_error;      // Look ahead empty flag


wire                    next_empty_n;
reg                     empty_n;
wire                    next_almost_empty_n;
reg                     almost_empty_n;
wire                    next_half_full;
reg                     half_full_int;
wire                    next_almost_full;
reg                     almost_full_int;
wire                    next_full;
reg                     full_int;
wire                    next_error;
reg                     error_int;
wire [ADDR_WIDTH-1:0]   next_wr_addr;
reg  [ADDR_WIDTH-1:0]   wr_addr_int;
wire                    next_wr_addr_at_max;
reg                     wr_addr_at_max;
wire [ADDR_WIDTH-1:0]   next_rd_addr;
reg  [ADDR_WIDTH-1:0]   rd_addr_int;
wire                    next_rd_addr_at_max;
reg                     rd_addr_at_max;
wire [ADDR_WIDTH-1:0]   next_word_count;
reg  [ADDR_WIDTH-1:0]   word_count;
reg  [ADDR_WIDTH  :0]   advanced_word_count;

wire                    advance_wr_addr;
wire [ADDR_WIDTH+1:0]   advanced_wr_addr;
wire                    advance_rd_addr;
wire [ADDR_WIDTH+1:0]   advanced_rd_addr;
wire                    inc_word_count;
wire                    dec_word_count;

localparam [ADDR_WIDTH-1 : 0] LASTADDRESS   =  DEPTH - 1;
localparam [ADDR_WIDTH-1 : 0] HF_THRESH_VAL = (DEPTH + 1)/2;
localparam [ADDR_WIDTH   : 0] ADDRP1_SIZED_ONE = 1;
localparam [ADDR_WIDTH-1 : 0] ADDR_SIZED_ONE   = 1;

  assign we_n = push_req_n | (full_int & pop_req_n);


  assign advance_wr_addr = ~(push_req_n | (full_int & pop_req_n));

  assign advance_rd_addr = ~pop_req_n  & empty_n;


  assign advanced_wr_addr = {wr_addr_int,advance_wr_addr} + ADDRP1_SIZED_ONE;
  assign next_wr_addr = (wr_addr_at_max  &advance_wr_addr)?
                                {ADDR_WIDTH{1'b0}} :
                                advanced_wr_addr[ADDR_WIDTH:1];

  assign advanced_rd_addr = {rd_addr_int,advance_rd_addr} + ADDRP1_SIZED_ONE;

  assign next_rd_addr_at_max = ((next_rd_addr & LASTADDRESS) == LASTADDRESS)? 1'b1 : 1'b0;

  assign next_wr_addr_at_max = ((next_wr_addr & LASTADDRESS) == LASTADDRESS)? 1'b1 : 1'b0;

  assign inc_word_count = ~push_req_n & pop_req_n & (~full_int) |
                          (~push_req_n) & (~empty_n);

  assign dec_word_count = push_req_n & (~pop_req_n) & empty_n;

  always @ (word_count or dec_word_count) begin : infer_incdec_PROC
    if (dec_word_count)
      advanced_word_count = word_count - ADDR_SIZED_ONE;
    else
      advanced_word_count = word_count + ADDR_SIZED_ONE;
  end

  assign next_word_count = ((inc_word_count | dec_word_count) == 1'b0)?
                                word_count : advanced_word_count[ADDR_WIDTH-1:0];

  assign next_full =    ((word_count == LASTADDRESS)? ~push_req_n & pop_req_n : 1'b0) |
                        (full_int & push_req_n & pop_req_n) |
                        (full_int & (~push_req_n));

  assign next_empty_n = (next_word_count == {ADDR_WIDTH{1'b0}})? next_full : 1'b1;


  assign next_half_full = (next_word_count >= HF_THRESH_VAL)? 1'b1 : next_full;


generate
  if ((1<<ADDR_WIDTH) == DEPTH) begin : GEN_PWR2
    assign next_almost_empty_n = ~(((next_word_count <= ae_level)? 1'b1 : 1'b0) &
                                 (~next_full));
  end else begin : GEN_NOT_PWR2
    assign next_almost_empty_n = ~((next_word_count <= ae_level)? 1'b1 : 1'b0);
  end
endgenerate


  assign next_almost_full = (next_word_count >= af_thresh)? 1'b1 :
                                next_full;


generate
  if (ERR_MODE == 0) begin : GEN_EM_EQ0
  end
  
  if (ERR_MODE == 1) begin : GEN_EM_EQ1
    assign next_rd_addr =  (rd_addr_at_max & advance_rd_addr)?
                            {ADDR_WIDTH{1'b0}} : advanced_rd_addr[ADDR_WIDTH:1];
    assign next_error = (~pop_req_n & (~empty_n)) | (~push_req_n & pop_req_n & full_int) | error_int;
  end
  
  if (ERR_MODE == 2) begin : GEN_EM_EQ2
    assign next_rd_addr =  (rd_addr_at_max & advance_rd_addr)?
                            {ADDR_WIDTH{1'b0}} : advanced_rd_addr[ADDR_WIDTH:1];
    assign next_error = (~pop_req_n & (~empty_n)) | (~push_req_n & pop_req_n & full_int);
  end
endgenerate



// spyglass disable_block CheckDelayTimescale-ML
// SMD: Delay is used without defining timescale compiler directive
// SJ: The design incorporates delays for behavioral simulation. Timescale compiler directive is assumed to be defined in the test bench.
  always @ (posedge clk or negedge rst_n) begin : registers_PROC
    if (rst_n == 1'b0) begin
      empty_n          <=  1'b0;
      almost_empty_n   <=  1'b0;
      half_full_int    <=  1'b0;
      almost_full_int  <=  1'b0;
      full_int         <=  1'b0;
      error_int        <=  1'b0;
      wr_addr_int      <=  {ADDR_WIDTH{1'b0}};
      rd_addr_at_max   <=  1'b0;
      wr_addr_at_max   <=  1'b0;
      rd_addr_int      <=  {ADDR_WIDTH{1'b0}};
      word_count       <=  {ADDR_WIDTH{1'b0}};
    end else if (init_n == 1'b0) begin
      empty_n          <=  1'b0;
      almost_empty_n   <=  1'b0;
      half_full_int    <=  1'b0;
      almost_full_int  <=  1'b0;
      full_int         <=  1'b0;
      error_int        <=  1'b0;
      rd_addr_at_max   <=  1'b0;
      wr_addr_at_max   <=  1'b0;
      wr_addr_int      <=  {ADDR_WIDTH{1'b0}};
      rd_addr_int      <=  {ADDR_WIDTH{1'b0}};
      word_count       <=  {ADDR_WIDTH{1'b0}};
    end else begin
// spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ: This module can be specifically configured/implemented with only a synchronous reset or no resets at all.
      empty_n          <=  next_empty_n;
      almost_empty_n   <=  next_almost_empty_n;
      half_full_int    <=  next_half_full;
      almost_full_int  <=  next_almost_full;
      full_int         <=  next_full;
      error_int        <=  next_error;
      rd_addr_at_max   <=  next_rd_addr_at_max;
      wr_addr_at_max   <=  next_wr_addr_at_max;
      wr_addr_int      <=  next_wr_addr;
      rd_addr_int      <=  next_rd_addr;
      word_count       <=  next_word_count;
// spyglass enable_block STARC-2.3.4.3
    end
  end
// spyglass enable_block CheckDelayTimescale-ML

  assign empty = ~empty_n;
  assign almost_empty = ~almost_empty_n;
  assign half_full = half_full_int;
  assign almost_full = almost_full_int;
  assign full = full_int;
  assign error = error_int;
  assign wr_addr = wr_addr_int;
  assign rd_addr = rd_addr_int;
  assign wrd_count = word_count;
  assign nxt_empty_n = next_empty_n | (~init_n);
  assign nxt_full    = next_full    &  init_n;
  assign nxt_error   = next_error   &  init_n;

endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #28 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_rx_filter.v#28 $ 
//
//
// File    : DW_apb_i2c_rx_filter
//
//
// Author  : Hani Saleh
// Created : Sep, 2002
// Abstract: The rx_filter module is reponsible for filtering the
//           incoming SDA and SCL signals on the I2C Bus. This module
//           will also detect the START & STOP conditions,
//           when configured as MASTER
//           this module will determine if arbitration was lost.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_rx_filter
  (
   //top level signals
   ic_clk,
                              ic_rst_n,
                              ic_clk_in_a,
                              ic_data_in_a,
                              ic_data_oe,
                              //tx shift register signals
                              slv_tx_ack_vld,
                              mst_tx_ack_vld,
                              mst_rx_ack_vld,
                              slv_tx_shift_en,
                              //clk_gen signals
                              sda_int,
                              scl_int,
                              //reg file signals
                              ic_hs_sync,
                              ic_fs_sync,
                              p_det_ifaddr_sync,
                              // jduarte 20110105 begin
                              // CRM 9000368180
                              // Added register outputs for spike length, in ic_clk cycles
                              // The value for FS and SS modes is the same (ic_fs_spklen)
                              ic_hs_spklen,
                              ic_fs_spklen,
                              ic_master_sync,
                              ic_sda_rx_hold_sync, // SDA hold time when I2C acts as reciever
                              hs_mcode_en,
                              rx_hs_mcode,
                              ic_spklen_o,
                              // jduarte 20110105 end
                              //mstfsm signals
                              stop_en,
                              start_en,
                              re_start_en,
                              split_start_en,
                              mst_tx_en,
                              mst_rx_en,
                              mst_activity,
                              //slvfsm signals
                              slv_tx_en,
                              slv_activity,
                              slv_addressed,
                              //misc.
                              sda_vld,
                              s_det,
                              p_det,
                              p_det_intr,
                              arb_lost,
                              ack_det,
                              slv_ack_det,
                              scl_edg_hl
                              );
   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;// peripherial clock: runs i2c module
   input ic_rst_n;// ic reset signal active low


   input ic_clk_in_a;// Input SCL signal
   input ic_data_in_a;// Input SDA signal

   input ic_hs_sync;//IC is in high speed mode
   input ic_fs_sync;//IC is in fast speed mode
   input p_det_ifaddr_sync; // Programmable option to generate stop only if slave is addressed

   // jduarte 20110105 begin
   // CRM 9000368180
   // Added register outputs for spike length, in ic_clk cycles
   // The value for FS and SS modes is the same (ic_fs_spklen)
   input [`IC_HS_SPKLEN_RS-1:0] ic_hs_spklen;
   input [`IC_FS_SPKLEN_RS-1:0] ic_fs_spklen;
   input                        ic_master_sync;
   input [`IC_SDA_RX_HOLD_RS-1:0]  ic_sda_rx_hold_sync;  // SDA Hold time while I2C acts as transmitter
   input                        hs_mcode_en; // Master sending high speed master code
   input                        rx_hs_mcode; // pulsed when slave receives high speed master code
   output [`IC_SPKLEN_RS-1:0]   ic_spklen_o; // Spike length currently being applied
   // jduarte 20110105 end

   input ic_data_oe;// Transmit SDA signal. Need in Master mode
                     // to determine if Arbitration is lost
                    // to determine Start and stop generation

   input mst_tx_en;// logic 1: enable transmit logic
   input mst_rx_en;// logic 1: enable receive logic
   input stop_en;// master generating stop condition
   input start_en;// master generating start/re_start condition
   input re_start_en;// master generating re_start condition
   input split_start_en; // Master halts temporarily in SplitStart
   input mst_activity;//logic 1: master is busy


   input slv_tx_ack_vld;//slave tx  check for ack now
   input mst_tx_ack_vld;//master tx  check for ack now
   input mst_rx_ack_vld;//master rx  check for ack now
   input slv_tx_en; // Enable tx shift register to transmit data
   input slv_activity;//logic 1:slave is using the bus
   input slv_addressed; // Qualifier signal to indicate the slave is addressed

   // OUTPUTS
   output sda_vld;// SDA signal is valid
   output s_det;// START condition detected
   output p_det;// STOP condition detected
   output p_det_intr;// STOP condition detected based on slave addressed or not
   output arb_lost;// When confgured as MSTR, Arbitration lost
   output slv_tx_shift_en;// shift enable pulse valid when falling
                          // edge detected on SCL signal
   output sda_int;//input SDA signal
   output scl_int;//filtered input scl signal
   output ack_det;//ACK has been detected
   output slv_ack_det;//ACK has been detected

   output   scl_edg_hl;   // falling edge detect of SCL

   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------
   //wires
   wire   ic_clk;
   wire   ic_rst_n;
   wire   ic_clk_in_a;
   wire   ic_data_in_a;

   wire   scl_edg_lh;   // rising edge detect of SCL
   wire   scl_edg_hl_int;   // falling edge detect of SCL
   wire   sda_edg_lh;    // rising edge detect of SDA
   wire   sda_edg_hl;    // falling edge detect of SDA


   wire   s_det_int;
   wire   p_det_int;
   wire start_stop_mstactivity;
   wire ack_bit_activity;
   wire sda_post_spk_suppression; // SDA line after Spike suppression
   wire ic_sda_rx_hold_done; // Asserted when SDA hold time is finished

   //regs
   reg           mst_arb_lost;
   reg           slv_arb_lost;
   reg           slv_tx_shift_en;
   wire          scl_sync;   
   // jduarte 20110105 begin
   // CRM 9000368180
   // The two signals below will be replaced by a counter
   //reg           scl_sync_q;   // 1 Clock delay of scl_sync
   //reg           scl_sync_qq;   // 1 Clock delay of scl_sync_q
   //reg [2:0] scl_ored;   // or scl,scl_q,&scl_qq
   // jduarte 20110105 end
   reg              scl_clk_int;   // best of 3 SCL's
   reg              scl_int_q;   // 1 clock delay of scl_clk_int
   reg [1:0] sda_cnt;   // cnt SDA samples
   reg              sda_vld_int;   // filtered SDA signal in Fast mode is valid
   wire             sda_sync;   
   // jduarte 20110105 begin
   // CRM 9000368180
   // The two signals below will be replaced by a counter
   //reg              sda_sync_q;    // 1 clock delay of sda_sync
   //reg              sda_sync_qq;    // 1 clock delay of sda_sync_q
   //reg [2:0] sda_ored;    // or sda,sda_q,&sda_qq
   // jduarte 20110105 end
   reg              sda_data_int;    // best of 3 SDA's
   reg              sda_int_q;    // 1 clock delay of sda_data_int
   reg              s_det;
   reg              p_det;
   reg              p_det_intr;
   reg               scl_is_low_q;   // scl low valid true
   reg               scl_low_vld;
   reg               scl_is_low_qq;   // 1 clock delay of scl_low_vld
   reg slv_ack_det;
   reg ack_det;
   reg scl_edg_hl_q;
   // jduarte 20110105 begin
   // CRM 9000368180
   // Added counters for timing spike length, in ic_clk cycles
   // Since FS/SS spike suppression is 50ns and HS is 10ns,
   // length of counter is dependent on the count value for FS/SS only
   reg [`IC_FS_SPKLEN_RS-1:0] ic_scl_spklen_cnt;
   reg [`IC_FS_SPKLEN_RS-1:0] ic_sda_spklen_cnt;
   // jduarte 20110105 end

   // Added counters for timing SDA HOLD time, in ic_clk cycles
   reg [`IC_SDA_RX_HOLD_RS-1:0]  ic_sda_rx_hold_cnt;
   reg [`IC_SDA_RX_HOLD_RS-1:0]  sda_prev_rx_hold;
   wire [`IC_SDA_RX_HOLD_RS-1:0]  sda_prev_rx_hold_c;
   reg sda_post_hold_done; // SDA Value after internal Hold Done  
   // ------------------------------------------------------
   // -- Edge detection combo logic
   // ------------------------------------------------------
   // SCL EDGE DETECTS
   assign scl_edg_lh = scl_int &  (~scl_int_q);
   assign scl_edg_hl_int =  ~scl_int & scl_int_q;
   assign scl_edg_hl = scl_edg_hl_int;

   // SDA EDGE DETECTS
   assign sda_edg_lh = sda_int &  (~sda_int_q);
   assign sda_edg_hl =  ~sda_int & sda_int_q;

   // SCL DETECT AND FILTERING
  // assign scl_rise_vld = scl_edg_lh | (s_det_int &  (~stop_en));
  // assign scl_fall_vld = scl_edg_hl_int | p_det_int;

   // START AND STOP DETECT FILTER
   assign s_det_int = scl_int & sda_edg_hl &  (~scl_edg_lh);
   assign p_det_int = scl_int & sda_edg_lh;
   // ------------------------------------------------------
   // -- Master and slave ack detection
   //
   // -- check the ack status during the 9th bit period
   // ------------------------------------------------------
   //master tx  ack
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_MST_ACK_CYCLE_PROC
      if(ic_rst_n == 1'b0)
        begin
             ack_det     <= 1'b0;
        end
      else
        begin
           if((mst_tx_ack_vld == 1'b1)&&(scl_edg_lh == 1'b1))
             begin
                ack_det     <= ~sda_int;
             end
           else if (mst_tx_ack_vld == 1'b0)
             begin
                ack_det     <= 1'b0;
             end
        end
   end // block: IC_MST_ACK_CYCLE_PROC

   //slave tx  ack
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_SLV_ACK_PROC
      if(ic_rst_n == 1'b0)
        begin
           slv_ack_det <= 1'b0;
        end
      else
        begin
           if((sda_vld_int == 1'b1)&&(slv_tx_ack_vld == 1'b1))
             begin
                slv_ack_det     <= ~sda_int;
             end
           else if (scl_edg_hl_q == 1)
             begin
                slv_ack_det <= 1'b0;
             end
        end // else: !if(ic_rst_n == 1'b0)
   end // block: IC_SLV_ACK_PROC

   wire          async2icl_ic_clk_in_a;
   wire          sasync2icl_scl_sync; 
   assign async2icl_ic_clk_in_a = ic_clk_in_a;
   assign scl_sync = sasync2icl_scl_sync;
   // ------------------------------------------------------
   // -- ic_clk_in_a & ic_data_in_a synchronization to ic_clk
   //
   // -- Sync the i2c bus signals to internal ic_clk
   // ------------------------------------------------------
   // ic_clk_in_a synchronization
   DW_apb_i2c_bcm41
    #(
     .RST_VAL     (1), 
     .F_SYNC_TYPE (`IC_SYNC_DEPTH),
     .VERIF_EN    (0)
   ) 
   U_DW_apb_i2c_bcm41_async2icl_ic_clk_in_a_icsyzr(
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (async2icl_ic_clk_in_a)
        ,.data_d              (sasync2icl_scl_sync)
      );

   wire          async2icl_ic_data_in_a;
   wire          sasync2icl_sda_sync; 
   assign async2icl_ic_data_in_a = ic_data_in_a;
   assign sda_sync = sasync2icl_sda_sync;
   // ic_data_in_a synchronization
   DW_apb_i2c_bcm41
    #(
     .RST_VAL     (1),
     .F_SYNC_TYPE (`IC_SYNC_DEPTH),
     .VERIF_EN    (0)
   ) 
   U_DW_apb_i2c_bcm41_async2icl_ic_data_in_a_icsyzr(
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (async2icl_ic_data_in_a)
        ,.data_d              (sasync2icl_sda_sync)
      );

   // ------------------------------------------------------
   // -- SDA & SCL Signals filtering
   //
   // -- filter the inputs from the i2c bus
   // ------------------------------------------------------

   // jduarte 20110105 begin
   // CRM 9000368180
   // Added register outputs for spike length, in ic_clk cycles
   // The value for FS and SS modes is the same (ic_fs_spklen)

   ////SCL filtering
   //always @(scl_sync or scl_sync_q or scl_sync_qq) begin:IC_SCL_FILTER_PROC
   //   scl_ored = {scl_sync,scl_sync_q,scl_sync_qq};
   //      case((scl_ored))
   //        3'b011 : begin
   //           scl_clk_int = 1'b1;
   //        end
   //        3'b101 : begin
   //           scl_clk_int = 1'b1;
   //        end
   //        3'b110 : begin
   //           scl_clk_int = 1'b1;
   //        end
   //        3'b111 : begin
   //           scl_clk_int = 1'b1;
   //        end
   //        default : begin
   //           scl_clk_int = 1'b0;
   //        end
   //      endcase
   //end // block: SCL_FILTER
   //
   //assign scl_int = scl_clk_int;
   //
   //
   ////SDA filtering
   //always @(sda_sync or sda_sync_q or sda_sync_qq) begin:IC_SDA_FILTER_PROC
   //   sda_ored = {sda_sync,sda_sync_q,sda_sync_qq};
   //      case((sda_ored))
   //        3'b000 : begin
   //           sda_data_int = 1'b0;
   //        end
   //        3'b001 : begin
   //           sda_data_int = 1'b0;
   //        end
   //        3'b010 : begin
   //           sda_data_int = 1'b0;
   //        end
   //        3'b100 : begin
   //           sda_data_int = 1'b0;
   //        end
   //        default : begin
   //           sda_data_int = 1'b1;
   //        end
   //      endcase
   //end
   //
   //assign sda_int = sda_data_int;

   // Generate speed mode signals
   reg ic_hs;
   reg ic_hs_r;
   wire ic_fs;
   wire ic_ss;

   // Detect that rx_hs_mcode has gone 1->0
   reg rx_hs_mcode_r;
   always @(posedge ic_clk or negedge ic_rst_n) begin : rx_hs_mcode_r_PROC
     if(~ic_rst_n) rx_hs_mcode_r <= 1'b0;
     else          rx_hs_mcode_r <= rx_hs_mcode;
   end // rx_hs_mcode_r_PROC
  
   wire rx_hs_mcode_fed;
   assign rx_hs_mcode_fed = rx_hs_mcode_r & (~rx_hs_mcode);

   // falling edge detect in hs_mcode_en
   reg hs_mcode_en_r;
   always @(posedge ic_clk or negedge ic_rst_n) begin : hs_mcode_en_r_PROC
     if(~ic_rst_n) hs_mcode_en_r <= 1'b0;
     else          hs_mcode_en_r <= hs_mcode_en;
   end // hs_mcode_en_r_PROC
  
   wire hs_mcode_en_fed;
   assign hs_mcode_en_fed = hs_mcode_en_r & (~hs_mcode_en);

   // Hold until STOP
   reg hs_mcode_fed_dtctd_r;
   always @(posedge ic_clk or negedge ic_rst_n) begin : hs_mcode_fed_dtctd_r_PROC
     if(~ic_rst_n) hs_mcode_fed_dtctd_r <= 1'b0;
     else begin
       // Set when falling edge occurs
       // clear when stop occurs
       // Switch between detected master and slave mode signals
       if(~hs_mcode_fed_dtctd_r)
         hs_mcode_fed_dtctd_r <= ic_master_sync ? hs_mcode_en_fed : rx_hs_mcode_fed;
       else  
         hs_mcode_fed_dtctd_r <= ~p_det_int;
     end
   end // hs_mcode_fed_dtctd_r_PROC

   //spyglass disable_block W415a
   //SMD: Signal may be multiply assigned (beside initialization) in the same scope
   //SJ : The signal ic_hs updated with the default values and then only if required
   //     the signal is updated, based on the required condition. This is done to 
   //     assign the default value during the else branches (if any). There is no 
   //     functional issue. Hence this can be waived.
   // Decode when to switch to HS glitch suppression. We must use FS/SS by
   // default until the bus events to switch to HS speed have occured.
   always @(*) begin : ic_hs_PROC
     ic_hs = ic_hs_r;

     // Switchh to HS speed glitch suppression
     // when SCL goes 0->1, and programmed for HS speed, and the
     // HS master code has been completed.
     // This will be at the first SCL posedge after the NACK 
     // for the HS master code i.e. time tH in the I2C protocol
     // spec (Fig.22 A complete Hs-mode transfer.)
     if(hs_mcode_fed_dtctd_r & scl_edg_lh & ic_hs_sync) ic_hs = 1'b1;
     if(p_det_int)                                       ic_hs = 1'b0;
   end // ic_hs_PROC
   //spyglass enable_block W415a

   always @(posedge ic_clk or negedge ic_rst_n) begin : ic_hs_r_PROC
     if(~ic_rst_n) begin
       ic_hs_r <= 1'b0;
     end else begin
       ic_hs_r <= ic_hs;
     end
   end // ic_hs_r_PROC

   // If programmed for HS speed, but the conditions to switch to HS speed
   // have not yet been met, use FS/SS glitch suppression.
   assign ic_fs = (ic_fs_sync 
                  | (ic_hs_sync & (~ic_hs_r))
                  );

   // Decode SS as not HS and not FS
   assign ic_ss = 
                 ~ic_hs_sync & 
                 (~ic_fs_sync);

   // Output the spike length that is currently being applied
   // Used by tx_shift block in implementation of SDA hold time
   assign ic_spklen_o = (ic_hs_r) ? ic_hs_spklen : ic_fs_spklen;

   //SCL filtering
   always@(posedge ic_clk or negedge ic_rst_n) begin : SCL_CLK_INT_PROC
      if(ic_rst_n == 1'b0) begin
        ic_scl_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
        scl_clk_int       <= 1'b1;
      end else begin
        if(scl_sync != scl_clk_int) begin
          if(
              ( (ic_hs_r         ) && (ic_scl_spklen_cnt < ic_hs_spklen) ) ||
              ( 
                (ic_fs || ic_ss) &&
                (ic_scl_spklen_cnt < ic_fs_spklen) ) ) begin
            ic_scl_spklen_cnt <= ic_scl_spklen_cnt + 1;
           end else begin
             scl_clk_int <= scl_sync;
             ic_scl_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
           end
         end else begin
             ic_scl_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
        end
      end
    end

   assign scl_int = (
                    ( (ic_hs_r         ) && (ic_scl_spklen_cnt == ic_hs_spklen) ) ||
                    ( 
                    (ic_fs || ic_ss) && 
                    (ic_scl_spklen_cnt == ic_fs_spklen) ) ) ? scl_sync : scl_clk_int;

   // Detect when an SCL spike has been rejected
   wire scl_spike_rejected;
   assign scl_spike_rejected =   (scl_sync == scl_clk_int) 
                               & (ic_scl_spklen_cnt != {`IC_FS_SPKLEN_RS{1'b0}});

   // Reset SDA spike rejection counter if an SCL spike is rejected
   // while scl_clk_int == 1. To avoid missampling a START or STOP when
   // a glitch on SCL extends internally sampled SCL high time until
   // after a transition in SDA (which could come from this master)
   // This could most likely happen after a negedge of SCL, when it
   // glitches high again.
   wire reset_sda_spk_cntr;
   assign reset_sda_spk_cntr = scl_spike_rejected & scl_clk_int;

   //SDA filtering
   always@(posedge ic_clk or negedge ic_rst_n) begin : SDA_DATA_INT_PROC
      if(ic_rst_n == 1'b0) begin
        ic_sda_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
        sda_data_int      <= 1'b1;
      end else begin
        if((sda_sync != sda_data_int) & (~reset_sda_spk_cntr)) begin
          if (
              ( (ic_hs_r         ) && (ic_sda_spklen_cnt < ic_hs_spklen) ) ||
              ( 
               (ic_fs || ic_ss) &&
               (ic_sda_spklen_cnt < ic_fs_spklen) ) ) begin
            ic_sda_spklen_cnt <= ic_sda_spklen_cnt + 1;
           end else begin
             sda_data_int <= sda_sync;
             ic_sda_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
           end
         end else begin
             ic_sda_spklen_cnt <= {`IC_FS_SPKLEN_RS{1'b0}};
        end
      end
    end

   assign sda_post_spk_suppression = (
                    ( (ic_hs_r         ) && (ic_sda_spklen_cnt == ic_hs_spklen) ) ||
                    ( 
                    (ic_fs || ic_ss) && 
                    (ic_sda_spklen_cnt == ic_fs_spklen) ) ) && (~reset_sda_spk_cntr) ? sda_sync : sda_data_int;

  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression present in the design.
  //SJ:  This Self Determined Expression is as per the design requirement. 
  //     There will not be any functional issue.
  //--------------------------------------------------------
  //    SDA HOLD time implementation
  //  As a Master or Slave while acting as reciever I2C should hold SDA 
  //  line internally (for 300ns for FS and SS according to I2C spec), which will be programmed by using input register 
  //  ic_sda_rx_hold_sync in terms of ic_clk cycles
  //  This logic only comes in picture whenever SCL line (scl_int) is HIGH
  //---------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : sda_rx_hold_count_r_PROC
     if(~ic_rst_n) begin
       ic_sda_rx_hold_cnt <= {`IC_SDA_RX_HOLD_RS{1'b0}};
     end else begin
       if (scl_int && (sda_post_spk_suppression != sda_post_hold_done )) 
            begin
             if((sda_prev_rx_hold > 8'b0) && (ic_sda_rx_hold_cnt < (sda_prev_rx_hold-{{(`IC_SDA_RX_HOLD_RS-1){1'b0}},1'b1}))) 
       begin
             ic_sda_rx_hold_cnt <= ic_sda_rx_hold_cnt + {{(`IC_SDA_RX_HOLD_RS-1){1'b0}},1'b1};
          end
             end 
      else begin
              ic_sda_rx_hold_cnt <= {`IC_SDA_RX_HOLD_RS{1'b0}};
            end
       end
   end // sda_rx_hold_count_r_PROC
  //spyglass enable_block SelfDeterminedExpr-ML

  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression present in the design.
  //SJ:  This Self Determined Expression is as per the design requirement. 
  //     There will not be any functional issue.
  assign ic_sda_rx_hold_done = (ic_sda_rx_hold_cnt == (sda_prev_rx_hold-{{(`IC_SDA_RX_HOLD_RS-1){1'b0}},1'b1})) || (~scl_int) || (p_det_int);
  //spyglass enable_block SelfDeterminedExpr-ML
  assign sda_prev_rx_hold_c = sda_prev_rx_hold;

// logic to assign post spike suppressed SDA to post hold done register 
// whenever ic_sda_rx_hold_done is asserted
   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : sda_rx_post_hold_PROC
     if(~ic_rst_n) begin
      sda_post_hold_done <= 1'b1;
     end
     else begin
     if (ic_sda_rx_hold_done)
        begin
        sda_post_hold_done <= sda_post_spk_suppression;
        end
     end
    end

  //--------------------------------------------------------------------
  //--IC_PREV_SDA_RX_HOLD Register
  //-- This Register holds the previous value of RX_HOLD programmed
  //-- to avoid the consideration of changed value while RX Hold counter
  //-- is running with the previous value
  //---------------------------------------------------------------------
  always @(posedge ic_clk or negedge ic_rst_n) begin : PREV_SDA_RX_HOLD_PROC
    if(!ic_rst_n)
      sda_prev_rx_hold <= {(`IC_SDA_RX_HOLD_RS){1'b0}};
    else begin
       if (sda_post_spk_suppression == sda_post_hold_done )
        sda_prev_rx_hold <= ic_sda_rx_hold_sync;
      else
        sda_prev_rx_hold <= sda_prev_rx_hold_c;
    end
  end

  //If ic_sda_rx_hold_sync==0 then assign sda_post_spk_suppression directly to sda_int
  //otherwise assign  sda_post_hold_done only when SCL is HIGH i.e. scl_int is HIGH
  //when scl_int is LOW assign sda_post_spk_suppression
    assign sda_int = (sda_prev_rx_hold==8'b0) ? sda_post_spk_suppression : (scl_int  ? sda_post_hold_done : sda_post_spk_suppression);

   // jduarte 20110105 end
   // ------------------------------------------------------
   // -- slv_tx_shift_en generation
   //
   // -- This signal indicates that SCL line has dropped form
   // -- High to low and enable the slave to set the sda line
   // -- to the required value to be transmitted
   // ------------------------------------------------------
   always @(
          ic_fs_sync or scl_low_vld or scl_is_low_qq 
         or ic_hs_sync
         or
         scl_edg_hl_int) begin:IC_TX_SHIFT_PROC
      if((ic_fs_sync == 1'b1) 
          || (ic_hs_sync == 1'b1)
          ) begin
         slv_tx_shift_en = (scl_low_vld == 1'b1) && ( scl_is_low_qq == 1'b0);
      end
      else //if standard mode ( ic_ss_sync == 1'b1)
        slv_tx_shift_en = scl_edg_hl_int;
   end




   // ------------------------------------------------------
   // -- slv_low_vld generation
   //
   // -- This signal indicates that SCL
   // -- line is at a valid low level
   // ------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n)begin:IC_SCL_IS_LOW_PROC
     if(ic_rst_n == 1'b0)
       scl_is_low_q <= 1'b0;
     else
       if((scl_edg_hl_int == 1'b1))
         scl_is_low_q <= 1'b1;

       else if((scl_edg_lh == 1'b1))
          scl_is_low_q <= 1'b0;
   end

   // 1 CLOCK DELAY of scl_is_low_q
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_SCL_LOW_PROC
      if(ic_rst_n == 1'b0)
        begin
           scl_is_low_qq <= 1'b0;
        end
      else
        begin
           scl_is_low_qq <= scl_is_low_q;
        end
   end

//#
//# PG
//#
//# Removed scl_low_q from the statement
//#
   //scl_low_vld generation
   always @(
       ic_hs_sync or
       ic_fs_sync or scl_is_low_q or scl_edg_hl_int or scl_edg_lh) begin:IC_LVLD_GEN_PROC
      if((ic_fs_sync == 1'b1) 
          || (ic_hs_sync == 1'b1)
          ) begin
         scl_low_vld = scl_is_low_q;
      end
      else if((scl_edg_lh == 1'b1)) begin
         scl_low_vld = 1'b0;
      end
      else begin
         scl_low_vld = scl_is_low_q | scl_edg_hl_int;
      end
   end
   // ------------------------------------------------------
   // -- sda_vld generation
   //
   // -- Indicates sda level is valid for sampling internally
   // ------------------------------------------------------
   assign sda_vld = sda_vld_int;

//#
//# PG
//#
//# removed sclK_int == 1'b1 from check
//#
   // SDA Valid detection
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_SDAVLD_DET_PROC
     if(ic_rst_n == 1'b0)
       begin
          sda_cnt <= 2'b11;
          sda_vld_int <= 1'b0;
       end
     else
       begin

          if((scl_int == 1'b0))
            sda_cnt <= 2'b00;
          else if((sda_cnt != 2'b11))
            sda_cnt <= sda_cnt + 2'b01;
          if(sda_cnt == 2'b10)//wait for three clocks in ic_hs_sync or ic_fs_sync mode before sampling sda
            sda_vld_int <= 1'b1;
          else
            sda_vld_int <= 1'b0;

       end // else: !if(ic_rst_n == 1'b0)
   end
   // ------------------------------------------------------
   // -- arb_lost signal generation
   //
   // -- arbitration lost detection circuit
   // ------------------------------------------------------

// ---------------------------------------------------------------------------
//#
//# PG
//#
//# Created the start_stop_mstactivity
//# Made start_stop_mstactivity == 1'b0 higher priority
//#
//
// Generate a signal to indicate when the I2C (as a Master) encounters
// collisions on the bus, forcing it to lose arbitration and release control
// to the other I2C Master.
//
// Performed on rising edge of the bus' SCL clock line, since the I2C setup
// time requirement will guarantee a stable SDA line.
//
// During Master-transmits, make sure this check is NOT done during the
// ACK bit, since this is NOT driven by the Master.
// During Master-receives, make sure this check is performed during the
// ACK bit, since this is driven by the Master.
//
// If a START condition ("s_det") occurs when "start_stop_mstactivity"
// is asserted, then it means that ANOTHER Master has begun transmission
// when this Master is transmitting. Since the current transmission is
// corrupted, arbitration is pointless.
// If a STOP condition occurs when "start_stop_mstactivity@ is asserted,
// then it means t[HD;DAT] is violated, and data corruption will also
// have occured.
// In both cases, there is no point continuing data transfer or arbitrating.
//
// In using the "re_start_en" and "split_start_en" signals, compensate for
// the 4 clock cycle delay for the SDA used for the arbitration detection.
// ---------------------------------------------------------------------------
   assign start_stop_mstactivity = ((start_en == 1'b0) && (stop_en == 1'b0) && (mst_activity == 1'b1));

   assign ack_bit_activity = ((mst_tx_en==1'b1 && mst_tx_ack_vld==1'b0) 
                             ) ||
                             (mst_rx_en==1'b1 && mst_rx_ack_vld==1'b1);

  reg [3:0] delay_re_start_en_or_split_start_en;
  wire      restart_splitstart;
  assign restart_splitstart = |delay_re_start_en_or_split_start_en;

  always @(posedge ic_clk or negedge ic_rst_n) begin : DELAY_RESTART_SPLIT_PROC
    if(!ic_rst_n)
      delay_re_start_en_or_split_start_en <= 4'h0;
    else begin
      delay_re_start_en_or_split_start_en[3:1] <= delay_re_start_en_or_split_start_en[2:0];
      delay_re_start_en_or_split_start_en[0]   <= re_start_en | split_start_en;
    end
  end // always

   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_DET_MST_ARB_LOST_PROC
      if(ic_rst_n == 1'b0) begin
           mst_arb_lost <= 1'b0;
      end else begin
      // Signal assigned more than once on a single flow of control
        if((s_det || p_det) && start_stop_mstactivity && (!restart_splitstart))
   begin
          mst_arb_lost <= 1'b1;
   end else begin
          if (scl_edg_lh == 1'b1) begin
            if (start_stop_mstactivity == 1'b0)
              mst_arb_lost <= 1'b0;
            else
              mst_arb_lost <= (ack_bit_activity && (~ic_data_oe != sda_int))
                         ? 1'b1 : 1'b0;
          end else begin
            if (mst_activity == 1'b0)
              mst_arb_lost <= 1'b0;
          end
        end

        //if((s_det || p_det) && start_stop_mstactivity && !restart_splitstart)
          //mst_arb_lost <= 1'b1;
      end // else ic_rst_n
   end // always


//#
//# PG
//#
//# Made slv_activity == 1'b0 higher priority
//#
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_DET_SLV_ARB_LOST_PROC
      if(ic_rst_n == 1'b0)
        begin
           slv_arb_lost <= 1'b0;
        end else
          if (scl_edg_lh == 1'b1)
            if (slv_activity == 1'b0)
              slv_arb_lost <= 1'b0;
            else
              slv_arb_lost <= ((slv_tx_en == 1'b1) &&
                               (slv_tx_ack_vld == 1'b0) &&
                               (~ic_data_oe != sda_int)) ? 1'b1 : 1'b0;
          else if (slv_activity == 1'b0)
            slv_arb_lost <= 1'b0;
   end

   assign arb_lost =  mst_arb_lost | slv_arb_lost;
   // ------------------------------------------------------
   // -- 1 ic_clk period delay for some signals
   // ------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin:IC_1DELAY_PROC
     if(ic_rst_n == 1'b0)
        begin
           s_det <= 1'b0;
           p_det <= 1'b0;
           p_det_intr <= 1'b0;
           scl_int_q <= 1'b1;
           sda_int_q <= 1'b1;
           scl_edg_hl_q <= 1'b0;
        end
     else
       begin
          scl_int_q <= scl_int;
          sda_int_q <= sda_int;
          scl_edg_hl_q <= scl_edg_hl_int;
          s_det <= s_det_int;
          p_det <= p_det_int;
          if(~ic_master_sync & p_det_ifaddr_sync)
            p_det_intr <= (slv_addressed) ? p_det_int : 1'b0;
          else begin
            p_det_intr <= p_det_int;
          end
       end // else: !if(ic_rst_n == 1'b0)
   end // block: IC_1DELAY_PROC

   

endmodule // DW_apb_i2c_rx_filter



















//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #14 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_slvfsm.v#14 $ 
//
//
// File    : DW_apb_i2c_slvfsm.v
//
//
// Author  : Hani Saleh
// Created : Sep, 2002
// Abstract: I2C Master Control will be active when the I2C module is
//           configured for slave mode of operation as defined by the
//           mode bit in ic_con register.  This module will control: 
//           slave-receiver or slave-transmit functions in either
//           the 7-bit or 10-bit mode as defined by the ic_con register
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

// -----------------------------------------------------------
// -- Macros
// -----------------------------------------------------------

module DW_apb_i2c_slvfsm
  (
   ic_rst_n
                           ,ic_clk
                           ,//Signals synchronized from pclk domain
                           ic_enable_sync
                           ,ic_10bit_slv_sync
                           ,tx_empty_sync
                           ,tx_empty_sync_hl
                           ,ic_slave_en_sync
                           ,ic_sda_setup
                           ,ic_ack_general_call
                           ,//signals to the toggle ckt
                           slv_tx_abrt
                           ,slv_rx_done
                           ,ic_rd_req
                           ,//rx filter signals
                           arb_lost
                           ,s_det
                           ,p_det
                           ,slv_ack_det
                           ,slv_rx_ack_vld
                           ,//Tx shift reg signals
                           slv_tx_en
                           ,slv_rx_en
                           ,slv_txfifo_ld_en
                           ,tx_fifo_dbuf_8
                           ,slv_gen_ack_en
                           ,scl_hld_low_en
                           ,slv_tx_cmplt
                           ,ic_data_oe
                           ,//Rx shift reg signals
                           slv_rxbyte_rdy
                           ,rx_gen_call
                           ,rx_addr_match
                           ,rx_slv_read
                           ,slv_rx_1byte_en
                           ,slv_rx_2byte_en
                           ,slv_push_rxfifo_en
                           ,slv_rx_2addr
                           //slv tx_abrt source indicator
                           ,abrt_slvflush_txfifo//slave flush tx fifo to request tx data
                           ,abrt_slv_arblost//Slave lost the bus while it is tx data
                           ,abrt_slvrd_intx//Slave request data to tx and processor wrote 
                           ,// a read command into the tx_fifo (9th bit is 1)
                           //misc.
                           slv_debug_addr
                           ,slv_debug_data
                           ,slv_activity
                           ,slv_clr_leftover
                           ,slv_debug_cstate                           
                           ,slv_rx_aborted
                           ,slv_fifo_filled_and_flushed
                           ,slv_addressed
                           ,slv_tx_data_en
                           );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;    // module clock: runs i2c module
   input ic_rst_n;  // asynchronous reset input active low
      
   input ic_enable_sync; // logic 1: enable i2c module
   input ic_10bit_slv_sync; // logic 1: IC 10-bit address transfer mode
                       // logic 0: IC 7-bit address transfer mode
   input tx_empty_sync;      // tx fifo empty
   input tx_empty_sync_hl;//logic 1:high to low edge detection of tx_empty_sync
   input arb_lost;   // logic 1: master lost arbitration
   input s_det;      // START condition detected
   input p_det;      // STOP condition detected
   input slv_ack_det;    // logic 1: acknowledge detected
   input slv_rx_ack_vld;
   input tx_fifo_dbuf_8;//Buffer to hold data popped from tx fifo
   input slv_rxbyte_rdy; //Indicates that a byte has been received
   input rx_gen_call;//General Call address has been received and acknowledged
//   input rx_start_byte;// Start byte has been received
   input rx_addr_match;//logic 1: An Address has been received and matched ours, logic 0: address fail
   input rx_slv_read;//logic 1: Slave is receiving data, logic 0: Slave has to transmit data
   input slv_tx_cmplt;//logic 1: slave has finished transmission
   input ic_data_oe;
   input ic_slave_en_sync;//1: slave is enabled, 0:disabled   
   
   input [7:0] ic_sda_setup; // SDA setup time, aka tsu;DAT
   
   input ic_ack_general_call;
   
   //Outputs
   output slv_tx_en; // Enable tx shift register to transmit data
   output slv_rx_en; // Enable rx shift register to transmit data
   output slv_gen_ack_en; // Enable Ack gen. ckt
   output slv_tx_abrt;   // logic 1: slave issued tx abort to flush the tx fifo
   output slv_rx_done;   // logic 1: slave stopped RX transfer   
   output slv_txfifo_ld_en;// load tx_buffer from the tx fifo output
   output slv_push_rxfifo_en;
   output slv_rx_1byte_en;//logic 1: we are receiving the 1st byte of a transfer
   output slv_rx_2byte_en;//logic 1: we are receiving the 2nd byte of a transfer
   output scl_hld_low_en;//logic 1:hold scl to low state (insert wait states)
   output slv_activity;//logic 1:slave is using the bus
   output ic_rd_req;//logic 1:Slave is waiting on data from the processor to tx
   output slv_debug_addr;
   output slv_debug_data;
   output slv_rx_2addr;//1: 2nd address byte in 10 bit mode has been received

   output abrt_slvflush_txfifo;//slave flush tx fifo to request tx data
   output abrt_slv_arblost;//Slave lost the bus while it is tx data
   output abrt_slvrd_intx;//Slave request data to tx and processor wrote 
   // a read command into the tx_fifo (9th bit is 1)
   output [3:0] slv_debug_cstate;//Currents state
   output slv_clr_leftover;//1: after a read request received we have more data in the 
                     // tx_fifo that was not transmitted
                     // so clear it inorder not to get the mstfsm to think
                     // that it is a data to send
   output       slv_rx_aborted;
   output       slv_fifo_filled_and_flushed;
   output       slv_addressed; // Qualifier signal to indicate the slave is addressed
   output       slv_tx_data_en; // Slave transmitting data from Tx_FIFO
   
   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------
   //registers
   reg [3:0] slv_current_state;//Currents state
   reg [3:0] slv_next_state;//Next state
   reg              slv_tx_en;//enable tx shifter
   reg              slv_rx_en;//enable rx shifter
   reg              slv_gen_ack_en;//enable gen ACK in rx mode
   reg              slv_tx_abrt;//Master Tx aborted int.
   reg              slv_rx_done;//Master Rx aborted int.
   reg              slv_txfifo_ld_en; //Load fifo data into TX buffer
   reg              slv_tx_flush;//logic 1: slave has flushed the tx_fifo buffer
                          // in a byte streamis write (1) or No Transaction (0)
   reg              slv_activity;//indicates that we can stop without performing
                                 //illegal action on I2C bus
   reg              slv_push_rxfifo_en; //push data into RX_FIFO
   reg              ic_rd_req;//logic 1:Slave is waiting on data from the processor to tx
   reg              scl_hld_low_en;//Allow scl to be held low ti insert wait states
   reg              slv_rx_1byte_en;//logic 1: slave is receiving the first byte of a transfer
   reg              slv_rx_2byte_en;//logic 1: slave is receiving the first byte of a transfer
   reg              slv_rx_2addr;//1: 2nd address byte in 10 bit mode has been received


   //slave tx_abrt source indicator   
   reg abrt_slvflush_txfifo;//slave flush tx fifo to request tx data
   reg abrt_slv_arblost;//Slave lost the bus while it is tx data
   reg abrt_slvrd_intx;//Slave request data to tx and processor wrote 
   // a read command into the tx_fifo (9th bit is 1)
   reg slv_clr_leftover;//1: after a read request received we have more data in the 
                     // tx_fifo that was not transmitted
                     // so clear it inorder not to get the mstfsm to think
                     // that it is a data to send
   reg slv_rx_aborted; // indicates if a Slave-Rx operation has been aborted due to
                       // "ic_enabled" negating, and a negative ACK sent
   reg slv_fifo_filled_and_flushed; // indicates if a Slave-Rx operation has been aborted
                                    // due to "ic_enable" negating, AND with >= 1 byte
                                    // pushed into the Rx FIFO.
   reg slv_addressed              ; // Qualifier to notify whether slave is addressed or not.




   // ----------------------------------------------------------
   // -- local wires
   // ----------------------------------------------------------

   // ----------------------------------------------------------
   // -- state variables (gray coded)
   // ----------------------------------------------------------
   parameter        IDLE             = 4'b0000;//0: No activity
   parameter        RX_1BYTE         = 4'b0001;//1: Receive 1st byte
   parameter        RX10_2ND_ADDR    = 4'b0010;//2: receive the 2nd byte of 10 bit addr
   parameter        RX_LOOP          = 4'b0101;//5: Receive data loop
   parameter        TX_LOOP          = 4'b0111;//7: transmit data loop
   parameter        WAIT_TX_DATA     = 4'b0110;//6: wait for processor to supply data for slv TX
   parameter        ABORT_RX_ADDR    = 4'b0100;//4: address reception aborted due to START
   parameter        INSPECT_DATA_CMD = 4'b1000;//8: check bit 8 of IC_DATA_CMD
   // ----------------------------------------------------------
   // -- state assignment
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : FSM_SEQ_PROC
      if(ic_rst_n == 1'b0) begin
         slv_current_state <= IDLE;
      end else begin
         if ( ((slv_activity == 1'b0) && (ic_enable_sync  == 1'b0)) 
              || (ic_slave_en_sync == 1'b0)
              ) begin
            slv_current_state <= IDLE;
         end else begin
            slv_current_state <= slv_next_state;
         end
      end
   end
   
   // ----------------------------------------------------------
   // -- This combinational process calculates the next state
   // ----------------------------------------------------------
   always @(
            ic_enable_sync
            or ic_10bit_slv_sync
            or tx_empty_sync
            or slv_rxbyte_rdy
            or rx_gen_call
            or rx_addr_match
            or rx_slv_read    
            or s_det
            or p_det
            or slv_ack_det
            or slv_current_state
            or tx_empty_sync_hl
            or arb_lost
            or tx_fifo_dbuf_8
            or slv_tx_cmplt
            or slv_tx_flush
            or ic_ack_general_call
            or ic_data_oe
            ) begin: FSM_COMB_PROC
      slv_tx_abrt = 1'b0;
      slv_rx_done = 1'b0;
      slv_rx_en = 1'b0;
      slv_txfifo_ld_en = 1'b0;
      slv_push_rxfifo_en = 1'b0; //push data into RX_FIFO
      ic_rd_req = 1'b0;
      slv_rx_1byte_en = 1'b0;
      slv_rx_2byte_en = 1'b0;
      slv_next_state = IDLE;

      //slv tx_abrt source indicators
      abrt_slvflush_txfifo = 1'b0;
      abrt_slv_arblost = 1'b0;
      abrt_slvrd_intx = 1'b0;
      slv_clr_leftover = 1'b0;
      case (slv_current_state)
        IDLE:
          begin
             //Control signals initialization
             slv_tx_abrt = 1'b0;
             slv_rx_done = 1'b0;
             slv_rx_en = 1'b0;
             slv_txfifo_ld_en = 1'b0;
             slv_push_rxfifo_en = 1'b0; //push data into RX_FIFO
             ic_rd_req = 1'b0;
             slv_rx_1byte_en = 1'b0;
             slv_rx_2byte_en = 1'b0;
             
             if ((ic_enable_sync  == 1'b1) && // IC enabled
                 (s_det == 1'b1) // Start detected on the bus
                 ) begin
                slv_next_state = RX_1BYTE;
             end else begin
                slv_next_state = IDLE;
             end
          end

        // ====================================================================
        // The reception of the address, during RX_1BYTE state, is interrupted
        // by the detection of an "unexpected" START condition.
        // Restore all signals, as per in IDLE state, and immediately resume
        // address reception by entering RX_1BYTE again.
        // ====================================================================
        ABORT_RX_ADDR: begin
          slv_tx_abrt = 1'b0;
          slv_rx_done = 1'b0;
          slv_rx_en = 1'b0;
          slv_txfifo_ld_en = 1'b0;
          slv_push_rxfifo_en = 1'b0; //push data into RX_FIFO
          ic_rd_req = 1'b0;
          slv_rx_1byte_en = 1'b0;
          slv_rx_2byte_en = 1'b0;

          slv_next_state = RX_1BYTE;
        end // case
        
        // ====================================================================
        // Receiving the first (address) byte from the master, after having
        // detected the START condition earlier.
        // If a START is unexpectedly detected again, then reset all controls
        // by going into ABORT_RX_ADDR and then re-enter here.
        // If a STOP is unexpected detected, then go into IDLE.
        //
        // Made sure that if this HW generated a negative ACK, the SlvFSM goes
        // back into the idle state.
        //
        // Software now controls as to whether receiving can continue when
        // a General Call address is detected.
        // ====================================================================
        RX_1BYTE: begin
          slv_rx_en = 1'b1;
          slv_rx_1byte_en = 1'b1;
                                 // or if we are 10 bit and it is 1st or 2nd address that matches
                                 // ours or if it is a general call address

          if(s_det || p_det) begin
            slv_next_state = s_det ? ABORT_RX_ADDR : IDLE;
          end

          else if (slv_rxbyte_rdy == 1'b1) begin //We received the data byte
            slv_rx_1byte_en = 1'b0;
            slv_rx_en = 1'b0;
                  
            if(ic_data_oe==1'd0) begin
              slv_next_state = IDLE;
            end

            else 
                if(rx_gen_call == 1'b1) begin //General call address has been received
              if(ic_ack_general_call)
                slv_next_state = RX_LOOP;
              else
                slv_next_state = IDLE;
            end



            else if(rx_addr_match == 1'b0) begin 
              slv_next_state = IDLE;
            end 
                  
            else if(rx_slv_read == 1'b1) begin
              if(tx_empty_sync == 1'b0) begin
                slv_tx_abrt =1'b1;//issue tx_abrt to flush the TX buffer
                abrt_slvflush_txfifo = 1'b1;
              end

              ic_rd_req = 1'b1;
              slv_next_state = WAIT_TX_DATA;
            end


            else if(ic_10bit_slv_sync == 1'b1) begin //IC 10 bit and 1st addr byte matched
              slv_next_state = RX10_2ND_ADDR;
            end
                  
            else begin
              slv_next_state = RX_LOOP;
            end // else: !if(ic_10bit_slv_sync == 1'b1)
                  
          end // if (slv_rxbyte_rdy == 1'b1)
          else begin                         
            slv_next_state = RX_1BYTE;
          end // else: !if(slv_rxbyte_rdy == 1'b1)
        end // case: RX_BYTE
        
        // ====================================================================

        RX10_2ND_ADDR:
          begin
             slv_push_rxfifo_en = 1'b0;
             slv_rx_en = 1'b1;
             slv_rx_1byte_en = 1'b0;
             slv_rx_2byte_en = 1'b1;
                             
             if(p_det == 1'b1)
               begin
                  slv_rx_en = 1'b0;
                  slv_next_state = IDLE;
               end

             else if(s_det == 1'b1)
               begin
                  slv_rx_en = 1'b0;
                  slv_next_state = RX_1BYTE;
               end
             else if (slv_rxbyte_rdy == 1'b1) 
               begin
                  slv_rx_en = 1'b0;
                  if(rx_addr_match == 1'b1)
                   begin
                      
                        slv_next_state = RX_LOOP;
                   end
                 else
                   slv_next_state = IDLE;
              end
             else
               slv_next_state = RX10_2ND_ADDR;
             
               end // case: RX10_2ND_ADDR
        
        RX_LOOP:
          begin
             slv_rx_1byte_en = 1'b0;
             slv_rx_2byte_en = 1'b0;
             slv_push_rxfifo_en = 1'b0;    
      
             slv_rx_en = 1'b1;
             
             if(p_det == 1'b1)
               begin
                  slv_rx_en = 1'b0;
                  slv_next_state = IDLE;
               end

             else if(s_det == 1'b1)
               begin

                  slv_rx_en = 1'b0;
                  slv_next_state = RX_1BYTE;
               end
             
             else if (slv_rxbyte_rdy == 1'b1) 
               begin //We received the 2nd data byte
                  slv_rx_en = 1'b0;
                  slv_push_rxfifo_en = 1'b1;
       
    slv_next_state = RX_LOOP;
               end
             else begin
               slv_next_state = RX_LOOP;
             end
          end // case: RX_LOOP


            
        
        WAIT_TX_DATA:
          begin
             ic_rd_req = 1'b0;
             slv_txfifo_ld_en = 1'b0; //Don't Latch the Fifo data into the TX buffer yet
             
             if(p_det == 1'b1)
              begin
                 slv_next_state = IDLE;
              end
             
             else if(s_det == 1'b1)
               begin
                 slv_next_state = RX_1BYTE;
               end
             
             else 
               if(((slv_tx_flush == 1'b0) && (tx_empty_sync == 1'b0)) 
                     || ((slv_tx_flush == 1'b1) && (tx_empty_sync_hl == 1'b1)))// We have data to send
               begin
                  slv_txfifo_ld_en = 1'b1;//issue a pop tx fifo signal
                  slv_next_state = INSPECT_DATA_CMD; // was TX_LOOP;
               end
             else//keep waiting
               slv_next_state = WAIT_TX_DATA;
             
          end // case: WAIT_TX_DATA
        
        // ======================================================================
        // After the TxFIFO has been popped, inspect bit 8 of the IC_DATA_CMD
        // value written in.
        // If bit 8 eq 0, then proceed as normal.
        // If bit 8 eq 1, then alert appropriately and go back to wait for data.
        // ======================================================================
        INSPECT_DATA_CMD : begin
          if(p_det == 1'b1) begin
            slv_next_state = IDLE;
          end else if(s_det == 1'b1) begin
            slv_next_state = RX_1BYTE;
          end else if(tx_fifo_dbuf_8) begin
            slv_tx_abrt = 1'b1;
            abrt_slvrd_intx = 1'b1;
            
            slv_next_state = WAIT_TX_DATA;
          end else if(arb_lost) begin
            slv_tx_abrt = 1'b1;
            abrt_slv_arblost = 1'b1;

            slv_next_state = IDLE;
          end else begin
            slv_next_state = TX_LOOP;
          end // else arb_lost
        end // case INSPECT_DATA_CMD

        // ======================================================================
        // Transmission in progress loop.
        //
        // If the I2C Master NAK's the transfer, and the TxFIFO is still contains
        // 1 or more bytes, then a Abort_SlvFlush_TxFIFO condition is deemed to
        // have occurred.
        // ======================================================================
        
        TX_LOOP: begin
          slv_txfifo_ld_en = 1'b0; //latch tx data into the tx buf

          ic_rd_req = 1'b0;

          if(p_det == 1'b1) begin
            slv_next_state = IDLE;
          end
          else if(s_det == 1'b1) begin
            slv_next_state = RX_1BYTE;
          end
             
          else if ((arb_lost == 1'b1) || (tx_fifo_dbuf_8 == 1'b1)) begin 
                 //lost arb. or proc. wrote 1 in the 9th bit
                 // we cant read from the bus the bus now
            slv_tx_abrt = 1'b1;
            if(arb_lost == 1'b1) 
              abrt_slv_arblost = 1'b1;
            if(tx_fifo_dbuf_8 == 1'b1)
              abrt_slvrd_intx = 1'b1;
            slv_next_state = IDLE;
          end // else if 
             
          else if(slv_tx_cmplt == 1'b1) begin
            if (slv_ack_det == 1'b1) begin    //master acknowledged the data bytes
              if(tx_empty_sync == 1'b0) begin //We have more data in tx fifo
                slv_txfifo_ld_en = 1'b1;      //Load the fifo data to the tx buffer
                slv_next_state = TX_LOOP;
              end
              else begin                  //No more data to process
                slv_txfifo_ld_en = 1'b0;      //Don't Load the fifo data to the tx buffer yet
                ic_rd_req = 1'b1;             //issue a read request
                slv_next_state = WAIT_TX_DATA;//go and wait for the data

              end // else
            end // if slv_ack_det
             
            else begin                        // Master did not acknowledge the data byte
                                              // (it means we need to send no more data)
              if(tx_empty_sync == 1'b0) begin //We have more data in tx fifo
                slv_clr_leftover = 1'b1;
                abrt_slvflush_txfifo = 1'b1;
                slv_tx_abrt = 1'b1;
              end
              slv_rx_done = 1'b1;
              slv_next_state = IDLE;

            end // else slv_ack_det
          end // else slv_tx_cmplt

          else begin
            slv_next_state = TX_LOOP; // Wait for an ACK signal
          end
        end // case: TX_LOOP


        
        default: slv_next_state = IDLE;

      endcase // case(slv_current_state)
      
   end // block: FSM_COMB_PROC
  // ==========================================================================
  // Generating the ACK bit's polarity.
  //
  // Force the ACK's polarity to be negative if:
  // - the IC_ENABLE bit is 0
  // ==========================================================================
  reg ic_enable_sync_vld;

  always @(posedge ic_clk or negedge ic_rst_n) begin : ENABLE_SYNC_D_PROC
    if(!ic_rst_n) begin
      ic_enable_sync_vld <= 1'd0;
    end else begin
      if(ic_enable_sync==1'd0) begin
        if(slv_rx_ack_vld==1'd0)
          ic_enable_sync_vld <= 1'd0;
      end else begin
        ic_enable_sync_vld <= 1'd1;
      end // else ic_enable_sync
    end // else ic_rst_n
  end // always

  always @(   slv_current_state
           //LK-- or slv_rxbyte_rdy
           or s_det 
           or ic_enable_sync_vld ) begin : SLV_GEN_CK_EN_PROC
      
    slv_gen_ack_en = 1'b0;

    if(ic_enable_sync_vld) begin
      if((slv_current_state == RX_1BYTE) ||
         (slv_current_state == RX10_2ND_ADDR) ||
         (slv_current_state == RX_LOOP && s_det==1'b0)
        ) begin
        slv_gen_ack_en = 1'b1;
      end // if slv_current_state,... 
    end // if ic_enable_sync
  end 


  // ==========================================================================
  // Generating the slv_rx_aborted signal.
  //
  // This signal reacts to the negating of the IC_ENABLE register bit, and 
  // reflects the Slave FSM activity state during Slave-Rx operations.
  // This provides an indication to software that an attempt to shut down the
  // DW_apb_i2c was made when a Slave-Rx was in progress.
  // ==========================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_TX_ABORTED_PROC 
    if(ic_rst_n==1'd0) begin
      slv_rx_aborted <= 1'd0;
    end else begin
      if(ic_enable_sync) begin
        slv_rx_aborted <= 1'd0;
      end else begin
        if(slv_current_state == RX_1BYTE ||
           slv_current_state == RX10_2ND_ADDR ||
           slv_current_state == RX_LOOP)
          slv_rx_aborted <= 1'd1;
      end // else ic_enable_sync
    end // else ic_rst_n
  end // always

  // ==========================================================================
  // Generating the slv_fifo_filled_and_flushed signal.
  //
  // This signal reacts to the negating of the IC_ENABLE register bit, and
  // reflects complete byte reception by the Slave FSM.
  // This provides an indication to software that an attempt to shut down the
  // DW_apb_i2c was made when >= 1 byte was received in a Slave-Rx operation,
  // irrespective of whether the transfer was ACK-ed or not.
  // ==========================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_FIFO_FLUSHED_PROC 
    if(ic_rst_n==1'd0) begin
      slv_fifo_filled_and_flushed <= 1'd0;
    end else begin
      if(ic_enable_sync) begin
        slv_fifo_filled_and_flushed <= 1'd0;
      end else begin
        if(slv_current_state == RX_LOOP && slv_rxbyte_rdy)
          slv_fifo_filled_and_flushed <= 1'd1;
      end // else ic_enable_sync
    end // else ic_rst_n
  end // always

// ==========================================================
// Generating the "slv_tx_en"
//
// "slv_tx_en" is the same as that originally coded, but is
// relocated here for style and ease of reading. It is
// used to enable the tx_shift module's internals signals.
// ==========================================================
always @( slv_current_state or
          arb_lost          or
          tx_fifo_dbuf_8    or
          slv_tx_cmplt      or
          slv_ack_det       ) begin : SLV_TX_EN_PROC
  slv_tx_en    = 1'b0;

  if(slv_current_state == IDLE || 
     slv_current_state == ABORT_RX_ADDR) begin
    slv_tx_en    = 1'b0;
  end
  else if((slv_current_state == TX_LOOP)
  )
  begin
    slv_tx_en    = 1'b1;

    if(arb_lost || tx_fifo_dbuf_8) begin
      slv_tx_en    = 1'b0;
    end
    else if(slv_tx_cmplt) begin
      if(slv_ack_det) begin
        slv_tx_en    = 1'b0;

      end
      else begin
        slv_tx_en    = 1'b0;
      end
    end
  end
end

// ==========================================================
// Generating the "hold" SCL at low signal.
//
// Following piece of code previously resides within the
// Slave FSM always block.
//
// This signal ensures that the ic_clk_oe is forced to 0,
// so that the SCL on the I2C bus is driven low. This action
// primarily occurs when the I2C (Slave) needs to stretch the
// SCL's low polarity in response to a (eg.) I2C read. This
// allows time for the FIFO to be filled in the I2C (Slave)
// so that the required data can be popped for the I2C read
// to be completed.
//
// If either the START (s_det) or STOP (p_det) conditions are
// encountered, then SCL must also be released.
// ==========================================================

reg [7:0] stretch_scl_count;

always @(slv_current_state or
         stretch_scl_count or
         p_det             or
         s_det           /*or
         min_hld_cmplt     or
         slv_tx_ready*/ ) begin : SCL_HLD_LOW_EN_PROC

  scl_hld_low_en = 1'b0;

  if(slv_current_state==IDLE) begin
    scl_hld_low_en = 1'b0;
  end // IDLE

  else if(slv_current_state == WAIT_TX_DATA || slv_current_state==INSPECT_DATA_CMD) begin
    scl_hld_low_en = 1'b1;

    if(p_det==1'b1 || s_det==1'b1)
      scl_hld_low_en = 1'b0;
  end // WAIT_TX_DATA


  else if(slv_current_state == TX_LOOP) begin
    if(stretch_scl_count=={8{1'b1}}) begin
      scl_hld_low_en = 1'b0;
    end else
      scl_hld_low_en = 1'b1;
    // if((slv_tx_ready == 1'b1) && (min_hld_cmplt == 1'b1))
    //   scl_hld_low_en = 1'b0;
    // else
    //   scl_hld_low_en = 1'b1; 
  end // TX_LOOP
end

// ==========================================================
// Counter to add ensure setup time for SDA changes to rising
// edge of SCL is adhered to.
//
// This counter will ensure "scl_hld_low_en" is maintained
// low for the programmed value ("ic_sda_setup") before
// releasing it. This applies for the Slave FSM moving from
// the WAIT_TX_DATA to the TX_LOOP state(transmit) or from
// the WAIT_RX_FULL to the RX_LOOP state(receive) states.
// ==========================================================
always @(posedge ic_clk or negedge ic_rst_n) begin : STRETCH_SCL_COUNT_PROC
  if(ic_rst_n==1'b0) begin
    stretch_scl_count <= 8'd0;
  end else begin
    if(slv_current_state==IDLE || slv_current_state==WAIT_TX_DATA || slv_current_state==INSPECT_DATA_CMD 
    )
      stretch_scl_count <= 8'd0;
    else if(slv_current_state==TX_LOOP
       )begin
      if(stretch_scl_count >= ic_sda_setup)
        stretch_scl_count <= {8{1'b1}};
      else
        stretch_scl_count <= stretch_scl_count + 8'd1;
    end // else if
  end // else ic_rst_n
end // always

   // ----------------------------------------------------------
   // -- FSM Flags
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_FSM_FLAGS_PROC
      if(ic_rst_n == 1'b0) begin
         
         slv_activity <= 1'b0;
         slv_tx_flush <= 1'b0;
         slv_rx_2addr <= 1'b0;
  
          end
        else 
          begin
             //slv flushed tx fifo buffer
             if ((slv_current_state == IDLE) 
                 || (slv_current_state == TX_LOOP)              
                 )
               begin
                  slv_tx_flush <= 1'b0;
               end
             
             else if((slv_current_state == RX_1BYTE) 
                     || (slv_current_state == RX10_2ND_ADDR)
                     || (slv_current_state == INSPECT_DATA_CMD))
               begin
                  slv_tx_flush <= slv_tx_abrt;
               end
             
             //slave activity flag
             if (slv_current_state != IDLE)
               begin
                  slv_activity <= 1'b1;
               end
             else
               slv_activity <= 1'b0;
             
             //10bit addr 2nd byte has been received
             if (slv_current_state == IDLE)                   
               begin
                  slv_rx_2addr <= 1'b0;
               end
             
             else if (slv_current_state == RX10_2ND_ADDR)
               begin
              slv_rx_2addr <= 1'b1;
               end

         
          end       
   end // block: FSM_FLAGS_PROC

   // ----------------------------------------------------
   // -- Slave addressed
   // -- Generate the signal which indicates the slave is addressed,
   // -- the slave is notified as addressed based on slave current state.
   // -- The slave is addressed on following conditions :
   // -- 7-bit address mode -> if address match in RX_1BYTE state, 
   // -- 10-bit address mode -> if address match in RX_1BYTE (MSB address) & RX10_2ND_ADDR (LSB address).

    always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_ADDRESSED_PROC
      if(ic_rst_n == 1'b0) begin
        slv_addressed <= 1'b0;
      end
      else begin
        if(p_det || s_det)
          slv_addressed <= 1'b0;
        else if(ic_10bit_slv_sync) begin
           if((rx_addr_match & slv_rx_2byte_en)
               || (slv_rx_2addr & rx_slv_read)
              )  // Check for address match in second address byte for all writes 
             slv_addressed <= 1'b1;                                               // If read happens, after second address, check in RX_1BYTE state 
        end
        else begin
          if(rx_addr_match & slv_rx_1byte_en) begin
             slv_addressed <= 1'b1;
          end
        end
      end
    end

 // ----------------------------------------------------------
   // -- Qualifier for setup count enable in RX_LOOP state after
   // holding the line in WAIT_RX_FULL state due to Receive fifo
   // full. 
   // This counter will ensure "scl_hld_low_en" is maintained
   // low for the programmed value ("ic_sda_setup") before
   // releasing it during the issue of data ACK phase. 
   // ------------------------------------------------------------


   // ----------------------------------
   // -- generate debug signals
   // ----------------------------------
   
   assign slv_debug_addr = ((slv_current_state == RX_1BYTE)
                            ||(slv_current_state == RX10_2ND_ADDR));
   
   assign slv_debug_data = ((slv_current_state == RX_LOOP)
                            ||(slv_current_state == TX_LOOP)
                           );

   assign slv_debug_cstate = slv_current_state;

   assign slv_tx_data_en = (slv_current_state == TX_LOOP) 
                            ;


endmodule // DW_apb_i2c_slvfsm
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #32 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c.v#32 $ 
//
//
// File    : DW_apb_i2c.v
//
//
// Abstract: The I2C module will perform as either a master or slave
//           on the I2C bus.  The I2C module is fully compliant.
//           Please refer to the databook for full details.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------
//
// Please refer to the databook for full details on the signals.
//
// These are found in the "Signal Description" section of the "Signals" chapter.
// There are details on the following
//   % Input Delays
//   % Output Delays
//   Any False Paths
//   Any Multicycle Paths
//   Any Asynchronous Signals
//
//==============================================================================
// Start License Usage
//==============================================================================
// Key Used   : DWC-APB-Advanced-Source (IP access)
//==============================================================================
// End License Usage
//==============================================================================

module DW_apb_i2c (

                   ic_start_det_intr,
                   ic_stop_det_intr,
                   ic_activity_intr,
                   ic_rx_done_intr,
                   ic_tx_abrt_intr,
                   ic_rd_req_intr,
                   ic_tx_empty_intr,
                   ic_tx_over_intr,
                   ic_rx_full_intr,
                   ic_rx_over_intr,
                   ic_rx_under_intr,
                   ic_gen_call_intr,
                   ic_current_src_en,
                   //APB Slave I/O Signals
                   pclk,
                   presetn,
                   psel,
                   penable,
                   pwrite,
                   paddr,
                   pwdata,
                   prdata,
                   pready,
                   pslverr,
                   ic_clk,
                   ic_clk_in_a,
                   ic_data_in_a,
                   ic_rst_n,
                   debug_s_gen,
                   debug_p_gen,
                   debug_data,
                   debug_addr,
                   debug_rd,
                   debug_wr,
                   debug_hs,
                   debug_master_act,
                   debug_slave_act,
                   debug_addr_10bit,
                   debug_mst_cstate,
                   debug_slv_cstate,
                   ic_clk_oe,
                   ic_data_oe,
                   ic_en
                   );

// ------------------------------------------------------
// -- Port declaration
// ------------------------------------------------------
// Inputs
  
   input pclk;    //# APB Clock Signal, used for the bus interface unit, can be asynchronous to the I2C clocks
  
   input presetn; //# APB Reset Signal (active low)

   input psel;    //# APB Peripheral Select Signal: lasts for two pclk cycles; when asserted indicates that the peripheral has been selected for read/write operation
   input penable; //# Strobe Signal: asserted for a single pclk cycle, used for timing read/write operations
   output pready;  //Slave ready: A low  on this APB3 signal stalls an APB transaction until signal goes high.
   output pslverr; //Slave error: A high on this APB3 signal indicates an error condition on the transfer.

   input pwrite;  //# Write Signal: when high indicates a write access to the peripheral; when low indicates a read access
   
   input [`IC_ADDR_SLICE_LHS:0] paddr; //# Address Bus: uses the lower 7 bits of the address bus for register decode, ignores bits 0 and 1 so that the 8 registers are on 32 bit boundaries
   
   input [`APB_DATA_WIDTH-1:0] pwdata;//Write Data Bus: driven by the
                                   // bus master (bridge unit)
                                   // during write cycles. Can
                                   // be 8,16,32 bits wide depending
                                   // on CoreConsultant parameter APB_DATA_WIDTH

   input                        ic_rst_n;

   input ic_clk; //I2C clock, used to clock transfers
                 // in standard, fast and high speed
                 // mode when this module is acting
                 // as master, can be asynchronous to pclk

   input ic_clk_in_a; //Incoming I2C clock:  Synchronous
                       // to i2c_clk when Master
                       // (except during slave acknowledge
                       // phase).  Asynchronous in when Slave.
                       // Synchronized with meta-stability techniques

   input ic_data_in_a; // Incoming I2C Data:  Asynchronous

  

   // OUTPUTS
   

//# APB read data bus.
//# Driven after the 1st APB cycle to align with the passing back of data to the AHB by the APB bridge.
//# Varies in size and can be 8, 16 or 32-bits wide.
   output [`APB_DATA_WIDTH-1:0] prdata;

   output                       ic_rx_over_intr;
   output                       ic_rx_under_intr;
   output                       ic_tx_over_intr;
   output                       ic_tx_abrt_intr;
   output                       ic_rx_done_intr;
   output                       ic_tx_empty_intr;
   output                       ic_activity_intr;
   output                       ic_stop_det_intr;


   output                       ic_start_det_intr;
   output                       ic_rd_req_intr;
   output                       ic_rx_full_intr;
   output                       ic_gen_call_intr;





   output                       debug_s_gen;
   output                       debug_p_gen;
   output                       debug_data;
   output                       debug_addr;
   output                       debug_rd;
   output                       debug_wr;
   output                       debug_hs;

   output                       ic_current_src_en;

//# Outgoing I2C clock: Open drain synchronous with i2c_clk
   output ic_clk_oe;
//# Outgoing I2C Data: Open Drain. Synchronous to i2c_clk
   output ic_data_oe;
//# ic_en indicates whether the I2C module is enabled. Some registers can only be programmed when the ic_en is set to 0. 
//# The fifo is flushed whenever the module is disabled. There is no need for the ic_clk when the module is disabled.
   output       ic_en;
//# To assist in the debug of any problems that may arise and also to give more visibility into the internals when running on silicon,
//# some internal states are brought out so that they can be viewed.. Very helpful considering the source code is generally encrypted.
   output       debug_master_act;
   output       debug_slave_act;
   output       debug_addr_10bit;
   output [4:0] debug_mst_cstate;
   output [3:0] debug_slv_cstate;

   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------

   //biu wires
   wire [`MAX_APB_DATA_WIDTH-1:0]  ipwdata;
   wire [`MAX_APB_DATA_WIDTH-1:0]  iprdata;
   wire                            wr_en;
   wire                            rd_en;
   wire [3:0]                      byte_en;
   wire [`IC_ADDR_SLICE_LHS-2:0]   reg_addr;

   //regfile wires
   wire                            rx_pop;         // rx fifo pop
   wire                            tx_push;        // tx fifo push
   wire                            fifo_rst_n;     // sync reset for fifo controllers
   wire                            tx_fifo_rst_n;  // sync reset for tx fifo
   wire                            ic_clr_intr_en;
   wire                            ic_clr_rx_under_en;
   wire                            ic_clr_rx_over_en;
   wire                            ic_clr_tx_over_en;
   wire                            ic_clr_rd_req_en;
   wire                            ic_clr_rx_done_en;
   wire                            ic_clr_tx_abrt_en;
   wire                            ic_clr_activity_en;
   wire                            ic_clr_stop_det_en;
   wire                            ic_clr_start_det_en;
   wire [`IC_TAR_RS_INT-1:0]       ic_tar;
   wire [`IC_SAR_RS-1:0]           ic_sar;
   wire [`IC_HS_MADDR_RS-1:0]      ic_hs_maddr;
   wire [`IC_FS_HCNT_RS-1:0]       ic_fs_hcnt;
   wire [`IC_FS_LCNT_RS-1:0]       ic_fs_lcnt;
   wire [`IC_INTR_MASK_RS-1:0]     ic_intr_mask;
   wire [`RX_ABW-1:0]              ic_rx_tl;
   wire [`IC_TX_TL_RS-1:0]         ic_tx_tl;
   wire [`IC_HS_HCNT_RS-1:0]       ic_hcnt;
   wire [`IC_HS_LCNT_RS-1:0]       ic_lcnt;
   wire                            ic_rstrt_en;    //logic 1:Master can generate re-starts in general
   // jduarte 20110105 begin
   // CRM 9000368180
   // Added register outputs for spike length, in ic_clk cycles
   // The value for FS and SS modes is the same (ic_fs_spklen)
   wire [`IC_SPKLEN_RS-1:0]        ic_spklen_o;
   wire [`IC_FS_SPKLEN_RS-1:0]     ic_fs_spklen;
   wire [`IC_HS_SPKLEN_RS-1:0]     ic_hs_spklen;
   // jduarte 20110105 end

   //fifo wires
   wire                            tx_empty;       // tx fifo empty status
   wire                            tx_almost_empty;// tx fifo almost empty status
   wire                            gen_tx_almost_empty;// tx fifo almost empty status
   wire                            tx_overflow;    // tx fifo overflow
   wire                            rx_almost_full; // rx fifo almost full status
   wire                            rx_overflow;    // rx fifo overflow
   wire                            rx_underflow;   // rx fifo underflow
   wire [`TX_ABW-1:0]              tx_wr_addr;     // tx fifo write pointer
   wire [`TX_ABW-1:0]              tx_rd_addr;     // tx fifo read pointer
   wire                            tx_we_n;        // tx fifo write enable
   wire [`RX_ABW-1:0]              rx_wr_addr;     // rx fifo write pointer
   wire [`RX_ABW-1:0]              rx_rd_addr;     // rx fifo read pointer
   wire                            rx_we_n;        // rx fifo write enable

   //ram wires
   wire [`IC_DATA_FIFO_RS-1:0]     rx_pop_data;
   wire [`IC_DATA_TX_CMD_RS-1:0]   tx_push_data;   // data to the tx fifo
   wire [`IC_DATA_TX_CMD_RS-1:0]   tx_pop_data;    // data from the tx fifo

   //internal inturrupt signal wires
   wire                             activity;
   wire                             mst_activity_sync;
   wire                             slv_activity_sync;

   // register decode wires
   wire [`IC_ENABLE_RS_INT-1:0]     ic_enable;
   wire                             ic_master;
   wire                             ic_10bit_mst;
   wire                             ic_10bit_slv;
   wire                             ic_hs;
   wire                             ic_fs;
   wire                             ic_ss;
   //rx_filter wires
   wire                             sda_vld;// SDA signal is valid
   wire                             s_det;// START condition detected
   wire                             p_det;// STOP condition detected
   wire                             p_det_intr;// STOP condition detected based on slave addressed or master active
   wire                             arb_lost;// When confgured as MSTR Arbitration lost
   wire                             slv_tx_shift_en;// shift enable pulse valid when falling
                                                    // edge detected on SCL signal
   wire                             ack_det;//ACK has been detected
   wire                             slv_ack_det;//ACK has been detected
   wire                             slv_rx_ack_vld;
   wire                             sda_int;//input SDA signal
   wire                             scl_int;//input scl signal

   wire                             scl_edg_hl;     // falling edge detect of SCL

   //signals feeding rx_filter from other ic_clk domain modules
   wire                             ic_dis_window;

   //clkgen wires
   wire                             scl_lcnt_cmplt;   //low count period has elapsed
   wire                             scl_hcnt_cmplt;   //high count period has elapsed
   wire                             scl_s_hld_cmplt;  //start hold period has elapsed
   wire                             scl_s_setup_cmplt;//start setup period has elapsed
   wire                             scl_p_setup_cmplt;//stop setup period has elapsed

   //signals feeding the clk_gen
   wire                             ic_enable_sync;     //IC module enable status sync to ic_clk
   wire                             ic_abort_sync;     //IC module abort status sync to ic_clk

   //mstfsm wires
   wire [`IC_DATA_RS-1:0]           mst_tx_data_buf_in; //data to be transmitted on sda data out
   wire                             start_en;           //Enable START condition
   wire                             re_start_en;        //Enable RE-START condition
   wire                             mst_tx_en;          //Enable tx shift register to transmit data
   wire                             split_start_en;     //SPLIT_START condition is in effect.
   wire                             mst_rx_en;          //Enable rx shift register to transmit data
   wire                             mst_gen_ack_en;     //Enable Ack gen. ckt
   wire                             mst_push_rxfifo_en; //logic 1:push received data to the RX fifo
   wire                             mst_txfifo_ld_en;   //load tx_buffer from the tx fifo output
   wire                             stop_en;            //Generate STOP condition
   wire                             hs_mcode_en;        //logic 1:master is in hs and transmitting the hs_mcode
   wire                             tx_empty_sync;      //tx_empty signal synchronized to ic_clk

   wire                             mst_tx_abrt;        //tx aborted
   wire                             mst_activity;       //master using the bus

// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
   wire                             abrt_in_rcve_trns;   //abort occured during receive transfer
   wire                             slv_tx_en;            // Enable tx shift register to transmit data
   wire                             slv_gen_ack_en;       // Enable Ack gen. ckt
   wire                             slv_tx_abrt;          // logic 1: master aborted TX transfer
   wire                             slv_rx_done;          // logic 1: master aborted RX transfer
   wire                             slv_txfifo_ld_en;     // load tx_buffer from the tx fifo wire
   wire                             scl_hld_low_en;       //logic 1: hold scl to low state (insert wait states)
   wire                             ic_rd_req;            //logic 1: Slave is waiting on data from the processor to tx

   //wires feeding mstfsm
   wire                             ic_bus_idle;        //logic 1: IC bus is idle

   //slvfsm wires
   wire                             slv_rx_en;            // Enable rx shift register to transmit data
   wire                             slv_push_rxfifo_en;
   wire                             slv_rx_1byte_en;      //logic 1: we are receiving the 1st byte of a transfer
   wire                             slv_rx_2byte_en;      //logic 1: we are receiving the 2nd byte of a transfer
   wire                             slv_activity;         //Slave is using the bus

   //signals feeding the slv fsm
   wire                             slv_rxbyte_rdy;
   wire                             rx_gen_call;
   wire                             rx_addr_match;
   wire                             rx_addr_10bit;
   wire                             rx_hs_mcode;
   wire                             slv_tx_cmplt;

   //rx shift  register wires
   wire                             rx_slv_read;       //logic 1: slave is written
   wire                             mst_rx_ack_vld;    //logic 1: check for ack now
   wire                             mst_rx_cmplt;
// jduarte begin 20101108
// CRM 9000366029
   wire                             rx_shift_data_done;
// jduarte end 20101108
   //to mst_fsm
   wire                             mst_rxbyte_rdy;    //logic 1: master received byte is ready
   //to clk_gen
   wire                             rx_scl_lcnt_en;
   wire                             rx_scl_hcnt_en;
   //tx shift register wires
   wire                             slv_tx_ack_vld;    //logic 1: check for ack now
   wire                             mst_tx_ack_vld;    //logic 1: check for ack now
   wire                             mst_rx_data_scl;
   //to clk_gen
   wire                             byte_wait_scl;
   //to fifo ram
   wire [`IC_DATA_FIFO_RS-1:0]      rx_push_data;      //push data to rx fifo
   //to fifo cntl
   wire                             rx_push;           //logic 1: push data to rx fifo
   //to top level
   wire                             rx_current_src_en; //logic 1: enables pull up current source in HS mode

   //to mst_fsm
   wire [`IC_DATA_TX_CMD_RS-1:0]    tx_fifo_data_buf;  //Buffer to hold data popped from tx fifo
   //to clk_gen
   wire                             scl_lcnt_en;       //enable low count period
   wire                             scl_hcnt_en;       //enable high count period
   wire                             scl_s_hld_en;      //Enable Start condition hold time counter
   wire                             scl_s_setup_en;    //Enable Start condition setup time counter
   wire                             scl_p_setup_en;    //Enable Stop condition hold time counter
   //to top level
   wire                             ic_clk_oe;//Drives the SCL line transistor
   wire                             tx_current_src_en;//1:enables pull up current source in HS mode
   //fifo cntl signals
   wire                             tx_pop;            //logic 1: pop data from TX fifo

   //intctl wires
   wire [`IC_INTR_STAT_RS-1:0]     ic_intr_stat;
   wire [`IC_RAW_INTR_STAT_RS-1:0] ic_raw_intr_stat;
   wire                            tx_abrt_flg_edg;
   wire                            ic_rx_over_intr;
   wire                            ic_rx_under_intr;
   wire                            ic_rx_full_intr;
   wire                            ic_tx_over_intr;
   wire                            ic_tx_abrt_intr;
   wire                            ic_rx_done_intr;
   wire                            ic_rd_req_intr;
   wire                            ic_tx_empty_intr;
   wire                            ic_gen_call_intr;
   wire                            ic_activity_intr;
   wire                            ic_stop_det_intr;
   wire                            ic_start_det_intr;

   //i2c_sync module wires
   wire                            ic_master_sync;    //logic 1: IC module is a Master
                                                      //logic 0: IC module is a Slave
   wire                            ic_10bit_slv_sync; //logic 1: IC Master 10-bit address transfer mode
                                                      //logic 0: IC Master 7-bit address transfer mode
   wire                            ic_hs_sync;        //logic 1: IC is in High Speed mode (3.4 Mb/s)
   wire                            ic_fs_sync;        //logic 1: IC is in Fast Speed mode (400 kb/s)
   wire                            ic_ss_sync;        //logic 1: IC is in Standard Speed mode (100 kb/s)
   wire                            ic_10bit_mst_sync; //logic 1: IC Slave 10-bit address transfer mode
                                                      //logic 0: IC Slave 7-bit address transfer mode
   wire                             ic_rstrt_en_sync; //logic 1: Master can generate re-starts in general

   //tx shift wires
   wire                            re_start_cmplt;
   wire                            stop_cmplt;
   wire                            mst_tx_cmplt;

   //debug wires
   wire                            mst_debug_data;
   wire                            mst_debug_addr;

   //top level wires
   wire                            ic_current_src_en;

//#
//# Although the DMA signals may not exist on the I/O, we need to create a placeholder to allow the code to compile.
//# That is why inputs (dma_tx_ack and dma_rx_ack) have a wire declared for themselves
//#
   wire                            mst_rxbyte_rdy_done;

   //toggle wires
   wire rx_done_flg;
   wire ic_rd_req_flg;
   wire tx_abrt_flg;
   wire ic_disable;
   wire p_det_flg;
   wire s_det_flg;
   wire rx_gen_call_flg;
   wire tx_pop_flg;
   wire rx_push_flg;
   wire tx_empty_sync_hl;
   wire ic_clr_gen_call_en;
   
   wire slv_tx_ready_unconn;
   wire mst_addr_state_unconn;

   wire ic_data_oe; //Outgoing I2C Data: Open Drain
                       // Synchronous to i2c_clk
   wire ic_data_oe_int; //Outgoing I2C Data: Open Drain
                       // Synchronous to i2c_clk
   wire [`IC_TX_ABRT_SOURCE_RS-1:0] tx_abrt_source;

   wire [`IC_TX_ABRT_SOURCE_RS-1:0] ic_tx_abrt_source;//tx_abrt sources combined signals

   /////////////////////////////
   //tx_abrt source
   wire                        abrt_master_dis;     // Access master while disabled
   wire                        abrt_sbyte_norstrt;  // Send SBYTE while restart is disabled
   wire                        abrt_hs_norstrt;     // High Speed mode while restart disabled
   wire                        abrt_hs_ackdet;      // High Speed Master code was acknowledged
   wire                        abrt_sbyte_ackdet;   // Start Byte was acknowleged
   wire                        abrt_gcall_read;     // Try to read while sending a Gcall
   wire                        abrt_7b_addr_noack;  // 7bit 1address was not acknowledged
   wire                        abrt_txdata_noack;   // Slave did not acknowledge sent data
   wire                        abrt_10addr1_noack;  // 10 bit 1address was not acknowledged
   wire                        abrt_10b_rd_norstrt; // 10 bit read command while restart is disabled
   wire                        abrt_10addr2_noack;  // 10 bit 2address was not acknowledged
   //slv tx_abrt source indicator
   wire                        abrt_slvflush_txfifo; // slave flush tx fifo to request tx data
   wire                        abrt_slv_arblost;     // Slave lost the bus while it is tx data
   wire                        abrt_slvrd_intx;      // Slave request data to tx and processor wrote
   wire                        abrt_user_abrt;      // user aborted

   // a read command into the tx_fifo (9th bit is 1)

   wire                        slv_debug_data;
   wire                        slv_debug_addr;
   wire                        ic_slave_en;
   wire                        ic_slave_en_sync;
   wire                        p_det_ifaddr;
   wire                        p_det_ifaddr_sync;
   wire                        slv_rx_2addr;
   wire                        tx_pop_sync;
   wire                        rx_push_sync;
   wire                        rx_full;
   wire                        tx_full;
   wire                        rx_empty;
   wire                        slv_rx_aborted;
   wire                        slv_fifo_filled_and_flushed;
   wire                        slv_rx_aborted_sync;
   wire                        slv_fifo_filled_and_flushed_sync;
   wire                        tx_empty_ctrl;

   wire [4:0] mst_debug_cstate;
   wire [3:0] slv_debug_cstate;
   wire [4:0] debug_mst_cstate;
   wire [3:0] debug_slv_cstate;
   wire       min_hld_cmplt;
   wire       abrt_gcall_noack;
   wire       slv_clr_leftover;
   wire       slv_clr_leftover_flg;
   wire       slv_clr_leftover_flg_edg;
   wire       mst_rx_bwen;
   wire       slv_addressed; // Qualifier signal to indicate the slave is addressed
   wire       set_tx_empty_en_flg;
   wire       set_tx_empty_en_flg_edg;

   wire [`IC_SDA_TX_HOLD_RS-1:0]         ic_sda_tx_hold_sync; //  Hold time value used when I2C acts as transmitter 
   wire [`IC_SDA_RX_HOLD_RS-1:0]      ic_sda_rx_hold_sync; // Hold time value used when I2C acts as reciever
   wire [`IC_SDA_HOLD_RS-1:0]  ic_sda_hold; // SDA hold register containing recieve hold time and transmit hold time values.
   wire                        ic_ack_general_call;
   wire [`IC_SDA_SETUP_RS-1:0] ic_sda_setup;
   wire                        ic_ack_general_call_sync;
   wire                        master_read;
   wire [3:0]                  mst_rx_bit_count;
   wire                        mstrx1_7_end;
   wire                        slv_tx_data_en;

   wire                        mst_txdata_state;
   wire                        set_tx_empty_en;
   wire                        penable_int;//# Internal PENABLE Signal
   

   assign ic_data_oe = ic_data_oe_int;

//#
//# Generates toggle flags for the signals travelling from the ic_clk to the pclk domain.
//# Looks for edges on signals to indicate a toggle then these edges can be detected as changes in pclk domain.
//#
   DW_apb_i2c_toggle
    U_DW_apb_i2c_toggle (
      //inputs
      .ic_rst_n(ic_rst_n),
                                          .ic_clk(ic_clk),
                                          .ic_rd_req(ic_rd_req),
                                          .mst_tx_abrt(mst_tx_abrt),
                                          .slv_tx_abrt(slv_tx_abrt),
                                          .slv_rx_done(slv_rx_done),
                                          .mst_activity(mst_activity),
                                          .slv_activity(slv_activity),
                                          .p_det(p_det_intr),
                                          .s_det(s_det),
                                          .rx_gen_call(rx_gen_call),
                                          .tx_pop(tx_pop),
                                          .rx_push(rx_push),
                                          .set_tx_empty_en(set_tx_empty_en),
                                          //master tx_abrt source indicators
                                          .abrt_master_dis(abrt_master_dis),     // Access master while disabled
                                          .abrt_sbyte_norstrt(abrt_sbyte_norstrt),  // Send SBYTE while restart is disabled
                                          .abrt_hs_norstrt(abrt_hs_norstrt),     // High Speed mode while restart disabled
                                          .abrt_hs_ackdet(abrt_hs_ackdet),      // High Speed Master code was acknowledged
                                          .abrt_sbyte_ackdet(abrt_sbyte_ackdet),   // Start Byte was acknowleged
                                          .abrt_gcall_read(abrt_gcall_read),     // Try to read while sending a Gcall
                                          .abrt_gcall_noack(abrt_gcall_noack),    // No slave acknowledged the G.CALL
                                          .abrt_7b_addr_noack(abrt_7b_addr_noack),  // 7bit 1address was not acknowledged
                                          .abrt_txdata_noack(abrt_txdata_noack),   // Slave did not acknowledge sent data
                                          .abrt_10addr1_noack(abrt_10addr1_noack),  // 10 bit 1address was not acknowledged
                                          .abrt_10b_rd_norstrt(abrt_10b_rd_norstrt), // 10 bit read command while restart is disabled
                                          .abrt_10addr2_noack(abrt_10addr2_noack),  // 10 bit 2address was not acknowledged
                                          .abrt_user_abrt(abrt_user_abrt),
                                          .arb_lost(arb_lost),
                                          .slv_clr_leftover(slv_clr_leftover),
                                          //slv tx_abrt source indicator
                                          .abrt_slvflush_txfifo(abrt_slvflush_txfifo), // Slave flush tx fifo to request tx data
                                          .abrt_slv_arblost(abrt_slv_arblost),     // Slave lost the bus while it is tx data
                                          .abrt_slvrd_intx(abrt_slvrd_intx),      // Slave request data to tx and processor wrote
                                          //debug inputs
                                          .tx_current_src_en(tx_current_src_en),
                                          .rx_current_src_en(rx_current_src_en),
                                          .start_en(start_en),
                                          .re_start_en(re_start_en),
                                          .stop_en(stop_en),
                                          .mst_debug_data(mst_debug_data),
                                          .mst_debug_addr(mst_debug_addr),
                                          .slv_debug_data(slv_debug_data),
                                          .slv_debug_addr(slv_debug_addr),
                                          .mst_rx_en(mst_rx_en),
                                          .mst_tx_en(mst_tx_en),
                                          .ic_enable_sync(ic_enable_sync),
                                          .ic_hs_sync(ic_hs_sync),
                                          .hs_mcode_en(hs_mcode_en),
                                          .rx_addr_10bit(rx_addr_10bit),
                                          .mst_debug_cstate(mst_debug_cstate),
                                          .slv_debug_cstate(slv_debug_cstate),
                                          .ic_dis_window(ic_dis_window),
                                          //outputs
                                          .debug_s_gen(debug_s_gen),
                                          .debug_p_gen(debug_p_gen),
                                          .debug_data(debug_data),
                                          .debug_addr(debug_addr),
                                          .debug_rd(debug_rd),
                                          .debug_wr(debug_wr),
                                          .debug_hs(debug_hs),
                                          .debug_master_act(debug_master_act),
                                          .debug_slave_act(debug_slave_act),
                                          .debug_addr_10bit(debug_addr_10bit),
                                          .debug_mst_cstate(debug_mst_cstate),
                                          .debug_slv_cstate(debug_slv_cstate),
                                          .ic_current_src_en(ic_current_src_en),
                                          .tx_abrt_flg(tx_abrt_flg),
                                          .ic_disable(ic_disable),
                                          .rx_done_flg(rx_done_flg),
                                          .ic_rd_req_flg(ic_rd_req_flg),
                                          .p_det_flg(p_det_flg),
                                          .s_det_flg(s_det_flg),
                                          .rx_gen_call_flg(rx_gen_call_flg),
                                          .tx_pop_flg(tx_pop_flg),
                                          .rx_push_flg(rx_push_flg),
                                          .tx_abrt_source(tx_abrt_source),
                                          .slv_clr_leftover_flg(slv_clr_leftover_flg),
                                          .set_tx_empty_en_flg(set_tx_empty_en_flg)
                                          );



   // Instantiation for the IC pclk to ic_clk synchronization module
   DW_apb_i2c_sync
    U_DW_apb_i2c_sync
     (
      .ic_rst_n(ic_rst_n),
      .ic_clk(ic_clk),
      //Signals from pclk domain
      .ic_enable(ic_enable),
      .ic_master(ic_master),
      .ic_10bit_mst(ic_10bit_mst),
      .ic_hs(ic_hs),
      .ic_fs(ic_fs),
      .ic_ss(ic_ss),
      .tx_empty(tx_empty),
      .ic_10bit_slv(ic_10bit_slv),
      .ic_rstrt_en(ic_rstrt_en),
      .ic_slave_en(ic_slave_en),
      .p_det_ifaddr(p_det_ifaddr),
      .ic_sda_hold(ic_sda_hold),
      .ic_ack_general_call(ic_ack_general_call),
      //signals to ic_clk domain
      .ic_10bit_slv_sync(ic_10bit_slv_sync),
      .ic_enable_sync(ic_enable_sync),
      .ic_abort_sync(ic_abort_sync),
      .ic_master_sync(ic_master_sync),
      .ic_hs_sync(ic_hs_sync),
      .ic_fs_sync(ic_fs_sync),
      .ic_ss_sync(ic_ss_sync),
      .p_det_ifaddr_sync(p_det_ifaddr_sync),
      .ic_10bit_mst_sync(ic_10bit_mst_sync),
      .tx_empty_sync(tx_empty_sync),
      .tx_empty_sync_hl(tx_empty_sync_hl),
      .ic_rstrt_en_sync(ic_rstrt_en_sync),
      .ic_slave_en_sync(ic_slave_en_sync),
      .ic_ack_general_call_sync(ic_ack_general_call_sync),
      .ic_sda_tx_hold_sync(ic_sda_tx_hold_sync),
      .ic_sda_rx_hold_sync(ic_sda_rx_hold_sync)      
      );


   // Instantiation for IC Interrupt Interface
   DW_apb_i2c_intctl
    U_DW_apb_i2c_intctl
     (
      // APB bus interface
      .pclk(pclk),
      .presetn(presetn),
      // DW_apb_i2c_biu interface
      .rd_en(rd_en),
      //from toggle.v
      .ic_disable(ic_disable),
      .tx_abrt_flg(tx_abrt_flg),
      .rx_done_flg(rx_done_flg),
      .ic_rd_req_flg(ic_rd_req_flg),
      .p_det_flg(p_det_flg),
      .s_det_flg(s_det_flg),
      .rx_gen_call_flg(rx_gen_call_flg),
      .slv_clr_leftover_flg(slv_clr_leftover_flg),
      .set_tx_empty_en_flg(set_tx_empty_en_flg),
      .gen_tx_almost_empty(gen_tx_almost_empty),
      .tx_abrt_source(tx_abrt_source),
      // internal i2c interrupt flags
      .rx_underflow(rx_underflow),
      .rx_overflow(rx_overflow),
      .rx_almost_full(rx_almost_full),
      .tx_overflow(tx_overflow),
      .tx_almost_empty(tx_almost_empty),
      .mst_activity(mst_activity),
      .slv_activity(slv_activity),
      .slv_rx_aborted(slv_rx_aborted),
      .slv_fifo_filled_and_flushed(slv_fifo_filled_and_flushed),
      .tx_empty_ctrl(tx_empty_ctrl),
      .ic_rx_under_intr(ic_rx_under_intr),
      .ic_rx_over_intr(ic_rx_over_intr),
      .ic_rx_full_intr(ic_rx_full_intr),
      .ic_tx_over_intr(ic_tx_over_intr),
      .ic_tx_empty_intr(ic_tx_empty_intr),
      .ic_rd_req_intr(ic_rd_req_intr),
      .ic_tx_abrt_intr(ic_tx_abrt_intr),
      .ic_rx_done_intr(ic_rx_done_intr),
      .ic_activity_intr(ic_activity_intr),
      .ic_stop_det_intr(ic_stop_det_intr),
      .ic_start_det_intr(ic_start_det_intr),
      .ic_gen_call_intr(ic_gen_call_intr),
      //regfile interface signals
      .ic_clr_intr_en(ic_clr_intr_en),
      .ic_clr_rx_under_en(ic_clr_rx_under_en),
      .ic_clr_rx_over_en(ic_clr_rx_over_en),
      .ic_clr_tx_over_en(ic_clr_tx_over_en),
      .ic_clr_rd_req_en(ic_clr_rd_req_en),
      .ic_clr_tx_abrt_en(ic_clr_tx_abrt_en),
      .ic_clr_rx_done_en(ic_clr_rx_done_en),
      .ic_clr_activity_en(ic_clr_activity_en),
      .ic_clr_stop_det_en(ic_clr_stop_det_en),
      .ic_clr_start_det_en(ic_clr_start_det_en),
      .ic_clr_gen_call_en(ic_clr_gen_call_en),
      .ic_enable(ic_enable[0]),
      .ic_intr_mask(ic_intr_mask),
      .ic_intr_stat(ic_intr_stat),
      .ic_raw_intr_stat(ic_raw_intr_stat),
      .tx_abrt_flg_edg(tx_abrt_flg_edg),
      //spyglass disable_block W528
      //SMD : A signal or variable is set but never read
      //SJ  : The slave clear left over flag is used to clear the Tx FIFO
      //      only during the non-UFM and non-async fifo mode. In other  
      //      configuration this will not be used. But there is no functional 
      //      issue, hence this can be waived.
      .slv_clr_leftover_flg_edg(slv_clr_leftover_flg_edg),
      //spyglass enable_block W528
      .set_tx_empty_en_flg_edg(set_tx_empty_en_flg_edg),
      .mst_activity_sync(mst_activity_sync),
      .slv_activity_sync(slv_activity_sync),
      .activity(activity),
      .ic_tx_abrt_source(ic_tx_abrt_source),
      .ic_ack_general_call(ic_ack_general_call),
      .slv_rx_aborted_sync(slv_rx_aborted_sync),
      .slv_fifo_filled_and_flushed_sync(slv_fifo_filled_and_flushed_sync),
      //to top level outputs
      .ic_en(ic_en)
      );



   // Instantiation for tx shift register
   DW_apb_i2c_tx_shift
    U_DW_apb_i2c_tx_shift
     (
      //top level
      .ic_clk(ic_clk),
      .ic_rst_n(ic_rst_n),
      //regfile
      .ic_hs_sync(ic_hs_sync),
      .ic_master_sync(ic_master_sync),
      .ic_sda_tx_hold_sync(ic_sda_tx_hold_sync), 
      .ic_spklen(ic_spklen_o),
      //mstfsm signals
      .mst_tx_en(mst_tx_en),
      .mst_rx_en(mst_rx_en),
      .mst_tx_data_buf_in(mst_tx_data_buf_in),
      .start_en(start_en),
      .re_start_en(re_start_en),
      .mst_txfifo_ld_en(mst_txfifo_ld_en),
      .tx_fifo_data_buf(tx_fifo_data_buf),
      .stop_en(stop_en),
      .mst_gen_ack_en(mst_gen_ack_en),
      .re_start_cmplt(re_start_cmplt),
      .stop_cmplt(stop_cmplt),
      .mst_tx_cmplt(mst_tx_cmplt),
      .byte_wait_scl(byte_wait_scl),
      // jduarte begin 20101008
      // CRM 9000366029
      // jduarte end 20101008
      //slvfsm signals
      .slv_txfifo_ld_en(slv_txfifo_ld_en),
      .slv_gen_ack_en(slv_gen_ack_en),
      .slv_tx_en(slv_tx_en),
      .scl_hld_low_en(scl_hld_low_en),
      //spyglass disable_block W528
      //SMD : A signal or variable is set but never read
      //SJ  : The Slave Tx ready is provided for the debugging purpose at 
      //      the top level file. But it is unused. But there is no functional 
      //      issue, hence this can be waived. 
      .slv_tx_ready(slv_tx_ready_unconn),
      //spyglass enable_block W528
      .slv_tx_cmplt(slv_tx_cmplt),
      .slv_tx_data_en(slv_tx_data_en),
      //clk_gen signals
      .hs_mcode_en(hs_mcode_en),
      .scl_lcnt_en(scl_lcnt_en),
      .scl_hcnt_en(scl_hcnt_en),
      .scl_s_hld_en(scl_s_hld_en),
      .scl_s_setup_en(scl_s_setup_en),
      .scl_p_setup_en(scl_p_setup_en),
      .scl_lcnt_cmplt(scl_lcnt_cmplt),
      .scl_hcnt_cmplt(scl_hcnt_cmplt),
      .scl_s_hld_cmplt(scl_s_hld_cmplt),
      .scl_s_setup_cmplt(scl_s_setup_cmplt),
      .scl_p_setup_cmplt(scl_p_setup_cmplt),
      //from rx_filter
      .arb_lost(arb_lost),
      .mst_tx_ack_vld(mst_tx_ack_vld),
      .slv_tx_shift_en(slv_tx_shift_en),
      .slv_tx_ack_vld(slv_tx_ack_vld),
      .scl_edg_hl(scl_edg_hl),
      .mst_txdata_state(mst_txdata_state),
      .master_read(master_read),
      .mst_rx_bit_count(mst_rx_bit_count),
      .mstrx1_7_end(mstrx1_7_end),
      .mst_rx_ack_vld(mst_rx_ack_vld),
      .mst_rx_data_scl(mst_rx_data_scl),
      .rx_scl_lcnt_en(rx_scl_lcnt_en),
      .rx_scl_hcnt_en(rx_scl_hcnt_en),
      .mst_rx_bwen(mst_rx_bwen),
      .slv_rx_ack_vld(slv_rx_ack_vld),
      //top level outputs
      .ic_clk_oe(ic_clk_oe),
      .ic_data_oe(ic_data_oe_int),
      .tx_current_src_en(tx_current_src_en),
      //fifo cntl signals
      .tx_pop(tx_pop),
      //fifo ram
      .tx_pop_data(tx_pop_data),
      //rx_filter
      .scl_int(scl_int),
      .set_tx_empty_en(set_tx_empty_en)
      );




   // Instantiation for rx shift register
   DW_apb_i2c_rx_shift
    U_DW_apb_i2c_rx_shift
     (
      .ic_clk(ic_clk)
      ,.ic_rst_n(ic_rst_n)
      ,//regfile
      .ic_hs_sync(ic_hs_sync)
      ,//mstfsm signals
      .mst_rx_en(mst_rx_en)
      ,.mst_push_rxfifo_en(mst_push_rxfifo_en)
      ,.mst_rxbyte_rdy(mst_rxbyte_rdy)
      ,.mst_rx_cmplt(mst_rx_cmplt)
      ,// jduarte end 20101008
      //slvfsm signals
      .slv_rx_en(slv_rx_en)
      ,.slv_rx_1byte_en(slv_rx_1byte_en)
      ,.slv_rx_2byte_en(slv_rx_2byte_en)
      ,.rx_slv_read(rx_slv_read)
      ,.slv_push_rxfifo_en(slv_push_rxfifo_en)
      ,.slv_rxbyte_rdy(slv_rxbyte_rdy)
      ,.rx_gen_call(rx_gen_call)
      ,.rx_addr_match(rx_addr_match)
      ,.rx_addr_10bit(rx_addr_10bit)
      ,.rx_hs_mcode(rx_hs_mcode)
      ,.slv_rx_2addr(slv_rx_2addr)
      ,//clk_gen signals
      .hs_mcode_en(hs_mcode_en)
      ,.rx_scl_lcnt_en(rx_scl_lcnt_en)
      ,.rx_scl_hcnt_en(rx_scl_hcnt_en)
      ,.scl_lcnt_cmplt(scl_lcnt_cmplt)
      ,.scl_hcnt_cmplt(scl_hcnt_cmplt)
      ,//from rx_filter
      .sda_int(sda_int)
      ,.sda_vld(sda_vld)
      ,.slv_rx_ack_vld(slv_rx_ack_vld)
      ,.scl_int(scl_int)
      ,.scl_edg_hl(scl_edg_hl)
      ,//rx shift reg
      .mst_rx_ack_vld(mst_rx_ack_vld)
      ,// jduarte begin 20101108
      // CRM 9000366029
      .rx_shift_data_done(rx_shift_data_done)
      ,// jduarte end 20101108
      //top level outputs
      .rx_current_src_en(rx_current_src_en)
      ,//fifo cntl signals
      .rx_push(rx_push)
      ,//regfile
      .ic_sar(ic_sar)
      ,.ic_10bit_slv(ic_10bit_slv)
      ,.ic_ack_general_call(ic_ack_general_call_sync)
      ,.mst_rxbyte_rdy_done(mst_rxbyte_rdy_done)
      ,//fifo ram
      .rx_push_data(rx_push_data)
      ,.mst_rx_bwen(mst_rx_bwen)
      ,.mst_rx_data_scl(mst_rx_data_scl)
      ,.mst_rx_bit_count(mst_rx_bit_count)
      ,.mstrx1_7_end(mstrx1_7_end)
      );

   // Instantiation for APB_Interface
   DW_apb_i2c_biu
    U_DW_apb_i2c_biu
     (
      .pclk(pclk),
      .presetn(presetn),
      .psel(psel),
      .penable(penable),
      .pwrite(pwrite),
      .paddr(paddr),
      .pwdata(pwdata),
      .iprdata(iprdata),
      .ipwdata(ipwdata),
      .prdata(prdata),
      .pready(pready),
      .pslverr(pslverr),
      .wr_en(wr_en),
      .rd_en(rd_en),
      .slave_rdy(slave_rdy),
      .slave_err(slave_err),
      .penable_int(penable_int),
      .byte_en(byte_en),
      .reg_addr(reg_addr)
      );

   // Instantiation for slave state machine
   DW_apb_i2c_slvfsm
    U_DW_apb_i2c_slvfsm
     (
      .ic_rst_n(ic_rst_n)
      ,.ic_clk(ic_clk)
      ,//Signals from pclk domain
      .ic_enable_sync(ic_enable_sync)
      ,.ic_10bit_slv_sync(ic_10bit_slv_sync)
      ,.tx_empty_sync(tx_empty_sync)
      ,.tx_empty_sync_hl(tx_empty_sync_hl)
      ,.ic_slave_en_sync(ic_slave_en_sync)
      ,.ic_sda_setup(ic_sda_setup)
      ,.ic_ack_general_call(ic_ack_general_call_sync)
      ,//signals to the int_cntl
      .slv_tx_abrt(slv_tx_abrt)
      ,.slv_rx_done(slv_rx_done)
      ,.ic_rd_req(ic_rd_req)
      ,.slv_rx_aborted(slv_rx_aborted)
      ,.slv_fifo_filled_and_flushed(slv_fifo_filled_and_flushed)
      ,//rx filter signals
      .arb_lost(arb_lost)
      ,.s_det(s_det)
      ,.p_det(p_det)
      ,.slv_ack_det(slv_ack_det)
      ,.slv_rx_ack_vld(slv_rx_ack_vld)
      ,//Tx shift reg signals
      .slv_tx_en(slv_tx_en)
      ,.slv_rx_en(slv_rx_en)
      ,.slv_txfifo_ld_en(slv_txfifo_ld_en)
      ,.tx_fifo_dbuf_8(tx_fifo_data_buf[8])
      ,.slv_gen_ack_en(slv_gen_ack_en)
      ,.scl_hld_low_en(scl_hld_low_en)
      ,.ic_data_oe(ic_data_oe)
      ,//Rx shift reg signals
      .slv_rxbyte_rdy(slv_rxbyte_rdy)
      ,.rx_gen_call(rx_gen_call)
      ,.rx_addr_match(rx_addr_match)
      ,.rx_slv_read(rx_slv_read)
      ,.slv_rx_1byte_en(slv_rx_1byte_en)
      ,.slv_rx_2byte_en(slv_rx_2byte_en)
      ,.slv_push_rxfifo_en(slv_push_rxfifo_en)
      ,.slv_tx_cmplt(slv_tx_cmplt)
      ,.slv_rx_2addr(slv_rx_2addr)
      //slv tx_abrt source indicator
      ,.abrt_slvflush_txfifo(abrt_slvflush_txfifo)//slave flush tx fifo to request tx data
      ,.abrt_slv_arblost(abrt_slv_arblost)//Slave lost the bus while it is tx data
      ,.abrt_slvrd_intx(abrt_slvrd_intx)//Slave request data to tx and processor wrote
      ,//misc.
      .slv_debug_addr(slv_debug_addr)
      ,.slv_debug_data(slv_debug_data)
      ,.slv_activity(slv_activity)
      ,.slv_clr_leftover(slv_clr_leftover)
      ,.slv_debug_cstate(slv_debug_cstate)      
      ,.slv_addressed(slv_addressed)
      ,.slv_tx_data_en(slv_tx_data_en)
      );

   // Instantiation for the master state machine
   DW_apb_i2c_mstfsm
    U_DW_apb_i2c_mstfsm
     (
      .ic_rst_n(ic_rst_n),
      .ic_clk(ic_clk),
      //Signals from pclk domain
      .ic_enable_sync(ic_enable_sync),
      .ic_abort_sync(ic_abort_sync),
      .ic_master_sync(ic_master_sync),
      .ic_10bit_mst_sync(ic_10bit_mst_sync),
      .ic_hs_sync(ic_hs_sync),
      .tx_empty_sync(tx_empty_sync),
      .tx_empty_sync_hl(tx_empty_sync_hl),
      .ic_rstrt_en_sync(ic_rstrt_en_sync),
      //signals to the int_cntl
      .mst_tx_abrt(mst_tx_abrt),
      //rx filter signals
      .ic_bus_idle(ic_bus_idle),
      .arb_lost(arb_lost),
      .ack_det(ack_det),
      //Tx shift reg signals
      .mst_tx_en(mst_tx_en),
      .mst_rx_en(mst_rx_en),
      .mst_tx_data_buf_in(mst_tx_data_buf_in),
      .start_en(start_en),
      .split_start_en(split_start_en),
      .re_start_en(re_start_en),
      .mst_txfifo_ld_en(mst_txfifo_ld_en),
      .tx_fifo_data_buf(tx_fifo_data_buf),
      .stop_en(stop_en),
      .mst_gen_ack_en(mst_gen_ack_en),
      .start_cmplt(scl_s_hld_cmplt),
      .re_start_cmplt(re_start_cmplt),
      .stop_cmplt(stop_cmplt),
      .mst_tx_cmplt(mst_tx_cmplt),
      .ic_dis_window(ic_dis_window),
      //clk_gen signals
      .hs_mcode_en(hs_mcode_en),
      .byte_wait_scl(byte_wait_scl),
      .min_hld_cmplt(min_hld_cmplt),
      .scl_lcnt_cmplt(scl_lcnt_cmplt),
      //Rx shift reg signals
      .mst_rxbyte_rdy(mst_rxbyte_rdy),
      .mst_push_rxfifo_en(mst_push_rxfifo_en),
      .mst_rx_cmplt(mst_rx_cmplt),
      // jduarte begin 20101108
      // CRM 9000366029
      .rx_shift_data_done(rx_shift_data_done),
      .mst_rxbyte_rdy_done(mst_rxbyte_rdy_done),
      // jduarte end 20101108
      //signals from the reg file
      .ic_hs_maddr(ic_hs_maddr),
      .ic_tar(ic_tar),
      //slvfsm signals
      .ic_rd_req(ic_rd_req),
      //misc
      .mst_activity(mst_activity),
      // jduarte begin 20101008
      // CRM 9000366029
      // jduarte end 20101008
      .abrt_in_rcve_trns(abrt_in_rcve_trns),
      //tx_abrt source indicators
      .abrt_master_dis(abrt_master_dis),//Access master while disabled
      .abrt_sbyte_norstrt(abrt_sbyte_norstrt),//Send SBYTE while restart is disabled
      .abrt_hs_norstrt(abrt_hs_norstrt),//High Speed mode while restart disabled
      .abrt_hs_ackdet(abrt_hs_ackdet),//High Speed Master code was acknowledged
      .abrt_sbyte_ackdet(abrt_sbyte_ackdet),//Start Byte was acknowleged
      .abrt_gcall_read(abrt_gcall_read),//Try to read while sending a Gcall
      .abrt_gcall_noack(abrt_gcall_noack),//No slave acknowledged the G.CALL
      .abrt_7b_addr_noack(abrt_7b_addr_noack),//7bit 1address was not acknowledged
      .abrt_txdata_noack(abrt_txdata_noack),//Slave did not acknowledge sent data
      .abrt_10addr1_noack(abrt_10addr1_noack),//10 bit 1address was not acknowledged
      .abrt_10b_rd_norstrt(abrt_10b_rd_norstrt),//10 bit read command while restart is disabled
      .abrt_10addr2_noack(abrt_10addr2_noack),//10 bit 2address was not acknowledged
      .abrt_user_abrt(abrt_user_abrt),
      //spyglass disable_block W528
      //SMD : A signal or variable is set but never read
      //SJ  : The Master address state is provided for the debugging purpose at 
      //      the top level file. But it is unused. But there is no functional 
      //      issue, hence this can be waived. 
      .mst_addr_state(mst_addr_state_unconn),
      //spyglass enable_block W528
      .mst_txdata_state(mst_txdata_state),
      .master_read(master_read),
      //top level signals
      .mst_debug_addr(mst_debug_addr),
      .mst_debug_data(mst_debug_data),
      .mst_debug_cstate(mst_debug_cstate)
      );

   // Instantiation for rx_filter
   DW_apb_i2c_rx_filter
    U_DW_apb_i2c_rx_filter
     (
      //top level signals
      .ic_clk(ic_clk),
      .ic_rst_n(ic_rst_n),
      .ic_clk_in_a(ic_clk_in_a),
      .ic_data_in_a(ic_data_in_a),
      .ic_data_oe(ic_data_oe_int),
      //tx shift register signals
      .slv_tx_ack_vld(slv_tx_ack_vld),
      .mst_tx_ack_vld(mst_tx_ack_vld),
      .mst_rx_ack_vld(mst_rx_ack_vld),
      .slv_tx_shift_en(slv_tx_shift_en),
      //clk_gen signals
      .sda_int(sda_int),
      .scl_int(scl_int),
      //reg file signals
      .ic_hs_sync(ic_hs_sync),
      .ic_fs_sync(ic_fs_sync),
      .p_det_ifaddr_sync(p_det_ifaddr_sync),
      // jduarte 20110105 begin
      // CRM 9000368180
      // Added register outputs for spike length, in ic_clk cycles
      // The value for FS and SS modes is the same (ic_fs_spklen)
      .ic_hs_spklen(ic_hs_spklen),
      .ic_fs_spklen(ic_fs_spklen),
      .ic_master_sync(ic_master_sync),
      .ic_sda_rx_hold_sync(ic_sda_rx_hold_sync),
      .hs_mcode_en(hs_mcode_en),
      .rx_hs_mcode(rx_hs_mcode),
      .ic_spklen_o(ic_spklen_o),
      // jduarte 20110105 end
      //mstfsm signals
      .stop_en(stop_en),
      .start_en(start_en),
      .re_start_en(re_start_en),
      .split_start_en(split_start_en),
      .mst_tx_en(mst_tx_en),
      .mst_rx_en(mst_rx_en),
      .mst_activity(mst_activity),
      //slvfsm signals
      .slv_tx_en(slv_tx_en),
      .slv_activity(slv_activity),
      //misc.
      .sda_vld(sda_vld),
      .s_det(s_det),
      .p_det(p_det),
      .p_det_intr(p_det_intr),
      .arb_lost(arb_lost),
      .ack_det(ack_det),
      .slv_ack_det(slv_ack_det),
      .scl_edg_hl(scl_edg_hl),
      .slv_addressed(slv_addressed)
      );


   // Instantiation for clk_gen
   DW_apb_i2c_clk_gen
    U_DW_apb_i2c_clk_gen (
     //top level signals
     .ic_clk(ic_clk),
                                            .ic_rst_n(ic_rst_n),
                                            .ic_master_sync(ic_master_sync),
                                            //rx_filter signal
                                            .sda_int(sda_int),
                                            .scl_int(scl_int),
                                            .s_det(s_det),
                                            .p_det(p_det),
                                            //inputs from regfile
                                            .ic_hcnt(ic_hcnt),
                                            .ic_lcnt(ic_lcnt),
                                            .ic_fs_lcnt(ic_fs_lcnt),
                                            .ic_fs_hcnt(ic_fs_hcnt),
                                            .ic_hs_sync(ic_hs_sync),
                                            .ic_fs_sync(ic_fs_sync),
                                            .ic_ss_sync(ic_ss_sync),
                                            .ic_fs_spklen(ic_fs_spklen),
                                            //mstfsm signals
                                            .ic_enable_sync(ic_enable_sync),
                                            .ic_bus_idle(ic_bus_idle),
                                            .min_hld_cmplt(min_hld_cmplt),
                                            //rx_shift_reg signals
                                            .hs_mcode_en(hs_mcode_en),
                                            .scl_lcnt_en(scl_lcnt_en),
                                            .scl_hcnt_en(scl_hcnt_en),
                                            .scl_s_hld_en(scl_s_hld_en),
                                            .scl_s_setup_en(scl_s_setup_en),
                                            .scl_p_setup_en(scl_p_setup_en),
                                            .rx_scl_lcnt_en(rx_scl_lcnt_en),
                                            .rx_scl_hcnt_en(rx_scl_hcnt_en),
                                            //outputs to tx/rx shift registers
                                            .scl_lcnt_cmplt(scl_lcnt_cmplt),
                                            .scl_hcnt_cmplt(scl_hcnt_cmplt),
                                            .scl_s_hld_cmplt(scl_s_hld_cmplt),
                                            .scl_s_setup_cmplt(scl_s_setup_cmplt),
                                            .scl_p_setup_cmplt(scl_p_setup_cmplt)
                                            );

   // Instantiation for IC register file
   DW_apb_i2c_regfile
    U_DW_apb_i2c_regfile (
     // APB bus interface
     .pclk(pclk),
                                            .presetn(presetn),
                                            // DW_apb_i2c_biu interface
                                            .wr_en(wr_en),
                                            .rd_en(rd_en),
                                            .slave_rdy(slave_rdy),
                                            .slave_err(slave_err),
                                            .penable_int(penable_int),
                                            .byte_en(byte_en),
                                            .reg_addr(reg_addr),
                                            .ipwdata(ipwdata),
                                            .iprdata(iprdata),
                                            .ic_enable(ic_enable),
                                            // DW_i2c_intctl interface
                                            .ic_clr_intr_en(ic_clr_intr_en),
                                            .ic_clr_rx_under_en(ic_clr_rx_under_en),
                                            .ic_clr_rx_over_en(ic_clr_rx_over_en),
                                            .ic_clr_tx_over_en(ic_clr_tx_over_en),
                                            .ic_clr_rd_req_en(ic_clr_rd_req_en),
                                            .ic_clr_tx_abrt_en(ic_clr_tx_abrt_en),
                                            .ic_clr_rx_done_en(ic_clr_rx_done_en),
                                            .ic_clr_activity_en(ic_clr_activity_en),
                                            .ic_clr_stop_det_en(ic_clr_stop_det_en),
                                            .ic_clr_start_det_en(ic_clr_start_det_en),
                                            .ic_clr_gen_call_en(ic_clr_gen_call_en),
                                            .mst_activity(mst_activity_sync),
                                            .slv_activity(slv_activity_sync),
                                            .activity(activity),
                                            .ic_tx_abrt_source(ic_tx_abrt_source),
                                            .psel(psel),
                                            //register value output
                                            .ic_tar(ic_tar),
                                            .ic_sar(ic_sar),
                                            .ic_hs_maddr(ic_hs_maddr),
                                            .ic_hcnt(ic_hcnt),
                                            .ic_lcnt(ic_lcnt),
                                            .ic_fs_hcnt(ic_fs_hcnt),
                                            .ic_fs_lcnt(ic_fs_lcnt),
                                            // jduarte 20110105 begin
                                            // CRM 9000368180
                                            // Added register outputs for spike length, in ic_clk cycles
                                            // The value for FS and SS modes is the same (ic_fs_spklen)
                                            .ic_hs_spklen(ic_hs_spklen),
                                            .ic_fs_spklen(ic_fs_spklen),
                                            // jduarte 20110105 end
                                            .ic_rx_tl_int(ic_rx_tl),
                                            .ic_tx_tl(ic_tx_tl),
                                            //register value input from intctl module
                                            .ic_intr_mask(ic_intr_mask),
                                            .ic_intr_stat(ic_intr_stat),
                                            .ic_raw_intr_stat(ic_raw_intr_stat),
                                            .ic_en(ic_en),
                                            .slv_rx_aborted_sync(slv_rx_aborted_sync),
                                            .slv_fifo_filled_and_flushed_sync(slv_fifo_filled_and_flushed_sync),
                                            //control signals
                                            .ic_hs(ic_hs),
                                            .ic_fs(ic_fs),
                                            .ic_ss(ic_ss),
                                            .ic_master(ic_master),
                                            .ic_10bit_mst(ic_10bit_mst),
                                            .ic_10bit_slv(ic_10bit_slv),
                                            .ic_slave_en(ic_slave_en),
                                            .p_det_ifaddr(p_det_ifaddr),
                                            // DW_i2c_fifo interfacs
                                            .rx_pop_data(rx_pop_data),
                                            .tx_push_data(tx_push_data),
                                            .fifo_rst_n(fifo_rst_n),
                                            .tx_fifo_rst_n(tx_fifo_rst_n),
                                            .tx_pop_sync(tx_pop_sync),
                                            .rx_push_sync(rx_push_sync),
                                            .rx_pop(rx_pop),
                                            .tx_push(tx_push),
                                            .tx_empty(tx_empty),
                                            .rx_full(rx_full),
                                            .tx_full(tx_full),
                                            .rx_empty(rx_empty),
                                            //misc
                                            .tx_abrt_flg_edg(tx_abrt_flg_edg),
                                            .abrt_in_rcve_trns(abrt_in_rcve_trns),
                                            .slv_clr_leftover_flg_edg(slv_clr_leftover_flg_edg),
                                            .ic_rstrt_en(ic_rstrt_en),
                                            .ic_sda_setup(ic_sda_setup),
                                            .ic_sda_hold(ic_sda_hold),
                                            .ic_ack_general_call(ic_ack_general_call),
                                            .tx_empty_ctrl(tx_empty_ctrl)
                                            );

   // Instantiation for IC FIFO Controller
   DW_apb_i2c_fifo
    U_DW_apb_i2c_fifo (
     .pclk            (pclk),
     .presetn         (presetn),
     .fifo_rst_n      (fifo_rst_n),
     .tx_fifo_rst_n   (tx_fifo_rst_n),
     .set_tx_empty_en_flg_edg (set_tx_empty_en_flg_edg),

     .ic_tx_tl        (ic_tx_tl),
     .tx_push         (tx_push),
     .rx_pop          (rx_pop),
     .tx_pop_flg      (tx_pop_flg),
     .tx_pop_sync     (tx_pop_sync),
     .tx_empty        (tx_empty),
     .rx_full         (rx_full),
     .tx_full         (tx_full),
     .tx_almost_empty (tx_almost_empty),
     .gen_tx_almost_empty (gen_tx_almost_empty),
     .tx_overflow     (tx_overflow),
     .tx_wr_addr      (tx_wr_addr),
     .tx_rd_addr      (tx_rd_addr),
     .tx_we_n         (tx_we_n),

     .ic_rx_tl        (ic_rx_tl),
     .rx_push_flg     (rx_push_flg),
     .rx_push_sync    (rx_push_sync),
     .rx_empty        (rx_empty),
     .rx_almost_full  (rx_almost_full),
     .rx_overflow     (rx_overflow),
     .rx_underflow    (rx_underflow),
     .rx_wr_addr      (rx_wr_addr),
     .rx_rd_addr      (rx_rd_addr),
     .rx_we_n         (rx_we_n)
   );

   
   // Instantiation for IC FIFO Controller




   // Receive FIFO RAM block
   DW_apb_i2c_bcm57
    #(`IC_DATA_FIFO_RS, `IC_RX_BUFFER_MOD_DEPTH, 0, `RX_ABW) U_dff_rx (
     .clk                  (pclk),
     .rst_n                (presetn),
     .wr_addr              (rx_wr_addr),
     .rd_addr              (rx_rd_addr),
     .data_in              (rx_push_data),
     .wr_n                 (rx_we_n),
     .data_out             (rx_pop_data)
   );

   // Transmit FIFO RAM block
   DW_apb_i2c_bcm57
    #(`IC_DATA_TX_CMD_RS, `IC_TX_BUFFER_MOD_DEPTH, 0, `TX_ABW) U_dff_tx (
     .clk                  (pclk),
     .rst_n                (presetn),
     .wr_addr              (tx_wr_addr),
     .rd_addr              (tx_rd_addr),
     .data_in              (tx_push_data),
     .wr_n                 (tx_we_n),
     .data_out             (tx_pop_data)
   );

//-----------------------------------------------------------
//--CRC Generation/Validity check module
//--This module Generates/Validity check of the PEC byte for
//--Address Resolution Protocol commands.
//--SMBus supports ATM Header CRC : X8 + x2 + x1 + 1 = 263
//------------------------------------------------------------

endmodule

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm57.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm57.v#11 $
// Author      : Rick Kelly    April 26, 2004
// Description : DW_apb_i2c_bcm57.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: 08e40b25
//
////////////////////////////////////////////////////////////////////////////////



  module DW_apb_i2c_bcm57 (
        clk,
        rst_n,
        wr_n,
        data_in,
        wr_addr,
        rd_addr,
        data_out
        );

   parameter DATA_WIDTH = 4;    // RANGE 1 to 256
   parameter DEPTH = 8;         // RANGE 2 to 256
   parameter MEM_MODE = 0;      // RANGE 0 to 3
   parameter ADDR_WIDTH = 3;    // RANGE 1 to 8

   input                        clk;            // clock input
   input                        rst_n;          // active low async. reset
   input                        wr_n;           // active low RAM write enable
   input [DATA_WIDTH-1:0]       data_in;        // RAM write data input bus
   input [ADDR_WIDTH-1:0]       wr_addr;        // RAM write address bus
   input [ADDR_WIDTH-1:0]       rd_addr;        // RAM read address bus

   output [DATA_WIDTH-1:0]      data_out;       // RAM read data output bus


   reg [DATA_WIDTH-1:0]         mem [0 : DEPTH-1];

  wire [ADDR_WIDTH-1:0]         write_addr;
  wire                          wr_n_int;
  wire                          write_en_n;
  wire [DATA_WIDTH-1:0]         write_data;
  wire [ADDR_WIDTH-1:0]         read_addr;
  wire [DATA_WIDTH-1:0]         read_data;

  localparam [ADDR_WIDTH-1:0]   MAX_ADDR = DEPTH-1;
   
generate
  if ( DEPTH != (1 << ADDR_WIDTH) ) begin : GEN_NONPWR2_DPTH
// If read address is out of range of RAM DEPTH, then produce all zeros for read data
    assign read_data = (rd_addr <= MAX_ADDR) ? mem[read_addr] : {DATA_WIDTH{1'b0}};

    assign wr_n_int = (wr_addr <= MAX_ADDR) ? wr_n : 1'b1;
  end else begin : GEN_PWR2_DPTH
    assign read_data = mem[read_addr];
    assign wr_n_int = wr_n;
  end
endgenerate

  always @ (posedge clk or negedge rst_n) begin : mem_array_regs_PROC
    integer i;
    if (rst_n == 1'b0) begin
      for (i=0 ; i < DEPTH ; i=i+1)
        mem[i] <= {DATA_WIDTH{1'b0}};
    end else begin
      if (write_en_n == 1'b0)
// spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ: This module can be specifically configured/implemented with only a synchronous reset or no resets at all.
        mem[write_addr] <= write_data;
// spyglass enable_block STARC-2.3.4.3
    end
  end

generate
  if ((MEM_MODE & 1) == 1) begin : GEN_RDDAT_REG
    reg [DATA_WIDTH-1:0] data_out_pipe;

    always @ (posedge clk or negedge rst_n) begin : retiming_rddat_reg_PROC
      if (rst_n == 1'b0) begin
        data_out_pipe <= {DATA_WIDTH{1'b0}};
      end else begin
        data_out_pipe <= read_data;
      end
    end

    assign data_out = data_out_pipe;
  end else begin : GEN_MM_NE_1
    assign data_out = read_data;
  end
endgenerate

generate
  if ((MEM_MODE & 2) == 2) begin : GEN_INPT_REGS
    reg                  we_pipe;
    reg [ADDR_WIDTH-1:0] wr_addr_pipe;
    reg [DATA_WIDTH-1:0] data_in_pipe;
    reg [ADDR_WIDTH-1:0] rd_addr_pipe;

    always @ (posedge clk or negedge rst_n) begin : retiming_regs_PROC
      if (rst_n == 1'b0) begin
        we_pipe <= 1'b0;
        wr_addr_pipe <= {ADDR_WIDTH{1'b0}};
        data_in_pipe <= {DATA_WIDTH{1'b0}};
        rd_addr_pipe <= {ADDR_WIDTH{1'b0}};
      end else begin
        we_pipe <= wr_n_int;
        wr_addr_pipe <= wr_addr;
        data_in_pipe <= data_in;
        rd_addr_pipe <= rd_addr;
      end
    end

    assign write_en_n = we_pipe;
    assign write_data = data_in_pipe;
    assign write_addr = wr_addr_pipe;
    assign read_addr  = rd_addr_pipe;
  end else begin : GEN_MM_NE_2
    assign write_en_n = wr_n_int;
    assign write_data = data_in;
    assign write_addr = wr_addr;
    assign read_addr  = rd_addr;
  end
endgenerate



endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #28 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_mstfsm.v#28 $ 
//
//
// File    : DW_apb_i2c_mstfsm.v
//
//
// Author  : Hani Saleh
// Created : Sep, 2002
// Abstract: I2C Master Control will be active when the I2C module is
//           configured for master mode of operation as defined by the
//           mode control bit.  This module will control: 
//           master-receiver or master-transmit functions in either
//           the 7-bit or 10-bit mode as defined by the ic_con 
///
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

// -----------------------------------------------------------
// -- Macros
// -----------------------------------------------------------


module DW_apb_i2c_mstfsm
  (
   ic_rst_n,
                           ic_clk,
                           //Signals from pclk domain
                           ic_enable_sync,
                           ic_abort_sync,
                           ic_master_sync,
                           ic_10bit_mst_sync,
                           ic_hs_sync,
                           tx_empty_sync,
                           tx_empty_sync_hl,
                           ic_rstrt_en_sync,
                           //signals to the int_cntl
                           mst_tx_abrt,
                           //rx filter signals
                           ic_bus_idle,
                           arb_lost,
                           ack_det,
                           //Tx shift reg signals
                           mst_tx_en,
                           mst_rx_en,
                           mst_tx_data_buf_in,
                           start_en,
                           re_start_en,
                           split_start_en,
                           mst_txfifo_ld_en,
                           tx_fifo_data_buf,
                           stop_en,
                           mst_gen_ack_en,
                           start_cmplt,   
                           re_start_cmplt,   
                           stop_cmplt,
                           mst_tx_cmplt,
                           byte_wait_scl,
                           ic_dis_window,
                           //clk_gen signals
                           hs_mcode_en,
                           min_hld_cmplt,
                           scl_lcnt_cmplt,
                           //Rx shift reg signals
                           mst_rxbyte_rdy,
                           mst_rxbyte_rdy_done,
                           mst_push_rxfifo_en,
                           mst_rx_cmplt,
                           // jduarte begin 20101108
                           // CRM 9000366029
                           rx_shift_data_done,
                           // jduarte end 20101108
                           //signals from the reg file
                           ic_hs_maddr,
                           ic_tar,
                           //slvfsm signals
                           ic_rd_req,
                           //misc signals
                           mst_activity,
                           // jduarte begin 20101008
                           // CRM 9000366029
                           // jduarte end 20101008
                           abrt_in_rcve_trns, 
                           //tx_abrt source indicators
                           abrt_master_dis,//Access master while disabled
                           abrt_sbyte_norstrt,//Send SBYTE while restart is disabled
                           abrt_hs_norstrt,//Hisgh Speed mode while restart disabled
                           abrt_hs_ackdet,//High Speed Master code was acknowledged
                           abrt_sbyte_ackdet,//Start Byte was acknowleged
                           abrt_gcall_read,//Try to read while sending a Gcall
                           abrt_gcall_noack,//No slave acknowledged the G.CALL
                           abrt_7b_addr_noack,//7bit 1address was not acknowledged
                           abrt_txdata_noack,//Slave did not acknowledge sent data
                           abrt_10addr1_noack,//10 bit 1address was not acknowledged
                           abrt_10b_rd_norstrt,//10 bit read command while restart is disabled
                           abrt_10addr2_noack,//10 bit 2address was not acknowledged
                           abrt_user_abrt,
                           mst_addr_state,
                           mst_txdata_state,
                           master_read,
                           //top level debug signals
                           mst_debug_addr,
                           mst_debug_data,
                           mst_debug_cstate
                           );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;    // module clock: runs i2c module
   input ic_rst_n;  // asynchronous reset input active low
   
   input ic_enable_sync; // logic 1: enable i2c module
   input ic_abort_sync; // logic 1: abort i2c module
   input ic_master_sync; //logic 1: IC module is a Master; logic 0: slave
   input ic_10bit_mst_sync; // logic 1: IC 10-bit address transfer mode
                       // logic 0: IC 7-bit address transfer mode
   input ic_hs_sync;  //logic 1: IC is in High Speed mode (3.4 Mb/s)
   input ic_bus_idle; //logic 1: IC bus is idle
   input tx_empty_sync; // tx fifo empty
   input tx_empty_sync_hl;//logic 1:high to low edge detection of tx_empty_sync
   input ic_rstrt_en_sync;//logic 1:Master can generate re-starts in general
   
   input arb_lost;   // logic 1: master lost arbitration
   input ack_det;    // logic 1: acknowledge detected
   input mst_rxbyte_rdy; //Indicates that a byte has been received
   input mst_rxbyte_rdy_done; //Indicates that a byte has been received in the hold_rx_byte state
   input [`IC_HS_MADDR_RS-1:0] ic_hs_maddr;//the master address code register value
   input [`IC_TAR_RS_INT-1:0]  ic_tar;//the target slave address register
   input [`IC_DATA_TX_CMD_RS-1:0] tx_fifo_data_buf;//Buffer to hold data popped from tx fifo
   input                       start_cmplt;//logic 1:start condition has been generated               
   input                       re_start_cmplt;//logic 1: restart condition has been generated                
   input                       stop_cmplt;//logic 1:stop condition has been generated         
   input                       mst_tx_cmplt;//logic 1:master bit transmission is finished             
   input                       mst_rx_cmplt;//logic 1:master bit receiption is finished   
// jduarte begin 20101108
// CRM 9000366029
   input                       rx_shift_data_done;
// jduarte end 20101108
   input                       byte_wait_scl;//logic 1: wait for scl to go high before a restart, tx, rx or stop
   input ic_rd_req;//logic 1:Slave is waiting on data from the processor to tx
   input min_hld_cmplt;//Scl hasbeen pulled low and the
                       // Minimum hold time to genearte 
                       // start conditionhas elapsed
   input                         scl_lcnt_cmplt;//logic 1:master completed low period count   
   //Outputs
   output                        ic_dis_window; // The Master FSM state under which ic_disable can be de-asserted
   output [`IC_DATA_RS-1:0]    mst_tx_data_buf_in; // data to be transmitted on sda data out
   output                        start_en;   // Enable START condition
   output                        re_start_en;   // Enable RE-START condition 
   output                        split_start_en; // Enable Split start condition
   output                        mst_tx_en; // Enable tx shift register to transmit data
   output                        mst_rx_en; // Enable rx shift register to transmit data
   output                        mst_gen_ack_en; // Enable Ack gen. ckt
   output                        mst_tx_abrt;   // logic 1: master aborted TX transfer
   output                        mst_txfifo_ld_en;// load tx_buffer from the tx fifo output
   output                        stop_en;   // Generate STOP condition
   output                        hs_mcode_en;//logic 1:master is in hs and transmitting the hs_mcode   
   output                        mst_push_rxfifo_en;//logic 1:push received data to the RX fifo
   output                        mst_activity;//logic 1: master is busy
   output                        mst_debug_addr;//logic 1:indicates master is transmitting the adress   
   output                        mst_debug_data;//logic 1:indicates master is transmitting the adress
   
// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
   output                        abrt_in_rcve_trns;


   /////////////////////////////
   //tx_abrt source
   output                        abrt_master_dis;//Access master while disabled
   output                        abrt_sbyte_norstrt;//Send SBYTE while restart is disabled
   output                        abrt_hs_norstrt;//Hisgh Speed mode while restart disabled
   output                        abrt_hs_ackdet;//High Speed Master code was acknowledged
   output                        abrt_sbyte_ackdet;//Start Byte was acknowleged
   output                        abrt_gcall_read;//Try to read while sending a Gcall
   output                        abrt_gcall_noack;//No slave acknowledged the G.CALL
   output                        abrt_7b_addr_noack;//7bit 1address was not acknowledged
   output                        abrt_txdata_noack;//Slave did not acknowledge sent data
   output                        abrt_10addr1_noack;//10 bit 1address was not acknowledged
   output                        abrt_10b_rd_norstrt;//10 bit read command while restart is disabled
   output                        abrt_10addr2_noack;//10 bit 2address was not acknowledged
   output                        abrt_user_abrt;
   //arb_lost ---> //Abort lost issue a tx abort as well

   output                        mst_addr_state;
   output                        mst_txdata_state;
   output                        master_read;
   output [4:0] mst_debug_cstate;

   // ----------------------------------------------------------
   // -- local registers
   // ----------------------------------------------------------
   reg [4:0] mst_current_state;
   reg [4:0] mst_next_state;

   //non registers (wires) have to be defined as regs to be used in always block
   reg [`IC_DATA_RS-1:0] mst_tx_data_buf_in;
   reg       start_en_int;//gen start condition
   reg       re_start_en_int;//gen re-start condition
   reg       mst_tx_en;//enable tx shifter
   reg       split_start_en_int; // split start
   reg       mst_rx_en;//enable rx shifter
   reg       mst_gen_ack_en_r, mst_gen_ack_en_s;//enable gen ACK in rx mode
   wire      mst_gen_ack_en;
   reg       mst_tx_abrt;//Master Tx aborted int.
   reg       master_read;//logic 1: master is reading from the bus, 0: writing
// jduarte begin 20101108
// CRM 9000366029
// jduarte begin 20101108
   reg       mst_txfifo_ld_en; //Load fifo data into TX buffer
   reg       stop_en; //Generate stop condition
   reg       delay_stop_en;
   reg       abrt_in_rcve_trns; // abort occured during receive transfer
   reg       addr_1byte_sent;//1st address byte has been sent
   reg       addr_2byte_sent;//2nd address byte has been sent
   reg       old_is_read; // Indicates if the previous transaction 
   // in a byte stream is read (1) or no transaction (0)
   // in a byte stream is write (1) or No Transaction (0)
   reg       byte_waiting_q;//Indicates there is another byte to be processed for the RX_BYTE state
   reg       mst_activity;//indicates that we can stop without performing
   //illegal action on I2C bus
   reg       hs_mcode_en;//logic 1:master is in hs and transmitting the hs_mcode
   reg       abrt_hscode_en;//logic 1: HS-code Aborted due to Ack detection
   reg       mst_push_rxfifo_en;//logic 1:push received data to the RX fifo
   reg       byte_waiting;//Indicates there is another byte to be processed for the RX_BYTE state
   reg       mst_tx_flush;//logic 1: Master has flushed the tx fifo buffer
   reg       abrt_in_idle;//logic 1: Master has generated user abort in idle state
   reg       tx_empty_hld;//Hold the value of tx_empty_sync_hl
//   reg       byte_no1;//1: this is the 1st byte ever of the current transfer
   
// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
   
   //tx_abrt source
   reg       abrt_master_dis;//Access master while disabled
   reg       abrt_sbyte_norstrt;//Send SBYTE while restart is disabled
   reg       abrt_hs_norstrt;//Hisgh Speed mode while restart disabled
   reg       abrt_hs_ackdet;//High Speed Master code was acknowledged
   reg       abrt_sbyte_ackdet;//Start Byte was acknowleged
   reg       abrt_gcall_read;//Try to read while sending a Gcall
   reg       abrt_gcall_noack;//No slave acknowledged the G.CALL
   reg       abrt_7b_addr_noack;//7bit 1address was not acknowledged
   reg       abrt_txdata_noack;//Slave did not acknowledge sent data
   reg       abrt_10addr1_noack;//10 bit 1address was not acknowledged
   reg       abrt_10b_rd_norstrt;//10 bit read command while restart is disabled
   reg       abrt_10addr2_noack;//10 bit 2address was not acknowledged
   reg       abrt_user_abrt;//User aborted
   //arb_lost ---> //Abort lost issue a tx abort as well
   reg       ic_abort_sync_d;
   reg       ic_abort_chk_win;
   reg       ic_enable_sync_chk_win;

   
   // ----------------------------------------------------------
   // -- local wires
   // ----------------------------------------------------------
   wire       start_en;//gen start condition
   wire       re_start_en;//gen re-start condition
   wire       split_start_en;
   wire       mst_addr_state;
   wire       mst_txdata_state;
   wire       ic_dis_window;


   // ----------------------------------------------------------
   // -- state variables (gray coded)
   // ----------------------------------------------------------
   parameter IDLE            = 5'b00000;//0
   parameter GEN_START       = 5'b00001;//1
   parameter TX_HS_MCODE     = 5'b00011;//3
   parameter POP_TX_DATA     = 5'b00010;//2
   parameter CHECK_IC_TAR    = 5'b00110;//6
   parameter RX_BYTE         = 5'b00111;//7
   parameter GEN_STOP        = 5'b00101;//5
   parameter TX7_1ST_ADDR    = 5'b00100;//4
   parameter TX10_1ST_ADDR   = 5'b01100;//c
   parameter TX10_2ND_ADDR   = 5'b01101;//d
   parameter GEN_RSTRT_SBYTE = 5'b01110;//e
   parameter TX_BYTE         = 5'b01011;//b
   parameter GEN_RSTRT_10BIT = 5'b1010;//a
   parameter GEN_RSTRT_7BIT  = 5'b01001;//9
   parameter GEN_RSTRT_HS    = 5'b01000;//8
   parameter GEN_SPLIT_STOP  = 5'b01111;//f
   parameter GEN_SPLIT_START = 5'b10101;//15
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108

   assign ic_dis_window = (mst_next_state == IDLE); 

   assign mst_addr_state = ic_10bit_mst_sync ? ((mst_current_state == TX10_1ST_ADDR) & addr_2byte_sent): addr_1byte_sent;
   assign mst_txdata_state = (mst_current_state == TX_BYTE);



   // ----------------------------------------------------------
   // -- Assigning outputs
   // ----------------------------------------------------------
   assign    start_en = start_en_int;
   assign    re_start_en = re_start_en_int;
   assign    split_start_en = split_start_en_int;
   
   // ----------------------------------------------------------
   // -- state assignment
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : FSM_SEQ_PROC
      if(ic_rst_n == 1'b0) begin
         mst_current_state <= IDLE;
      end else begin
         if (             
             (ic_master_sync  == 1'b0)
             || (arb_lost == 1'b1)
             )  begin
            mst_current_state <= IDLE;
         end else begin
                 mst_current_state <= mst_next_state;
         end
      end
   end

   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Ensure that the sequential and combinational parts of an FSM description 
   //     should be in separate always blocks.
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   // ----------------------------------------------------------
   // -- FSM Flags
   // ----------------------------------------------------------
   //start enable control flag   
   always @(posedge ic_clk or negedge ic_rst_n) begin : START_EN_INT_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           start_en_int <= 1'b0;
        end
      else
        begin
           if (
               (mst_current_state == TX_HS_MCODE) || 
                  (mst_current_state == CHECK_IC_TAR)
               || (mst_current_state == TX7_1ST_ADDR) 
               || (mst_current_state == TX10_1ST_ADDR)
               || (mst_current_state == IDLE)
               || ((mst_next_state == GEN_SPLIT_START) 
                   && (min_hld_cmplt == 1'b1)
                   && (start_cmplt == 1'b1))
               )
             begin
                start_en_int <= 1'b0;
             end

           else if (mst_next_state == GEN_START)
             begin
                start_en_int <= 1'b1;
             end
           
           else if (mst_next_state == GEN_SPLIT_START)
             begin
                start_en_int <= (start_en_int == 1'b0) ? ic_bus_idle:1'b1;
             end


        end // else: !if(ic_rst_n == 1'b0)
   end // block: START_EN_INT_FLAG_PROC
   //spyglass enable_block STARC05-2.11.3.1
   
   
   //restart enable control flag
   always @(posedge ic_clk or negedge ic_rst_n) begin : RE_START_EN_INT_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           re_start_en_int <= 1'b0;
        end
      else
        begin
           if ((mst_next_state == GEN_RSTRT_7BIT) || (mst_next_state == GEN_RSTRT_10BIT)
               || (mst_next_state == GEN_RSTRT_HS) 
               || (mst_next_state == GEN_RSTRT_SBYTE) 
               )
             begin
                re_start_en_int <= ~byte_wait_scl;
             end
           else if ((mst_current_state == TX_BYTE) 
               || (mst_current_state == RX_BYTE) 
                     || (mst_current_state == CHECK_IC_TAR) ||(mst_current_state == TX7_1ST_ADDR) 
                     || (mst_current_state == TX10_1ST_ADDR)||(mst_current_state == IDLE)
                     || (mst_current_state == TX_HS_MCODE)
                     )
             begin
                re_start_en_int <= 1'b0;
             end
        end // else: !if(ic_rst_n == 1'b0)

   end // block: RE_START_EN_INT_FLAG_PROC

   always @(posedge ic_clk or negedge ic_rst_n) begin : SPLIT_START_EN_INT_PROC
     if(ic_rst_n==1'b0) begin
       split_start_en_int <= 1'd0;
     end else begin
       if(mst_next_state == GEN_SPLIT_START)
         split_start_en_int <= 1'd1;
       else
         split_start_en_int <= 1'd0;
     end
   end
   
   //previous transaction direction   
   always @(posedge ic_clk or negedge ic_rst_n) begin : OLD_IS_READ_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           old_is_read <= 1'b0;
        end
      else
        begin
           if (mst_current_state == IDLE)             
             begin
                old_is_read <= 1'b0;
             end
             
           else if (mst_current_state == TX_BYTE) 
             begin
                old_is_read <= 1'b0;
             end
           else  if (mst_current_state == RX_BYTE)
             begin
                old_is_read <= 1'b1;
             end
        end // else: !if(ic_rst_n == 1'b0)
   end // block: OLD_IS_READ_FLAG_PROC
   
   //1st address byte sent flag   
   always @(posedge ic_clk or negedge ic_rst_n) begin : ADDR1_SENT_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           addr_1byte_sent <=1'b0;
        end
      else
        begin
           if ((mst_current_state == IDLE)
               ||(mst_current_state == GEN_SPLIT_START)
               )
             begin
                addr_1byte_sent <= 1'b0;
             end
           
           else if ((mst_current_state == TX7_1ST_ADDR) 
               || (mst_current_state == TX10_1ST_ADDR))
             begin
                addr_1byte_sent <= 1'b1;
             end
        end // else: !if(ic_rst_n == 1'b0)
   end // block: ADDR1_SENT_FLAG_PROC
   
   
   //2nd address byte sent flag
   always @(posedge ic_clk or negedge ic_rst_n) begin : ADDR2_SENT_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           addr_2byte_sent <=1'b0;
        end
      else
        begin
           if ((mst_current_state == IDLE)
               ||(mst_current_state == GEN_SPLIT_START)
               )
             begin
                addr_2byte_sent <= 1'b0;
             end
           else if (mst_current_state == TX10_2ND_ADDR)
             begin
                addr_2byte_sent <= 1'b1;
             end
           
        end // else: !if(ic_rst_n == 1'b0)
   end // block: ADDR2_SENT_FLAG_PROC
   //RX_BYTE state byte is waiting flag
   always @(posedge ic_clk or negedge ic_rst_n) begin : BYTE_WAITING_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           byte_waiting_q <= 1'b0;
        end
      else
        begin
// jduarte begin 20101008
// CRM 9000366029
//           if (((mst_next_state == RX_BYTE) && (byte_waiting == 1'b0)) 
//               || (mst_current_state == IDLE))
//             begin
//                byte_waiting_q <= 1'b0;
//             end
//           else if (mst_next_state == RX_BYTE)
//             begin
//                byte_waiting_q <= 1'b1;
//             end
           if (((mst_next_state == RX_BYTE) && (byte_waiting == 1'b0)) 
               || (mst_current_state == IDLE))
             begin
                byte_waiting_q <= 1'b0;
             end
           else if (mst_next_state == RX_BYTE)
             begin
                byte_waiting_q <= 1'b1;
             end
// jduarte end 20101008
        end // else: !if(ic_rst_n == 1'b0)
   end // block: BYTE_WAITING_FLAG_PROC
   //master activity flag
   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_ACTIVITY_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           mst_activity <= 1'b0;
        end
      else
        begin
           if (mst_current_state != IDLE) 
             begin
                mst_activity <= 1'b1;
             end
           else
             mst_activity <= 1'b0;
        end // else: !if(ic_rst_n == 1'b0)
   end // block: MST_ACTIVITY_FLAG_PROC
   
   //master flushed tx fifo buffer
   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_TX_FLUSH_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
              mst_tx_flush <= 1'b0;
        end
      else
        begin
           if ((mst_current_state == GEN_START) 
               || (ic_enable_sync  == 1'b0)
               || (ic_rd_req == 1'b1)
               )
             //                  else  if (mst_current_state == GEN_START)
             begin
              mst_tx_flush <= 1'b0;
             end
           
           else if((mst_current_state != IDLE) && mst_tx_abrt)
             begin
              mst_tx_flush <= 1'b1;
             end
          else if((mst_current_state == IDLE) && (abrt_in_idle || abrt_user_abrt || abrt_master_dis || abrt_sbyte_norstrt
                     || abrt_hs_norstrt 
               ))
             begin
              mst_tx_flush <= 1'b1;
             end
        end // else: !if(ic_rst_n == 1'b0)
   end // block: MST_ACTIVITY_FLAG_PROC

  // =======================================================================
  // Generate "abrt_in_idle".
  // 1. This is necessary to ensure that the state machine should not procceed 
  // as there are commands in tx fifo until the fifo is flushed due to user abort. 
  // =======================================================================
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_IN_IDLE_PROC 
   if (ic_rst_n == 1'b0)
     abrt_in_idle <= 1'b0;
   else if(mst_current_state == GEN_START)
     abrt_in_idle <= 1'b0;
   else if((mst_current_state == IDLE) && abrt_user_abrt)
     abrt_in_idle <= 1'b1;
   end // block: ABRT_IN_IDLE_PROC


      //master tx_empty_hld generation
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_EMPTY_FLAG_PROC
      if(ic_rst_n == 1'b0) 
        begin
              tx_empty_hld <= 1'b0;
        end
      else
        begin

           if ((mst_current_state == GEN_START) 
               || (ic_enable_sync  == 1'b0)
               || (ic_rd_req == 1'b1)     
               )
             begin
                tx_empty_hld <= 1'b0;
             end
          else if(tx_empty_sync == 1'b1)
             begin
                tx_empty_hld <= 1'b0;
             end
          else if((mst_current_state == IDLE) && (abrt_user_abrt || abrt_master_dis || abrt_sbyte_norstrt
                     || abrt_hs_norstrt 
               ))
            begin
                tx_empty_hld <= 1'b0;
             end

           else if((tx_empty_sync_hl == 1'b1) && (mst_current_state == IDLE))
             begin
              tx_empty_hld <= 1'b1;
             end
        end // else: !if(ic_rst_n == 1'b0)
   end // block: MST_ACTIVITY_FLAG_PROC

   //spyglass disable_block W415a
   //SMD: Signal may be multiply assigned (beside initialization) in the same scope
   //SJ : Few signals are updated with the default values and then only if required
   //     the signal is updated, based on the required condition. There is no functional 
   //     issue. Hence this can be waived.
   // ----------------------------------------------------------
   // -- This combinational process calculates the next state
   // -- and generate the outputs 
   // -- (Check RMM, 2nd Edition, Page 112)
   // ----------------------------------------------------------
   always @(
            ic_master_sync
            or ic_enable_sync
            or ic_10bit_mst_sync 
            or tx_empty_sync
            or ack_det
            or mst_current_state
            or delay_stop_en
            or arb_lost
            or ic_tar
            or tx_fifo_data_buf
            or old_is_read
            or addr_1byte_sent
            or byte_waiting_q
            or ic_bus_idle
            or ic_hs_maddr
            or ic_hs_sync 
            or scl_lcnt_cmplt
            or abrt_hscode_en
            or addr_2byte_sent 
            or mst_rxbyte_rdy
            or mst_rxbyte_rdy_done
            or start_cmplt
            or re_start_cmplt
            or stop_cmplt
            or mst_tx_cmplt
            or mst_rx_cmplt
            or ic_rstrt_en_sync
            or byte_wait_scl
            or mst_tx_flush
            or tx_empty_hld
            or min_hld_cmplt
            or ic_abort_sync
            or ic_abort_sync_d
            or ic_abort_chk_win
            or ic_enable_sync_chk_win
            or mst_activity
// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
            ) begin: FSM_COMB_PROC

      //set default values
      mst_tx_abrt = arb_lost;
      mst_tx_en = 1'b0;
      mst_rx_en = 1'b0;
      mst_gen_ack_en_s = 1'b0;
      mst_txfifo_ld_en = 1'b0;
      stop_en = 1'b0;
      master_read = 1'b0;
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
      hs_mcode_en = 1'b0;             
      mst_push_rxfifo_en = 1'b0;
      mst_tx_data_buf_in = {`IC_DATA_RS{1'b1}};
      mst_next_state = IDLE;
      byte_waiting = 1'b0; 

// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008

      abrt_master_dis = 1'b0;//Access master while disabled
      abrt_sbyte_norstrt = 1'b0;//Send SBYTE while restart is disabled
      abrt_hs_norstrt = 1'b0;//Hisgh Speed mode while restart disabled
      abrt_hs_ackdet = 1'b0;//High Speed Master code was acknowledged
      abrt_sbyte_ackdet = 1'b0;//Start Byte was acknowleged
      abrt_gcall_read = 1'b0;//Try to read while sending a Gcall
      abrt_gcall_noack = 1'b0;//No slave acknowledged the G.CALL
      abrt_7b_addr_noack = 1'b0;//7bit 1address was not acknowledged
      abrt_txdata_noack = 1'b0;//Slave did not acknowledge sent data
      abrt_10addr1_noack = 1'b0;//10 bit 1address was not acknowledged
      abrt_10b_rd_norstrt = 1'b0;//10 bit read command while restart is disabled
      abrt_10addr2_noack = 1'b0;//10 bit 2address was not acknowledged
      abrt_user_abrt = 1'b0;

      case (mst_current_state)
        IDLE :
          begin
             //Control signals initialization
             mst_tx_abrt = 1'b0;
             mst_tx_en = 1'b0;
             mst_rx_en = 1'b0;
             mst_gen_ack_en_s = 1'b0;
             mst_txfifo_ld_en = 1'b0;
             stop_en = 1'b0;
             hs_mcode_en = 1'b0;             
             mst_push_rxfifo_en = 1'b0;
             mst_tx_data_buf_in = {`IC_DATA_RS{1'b1}};
             byte_waiting = 1'b0;             

             if(ic_abort_sync == 1'b1) begin //user initiated abort
               if(ic_abort_sync_d == 1'b0 || mst_activity == 1'b1) begin 
                 mst_tx_abrt = 1'b1;//user abort
                 abrt_user_abrt = 1'b1;
               end
               mst_next_state = IDLE;//Remain in the idle state
             end
             else if (
                 (((mst_tx_flush == 1'b0)&&(tx_empty_sync   == 1'b0)) || // TX FIFO has data in it
                 ((mst_tx_flush == 1'b1)&&(tx_empty_hld == 1'b1))) &&  // TX FIFO has data in it
                 (ic_bus_idle == 1'b1) // The bus is free
                 ) 
               begin
                  //
                    if(
                      ((ic_rstrt_en_sync == 1'b0) &&//re_start is disabled and 
                         (
                          (ic_hs_sync == 1'b1) || //High speed transfer
                          (ic_tar[11:10] == 2'b11)))//send a start byte
                          || (ic_master_sync  == 1'b0)//master is disabled
                         ) 
                         begin
                           mst_tx_abrt = 1'b1;//Abrt invalid transaction while re_start is disabled

                           if(ic_master_sync  == 1'b0) abrt_master_dis  = 1'b1;
                           if(ic_tar[11:10] == 2'b11)  abrt_sbyte_norstrt = 1'b1;
                           if(ic_hs_sync == 1'b1)      abrt_hs_norstrt = 1'b1;
                           mst_next_state = IDLE;//Camp on Idle 
                         end
                       else
                        mst_next_state = GEN_START;//Generate a start condition and go ahead with the transfer
               end 
             else 
               begin
                  mst_next_state = IDLE;//Remain in the idle state
               end
          end // case: IDLE
        
        
        // =========================================================================================
        // When "start_cmplt" is asserted, this Master will have satisfied the minimum time for SDA
        // to stay LOW and move on to pulling SCL to LOW. This is t[HD,STA] requirement.
        // Meanwhile "min_hld_cmplt" waits to be asserted whenever SDA is pulled LOW, potentially
        // by *other* Masters.
        // Thus, if "start_cmplt" is HIGH and "min_hld_cmplt" is HIGH as well, then this Master have
        // already discovered that, after waiting for t[HD;STA], the I2C bus requires arbitration.
        // =========================================================================================

        GEN_START: begin //This state generates a Start Condition on the I2C bus

          if(ic_hs_sync == 1'b1)
            hs_mcode_en = 1'b1;//Use FS timing if in High Speed Mode

          if(start_cmplt == 1'b1) begin  //We still own the bus (Has a start condition been detected?)
                                         //Start detected go on

            //LK--ToBeDeleted if(min_hld_cmplt == 1'b1) //Another master is on the bus
            //LK--ToBeDeleted                           // and The minimum hold time to generate
            //LK--ToBeDeleted                           // a start has elapsed
            //LK--ToBeDeleted                           // So park on the idle state until
            //LK--ToBeDeleted                           // the bus is idle again
            //LK--ToBeDeleted   mst_next_state = IDLE;

            //LK--ToBeDeleted else if(ic_tar[11] == 1'b1)     //if ic_tar[11]=1 then  We are sending General Call or Start byte
            if((ic_tar[11] == 1'b1)      //if ic_tar[11]=1 then  We are sending General Call or Start byte
               )
              mst_next_state = CHECK_IC_TAR;//Decide if we are sending General Call or start byte

            else  if (ic_hs_sync == 1'b1) begin //Are we in High speed mode?
              mst_next_state = TX_HS_MCODE;     // We are in HS mode so send the HS Master Code
            end

            else begin                      //if (ic_tar[11] = 1'b0) we are sending normal data
              mst_txfifo_ld_en = 1'b1;      // load the FIFO data into the tx buf
                                            // (pop data from tx fifo)
              mst_next_state = POP_TX_DATA; //Complete Pop data process and process the data to be send
            end
          end // if (start_cmplt == 1'b1)

          else begin
            mst_next_state = GEN_START; // Wait for the Start condition to be detected,
                                        // so loopback to GEN_START
          end // else: !if(start_cmplt == 1'b1)
        end // case: GEN_START
        

        TX_HS_MCODE://This state transmits the HS Master Code on the I2C bus
          begin
             mst_tx_data_buf_in = {`IC_HS_CODE,ic_hs_maddr}; //Fill the data buf with the correct value
             hs_mcode_en = 1'b1;//State that we are sending the HS mode Master Code (MCODE)
             
               mst_tx_en = ~byte_wait_scl; // Enable Transmission of HS Master Code
             
             if (mst_tx_cmplt == 1'b1)
               begin
                  if(ack_det == 1'b1) begin //MCODE should not be acknowledged (something is wrong)
                     mst_tx_en = 1'b0; // Stop TX of the data
                     hs_mcode_en = 1'b0;//We finished sending the MCODE
                     mst_tx_abrt = 1'b1;//Master aborted Transmission
                     
                     abrt_hs_ackdet = 1'b1;
                     
                     mst_next_state = GEN_STOP;//Generate a stop condition and quit the bus
                     
                  end
                  else
                  begin //We still own the bus and no SLAVE 
                     // acknowledged the  MCODE (correct behavior)
                     hs_mcode_en = 1'b0;//We finished transmitting the MCODE
                     mst_tx_en = 1'b0; // Disable Transmitter
                     mst_next_state = GEN_RSTRT_HS;
                  end 
               end
             else 
               begin//We are still waiting for a start or arb lost or ack or not ack signals
                  mst_next_state = TX_HS_MCODE;
               end
             
          end // case: TX_HS_MCODE
        
        
        CHECK_IC_TAR://This State sends general call or start byte to the I2C bus 
          begin
              if(ic_tar[11:10] == 2'b10) begin //Are we sending a general call address?
                mst_tx_data_buf_in   = 8'h00;// Load Tx data buffer with a general Call "00h"

                hs_mcode_en = ic_hs_sync;//1'b1;//Use FS timing if in High Speed Mode
                   mst_tx_en = ~byte_wait_scl; // Enable transmitter to send the Gen. Call if we are not in byte waiting mode

                if (mst_tx_cmplt == 1'b1) begin
                   if (ack_det == 1'b1)  begin //We still own the bus, has a slave acknowldged the Gen Call
                      mst_tx_en = 1'b0;//We have an acknowledge so procede to next byte
                      mst_txfifo_ld_en = 1'b1; // Load the FIFO data into the tx buf
                      mst_next_state = POP_TX_DATA;
                      
                   end else
                     begin 
                        //No slave ackwnoledged the General call so abort transfer
                        mst_tx_abrt = 1'b1;//Master aborted transfer
                        abrt_gcall_noack =  1'b1;//No slave acknowledged the G.CALL
                        mst_next_state = GEN_STOP;//Generate a stop condition
                     end 
                end
                else begin
                   mst_next_state = CHECK_IC_TAR; // Wait for an ACK signal
                end
             end
             
             else //if(ic_tar[11:10] == 2'b11) //Tx Start Byte
              begin 
                 hs_mcode_en = ic_hs_sync;//Use FS timing if in High Speed Mode
                 
                 mst_tx_data_buf_in   = 8'h01; //Set the Start Byte data
                 
                   mst_tx_en = ~byte_wait_scl; //Enable the transmitter

                 if (mst_tx_cmplt == 1'b1) //Start byte should not be acknwledged (correct behavior)
                   begin
                       if (ack_det == 1'b1)
                        begin //something is wrong on the bus
                           mst_tx_abrt = 1'b1;
                         abrt_sbyte_ackdet = 1'b1;
                           
                           mst_next_state = GEN_STOP;
                        end 
                      else
                        begin
                           mst_tx_en = 1'b0;
                           mst_next_state = GEN_RSTRT_SBYTE;
                        end
                   end
                 else
                   mst_next_state = CHECK_IC_TAR;
              end // if (ic_tar[11:10] = 2'b11)
          end // case: CHECK_IC_TAR
        
        
        
        POP_TX_DATA:
          begin
             mst_txfifo_ld_en = 1'b0; //Latch the Fifo data into the TX buffer
             mst_tx_en = 1'b0;
             master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
             if((mst_tx_cmplt == 1'b1)
                 || (mst_rx_cmplt == 1'b1)
               )
                    begin
                     mst_next_state = POP_TX_DATA;
                    end

             ////----> Case 1: we are in General call processing

             else if(ic_tar[11:10] == 2'b10) begin //IC is sending general call data
                /////
                if(master_read == 1'b0) //Master is writing
                  begin
                     mst_next_state = TX_BYTE;
                     mst_tx_en = 1'b1;
                  end
                else //Master is reading (not allowed)
                  begin
                     mst_tx_abrt = 1'b1;
                     abrt_gcall_read = 1'b1;
                     
                     mst_next_state = GEN_STOP;
                  end        
                /////
             end // if (ic_tar[11:10] == 2'b10)
             
        
             ////----> Case 2: we are in 7 bit address mode
             else
               begin
               if(ic_10bit_mst_sync == 1'b0) begin //IC is in 7 bit address mode
                /////
                
// jduarte begin 20101108
// CRM 9000366029
//                if ((master_read != old_is_read) && (addr_1byte_sent == 1'b1))//are we changing direction?
                if ((master_read != old_is_read) && (addr_1byte_sent == 1'b1))//are we changing direction?
// jduarte begin 20101108
                  begin //gen re-start condition to change the direction of the transaction
                     if(ic_rstrt_en_sync == 1'b1)
                       mst_next_state = GEN_RSTRT_7BIT;
                     else
                       mst_next_state = GEN_SPLIT_STOP;
                  end
                
                else 
                if(addr_1byte_sent == 1'b0) 
                  begin
                     mst_next_state = TX7_1ST_ADDR;
                  end 
                else 
                  begin
                          mst_next_state = TX_BYTE;
                          mst_tx_en = 1'b1;
                  end        
                /////
             ////----> Case 3: we are in 10 bit address mode
             end else 
               begin // IC is in 10 bit address mode
                  
// jduarte begin 20101108
// CRM 9000366029
//                  if ((master_read != old_is_read) && (addr_2byte_sent == 1'b1))//change dir of transfer
                  if ((master_read != old_is_read) && (addr_2byte_sent == 1'b1))//change dir of transfer
// jduarte begin 20101108
                    begin //gen re-start condition to change the direction of the transaction
                       if(ic_rstrt_en_sync == 1'b1)
                         mst_next_state = GEN_RSTRT_10BIT;
                       else
                         mst_next_state = GEN_SPLIT_STOP;
                    end
                  
                  else 
                   if(addr_1byte_sent == 1'b0)
                    begin
                       mst_next_state = TX10_1ST_ADDR;
                    end 
                  else
                    begin
                            mst_next_state = TX_BYTE;
                            mst_tx_en = 1'b1;
                    end   
                  
               end // else: !if(ic_10bit_mst_sync == 1'b0)
               end // else: !if(ic_tar[11:10] == 2'b10)
             
          end // case: POP_TX_DATA
        
        TX7_1ST_ADDR:
          begin
             master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
                mst_tx_data_buf_in   = {ic_tar[6:0],master_read}; //Set the Start Byte data
             mst_tx_en = ~byte_wait_scl; //Enable the transmitter
             
             if (mst_tx_cmplt == 1'b1)
               begin
                  if (ack_det == 1'b1)
                    begin //slave acknowledged the address
                       mst_tx_en = 1'b0;//disable the transmitter
// jduarte begin 20101108
// CRM 9000366029
//                       if(master_read ==1'b1)
//                         begin
//                            if(tx_empty_sync == 1'b0) //We have more data in tx fifo
//                           begin
//                  mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
//                              byte_waiting = 1'b1;
//                           end
//                            else
//                              begin
//                                 byte_waiting = 1'b0;
//                              end
//                              byte_waiting = 1'b1;
//                           end
//                            else
//                              begin
//                                 byte_waiting = 1'b0;
//                              end
//                            mst_next_state = RX_BYTE;
//                         end
                       if(master_read ==1'b1)
                         begin
                           if(tx_empty_sync == 1'b0) //We have more data in tx fifo
                             begin
                               mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
                               byte_waiting = 1'b1;
                             end
                           else
                             begin
                               byte_waiting = 1'b0;
                             end
                           mst_next_state = RX_BYTE;
                         end
// jduarte end 20101108
                       else
                         mst_next_state = TX_BYTE;   
                    end
                  else
                  begin
                     mst_tx_abrt = 1'b1;
                     abrt_7b_addr_noack = 1'b1;
                     
                     mst_tx_en = 1'b0; //disable the transmitter
                     mst_next_state = GEN_STOP;
                  end 
               end
             else
               mst_next_state = TX7_1ST_ADDR; // Wait for an ACK signal

          end // case: TX_1ST_ADDR
        
        
        TX_BYTE:   
          begin

// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108

             if(ic_tar[11:10] == 2'b10) 
               begin
                  //IC is sending general call data
                  hs_mcode_en = ic_hs_sync;//1'b1;//Use FS timing if in High Speed Mode
               end
             else
               hs_mcode_en = 1'b0;
             
             
             mst_tx_data_buf_in = tx_fifo_data_buf[7:0];
             mst_tx_en = ~byte_wait_scl;
             
             if(mst_tx_cmplt == 1'b1)
               begin
                  if (ack_det == 1'b1)
                    begin //slave acknowledged the data bytes
                       mst_tx_en = 1'b0;//disable the transmitter
// jduarte begin 20101108
// CRM 9000366029
//                       if(tx_empty_sync == 1'b0) //We have more data in tx fifo
//                         begin
//                            mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
//                            mst_next_state = POP_TX_DATA;
//                         end
                       if((ic_abort_sync == 1'b1) || (ic_enable_sync == 1'b0)) begin //user initiated abort
                         mst_next_state = GEN_STOP;
                       end
                       else if(tx_empty_sync == 1'b0) //We have more data in tx fifo
                         begin
                            mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
                            mst_next_state = POP_TX_DATA;
                         end
// jduarte end 20101108
                       else //No more data to process
                         begin
                            mst_next_state = GEN_STOP;
                         end
                    end
                  else
                         begin
                            mst_tx_abrt = 1'b1;
                            abrt_txdata_noack = 1'b1;
                            
                            mst_tx_en = 1'b0;//disable the transmitter
                            mst_next_state = GEN_STOP;
                            
                         end
               end
             else // else: !if(ack_det == 1'b1)
                           
               mst_next_state = TX_BYTE; // Wait for an ACK signal
             
          end // case: TX_BYTE
        // =========================================================================
        //
        // =========================================================================
        RX_BYTE:   begin
            master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
          if(byte_waiting_q ==1) begin
            mst_txfifo_ld_en = 1'b0; //Latch the fifo data to the tx buffer if it has been loaded before
            master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
//             mst_gen_ack_en_s = master_read;//(master_read == 1'b1) ? 1'b1 : 1'b0;
//                                            //if next byte is RX then gen ack                 
            mst_gen_ack_en_s = master_read && (~(ic_abort_chk_win && ic_abort_sync)) && ((~ic_enable_sync_chk_win) || ic_enable_sync);//(master_read == 1'b1) ? 1'b1 : 1'b0;
                                               //if next byte is RX then gen ack
// jduarte end 20101108
          end else  begin
            mst_gen_ack_en_s = 1'b0;
          end

          mst_push_rxfifo_en = 1'b0;             
          mst_rx_en = ~byte_wait_scl;

          if (mst_rxbyte_rdy == 1'b1 && mst_rxbyte_rdy_done == 1'b0) begin //We recevied the data byte
            mst_rx_en = 1'b0;
            mst_gen_ack_en_s = 1'b0;
                 
// CRM 9000481699 Start
            mst_push_rxfifo_en = 1'b1;

            if(byte_waiting_q == 1'b1) begin
// jduarte begin 20101108
// CRM 9000366029
//              if(master_read == 1'b1) begin //byte waiting is read
//                if(tx_empty_sync == 1'b0) begin //We have more data in tx fifo
//                  mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
              if((ic_abort_chk_win == 1'b1 && ic_abort_sync == 1'b1) || ((ic_enable_sync_chk_win == 1'b1) && (ic_enable_sync == 1'b0))) begin
                mst_next_state = GEN_STOP;
              end
              else if(master_read == 1'b1) begin //byte waiting is read
                if(tx_empty_sync == 1'b0) begin //We have more data in tx fifo
                  mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
                  byte_waiting = 1'b1;
                end else begin
                  byte_waiting = 1'b0;
                end
                mst_gen_ack_en_s = 1'b0;
                mst_next_state = RX_BYTE;
              end else begin //Byte waiting is write (change direction)
                if(ic_rstrt_en_sync == 1'b0)
                  mst_next_state = GEN_SPLIT_STOP;
                else
                  mst_next_state = (ic_10bit_mst_sync == 1'b0) ? GEN_RSTRT_7BIT
                                                               : GEN_RSTRT_10BIT;                  
              end // else master_read
// jduarte end 20101108
            end else begin //no more data to process
              mst_rx_en = 1'b0;
              mst_next_state = GEN_STOP;
            end

          end // if (mst_rxbyte_rdy == 1'b1)
          else begin
            byte_waiting = (byte_waiting_q == 1'b1) ? 1'b1 : 1'b0;//preserve the value of the byte waiting flag
// jduarte begin 20101108
// CRM 9000366029
//mst_next_state = RX_BYTE;
              mst_next_state = RX_BYTE;
// jduarte end 20101108
          end // else mst_rxbyte_rdy
             
        end // case: RX_BYTE

// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108

        TX10_1ST_ADDR:
          begin
             master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
// jduarte begin 20101108
// CRM 9000366029
//             if ((master_read != old_is_read) && (addr_2byte_sent == 1'b1))//change direction of transfer
             if ((master_read != old_is_read) && (addr_2byte_sent == 1'b1))//change direction of transfer
// jduarte end 20101108
               //Set the 1st ADDR Byte data + Read, we are switching dir.
               mst_tx_data_buf_in   = {`IC_SLV_ADDR_10BIT,ic_tar[9:8],master_read}; 
             else
               //Set the 1st ADDR Byte data + Write it is a normal addr phase
               mst_tx_data_buf_in   = {`IC_SLV_ADDR_10BIT,ic_tar[9:8],1'b0}; 

             mst_tx_en = ~byte_wait_scl; //Enable the transmitter
             if (mst_tx_cmplt == 1'b1)
               begin
                  if (ack_det == 1'b1)
                    begin //slave acknowledged the address
                       mst_tx_en = 1'b0;
// jduarte begin 20101108
// CRM 9000366029
//                       if ((master_read != old_is_read)&&(addr_2byte_sent == 1'b1)&&(master_read == 1'b1))// we are changing the transfer direction
//                         begin
//                            if(tx_empty_sync == 1'b0) //We have more data in tx fifo
//                              begin
//                                 mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
//                                 byte_waiting = 1'b1;
//                              end
//                            else
//                              byte_waiting = 1'b0;
//                            mst_next_state = RX_BYTE;
//                         end
//                       else
//                         mst_next_state = TX10_2ND_ADDR;
                       if ((master_read != old_is_read)&&(addr_2byte_sent == 1'b1)&&(master_read == 1'b1))// we are changing the transfer direction
                         begin
                            if(tx_empty_sync == 1'b0) //We have more data in tx fifo
                              begin
                                 mst_txfifo_ld_en = 1'b1; //Load the fifo data to the tx buffer
                                 byte_waiting = 1'b1;
                              end
                            else
                              byte_waiting = 1'b0;
                            mst_next_state = RX_BYTE;
                         end
                       else
                         mst_next_state = TX10_2ND_ADDR;
// jduarte end 20101108
                    end
                  
                  else //No Slave acknowledged the address
                    begin
                       mst_tx_abrt = 1'b1;
                       abrt_10addr1_noack = 1'b1;
                       mst_tx_en = 1'b0; //disable the transmitter
                       mst_next_state = GEN_STOP;
                    end
               end 
             else
               mst_next_state = TX10_1ST_ADDR; // Wait for an ACK signal
          end // case: TX10_1ST_ADDR
        
        TX10_2ND_ADDR:
          begin
             master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
             mst_tx_data_buf_in   = ic_tar[7:0]; //Set the 2nd ADDR Byte data
             if((ic_rstrt_en_sync == 1'b0) && (master_read == 1'b1))//if re_start is disabled then you cant read in 10 bit mode
               begin
                  mst_tx_abrt = 1'b1;
                  abrt_10b_rd_norstrt = 1'b1;
                  
                  mst_next_state = GEN_STOP;//Master is reading from slave  
               end
             
             else
               begin
                  mst_tx_en = ~byte_wait_scl; //Enable the transmitter
                  if (mst_tx_cmplt == 1'b1)//ack detected
                    begin
                       if (ack_det == 1'b1)//ack detected
                         begin //slave acknowledged the address
                            mst_tx_en = 1'b0; //disable the transmitter
                            if(master_read == 1'b0) //Master is writing to slave
                              mst_next_state = TX_BYTE;
                            else
                              begin 
                                 mst_next_state =  GEN_RSTRT_10BIT;//Master is reading from slave
                              end
                         end
                       
                       else
                       begin
                          mst_tx_en = 1'b0;
                          mst_tx_abrt = 1'b1;
                          abrt_10addr2_noack = 1'b1;
                          mst_next_state = GEN_STOP;
                       end
                    end
                  else
                    mst_next_state = TX10_2ND_ADDR; // Wait for an ACK signal
               end
          end // case: TX10_2ND_ADDR
        
        GEN_RSTRT_HS:
          begin //gen re-start condition to change the direction of the transaction
             //if(ic_hs_sync == 1'b1)
               //hs_mcode_en = 1'b1;//Use FS timing if in High Speed Mode
            if(scl_lcnt_cmplt == 1'b1)
              hs_mcode_en = 1'b0;
            else
              hs_mcode_en = 1'b1;
             
             if (re_start_cmplt == 1'b1)
               begin //Re-Start detected go on
                       mst_txfifo_ld_en = 1'b1;// Load the FIFO data into the tx buf
                       mst_next_state = POP_TX_DATA;//Complete the POP TX FIFO process
               end
             
             else begin
                mst_next_state = GEN_RSTRT_HS;
             end
          end//case: GEN_RSTRT_HS;

        GEN_RSTRT_SBYTE:
          begin //gen re-start condition to change the direction of the transaction
             hs_mcode_en = ic_hs_sync;//Use FS timing if in High Speed Mode
             
             if (re_start_cmplt == 1'b1)
               begin //Re-Start detected go on
                  if(ic_hs_sync == 1'b1)
                    mst_next_state = TX_HS_MCODE;//Complete the POP TX FIFO process
                  else
                    begin
                       mst_txfifo_ld_en = 1'b1;// Load the FIFO data into the tx buf
                       mst_next_state = POP_TX_DATA;//Complete the POP TX FIFO process
                    end
               end
             
             else 
               begin
                  mst_next_state = GEN_RSTRT_SBYTE;
               end
          end//case: GEN_RSTRT_SBYTE;


        GEN_RSTRT_7BIT:
          begin //gen re-start condition to change the direction of the transaction
             if (re_start_cmplt == 1'b1)
               begin //Re-Start detected go on
                  mst_next_state = TX7_1ST_ADDR;
               end
             else begin
                mst_next_state = GEN_RSTRT_7BIT;
             end
          end//case: GEN_RSTRT_7BIT;

        GEN_RSTRT_10BIT:
          begin //gen re-start condition to change the direction of the transaction
             if (re_start_cmplt == 1'b1)
               begin //Re-Start detected go on
                  mst_next_state = TX10_1ST_ADDR;//TX10_1ST_ADDR_RD;
               end
             else begin
                mst_next_state = GEN_RSTRT_10BIT;
             end
          end//case: GEN_RSTRT_10BIT;

        GEN_SPLIT_STOP:   //used only in SS or FS Mode
          begin
             stop_en = ~byte_wait_scl; //Enable generating stop condition
             
             if ( stop_cmplt == 1'b1)
               begin
                  mst_next_state = GEN_SPLIT_START;
               end
             else
               mst_next_state = GEN_SPLIT_STOP;
             
          end // case: GEN_STOP

        GEN_SPLIT_START://This is only used in SS or FS Mode
          begin //gen stop-start condition to split a combined transaction when re_start is disabled
             master_read = tx_fifo_data_buf[8]; // 0: Master is writing, 1: Master is reading
// jduarte begin 20101108
// CRM 9000366029
// jduarte end 20101108
             
             if (start_cmplt == 1'b1)
               begin //Start detected, go on
                  if (min_hld_cmplt == 1'b1)//Another master is on the bus 
                                            // and The minimum hold time to generate
                                            // a start has elapsed
                                            // So park on the gen_split_start 
                                            // state until 
                                            // the bus is idle again
                    mst_next_state = GEN_SPLIT_START;

                  else
                      if(ic_10bit_mst_sync == 1'b0)
                    mst_next_state = TX7_1ST_ADDR;
                  else
                    mst_next_state = TX10_1ST_ADDR; //<HS>Might be redundent
               end // if (start_cmplt == 1'b1)
             
             else
               begin
                  mst_next_state = GEN_SPLIT_START;
               end
             
          end // case: GEN_SPLIT_START
        

        GEN_STOP:   
          begin
             hs_mcode_en = abrt_hscode_en;
             
             if(delay_stop_en)
               stop_en = 1'd0;
             else begin
             stop_en = ~byte_wait_scl; //Enable generating stop condition
             end 
               if ( stop_cmplt == 1'b1) begin
                  mst_next_state = IDLE; // We lost the bus
               end else
                 mst_next_state = GEN_STOP;
             
          end // case: GEN_STOP
        
        
        default :
          mst_next_state = IDLE;
        
        
      endcase // case(mst_current_state)
      
   end // block: FSM_COMB_PROC
   //spyglass enable_block W415a


  // =======================================================================
  // Generate "ic_abort_sync_d" and "ic_abort_chk_win".
  // 1. This is necessary to ensure that the ic_abort_sync is not sampled 
  // during ACK phase of receive transfer
  // 2. This is necessary to ensure that the abrt_user_abrt is generated 
  // only once in the IDLE state.
  // =======================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      ic_abort_sync_d <= 1'b0;
      ic_abort_chk_win <= 1'b0;
    end else begin
      ic_abort_sync_d <= ic_abort_sync;
      if (rx_shift_data_done == 1'b1 
         )
        ic_abort_chk_win <= ic_abort_sync;
      else if (mst_tx_abrt == 1'b1)
        ic_abort_chk_win <= 1'b0;
    end
  end

  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      ic_enable_sync_chk_win <= 1'b0;
    end else begin
      if (rx_shift_data_done == 1'b1 
         )
        ic_enable_sync_chk_win <= ~ic_enable_sync;
      else if (ic_enable_sync == 1'b1)
        ic_enable_sync_chk_win <= 1'b0;
    end
  end  

  // ================================================================================
  // Generate "abrt_in_rcve_trns".
  // This is necessary to ensure the correct flush count value generated 
  // after user abort occurs during receive transfer due to pipelining of 
  // receive commands.
  // -->When IC_EMPTYFIFO_HOLD_EN=0, Receive transfers are pipelined . 
  // Next read command is loaded in to internal register tx_fifo_data_buf during
  // execution of current command. so, when abort happens the commands in fifo and
  // the command stored(byte_waiting_q) in internal register are flushed.
  // Hence Flushed commands = ic_txflr (fifo commands) + 1'b1(if abrt_in_rcve_trans=1)
  // --> When IC_EMPTYFIFO_HOLD_EN=1, Only First receive command is pipelined.
  // Next read command is loaded in to internal register tx_fifo_data_buf during 
  // execution of first read command. So, if abort happens during the execution of 
  // first read transfer, the commands in fifo and the command in internal register are 
  // flushed. remaining receive transfers from 2nd transfer, there is no pipelining.
  // Hence Flushed commands during first read transfer 
  //                   = ic_txflr (fifo commands) + 1'b1(if abrt_in_rcve_trans=1)
  // =================================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      abrt_in_rcve_trns <= 1'b0;
    end else begin
      if(mst_current_state == GEN_START)
        abrt_in_rcve_trns <= 1'b0;
    else if(ic_abort_sync && ic_abort_chk_win && (mst_current_state == RX_BYTE) && byte_waiting_q)
       abrt_in_rcve_trns <= 1'b1;
    end
  end

  // =======================================================================
  // Generate "delay_stop_en".
  // This is necessary to ensure that the "stop_hi" signal, inside the TxShift
  // module, does NOT glitch prior to the "stop_lo" signal being asserted.
  // Subsequently, this removes the problem where "ic_data_oe" changes together
  // with "ic_clkc_oe" during Master-Tx.
  // =======================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      delay_stop_en <= 1'd0;
    end else begin
      if(mst_current_state == TX_BYTE      ||
         mst_current_state == TX_HS_MCODE  ||
         mst_current_state == TX7_1ST_ADDR ||
         mst_current_state == TX10_2ND_ADDR ||
         mst_current_state == TX10_1ST_ADDR) 
        delay_stop_en <= 1'd1;
      else
        delay_stop_en <= 1'd0;
    end // else ic_rst_n
  end
  // =======================================================================
  // Generate "mst_gen_ack_en"
  // Forced the original behaviour of the signal to pulse for TWO clock
  // cycles, INSTEAD of the previous ONE.
  // This ensures that the second transition due to the ACK bit is made 1
  // clock cycle after "ic_clk_oe".
  // =======================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      mst_gen_ack_en_r <= 1'd0;
    end else begin
      mst_gen_ack_en_r <= mst_gen_ack_en_s;
    end
  end // always

  assign mst_gen_ack_en = mst_gen_ack_en_r & mst_gen_ack_en_s;

  // =======================================================================
  // Generate "abrt_hscode_en"
  // When Master is programmed to Hs-mode and transfer abort is generated for
  // the following cases, the STOP is generated in FS Speed.(Error Conditions)
  // 1. START-Byte ACK Detected 
  // 2. HS-Code ACK detected
  // 3. General Call ACK detected
  // ========================================================================
  always @(posedge ic_clk or negedge ic_rst_n) begin
    if(!ic_rst_n) begin
      abrt_hscode_en <= 1'b0;
    end else begin
     if(mst_current_state == IDLE)
       abrt_hscode_en <= 1'b0;
     else if(ic_hs_sync && (abrt_sbyte_ackdet ||
                            abrt_hs_ackdet    ||
                            abrt_gcall_noack))
        abrt_hscode_en <= 1'b1;
    end
  end

   // ----------------------------------
   // : generate debug signals
   // ----------------------------------
   assign mst_debug_addr = ((mst_current_state == TX7_1ST_ADDR)
                            ||(mst_current_state == TX10_1ST_ADDR)
                            ||(mst_current_state == TX10_2ND_ADDR)
                            ||(mst_current_state == TX_HS_MCODE)
                            ||(mst_current_state == CHECK_IC_TAR));
   
   assign mst_debug_data = ((mst_current_state == TX_BYTE)
                            ||(mst_current_state == RX_BYTE)
   );

   assign mst_debug_cstate = mst_current_state;
   
endmodule // DW_apb_i2c_mstfsm
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #13 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_toggle.v#13 $ 
//
//
// File    : DW_apb_i2c_toggle.v
//
//
// Author  : Hani Saleh
// Created : Nov, 2002
// Abstract: This module generates toggle flags for the signals
//           travelling from the ic_clk to the pclk domain
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

module DW_apb_i2c_toggle
  (
   //inputs
   ic_rst_n,
                           ic_clk,
                           ic_rd_req,   
                           mst_tx_abrt,  
                           slv_tx_abrt,  
                           slv_rx_done,  
                           mst_activity,
                           slv_activity,
                           p_det,
                           s_det,
                           rx_gen_call,
                           tx_pop,
                           rx_push,
                           set_tx_empty_en,
                           //tx_abrt source indicators
                           abrt_master_dis,//Access master while disabled
                           abrt_sbyte_norstrt,//Send SBYTE while restart is disabled
                           abrt_hs_norstrt,//Hisgh Speed mode while restart disabled
                           abrt_hs_ackdet,//High Speed Master code was acknowledged
                           abrt_sbyte_ackdet,//Start Byte was acknowleged
                           abrt_gcall_read,//Try to read while sending a Gcall
                           abrt_gcall_noack,//No slave acknowledged the G.CALL
                           abrt_7b_addr_noack,//7bit 1address was not acknowledged
                           abrt_txdata_noack,//Slave did not acknowledge sent data
                           abrt_10addr1_noack,//10 bit 1address was not acknowledged
                           abrt_10b_rd_norstrt,//10 bit read command while restart is disabled
                           abrt_10addr2_noack,//10 bit 2address was not acknowledged
                           abrt_user_abrt,
                           arb_lost,
                           //slv tx_abrt source indicator
                           abrt_slvflush_txfifo,//slave flush tx fifo to request tx data
                           abrt_slv_arblost,//Slave lost the bus while it is tx data
                           abrt_slvrd_intx,//Slave request data to tx and processor wrote 
                           // a read command into the tx_fifo (9th bit is 1)
                           slv_clr_leftover,
                           //debug inputs
                           tx_current_src_en,
                           rx_current_src_en,
                           start_en,
                           re_start_en,
                           stop_en,
                           mst_debug_data,
                           mst_debug_addr,
                           slv_debug_addr,
                           slv_debug_data,
                           mst_rx_en,
                           mst_tx_en,
                           ic_enable_sync,
                           ic_hs_sync,
                           hs_mcode_en,
                           rx_addr_10bit,
                           slv_debug_cstate,
                           mst_debug_cstate,
                           ic_dis_window,
                           //outputs
                           debug_s_gen,
                           debug_p_gen,
                           debug_data,
                           debug_addr,
                           debug_rd,
                           debug_wr,
                           debug_hs,
                           debug_master_act,
                           debug_slave_act,  
                           debug_addr_10bit,
                           debug_slv_cstate,
                           debug_mst_cstate,
                           ic_current_src_en,
                           ic_disable,
                           tx_abrt_flg,   
                           rx_done_flg,   
                           ic_rd_req_flg, 
                           p_det_flg, 
                           s_det_flg, 
                           rx_gen_call_flg,
                           tx_pop_flg,    
                           rx_push_flg,  
                           slv_clr_leftover_flg,
                           set_tx_empty_en_flg,
                           tx_abrt_source//tx_abrt sources combined signals
                           
                           );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;    // module clock: runs i2c module
   input ic_rst_n;  // I2C module asynchronous reset input active low
   

   input mst_tx_abrt;//logic 1: Master aborted tx 
   input slv_tx_abrt;//logic 1: SLave aborted tx 
   input slv_rx_done;//logic 1: SLave aborted rx 
   input mst_activity;
   input slv_activity; 

   input ic_rd_req;//logic 1: I2C slave is requesting data to tx
   input s_det;//logic 1: start detected
   input p_det;//logic 1: stop detected
   input rx_gen_call;//logic 1: slv received a general call
   input set_tx_empty_en;
   
   input tx_pop;         // tx fifo pop
   input rx_push;        // rx fifo push
   
   input tx_current_src_en;//mst HS tx current source enable
   input rx_current_src_en;//mst HS rx current source enable
   input start_en;//start generation enable
   input re_start_en;//re start generation enable
   input stop_en;//stop generation enable
   input mst_debug_data;//master in data phase
   input mst_debug_addr;//master in addr phase
   input slv_debug_data;//master in data phase
   input slv_debug_addr;//master in addr phase
   input mst_rx_en;//master receiver enable 
   input mst_tx_en;//master transmit enable
   input ic_enable_sync;//IC is enabled
   input ic_hs_sync;//IC in HS mode
   input hs_mcode_en;//HS master code send enable
   input rx_addr_10bit;//Rx address is 10bit
   input [3:0] slv_debug_cstate;
   input [4:0] mst_debug_cstate;
   input slv_clr_leftover;
   input ic_dis_window;

   /////////////////////////////
   //tx_abrt source
   input                        abrt_master_dis;//Access master while disabled
   input                        abrt_sbyte_norstrt;//Send SBYTE while restart is disabled
   input                        abrt_hs_norstrt;//Hisgh Speed mode while restart disabled
   input                        abrt_hs_ackdet;//High Speed Master code was acknowledged
   input                        abrt_sbyte_ackdet;//Start Byte was acknowleged
   input                        abrt_gcall_read;//Try to read while sending a Gcall
   input                        abrt_gcall_noack;//No slave acknowledged the G.CALL
   input                        abrt_7b_addr_noack;//7bit 1address was not acknowledged
   input                        abrt_txdata_noack;//Slave did not acknowledge sent data
   input                        abrt_10addr1_noack;//10 bit 1address was not acknowledged
   input                        abrt_10b_rd_norstrt;//10 bit read command while restart is disabled
   input                        abrt_10addr2_noack;//10 bit 2address was not acknowledged
   input                        abrt_user_abrt;
   input                        arb_lost;//Abort lost issues a tx abort as well

   //slv tx_abrt source indicator
   input                        abrt_slvflush_txfifo;//slave flush tx fifo to request tx data
   input                        abrt_slv_arblost;//Slave lost the bus while it is tx data
   input                        abrt_slvrd_intx;//Slave request data to tx and processor wrote 
   // a read command into the tx_fifo (9th bit is 1)

   //outputs
   output debug_s_gen;//start generated
   output debug_p_gen;//stop generated
   output debug_data;//data phase
   output debug_addr;//address phase
   output debug_rd;// IC is reading from the bus
   output debug_wr;//IC is writing the bus
   output debug_hs;//HS Mode
   output debug_master_act;//MAster is active
   output debug_slave_act;//Slave is active
   output debug_addr_10bit;//address is 10 bit

   output ic_current_src_en;//Current source enable output
   output ic_disable;
   output [3:0] debug_slv_cstate;
   output [4:0] debug_mst_cstate;
   output slv_clr_leftover_flg;
   output set_tx_empty_en_flg;
   
   output tx_abrt_flg;//if pclk is async. to ic_clk this signal toggles on tx_abrt signal
   output rx_done_flg;//if pclk is async. to ic_clk this signal toggles on rx_done signal
   output ic_rd_req_flg;//if pclk is async. to ic_clk this signal toggles on ic_rd_req signal
   output p_det_flg;//if pclk is async. to ic_clk this signal toggles on p_det signal

   output s_det_flg;//if pclk is async. to ic_clk this signal toggles on s_det signal
   output rx_gen_call_flg;//if pclk is async. to ic_clk this signal toggles on rx_gen_call signal
   output tx_pop_flg;//if pclk is async. to ic_clk this signal toggles on tx_pop signal
   output rx_push_flg;//if pclk is async. to ic_clk this signal toggles on rx_push signal
   output [`IC_TX_ABRT_SOURCE_RS-1:0] tx_abrt_source;//tx_abrt sources combined signals
   
   // ----------------------------------------------------------
   // -- local registers
   // ----------------------------------------------------------
   reg debug_s_gen;//start generated
   reg debug_p_gen;//stop generated
   reg debug_data;//data phase
   reg debug_addr;//address phase
   reg debug_rd;// IC is reading from the bus
   reg debug_wr;//IC is writing the bus
   reg debug_hs;//HS Mode
   reg debug_master_act;//MAster is active
   reg debug_slave_act;//Slave is active
   reg debug_addr_10bit;//address is 10 bit
   reg ic_current_src_en;//Current source enable output
   reg [3:0] debug_slv_cstate;
   reg [4:0] debug_mst_cstate;

   reg    tx_abrt_r;
   reg    rx_gen_call_r;
// -------------------------------------------------------------------------------- //
// -------------------------------------------------------------------------------- //
   reg    tx_abrt_tog;
   reg    rx_done_tog;  
   reg    ic_rd_req_tog;   
   reg    p_det_tog;
   reg    s_det_tog;
   reg    rx_gen_call_tog;   
   reg    tx_pop_tog;      
   reg    rx_push_tog;
   reg    slv_clr_leftover_tog;
   reg    set_tx_empty_en_tog;
   //tx_abrt sources toggle signals
   reg abrt_txdata_noack_tog;
   reg abrt_7b_addr_noack_tog;
   reg abrt_hs_ackdet_tog;
   reg abrt_hs_norstrt_tog;
   reg abrt_sbyte_norstrt_tog;
   reg abrt_master_dis_tog;
   reg abrt_sbyte_ackdet_tog;
   reg abrt_gcall_read_tog;
   reg abrt_gcall_noack_tog;
   reg abrt_10addr1_noack_tog;
   reg abrt_10b_rd_norstrt_tog;
   reg abrt_10addr2_noack_tog;
   reg abrt_user_abrt_tog;
   reg arb_lost_tog;
   reg abrt_slvflush_txfifo_tog;
   reg abrt_slv_arblost_tog;
   reg abrt_slvrd_intx_tog;

// -------------------------------------------------------------------------------- //
// -------------------------------------------------------------------------------- //

   wire [`IC_TX_ABRT_SOURCE_RS-1:0] tx_abrt_source;
 
   
   // ----------------------------------------------------------
   // -- local wires
   // ----------------------------------------------------------
   wire  tx_abrt;
   wire  rx_done;

   wire    tx_abrt_flg;
   wire    rx_done_flg;  
   wire    ic_rd_req_flg;   
   wire    p_det_flg;
   wire    s_det_flg;
   wire    rx_gen_call_flg;   
   wire    tx_pop_flg;      
   wire    rx_push_flg;
   wire    slv_clr_leftover_flg;
   wire    set_tx_empty_en_flg;
  
   wire ic_disable_a; 
   reg  ic_disable; 
   reg  ic_disable_r; 
   reg  ic_disable_r2; 

   // ----------------------------------------------------------
   // -- Combining Mst/Slv interrupts
   // ----------------------------------------------------------
   assign rx_done   = slv_rx_done;
   assign tx_abrt   = mst_tx_abrt 
                      | slv_tx_abrt
    ;

   assign ic_disable_a = ((!ic_enable_sync) & ic_dis_window 
                          );

   always @(posedge ic_clk or negedge ic_rst_n) begin : IC_DISABLE_REG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           ic_disable_r  <= 1'b1;
           ic_disable_r2 <= 1'b1;
           ic_disable    <= 1'b1;
        end 
      else 
        begin
           ic_disable_r  <= ic_disable_a;           
           ic_disable_r2 <= ic_disable_r;           
           ic_disable    <= ic_disable_r2;           
        end
   end




// -------------------------------------------------------------------------------- //
// -------------------------------------------------------------------------------- //
    
   // ----------------------------------------------------------
   // -- This block generates slv_clr_leftover_tog signal, 
   // -- which toggles on the rising edge of slv_clr_leftover_flg
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_CLR_LEFTOVER_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           slv_clr_leftover_tog <= 1'b0;
        end 
      else 
        begin
           if(slv_clr_leftover == 1'b1)
             slv_clr_leftover_tog <= ~slv_clr_leftover_tog;
        end
   end
   // ----------------------------------------------------------
   // -- This block generates abrt_master_dis_tog signal, 
   // -- which toggles on the rising edge of abrt_master_dis
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_MASTER_DIS_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_master_dis_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_master_dis == 1'b1)
             abrt_master_dis_tog <= ~abrt_master_dis_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_sbyte_norstrt_tog signal, 
   // -- which toggles on the rising edge of abrt_sbyte_norstrt
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_SBYTE_NORSTRT_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_sbyte_norstrt_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_sbyte_norstrt == 1'b1)
             abrt_sbyte_norstrt_tog <= ~abrt_sbyte_norstrt_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_hs_norstrt_tog signal, 
   // -- which toggles on the rising edge of abrt_hs_norstrt
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_HS_NORSTRT_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_hs_norstrt_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_hs_norstrt == 1'b1)
             abrt_hs_norstrt_tog <= ~abrt_hs_norstrt_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_hs_ackdet_tog signal, 
   // -- which toggles on the rising edge of abrt_hs_ackdet
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_HS_ACKDET_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_hs_ackdet_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_hs_ackdet == 1'b1)
             abrt_hs_ackdet_tog <= ~abrt_hs_ackdet_tog;
        end
   end
   
   // ----------------------------------------------------------
   // -- This block generates abrt_sbyte_ackdet_tog signal, 
   // -- which toggles on the rising edge of abrt_sbyte_ackdet
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_SBYTE_ACKDET_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_sbyte_ackdet_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_sbyte_ackdet == 1'b1)// && (abrt_sbyte_ackdet_r == 1'b0))
             abrt_sbyte_ackdet_tog <= ~abrt_sbyte_ackdet_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_gcall_read_tog signal, 
   // -- which toggles on the rising edge of abrt_gcall_read
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_GCALL_READ_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_gcall_read_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_gcall_read == 1'b1)
             abrt_gcall_read_tog <= ~abrt_gcall_read_tog;
        end
   end
   
   // ----------------------------------------------------------
   // -- This block generates abrt_gcall_noack_tog signal, 
   // -- which toggles on the rising edge of abrt_gcall_noack
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_GCALL_NOACK_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_gcall_noack_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_gcall_noack == 1'b1)
             abrt_gcall_noack_tog <= ~abrt_gcall_noack_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_7b_addr_noack_tog signal, 
   // -- which toggles on the rising edge of abrt_7b_addr_noack
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_7B_ADDR_NOACK_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_7b_addr_noack_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_7b_addr_noack == 1'b1)
             abrt_7b_addr_noack_tog <= ~abrt_7b_addr_noack_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_txdata_noack_tog signal, 
   // -- which toggles on the rising edge of abrt_txdata_noack
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_TXDATA_NOACK_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_txdata_noack_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_txdata_noack == 1'b1)// && (abrt_txdata_noack_r == 1'b0))
             abrt_txdata_noack_tog <= ~abrt_txdata_noack_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_10addr1_noack_tog signal, 
   // -- which toggles on the rising edge of abrt_10addr1_noack
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_10ADDR1_NOACK_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_10addr1_noack_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_10addr1_noack == 1'b1)
             abrt_10addr1_noack_tog <= ~abrt_10addr1_noack_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_10b_rd_norstrt_tog signal, 
   // -- which toggles on the rising edge of abrt_10b_rd_norstrt
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_10B_RD_NORSTRT_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_10b_rd_norstrt_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_10b_rd_norstrt == 1'b1)
             abrt_10b_rd_norstrt_tog <= ~abrt_10b_rd_norstrt_tog;
        end
   end
   

   // ----------------------------------------------------------
   // -- This block generates abrt_10addr2_noack_tog signal, 
   // -- which toggles on the rising edge of abrt_10addr2_noack
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_10ADDR2_NOACK_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_10addr2_noack_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_10addr2_noack == 1'b1)
             abrt_10addr2_noack_tog <= ~abrt_10addr2_noack_tog;
        end
   end
   // ----------------------------------------------------------
   // -- This block generates abrt_user_abrt_tog signal, 
   // -- which toggles on the rising edge of abrt_user_abrt
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_USER_ABRT_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_user_abrt_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_user_abrt == 1'b1)
             abrt_user_abrt_tog <= ~abrt_user_abrt_tog;
        end
   end


   // ----------------------------------------------------------
   // -- This block generates arb_lost_tog signal, 
   // -- which toggles on the rising edge of arb_lost
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ARB_LOST_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           arb_lost_tog <= 1'b0;
        end 
      else 
        begin
           if(arb_lost == 1'b1)
             arb_lost_tog <= ~arb_lost_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates abrt_slvflush_txfifo_tog signal, 
   // -- which toggles on the rising edge of abrt_slvflush_txfifo
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_SLVFLUSH_TXFIFO_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_slvflush_txfifo_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_slvflush_txfifo == 1'b1)
             abrt_slvflush_txfifo_tog <= ~abrt_slvflush_txfifo_tog;
        end
   end
   
   // ----------------------------------------------------------
   // -- This block generates abrt_slv_arblost_tog signal, 
   // -- which toggles on the rising edge of abrt_slv_arblost
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_SLV_ARBLOST_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_slv_arblost_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_slv_arblost == 1'b1)
             abrt_slv_arblost_tog <= ~abrt_slv_arblost_tog;
        end
   end
   
   // ----------------------------------------------------------
   // -- This block generates abrt_slvrd_intx_tog signal, 
   // -- which toggles on the rising edge of abrt_slvrd_intx
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : ABRT_SLVRD_INTX_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           abrt_slvrd_intx_tog <= 1'b0;
        end 
      else 
        begin
           if(abrt_slvrd_intx == 1'b1)
             abrt_slvrd_intx_tog <= ~abrt_slvrd_intx_tog;
        end
   end
   


   // ----------------------------------------------------------
   // -- This block generates tx_abrt_tog signal, 
   // -- which toggles on the rising edge of tx abrt
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_ABRT_R_PROC
      if(ic_rst_n == 1'b0) 
        begin
           tx_abrt_r <= 1'b0;
        end 
      else 
        begin
           tx_abrt_r <= tx_abrt;           
        end
   end

   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_ABRT_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           tx_abrt_tog <= 1'b0;
        end 
      else 
        begin
           if((tx_abrt == 1'b1) && (tx_abrt_r == 1'b0))
             tx_abrt_tog <= ~tx_abrt_tog;
        end
   end
   
   // ----------------------------------------------------------
   // -- This block generates rx_done_tog signal, 
   // -- which toggles on the rising edge of rx_done
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : RX_DONE_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           rx_done_tog <= 1'b0;
        end 
      else 
        begin
           if(rx_done == 1'b1)
             rx_done_tog <= ~rx_done_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates tx_pop_tog signal, 
   // -- which toggles on the rising edge of tx_pop
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_POP_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           tx_pop_tog <= 1'b0;
        end 
      else 
        begin
           if(tx_pop == 1'b1)
             tx_pop_tog <= ~tx_pop_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates rx_push_tog signal, 
   // -- which toggles on the rising edge of rx_push
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : RX_PUSH_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           rx_push_tog <= 1'b0;
        end 
      else 
        begin
           if(rx_push == 1'b1)
             rx_push_tog <= ~rx_push_tog;
        end
   end
   // ----------------------------------------------------------
   // -- This block generates ic_rd_req_tog signal, 
   // -- which toggles on the rising edge of ic_rd_req
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : IC_RD_REQ_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           ic_rd_req_tog <= 1'b0;
        end 
      else 
        begin
           if(ic_rd_req == 1'b1)
             ic_rd_req_tog <= ~ic_rd_req_tog;
        end
   end
   // ----------------------------------------------------------
   // -- This block generates s_det_tog signal, 
   // -- which toggles on the rising edge of s_det
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : S_DET_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           s_det_tog <= 1'b0;
        end 
      else 
        begin
           if(s_det == 1'b1)
             s_det_tog <= ~s_det_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates p_det_tog signal, 
   // -- which toggles on the rising edge of p_det
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : P_DET_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           p_det_tog <= 1'b0;
        end 
      else 
        begin
           if(p_det == 1'b1)
             p_det_tog <= ~p_det_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates  set_tx_empty_en_tog signal, 
   // -- which toggles on the rising edge of set_tx_empty_en
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_EMPTY_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           set_tx_empty_en_tog <= 1'b0;
        end 
      else 
        begin
           if(set_tx_empty_en == 1'b1)
             set_tx_empty_en_tog <= ~set_tx_empty_en_tog;
        end
   end

   // ----------------------------------------------------------
   // -- This block generates rx_gen_call_tog signal, 
   // -- which toggles on the rising edge of rx_gen_call
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : RX_GEN_CALL_R_PROC
      if(ic_rst_n == 1'b0) 
        begin
           rx_gen_call_r <= 1'b0;
        end 
      else 
        begin
           rx_gen_call_r <= rx_gen_call;           
        end
   end

   always @(posedge ic_clk or negedge ic_rst_n) begin : RX_GEN_CALL_TOG_PROC
      if(ic_rst_n == 1'b0) 
        begin
           rx_gen_call_tog <= 1'b0;
        end 
      else 
        begin
           if((rx_gen_call == 1'b1) && (rx_gen_call_r == 1'b0))
             rx_gen_call_tog <= ~rx_gen_call_tog;
        end
   end



   assign    tx_abrt_flg          = tx_abrt_tog;
   assign    rx_done_flg          = rx_done_tog;
   assign    ic_rd_req_flg        = ic_rd_req_tog;   
   assign    p_det_flg            = p_det_tog;
   assign    s_det_flg            = s_det_tog;
   assign    rx_gen_call_flg      = rx_gen_call_tog;   
   assign    tx_pop_flg           = tx_pop_tog;      
   assign    rx_push_flg          = rx_push_tog;
   assign    slv_clr_leftover_flg = slv_clr_leftover_tog;
   assign    set_tx_empty_en_flg  = set_tx_empty_en_tog;
   assign    tx_abrt_source[0]    = abrt_7b_addr_noack_tog;
   assign    tx_abrt_source[1]    = abrt_10addr1_noack_tog;
   assign    tx_abrt_source[2]    = abrt_10addr2_noack_tog;
   assign    tx_abrt_source[3]    = abrt_txdata_noack_tog;
   assign    tx_abrt_source[4]    = abrt_gcall_noack_tog;
   assign    tx_abrt_source[5]    = abrt_gcall_read_tog;
   assign    tx_abrt_source[6]    = abrt_hs_ackdet_tog;
   assign    tx_abrt_source[8]    = abrt_hs_norstrt_tog;
   assign    tx_abrt_source[7]    = abrt_sbyte_ackdet_tog;
   assign    tx_abrt_source[10]   = abrt_10b_rd_norstrt_tog;
   assign    tx_abrt_source[12]   = arb_lost_tog;
   assign    tx_abrt_source[13]   = abrt_slvflush_txfifo_tog;
   assign    tx_abrt_source[14]   = abrt_slv_arblost_tog;
   assign    tx_abrt_source[15]   = abrt_slvrd_intx_tog;
   assign    tx_abrt_source[9]    = abrt_sbyte_norstrt_tog;
   assign    tx_abrt_source[11]   = abrt_master_dis_tog;
   assign    tx_abrt_source[16]   = abrt_user_abrt_tog;
// -------------------------------------------------------------------------------- //
// -------------------------------------------------------------------------------- //
  
// ----------------------------------------------------------
// -- This block passes the toggled or the original signal 
// -- based on the IC_CLK_TYPE paremeter
// ----------------------------------------------------------

   // ----------------------------------------------------------
   // -- Debug outputs generation
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : DEBUG_OUT_PROC
      if(ic_rst_n == 1'b0) 
        begin
           ic_current_src_en <= 1'b0;
           debug_s_gen <= 1'b0;
           debug_p_gen <= 1'b0;
           debug_data  <= 1'b0;
           debug_addr  <= 1'b0;
           debug_rd    <= 1'b0;
           debug_wr    <= 1'b0;
           debug_hs    <= 1'b0;
           debug_master_act <= 1'b0;
           debug_slave_act  <= 1'b0;
           debug_addr_10bit <= 1'b0;
           debug_slv_cstate <= 4'h0;
           debug_mst_cstate <= 5'h00;

        end 
      else 
        begin
           ic_current_src_en <= tx_current_src_en | rx_current_src_en;
           debug_s_gen <= start_en|re_start_en;
           debug_p_gen <= stop_en;
           debug_data  <= mst_debug_data | slv_debug_data;
           debug_addr  <= mst_debug_addr | slv_debug_addr;
           debug_rd    <= mst_rx_en;  
           debug_wr    <= mst_tx_en;
           debug_hs    <= ic_enable_sync & ic_hs_sync & mst_activity & (~hs_mcode_en);
           debug_master_act <= mst_activity;
           debug_slave_act  <= slv_activity;
           debug_addr_10bit <= rx_addr_10bit;
           debug_slv_cstate <= slv_debug_cstate;
           debug_mst_cstate <= mst_debug_cstate;

        end
   end


   
endmodule // DW_apb_i2c_toggle
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #18 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_rx_shift.v#18 $ 
//
//
// File    : DW_apb_i2c_rx_shift.v
//
//
// Author  : Hani Saleh
// Created : Sep  2002
// Abstract: The rx_shft_reg module is responsible for receiving
//           a byte of data to either a slave or master in either 
//           Master or Slave mode configuration.  This module will
//           also generate the acknowledge pulse after a byte of 
//           data has been received 
//
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

module DW_apb_i2c_rx_shift
  (
   ic_clk
                             ,ic_rst_n
                             ,//regfile
                             ic_hs_sync
                             ,//mstfsm signals
                             mst_rx_en
                             ,mst_push_rxfifo_en
                             ,mst_rxbyte_rdy   
                             ,mst_rx_cmplt
                             ,// jduarte end 20101008
                             //slvfsm signals
                             slv_rx_en
                             ,slv_rx_1byte_en
                             ,slv_rx_2byte_en
                             ,rx_slv_read
                             ,slv_push_rxfifo_en
                             ,slv_rxbyte_rdy
                             ,slv_rx_2addr
                             ,rx_gen_call
                             ,rx_addr_match
                             ,rx_addr_10bit
                             ,rx_hs_mcode
                             ,//clk_gen signals
                             hs_mcode_en
                             ,ic_ack_general_call
                             ,rx_scl_lcnt_en
                             ,rx_scl_hcnt_en
                             ,scl_lcnt_cmplt
                             ,scl_hcnt_cmplt
                             ,//from rx_filter
                             sda_int
                             ,sda_vld
                             ,slv_rx_ack_vld
                             ,scl_int
                             ,scl_edg_hl
                             ,//rx shift reg
                             mst_rx_ack_vld
                             ,// jduarte begin 20101108
                             // CRM 9000366029
                             rx_shift_data_done
                             ,// jduarte end 20101108
                             //top level outputs
                             rx_current_src_en
                             ,//fifo cntl signals
                             rx_push
                             ,//regfile
                             ic_sar
                             ,ic_10bit_slv
                             ,mst_rxbyte_rdy_done
                             ,//fifo ram
                             rx_push_data
                             ,//tx_shift_reg
                             mst_rx_bwen
                             ,mst_rx_data_scl
                             ,mst_rx_bit_count
                             ,mstrx1_7_end
                             );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;// processor clock
   input ic_rst_n;// syn rst active high
   //mstfsm signals
   input                    mst_rx_en; // Enable rx shift register to transmit data
   input                    mst_push_rxfifo_en;//logic 1:push received data to the RX fifo
// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
   //slvfsm signals
   input                    slv_rx_en;//slave enable RX
   input                    slv_rx_1byte_en;//slave receive 1st byte
   input                    slv_rx_2byte_en;//slave receive 2nd byte
   input                    slv_push_rxfifo_en;//slave push data to rx fifo enable
   input                    slv_rx_2addr;//1: 2nd address byte in 10 bit mode has been received

   //regfile
   input                    ic_hs_sync;//ic is in high speed mode
   //from rx_filter
   input                    sda_int;//SDA bus value
   input                    sda_vld;//SDA value is valid
   input                    scl_int;//internal filtered input SCL line
   input                    scl_edg_hl;   // falling edge detect of SCL

   //from clk_gen
   input                    scl_lcnt_cmplt;//Low count completed
   input                    scl_hcnt_cmplt;//High count completed
   //regfile
   input [`IC_SAR_RS-1:0]  ic_sar;//IC module address to other Masters
   input                    ic_10bit_slv;//IC slave 10 bit address mode selection
   input                    hs_mcode_en;//IC in HS mode and transmitting the HS Master Code
   input                    ic_ack_general_call;
   //OUTPUTS
   output                    rx_slv_read;//logic 1:slave is written
   output                    mst_rx_ack_vld;//logic 1:check for ack now

// jduarte begin 20101108
// CRM 9000366029
   output                    rx_shift_data_done;
// jduarte end 20101108


   //to fifo ram
   output [`IC_DATA_FIFO_RS-1:0] rx_push_data;//push data to rx fifo

   //to slv_fsm
   output                         mst_rxbyte_rdy;//logic 1: master received byte is ready
   output                         mst_rxbyte_rdy_done;
   output    mst_rx_cmplt;//master rx completed

   output                        slv_rxbyte_rdy; //Indicates that a byte has been received
   output                        rx_gen_call;//General Call address has been received and acknowledged
//   output                        rx_start_byte;// Start byte has been received
   output                        rx_addr_match;//logic 1: An Address has been received and matched ours, logic 0: address fail
   output                        rx_addr_10bit;//Rx address is 10bit
   output                        rx_hs_mcode;//logic 1:High speed mode code has been received




   //to fifo cntl
   output                         rx_push;//logic 1: push data to rx fifo
   //to clk_gen
   output                         rx_scl_lcnt_en;
   output                         rx_scl_hcnt_en;
   //to top level
   output                         rx_current_src_en;//logic 1:enables pull up current source in HS mode
   output slv_rx_ack_vld;//logic 1:slave receiver ack is valid
   //to tx shift reg
   output              mst_rx_data_scl;//Master rx generated clock signal
   output              mst_rx_bwen;//master rx byte wait enable

   output [3:0]        mst_rx_bit_count;
   output              mstrx1_7_end;
   // ----------------------------------------------------------
   // -- local wires
   // ----------------------------------------------------------
   //registers
   reg [`IC_DATA_RS-1:0]         mst_rx_shift_reg;//Master RX shift register
   reg [`IC_DATA_RS-1:0]         slv_rx_shift_reg;//Slave RX shift register
   //to clk_gen
   reg                           rx_scl_lcnt_en;
   reg                           rx_scl_hcnt_en;
   
   reg                           rx_current_src_en;
   reg [`IC_DATA_FIFO_RS-1:0]    rx_push_data;
   reg [3:0]                     mst_rx_bit_count;
   reg                           mst_rx_data_scl;
   reg                           mst_rx_ack_int;//logic 1: This is the ack clock cycle
   reg                           mst_rxbyte_rdy;//logic 1: 1 byte has been received and ready
   reg                           slv_rx_ack_vld;
   reg [3:0]                     slv_rx_bit_count;
   reg [3:0]                     scl_hl_edg_cntr;
   reg                           slv_rxbyte_rdy;
   reg                           rx_gen_call;
   reg                           rx_addr_match;
   reg                           rx_addr_10bit;
   reg                           rx_hs_mcode;
   reg                           rx_slv_read;
   reg                            rx_slv_read_s;

   reg                           rx_push;
   reg                           mst_rx_bwen;//master rx byte wait enable
// jduarte begin 20101108
// CRM 9000424562
   reg                           scl_int_r;
// jduarte end 20101108
   reg    mst_rxbyte_rdy_done;
   //wires   
   wire rx_rdy_en;
   wire slvrx_bit1_7_lo;
   wire slvrx_bit1_7_hi;
   wire slvrx_bit8;
   wire rx_mcode;
   wire rx_10bit_1addr;
   wire rx_10b_in7bit;
   wire rx_7bit_addr;
   wire rx_2byte;
   wire rx_10bit_2addr;
   wire mst_rx_cmplt;
   wire mst_enrx;
   wire mstrx1_7_lo;
   wire mstrx1_7_hi;
   wire mstrx1_7_end;
   wire mstrx1_7_end_int;
   wire mstrx_8_lo;
   wire mstrx_8_hi;
   wire mstrx_8_end;
   wire mstrx_8_end_int;
   wire [2:0] mst_rx_bit_count_2to0;
   wire [2:0] slv_rx_bit_count_2to0;
// jduarte begin 20101108
// CRM 9000424562
   wire scl_int_ed;
// jduarte end 20101108
   
   
// jduarte begin 20101108
// CRM 9000366029
   wire rx_shift_data_done;
// jduarte end 20101108
   assign mst_rx_bit_count_2to0 = mst_rx_bit_count[2:0];
   assign slv_rx_bit_count_2to0 = slv_rx_bit_count[2:0];
   //assigning outputs to internal signal
   assign    mst_rx_ack_vld = mst_rx_ack_int;
   // ------------------------------------------------------
   // -- rx_push output
   //
   //  The rx_push output is used in the pclk
   //  domain to remove data
   //  from the tx fifo.
   // ------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : PUSH_RX_PROC
      if(ic_rst_n == 1'b0)
        rx_push <= 1'b0;
      else
        rx_push <= (slv_push_rxfifo_en == 1'b1) 
        || (mst_push_rxfifo_en == 1'b1)
        ;
   end
   

   // ------------------------------------------------------
   // -- rx_fifo data buffer
   //
   // -- This buffer is used to store the last pushed data
   // -- to the rx fifo
   // ------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : RX_FIFO_DATA_PROC
      if(ic_rst_n == 1'b0) begin
         rx_push_data <= {`IC_DATA_FIFO_RS{1'b0}};
      end else begin
         if(mst_rxbyte_rdy== 1'b1) begin
            rx_push_data <= mst_rx_shift_reg;
         end
         else 
             if(slv_rxbyte_rdy== 1'b1) begin
            rx_push_data <= slv_rx_shift_reg;
         end
      end
   end

   // ------------------------------------------------------
   // -- slave rx shift process
   //
   // -- The size of a data transfer is always 8 
   // -- bits.  
   // ------------------------------------------------------

   assign rx_rdy_en = (slv_rx_en == 1'b1);
   assign slvrx_bit1_7_lo = ((scl_edg_hl == 1'b1) && (slv_rx_bit_count < 8));
   assign slvrx_bit1_7_hi = ((slv_rx_bit_count < 8)&&(sda_vld == 1'b1));
   assign slvrx_bit8 = (slv_rx_bit_count == 8) && ((slv_rx_1byte_en == 1'b1)
           );
   assign rx_mcode = (( slv_rx_shift_reg[`IC_DATA_RS - 1:3] == `IC_HS_CODE));
   assign rx_10bit_1addr = (( slv_rx_shift_reg[`IC_DATA_RS - 1:1] == {`IC_SLV_ADDR_10BIT,ic_sar[9:8]}) && (ic_10bit_slv == 1'b1));
   assign rx_10b_in7bit = (( slv_rx_shift_reg[`IC_DATA_RS - 1:3] == `IC_SLV_ADDR_10BIT) && (ic_10bit_slv == 1'b0));
   assign rx_7bit_addr = ((slv_rx_shift_reg[`IC_DATA_RS - 1:1] == ic_sar[6:0]) && (ic_10bit_slv == 1'b0));
   assign rx_2byte = ((slv_rx_bit_count == 8) && (slv_rx_2byte_en == 1'b1));
   assign rx_10bit_2addr = (( slv_rx_shift_reg[`IC_DATA_RS - 1:0] == ic_sar[7:0]) && (ic_10bit_slv == 1'b1));

   always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_RX_SHIFT_PROC
      if(ic_rst_n == 1'b0) begin
         slv_rx_shift_reg <= {`IC_DATA_RS{1'b0}};
         slv_rx_bit_count <= 4'b0000;
         scl_hl_edg_cntr  <= 4'b0000;
         slv_rxbyte_rdy <= 1'b0;
         slv_rx_ack_vld <= 1'b0;
         rx_gen_call     <= 1'b0;
         rx_addr_match   <= 1'b0;
         rx_addr_10bit   <= 1'b0;
         rx_hs_mcode  <= 1'b0;
         //LK-- rx_slv_read      <= 1'b0;
         
      end else if (rx_rdy_en == 1'b1) begin
         slv_rx_bit_count <= (scl_hl_edg_cntr == 4'h0) ? scl_hl_edg_cntr : 
                             ((slv_rx_1byte_en == 1'b1) ? (scl_hl_edg_cntr - {3'h0,1'b1} ): scl_hl_edg_cntr);             
         
         if(slvrx_bit1_7_lo == 1'b1) begin
              scl_hl_edg_cntr <= scl_hl_edg_cntr + {3'h0,1'b1};
         end
         else if (slvrx_bit1_7_hi == 1'b1) begin
              slv_rxbyte_rdy  <= 1'b0;
              slv_rx_ack_vld  <= 1'b0;
              rx_gen_call     <= 1'b0;
              rx_addr_match   <= 1'b0;
              rx_addr_10bit   <= 1'b0;
              rx_hs_mcode  <= 1'b0;
              //LK-- rx_slv_read       <= 1'b0;
              case(slv_rx_bit_count_2to0)
                0       : slv_rx_shift_reg[7] <= sda_int;
                1       : slv_rx_shift_reg[6] <= sda_int;
                2       : slv_rx_shift_reg[5] <= sda_int;
                3       : slv_rx_shift_reg[4] <= sda_int;
                4       : slv_rx_shift_reg[3] <= sda_int;
                5       : slv_rx_shift_reg[2] <= sda_int;
                6       : slv_rx_shift_reg[1] <= sda_int;
                default : slv_rx_shift_reg[0] <= sda_int;
              endcase
         end else if(slvrx_bit8 == 1'b1) begin
             //LK-- rx_slv_read <= slv_rx_1byte_en & slv_rx_shift_reg[0];//Only the 1st addrss byte indicates the direction

             slv_rxbyte_rdy <= scl_edg_hl;

              if(scl_edg_hl == 1'b0)
                begin
                   if(rx_mcode == 1'b1)
                     begin
                        rx_hs_mcode <= 1'b1;
                        slv_rx_ack_vld <= 1'b0;//dont acknowledge  HS_MCODE
                     end
                   
                   else 
                       if( slv_rx_shift_reg[`IC_DATA_RS - 1:0] == `IC_GENERAL_CALL)
                     begin
                        rx_gen_call <=1'b1;
                        if(ic_ack_general_call)    // If the ACK_GENERAL_CALL reg is set,
                          slv_rx_ack_vld <= 1'b1;  // then ACK the address
                        else
                          slv_rx_ack_vld <= 1'b0;  // Otherwise, NAK the address.
                     end
                   
                   else if( slv_rx_shift_reg[`IC_DATA_RS - 1:0] == `IC_START_BYTE)
                     begin
                        slv_rx_ack_vld <= 1'b0;//dont acknowledge  start byte
                     end
                   else if(rx_10bit_1addr == 1'b1)
                     begin
                        rx_addr_10bit  <= 1'b1;//address received is 10 bit
                        rx_addr_match  <= ~rx_slv_read 
                                          | (rx_slv_read & slv_rx_2addr);
                        slv_rx_ack_vld <= ~rx_slv_read_s 
                                          | (rx_slv_read_s & slv_rx_2addr);//Acknowledge only
                        //if this is a switch of diriction and we 
                        // were addressed before
                     end

                   else if(rx_10b_in7bit == 1'b1)
                     begin
                        rx_addr_10bit  <= 1'b1;//address received is 10 bit 
                                               // while i2c slave is 7 bit
                        rx_addr_match  <= 1'b0;
                        slv_rx_ack_vld <= 1'b0;
                     end
                    
                   else if(rx_7bit_addr == 1'b1)
                     begin
                        rx_addr_10bit  <= 1'b0;//address received is 7 bit
                        rx_addr_match  <= 1'b1;
                        slv_rx_ack_vld <= 1'b1;
                     end
                end // if (scl_edg_hl == 1'b0)
           end // if ((slv_rx_bit_count == 8) &&...
         
         else if(rx_2byte == 1'b1) begin
            slv_rxbyte_rdy <= scl_edg_hl;

            if(scl_edg_hl == 1'b0) begin
              if(rx_10bit_2addr == 1'b1) begin
               rx_addr_match   <= rx_10bit_2addr;
               slv_rx_ack_vld <= rx_10bit_2addr;
              end // if ((slv_rx_bit_count == 8) &&...
            end
         end // if ((slv_rx_bit_count == 8) &&...
         else begin //if((slv_rx_bit_count == 8)
           slv_rx_ack_vld <= (slv_rx_bit_count == 4'h8) ? 1'b1:1'b0;

           slv_rxbyte_rdy <= scl_edg_hl;


         end 
         
      end // if ((slv_rx_en == 1'b1) && (slv_rxbyte_rdy == 1'b0))
      else if (slv_rx_en == 1'b0)
        begin
           slv_rx_shift_reg <= {`IC_DATA_RS{1'b0}};
           slv_rx_bit_count <= 4'b0000;
           scl_hl_edg_cntr  <= 4'b0000;
           slv_rxbyte_rdy   <= 1'b0;
           slv_rx_ack_vld   <= 1'b0;
           rx_gen_call     <= 1'b0;
           rx_addr_match   <= 1'b0;
           rx_addr_10bit   <= 1'b0;
           rx_hs_mcode  <= 1'b0;
           //LK-- rx_slv_read       <= 1'b0;
        end // if (slv_rx_en == 1'b0)
   end // block: SLV_RX_SHIFT_PROC

  // =====================================================
  // Generate the "rx_slv_read" signal
  //
  // "slv_rx_ack_vld" uses "rx_slv_read" originally. In
  // fixing glitches in "ic_data_oe", "slv_rx_ack_vld" now
  // uses "rx_slv_read_s". See CRM 9000083225.
  // =====================================================
  wire slv_rx_shift_reg_bit0;
  assign slv_rx_shift_reg_bit0 = slv_rx_shift_reg[0];

  always @(posedge ic_clk or negedge ic_rst_n) begin : RX_SLV_READ_PROC
    if(!ic_rst_n)
      rx_slv_read <= 1'd0;
    else
      rx_slv_read <= rx_slv_read_s;
  end // always

  always @(   slv_rx_en 
           or slvrx_bit1_7_hi
           or slvrx_bit8
           or rx_slv_read
           or slv_rx_1byte_en 
           or slv_rx_shift_reg_bit0 ) begin : RX_SLV_READ_S_PROC
    rx_slv_read_s = rx_slv_read;

    if(slv_rx_en) begin
      if(slvrx_bit1_7_hi)
        rx_slv_read_s = 1'd0;
      else if(slvrx_bit8)
        rx_slv_read_s = slv_rx_1byte_en & slv_rx_shift_reg_bit0;
    end else begin
      rx_slv_read_s = 1'd0;
    end
  end // always

   // ------------------------------------------------------
   // -- master rx shift process
   //
   // -- The size of a data transfer is always 8 
   // -- bits.  
   // ------------------------------------------------------ 

   assign mst_rx_cmplt = (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt ==1'b1) && (mst_rx_ack_int == 1'b1);

   assign mst_enrx = (mst_rx_en == 1'b1);
   assign mstrx1_7_lo = ((mst_rx_bit_count < 8) && (scl_lcnt_cmplt == 1'b0));
   assign mstrx1_7_hi = ((mst_rx_bit_count < 8) && (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt == 1'b0));
   assign mstrx1_7_end_int = ((scl_lcnt_cmplt == 1'b1) 
                              && (rx_scl_lcnt_en == 1'b1) && (rx_scl_hcnt_en == 1'b1));
   assign mstrx1_7_end = ((mstrx1_7_end_int == 1'b1) 
                          && (mst_rx_bit_count < 8) && (scl_hcnt_cmplt == 1'b1));
   
   assign mstrx_8_lo = ((mst_rx_bit_count == 8) && (scl_lcnt_cmplt == 1'b0) && (scl_hcnt_cmplt == 1'b0));
   assign mstrx_8_hi = ((mst_rx_bit_count == 8) && (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt == 1'b0));
   assign mstrx_8_end_int = ((scl_lcnt_cmplt == 1'b1) 
                             && (rx_scl_lcnt_en == 1'b1) && (rx_scl_hcnt_en == 1'b1));
   assign mstrx_8_end = ((mstrx_8_end_int == 1'b1) && (mst_rx_bit_count == 8) && (scl_hcnt_cmplt == 1'b1));
   
// jduarte begin 20101108
// CRM 9000366029
   assign rx_shift_data_done = (mst_rx_bit_count == 4'b0111) && mstrx1_7_end;
// jduarte end 20101108
   
   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Ensure that the sequential and combinational parts of an FSM description 
   //     should be in separate always blocks.
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_RX_SHIFT_PROC
      if(ic_rst_n == 1'b0) begin
         mst_rx_shift_reg <= {`IC_DATA_RS{1'b0}};
         mst_rx_bit_count <= 4'b0000;
         mst_rx_ack_int <= 1'b0;
// jduarte begin 20101108
// CRM 9000424562
//         rx_current_src_en <= 1'b0;
// jduarte end 20101108
         mst_rxbyte_rdy <= 1'b0;
         mst_rx_data_scl <= 1'b1;
         rx_scl_lcnt_en <= 1'b0;
         mst_rxbyte_rdy_done <= 1'b0;
         rx_scl_hcnt_en <= 1'b0;
      end else if (mst_enrx == 1'b1)
        begin

         if (mstrx1_7_lo == 1'b1)
           begin
         
              mst_rx_ack_int <= 1'b0;
              
// jduarte begin 20101108
// CRM 9000424562
//              if (src_on == 1'b1)
//                rx_current_src_en <= 1'b1;
// jduarte end 20101108

              mst_rxbyte_rdy <= 1'b0;
              mst_rx_data_scl <= 1'b0;
              rx_scl_lcnt_en <= 1'b1;
              rx_scl_hcnt_en <= 1'b0;
           end
         
         else if(mstrx1_7_hi == 1'b1)
           begin
              mst_rx_data_scl <= 1'b1;
              rx_scl_lcnt_en <= 1'b1;

                if(rx_scl_hcnt_en == 1'b0)//Bit wait state condition
                  rx_scl_hcnt_en <= (scl_int == 1'b1) ? 1'b1 : 1'b0;
                else
                  rx_scl_hcnt_en <= 1'b1;
           end

         else if(mstrx1_7_end == 1'b1)
           begin
              case (mst_rx_bit_count_2to0)
                0 : mst_rx_shift_reg[7] <= sda_int;
                1 : mst_rx_shift_reg[6] <= sda_int;
                2 : mst_rx_shift_reg[5] <= sda_int;
                3 : mst_rx_shift_reg[4] <= sda_int;
                4 : mst_rx_shift_reg[3] <= sda_int;
                5 : mst_rx_shift_reg[2] <= sda_int;
                6 : mst_rx_shift_reg[1] <= sda_int;
                default : mst_rx_shift_reg[0] <= sda_int;
              endcase               
              mst_rx_bit_count <= mst_rx_bit_count + {3'h0,1'b1};
              mst_rx_data_scl <= 1'b0;
              rx_scl_lcnt_en <= 1'b0;
              rx_scl_hcnt_en <= 1'b0;
           end
         
         else if(mstrx_8_lo == 1'b1)
           begin
                mst_rxbyte_rdy <= 1'b0;
              

              mst_rx_ack_int <= 1'b1;//gen ack during the low state of SCL
// jduarte begin 20101008
// CRM 9000366029
//              rx_scl_lcnt_en <= 1'b1;
              mst_rx_data_scl <= 1'b0;
              rx_scl_lcnt_en <= 1'b1;
// jduarte end 20101008
              rx_scl_hcnt_en <= 1'b0;
           end
         
         else if(mstrx_8_hi == 1'b1)
           begin
              mst_rx_ack_int <= 1'b1;//it is scl high keep the ack sda value
              mst_rxbyte_rdy <= 1'b0;
              mst_rx_data_scl <= 1'b1;
              rx_scl_lcnt_en <= 1'b1;

                if(rx_scl_hcnt_en == 1'b0)//Bit wait state condition
                  rx_scl_hcnt_en <= (scl_int == 1'b1) ? 1'b1 : 1'b0;
                else
                  rx_scl_hcnt_en <= 1'b1;
           end

         else if(mstrx_8_end == 1'b1)
           begin
// jduarte begin 20101008
// CRM 9000366029
//              mst_rx_bit_count <= 4'b0000;
              mst_rx_bit_count <= 4'b0000;
// jduarte end 20101008

// jduarte begin 20101108
// CRM 9000424562
//              if (ic_hs_sync == 1'b1)
//                rx_current_src_en <= 1'b0;
// jduarte end 20101108
              
// CRM 9000424562

              mst_rx_ack_int <= 1'b1;
              mst_rxbyte_rdy <= 1'b1;
              mst_rxbyte_rdy_done <= 1'b0;
              mst_rx_data_scl <= 1'b1;
              rx_scl_lcnt_en <= 1'b0;
              rx_scl_hcnt_en <= 1'b0;
           end
         end
         else if (mst_rx_en == 1'b0)
               begin
                 mst_rx_bit_count <= 4'b0000;
                 mst_rx_ack_int <= 1'b0;
// jduarte begin 20101108
// CRM 9000424562
//                 rx_current_src_en <= 1'b0;
// jduarte end 20101108
                 mst_rxbyte_rdy <= 1'b0;
                 mst_rx_data_scl <= 1'b1;
                 rx_scl_lcnt_en <= 1'b0;
                 rx_scl_hcnt_en <= 1'b0;
                end
   end // block: RX_SHIFT_PROC
   //spyglass enable_block STARC05-2.11.3.1

// jduarte begin 20101108
// CRM 9000424562
   always @(posedge ic_clk or negedge ic_rst_n) begin : IC_CLOCK_IN_R_PROC  
       if(ic_rst_n == 1'b0) begin
           scl_int_r <= 1'b1;
       end else begin
           scl_int_r <= scl_int;
       end
   end
      
   assign scl_int_ed = scl_int && (~scl_int_r);
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_CURRENT_SRC_EN_PROC
       if(ic_rst_n == 1'b0) begin
            rx_current_src_en <= 1'b0;
       end else begin
            if(((mst_rx_bit_count == 0) && mstrx1_7_lo) || (~((ic_hs_sync == 1'b1) && (hs_mcode_en == 1'b0)))) begin
                rx_current_src_en <= 1'b0;
            end else if((mst_rx_bit_count == 0) && scl_int_ed) begin
                rx_current_src_en <= 1'b1;
            end
       end
   end
// jduarte end 20101108
   // ------------------------------------------------------
   // -- master rx byte wait enable process
   //
   // ------------------------------------------------------ 
      always @(posedge ic_clk or negedge ic_rst_n) begin : MST_RX_BWEN_PROC
      if(ic_rst_n == 1'b0) begin
         mst_rx_bwen <= 1'b0;
      end else 
        if (mstrx1_7_lo == 1'b1)
          mst_rx_bwen <= 1'b0;
      
        else if(mstrx_8_hi ==1'b1)
          mst_rx_bwen <= rx_scl_hcnt_en;
   end // block: MST_RX_BWEN

   
endmodule // DW_apb_i2c_rx_shift

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #18 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_clk_gen.v#18 $ 
//
//
// File    : DW_apb_i2c_clk_gen.v
//
//
// Author  : Hani Saleh
// Created : Sep, 2002
// Abstract: This module is used to calculate the required timing and
//           to create the SCL clock when configured as MASTER mode.
//           This module will also calculate the timing required for 
//           bus idle signal, START and STOP conditions.
//
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

module DW_apb_i2c_clk_gen
  (
   //top level signals
   ic_clk,
                            ic_rst_n,
                            //rx_filter signals
                            sda_int,
                            scl_int,
                            s_det,
                            p_det,
                            //inputs from regfile
                            ic_hcnt,
                            ic_lcnt,
                            ic_fs_lcnt,
                            ic_fs_hcnt,
                            ic_hs_sync,
                            ic_fs_sync,
                            ic_ss_sync,
                            //rx_shift_reg signals
                            hs_mcode_en,
                            scl_lcnt_en,
                            rx_scl_lcnt_en,
                            scl_hcnt_en,
                            rx_scl_hcnt_en,
                            scl_s_hld_en,
                            scl_s_setup_en,
                            scl_p_setup_en,
                            //mstfsm signals
                            ic_enable_sync,
                            ic_master_sync,
                            ic_fs_spklen,
                            ic_bus_idle,   
                            min_hld_cmplt,
                            //outputs to tx/rx shift registers
                            scl_lcnt_cmplt,
                            scl_hcnt_cmplt,
                            scl_s_hld_cmplt,
                            scl_s_setup_cmplt,
                            scl_p_setup_cmplt
                            );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk; // processor clock
   input ic_rst_n; // asynchronous reset, active low
   input [`IC_HS_HCNT_RS-1:0] ic_hcnt;//Holds the high count of the active mode
   // ic_hcnt defines number of 
   // ic_clks to count for a valid high time
   // of SCL clock
   input [`IC_HS_LCNT_RS-1:0] ic_lcnt;//Holds the low count of the active mode
   // ic_lcnt defines number of
   // ic_clks to count for a valid low time
   // of SCL clock
   input [`IC_FS_LCNT_RS-1:0] ic_fs_lcnt;//Fast Speed mode low count register value
   input [`IC_FS_HCNT_RS-1:0] ic_fs_hcnt;//Fast Speed mode high count register value
   input                       ic_hs_sync;//IC is in High speed mode
   input                       ic_fs_sync;//IC is in Fast Speed mode
   input                       ic_ss_sync;//IC is in Standard speed mode
   input                       sda_int;//The filtered value detected on SDA bus line
   input                       scl_int;//The filtered value detected on SCL bus line
   input                       s_det;//Start has been detected on the bus
   input                       p_det;//Stop has been detected on the bus
   input                       ic_enable_sync;//IC module enable status (sync to ic_clk)
   input                       hs_mcode_en;//Enablle HS mode Mcode tx phase (Use FS timing in HS)
   input                       scl_lcnt_en;//Master TX low period counter enable
   input                       rx_scl_lcnt_en;//Master RX low period counter enable
   input                       scl_hcnt_en;//Master TX high period counter enable
   input                       rx_scl_hcnt_en;//Master RX high period counter enable
   input                       scl_s_hld_en;//Enable Start condition hold time counter
   input                       scl_s_setup_en;//Enable Start condition setup time counter
   input                       scl_p_setup_en;//Enable Stop condition hold time counter
   input                       ic_master_sync;    //logic 1: IC module is a Master 
   

   input [`IC_FS_SPKLEN_RS-1:0]  ic_fs_spklen;


   //OUTPUTS
   output                       scl_lcnt_cmplt;//low count period has elapsed
   output                       scl_hcnt_cmplt;//high count period has elapsed
   output                       scl_s_hld_cmplt;//start hold time period has elapsed
   output                       scl_s_setup_cmplt;//start setup period has elapsed
   output                       scl_p_setup_cmplt;//stop setup period has elapsed
   output                       min_hld_cmplt;//Scl has been pulled low and the
                                              // Minimum hold time to genearte 
                                              // start conditionhas elapsed
   output                       ic_bus_idle;//logic 1:The I2C bus is idle



   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------
   //registers
   reg [`IC_HS_HCNT_RS-1:0] bus_idle_cntr;
   reg                      ic_bus_idle;
   reg [`IC_HS_LCNT_RS-1:0] clkgen_lcnt;
   reg [`IC_HS_HCNT_RS-1:0] clkgen_hcnt;
   reg [`IC_HS_HCNT_RS-1:0] scl_low_cntr ;
   reg [`IC_HS_HCNT_RS-1:0] scl_high_cntr ;
   reg [`IC_HS_HCNT_RS-1:0] scl_s_hld_cntr ;
   reg [`IC_HS_HCNT_RS-1:0] scl_s_setup_cntr ;
   reg [`IC_HS_HCNT_RS-1:0] scl_p_setup_cntr ;
   reg [`IC_HS_HCNT_RS-1:0] min_hld_cntr;
   reg                      min_hld_cmplt_int;
   reg                      scl_lcnt_cmplt ;
   reg                      scl_hcnt_cmplt_int ;
   reg                      scl_int_d ;
   reg                      scl_hcnt_cmplt_d1_r;
   reg                      scl_s_hld_cmplt_int ;
   reg                      scl_s_setup_cmplt ;
   reg                      scl_p_setup_cmplt ;
   reg                      count_en;
   //wires
   wire                     comb_scl_lcnt_en;
   wire                     comb_scl_hcnt_en;
   wire                     scl_hcnt_cmplt ;
   wire [`IC_SS_LCNT_RS-1:0] idle_count;
   wire [`IC_HS_HCNT_RS-1:0] bus_idle_next;
   wire [`IC_HS_LCNT_RS-1:0] low_cnt_limit;
   wire [`IC_HS_HCNT_RS-1:0] high_cnt_limit;
   wire [`IC_HS_HCNT_RS-1:0] high_cnt_plus_latency;
   wire [`IC_HS_HCNT_RS-1:0] scl_low_next;
   wire [`IC_HS_HCNT_RS-1:0] scl_high_next;
   wire [`IC_HS_LCNT_RS-1:0] hs_low_limit;
   wire [`IC_HS_HCNT_RS-1:0] hld_lo_lmt;
   wire [`IC_HS_HCNT_RS-1:0] half_clkgen;
   wire [`IC_HS_HCNT_RS-1:0] hld_hs_lo_lmt;
   wire                      not_hs_timing;
   wire                      cap_load_100;
   wire                      cap_load_400;
   wire [`IC_HS_HCNT_RS-1:0] scl_s_hld_next;
   wire [`IC_HS_HCNT_RS-1:0] scl_s_setup_next;
   wire [`IC_HS_HCNT_RS-1:0] scl_p_setup_next;
   wire [`IC_HS_HCNT_RS-1:0] min_hld_next;
   wire                      scl_s_hld_cmplt;
   wire                      min_hld_cmplt;
   wire                      min_hld_cntr_en;


   
   // ----------------------------------------------------------
   // -- ic_bus_idle signal generation
   //
   // -- Determines if the I2C bus is idle
   // -- This procedure is used to calculate tBUF (I2C specs)
   // ----------------------------------------------------------

   // Idle count generation for Standard Speed
   //tBuf timing is taken from IC_SS_SCL_LCNT in standard mode.
   // IC_FS_SCL_HCNT from Fastspeed and High speed mode.  
   // Since High speed starts from Fastspeed, tBuf should consider IC_FS_SCL_HCNT in High Speed mode.
   assign idle_count = (ic_ss_sync ? (ic_lcnt + {{(`IC_HS_LCNT_RS-1){1'b0}},1'b1}) : (ic_fs_lcnt + {{(`IC_FS_LCNT_RS-1){1'b0}},1'b1})); 
//`ifdef IC_HIGHSPEED_MODE_EN
//        ic_hs_sync ?  (ic_hs_hcnt < `IC_HS_SCL_LOW_COUNT) ? `IC_HS_SCL_LOW_COUNT : ( ic_hs_hcnt + ic_hs_spklen + 6) :
//`endif 
//                      ic_fs_sync ?  (ic_fs_hcnt < `IC_FS_SCL_LOW_COUNT) ? `IC_FS_SCL_LOW_COUNT : ( ic_fs_hcnt + ic_fs_spklen + 6) :
//                                    (ic_ss_hcnt < `IC_SS_SCL_LOW_COUNT) ? `IC_SS_SCL_LOW_COUNT : ( ic_ss_hcnt + ic_fs_spklen + 6) ;



   always @(posedge ic_clk or negedge ic_rst_n) begin : BUS_IDLE_PROC
      if(ic_rst_n == 1'b0) begin
         ic_bus_idle <= 1'b0;
         count_en <= 1'b1;
      end else 
        begin
           ic_bus_idle <= ((ic_enable_sync == 1'b1) && (
                          (bus_idle_cntr >= idle_count)
                          )) ? 1'b1 : 1'b0;

           if(s_det == 1'b1) begin
             count_en <=  1'b0;
           end
           else if (p_det == 1'b1)
             count_en <= 1'b1;
        end
   end // block: BUS_FREE_PROC

  // ============================================================
  // Counter for determining when the bus is idle
  // 
  // If SCL goes to "0" at any time, this counter will be reset.
  // ============================================================
   assign bus_idle_next = bus_idle_cntr + {{(`IC_HS_HCNT_RS-1){1'b0}} , 1'b1};

  always @(posedge ic_clk or negedge ic_rst_n) begin : BUS_IDLE_CNTR_PROC
    if(ic_rst_n == 1'b0) begin
      bus_idle_cntr <= {`IC_HS_HCNT_RS{1'b0}};
    end else begin
         
      if((ic_enable_sync == 1'b0) || (s_det == 1'b1) 
            || sda_int==1'd0 || scl_int==1'd0
        ) begin
        bus_idle_cntr <= {`IC_HS_HCNT_RS{1'b0}};
      end else begin
        bus_idle_cntr <= ((bus_idle_cntr < idle_count) && (count_en == 1'b1)) 
                         ? bus_idle_next : bus_idle_cntr;
      end
    end // else: !if(ic_rst_n == 1'b0)
  end // block: BUS_IDLE_CNTR_PROC

   
   // ----------------------------------------------------------
   // -- clkgen_lcnt & clkgen_hcnt calculation
   //
   // -- Calculate the required low period for scl_clk output
   // -- depending on the mode of operation
   // ----------------------------------------------------------
   always @(*)
     begin: CLKGEN_CNT_PROC
        if ((ic_ss_sync == 1'b1) 
            || (ic_fs_sync == 1'b1)
            )
          begin
             clkgen_lcnt = ic_lcnt;
             clkgen_hcnt = ic_hcnt;
          end
        else//ic_hs_sync == 1
          begin
             clkgen_lcnt = (hs_mcode_en == 1'b1) ? ic_fs_lcnt : ic_lcnt;
             clkgen_hcnt = (hs_mcode_en == 1'b1) ? ic_fs_hcnt : ic_hcnt;
          end
     end
   // ----------------------------------------------------------
   // -- scl low period calculation
   //
   // -- Calculate the required low period for scl_clk output
   // -- This procedure is used to calculate tLOW (I2C specs)
   // ----------------------------------------------------------

   assign low_cnt_limit = clkgen_lcnt - 1;
   assign high_cnt_limit = clkgen_hcnt - 1;
   assign high_cnt_plus_latency = high_cnt_limit + {{(`IC_HS_HCNT_RS-`IC_FS_SPKLEN_RS){1'b0}},ic_fs_spklen} + {{(`IC_HS_HCNT_RS-3){1'b0}},3'h7}; 
   assign scl_low_next = scl_low_cntr + 1;   
   assign comb_scl_lcnt_en = scl_lcnt_en 
                             | rx_scl_lcnt_en
                            ;

   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_LOW_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         scl_lcnt_cmplt <= 1'b0;
         scl_low_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         if(comb_scl_lcnt_en == 1'b0)
           begin
              scl_lcnt_cmplt<= 1'b0;
              scl_low_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
         else if (scl_low_cntr < low_cnt_limit)
           begin
              scl_low_cntr <= scl_low_next;
              
           end
            else if (scl_low_cntr >= low_cnt_limit)
              begin
                 scl_lcnt_cmplt <= 1'b1;
              end
      end
   end // block: SCL_LOW_COUNT_PROC

 
   // ----------------------------------------------------------
   // -- scl high period calculation
   //
   // -- Calculate the required high period for scl_clk output
   // -- This procedure is used to calculate tHIGH (I2C specs)
   // ----------------------------------------------------------
   assign scl_high_next = scl_high_cntr + 1;
   assign comb_scl_hcnt_en = scl_hcnt_en 
                             | rx_scl_hcnt_en
                         ;

   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_HIGH_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         scl_hcnt_cmplt_int <= 1'b0;
         scl_high_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         if(comb_scl_hcnt_en == 1'b0)
           begin
              scl_hcnt_cmplt_int<= 1'b0;
              scl_high_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
         else if (scl_high_cntr < high_cnt_limit)
           begin
              scl_high_cntr <= scl_high_next;
              
           end
            else if (scl_high_cntr >= high_cnt_limit)
              begin
                 scl_hcnt_cmplt_int <= 1'b1;
              end
      end
   end // block: SCL_HIGH_COUNT_PROC

   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_HCNT_CMPLT_D1_PROC
     if(ic_rst_n == 1'b0) begin
       scl_hcnt_cmplt_d1_r <= 1'b0;
     end else begin
        scl_hcnt_cmplt_d1_r <= scl_hcnt_cmplt;
     end
   end



   // ------------------------------------------------------------------
   // -- 1- clock delayed version of scl_int signal
   //
   // -- Delayed scl_int signal is used to de-assert the scl high counter
   // -- when the other master pulls the SCL line before completes its
   // -- HIGH period during the ACK Phase. (sec 8.1 Synchronization of I2C Spec)
   // ------------------------------------------------------------------
    always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_INT_DELAYED_PROC
      if(ic_rst_n == 1'b0) begin
        scl_int_d <= 1'b0;
      end else begin
        scl_int_d <= scl_int;
      end
   end // block: SCL_INT_DELAYED_PROC

   // ------------------------------------------------------------------------
   // -- SCL High count completion signal
   // 
   // -- Generate the high count completion signal either pre-maturely when
   // -- other master pulls the SCL line before completes its high period or
   // -- once thw high count period counter expires.
   // --------------------------------------------------------------------------
   assign scl_hcnt_cmplt = (scl_hcnt_cmplt_int 
                            || (~scl_int && scl_int_d && comb_scl_hcnt_en) || (scl_lcnt_cmplt && scl_hcnt_cmplt_d1_r)
                            );

   
   // ----------------------------------------------------------
   // -- scl Start hold time calculation
   //
   // -- Calculate the required shld period for scl_clk output
   // -- This procedure is used to calculate tHD;STA (I2C specs)
   // ----------------------------------------------------------
   assign scl_s_hld_next = scl_s_hld_cntr + 1;
   
   assign hs_low_limit = ((clkgen_lcnt>>1) - 1);
   assign not_hs_timing = ((ic_ss_sync == 1'b1)||(ic_fs_sync == 1'b1) || (hs_mcode_en == 1'b1));
   assign cap_load_100 = (hs_mcode_en == 1'b0) && (ic_hs_sync== 1'b1) && (`IC_CAP_LOADING == 100);
   assign cap_load_400 = (hs_mcode_en == 1'b0) && (ic_hs_sync== 1'b1) && (`IC_CAP_LOADING == 400);
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_S_HLD_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         scl_s_hld_cmplt_int <= 1'b0;
         scl_s_hld_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         if(scl_s_hld_en == 1'b0)
           begin
              scl_s_hld_cmplt_int <= 1'b0;
              scl_s_hld_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
         else if (( 
                   not_hs_timing &&
                 (scl_s_hld_cntr < high_cnt_plus_latency))
                  ||
                  ( cap_load_100 && (scl_s_hld_cntr < low_cnt_limit))
                  ||
                  ( cap_load_400 && (scl_s_hld_cntr < hs_low_limit ))
              )
                  
           begin
              scl_s_hld_cntr <= scl_s_hld_next;
              
           end
         else 
           begin
              scl_s_hld_cmplt_int <= 1'b1;       
           end
      end
   end // block: SCL_S_HLD_COUNT_PROC
   
   // ------------------------------------------------------------------------
   // -- SCL Start/Restart Hold completion signal
   // 
   // -- Generate the Start/Restart Hold completion signal either pre-maturely when
   // -- other master pulls the SCL line before completes its Start/Restart Hold period or
   // -- once the Start/Restart count period counter expires.
   // --------------------------------------------------------------------------
   assign scl_s_hld_cmplt = (scl_s_hld_cmplt_int 
                             || (~scl_int && scl_int_d && scl_s_hld_en)
                             );


   // ----------------------------------------------------------
   // -- Minumum hold time calculation
   //
   // -- Calculate the required shld period for scl_clk output
   // -- This procedure is used to calculate tHD;STA (I2C specs)
   // ----------------------------------------------------------
   //assign hld_lo_lmt  = (clkgen_lcnt > 6 ) ? (clkgen_lcnt - 6) : 1;
   assign hld_lo_lmt  = clkgen_lcnt;
   //assign hld_hi_lmt  = (clkgen_hcnt > 6 ) ? (clkgen_hcnt - 6) : 1;
   //assign hld_hi_lmt  = clkgen_hcnt;
   assign half_clkgen = (clkgen_lcnt>>1);
   //assign hld_hs_lo_lmt = (half_clkgen > 6 ) ? (half_clkgen - 6) : 1;
   assign hld_hs_lo_lmt = half_clkgen;
   assign min_hld_next = min_hld_cntr + 1;
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : MIN_HLD_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         min_hld_cmplt_int <= 1'b0;
         min_hld_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         //if ((scl_int == 1'b1) || (ic_enable_sync == 1'b0) || (ic_master_sync == 1'b0))
         if ((sda_int == 1'b1) || (ic_enable_sync == 1'b0) || (ic_master_sync == 1'b0) || (p_det ==1'b1))
           begin
              min_hld_cmplt_int <= 1'b0;
              min_hld_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
         else 
              if (( 
                  not_hs_timing && 
                  (min_hld_cntr < high_cnt_plus_latency)) 
                  ||
                  ( cap_load_100 && (min_hld_cntr < hld_lo_lmt))
                  ||
                  ( cap_load_400 && (min_hld_cntr < hld_hs_lo_lmt ))
              )
                  
                begin
                   min_hld_cntr <= min_hld_next;
                end
              else 
                begin
                   min_hld_cmplt_int <= 1'b1;       
                end // else: !if(( not_hs_timing && (min_hld_cntr < hld_hi_lmt))...
      end
   end // block: MIN_HLD_COUNT_PROC

   // ------------------------------------------------------------------------
   // -- SCL Start/Restart Minimum Hold completion signal
   // 
   // -- Generate the Start/Restart Minimum Hold completion signal either pre-maturely when
   // -- other master pulls the SCL line before completes its Start/Restart Hold minimum period or
   // -- once the Start/Restart Minimum count period counter expires.
   // --------------------------------------------------------------------------
   assign min_hld_cntr_en = (~(sda_int || (~ic_enable_sync) || (~ic_master_sync) || p_det));
   assign min_hld_cmplt = (min_hld_cmplt_int || (~scl_int && scl_int_d && min_hld_cntr_en));

   
   // ----------------------------------------------------------
   // -- scl Start setup time calculation
   //
   // -- Calculate the required shld period for scl_clk output
   // -- This procedure is used to calculate tSU;STA (I2C specs)
   // ----------------------------------------------------------
   assign scl_s_setup_next = scl_s_setup_cntr + 1;
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_S_SETUP_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         scl_s_setup_cmplt <= 1'b0;
         scl_s_setup_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         if(scl_s_setup_en == 1'b0)
           begin
              scl_s_setup_cmplt<= 1'b0;
              scl_s_setup_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
         
         else if ((((ic_ss_sync == 1'b1) && 
                   (scl_s_setup_cntr < low_cnt_limit)) 
                  ||
                  (((ic_fs_sync == 1'b1) 
                  || (hs_mcode_en == 1'b1)
                  ) && (scl_s_setup_cntr < high_cnt_plus_latency)) 
                  ||
                  (cap_load_100 && (scl_s_setup_cntr < low_cnt_limit)) 
                  ||
                  (cap_load_400 && (scl_s_setup_cntr < hs_low_limit))
              ) 
              && (sda_int == 1'b1)
              )
           
           begin
              scl_s_setup_cntr <= scl_s_setup_next;
              
           end
         else
           begin
              scl_s_setup_cmplt <= 1'b1;
           end

      end
   end // block: SCL_S_SETUP_COUNT_PROC

   // ----------------------------------------------------------
   // -- scl Stop setup time calculation
   //
   // -- Calculate the required shld period for scl_clk output
   // -- This procedure is used to calculate tSU;STO (I2C specs)
   // ----------------------------------------------------------
   assign scl_p_setup_next = scl_p_setup_cntr + 1;
   
   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression present in the design.
   //SJ:  This Self Determined Expression is as per the design requirement. 
   //     There will not be any functional issue.
   always @(posedge ic_clk or negedge ic_rst_n) begin : SCL_P_SETUP_COUNT_PROC
      if(ic_rst_n == 1'b0) begin
         scl_p_setup_cmplt <= 1'b0;
         scl_p_setup_cntr <= {`IC_HS_HCNT_RS{1'b0}};
         
      end else begin
         if(scl_p_setup_en == 1'b0)
           begin
              scl_p_setup_cmplt<= 1'b0;
              scl_p_setup_cntr <= {`IC_HS_HCNT_RS{1'b0}};
           end
          else if ((
                  not_hs_timing &&
                  (scl_p_setup_cntr < high_cnt_plus_latency))
                  ||
                  ( cap_load_100 && (scl_p_setup_cntr < low_cnt_limit))
                  ||
                  ( cap_load_400 && (scl_p_setup_cntr < hs_low_limit ))
              )
           begin
              scl_p_setup_cntr <= scl_p_setup_next;
              
           end
         else
           begin
              scl_p_setup_cmplt <= 1'b1;
           end
      end
   end // block: SCL_P_SETUP_COUNT_PROC
   //spyglass enable_block SelfDeterminedExpr-ML

   
endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #14 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_fifo.v#14 $ 
//
//
// File    : DW_apb_i2c_fifo.v
//
//
// Abstract: FIFO Controller for the DW_apb_i2c macrocell
//
//        1: Instantiates the DW_apb_i2c_DWbb_fifoctl_s1_df macrocell twice.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_fifo
   (
    pclk,
    presetn,
    fifo_rst_n,
    tx_fifo_rst_n,
    set_tx_empty_en_flg_edg,
    ic_tx_tl,
    ic_rx_tl,
    tx_push,
    rx_pop,
    tx_pop_flg,
    rx_push_flg,

    tx_pop_sync,
    rx_push_sync,

    tx_empty,
    rx_full, 
    tx_full, 
    rx_empty,
    
    tx_almost_empty,
    gen_tx_almost_empty,
    tx_overflow,
    rx_almost_full,
    rx_overflow,
    rx_underflow,
    tx_wr_addr,
    tx_rd_addr,
    tx_we_n,
    rx_wr_addr,
    rx_rd_addr,
    rx_we_n
    );
   
   input                pclk;           // APB clock
   input                presetn;        // APB async reset
   input                fifo_rst_n;     // sync fifo reset
   input                tx_fifo_rst_n;     // sync fifo reset
   input                set_tx_empty_en_flg_edg;     // sync fifo reset
   input [`IC_TX_TL_RS-1:0] ic_tx_tl;        // tx fifo empty threshold
   input  [`RX_ABW-1:0] ic_rx_tl;           // rx fifo full threshold
   input                    tx_push;        // tx fifo push
   input                    rx_pop;         // rx fifo pop
   input                    tx_pop_flg;//if pclk is async. to ic_clk, this signal toggles on tx_pop signal
   input                    rx_push_flg;//if pclk is async. to ic_clk, this signal toggles on rx_push signal
   

   output                   tx_empty;       // tx fifo empty status
   output                   rx_full;        // rx fifo full status
   output                   tx_full;        // tx fifo full status   
   output                   rx_empty;       // rx fifo empty status   

   output                   tx_almost_empty;// tx fifo almost empty status
   output                   tx_overflow;    // tx fifo overflow

   output                   rx_almost_full; // rx fifo almost full status
   output                   rx_overflow;    // rx fifo overflow
   output                   rx_underflow;   // rx fifo underflow
   output   [`TX_ABW-1:0] tx_wr_addr;     // tx fifo write pointer
   output   [`TX_ABW-1:0] tx_rd_addr;     // tx fifo read pointer
   output                   tx_we_n;        // tx fifo write enable
   output   [`RX_ABW-1:0] rx_wr_addr;     // rx fifo write pointer
   output   [`RX_ABW-1:0] rx_rd_addr;     // rx fifo read pointer
   output                   rx_we_n;        // rx fifo write enable
   output                   tx_pop_sync;    // pclk sync tx fifo pop
   output                   rx_push_sync;   // pclk sync rx fifo push
   output                   gen_tx_almost_empty; 
   // ------------------------------------------------------
   // -- local registers and wires
   // ------------------------------------------------------
   reg                      tx_push_dly;
   reg                      tx_pop_sync_dly;
   reg                      rx_push_sync_dly;
   reg                      rx_pop_dly;
   
   reg                      tx_pop_flg_sync_q;
   reg                      rx_push_flg_sync_q;

   wire                     rx_empty;       // rx fifo empty status   
   wire                     tx_pop_flg_sync;
   wire                     rx_push_flg_sync;
   
   wire                     tx_pop_flg_edg;
   wire                     rx_push_flg_edg;
   //

   wire                     rx_full;        // rx fifo full status
   wire                     tx_full;        // tx fifo full status   
   
   wire                     tx_pop_sync;    // pclk sync tx fifo pop
   wire                     rx_push_sync;   // pclk sync rx fifo push
   wire                     tx_error_ir;
   wire                     rx_error_ir;
   wire                     i_rx_almost_full;
   wire                     tx_pop_n;
   wire                     tx_push_n;
   wire                     rx_pop_n;
   wire                     rx_push_n;
   wire [`TX_ABW-1:0]       tx_empty_level;
   wire [`RX_ABW-1:0]       rx_thresh;
   wire                     switch_almost_full;
   wire                     rx_thresh_eq_rx_buffer_depth;
   wire                     max_ic_rx_tl;
   reg  [`IC_TX_TL_RS:0]  tx_fifo_cmd_cntr;
   wire [`IC_TX_TL_RS:0]  tx_fifo_cmd_cntr_c;
   wire                     gen_tx_almost_empty;
   wire [`RX_ABW-1:0]       ic_rx_tl_int;
  
   wire nxten_tx_unconn, nxtf_tx_unconn, nxte_tx_unconn;
   wire nxten_rx_unconn, nxtf_rx_unconn, nxte_rx_unconn;
   wire                     tx_half_full_unconn;
   wire                     rx_half_full_unconn;
   wire                     tx_almost_full_unconn;
   wire                     rx_almost_empty_unconn;
   wire [`TX_ABW-1:0] wrdc_tx_unconn;
   wire [`RX_ABW-1:0] wrdc_rx_unconn;
   
   // ----------------------------------------------------------
   // -- Synchronization registers for input from ic_clk domain
   // ----------------------------------------------------------

   wire                     ic2pl_tx_pop_flg;
   wire                     sic2pl_tx_pop_flg_sync;
   assign ic2pl_tx_pop_flg = tx_pop_flg;
   assign tx_pop_flg_sync = sic2pl_tx_pop_flg_sync;
      DW_apb_i2c_bcm21
       #(
       .F_SYNC_TYPE (`IC_SYNC_DEPTH),
       .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_tx_pop_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_tx_pop_flg)
        ,.data_d              (sic2pl_tx_pop_flg_sync)
      );


   wire                     ic2pl_rx_push_flg;
   wire                     sic2pl_rx_push_flg_sync;
   assign ic2pl_rx_push_flg = rx_push_flg;
   assign rx_push_flg_sync = sic2pl_rx_push_flg_sync;
      DW_apb_i2c_bcm21
       #(
       .F_SYNC_TYPE (`IC_SYNC_DEPTH),
       .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_rx_push_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_rx_push_flg)
        ,.data_d              (sic2pl_rx_push_flg_sync) 
      );

   // ----------------------------------------------------------
   // -- Edge detection circuitry for input from ic_clk domain
   // ----------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : EDGE_DET_PROC
      if(presetn == 1'b0) begin
         tx_pop_flg_sync_q <= 1'b0; 
         rx_push_flg_sync_q <= 1'b0; 
      end else begin
         tx_pop_flg_sync_q <= tx_pop_flg_sync; 
         rx_push_flg_sync_q <= rx_push_flg_sync; 
      end
   end

   assign tx_pop_flg_edg       = ((~tx_pop_flg_sync_q   & tx_pop_flg_sync ) |(tx_pop_flg_sync_q  & (~tx_pop_flg_sync )));
   assign rx_push_flg_edg      = ((~rx_push_flg_sync_q  & rx_push_flg_sync) |(rx_push_flg_sync_q & (~rx_push_flg_sync)));

   
   // ------------------------------------------------------
   // -- overflow and underflow flags
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : ERROR_DLY_PROC
      if(presetn == 1'b0) begin
         tx_push_dly      <= 1'b0;
         tx_pop_sync_dly  <= 1'b0;
         rx_pop_dly       <= 1'b0;
         rx_push_sync_dly <= 1'b0;
         
      end else begin
         tx_push_dly      <= tx_push;
         tx_pop_sync_dly  <= tx_pop_flg_edg;
         rx_pop_dly       <= rx_pop;
         rx_push_sync_dly <= rx_push_flg_edg;
      end
   end // block: ERROR_DLY_PROC
   
   assign tx_overflow  = tx_error_ir & (tx_push_dly == 1'b1 & tx_pop_sync_dly == 1'b0);
   assign rx_overflow  = rx_error_ir & (rx_push_sync_dly == 1'b1 & rx_pop_dly == 1'b0);
   assign rx_underflow = rx_error_ir & (rx_pop_dly == 1'b1 & rx_empty == 1'b1);

   // -------------------------------------------------------
   // -- Generation of tx_push_sync and rx_pop_sync signals.
   //
   //  The tx_pop and rx_push signal are driven from the
   //  ssi_clk domain. They are synchronized over to the
   //  pclk domain here if pclk and ic_clk are asynchronous
   //  Both signal are also rising edge detected.
   // -------------------------------------------------------
   assign tx_pop_sync  = tx_pop_flg_edg;
   assign rx_push_sync = rx_push_flg_edg;

   // ------------------------------------------------------
   // -- active low input the DW_ffioctl_s1_df
   // ------------------------------------------------------
   assign tx_pop_n  = !tx_pop_sync;
   assign tx_push_n = !tx_push;
   assign rx_pop_n  = !rx_pop;
   assign rx_push_n = !rx_push_sync;

   assign tx_empty_level = ic_tx_tl[`TX_ABW-1:0];

   assign max_ic_rx_tl = (&ic_rx_tl[`RX_ABW-1:0]);
   assign ic_rx_tl_int = ic_rx_tl[`RX_ABW-1:0] + {{(`RX_ABW-1){1'b0}},1'b1};
   assign rx_thresh_eq_rx_buffer_depth = (rx_thresh == `IC_RX_BUFFER_DEPTH);
   assign rx_thresh          = (max_ic_rx_tl == 1'b1)                 ? ic_rx_tl[`RX_ABW-1:0]: ic_rx_tl_int[`RX_ABW-1:0];
   assign rx_almost_full     = (max_ic_rx_tl == 1'b1)                 ? rx_full : switch_almost_full;
   assign switch_almost_full = (rx_thresh_eq_rx_buffer_depth == 1'b1) ? rx_full : i_rx_almost_full;

   // Counter which increments on number of commands pushed in to fifo 
   // and decrements on the number of commands executed
   always @(posedge pclk or negedge presetn) begin : FIFO_CMD_CNTR_PROC
     if(presetn == 1'b0) begin
       tx_fifo_cmd_cntr <= {(`IC_TX_TL_RS+1){1'b0}};
     end
     else begin
       if (!tx_fifo_rst_n)
         tx_fifo_cmd_cntr <= {(`IC_TX_TL_RS+1){1'b0}};
       else if(set_tx_empty_en_flg_edg && tx_push)
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr_c;
       else if(set_tx_empty_en_flg_edg && (tx_fifo_cmd_cntr !=0))
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr - {{(`IC_TX_TL_RS){1'b0}},1'b1};
       else if(tx_push && (tx_fifo_cmd_cntr < `IC_TX_BUFFER_DEPTH))
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr + {{(`IC_TX_TL_RS){1'b0}},1'b1};
     end
   end 

   assign tx_fifo_cmd_cntr_c = tx_fifo_cmd_cntr;
   // Generate Tx FIFO almost empty based on the command executed
   // in the ic_clk domain
   assign gen_tx_almost_empty = (tx_fifo_cmd_cntr <= {1'b0,ic_tx_tl});

   // ------------------------------------------------------
   // -- Instance of tx fifo controller
   // ------------------------------------------------------
   DW_apb_i2c_bcm06
    #(`IC_TX_BUFFER_DEPTH, 2, `TX_ABW) U_tx_fifo
         (
          .clk           (pclk)
          ,.init_n       (tx_fifo_rst_n)
          ,.rst_n        (presetn)
          ,.push_req_n   (tx_push_n)
          ,.pop_req_n    (tx_pop_n)
          ,.ae_level     (tx_empty_level)
          ,.af_thresh    ({`TX_ABW{1'b1}})
          ,.we_n         (tx_we_n)
          ,.wr_addr      (tx_wr_addr)
          ,.rd_addr      (tx_rd_addr)
          ,.empty        (tx_empty)
          ,.almost_empty (tx_almost_empty)
          ,.full         (tx_full)
          //spyglass disable_block W528
          //SMD : A signal or variable is set but never read
          //SJ  : The BCM07 is a generic FIFO design, which has many features.
          //      But this use case does not use all features. Hence these signals
          //      are unused. But there is no functional issue, hence this can be 
          //      waived. 
          ,.almost_full  (tx_almost_full_unconn)
          ,.half_full    (tx_half_full_unconn)
          //spyglass enable_block W528
          ,.error        (tx_error_ir)
          //spyglass disable_block W528
          //SMD : A signal or variable is set but never read
          //SJ  : The BCM07 is a generic FIFO design, which has many features.
          //      But this use case does not use all features. Hence these signals
          //      are unused. But there is no functional issue, hence this can be 
          //      waived. 
          ,.wrd_count    (wrdc_tx_unconn)
          ,.nxt_empty_n  (nxten_tx_unconn)
          ,.nxt_full     (nxtf_tx_unconn)
          ,.nxt_error    (nxte_tx_unconn) 
          //spyglass enable_block W528
          );


   // ------------------------------------------------------
   // -- Instance of rx fifo controller
   // ------------------------------------------------------
   DW_apb_i2c_bcm06
    #(`IC_RX_BUFFER_DEPTH, 2, `RX_ABW) U_rx_fifo
         (
          .clk           (pclk)
          ,.init_n       (fifo_rst_n)
          ,.rst_n        (presetn)
          ,.push_req_n   (rx_push_n)
          ,.pop_req_n    (rx_pop_n)
          ,.ae_level     ({`RX_ABW{1'b0}})
          ,.af_thresh    (rx_thresh)
          ,.we_n         (rx_we_n)
          ,.wr_addr      (rx_wr_addr)
          ,.rd_addr      (rx_rd_addr)
          ,.empty        (rx_empty)
          //spyglass disable_block W528
          //SMD : A signal or variable is set but never read
          //SJ  : The BCM07 is a generic FIFO design, which has many features.
          //      But this use case does not use all features. Hence these signals
          //      are unused. But there is no functional issue, hence this can be 
          //      waived. 
          ,.almost_empty (rx_almost_empty_unconn)
          //spyglass enable_block W528
          ,.full         (rx_full)
          ,.almost_full  (i_rx_almost_full)
          //spyglass disable_block W528
          //SMD : A signal or variable is set but never read
          //SJ  : The BCM07 is a generic FIFO design, which has many features.
          //      But this use case does not use all features. Hence these signals
          //      are unused. But there is no functional issue, hence this can be 
          //      waived. 
          ,.half_full    (rx_half_full_unconn)
          //spyglass enable_block W528
          ,.error        (rx_error_ir)
          //spyglass disable_block W528
          //SMD : A signal or variable is set but never read
          //SJ  : The BCM07 is a generic FIFO design, which has many features.
          //      But this use case does not use all features. Hence these signals
          //      are unused. But there is no functional issue, hence this can be 
          //      waived. 
          ,.wrd_count    (wrdc_rx_unconn)
          ,.nxt_empty_n  (nxten_rx_unconn)
          ,.nxt_full     (nxtf_rx_unconn)
          ,.nxt_error    (nxte_rx_unconn) 
          //spyglass enable_block W528
          );

endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #7 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_biu.v#7 $ 
//
// File    : DW_apb_i2c_biu.v
// Author  : Joe Mc Cann
//
//
// Created : Thu Jun 13 13:32:20 BST 2002
//
// Abstract: Apb bus interface module.
//           This module is intended for use with APB slave
//           macrocells.  The module generates output signals
//           from the APB bus interface that are intended for use in
//           the register block of the macrocell.
//
//        1: Generates the write enable (wr_en) and read
//           enable (rd_en) for register accesses to the macrocell.
//
//        2: Decodes the address bus (paddr) to generate the active
//           byte lane signal (byte_en).
//
//        3: Strips the APB address bus (paddr) to generate the
//           register offset address output (reg_addr).
//
//        4: Registers APB read data (prdata) onto the APB data bus.
//           The read data is routed to the correct byte lane in this
//           module.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_biu
(
 // APB bus interface
 pclk,
                      presetn,
                      psel,
                      penable,
                      pwrite, 
                      paddr,
                      pwdata,
                      pready,
                      pslverr,
                      prdata,
                      // regfile interface
                      wr_en,
                      rd_en,
                      slave_rdy,
                      slave_err,
                      penable_int,
                      byte_en,
                      reg_addr,
                      ipwdata,
                      iprdata
                      );

   // -------------------------------------
   // -- APB bus signals
   // -------------------------------------
   input                            pclk;      // APB clock
   input                            presetn;   // APB reset
   input                            psel;      // APB slave select
   input     [`IC_ADDR_SLICE_LHS:0] paddr;     // APB address
   input                            pwrite;    // APB write/read
   input                            penable;   // APB enable
   input      [`APB_DATA_WIDTH-1:0] pwdata;    // APB write data bus
   input                            slave_rdy; // slave ready signal
   input                            slave_err; // slave error signal
   

   // -------------------------------------
   // -- Register block interface signals
   // -------------------------------------
   input  [`MAX_APB_DATA_WIDTH-1:0] iprdata;   // Internal read data bus


   output     [`APB_DATA_WIDTH-1:0] prdata;    // APB read data bus
   output                           pready;    //Slave ready: A low  on this APB3 signal stalls an APB transaction until signal goes high.
   output                           pslverr;   //Slave error: A high on this APB3 signal indicates an error condition on the transfer.

   output                           wr_en;     // Write enable signal
   output                           rd_en;     // Read enable signal
   output                           penable_int; // Internal PENABLE Signal
   output                     [3:0] byte_en;   // Active byte lane signal
   output  [`IC_ADDR_SLICE_LHS-2:0] reg_addr;  // Register address offset
   output [`MAX_APB_DATA_WIDTH-1:0] ipwdata;   // Internal write data bus

   // -------------------------------------
   // -- Local registers & wires
   // -------------------------------------
   reg        [`APB_DATA_WIDTH-1:0] prdata;    // Registered prdata output
   reg    [`MAX_APB_DATA_WIDTH-1:0] ipwdata;   // Internal pwdata bus
   wire                       [3:0] byte_en;   // Registered byte_en output



   
   // --------------------------------------------
   // -- write/read enable -- penable --
   //
   // -- Generate write/read enable signals from
   // -- psel, penable and pwrite inputs
   // --------------------------------------------
   assign wr_en = (psel) & ( pwrite);
   assign rd_en = (psel) & (!pwrite);
   assign penable_int = penable;
   assign pready      = slave_rdy;
   assign pslverr     = slave_err;
   
   // --------------------------------------------
   // -- Register address
   //
   // -- Strips register offset address from the
   // -- APB address bus
   // --------------------------------------------
   assign reg_addr = paddr[`IC_ADDR_SLICE_LHS:2];

   
   //spyglass disable_block W415a
   //SMD: Signal may be multiply assigned (beside initialization) in the same scope
   //SJ : The signal ipwdata is updated with the default values (0's) and then only required
   //     bits are  updated. There is no functional issue. Hence this can be waived.
   // --------------------------------------------
   // -- APB write data
   //
   // -- ipwdata is zero padded before being
   // -- passed through this block
   // --------------------------------------------
   always @(pwdata) begin : IPWDATA_PROC
      ipwdata = { `MAX_APB_DATA_WIDTH{1'b0} };
      ipwdata[`APB_DATA_WIDTH-1:0] = pwdata[`APB_DATA_WIDTH-1:0];
   end
   //spyglass enable_block W415a
   
   // --------------------------------------------
   // -- Set active byte lane
   //
   // -- This bit vector is used to set the active
   // -- byte lanes for write/read accesses to the
   // -- registers
   // --------------------------------------------

    assign  byte_en = 4'b1111;


   // --------------------------------------------
   // -- APB read data.
   //
   // -- Register data enters this block on a
   // -- 32-bit bus (iprdata). The upper unused
   // -- bit(s) have been zero padded before entering
   // -- this block.  The process below strips the
   // -- active byte lane(s) from the 32-bit bus
   // -- and registers the data out to the APB
   // -- read data bus (prdata).
   // --------------------------------------------
   always @(posedge pclk or negedge presetn) begin : PRDATA_PROC
      if(presetn == 1'b0) begin
         prdata <= { `APB_DATA_WIDTH{1'b0} };
      end else begin
         if(rd_en && (!penable) ) begin
                  prdata <= iprdata;
         end
      end
   end
   
endmodule // DW_apb_i2c_biu
  

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm07.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm07.v#3 $
// Author      : Vikas Gokhale       5/17/04
// Description : DW_apb_i2c_bcm07.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: 40819a07
//
////////////////////////////////////////////////////////////////////////////////

module DW_apb_i2c_bcm07 (
        clk_push,
        rst_push_n,
        init_push_n,
        push_req_n,
        push_empty,
        push_ae,
        push_hf,
        push_af,
        push_full,
        push_error,
        push_word_count,
        we_n,
        wr_addr,

        clk_pop,
        rst_pop_n,
        init_pop_n,
        pop_req_n,
        pop_empty,
        pop_ae,
        pop_hf,
        pop_af,
        pop_full,
        pop_error,
        pop_word_count,
        rd_addr
        );

parameter DEPTH         =  8;   // RANGE 4 to 16777216
parameter ADDR_WIDTH    =  3;   // RANGE 2 to 24
parameter COUNT_WIDTH   =  4;   // RANGE 3 to 25
parameter PUSH_AE_LVL   =  2;   // RANGE 1 to DEPTH-1
parameter PUSH_AF_LVL   =  2;   // RANGE 1 to DEPTH-1
parameter POP_AE_LVL    =  2;   // RANGE 1 to DEPTH-1
parameter POP_AF_LVL    =  2;   // RANGE 1 to DEPTH-1
parameter ERR_MODE      =  0;   // RANGE 0 to 1
parameter PUSH_SYNC     =  2;   // RANGE 1 to 4
parameter POP_SYNC      =  2;   // RANGE 1 to 4
parameter EARLY_PUSH_STAT =  0;   // RANGE 0 to 15
parameter EARLY_POP_STAT  =  0;   // RANGE 0 to 15
parameter MEM_MODE      =  0;   // RANGE 0 to 3
parameter VERIF_EN      =  1;   // RANGE 0 to 5

localparam PIPE_GRAY_POP = (MEM_MODE==1 || MEM_MODE==3) ? 1 : 0;
localparam PIPE_GRAY_PUSH = (MEM_MODE==2 || MEM_MODE==3) ? 1 : 0;

input                           clk_push;       // Push domain clk input
input                           rst_push_n;     // Push domain active low async reset
input                           init_push_n;    // Push domain active low sync reset
input                           push_req_n;     // Push domain active high push reqest
output                          push_empty;     // Push domain Empty status flag
output                          push_ae;        // Push domain Almost Empty status flag
output                          push_hf;        // Push domain Half full status flag
output                          push_af;        // Push domain Almost full status flag
output                          push_full;      // Push domain Full status flag
output                          push_error;     // Push domain Error status flag
output [COUNT_WIDTH-1 : 0]      push_word_count;// Push domain word count
output                          we_n;           // Push domain active low RAM write enable
output [ADDR_WIDTH-1 : 0]       wr_addr;        // Push domain RAM write address

input                           clk_pop;        // Pop domain clk input
input                           rst_pop_n;      // Pop domain active low async reset
input                           init_pop_n;     // Pop domain active low sync reset
input                           pop_req_n;      // Pop domain active high pop request
output                          pop_empty;      // Pop domain Empty status flag
output                          pop_ae;         // Pop domain Almost Empty status flag
output                          pop_hf;         // Pop domain Half full status flag
output                          pop_af;         // Pop domain Almost full status flag
output                          pop_full;       // Pop domain Full status flag
output                          pop_error;      // Pop domain Error status flag
output [COUNT_WIDTH-1 : 0]      pop_word_count; // Pop domain word count
output [ADDR_WIDTH-1 : 0]       rd_addr;        // Pop domain RAM read address

wire                            reg_push_empty;         // Registered Push domain Empty status flag
wire                            reg_push_full;          // Registered Push domain Full status flag
wire                            reg_push_error;         // Registered Push domain Error status flag
wire   [COUNT_WIDTH-1 : 0]      reg_push_word_count;    // Registered Push domain word count
wire                            early_push_empty_n;     // Unregistered Push domain Empty status flag (active-low)
wire                            early_push_full;        // Unregistered Push domain Full status flag
wire                            early_push_error;       // Unregistered Push domain Error status flag
wire   [COUNT_WIDTH-1 : 0]      early_push_word_count;  // Unregistered Push domain word count

wire                            reg_pop_empty;          // Registered Pop domain Empty status flag
wire                            reg_pop_full;           // Registered Pop domain Full status flag
wire                            reg_pop_error;          // Registered Pop domain Error status flag
wire   [COUNT_WIDTH-1 : 0]      reg_pop_word_count;     // Registered Pop domain word count
wire                            early_pop_empty_n;      // Unregistered Pop domain Empty status flag (active-low)
wire                            early_pop_full;         // Unregistered Pop domain Full status flag
wire                            early_pop_error;        // Unregistered Pop domain Error status flag
wire   [COUNT_WIDTH-1 : 0]      early_pop_word_count;   // Unregistered Pop domain word count

wire [COUNT_WIDTH-1 : 0]        push_addr_g;

wire [COUNT_WIDTH-1 : 0]        pop_addr_g;


`ifndef SYNTHESIS
`ifndef DWC_DISABLE_CDC_METHOD_REPORTING
  initial begin
    if ((POP_SYNC > 0)&&(POP_SYNC < 8))
       $display("Information: *** Instance %m module is using the <Dual Clock FIFO Controller (11)> Clock Domain Crossing Method ***");
  end

`endif
`endif

  assign we_n = push_full | push_req_n;

DW_apb_i2c_bcm05
 #(DEPTH, ADDR_WIDTH, COUNT_WIDTH, PUSH_AE_LVL, PUSH_AF_LVL, ERR_MODE, PUSH_SYNC, 1, PIPE_GRAY_PUSH, VERIF_EN ) U_PUSH_FIFOFCTL(
  .clk(clk_push),
  .rst_n(rst_push_n),
  .init_n(init_push_n),
  .inc_req_n(push_req_n),
  .other_addr_g(pop_addr_g),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .word_count(reg_push_word_count),
  .empty(reg_push_empty),
// spyglass enable_block W528
  .almost_empty(push_ae),
  .half_full(push_hf),
  .almost_full(push_af),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .full(reg_push_full),
  .error(reg_push_error),
// spyglass enable_block W528
  .this_addr(wr_addr),
  .this_addr_g(push_addr_g),
 
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .next_word_count(early_push_word_count),
  .next_empty_n(early_push_empty_n),
  .next_full(early_push_full),
// spyglass enable_block W528
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .next_error(early_push_error)
// spyglass enable_block W528
  );

  DW_apb_i2c_bcm05
   #(DEPTH, ADDR_WIDTH, COUNT_WIDTH, POP_AE_LVL, POP_AF_LVL, ERR_MODE, POP_SYNC, 0, PIPE_GRAY_POP, VERIF_EN ) U_POP_FIFOFCTL(
  .clk(clk_pop),
  .rst_n(rst_pop_n),
  .init_n(init_pop_n),
  .inc_req_n(pop_req_n),
  .other_addr_g(push_addr_g),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .word_count(reg_pop_word_count),
  .empty(reg_pop_empty),
// spyglass enable_block W528
  .almost_empty(pop_ae),
  .half_full(pop_hf),
  .almost_full(pop_af),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .full(reg_pop_full),
  .error(reg_pop_error),
// spyglass enable_block W528
  .this_addr(rd_addr),
  .this_addr_g(pop_addr_g),
 
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .next_word_count(early_pop_word_count),
  .next_empty_n(early_pop_empty_n),
  .next_full(early_pop_full),
// spyglass enable_block W528
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
  .next_error(early_pop_error)
// spyglass enable_block W528
  );

generate
  if ((EARLY_PUSH_STAT & 1) == 1) begin : GEN_EARLY_PSH_EMPTY
    wire   early_push_empty;
    assign early_push_empty = ~early_push_empty_n;
    assign push_empty = early_push_empty;
  end else begin : GEN_REG_PSH_EMPTY
    assign push_empty = reg_push_empty;
  end
  if ((EARLY_PUSH_STAT & 2) == 2) begin : GEN_EARLY_PSH_FULL
    assign push_full = early_push_full;
  end else begin : GEN_REG_PSH_FULL
    assign push_full = reg_push_full;
  end
  if ((EARLY_PUSH_STAT & 4) == 4) begin : GEN_EARLY_PSH_WC
    assign push_word_count = early_push_word_count;
  end else begin :  GEN_REG_PSH_WC
    assign push_word_count = reg_push_word_count;
  end
  if ((EARLY_PUSH_STAT & 8) == 8) begin : GEN_EARLY_PSH_ERR
    assign push_error = early_push_error;
  end else begin : GEN_REG_PSH_ERR
    assign push_error = reg_push_error;
  end

  if ((EARLY_POP_STAT & 1) == 1) begin : GEN_EARLY_POP_EMPTY
    wire   early_pop_empty;
    assign early_pop_empty = ~early_pop_empty_n;
    assign pop_empty = early_pop_empty;
  end else begin : GEN_REG_POP_EMPTY
    assign pop_empty = reg_pop_empty;
  end
  if ((EARLY_POP_STAT & 2) == 2) begin : GEN_EARLY_POP_FULL
    assign pop_full = early_pop_full;
  end else begin : GEN_REG_POP_FULL
    assign pop_full = reg_pop_full;
  end
  if ((EARLY_POP_STAT & 4) == 4) begin : GEN_EARLY_POP_WC
    assign pop_word_count = early_pop_word_count;
  end else begin : GEN_REG_POP_WC
    assign pop_word_count = reg_pop_word_count;
  end
  if ((EARLY_POP_STAT & 8) == 8) begin : GEN_EARLY_POP_ERR
    assign pop_error = early_pop_error;
  end else begin : GEN_REG_POP_ERR
    assign pop_error = reg_pop_error;
  end
endgenerate

`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS

  DW_apb_i2c_sva07 #(
    .F_SYNC_TYPE (PUSH_SYNC  ),
    .R_SYNC_TYPE (POP_SYNC   )
  ) P_CDC_CLKCOH (
      .clk_s     (clk_push   )
    , .clk_d     (clk_pop    )
    , .rst_s_n   (rst_push_n )
    , .rst_d_n   (rst_pop_n  )
  );

`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON
endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #4 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_async_fifo.v#4 $ 
//
//
// File    : DW_apb_i2c_fifo.v
//
//
// Abstract: FIFO Controller for the DW_apb_i2c macrocell
//
//        1: Instantiates the DW_apb_i2c_DWbb_fifoctl_s1_df macrocell twice.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_async_fifo
   (
    pclk,
                                presetn,
                                ic_clk,
                                ic_rst_n,
                                ptx_fifo_rst,
                                ictx_fifo_rst,
                                set_tx_empty_en_flg_edg,
                                ic_tx_tl,
                                tx_push,
                                tx_pop,
                                tx_pop_flg,
                                tx_pop_sync,
                                ptx_empty,
                                ictx_empty,
                                ptx_full, 
                                ptx_almost_empty,
                                gen_tx_almost_empty,
                                ptx_overflow,
                                tx_wr_addr,
                                tx_rd_addr,
                                tx_we_n,
                                prx_fifo_rst,
                                icrx_fifo_rst,
                                ic_rx_tl,
                                rx_pop,
                                rx_push,
                                rx_push_flg,
                                rx_push_sync,
                                prx_full, 
                                icrx_full, 
                                prx_empty,
                                prx_almost_full,
                                prx_overflow,
                                prx_underflow,
                                rx_wr_addr,
                                rx_rd_addr,
                                rx_we_n
                                );
   
   input                pclk;            // APB clock
   input                presetn;         // APB async reset
   input                ic_clk;          // I2C clock
   input                ic_rst_n;        // I2C async reset
   
   input                ptx_fifo_rst;   // Sync Tx fifo reset
   input                ictx_fifo_rst;  // Sync Tx fifo reset
   input                set_tx_empty_en_flg_edg;     // sync fifo reset
   input [`IC_TX_TL_RS-1:0] ic_tx_tl;     // tx fifo empty threshold
   input                tx_push;          // tx fifo push
   input                tx_pop;           // tx fifo pop
   input                tx_pop_flg;       // tx fifo pop toggle from ic_clk domain
   output               tx_pop_sync;      // pclk sync tx fifo pop
   output               ptx_empty;        // pclk sync tx fifo empty status
   output               ictx_empty;       // ic_clk sync tx fifo empty status
   output               ptx_full;         // pclk sync tx fifo full status   
   output               ptx_almost_empty; // pclk sync tx fifo almost empty status
   output               gen_tx_almost_empty; // pclk sync tx fifo almost empty status based 
   output               ptx_overflow;     // pclk sync tx fifo overflow
   output [`TX_ABW-1:0] tx_wr_addr;       // tx fifo write pointer
   output [`TX_ABW-1:0] tx_rd_addr;       // tx fifo read pointer
   output               tx_we_n;          // tx fifo write enable
   
   input                prx_fifo_rst;   // Sync Rx fifo reset
   input                icrx_fifo_rst;  // Sync Rx fifo reset
   input [`RX_ABW-1:0]  ic_rx_tl;         // rx fifo full threshold
   input                rx_pop;           // rx fifo pop
   input                rx_push;          // rx fifo push
   input                rx_push_flg;      // rx fifo push toggle from ic_clk domain 
   output               rx_push_sync;     // pclk sync rx fifo push
   output               prx_full;         // pclk sync rx fifo full status
   output               icrx_full;        // ic_clk sync rx fifo full status
   output               prx_empty;        // pclk sync rx fifo empty status   
   output               prx_almost_full;  // pclk sync rx fifo almost full status
   output               prx_overflow;     // pclk sync rx fifo overflow
   output               prx_underflow;    // pclk sync rx fifo underflow
   output [`RX_ABW-1:0] rx_wr_addr;       // rx fifo write pointer
   output [`RX_ABW-1:0] rx_rd_addr;       // rx fifo read pointer
   output               rx_we_n;          // rx fifo write enable

   // ------------------------------------------------------
   // -- local registers
   // ------------------------------------------------------
   reg                      tx_pop_flg_sync_q;
   reg                      rx_push_flg_sync_q;

   reg  [`IC_TX_TL_RS:0]  tx_fifo_cmd_cntr;

   reg                      tx_push_dly;
   reg                      rx_pop_dly;
   
   // ------------------------------------------------------
   // -- local wires
   // ------------------------------------------------------
   wire                     tx_pop_flg_sync;
   wire                     rx_push_flg_sync;

   wire                     tx_pop_flg_edg;
   wire                     rx_push_flg_edg;

   wire                     tx_pop_sync;
   wire                     rx_push_sync;

   wire                     ptx_fifo_rst_n;
   wire                     ictx_fifo_rst_n;
   wire                     prx_fifo_rst_n;
   wire                     icrx_fifo_rst_n;

   wire                     tx_pop_n;
   wire                     tx_push_n;
   wire                     rx_pop_n;
   wire                     rx_push_n;

   wire [`TX_ABW:0]         tx_empty_level;
   wire                     max_ic_rx_tl;
   wire [`RX_ABW-1:0]       ic_rx_tl_int;
   wire [`RX_ABW:0]         rx_thresh;

   wire [`IC_TX_TL_RS:0]  tx_fifo_cmd_cntr_c;
   wire                     gen_tx_almost_empty;

   wire                     rx_thresh_eq_rx_buffer_depth;
   wire                     switch_almost_full;
   wire                     i_rx_almost_full;

   wire                     tx_we_n;
   wire [`TX_ABW-1:0]       tx_wr_addr;
   wire [`TX_ABW-1:0]       tx_rd_addr;
   wire                     rx_we_n;
   wire [`RX_ABW-1:0]       rx_wr_addr;
   wire [`RX_ABW-1:0]       rx_rd_addr;


   
   wire                     ptx_empty;
   wire                     ptx_full;
   wire                     ptx_almost_empty;
   wire                     ptx_overflow_i;
   wire                     ptx_overflow;
   wire [`TX_ABW:0]         ptx_word_count;

   wire                     ictx_empty;

   wire                     ptx_ae_unconn;
   wire                     ptx_hf_unconn;
   wire                     ptx_af_unconn;
   
   wire                     ictx_ae_unconn;
   wire                     ictx_hf_unconn;
   wire                     ictx_af_unconn;
   wire                     ictx_full_unconn;
   wire                     ictx_underflow_unconn;
   wire [`TX_ABW:0]         ictx_word_count_unconn;

   wire                     icrx_full;

   wire                     prx_empty;
   wire                     prx_full;
   wire                     prx_almost_full;
   wire                     prx_overflow;
   wire                     prx_overflow_tog;
   reg                      prx_overflow_tog_q;
   wire                     prx_overflow_i;
   wire                     prx_underflow_i;
   wire                     prx_underflow;
   wire [`RX_ABW:0]         prx_word_count;

   wire                     icrx_overflow_i;
   wire                     icrx_overflow_r;
   wire                     icrx_overflow_edg;
   wire                     icrx_overflow_tog;

   wire                     icrx_empty_unconn;
   wire                     icrx_ae_unconn;
   wire                     icrx_hf_unconn;
   wire                     icrx_af_unconn;
   wire [`RX_ABW:0]         icrx_word_count_unconn;
   
   wire                     prx_ae_unconn;
   wire                     prx_hf_unconn;
   wire                     prx_af_unconn;

   // ----------------------------------------------------------
   // -- Synchronization registers for input from ic_clk domain
   // ----------------------------------------------------------

   DW_apb_i2c_bcm21
    #(
     .F_SYNC_TYPE (`IC_SYNC_DEPTH),
     .VERIF_EN    (`IC_VERIF_EN)
   ) 
   U_DW_apb_i2c_bcm21_ic2pl_tx_pop_flg_psyzr
   (
      .clk_d               (pclk)
     ,.rst_d_n             (presetn)
     ,.data_s              (tx_pop_flg)
     ,.data_d              (tx_pop_flg_sync)
   );


   DW_apb_i2c_bcm21
    #(
     .F_SYNC_TYPE (`IC_SYNC_DEPTH),
     .VERIF_EN    (`IC_VERIF_EN)
   ) 
   U_DW_apb_i2c_bcm21_ic2pl_rx_push_flg_psyzr
   (
      .clk_d               (pclk)
     ,.rst_d_n             (presetn)
     ,.data_s              (rx_push_flg)
     ,.data_d              (rx_push_flg_sync) 
   );


   // ----------------------------------------------------------
   // -- Edge detection circuitry for input from ic_clk domain
   // ----------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : EDGE_DET_PROC
      if(presetn == 1'b0) begin
         tx_pop_flg_sync_q  <= 1'b0; 
         rx_push_flg_sync_q <= 1'b0; 
      end else begin
         tx_pop_flg_sync_q  <= tx_pop_flg_sync; 
         rx_push_flg_sync_q <= rx_push_flg_sync; 
      end
   end

   assign tx_pop_flg_edg       = (tx_pop_flg_sync_q  ^ tx_pop_flg_sync);
   assign rx_push_flg_edg      = (rx_push_flg_sync_q ^ rx_push_flg_sync);
   
   // -------------------------------------------------------
   // -- Generation of tx_push_sync and rx_pop_sync signals.
   //
   //  The tx_pop and rx_push signal are driven from the
   //  ssi_clk domain. They are synchronized over to the
   //  pclk domain here if pclk and ic_clk are asynchronous
   //  Both signal are also rising edge detected.
   // -------------------------------------------------------
   assign tx_pop_sync  = tx_pop_flg_edg;
   assign rx_push_sync = rx_push_flg_edg;

   // ------------------------------------------------------
   // -- Active low Reset signal generation
   // ------------------------------------------------------
   assign ptx_fifo_rst_n  = !ptx_fifo_rst;
   assign ictx_fifo_rst_n = !ictx_fifo_rst;
   assign prx_fifo_rst_n  = !prx_fifo_rst;
   assign icrx_fifo_rst_n = !icrx_fifo_rst;

   // ------------------------------------------------------
   // -- Active low push and pop control signal generation
   // ------------------------------------------------------
   assign tx_pop_n  = !tx_pop;
   assign tx_push_n = !tx_push;
   assign rx_pop_n  = !rx_pop;
   assign rx_push_n = !rx_push;

   // ------------------------------------------------------
   // -- Set the Almost Empty Level and Almost Full Threshold
   // ------------------------------------------------------
   assign tx_empty_level = {1'b0, ic_tx_tl[`TX_ABW-1:0]};

   assign max_ic_rx_tl = (&ic_rx_tl[`RX_ABW-1:0]);
   assign ic_rx_tl_int = ic_rx_tl[`RX_ABW-1:0] + {{(`RX_ABW-1){1'b0}},1'b1};
   
   assign rx_thresh    = (max_ic_rx_tl == 1'b1) ? {1'b0, ic_rx_tl[`RX_ABW-1:0]}: {1'b0, ic_rx_tl_int[`RX_ABW-1:0]};

   // ------------------------------------------------------
   // -- Get the Tx FIFO Almost Empty based on command execution in the ic_clk domain
   // ------------------------------------------------------
   // Counter which increments on number of commands pushed in to fifo 
   // and decrements on the number of commands executed
   always @(posedge pclk or negedge presetn) begin : FIFO_CMD_CNTR_PROC
     if(presetn == 1'b0) begin
       tx_fifo_cmd_cntr <= {(`IC_TX_TL_RS+1){1'b0}};
     end
     else begin
       if (!ptx_fifo_rst_n)
         tx_fifo_cmd_cntr <= {(`IC_TX_TL_RS+1){1'b0}};
       else if(set_tx_empty_en_flg_edg && tx_push)
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr_c;
       else if(set_tx_empty_en_flg_edg && (tx_fifo_cmd_cntr !=0))
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr - {{(`IC_TX_TL_RS){1'b0}},1'b1};
       else if(tx_push && (tx_fifo_cmd_cntr < `IC_TX_BUFFER_DEPTH))
         tx_fifo_cmd_cntr <= tx_fifo_cmd_cntr + {{(`IC_TX_TL_RS){1'b0}},1'b1};
     end
   end 

   assign tx_fifo_cmd_cntr_c = tx_fifo_cmd_cntr;
   // Generate Tx FIFO almost empty based on the command executed
   // in the ic_clk domain
   assign gen_tx_almost_empty = (tx_fifo_cmd_cntr <= {1'b0,ic_tx_tl});

//// reuse-pragma attr GenerateIf @IC_CLK_TYPE==0      
//   DW_apb_i2c_bcm06 #(`IC_TX_BUFFER_DEPTH, 2, `TX_ABW) U_tx_fifo
//         (
//          .clk           (pclk)
//          ,.init_n       (ptx_fifo_rst_n)
//          ,.rst_n        (presetn)
//          ,.push_req_n   (tx_push_n)
//          ,.pop_req_n    (tx_pop_n)
//          ,.diag_n       (1'b1)
//          ,.ae_level     (tx_empty_level)
//          ,.af_thresh    ({`TX_ABW{1'b1}})
//          ,.we_n         (tx_we_n)
//          ,.wr_addr      (tx_wr_addr)
//          ,.rd_addr      (tx_rd_addr)
//          ,.empty        (ptx_empty)
//          ,.almost_empty (ptx_almost_empty)
//          ,.full         (ptx_full)
//          ,.almost_full  (ptx_almost_full_unconn)
//          ,.half_full    (ptx_half_full_unconn)
//          ,.error        (ptx_error_ir)
//          ,.wrd_count    (pwrdc_tx_unconn)
//          ,.nxt_empty_n  (pnxten_tx_unconn)
//          ,.nxt_full     (pnxtf_tx_unconn)
//          ,.nxt_error    (pnxte_tx_unconn) 
//          );


//// reuse-pragma attr GenerateIf @IC_CLK_TYPE==0      
//   DW_apb_i2c_bcm06 #(`IC_RX_BUFFER_DEPTH, 2, `RX_ABW) U_rx_fifo
//         (
//          .clk           (pclk)
//          ,.init_n       (prx_fifo_rst_n)
//          ,.rst_n        (presetn)
//          ,.push_req_n   (rx_push_n)
//          ,.pop_req_n    (rx_pop_n)
//          ,.diag_n       (1'b1)
//          ,.ae_level     ({`RX_ABW{1'b0}})
//          ,.af_thresh    (rx_thresh)
//          ,.we_n         (rx_we_n)
//          ,.wr_addr      (rx_wr_addr)
//          ,.rd_addr      (rx_rd_addr)
//          ,.empty        (prx_empty)
//          ,.almost_empty (prx_almost_empty_unconn)
//          ,.full         (prx_full)
//          ,.almost_full  (i_rx_almost_full)
//          ,.half_full    (prx_half_full_unconn)
//          ,.error        (prx_error_ir)
//          ,.wrd_count    (pwrdc_rx_unconn)
//          ,.nxt_empty_n  (pnxten_rx_unconn)
//          ,.nxt_full     (pnxtf_rx_unconn)
//          ,.nxt_error    (pnxte_rx_unconn) 
//          );



   // ------------------------------------------------------
   // -- Instance of Tx FIFO controller
   // ------------------------------------------------------
       DW_apb_i2c_bcm07
        #(
           .DEPTH (`IC_TX_BUFFER_DEPTH),
           .ADDR_WIDTH (`TX_ABW),
           //spyglass disable_block SelfDeterminedExpr-ML
           //SMD: Self determined expression present in the design.
           //SJ:  This Self Determined Expression is as per the design requirement. 
           //     There will not be any functional issue.
           .COUNT_WIDTH (`TX_ABW+1),
           //spyglass enable_block SelfDeterminedExpr-ML
           .ERR_MODE(1),
           .VERIF_EN(`IC_VERIF_EN),
           .PUSH_SYNC(`IC_SYNC_DEPTH),
           .POP_SYNC(`IC_SYNC_DEPTH)
           )
           U_tx_fifo(
           .clk_push        (pclk),
           .rst_push_n      (presetn),
           .init_push_n     (ptx_fifo_rst_n),
           .push_req_n      (tx_push_n),
           .push_empty      (ptx_empty),
           //spyglass disable_block W528
           //SMD : A signal or variable is set but never read
           //SJ  : The BCM07 is a generic FIFO design, which has many features.
           //      But this use case does not use all features. Hence these signals
           //      are unused. But there is no functional issue, hence this can be 
           //      waived. 
           .push_ae         (ptx_ae_unconn),
           .push_hf         (ptx_hf_unconn),
           .push_af         (ptx_af_unconn),
           //spyglass enable_block W528
           .push_full       (ptx_full),
           .push_error      (ptx_overflow_i),
           .push_word_count (ptx_word_count),
           .we_n            (tx_we_n),
           .wr_addr         (tx_wr_addr),


           .clk_pop         (ic_clk),
           .rst_pop_n       (ic_rst_n),
           .init_pop_n      (ictx_fifo_rst_n),
           .pop_req_n       (tx_pop_n),
           .pop_empty       (ictx_empty),
           //spyglass disable_block W528
           //SMD : A signal or variable is set but never read
           //SJ  : The BCM07 is a generic FIFO design, which has many features.
           //      But this use case does not use all features. Hence these signals
           //      are unused. But there is no functional issue, hence this can be 
           //      waived. 
           .pop_ae          (ictx_ae_unconn),
           .pop_hf          (ictx_hf_unconn),
           .pop_af          (ictx_af_unconn),
           .pop_full        (ictx_full_unconn),
           .pop_error       (ictx_underflow_unconn),
           .pop_word_count  (ictx_word_count_unconn),
           //spyglass enable_block W528
           .rd_addr         (tx_rd_addr)
          );


   // ------------------------------------------------------
   // -- Instance of Rx FIFO controller
   // ------------------------------------------------------
       DW_apb_i2c_bcm07
        #(
           .DEPTH (`IC_RX_BUFFER_DEPTH),
           .ADDR_WIDTH (`RX_ABW),
           //spyglass disable_block SelfDeterminedExpr-ML
           //SMD: Self determined expression present in the design.
           //SJ:  This Self Determined Expression is as per the design requirement. 
           //     There will not be any functional issue.
           .COUNT_WIDTH (`RX_ABW+1),
           //spyglass enable_block SelfDeterminedExpr-ML
           .ERR_MODE(1),
           .VERIF_EN(`IC_VERIF_EN),
           .PUSH_SYNC(`IC_SYNC_DEPTH),
           .POP_SYNC(`IC_SYNC_DEPTH)
           )
           U_rx_fifo(
           .clk_push        (ic_clk),
           .rst_push_n      (ic_rst_n),
           .init_push_n     (icrx_fifo_rst_n),
           .push_req_n      (rx_push_n),
           //spyglass disable_block W528
           //SMD : A signal or variable is set but never read
           //SJ  : The BCM07 is a generic FIFO design, which has many features.
           //      But this use case does not use all features. Hence these signals
           //      are unused. But there is no functional issue, hence this can be 
           //      waived. 
           .push_empty      (icrx_empty_unconn),
           .push_ae         (icrx_ae_unconn),
           .push_hf         (icrx_hf_unconn),
           .push_af         (icrx_af_unconn),
           //spyglass enable_block W528
           .push_full       (icrx_full),
           .push_error      (icrx_overflow_i),
           //spyglass disable_block W528
           //SMD : A signal or variable is set but never read
           //SJ  : The BCM07 is a generic FIFO design, which has many features.
           //      But this use case does not use all features. Hence these signals
           //      are unused. But there is no functional issue, hence this can be 
           //      waived. 
           .push_word_count (icrx_word_count_unconn), 
           //spyglass enable_block W528
           .we_n            (rx_we_n),
           .wr_addr         (rx_wr_addr),
          
           .clk_pop         (pclk),
           .rst_pop_n       (presetn),
           .init_pop_n      (prx_fifo_rst_n),
           .pop_req_n       (rx_pop_n),
           .pop_empty       (prx_empty),
           //spyglass disable_block W528
           //SMD : A signal or variable is set but never read
           //SJ  : The BCM07 is a generic FIFO design, which has many features.
           //      But this use case does not use all features. Hence these signals
           //      are unused. But there is no functional issue, hence this can be 
           //      waived. 
           .pop_ae          (prx_ae_unconn),
           .pop_hf          (prx_hf_unconn),
           .pop_af          (prx_af_unconn),
           //spyglass enable_block W528
           .pop_full        (prx_full),
           .pop_error       (prx_underflow_i),
           .pop_word_count  (prx_word_count),
           .rd_addr         (rx_rd_addr)
          );


   // ------------------------------------------------------
   // -- Get the Tx FIFO Almost Empty
   // ------------------------------------------------------
   assign ptx_almost_empty =  (ptx_word_count <= tx_empty_level);

   // ------------------------------------------------------
   // -- Get the Rx FIFO Almost Full
   // ------------------------------------------------------
   assign i_rx_almost_full   =  (prx_word_count >= rx_thresh);
   assign rx_thresh_eq_rx_buffer_depth = (rx_thresh == `IC_RX_BUFFER_DEPTH);
   assign switch_almost_full = (rx_thresh_eq_rx_buffer_depth == 1'b1) ? prx_full : i_rx_almost_full;
   assign prx_almost_full    = (max_ic_rx_tl == 1'b1)                 ? prx_full : switch_almost_full;

   // ------------------------------------------------------
   // -- Overflow and Underflow flags (Asynchronous Mode)
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : ERROR_DLY_ASYNC_PROC
      if(presetn == 1'b0) begin
         tx_push_dly <= 1'b0;
         rx_pop_dly  <= 1'b0;
      end else begin
         tx_push_dly <= tx_push;
         rx_pop_dly  <= rx_pop;
      end
   end // block: ERROR_DLY_ASYNC_PROC

   assign ptx_overflow  = ptx_overflow_i && tx_push_dly; 

   DW_apb_i2c_regs
    
   #(1)
   U_icrx_overflow_reg (
     .clk        (ic_clk),
     .resetn     (ic_rst_n),
     .data_in    (icrx_overflow_i),
     .data_r_out (icrx_overflow_r)
   );


   // ----------------------------------------------------------
   // -- This block generates icrx_overflow_tog signal, 
   // -- which toggles on the rising edge of icrx_overflow_edg
   // ----------------------------------------------------------
   assign icrx_overflow_edg = ((icrx_overflow_i == 1'b1) && (icrx_overflow_r == 1'b0));

   DW_apb_i2c_tog
    
   U_icrx_overflow_tog (
     .clk          (ic_clk),
     .resetn       (ic_rst_n),
     .tog_data_in  (icrx_overflow_edg),
     .tog_data_out (icrx_overflow_tog)
   );


   DW_apb_i2c_bcm21
    #(
     .F_SYNC_TYPE (`IC_SYNC_DEPTH),
     .VERIF_EN    (`IC_VERIF_EN)
   ) 
   U_rx_overflow_sync
   (
      .clk_d               (pclk)
     ,.rst_d_n             (presetn)
     ,.data_s              (icrx_overflow_tog)
     ,.data_d              (prx_overflow_tog) 
   );


   always @(posedge pclk or negedge presetn) begin : EDGE_DET_PRX_OVERFLOW_PROC
      if(presetn == 1'b0) begin
         prx_overflow_tog_q <= 1'b0; 
      end else begin
         prx_overflow_tog_q <= prx_overflow_tog; 
      end
   end

   assign prx_overflow_i = (prx_overflow_tog_q ^ prx_overflow_tog);

   assign prx_overflow  = prx_overflow_i;
   assign prx_underflow = prx_underflow_i && rx_pop_dly;


endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #19 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_tx_shift.v#19 $ 
//
//
// File    : DW_apb_i2c_rx_shift.v
//
//
// Author  : Hani Saleh
// Created : Sep  2002
// Abstract: The tx_shft module is responsible for transmitting
//           a byte of data to either a slave or master in either 
//           Master or Slave mode configuration.  This module will
//           also generate the acknowledge pulse after a byte of 
//           data has been received and generate the START and STOP
//           conditions when configured as a master.
//
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_tx_shift
  (
   //top level
   ic_clk,
                             ic_rst_n,
                             //regfile
                             ic_hs_sync,
                             ic_sda_tx_hold_sync,
                             ic_spklen,
                             ic_master_sync,
                             //mstfsm signals
                             mst_tx_en,
                             mst_rx_en,
                             mst_tx_data_buf_in,
                             start_en,
                             re_start_en,
                             mst_txfifo_ld_en,
                             tx_fifo_data_buf,
                             stop_en,
                             mst_gen_ack_en,
                             // jduarte begin 20101008
                             // CRM 9000366029
                             // jduarte end 20101008
                             //slvfsm signals
                             slv_txfifo_ld_en,
                             slv_gen_ack_en,
                             slv_tx_en,
                             scl_hld_low_en,
                             slv_tx_ready,
                             slv_tx_cmplt,
                             //clk_gen signals
                             hs_mcode_en,
                             scl_lcnt_en,
                             scl_hcnt_en,
                             scl_s_hld_en,
                             scl_s_setup_en,
                             scl_p_setup_en,
                             scl_lcnt_cmplt,
                             scl_hcnt_cmplt,
                             scl_s_hld_cmplt,
                             scl_s_setup_cmplt,
                             scl_p_setup_cmplt,
                             // rx_filter signals
                             arb_lost,
                             mst_tx_ack_vld,
                             slv_tx_shift_en,
                             slv_tx_ack_vld,
                             scl_edg_hl,
                             scl_int,
                             mst_txdata_state,
                             master_read,
                             mst_rx_bit_count,
                             mstrx1_7_end,
                             //rx shift reg
                             mst_rx_ack_vld,
                             mst_rx_bwen,
                             slv_rx_ack_vld,
                             re_start_cmplt,
                             stop_cmplt,
                             mst_tx_cmplt,
                             byte_wait_scl,
                             //top level outputs
                             ic_clk_oe,
                             ic_data_oe,
                             tx_current_src_en,
                             //fifo cntl signals
                             tx_pop,
                             //fifo ram
                             tx_pop_data,
                             // from rx shift reg
                             mst_rx_data_scl,
                             rx_scl_lcnt_en,
                             rx_scl_hcnt_en,
                             slv_tx_data_en,
                             set_tx_empty_en
                             );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;// processor clock
   input ic_rst_n;// syn rst active high
   //mstfsm signals
   input [`IC_DATA_RS-1:0] mst_tx_data_buf_in; // data to be transmitted on sda data out   
   input                   mst_tx_en; // Enable tx shift register to transmit data
   input                   mst_rx_en; // Enable rx shift register to transmit data
   input                   start_en;   // Enable START condition
   input                   stop_en;   // Generate STOP condition
   input                   mst_txfifo_ld_en;// load tx_buffer from the tx fifo output
   input                   mst_gen_ack_en; // Enable Ack gen. ckt
   input                   re_start_en;   // Enable RE-START condition

// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008

   //slvfsm
   input                   slv_txfifo_ld_en;// load tx_buffer from the tx fifo output
   input                   slv_gen_ack_en; // Enable Ack gen. ckt
   input                   slv_tx_en; // Enable tx shift register to transmit data

  
   //rx shift reg
   input                   mst_rx_ack_vld;//master RX ack pulse is valid
   input                   slv_rx_ack_vld;//slave RX ack pulse is valid
   input                   scl_hld_low_en;//Salve held scl signal low waiting for input from the processor
   input                   mst_rx_data_scl;//Master receiver scl clock signal
   input                   rx_scl_lcnt_en;//Enable low count period counter
   input                   rx_scl_hcnt_en;//Enable high count period counter
   input                   mst_rx_bwen;//master rx byte wait enable


   //regfile
   input                   ic_hs_sync;//ic is in high speed mode
   input [`IC_SDA_TX_HOLD_RS-1:0]   ic_sda_tx_hold_sync;//SDA transmit hold time num cycles.
   input [`IC_SPKLEN_RS-1:0] ic_spklen; // Spike length currently being supressed
   input                   ic_master_sync;//1 master, 0 slave.
   //from rx_filter
   input                   arb_lost;//arbitration lost to another master
   input                   slv_tx_shift_en;//logic 1:SDA data is valid and could be sampled
   input   scl_edg_hl;   // falling edge detect of SCL
   input   scl_int;//filtered input scl signal


   //from clk_gen
   input                   scl_lcnt_cmplt;//scl low count period has elapsed
   input                   scl_hcnt_cmplt;//scl high count period has elapsed
   input                   scl_s_hld_cmplt;//scl start hold count period has elapsed
   input                   scl_s_setup_cmplt;//scl start setup  count period has elapsed
   input                   scl_p_setup_cmplt;//scl stop setup  count period has elapsed
   //from mst_fsm
   input                   hs_mcode_en;//IC is in HS mode and TX the Master Code
//   input                   byte_no1;//1: this is the 1st byte ever of the current transfer

   //from fifo ram
   input [`IC_DATA_TX_CMD_RS-1:0] tx_pop_data;//Data popped from the TX fifo
   
   input                   mst_txdata_state;
   input                   master_read;
   input [3:0]             mst_rx_bit_count;
   input                   mstrx1_7_end;
   input                   slv_tx_data_en; // slave transmitting Tx-FIFO data
//   input [`IC_SMBUS_UDID_RS-1:0] smbus_udid_shift; // SMBUS UDID Shift Rrgister.

   //outputs
   output                  slv_tx_ack_vld;//logic 1:check for ack now
   output                  slv_tx_ready;//slave is ready to transmit
   output                  slv_tx_cmplt;//logic 1: slave has finished transmission
   output                  mst_tx_ack_vld;//logic 1:check for ack now
   //to mst_fsm
   output [`IC_DATA_TX_CMD_RS-1:0] tx_fifo_data_buf;//Buffer to hold data popped from tx fifo
   //to clk_gen
   output                       scl_lcnt_en;//enable low count period
   output                       scl_hcnt_en;//enable high count period
   output                       scl_s_hld_en;//enable start hold count period
   output                       scl_s_setup_en;//enable start setup count period
   output                       scl_p_setup_en;//enable stop setup count period   
   output                       re_start_cmplt;//logic 1:re-start condition has been generated        
   output                       stop_cmplt;//logic 1:stop condition has been generated        
   output                       mst_tx_cmplt;//logic 1:master tx bit completed        
   //to top level
   output                       ic_clk_oe;//Drives the SCL line transistor
   output                       ic_data_oe;//Drives the SDA line transistor
   output                       tx_current_src_en;//logic 1:enables pull up current source in HS mode
   //fifo cntl signals
   output                       tx_pop;//logic 1: pop data from TX fifo
   output                       byte_wait_scl;//logic 1: wait for scl to go high before a restart, tx, rx or stop

   output                       set_tx_empty_en;
   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------
   //registers
   reg [`IC_DATA_TX_CMD_RS-1:0]    tx_fifo_data_buf;//Buffer to hold data popped from tx fifo   
   reg [`IC_DATA_RS-1:0]        tx_shift_buf;//TX shift register
   //to clk_gen
   reg                          data_scl_lcnt_en;
   reg                          scl_hcnt_en_int;
   reg                          st_scl_s_hld_en;
   reg                          re_scl_s_hld_en;
   reg                          scl_s_stp_int;
   reg                          scl_p_stp_int;   
   reg                          start_sda;
   wire                         start_sda_gated;
   reg                          start_sda_gate_r;
   reg                          stop_sda;
   wire                         stop_sda_gated;
   reg                          stop_scl;
   reg                          re_start_sda, re_start_sda_r;
   wire                         re_start_sda_gated, re_start_sda_r_gated;
   reg                          re_start_scl;
   reg                          ic_data_oe;
   reg                          ic_clk_oe;
//   wire ic_clk_oe;
   
   reg                          tx_current_src_en;
   reg                          stop_scl_lcnt_en;
   reg                          tx_data_capture;
   reg [3:0]                    tx_bit_count;
   reg                          data_sda;
   reg                          data_sda_prev_r; // Data SDA of previous SCL.
   wire                         data_sda_gated; // Data SDA gated to change when SCL in=0.
   wire                         ack_sda_gated; // ACK SDA gated to change when SCL in=0.
   reg                          mst_tx_ack_int;//logic 1: This is the ack clock cycle
   reg [3:0]                    slv_tx_bit_count;
   reg                          slv_data_sda;
   wire                         slv_data_sda_gated;
   reg                          slv_tx_ack_vld;
   reg                          slv_tx_ready;//slave is ready to transmit
   reg                          slv_tx_ready_dly1;//slave is ready to transmit, delay1
   reg                          slv_tx_ready_dly2;//slave is ready to transmit, delay2
   reg                          slv_tx_cmplt;//logic 1: slave has finished transmission
   reg                          data_scl;
   reg                          re_start_scl_lcnt_en;
   reg                          ic_data_oe_early;
   reg                          byte_wait_scl;
   reg                          scl_hld_low_en_r;
// jduarte begin 20101008
// CRM 9000366029
// jduarte end 20101008
   reg                          tx_pop;
   reg                          mst_tx_bwen;//master tx byte wait enable
   // jduarte 20101004 begin
   // CRM 9000423043
   reg                          mst_slv_ack_ext;
   reg                          mst_slv_ack_ext_r;
   reg                          sda_hold_done; // Asserted when sda hold time finished.
   // jduarte 20101004 end
// jduarte 20101108 begin
// CRM 9000424562
   reg                          scl_int_r;
// jduarte 20101108 end
   
// start 9000557489
reg set_tx_empty_en;
// end 9000557489

   
   //wires   
   wire                          ack_sda;
   wire                         scl_shld_en_int;//enable start hold count period
   wire                         scl_lcnt_en_int;//enable low count period
   wire                         sda_out_n;
   wire                         scl_out_n;
   wire                         load_sda_scl;
   wire                         load_sda_scl_int;
   wire                         ack_load;
   wire                         stop_cmplt_int;
   wire                         bit1_7_lo;
   wire                         bit1_7_hi;
   wire                         bit1_7_end;
   wire                         bit1_7_end_int;
   wire                         bit8_lo;
   wire                         bit8_hi;
   wire                         bit8_end;
   wire                         bit8_end_int;
   wire                         start_tx;
   wire                         slv_bit1_7;
   wire                         slv_inc_cnt;
   wire                         hs_no_mcode;
   wire                         tx_no_capture;
   wire                         mst_slv_ack;
   wire                         mstslv_txfld;
   wire                         byte_wait_en_int;
   wire                         byte_wait_en;
   wire                         slv_tx_data_en;
   wire                         start_lo;
   wire                         start_hld;
   wire                         no_start_hld;
   wire                         no_st_no_hld;
   wire                         re_lo;
   wire                         re_lo_int;
   wire                         re_hi;
   wire                         re_hi_int;
   wire                         re_hld;
   wire                         re_hld_int;
   wire                         re_setup;
   wire                         re_setup_int;
   wire                         stop_lo;
   wire                         stop_lo_int;
   wire                         stop_hi;
   wire                         stop_setup;
   wire                         stop_setup_int;
// jduarte 20101108 begin
// CRM 9000424562
   wire scl_int_ed;
// jduarte 20101108 end


   

   // ------------------------------------------------------
   // -- outputs assignments
   //
   // -- This is needed to resolve a reading from output 
   // ------------------------------------------------------
   assign mst_tx_ack_vld = mst_tx_ack_int;
   assign scl_lcnt_en = scl_lcnt_en_int;
   assign scl_hcnt_en = scl_hcnt_en_int;
   assign scl_s_hld_en = scl_shld_en_int;
   assign scl_s_setup_en = scl_s_stp_int;
   assign scl_p_setup_en = scl_p_stp_int;
   assign stop_cmplt = stop_cmplt_int;
   

   // ------------------------------------------------------
   // -- ic_data_oe generation
   //
   // -- This signal is used to drive the SDA output transistor
   // ------------------------------------------------------
   // 22/2/2010, jstokes, programmable SDA hold time added.
   assign sda_out_n 
     = (  ~start_sda_gated 
        | (~data_sda_gated) 
        | (~stop_sda_gated) 
        | (~re_start_sda_gated) 
        | (~re_start_sda_r_gated)
        | (~ack_sda_gated)
        | (~slv_data_sda_gated)
       );

// jduarte begin 20101008
// CRM 9000366029
//   assign scl_out_n =  (~data_scl | ~stop_scl | ~re_start_scl|~mst_rx_data_scl 
//                        | scl_hld_low_en);
//   assign load_sda_scl_int =  (re_start_scl_lcnt_en == 1'b1) || (rx_scl_hcnt_en == 1'b1) 
//                            || (scl_s_stp_int == 1'b1)     || (stop_scl_lcnt_en == 1'b1)
//                            || (scl_p_stp_int == 1'b1);
   assign scl_out_n =  ((~data_scl) | (~stop_scl) | (~re_start_scl) 
                        | (~mst_rx_data_scl) 
                        | scl_hld_low_en
                        );
                        
   assign load_sda_scl_int =  (re_start_scl_lcnt_en == 1'b1) 
                            || (rx_scl_hcnt_en == 1'b1) 
                            || (scl_s_stp_int == 1'b1)     || (stop_scl_lcnt_en == 1'b1)
                            || (scl_p_stp_int == 1'b1
                            );
// jduarte end 20101008
   
   assign load_sda_scl = (start_en == 1'b1) 
                         || (scl_hcnt_en_int == 1'b1) || (stop_cmplt_int == 1'b1)     
                         || (ack_load == 1'b1) 
                         || ((scl_shld_en_int  == 1'b1)
                            )
                         || ((rx_scl_lcnt_en == 1'b1)
                            )
                         || (slv_tx_en == 1'b1)
                         || (scl_hld_low_en_r == 1'b1)
                         || (load_sda_scl_int == 1'b1)
                         || ((scl_lcnt_en_int == 1'b1)
                         );
    
   //delay sda by 1 clk to make sure it is not changing with scl
   // and generate scl_hld_low_en_r signal by delaying scl_hld_low_en_r
   always @(posedge ic_clk or negedge ic_rst_n) begin : DLY_1_PROC
      if(ic_rst_n == 1'b0) 
        begin      
           ic_data_oe <= 1'b0;
           scl_hld_low_en_r <= 1'b0;
        end
      else 
        begin
           ic_data_oe <= ic_data_oe_early;
           scl_hld_low_en_r <= scl_hld_low_en;

        end
   end

// jduarte begin 20101008
// CRM 9000366029

// jduarte end 20101008
   
// start 9000557489
   // Generate the strobe to set the tx_empty_en in the end of the Read/Write data phase 
   always @(posedge ic_clk or negedge ic_rst_n) begin : EN_STRB_TX_EMPTY_PROC
      if(ic_rst_n == 1'b0) begin      
        set_tx_empty_en <= 1'b0;
      end
      else begin
        // Master mode read: data phase end of all read transfers
        if (
            (mst_rx_en 
            && (mst_rx_bit_count == 7) && mstrx1_7_end) ||
            // Master mode write: data phase completion of the write data transfer
            (mst_txdata_state 
              && (!master_read) 
              && (tx_bit_count == 7) && bit1_7_end) 
            // Slave mode write: Completion of last bit transmission
           || (slv_tx_en && slv_tx_data_en && (slv_tx_bit_count == 7) && slv_inc_cnt)
          )
          set_tx_empty_en <= 1'b1;
        else
          set_tx_empty_en <= 1'b0;
      end
   end
// end 9000557489
   
   //drive scl and sda outputs
   assign mst_slv_ack = ((mst_gen_ack_en == 1'b1) ||  (slv_gen_ack_en == 1'b1));

   // jduarte 20101004 begin
   // CRM 9000423043

   always @(*) begin : MST_SLV_ACK_EXT_PROC

     mst_slv_ack_ext = 1'b0;
     
     if(  (ic_clk_oe & ic_master_sync) 
        // In slave mode use external SCL.
          | (~scl_int & (~ic_master_sync)))
       begin
         if(~sda_hold_done && (~mst_slv_ack))
    mst_slv_ack_ext = 1'b1;
       end
   end

   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_SLV_ACK_EXT_R_PROC
      if(ic_rst_n == 1'b0) 
        begin
          mst_slv_ack_ext_r <= 1'b0;
        end
      else
        begin
          mst_slv_ack_ext_r <= mst_slv_ack_ext;
 end
   end

   // jduarte 20101004 end
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : IC_DATA_CLK_OE_PROC
      if(ic_rst_n == 1'b0) 
        begin
           ic_data_oe_early <= 1'b0;
           ic_clk_oe <= 1'b0;
        end 
      else if(load_sda_scl == 1'b1)
        begin
           ic_data_oe_early <= (arb_lost == 1'b0) ? sda_out_n : 1'b0;
           ic_clk_oe <= (arb_lost == 1'b0) ? scl_out_n : 1'b0;
        end 
      // jduarte 20101004 begin
      // CRM 9000423043
      // else if(mst_slv_ack == 1'b1)
      else if((mst_slv_ack == 1'b1) || (mst_slv_ack_ext == 1'b1) || (mst_slv_ack_ext_r == 1'b1))
      // jduarte 20101004 end
        begin
           ic_data_oe_early <= (arb_lost == 1'b0) ? sda_out_n : 1'b0;
        end
      
      else 
        begin
           ic_data_oe_early <= (arb_lost == 1'b0) ? ic_data_oe_early : 1'b0;
           if(arb_lost == 1'b1) ic_clk_oe <= 1'b0;
        end
   end
   

   // ------------------------------------------------------
   // -- Clk gen control signals
   // ------------------------------------------------------
   assign scl_shld_en_int = st_scl_s_hld_en | re_scl_s_hld_en;
   assign scl_lcnt_en_int = data_scl_lcnt_en | stop_scl_lcnt_en |re_start_scl_lcnt_en;
   
   // ------------------------------------------------------
   // -- tx_fifo data buffer
   //
   // -- This buffer is used to store the last popped data
   // -- from the tx fifo
   // ------------------------------------------------------
   assign mstslv_txfld = ((mst_txfifo_ld_en == 1'b1) 
                          || (slv_txfifo_ld_en == 1'b1)
   );
   always @(posedge ic_clk or negedge ic_rst_n) begin : POP_TX_DATA_BUF_PROC
      if(ic_rst_n == 1'b0) begin
         tx_fifo_data_buf   <= {`IC_DATA_TX_CMD_RS{1'b0}};
      end else begin
           if(mstslv_txfld == 1'b1)
           tx_fifo_data_buf <= tx_pop_data;
      end
   end
  

   // ------------------------------------------------------
   // -- tx_pop output
   //
   //  The tx_pop output is used in the pclk
   //  domain to remove data
   //  from the tx fifo.
   // ------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : POP_TX_PROC
      if(ic_rst_n == 1'b0)
        tx_pop <= 1'b0;
      else
        tx_pop <= ((mst_txfifo_ld_en == 1'b1) 
        || (slv_txfifo_ld_en == 1'b1)
        );

      
   end

   // ------------------------------------------------------
   // -- generate byte_wait_scl  byte level wait state  signal
   //
   // -- Forces the tx_shift proces,re-start and stop to wait 
   // -- for scl to go high befor touching the bus 
   // ------------------------------------------------------
   assign byte_wait_en_int = ((re_start_en == 1'b0) 
                              && (stop_en == 1'b0) 
                              && (start_en == 1'b0));
                                
   assign byte_wait_en     = ((byte_wait_en_int == 1'b1)
                              && ((mst_tx_bwen == 1'b1) || (mst_rx_bwen == 1'b1))  
                              && (scl_int == 1'b0));

   always @(posedge ic_clk or negedge ic_rst_n) begin : HCNT_WAIT_PROC
      if(ic_rst_n == 1'b0) begin
         byte_wait_scl  <= 1'b0;
      end else 
          byte_wait_scl <= byte_wait_en;
   end
    

   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_TX_BWEN_PROC
      if(ic_rst_n == 1'b0) begin
         mst_tx_bwen <= 1'b0;
      end else 
        if (bit1_7_lo == 1'b1)
          mst_tx_bwen <= 1'b0;
      
        else if(bit8_hi ==1'b1)
          mst_tx_bwen <= scl_hcnt_en_int;
   end // block: MST_TX_BWEN
   

   
   // ------------------------------------------------------
   // -- generate start condition
   //
   // -- Set SDA low and wait for tHD,STA and then set SCL low
   // ------------------------------------------------------

   assign start_lo = ((start_en == 1'b1) && (scl_s_hld_cmplt == 1'b0));
   assign start_hld = ((start_en == 1'b1) && (scl_s_hld_cmplt == 1'b1));
   assign no_start_hld = ((start_en == 1'b0)&& (st_scl_s_hld_en == 1'b1));
   assign no_st_no_hld = ((start_en == 1'b0)&& (st_scl_s_hld_en == 1'b0));

   always @(posedge ic_clk or negedge ic_rst_n) begin:GEN_START_PROC
      if(ic_rst_n == 1'b0) 
        begin
          start_sda     <= 1'b1;
          st_scl_s_hld_en  <= 1'b0;
        end else 
             begin
               if(start_lo == 1'b1)
                 begin
                    start_sda     <= 1'b0;
                    st_scl_s_hld_en  <= 1'b1;
                 end
               else if (start_hld == 1'b1)
                 begin
                    start_sda     <= 1'b0;
                    st_scl_s_hld_en  <= 1'b1;
                 end
               else if (no_start_hld == 1'b1)
                 begin
                    start_sda     <= 1'b0;
                    st_scl_s_hld_en  <= 1'b0;
                 end             
               else if (no_st_no_hld == 1'b1)
                 begin
                    start_sda     <= 1'b1;
                    st_scl_s_hld_en  <= 1'b0;
                 end             
             end
   end
   

   // ------------------------------------------------------
   // -- generate re-start condition
   //
   // -- Set SDA low and wait for tHD,STA and then set SCL low
   // ------------------------------------------------------

   assign re_start_cmplt = (scl_s_setup_cmplt == 1'b1) && (scl_s_hld_cmplt == 1'b1);
   assign re_lo_int = ((scl_s_hld_cmplt == 1'b0) && (scl_s_setup_cmplt == 1'b0)&&(mst_tx_cmplt == 1'b0));
   assign re_lo = ((re_lo_int == 1'b1)&&(re_start_en == 1'b1)&&(scl_lcnt_cmplt == 1'b0));
   assign re_hi_int = ((scl_s_hld_cmplt == 1'b0)&&(mst_tx_cmplt == 1'b0));
   assign re_hi = ((re_hi_int == 1'b1)&&(re_start_en == 1'b1)&&(scl_s_setup_cmplt == 1'b0)&&(scl_lcnt_cmplt == 1'b1)&&(scl_hcnt_cmplt == 1'b0));
   assign re_setup_int = ((re_start_en == 1'b1)&&(mst_tx_cmplt == 1'b0) &&(scl_lcnt_cmplt == 1'b1));
   assign re_setup = ((re_setup_int == 1'b1)&& (scl_s_hld_cmplt == 1'b0) && (scl_s_setup_cmplt == 1'b1));
   assign re_hld_int = ((re_start_en == 1'b1) && (scl_s_hld_cmplt == 1'b1));
   assign re_hld = ((re_hld_int == 1'b1) && (scl_s_setup_cmplt == 1'b1)&&(mst_tx_cmplt == 1'b0) &&(scl_lcnt_cmplt == 1'b1));
   
   // ===========================================================
   // Extend re_start_sda by another "ic_clk" period by using
   // a further-registered version (ie., re_start_sda_r) and then
   // using the latter in exactly the same manner as re_start_sda.
   // ===========================================================
   always @(posedge ic_clk or negedge ic_rst_n) begin : GEN_RE_START_R_PROC
     if(ic_rst_n==1'd0)
       re_start_sda_r <= 1'd1;
     else
       re_start_sda_r <= re_start_sda;
   end // always

   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Ensure that the sequential and combinational parts of an FSM description 
   //     should be in separate always blocks.
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   always @(posedge ic_clk or negedge ic_rst_n) begin : GEN_RE_START_PROC
      if(ic_rst_n == 1'b0) begin
             re_start_sda     <= 1'b1;
             re_start_scl     <= 1'b1;
             re_scl_s_hld_en  <= 1'b0;
             scl_s_stp_int   <= 1'b0;
             re_start_scl_lcnt_en <= 1'b0;
      end else        
          begin
             if(re_lo == 1'b1)
               begin
                  re_start_sda <= 1'b1;
                  re_start_scl <= 1'b0;
                  re_start_scl_lcnt_en <= 1'b1;
                  scl_s_stp_int <= 1'b0;
                  re_scl_s_hld_en  <= 1'b0;
               end
             else if(re_hi == 1'b1) 
               begin
                  re_start_sda <= 1'b1;
                  re_start_scl <= 1'b1;
                  re_start_scl_lcnt_en <= 1'b1;
                  re_scl_s_hld_en  <= 1'b0;

               if(scl_s_stp_int == 1'b0) begin//Bit wait state condition
                  scl_s_stp_int <= scl_int;
               end else
                  scl_s_stp_int <= 1'b1;

               end

             else if(re_setup == 1'b1)
               begin
                  re_start_sda <= 1'b0;
                  re_start_scl <= 1'b1;
                  scl_s_stp_int <= 1'b1;
                  re_scl_s_hld_en  <= 1'b1;
                  re_start_scl_lcnt_en <= 1'b1;
               end
             else if (re_hld == 1'b1)
               begin
                  re_start_sda <= 1'b0;
                  re_start_scl <= 1'b1;
                  scl_s_stp_int <= 1'b0;
                  re_scl_s_hld_en  <= 1'b0;
                  re_start_scl_lcnt_en <= 1'b0;
               end

             else if (re_start_en == 1'b0)
                 begin
                    re_start_sda     <= 1'b1;
                    re_start_scl     <= 1'b1;
                    re_scl_s_hld_en      <= 1'b0;
                    scl_s_stp_int       <= 1'b0;
                    re_start_scl_lcnt_en <= 1'b0;
                 end
          end
   end
   //spyglass enable_block STARC05-2.11.3.1
   
   
   // ------------------------------------------------------
   // -- generate stop condition
   //
   // -- Set SDA low and wait for tHD,STA and then set SCL low
   // ------------------------------------------------------
   assign stop_cmplt_int = (scl_p_setup_cmplt == 1'b1) && (scl_lcnt_cmplt == 1'b1);
   assign stop_lo_int = ((scl_p_setup_cmplt == 1'b0) &&(mst_tx_cmplt == 1'b0));
   assign stop_lo = ((stop_lo_int == 1'b1) && (stop_en == 1'b1) && (scl_lcnt_cmplt == 1'b0));
   assign stop_hi = ((stop_en == 1'b1) && (scl_p_setup_cmplt == 1'b0) && (scl_lcnt_cmplt == 1'b1)&&(mst_tx_cmplt == 1'b0));
   assign stop_setup_int = (mst_tx_cmplt == 1'b0);
   assign stop_setup = ((stop_setup_int == 1'b1) && (stop_en == 1'b1) && (scl_p_setup_cmplt == 1'b1));
   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Ensure that the sequential and combinational parts of an FSM description 
   //     should be in separate always blocks.
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   always @(posedge ic_clk or negedge ic_rst_n) begin : GEN_STOP_PROC
      if(ic_rst_n == 1'b0) begin
             stop_sda     <= 1'b1;
             stop_scl     <= 1'b1;
             scl_p_stp_int  <= 1'b0;
             stop_scl_lcnt_en <= 1'b0;
      end else        
          begin
             if (stop_lo == 1'b1)
               begin
                  stop_scl_lcnt_en <= 1'b1;
                  stop_sda <= 1'b0;
                  stop_scl <= 1'b0;
                  scl_p_stp_int  <= 1'b0;
               end
             else if (stop_hi == 1'b1)
               begin
                  stop_scl_lcnt_en <= 1'b1;
                  stop_sda <= 1'b0;
                  stop_scl <= 1'b1;

                 if(scl_p_stp_int == 1'b0) begin//Bit wait state condition
                    scl_p_stp_int <= scl_int;
                 end else
                    scl_p_stp_int <= 1'b1;
               end
             else if (stop_setup == 1'b1)
               begin
                  stop_scl_lcnt_en <= 1'b1;
                  stop_sda <= 1'b1;
                  stop_scl <= 1'b1;
                  scl_p_stp_int  <= 1'b1;
               end
             else if (stop_en == 1'b0)
               begin
                 stop_sda     <= 1'b1;
                 stop_scl     <= 1'b1;
                 scl_p_stp_int  <= 1'b0;
                 stop_scl_lcnt_en <= 1'b0;
               end
            end
      end
   //spyglass enable_block STARC05-2.11.3.1


   // ------------------------------------------------------
   // -- generate ack signal
   //
   // -- Set SDA low and wait for tHD,STA and then set SCL low
   // ------------------------------------------------------

    assign ack_load = (((mst_gen_ack_en == 1'b1) && (mst_rx_ack_vld == 1'b1))
                        || ((slv_rx_ack_vld == 1'b1) && (slv_gen_ack_en == 1'b1)));
   assign ack_sda = ~ack_load;
   
   // ------------------------------------------------------
   // -- tx shift register data load
   //
   // -- The size of a data transfer is always 8 
   // -- bits.  
   // ------------------------------------------------------
   assign tx_no_capture = ((mst_tx_en == 1'b1) && (tx_data_capture == 1'b1));
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_SHIFT_BUF_PROC
      if(ic_rst_n == 1'b0) begin
         tx_shift_buf <= {`IC_DATA_RS{1'b0}};
         tx_data_capture <= 1'b0;
         
      end else begin
         tx_data_capture <= mst_tx_en;
         if(tx_no_capture == 1'b1)
           tx_shift_buf <= mst_tx_data_buf_in;
      end
   end


   // ------------------------------------------------------
   // -- master tx shift process
   //
   // -- The size of a data transfer is always 8 
   // -- bits.  
   // ------------------------------------------------------

   assign mst_tx_cmplt = (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt ==1'b1) 
                             && (mst_tx_ack_int == 1'b1)
                          ;
   
   assign start_tx = ((mst_tx_en == 1'b1)  && (tx_data_capture == 1'b1));
   assign bit1_7_lo = ((tx_bit_count < 8) && (scl_lcnt_cmplt == 1'b0) && (scl_hcnt_cmplt == 1'b0));
   assign bit1_7_hi = ((tx_bit_count < 8) && (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt == 1'b0));
   assign bit1_7_end_int = ((scl_lcnt_cmplt == 1'b1) && (data_scl_lcnt_en == 1'b1) && (scl_hcnt_en_int == 1'b1));
   assign bit1_7_end = ((bit1_7_end_int == 1'b1) && (tx_bit_count < 8) && (scl_hcnt_cmplt == 1'b1));
   assign bit8_lo = ((tx_bit_count == 8) && (scl_lcnt_cmplt == 1'b0) && (scl_hcnt_cmplt == 1'b0));
   assign bit8_hi = ((tx_bit_count == 8) && (scl_lcnt_cmplt == 1'b1) && (scl_hcnt_cmplt == 1'b0));
   assign bit8_end_int = ((scl_lcnt_cmplt == 1'b1) && (data_scl_lcnt_en == 1'b1) && (scl_hcnt_en_int == 1'b1));
   assign bit8_end = ((bit8_end_int == 1'b1) &&( tx_bit_count == 8)  && (scl_hcnt_cmplt == 1'b1));

   assign hs_no_mcode = ((ic_hs_sync == 1'b1) && (hs_mcode_en == 1'b0));


   /* ------------------------------------------------------------------
    * IMPLEMENT SDA TRANSMIT HOLD TIME
    *
    * - As a Master
    *   When the internally generated SCL goes high (pulling external 
    *   SCL low), count up to programmed hold time before allowing SDA
    *   to change.
    *
    * - As a Slave.
    *   When the externally generated SCL goes high (pulling external 
    *   SCL low), count up to programmed hold time before allowing SDA
    *   to change.
    * 
    *   Different SDA signals (data_sda , start_sda) are treated 
    *   seperately because the scenario where the previous value is
    *   captured is different for each.
    *
    */

   // jduarte 20101004 begin
   // CRM 9000423043
   // Had to move declaration of sda_hold_done higher because it is
   // now used in other preceding processes
   // reg sda_hold_done; // Asserted when sda hold time finished.
   // jduarte 20101004 end

   reg [`IC_SDA_TX_HOLD_RS-1:0] sda_hold_count_r; // Sda hold time counter.
   wire [`IC_SDA_TX_HOLD_RS-1:0] ic_sda_hold_local;
   wire [`IC_SDA_TX_HOLD_RS-1:0] ic_sda_tx_hold_sync_int;

   // 1-bit longer than ic_spklen, to cover max values.
   wire [`IC_SPKLEN_RS:0] spklen_plus_ltncy;

   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression present in the design.
   //SJ:  This Self Determined Expression is as per the design requirement. 
   //     There will not be any functional issue.
   // 2 cycles for meta flops on input signals
   // 2 cycles from sda_out_n to ic_data_oe
   assign spklen_plus_ltncy = 
           (9'h4+{1'h0,ic_spklen});

   assign ic_sda_tx_hold_sync_int = ic_sda_tx_hold_sync;
   //spyglass enable_block SelfDeterminedExpr-ML

   //spyglass disable_block W484
   //SMD: Possible loss of carry or borrow in addition or subtraction (Verilog)
   //SJ:  This implmentation is as per the design requirement. There is no chance 
   //     of carry/borrow overflow. There will not be any functional issue.
   // Alter the actual count time to take account of internal latencies.
   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression present in the design.
   //SJ:  This Self Determined Expression is as per the design requirement. 
   //     There will not be any functional issue.
   assign ic_sda_hold_local
     = ic_master_sync
       ? (ic_sda_tx_hold_sync >= 16'h3)
         // Subtract 2 to take account of the 2 registers after
         // sda_out_n before ic_data_oe.
         ? (ic_sda_tx_hold_sync - 16'h2)
         : ic_sda_tx_hold_sync
         // Only subtract when the result will not be negative/wrapped around.
       : (ic_sda_tx_hold_sync >= ({{(`IC_SDA_TX_HOLD_RS-`IC_SPKLEN_RS-1){1'b0}},spklen_plus_ltncy}
                                  +{{(`IC_SDA_TX_HOLD_RS-1){1'b0}},1'b1}
                                  ))
         // * jstokes, 30.3.11, STAR 9000368180
         //   Configurable spike supression added. Programmed spike
         //   suppression length is subtraced from SDA hold time count
         //   when operating as a slave, because SCL will not arrive here
         //   until after the spike suppression filtering.
         //
         // Reduce the implemented hold time by the latency already
         // present in sampling SCL (meta stability + spike suppression)
         // and returning SDA from this point ic_data_oe.
         ? (ic_sda_tx_hold_sync - {{(`IC_SDA_TX_HOLD_RS-`IC_SPKLEN_RS-1){1'b0}},spklen_plus_ltncy})
         : ic_sda_tx_hold_sync_int;
   //spyglass enable_block SelfDeterminedExpr-ML
   //spyglass enable_block W484



   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : sda_hold_count_r_PROC
     if(~ic_rst_n) begin
       sda_hold_count_r <= {`IC_SDA_TX_HOLD_RS{1'b0}};
     end else begin
       if(  (ic_clk_oe & ic_master_sync) 
            // In slave mode use external SCL.
          | (~scl_int & (~ic_master_sync))
         ) begin
         // Don't wrap around to 0, want to hold sda_hold_done
         // until ic_clk_oe == 0.
         if(sda_hold_count_r < ic_sda_hold_local) begin
           sda_hold_count_r <= sda_hold_count_r + 1;
         end
       end else begin
         sda_hold_count_r <= {`IC_SDA_TX_HOLD_RS{1'b0}};
       end
     end
   end // sda_hold_count_r_PROC
    
  
   always @(*) begin : sda_hold_done_PROC
     sda_hold_done = 1'b0;

     case(ic_sda_tx_hold_sync) 
       // Implementing a hold time of 1 (min. possible in master mode)
       // requires no work at all.
       {{(`IC_SDA_TX_HOLD_RS-1){1'b0}},1'b1} : begin
         sda_hold_done = 1'b1;
       end
       // Implementing a hold time of 2 requires waiting until ic_clk_oe
       // is 1.
       {{(`IC_SDA_TX_HOLD_RS-2){1'b0}},2'b10} : begin
         sda_hold_done = ic_master_sync ? ic_clk_oe : ~scl_int;
       end
       // All other hold times require counter value.
       default : begin
         sda_hold_done = (sda_hold_count_r >= ic_sda_hold_local);
       end
     endcase 

   end // sda_hold_done_PROC

   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : data_sda_prev_r_PROC
     if(ic_rst_n == 1'b0) begin
       data_sda_prev_r <= 1'b1;
     end else begin
       if(sda_hold_done) begin
         data_sda_prev_r <= data_sda 
               & slv_data_sda & ack_sda
               ;
       end
     end 
   end // data_sda_prev_r_PROC

   // Select the previous SDA until internal SCL has gone low.
   assign data_sda_gated = sda_hold_done ? data_sda : data_sda_prev_r;
   assign slv_data_sda_gated = sda_hold_done ? slv_data_sda : data_sda_prev_r;

   // Send previous data bit until SCL is low, when SCL goes high
   // data_sda_prev_r will have captured the value of the ACK while SCL was
   // low. When previous data was not being sent from here, data_sda_prev_r
   // will be 1, and it will be up to the sending device to 
   // implement SDA hold time.
   assign ack_sda_gated = sda_hold_done
                          ? ack_sda 
                          : data_sda_prev_r;

   // Gate start_sda as soon as is is low while scl_int == 1.                          
   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : start_sda_gate_r_PROC
     if(ic_rst_n == 1'b0) begin
       start_sda_gate_r <= 1'b0;
     end else begin
       if(~start_sda_gate_r) begin
         start_sda_gate_r <= ~ic_clk_oe & (~start_sda | (~re_start_sda) | (~re_start_sda_r));
       end else begin
         start_sda_gate_r <= ~sda_hold_done;
       end
     end
   end // start_sda_gate_r_PROC


   // Stop gating (holding at 1'b0) start_sda in the same cycle that
   // scl_int goes low. Also for restart signals.
   assign start_sda_gated = (start_sda_gate_r & (~sda_hold_done)) ? 1'b0 : start_sda;
   assign re_start_sda_gated = (start_sda_gate_r & (~sda_hold_done)) ? 1'b0 : re_start_sda;
   assign re_start_sda_r_gated = (start_sda_gate_r & (~sda_hold_done)) ? 1'b0 : re_start_sda_r;


   // Gate stop_sda by default. Stop gating when stop_sda=0 and the
   // sda hold count is complete. Once stop_sda goes to 1, allow
   // stop_sda_gated to transition to 1 also.
   reg stop_sda_gate_r;
   always @(posedge ic_clk or negedge ic_rst_n) 
   begin : stop_sda_gate_r_PROC
     if(ic_rst_n == 1'b0) begin
       stop_sda_gate_r <= 1'b1;
     end else begin
       if(stop_sda_gate_r) begin
         //stop_sda_gate_r <= scl_int | stop_sda;
         stop_sda_gate_r <= ~sda_hold_done | stop_sda;
       end else begin
         stop_sda_gate_r <= stop_sda;
       end
     end
   end // stop_sda_gate_r_PROC

   // During the gating period, hold at 1. Gating period stops immediately
   // when scl_int goes low.
   assign stop_sda_gated = (stop_sda_gate_r & (~sda_hold_done)) ? 1'b1 : stop_sda;


   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression present in the design.
   //SJ:  This Self Determined Expression is as per the design requirement. 
   //     There will not be any functional issue.
   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Ensure that the sequential and combinational parts of an FSM description 
   //     should be in separate always blocks.
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   always @(posedge ic_clk or negedge ic_rst_n) begin : MST_TX_SHIFT_PROC
      if(ic_rst_n == 1'b0) begin
         tx_bit_count <= 4'b0000;
         mst_tx_ack_int <= 1'b0;
// jduarte 20101108 begin
// CRM 9000424562
//         tx_current_src_en <= 1'b0;
// jduarte 20101108 end         
         data_sda <= 1'b1;
         data_scl <= 1'b1;
         data_scl_lcnt_en <= 1'b0;
         scl_hcnt_en_int <= 1'b0;
      end else if(start_tx == 1'b1) 
        begin
           
           if (bit1_7_lo == 1'b1)
             begin
// jduarte 20101108 begin
// CRM 9000424562
//                if ((ic_hs_sync == 1'b1) && (hs_mcode_en == 1'b0) && (tx_bit_count !=4'b0000)) 
//                      tx_current_src_en <= 1'b1;
// jduarte 20101108 end
                data_sda <= tx_shift_buf[`IC_DATA_RS - 1 - tx_bit_count];
                data_scl <= 1'b0;
                if(ack_load == 1'b0)
                      begin
                         data_scl_lcnt_en <= 1'b1;
                      end
                
                scl_hcnt_en_int <= 1'b0;
              end
           
           else if(bit1_7_hi == 1'b1)
             begin
                data_scl <= 1'b1;
                data_scl_lcnt_en <= 1'b1;
                if(scl_hcnt_en_int == 1'b0) //Bit wait state condition
                  scl_hcnt_en_int <= scl_int;
                else
                  scl_hcnt_en_int <= 1'b1;
             end
           else if(bit1_7_end == 1'b1)
           begin
              tx_bit_count <= tx_bit_count + {3'h0,1'b1};
              data_scl_lcnt_en <= 1'b0;
              scl_hcnt_en_int <= 1'b0;
           end
         
           else if(bit8_lo ==1'b1)
             begin
                mst_tx_ack_int <= 1'b1;
              
                data_sda <= 1'b1;//Keep SDA float for ack pulse
                data_scl <= 1'b0;
                data_scl_lcnt_en <= 1'b1;
                scl_hcnt_en_int <= 1'b0;
             end
           
           else if(bit8_hi ==1'b1)
             begin
                mst_tx_ack_int <= 1'b1;
              
                data_sda <= 1'b1;//Keep SDA float for ack pulse
                data_scl <= 1'b1;
                data_scl_lcnt_en <= 1'b1;

                if(scl_hcnt_en_int == 1'b0)//Bit wait state condition
                     scl_hcnt_en_int <= scl_int;
                else
                  scl_hcnt_en_int <= 1'b1;

             end
           
           else if(bit8_end ==1'b1)
           begin
              tx_bit_count <= 4'b0000;
              mst_tx_ack_int <= 1'b1;
              data_sda <= 1'b1;
              data_scl <= 1'b1;
              data_scl_lcnt_en <= 1'b0;
              scl_hcnt_en_int <= 1'b0;
           end
           
        end // if ((mst_tx_en == 1'b1)  && (tx_data_capture == 1'b1))
      else if(mst_tx_en == 1'b0)
        begin
           tx_bit_count <= 4'b0000;
           mst_tx_ack_int <= 1'b0;
// jduarte 20101108 begin
// CRM 9000424562
//           tx_current_src_en <= 1'b0;
// jduarte 20101108 end
           data_sda <= 1'b1;
           data_scl <= 1'b1;
           data_scl_lcnt_en <= 1'b0;
           scl_hcnt_en_int <= 1'b0;
        end
      
   end // block: TX_SHIFT_PROC
   //spyglass enable_block STARC05-2.11.3.1
   //spyglass enable_block SelfDeterminedExpr-ML


// jduarte 20101108 begin
// CRM 9000424562
   always @(posedge ic_clk or negedge ic_rst_n) begin : IC_CLOCK_IN_R_PROC  
       if(ic_rst_n == 1'b0) begin
           scl_int_r <= 1'b1;
       end else begin
           scl_int_r <= scl_int;
       end
   end
      
   assign scl_int_ed = scl_int && (~scl_int_r);
   
   always @(posedge ic_clk or negedge ic_rst_n) begin : TX_CURRENT_SRC_EN_PROC
       if(ic_rst_n == 1'b0) begin
            tx_current_src_en <= 1'b0;
       end else begin
            if(((tx_bit_count == 0) && bit1_7_lo) || (~hs_no_mcode)) begin
                tx_current_src_en <= 1'b0;
            end else if((tx_bit_count == 0) && scl_int_ed) begin
                tx_current_src_en <= 1'b1;
            end
       end
   end
// jduarte 20101108 end
   
   // ------------------------------------------------------
   // -- slave tx shift process
   //
   // -- The size of a data transfer is always 8 
   // -- bits.  
   // ------------------------------------------------------
   assign slv_bit1_7 = ((slv_tx_bit_count > 4'b0000) && (slv_tx_bit_count < 4'b1000) );
   assign slv_inc_cnt = ((slv_tx_bit_count < 8) && (slv_tx_shift_en == 1'b1));
   

   always @(posedge ic_clk or negedge ic_rst_n) begin : SLV_TX_SHIFT_PROC
      if(ic_rst_n == 1'b0) begin
         slv_tx_bit_count <= 4'b0000;
         slv_data_sda <= 1'b1;
         slv_tx_ack_vld <= 1'b0;
         slv_tx_ready <= 1'b0;
         slv_tx_ready_dly1 <= 1'b0;
         slv_tx_ready_dly2 <= 1'b0;
         slv_tx_cmplt <= 1'b0;
      end else if (slv_tx_en == 1'b1)
        begin
           slv_tx_ready <= slv_tx_ready_dly2;
           slv_tx_ready_dly2 <= slv_tx_ready_dly1;

   /*
           if(slv_bit1_7 == 1'b1)
`ifndef IC_ULTRA_FAST_MODE_EN
`ifndef IC_CLK_FREQ_OPTIMIZATION_EN
             slv_data_sda <= tx_fifo_data_buf[`IC_DATA_RS - 1 - slv_tx_bit_count];
`endif
`endif

           slv_tx_ready <= slv_tx_ready_dly2;
           slv_tx_ready_dly2 <= slv_tx_ready_dly1;
    */
           
           if(slv_tx_ready_dly1 == 1'b0)
             begin
                slv_data_sda <= tx_fifo_data_buf[`IC_DATA_RS - 1];
                slv_tx_ready_dly1 <= 1'b1;
             end
           else if (slv_tx_ready == 1'b0)
             slv_tx_ready_dly1 <= 1'b1;
           
           else if (slv_inc_cnt == 1'b1)
             begin
                slv_tx_bit_count <= slv_tx_bit_count + {3'h0,1'b1};
             end
           
           else if(slv_tx_bit_count == 8)
             begin
                slv_data_sda <= 1'b1;//Keep SDA float for ack pulse
                slv_tx_ack_vld <= 1'b1;
                slv_tx_cmplt <= scl_edg_hl;
             end
           
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression present in the design.
    //SJ:  This Self Determined Expression is as per the design requirement. 
    //     There will not be any functional issue.
    // FM_1_7, signal assigned more than once in a single
    // flow.
    else if(slv_bit1_7 == 1'b1)
      begin
               slv_data_sda <= tx_fifo_data_buf[`IC_DATA_RS - 1 - slv_tx_bit_count];
      end
    //spyglass enable_block SelfDeterminedExpr-ML

        end // if (slv_tx_en == 1'b1)
      
      else if(slv_tx_en == 1'b0)
        begin
           slv_tx_bit_count <= 4'b0000;
           slv_data_sda <= 1'b1;
           slv_tx_ack_vld <= 1'b0;
           slv_tx_ready <= 1'b0;
           slv_tx_ready_dly1 <= 1'b0;
           slv_tx_ready_dly2 <= 1'b0;
           slv_tx_cmplt <= 1'b0;
           end
      
   end // block: SLV_TX_SHIFT_PROC
   


endmodule // DW_apb_i2c_tx_shift

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm_params.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm_params.v#5 $
// Author      : Build Meister - 12/09/08
// Description : DW_apb_i2c_bcm_params.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: bc7c479f
//
////////////////////////////////////////////////////////////////////////////////

 // Existence parameter definitions for BCM modules


`define RM_BCM01 0


`define RM_BCM02 0


`define RM_BCM03 0


`define RM_BCM05 0


`define RM_BCM05_ATV 0


`define RM_BCM06 0


`define RM_BCM06_ATV 0


`define RM_BCM07 0


`define RM_BCM07_ATV 0


`define RM_BCM08 0


`define RM_BCM09 0


`define RM_BCM09_DP 0


`define RM_BCM09_ECC 0


`define RM_BCM10 0


`define RM_BCM11 0


`define RM_BCM12 0


`define RM_BCM15 0


`define RM_BCM16 0


`define RM_BCM21 0


`define RM_BCM21_A 0


`define RM_BCM21_ATV 0


`define RM_BCM21_CG 0


`define RM_BCM22 0


`define RM_BCM22_ATV 0


`define RM_BCM23 0


`define RM_BCM23_ATV 0


`define RM_BCM24 0


`define RM_BCM24_AP 0


`define RM_BCM25 0


`define RM_BCM25_ATV 0


`define RM_BCM26 0


`define RM_BCM27 0


`define RM_BCM28 0


`define RM_BCM29 0


`define RM_BCM30 0


`define RM_BCM31 0


`define RM_BCM32 0


`define RM_BCM35 0


`define RM_BCM36 0


`define RM_BCM36_NHS 0


`define RM_BCM37 0


`define RM_BCM38 0


`define RM_BCM38_ADP 0


`define RM_BCM38_AP 0


`define RM_BCM38_ECC 0


`define RM_BCM39 0


`define RM_BCM40 0


`define RM_BCM41 0


`define RM_BCM42 0


`define RM_BCM43 0


`define RM_BCM43_NRO 0


`define RM_BCM44 0


`define RM_BCM44_NRO 0


`define RM_BCM46_A 0


`define RM_BCM46_AA 0


`define RM_BCM46_B 0


`define RM_BCM46_C 0


`define RM_BCM46_D 0


`define RM_BCM46_E 0


`define RM_BCM47 0


`define RM_BCM48 0


`define RM_BCM48_DM 0


`define RM_BCM48_SV 0


`define RM_BCM49 0


`define RM_BCM49_SV 0


`define RM_BCM50 0


`define RM_BCM51 0


`define RM_BCM52 0


`define RM_BCM53 0


`define RM_BCM54 0


`define RM_BCM55 0


`define RM_BCM56 0


`define RM_BCM57 0


`define RM_BCM58 0


`define RM_BCM59 0


`define RM_BCM60 0


`define RM_BCM62 0


`define RM_BCM63 0


`define RM_BCM64 0


`define RM_BCM64_TD 0


`define RM_BCM65 0


`define RM_BCM65_ATV 0


`define RM_BCM65_TD 0


`define RM_BCM66 0


`define RM_BCM71 0


`define RM_BCM72 0


`define RM_BCM73 0


`define RM_BCM74 0


`define RM_BCM76 0


`define RM_BCM85 0


`define RM_BCM86 0


`define RM_BCM87 0


`define RM_BCM90 0


`define RM_BCM95 0


`define RM_BCM95_E 0


`define RM_BCM95_I 0


`define RM_BCM95_IE 0


`define RM_BCM98 0


`define RM_BCM99 0


`define RM_BCM99_N 0


`define RM_BVM01 0


`define RM_BVM02 1


`define RM_SVA01 0


`define RM_SVA02 0


`define RM_SVA03 0


`define RM_SVA04 0


`define RM_SVA05 0


`define RM_SVA06 0


`define RM_SVA07 0


`define RM_SVA99 0

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm41.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm41.v#5 $
// Author      : Rick Kelly         8/28/12
// Description : DW_apb_i2c_bcm41.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: ea00bd45
//
////////////////////////////////////////////////////////////////////////////////


module DW_apb_i2c_bcm41 (
    clk_d,
    rst_d_n,
    data_s,
    data_d
    );

parameter WIDTH        = 1;  // RANGE 1 to 1024
parameter RST_VAL      = -1; // RANGE -1 to 2147483647
parameter F_SYNC_TYPE  = 2;  // RANGE 0 to 4
parameter VERIF_EN     = 1;  // RANGE 0 to 5
parameter SVA_TYPE     = 1;  // RANGE 0 to 2

// spyglass disable_block ParamWidthMismatch-ML
// SMD: Parameter width does not match with the value assigned
// SJ: The legal value of RHS parameter cannot exceed the range that the LHS parameter can represent.  Even though there is a width mismatch, no information is lost in the assignment.
// spyglass disable_block W163
// SMD: Truncation of bits in constant integer conversion
// SJ: In some case, sized local parameters are used to convert to the needed vector widths internally.  This may truncate bits of integers on the RHS which is intentional.
localparam [WIDTH-1 : 0] RST_POLARITY = RST_VAL;
// spyglass enable_block ParamWidthMismatch-ML
// spyglass enable_block W163

input                   clk_d;      // clock input from destination domain
input                   rst_d_n;    // active low asynchronous reset from destination domain
input  [WIDTH-1:0]      data_s;     // data to be synchronized from source domain
output [WIDTH-1:0]      data_d;     // data synchronized to destination domain

wire   [WIDTH-1:0]      data_s_int;
wire   [WIDTH-1:0]      data_d_int;

  assign data_s_int = data_s ^ RST_POLARITY;

// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The integer value of a parameter, that starts in the range of 0-4, is incremented by 8 through design hierarchy.  The depth of the hierarchy never reaches levels that cause the parameter value to exceed the bounds of a 32-bit integer.
  DW_apb_i2c_bcm21
   #(WIDTH, F_SYNC_TYPE+8, VERIF_EN, SVA_TYPE) U_SYNC (
// spyglass enable_block SelfDeterminedExpr-ML
      .clk_d(clk_d),
      .rst_d_n(rst_d_n),
      .data_s(data_s_int),
      .data_d(data_d_int)
      );

  assign data_d = data_d_int ^ RST_POLARITY;

endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #52 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_cc_constants.v#52 $ 
//


// Name:         SLAVE_INTERFACE_TYPE
// Default:      APB2
// Values:       APB2 (0), APB3 (1), APB4 (2)
// Enabled:      [<functionof> %item]
// 
// Select Register Interface type as APB2, APB3 or APB4. 
// By default, DW_apb_i2c supports APB2 interface.
`define SLAVE_INTERFACE_TYPE 1


// Name:         SLVERR_RESP_EN
// Default:      false
// Values:       false (0), true (1)
// Enabled:      SLAVE_INTERFACE_TYPE>0
// 
// Enable Slave Error response signaling:The component will refrain 
// From signaling an error response if this parameter is disabled.
`define SLVERR_RESP_EN 1

//APB Interface has APB3 signals

`define IC_HAS_APB3_IF_SIGNALS

//APB Interface has APB4 signals

// `define IC_HAS_APB4_IF_SIGNALS

//Component has slave error response enabled

`define IC_HAS_SLVERR_RESP_EN


// Name:         IC_ULTRA_FAST_MODE
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      [<functionof> %item]
// 
// This parameter is used to control whether DW_apb_i2c supports Ultra-Fast speed mode or not. 
//  
// If this Parameter is enabled, the Master 
//  - Disables the Arbitration, clock synchronization features. 
//  - Support only write transfers. 
//  - Does not check the validity of ACK/NACK for each byte. 
// The Slave  
//  - Supports only write transfers. 
//  - Disables the logic to generate ACK/NACK after the end of each byte. 
//  - Disables the logic to stretch the clock if RX-FIFO is full.
`define IC_ULTRA_FAST_MODE 1'h0

//Internal Define for Ic CLK Frequency optimization

// `define IC_ULTRA_FAST_MODE_EN


// Name:         IC_CLK_FREQ_OPTIMIZATION
// Default:      false (IC_ULTRA_FAST_MODE == 1 ? 1 : 0)
// Values:       false (0x0), true (0x1)
// Enabled:      ([<functionof> %item]) && (IC_ULTRA_FAST_MODE ==0)
// 
// This parameter is used to reduce the system clock frequency (ic_clk)  
// by reducing the internal latency required to generate the high period  
// and low period of the SCL line.
`define IC_CLK_FREQ_OPTIMIZATION 1'h0

//Internal Define for Ic CLK Frequency optimization

// `define IC_CLK_FREQ_OPTIMIZATION_EN


// Name:         IC_SMBUS
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      ([<functionof> %item]) && (IC_ULTRA_FAST_MODE ==0)
// 
// Controls whether DW_apb_i2c Master/Slave supports SMBus mode. 
// If checked, the DW_apb_i2c includes the SMBus mode related registers, real-time checks,  
// timeout interrupts, and SMBus optional signals. 
//  
// Note: If this parameter is selected (1), then the user can set the parameter 
// IC_MAX_SPEED_MODE to Standard mode(1) or Fast Mode/Fast Mode Plus (2).
`define IC_SMBUS 1'h0

//Lower limit of number of clocks used for high count
//
//

`define IC_HCNT_LO_LIMIT 16'h6

//Lower limit of number of clocks used for low count

`define IC_LCNT_LO_LIMIT 16'h8


// Name:         IC_ADD_ENCODED_PARAMS
// Default:      true
// Values:       false (0x0), true (0x1)
// 
// Adding the encoded parameters gives firmware an easy and quick  
// way of identifying the DesignWare component within an I/O memory  
// map. Some critical design-time options determine how a driver  
// should interact with the peripheral. There is a minimal area  
// overhead by including these parameters. Allows a single driver  
// to be developed for each component which will be self-configurable. 
//  
// When bit 7 of the IC_COMP_PARAM_1 is read and contains a '1'  
// the encoded parameters can be read via software. If this bit  
// is a '0' then the entire register is '0' regardless of the  
// setting of any of the other parameters that are encoded in  
// the register's bits.  For details about this register, 
// see the IC_COMP_PARAM_1 register. 
//  
// Note: Unique drivers must be developed for each configuration of the 
// DW_apb_i2c. Based on the configuration, the registers in the IP can differ;  
// thus the same driver cannot be used with different configurations of the IP.
`define IC_ADD_ENCODED_PARAMS 1'h1


// Name:         APB_DATA_WIDTH
// Default:      8
// Values:       8 16 32
// 
// Width of the APB data bus.
`define APB_DATA_WIDTH 32

//Internal Define for APB Data Width 8

// `define APB_DATA_WIDTH_8

//Internal Define for APB Data Width != 8

`define APB_DATA_WIDTH_NOT_8

//Internal Define for APB Data Width 16

// `define APB_DATA_WIDTH_16

//Internal Define for APB Data Width 32

`define APB_DATA_WIDTH_32


// Name:         IC_MAX_SPEED_MODE
// Default:      High Speed Mode ((IC_ULTRA_FAST_MODE ==1)? 1 : (IC_SMBUS == 1 ? 2 : 
//               3))
// Values:       Standard Mode (0x1), Fast Mode or Fast Mode Plus (0x2), High Speed 
//               Mode (0x3)
// Enabled:      IC_ULTRA_FAST_MODE == 0
// 
// Maximum I2C mode supported. 
// Controls the reset value of the SPEED bit field [2:1] of the I2C Control Register (IC_CON). 
// Count registers are used to generate the outgoing clock SCL on the I2C interface.  
// For speed modes faster than the configured maximum speed mode, the corresponding 
// registers are not present in the top-level RTL. 
//  
// For unsupported speed modes those registers are not present as described below. 
//  - If this parameter is set to "Standard Mode" then the IC_FS_SCL_*, IC_HS_MADDR, and IC_HS_SCL_* registers are not 
//  present. 
//  - If this parameter is set to "Fast Mode" then the IC_HS_MADDR, and IC_HS_SCL_* registers are not present.
`define IC_MAX_SPEED_MODE 2'h3


// Name:         IC_10BITADDR_MASTER
// Default:      true (IC_SMBUS == 1 ? 0 : 1)
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c supports 7 or 10 bit addressing on the I2C  
// interface after reset when acting as a master.  
// Controls reset value of part of Register IC_CON.  
// Master generated transfers will use this number of address bits. Additionally, it  
// can be reprogrammed by software by writing to the IC_CON register.
`define IC_10BITADDR_MASTER 1'h1


// Name:         IC_RESTART_EN
// Default:      true
// Values:       false (0x0), true (0x1)
// 
// Controls the reset value of bit 5 (IC_RESTART_EN) in the 
// IC_CON register. By default, this parameter is checked, which allows 
// RESTART conditions to be sent when DW_apb_i2c is acting as a master. 
// Some older slaves do not support handling RESTART conditions; however, 
// RESTART conditions are used in several I2C operations. When the RESTART 
// is disabled, the DW_apb_i2c master is incapable of performing the following 
// functions: 
//  - Sending a START BYTE 
//  - Performing any high-speed mode operation 
//  - Performing direction changes in combined format mode 
//  - Performing a read operation with a 10-bit address
`define IC_RESTART_EN 1'h1


// Name:         IC_10BITADDR_SLAVE
// Default:      true (IC_SMBUS == 1 ? 0 : 1)
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c slave supports 7 or 10 bit addressing on the I2C  
// interface after reset when acting as a slave.   
// Controls reset value of part of Register IC_CON.  
// The DW_apb_i2c module will respond to this number of address bits when 
// acting as a slave; it can be reprogrammed by software.
`define IC_10BITADDR_SLAVE 1'h1



// Name:         IC_MASTER_MODE
// Default:      true
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c has its master enabled to be a master after reset.  
// This parameter controls the reset value of bit 0 of the I2C Control  
// Register (IC_CON). To enable the component to be a master, you must  
// write a 1 in bit 0 of the IC_CON register.  
//  
// Note: If this parameter is checked (1), then you must ensure that the  
// parameter IC_SLAVE_DISABLE is checked (1) as well.
`define IC_MASTER_MODE 1'h1


// Name:         IC_SLAVE_DISABLE
// Default:      true
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c has its slave enabled or disabled after reset. 
// If checked, the DW_apb_i2c slave interface is disabled after reset. 
// The slave also can be disabled by programming a 1 into IC_CON[6]. 
// By default the slave is enabled. 
//  
// Note: If this parameter is unchecked (0), then you must ensure that the 
// parameter IC_MASTER_MODE is unchecked (0) as well.
`define IC_SLAVE_DISABLE 1'h1

//A user is not allowed to assign any reserved addresses 
//or have the lower seven bits the same as a reserved 
//address.

// Name:         IC_DEFAULT_SLAVE_ADDR
// Default:      0x055
// Values:       0x000, ..., 0x3ff
// 
// Reset Value of DW_apb_i2c Slave Address.  
// Controls the reset value of Register (IC_SAR).  
// The default values cannot be any of the reserved  
// address locations: 0x00 to 0x07 or 0x78 to 0x7f.
`define IC_DEFAULT_SLAVE_ADDR 10'h033

//A user is not allowed assign any reserved addresses or have the lower 
//seven bits the same as a reserved address.

// Name:         IC_DEFAULT_TAR_SLAVE_ADDR
// Default:      0x055
// Values:       0x000, ..., 0x3ff
// 
// Reset value of DW_apb_i2c target slave address. Controls the reset value  
// of the IC_TAR bit field (9:0) of the I2C Target Address Register (IC_TAR).  
// The default values cannot be any of the reserved address locations: 
// 0x00 to 0x07 or 0x78 to 0x7f.
`define IC_DEFAULT_TAR_SLAVE_ADDR 10'h033


// Name:         IC_HS_MASTER_CODE
// Default:      0x1
// Values:       0x0, ..., 0x7
// Enabled:      (IC_MAX_SPEED_MODE == 3) && (IC_ULTRA_FAST_MODE ==0)
// 
// High Speed mode master code of the DW_apb_i2c block. 
// Controls the reset value of I2C HS Master Mode Code Address Register (IC_HS_MADDR). 
// This is a unique code that alerts other masters on the I2C  
// bus that a high-speed mode transfer is going to begin. For more information 
// about this code, refer to "Multiple Master Arbitration" section in data 
// book.
`define IC_HS_MASTER_CODE 3'h1


// Name:         IC_TX_BUFFER_DEPTH
// Default:      8
// Values:       2, ..., 256
// 
// Depth of transmit buffer. The buffer is 9 bits wide; 
// 8 bits for the data, and 1 bit for the read or write command.
`define IC_TX_BUFFER_DEPTH 8


// Name:         IC_RX_BUFFER_DEPTH
// Default:      8
// Values:       2, ..., 256
// 
// Depth of receive buffer, the buffer is 8 bits wide.
`define IC_RX_BUFFER_DEPTH 8

//Receive data width of FIFO

`define RX_ABW 3


`define RX_ABW_P1 4

//Write data width of FIFO

`define TX_ABW 3


`define TX_ABW_P1 4


// Name:         IC_INTR_POL
// Default:      true
// Values:       false (0x0), true (0x1)
// 
// Configures the active level of the output interrupt lines.
`define IC_INTR_POL 1'h1


// Name:         IC_INTR_IO
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// If unchecked, each interrupt source has its own output. If 
// checked, all interrupt sources are combined into a single output.
`define IC_INTR_IO 1'h0


// Name:         IC_HAS_DMA
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// Configures the inclusion of DMA handshaking interface signals. 
// When checked, includes the DMA handshaking interface signals 
// at the top-level I/O. For more information about these signals,  
// see "Signal Descriptions" in data book.
`define IC_HAS_DMA 1'h0


//DW_apb_i2c module version ID

`define IC_VERSION_ID 32'h3230322a


// Name:         IC_TX_TL
// Default:      0x0
// Values:       0x0, ..., IC_TX_BUFFER_DEPTH-1
// 
// Reset value for threshold level of transmit buffer. 
// This parameter controls the reset value of the I2C  
// Transmit FIFO Threshold Level Register (IC_TX_TL).
`define IC_TX_TL 8'h0


// Name:         IC_RX_TL
// Default:      0x0
// Values:       0x0, ..., IC_RX_BUFFER_DEPTH-1
// 
// Reset value for threshold level of receive buffer. 
// This parameter controls the reset value of the I2C  
// Receive FIFO Threshold Level Register (IC_RX_TL).
`define IC_RX_TL 8'h0


// Name:         IC_USE_COUNTS
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// Determines whether *CNT values are provided directly or by specifying the ic_clk  
// clock frequency and letting coreConsultant (or coreAssembler) calculate the count values. 
//  
// When this parameter is checked, the reset values of the *CNT registers are specified by 
// the corresponding *COUNT configuration parameters which may be user-defined or derived  
// (see standard, fast, fast mode plus, and high speed mode parameters later in this table).  
//  
// When unchecked (default setting), the reset values of the *CNT registers are calculated 
// from the configuration parameter IC_CLOCK_PERIOD. 
//  
// Note: For fast mode plus, reprogram the IC_FS_SCL_*CNT register to achieve 
// the required data rate when unchecked.
`define IC_USE_COUNTS 1'h0


// Name:         IC_CLOCK_PERIOD
// Default:      10 ([<functionof> IC_MAX_SPEED_MODE IC_ULTRA_FAST_MODE])
// Values:       2, ..., 2147483647
// Enabled:      IC_USE_COUNTS == 0
// 
// Specifies the period of incoming ic_clk, used to generate outgoing I2C 
// interface SCL clock. (ns integers only) 
//  
// When the count values are used to generate the IC_CLOCK_PERIOD then 
// the IC_MAX_SPEED_MODE setting determines the actual period 
//  
//   IC_MAX_SPEED_MODE = Standard => 500ns 
//  
//   IC_MAX_SPEED_MODE = Fast     => 100ns 
//  
//   IC_MAX_SPEED_MODE = High     => 10ns 
//  
//   IC_ULTRA_FAST_MODE = 1       => 25ns 
//  
// Note: For fast mode plus, user has to reprogram the IC_FS_SCL_*CNT register to achieve required data rate.
`define IC_CLOCK_PERIOD 10


// Name:         IC_SS_SCL_HIGH_COUNT
// Default:      0x0190 ([<functionof> IC_USE_COUNTS IC_HCNT_LO_LIMIT 
//               IC_CLOCK_PERIOD])
// Values:       IC_HCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_USE_COUNTS==1) && (IC_ULTRA_FAST_MODE ==0)
// 
// Reset value of Standard Speed I2C Clock SCL High Count 
// register (IC_SS_SCL_HCNT). The value must be calculated  
// based on the I2C data rate desired and I2C clock frequency.  
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using the  
// IC_CLOCK_PERIOD parameter. For more information, see the IC_SS_SCL_HCNT register.
`define IC_SS_SCL_HIGH_COUNT 16'h0190


// Name:         IC_SS_SCL_LOW_COUNT
// Default:      0x01d6 ([<functionof> IC_USE_COUNTS IC_LCNT_LO_LIMIT 
//               IC_CLOCK_PERIOD])
// Values:       IC_LCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_USE_COUNTS==1) && (IC_ULTRA_FAST_MODE ==0)
// 
// Reset value of Standard Speed I2C Clock SCL High Count register (IC_SS_SCL_HCNT). 
// Value must be calculated based on I2C data rate desired and I2C clock frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using  
// the IC_CLOCK_PERIOD parameter. For more information, see IC_SS_SCL_LCNT register.
`define IC_SS_SCL_LOW_COUNT 16'h01d6


// Name:         IC_FS_SCL_HIGH_COUNT
// Default:      0x003c ([<functionof> IC_MAX_SPEED_MODE IC_USE_COUNTS 
//               IC_HCNT_LO_LIMIT IC_CLOCK_PERIOD])
// Values:       IC_HCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_MAX_SPEED_MODE>=2 && IC_USE_COUNTS==1) && 
//               (IC_ULTRA_FAST_MODE==0)
// 
// Reset value of Fast Mode or Fast Mode Plus I2C Clock SCL High Count register (IC_FS_SCL_HCNT). 
// The value must be calculated based on I2C data rate desired and I2C clock frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using  
// the IC_CLOCK_PERIOD parameter. For more information, see IC_FS_SCL_HCNT register.
`define IC_FS_SCL_HIGH_COUNT 16'h003c


// Name:         IC_FS_SCL_LOW_COUNT
// Default:      0x0082 ([<functionof> IC_MAX_SPEED_MODE IC_USE_COUNTS 
//               IC_LCNT_LO_LIMIT IC_CLOCK_PERIOD])
// Values:       IC_LCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_MAX_SPEED_MODE>=2 && IC_USE_COUNTS==1) && 
//               (IC_ULTRA_FAST_MODE==0)
// 
// Reset value of Fast Mode or Fast Mode Plus I2C Clock SCL Low Count register (IC_FS_SCL_LCNT). 
// The value must be calculated based on I2C data rate desired and I2C clock frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using  
// the IC_CLOCK_PERIOD parameter. For more information, see the IC_FS_SCL_LCNT register
`define IC_FS_SCL_LOW_COUNT 16'h0082


// Name:         IC_CAP_LOADING
// Default:      100
// Values:       100 400
// Enabled:      (IC_MAX_SPEED_MODE==3) && (IC_ULTRA_FAST_MODE ==0)
// 
// For high speed mode, the bus loading affects the high and low 
// pulse width of SCL.
`define IC_CAP_LOADING 100


// Name:         IC_HS_SCL_HIGH_COUNT
// Default:      0x0006 ([<functionof> IC_MAX_SPEED_MODE IC_USE_COUNTS 
//               IC_HCNT_LO_LIMIT IC_CLOCK_PERIOD IC_CAP_LOADING])
// Values:       IC_HCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_MAX_SPEED_MODE==3 && IC_USE_COUNTS==1) && 
//               (IC_ULTRA_FAST_MODE==0)
// 
// Reset value of High Speed I2C Clock SCL High Count register (IC_HS_SCL_HCNT). 
// The value must be calculated based on I2C data rate desired and high speed 
// I2C clock frequency. When parameter IC_USE_COUNTS = 0, this parameter is  
// automatically calculated using the IC_CLOCK_PERIOD parameter.  
// For more information, see IC_HS_SCL_HCNT register.
`define IC_HS_SCL_HIGH_COUNT 16'h0006


// Name:         IC_HS_SCL_LOW_COUNT
// Default:      0x0010 ([<functionof> IC_MAX_SPEED_MODE IC_USE_COUNTS 
//               IC_LCNT_LO_LIMIT IC_CLOCK_PERIOD IC_CAP_LOADING])
// Values:       IC_LCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_MAX_SPEED_MODE==3 && IC_USE_COUNTS==1) && 
//               (IC_ULTRA_FAST_MODE==0)
// 
// Reset value of High Speed I2C Clock SCL Low Count register (IC_HS_SCL_LCNT). 
// The value must be calculated based on I2C data rate and I2C clock 
// frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using  
// the IC_CLOCK_PERIOD parameter. For more information, see IC_HS_SCL_LCNT register.
`define IC_HS_SCL_LOW_COUNT 16'h0010


// Name:         IC_HC_COUNT_VALUES
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// By checking this parameter, the *CNT registers are set to read 
// only. Unchecking this parameter (default setting) allows the *CNT registers to 
// be writable. 
//  
// Regardless of the setting, the *CNT registers are always readable and 
// have reset values from the corresponding *COUNT configuration parameters, which 
// may be user defined or derived (see standard, fast, fast mode plus, or high 
// speed mode parameters later in this table). 
//  
// Note: Since the DW_apb_i2c uses the same high and low count registers for fast mode and fast mode plus operation,  
// if this parameter is checked (1) the IC_FS_SCL_*CNT registers are hard coded to either one of the fast mode and fast 
// mode plus.  
// Consequently, DW_apb_i2c can operate in either fast mode or fast mode plus, but not in both modes simultaneously. 
//  
// For fast mode plus, it is recommended that this parameter be Unchecked (0).
`define IC_HC_COUNT_VALUES 1'h0


`define IDENT 2'h0

//Asynchronous clock relationship

`define ASYNC 2'h1

//Synchronous clock relationship

`define SYNC 2'h3


// Name:         IC_CLK_TYPE
// Default:      Asynchronous (0x1)
// Values:       Identical (0x0), Asynchronous (0x1)
// 
// Specifies the relationship between pclk and ic_clk 
//  
// Identical (0): clocks are identical; no meta-stability flops 
// used for data passing between clock domains. 
//  
// Asynchronous (1): clocks may be completely asynchronous to 
// each other, meta-stability flops are required for data passing between clock domains.
`define IC_CLK_TYPE 2'h1


`define IC_SYNC_DEPTH 2


`define IC_VERIF_EN 1


// Name:         IC_HAS_ASYNC_FIFO
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_CLK_TYPE==ASYNC
// 
// This parameter controls whether DW_apb_i2c consist of Asynchronous or Synchronous 
// FIFO's for the Transmit and Receive Data Buffers.
`define IC_HAS_ASYNC_FIFO 1'h0


//Modified Depth of the Transmit buffer

`define IC_TX_BUFFER_MOD_DEPTH 8

//Modified Depth of the Receive buffer

`define IC_RX_BUFFER_MOD_DEPTH 8

`define IC_HAS_ASYNC_CLK

//Setting up a clock period for the I2C.

`define IC_CLK_FREQ 100

//LHS of Paddr bus

`define IC_ADDR_SLICE_LHS 3'h7

//LHS of Paddr bus

`define MAX_APB_DATA_WIDTH 6'h20


// Name:         I2C_DYNAMIC_TAR_UPDATE
// Default:      false
// Values:       false (0), true (1)
// 
// When checked, allows the IC_TAR register to be updated 
// dynamically. Setting this parameter affects the operation  
// of DW_apb_i2c when it is in master mode. For more details,  
// see "Master Mode Operation".
`define I2C_DYNAMIC_TAR_UPDATE 0




// Name:         IC_SLV_DATA_NACK_ONLY
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// Enables an additional register which controls whether the DW_apb_i2c generates a NACK 
// after a data byte has been transferred to it. This NACK generation only occurs when 
// the DW_apb_i2c is a Slave-Receiver. If this register is set to a value of 1, it can 
// only generate a NACK after a data byte is received; hence, the data transfer is aborted. 
// Also, the data received is not pushed to the receive buffer. 
//  
// When the register is set to a value of 0, it generates NACK/ACK depending on  
// normal criteria. 
// If this option is selected, the default value of the register IC_SLV_DATA_NACK_ONLY is always 0. 
// The register must be explicitly programmed to a value of 1 if NACKs are to be generated. The 
// register can only be written to successfully if DW_apb_i2c is disabled (IC_ENABLE[0] = 0) or the  
// slave part is inactive (IC_STATUS[6] = 0).
`define IC_SLV_DATA_NACK_ONLY 1'h0




// Name:         IC_RX_FULL_GEN_NACK
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      (IC_ULTRA_FAST_MODE ==0) && (IC_SLV_DATA_NACK_ONLY ==0)
// 
// This parameter enables DW_apb_i2c in Slave mode to generate NACK for a data byte recieved  
// when Receive FIFO is physically full. The new data byte will not be pushed to the Receive 
// FIFO, hence no overflow happens and rx_over interrupt will not be set. 
// This works only when DW_apb_i2c is in Slave/Receiver mode (data being written 
// to the slave) and is not applicable in Master mode.
`define IC_RX_FULL_GEN_NACK 1'h0




// Name:         IC_EMPTYFIFO_HOLD_MASTER_EN
// Default:      false (IC_SMBUS == 1 ? 1 : 0)
// Values:       false (0), true (1)
// 
// If this parameter is set, the master will only complete a transfer - that is issues a STOP -  
// when it finds a Tx FIFO entry tagged with a Stop bit. If the Tx FIFO becomes 
// empty and the last byte does not have the Stop bit set, the master stalls 
// the transfer by holding the SCL line low. 
//  
// If this parameter is not set, the master completes a transfer when the  
// Tx FIFO is empty. In SMbus Mode (IC_SMBUS=1), 
// IC_EMPTYFIFO_HOLD_MASTER_EN should be always enabled.
`define IC_EMPTYFIFO_HOLD_MASTER_EN 0



// Name:         IC_DEFAULT_SDA_SETUP
// Default:      0x64
// Values:       0x02, ..., 0xff
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// Determines the reset value for the register IC_SDA_SETUP, which in 
// turn controls the time delay - in terms of number of ic_clk clock periods - introduced 
// in the rising edge of SCL, relative to SDA changing when a read-request is serviced. 
// The relevant I2C requirement is t[su:DAT] as detailed in the I2C Bus Specifications.
`define IC_DEFAULT_SDA_SETUP 8'h64


// Name:         IC_DEFAULT_SDA_HOLD
// Default:      0x000001 ([<functionof> IC_USE_COUNTS IC_CLOCK_PERIOD 
//               IC_ULTRA_FAST_MODE])
// Values:       0x000001, ..., 0xffffff
// 
// Determines the reset value for the register IC_SDA_HOLD, which in 
// turn controls the SDA hold time implemented by DW_apb_i2c (when 
// transmitting or receiving, as either master or slave) 
// as a master/slave transmitter or Master/Slave Reciever). 
// The relevant I2C requirement is t[HD:DAT] as detailed in the I2C Bus Specifications. 
//  
// The programmed SDA hold time as transmitter cannot exceed at any time the 
// duration of the low part of scl. Therefore it is recommended that the configured 
// default value should not be larger than N_SCL_LOW-2, where N_SCL_LOW is 
// the duration of the low part of the scl period measured in ic_clk cycles, for the 
// maximum speed mode the component is configured for.
`define IC_DEFAULT_SDA_HOLD 24'h000001


`define IC_DEFAULT_SDA_TX_HOLD 16'h1


`define IC_DEFAULT_SDA_RX_HOLD 8'h0


// Name:         IC_DEFAULT_ACK_GENERAL_CALL
// Default:      true
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE == 0
// 
// This parameter determines the reset value for the register IC_ACK_GENERAL_CALL, which 
// in turn controls whether I2C general call addresses are to responded or not.
`define IC_DEFAULT_ACK_GENERAL_CALL 1'h1


// Name:         IC_RX_FULL_HLD_BUS_EN
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// When the Rx FIFO is physically full to its RX_BUFFER_DEPTH,  
// this parameter provides a hardware method to hold the bus till Rx FIFO data  
// is read out and there is a space available in the FIFO. 
// This parameter can be used when DW_apb_i2c is either a slave-receiver (that 
// is, data is written to the device) or a master-receiver (that is, the device reads 
// data from a slave). 
//  
// Note: If parameter "IC_RX_FULL_GEN_NACK" is enabled, then setting this parameter 
// has no impact in slave-receiver mode since, the controller NACK's the Data byte if Rx-FIFO 
// has no empty space. 
// Note: If this parameter is checked, then the RX_OVER interrupt is never set to 1  
// as the criteria to set this interrupt is never met. The RX_OVER interrupt can be found  
// in IC_INTR_STAT and IC_RAW_INTR_STAT registers. It is also an optional output signal, 
//  ic_rx_over_intr(_n).
`define IC_RX_FULL_HLD_BUS_EN 1'h0







// Name:         IC_SLV_RESTART_DET_EN
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// When checked, allows the slave to detect and issue the restart interrupt when slave is  
// addressed. Setting this parameter affects the operation of DW_apb_i2c only when it is in slave mode.  
// This controls the "RESTART_DET" bit in the IC_RAW_INTR_STAT, IC_INTR_MASK, IC_INTR_STAT,  
// and IC_CLR_RESTART_DET registers.This also controls the ic_restart_det_intr(_n)  
// and ic_intr(_n) signals.
`define IC_SLV_RESTART_DET_EN 1'h0




// Name:         IC_STOP_DET_IF_MASTER_ACTIVE
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// Controls whether DW_apb_i2c generates STOP_DET interrupt when master is active: 
//  - Checked (1): Allows the master to detect and issue the stop interrupt when master is active. 
//  - Unchecked (0): The master always detects and issues the stop interrupt irrespective of whether it is active. 
// This parameter affects the operation of DW_apb_i2c when it is in master mode.  
// This controls the STOP_DET bit of the IC_RAW_INTR_STAT, IC_INTR_MASK,   
// IC_INTR_STAT and IC_CLR_STOP_DET registers. This also controls the ic_stop_det_intr(_n) and  
// ic_intr(_n) signals.
`define IC_STOP_DET_IF_MASTER_ACTIVE 1'h0




// Name:         IC_STAT_FOR_CLK_STRETCH
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// If this parameter is set, the DW_apb_i2c consists of status bits indicating 
// the reason for clock stretching in the IC_STATUS Register.
`define IC_STAT_FOR_CLK_STRETCH 1'h0





// Name:         IC_TX_CMD_BLOCK
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c transmits data on I2C bus as soon as data is available in  
// Tx FIFO. When checked, allows the master to hold the transmission of data on  
// I2C bus when Tx FIFO has data to transmit.
`define IC_TX_CMD_BLOCK 1'h0



// Name:         IC_TX_CMD_BLOCK_DEFAULT
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_TX_CMD_BLOCK==1
// 
// Controls whether DW_apb_i2c has its transmit command block enabled or disabled after reset. 
// If checked, the DW_apb_i2c blocks the transmission of data on I2C bus.
`define IC_TX_CMD_BLOCK_DEFAULT 1'h0


// Name:         IC_FIRST_DATA_BYTE_STATUS
// Default:      false
// Values:       false (0x0), true (0x1)
// 
// Controls whether DW_apb_i2c generates FIRST_DATA_BYTE status bit in IC_DATA_CMD register. 
// When checked, the master/slave receiver to set the FIRST_DATA_BYTE status bit 
// in IC_DATA_CMD register to indicate whether the data present in IC_DATA_CMD register is  
// first data byte after the address phase of a receive transfer. 
//  
// Note: In the case when APB_DATA_WIDTH is set to 8, you must perform two 
// APB reads to the IC_DATA_CMD register to get status on bit 11.
`define IC_FIRST_DATA_BYTE_STATUS 1'h0



// Name:         IC_AVOID_RX_FIFO_FLUSH_ON_TX_ABRT
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// This Parameter controls the Rx FIFO Flush during the Transmit Abort. 
// If this parameter is checked(1), only the Tx FIFO is flushed (not the Rx FIFO) 
// Flush on the Transmit Abort. 
// If this parameter is unchecked(0), both Tx FIFO and Rx FIFO are flushed on Transmit Abort.
`define IC_AVOID_RX_FIFO_FLUSH_ON_TX_ABRT 1'h0



// Name:         IC_BUS_CLEAR_FEATURE
// Default:      false (IC_SMBUS==1 ? 1 : 0)
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// This parameter will enable the Bus clear feature for the DW_apb_i2c core. 
//  
//  
// If this parameter is set: 
//  - If an SDA line is stuck at low for IC_SDA_STUCK_LOW_TIMEOUT period of ic_clk, DW_apb_i2c master generates a master 
//  transmit abort (IC_TX_ABRT_SOURCE[17]: ABRT_SDA_STUCK_AT_LOW) to indicate SDA stuck at low. 
// User can enable the SDA_STUCK_RECOVERY_EN (IC_ENABLE[3]) register bit to recover the SDA by sending at most 9 SCL 
// clocks. 
// If SDA line is recovered, then the master generates a STOP and auto clear the 'SDA_STUCK_RECOVERY_EN' register bit and 
// resume the normal I2C transfers. 
// If an SDA line is not recovered, then the master auto clears the SDA_STUCK_RECOVERY_EN register bit and asserts the 
// SDA_STUCK_NOT_RECOVERED (IC_STATUS[12]) status bit to indicate the SDA is not recovered after sending 9 SCL clocks which 
// intimate the user for system reset. 
//  - If SCL line is stuck at low for IC_SCL_STUCK_LOW_TIMEOUT period of ic_clk, DW_apb_i2c Master will generate an 
//  SCL_STUCK_AT_LOW (IC_INTR_RAW_STATUS[14]) interrupt to intimate the user for system reset.
`define IC_BUS_CLEAR_FEATURE 1'h0



// Name:         IC_SCL_STUCK_TIMEOUT_DEFAULT
// Default:      0xffffffff
// Values:       0x0, ..., 0xffffffff
// Enabled:      IC_BUS_CLEAR_FEATURE==1
// 
// Default value of the IC_SCL_STUCK_LOW_TIMEOUT Register.
`define IC_SCL_STUCK_TIMEOUT_DEFAULT 32'hffffffff


// Name:         IC_SDA_STUCK_TIMEOUT_DEFAULT
// Default:      0xffffffff
// Values:       0x0, ..., 0xffffffff
// Enabled:      IC_BUS_CLEAR_FEATURE==1
// 
// Default value of the IC_SDA_STUCK_LOW_TIMEOUT Register.
`define IC_SDA_STUCK_TIMEOUT_DEFAULT 32'hffffffff


// Name:         IC_DEVICE_ID
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_ULTRA_FAST_MODE ==0
// 
// If this Parameter is enabled, the DW_apb_i2c slave includes a 24-bit  
// IC_DEVICE_ID Register to store the value of 
// Device-ID and transmits whenever master is requested. 
//  
// The Master mode includes a DEVICE_ID bit 13 in IC_TAR register to initiate 
// the Device ID read for a particular slave address mentioned in IC_TAR[6:0] 
// register.
`define IC_DEVICE_ID 1'h0



// Name:         IC_DEVICE_ID_VALUE
// Default:      0x0
// Values:       0x0, ..., 0xffffff
// Enabled:      IC_DEVICE_ID==1
// 
// Device ID Value of the I2C Slave stored in the IC_DEVICE_ID Register (24 bit, MSB is transferred first 
// on the Device ID read from the master).
`define IC_DEVICE_ID_VALUE 24'h0



// Name:         IC_SMBUS_CLK_LOW_SEXT_DEFAULT
// Default:      0xffffffff
// Values:       0x0, ..., 0xffffffff
// Enabled:      IC_SMBUS==1
// 
// Default value of the IC_SMBUS_CLK_LOW_SEXT Register.
`define IC_SMBUS_CLK_LOW_SEXT_DEFAULT 32'hffffffff


// Name:         IC_SMBUS_CLK_LOW_MEXT_DEFAULT
// Default:      0xffffffff
// Values:       0x0, ..., 0xffffffff
// Enabled:      IC_SMBUS==1
// 
// Default value of the IC_SMBUS_CLK_LOW_MEXT Register.
`define IC_SMBUS_CLK_LOW_MEXT_DEFAULT 32'hffffffff


// Name:         IC_SMBUS_RST_IDLE_CNT_DEFAULT
// Default:      0xffff
// Values:       0x0, ..., 0xffff
// Enabled:      IC_SMBUS==1
// 
// Default value of the IC_SMBUS_THIGH_MAX_IDLE_COUNT Register.
`define IC_SMBUS_RST_IDLE_CNT_DEFAULT 16'hffff


// Name:         IC_SMBUS_SUSPEND_ALERT
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_SMBUS==1
// 
// This parameter controls whether DW_apb_i2c includes  
// Optional SMBus Suspend and Alert signals on the interface.
`define IC_SMBUS_SUSPEND_ALERT 1'h0

//Internal Define for SMBus optional signals

// `define IC_SMBUS_SUSPEND_ALERT_EN


// Name:         IC_OPTIONAL_SAR
// Default:      false
// Values:       false (0x0), true (0x1)
// Enabled:      IC_SMBUS==1
// 
// This parameter controls whether to include optional  
// Slave Address Register in SMBus Mode.
`define IC_OPTIONAL_SAR 1'h0



// Name:         IC_OPTIONAL_SAR_DEFAULT
// Default:      0x0
// Values:       0x0, ..., 0x7f
// Enabled:      IC_OPTIONAL_SAR==1
// 
// Controls whether to include Optional Slave Address Register in 
// SMBus Mode. A user is not allowed to assign any reserved  
// addresses. The reserved address are as follows: 
//  
// 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 
//  
// 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
`define IC_OPTIONAL_SAR_DEFAULT 7'h0


// Name:         IC_SMBUS_ARP
// Default:      0x0
// Values:       0x0, 0x1
// Enabled:      IC_SMBUS==1
// 
// Controls whether DW_apb_i2c includes logic to detect and 
// respond ARP commands in Slave mode. It also includes logic to 
// generate/validate the PEC byte at the end of the transfer in  
// Slave mode only.
`define IC_SMBUS_ARP 1'h0



// Name:         IC_SMBUS_UDID_HC
// Default:      0x1
// Values:       0x0, 0x1
// Enabled:      IC_SMBUS_ARP==1
// 
// Controls whether Unique Device Identifier (UDID) used for Dynamic 
// Address Resolution process in SMBus ARP Mode is Hardcoded  
// (Upper 96-bits) or Complete UDID is Software Programmable.
`define IC_SMBUS_UDID_HC 1'h1

//DMAC has Debug Ports Define 
`define IC_SMBUS_HAS_UDID_HC



// Name:         IC_SMBUS_UDID_MSB
// Default:      0x0
// Values:       0x0, ..., 0xffffffffffffffffffffffff
// Enabled:      IC_SMBUS_ARP==1
// 
// If the parameter IC_SMBUS_UDID_HC is 1, stores the Static Unique  
// Device Identifier used for Dynamic Address Resolution process in  
// SMBus ARP Mode (Upper 96bits of UDID). 
// If the parameter IC_SMBUS_UDID_HC is 0, then this field is used as the 
// default value of the upper 96bits of the UDID Registers 
// {IC_SMBUS_UDID_WORD3, IC_SMBUS_UDID_WORD2, IC_SMBUS_UDID_WORD1}
`define IC_SMBUS_UDID_MSB 96'h0


// Name:         IC_SMBUS_UDID_LSB_DEFAULT
// Default:      0xffffffff
// Values:       0x0, ..., 0xffffffff
// Enabled:      IC_SMBUS_ARP==1
// 
// If the parameter IC_SMBUS_UDID_HC is 1, specifies default value of  
// the IC_SMBUS_UDID_LSB register used for Dynamic Address Resolution  
// process in SMBus ARP mode (Lower 32bits of UDID). 
// If the parameter IC_SMBUS_UDID_HC is 0, specifies default value of  
// the IC_SMBUS_UDID_WORD0 register used for Dynamic Address Resolution  
// process in SMBus ARP mode (Lower 32bits of UDID).
`define IC_SMBUS_UDID_LSB_DEFAULT 32'hffffffff



// Name:         IC_PERSISTANT_SLV_ADDR_DEFAULT
// Default:      0x0
// Values:       0x0, 0x1
// Enabled:      IC_SMBUS_ARP==1
// 
// Default value of the Persistent Slave Address register bit in IC_CON Register.
`define IC_PERSISTANT_SLV_ADDR_DEFAULT 1'h0


// Name:         IC_UFM_SCL_HIGH_COUNT
// Default:      0x0006 ([<functionof> IC_USE_COUNTS IC_HCNT_LO_LIMIT 
//               IC_CLOCK_PERIOD IC_ULTRA_FAST_MODE])
// Values:       IC_HCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_USE_COUNTS==1) && (IC_ULTRA_FAST_MODE==1)
// 
// Reset value of Ultra-Fast Speed I2C Clock SCL High Count register (IC_UFM_SCL_HCNT).  
// The value must be calculated based on the I2C data rate desired and I2C clock frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using the IC_CLOCK_PERIOD parameter.
`define IC_UFM_SCL_HIGH_COUNT 16'h0006


// Name:         IC_UFM_SCL_LOW_COUNT
// Default:      0x0008 ([<functionof> IC_USE_COUNTS IC_LCNT_LO_LIMIT 
//               IC_CLOCK_PERIOD IC_ULTRA_FAST_MODE])
// Values:       IC_LCNT_LO_LIMIT, ..., 0xffff
// Enabled:      (IC_USE_COUNTS==1) && (IC_ULTRA_FAST_MODE==1)
// 
// Reset value of Ultra-Fast Speed I2C Clock SCL Low Count register (IC_UFM_SCL_LCNT).  
// The value must be calculated based on the I2C data rate desired and I2C clock frequency. 
// When parameter IC_USE_COUNTS = 0, this parameter is automatically calculated using the IC_CLOCK_PERIOD parameter.
`define IC_UFM_SCL_LOW_COUNT 16'h0008


// Name:         IC_UFM_TBUF_CNT_DEFAULT
// Default:      0x8 ([<functionof> IC_USE_COUNTS IC_CLOCK_PERIOD])
// Values:       0x0, ..., 0xffff
// Enabled:      (IC_USE_COUNTS==1) && (IC_ULTRA_FAST_MODE==1)
// 
// Default value of the IC_UFM_TBUF_CNT Register. This parameter is active when the IC_USE_COUNTS and 
// IC_ULTRA_FAST_MODE parameters are checked (1); otherwise, this value is automatically calculated  
// using the IC_CLK_PERIOD parameter.
`define IC_UFM_TBUF_CNT_DEFAULT 16'h8
// -----------------------------------------------------------
// -- Regsiter bit Width macros
// -----------------------------------------------------------
//ic_con register bit width

`define IC_CON_RS 9

//SMB extension for ic_con register bit width

`define IC_SMBUS_CON_EXT_RS 4

//ic_tar register bit width

`define IC_TAR_RS 12


`define IC_TAR_RS_INT 12

//ic_sar optional register bit width

`define IC_SAR_OPT_RS 7

//ic_sar register bit width

`define IC_SAR_RS 10

//ic_hs_maddr register bit width

`define IC_HS_MADDR_RS 3

//ic_data_cmd Receiver register bit width

`define IC_DATA_CMD_RS 9

//ic_data_cmd Transmit register bit width

`define IC_DATA_TX_CMD_RS 9

//ic_data_cmd register valid data bit width

`define IC_DATA_RS 8

//ic_data_cmd register register fifo bit width

`define IC_DATA_FIFO_RS 8

//ic_ss_hcnt register bit width

`define IC_SS_HCNT_RS 16

//ic_ss_lcnt register bit width

`define IC_SS_LCNT_RS 16

//ic_fs_hcnt register bit width

`define IC_FS_HCNT_RS 16

//ic_fs_lcnt register bit width

`define IC_FS_LCNT_RS 16

//ic_hs_hcnt register bit width

`define IC_HS_HCNT_RS 16

//ic_hs_lcnt register bit width

`define IC_HS_LCNT_RS 16

//ic_intr_stat register bit width

`define IC_INTR_STAT_RS 15

//ic_intr_mask register bit width

`define IC_INTR_MASK_RS 15

//ic_raw_intr_stat register bit width

`define IC_RAW_INTR_STAT_RS 15

//ic_smbus_intr_* register bit width

`define IC_SMBUS_INTR_RS 4

//ic_rx_tl register bit width

`define IC_RX_TL_RS 8

//ic_tx_tl register bit width

`define IC_TX_TL_RS 8

//ic_clr_intr register bit width

`define IC_CLR_INTR_RS 1

//ic_clr_rx_under register bit width

`define IC_CLR_RX_UNDER_RS 1

//ic_clr_rx_over register bit width

`define IC_CLR_RX_OVER_RS 1

//ic_clr_tx_over register bit width

`define IC_CLR_TX_OVER_RS 1

//ic_clr_rd_req register bit width

`define IC_CLR_RD_REQ_RS 1

//ic_clr_tx_abrt register bit width

`define IC_CLR_TX_ABRT_RS 1

//ic_clr_rx_done register bit width

`define IC_CLR_RX_DONE_RS 1

//ic_clr_activity register bit width

`define IC_CLR_ACTIVITY_RS 1

//ic_clr_stop_det register bit width

`define IC_CLR_STOP_DET_RS 1

//ic_clr_stop_det register bit width

`define IC_CLR_RESTART_DET_RS 1

//ic_clr_start_det register bit width

`define IC_CLR_START_DET_RS 1

//ic_clr_gen_call register bit width

`define IC_CLR_GEN_CALL_RS 1

//ic_enable register bit width

`define IC_ENABLE_RS 2

//ic_enable internal register bit width for sync module

`define IC_ENABLE_RS_INT 2

// ic_status register bit width

`define IC_STATUS_RS 7

//ic_sreset register bit width

`define IC_SRESET_RS 3

//ic_device_id register width

//ic_tx_abrt_source register bit width

`define IC_TX_ABRT_SOURCE_RS 17

//PAT START
//ic_slv_data_nack_only register bit width

`define IC_SLV_DATA_NACK_ONLY_RS 1
//PAT END

//ic_version_id register bit width

`define IC_VERSION_ID_RS 32

//ic_version_id register bit width

`define IC_DMA_CR_RS 2

//ic_version_id register bit width

`define IC_DMA_TDLR_RS 3

//ic_version_id register bit width

`define IC_DMA_RDLR_RS 3

//SDA setup time setting; used when SCL is held

`define IC_SDA_SETUP_RS 8

//internal SDA hold time setting; used when I2C acts as transmitter

`define IC_SDA_TX_HOLD_RS 16

//internal SDA hold time setting; used when I2C acts as reciever

`define IC_SDA_RX_HOLD_RS 8

//SDA hold time setting; used when I2cis acting as either Master or reciever

`define IC_SDA_HOLD_RS 24

//Acknowledgement of General Call addresses

`define IC_ACK_GENERAL_CALL_RS 1

//IC_ENABLE_STATUS

`define IC_ENABLE_STATUS_RS 3

//IC_SMBUS_TIMEOUT Register size

`define IC_SMBUS_TIMEOUT_RS 32

//IC_SMBUS_RST_IDLE_CNT Register size

`define IC_SMBUS_RST_IDLE_CNT_RS 16

//IC_SMBUS_SUS_ALERT_CTRL Register size

`define IC_SMBUS_SUS_ALERT_RS 2

//IC_SMBUS_UDID_LSB Register size

`define IC_SMBUS_UDID_LSB_RS 32

//ic_con_smbus register width value

`define IC_SMBUS_UDID_RS 144

//SMBus Host Slave Address

`define IC_SMBUS_HOST_SLAVE_ADDRESS 7'h8

//SMBus write Device Default Address

`define IC_SMBUS_DEVICE_DEFAULT_ADDRESS 8'hc2

//SMBus Read Device Default Address

`define IC_SMBUS_RD_DEVICE_DEFAULT_ADDRESS 8'hc3

//SMBus Prepare to ARP command

`define IC_SMBUS_PREPARE_TO_ARP_CMD 8'h1

//SMBus General Reset command

`define IC_SMBUS_GEN_RESET_CMD 8'h2

//SMBus General Get UDID command

`define IC_SMBUS_GEN_GET_UDID_CMD 8'h3

//SMBus General Assign address command

`define IC_SMBUS_ASSGN_ADDR_CMD 8'h4

//SMBus UDID byte count

`define IC_SMBUS_UDID_BYTE_COUNT 5'h11

//SMBus UDID byte count plus 1

`define IC_SMBUS_UDID_BYTE_COUNT_PLS1 5'h12

//SMBus UDID byte count width

`define IC_SMBUS_UDID_BYTE_COUNT_LOG2 5

//SMBUS Alert Response address

`define SMB_ALERT_ADDRESS 7'hc

// -----------------------------------------------------------
// -- Register reset value  macros
// -----------------------------------------------------------
//ic_con register reset value

`define IC_CON_IN 20'h7f

//ic_tar register reset value

`define IC_TAR_IN 13'h1033

//ic_tar register reset value

`define IC_TAR_IN_RAL 44'h33

//ic_sar register reset value

`define IC_SAR_IN 10'h33

//ic_sar register reset value

`define IC_SAR_OPT_IN 7'h0

//ic_hs_maddr register reset value

`define IC_HS_MADDR_IN 3'h1

//ic_ss_hcnt register reset value

`define IC_SS_HCNT_IN 16'h190

//ic_ss_lcnt register reset value

`define IC_SS_LCNT_IN 16'h1d6

//ic_fs_hcnt register reset value

`define IC_FS_HCNT_IN 16'h3c

//ic_fs_lcnt register reset value

`define IC_FS_LCNT_IN 16'h82

//ic_hs_hcnt register reset value

`define IC_HS_HCNT_IN 16'h6

//ic_hs_lcnt register reset value

`define IC_HS_LCNT_IN 16'h10

//ic_rx_tl register reset value

`define IC_RX_TL_IN 8'h0

//ic_tx_tl register reset value

`define IC_TX_TL_IN 8'h0

//ic_status register reset value

`define IC_STATUS_IN 21'h6

//IC_ENABLE register reset value

`define IC_ENABLE_IN 3'h0

//Indicates a High Speed Mode Address value

`define IC_HS_CODE 5'h1

//Indicates a 10 bit address transfer

`define IC_SLV_ADDR_10BIT 5'h1e

//General Call I2C bus Code

`define IC_GENERAL_CALL 8'h0

//Start Byte I2C bus Code

`define IC_START_BYTE 8'h1

//DEVICE-ID I2C bus Code

`define IC_DEVICE_ID_BYTE 7'h7c

//I2C Version ID

`define IC_VERSION_ID_IN 32'h3230322a

//Speed up my simulation

`define IC_SPEED_SIM 1'h1

//Random Seed For Simulations. Anything between 1 and 31.

`define IC_RAND_SEED 1

//Determines if simulation max is one hour

`define IC_RUN_FOR_ONE_HOUR 1'h1

//Determines if the I2C VIP VMT models are instaniated

`define IC_VMT_MODEL_INCLUDED 1'h0

//Encoded APB Data Width

`define ENCODED_APB_DATA_WIDTH 2'h2

//Encoded value of the transmit buffer depth

`define ENCODED_IC_TX_BUFFER_DEPTH 8'h7

//Encoded value of the receiver buffer depth

`define ENCODED_IC_RX_BUFFER_DEPTH 8'h7

//ic_comp_param_1 register reset value

`define IC_COMP_PARAM_1_IN 24'h7078e

//ic_comp_param_1 register reset value

`define IC_COMP_PARAM_UFM_1_IN 24'h70782


// `define I2C_ENCRYPT

//Lower limit of number of clocks used for spike suppression in SS and FS

`define IC_FS_SPKLEN_LO_LIMIT 8'h1

//Lower limit of number of clocks used for spike suppression in HS

`define IC_HS_SPKLEN_LO_LIMIT 8'h1

//Duration (in ns) of longest spike to be suppressed in SS and FS

`define IC_FS_MAX_SPKLEN 50

//Duration (in ns) of longest spike to be suppressed in HS

`define IC_HS_MAX_SPKLEN 10


// Name:         IC_DEFAULT_FS_SPKLEN
// Default:      0x5 ([<functionof> IC_CLOCK_PERIOD IC_FS_MAX_SPKLEN])
// Values:       0x1, ..., 0xff
// Enabled:      IC_ULTRA_FAST_MODE==0
// 
// Reset value of maximum suppressed spike length register in  
// Standard Mode, Fast Mode, and Fast Mode Plus modes (IC_FS_SPKLEN Register). 
// Spike length is expressed in ic_clk cycles and this value is calculated based 
// on the value of IC_CLOCK_PERIOD.
`define IC_DEFAULT_FS_SPKLEN 8'h5


// Name:         IC_DEFAULT_HS_SPKLEN
// Default:      0x1 ([<functionof> IC_CLOCK_PERIOD IC_HS_MAX_SPKLEN])
// Values:       0x1, ..., 0xff
// Enabled:      (IC_MAX_SPEED_MODE==3) && (IC_ULTRA_FAST_MODE ==0)
// 
// Reset value of maximum suppressed spike length register in HS modes (Register IC_HS_SPKLEN). 
// Spike length is expressed in ic_clk cycles and this value is calculated based on the value 
// of IC_CLOCK_PERIOD.
`define IC_DEFAULT_HS_SPKLEN 8'h1


// Name:         IC_DEFAULT_UFM_SPKLEN
// Default:      0x1 ([<functionof> IC_CLOCK_PERIOD IC_HS_MAX_SPKLEN])
// Values:       0x1, ..., 0xff
// Enabled:      IC_ULTRA_FAST_MODE ==1
// 
// Reset value of maximum suppressed spike length register in Ultra-Fast Mode (IC_UFM_SPKLEN Register). 
// Spike length is expressed in ic_clk cycles and this value is calculated based on the value of IC_CLOCK_PERIOD.
`define IC_DEFAULT_UFM_SPKLEN 8'h1


//ic_fs_spklen width

`define IC_FS_SPKLEN_RS 8

//ic_hs_spklen width

`define IC_HS_SPKLEN_RS 8

//Larger of IC_HS_SPKLEN_RS and IC_FS_SPKLEN_RS

`define IC_SPKLEN_RS 8

//ic_scl_sda_timeout width

`define IC_SCL_SDA_TIMEOUT_RS 32

//Creates a define for enabling low power interface

`define IC_HIGHSPEED_MODE_EN

//Include SVA assertions



// Name:         REG_TIMEOUT_WIDTH
// Default:      4
// Values:       0 4 5 6 7 8
// Enabled:      SLAVE_INTERFACE_TYPE>0 && SLVERR_RESP_EN==1
// 
// Defines the width of Register timeout counter. If set to zero, 
// the timeout counter register is disabled, and timeout is triggered 
// as soon as the transaction tries to read an empty RX_FIFO or write 
// to a full TX_FIFO. As these are the only cases where PREADY signal 
// goes low , it ensures that PREADY is tied high throughout. Setting 
// values from 4 through 32 for this parameter configures the timeout 
// period from 2^4 to 2^8 pclk cycles.
`define REG_TIMEOUT_WIDTH 4

//Slave has non-zero reg_timeout_width

`define IC_HAS_POSITIVE_REG_TIMEOUT_WIDTH


// Name:         HC_REG_TIMEOUT_VALUE
// Default:      false
// Values:       false (0), true (1)
// Enabled:      SLAVE_INTERFACE_TYPE>0 && SLVERR_RESP_EN==1 && REG_TIMEOUT_WIDTH>0
// 
// Checking this parameter makes Register timeout counter a read-only register. 
// The register can be programmed by user if the hardcode option is turned off.
`define HC_REG_TIMEOUT_VALUE 0

//APB Interface has hardcoded timeout reset value

// `define IC_HAS_HC_REG_TIMEOUT_VALUE


`define POW_2_REG_TIMEOUT_WIDTH 15


// Name:         REG_TIMEOUT_VALUE
// Default:      8
// Values:       1, ..., POW_2_REG_TIMEOUT_WIDTH
// Enabled:      SLAVE_INTERFACE_TYPE>0 && SLVERR_RESP_EN==1 && REG_TIMEOUT_WIDTH>0
// 
// Defines the reset value of Register timeout counter register. This value can 
// be over - ridden by programming the timeout counter register before 
// enabling the component , if the HC_REG_TIMEOUT_VALUE is left un-checked
`define REG_TIMEOUT_VALUE 8

//BCM defines
`define DWC_NO_CDC_INIT
`define DWC_NO_TST_MODE
`define DWC_BCM06_NO_DIAG_N

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #1 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_tog.v#1 $ 
//
//
// File    : DW_apb_i2c_tog.v
//
//
// Author  : Madhusudhan Prabhu
// Created : Thu Nov 05 00:54:48 IST 2015
// Abstract: The toggle module is used for generating toggle signal of its input. This is used for
//           avoiding the scenario in which the same file has the logic corresponding 
//           to two clocks i.e. pclk and ic_clk.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------


module DW_apb_i2c_tog (
    clk,
    resetn,
    tog_data_in,
    tog_data_out
);

input  clk;
input  resetn;
input  tog_data_in;
output tog_data_out;

  reg  tog_data_out;

  always @(posedge clk or negedge resetn)
  begin : i2c_tog_PROC
    if (resetn == 1'b0) begin
      tog_data_out <= 1'b0;
    end else begin
      if (tog_data_in == 1'b1) 
      tog_data_out <= ~tog_data_out;
    end
  end

endmodule



   `undef APB_DATA_WIDTH
   `undef APB_DATA_WIDTH_32
   `undef APB_DATA_WIDTH_NOT_8
   `undef ASYNC
   `undef DWC_BCM06_NO_DIAG_N
   `undef DWC_NO_CDC_INIT
   `undef DWC_NO_TST_MODE
   `undef DW_HOLD_MUX_DELAY
   `undef DW_SETUP_MUX_DELAY
   `undef ENCODED_APB_DATA_WIDTH
   `undef ENCODED_IC_RX_BUFFER_DEPTH
   `undef ENCODED_IC_TX_BUFFER_DEPTH
   `undef HC_REG_TIMEOUT_VALUE
   `undef I2C_DYNAMIC_TAR_UPDATE
   `undef IC_10BITADDR_MASTER
   `undef IC_10BITADDR_SLAVE
   `undef IC_ACK_GENERAL_CALL_OS
   `undef IC_ACK_GENERAL_CALL_RS
   `undef IC_ADDR_SLICE_LHS
   `undef IC_ADD_ENCODED_PARAMS
   `undef IC_AVOID_RX_FIFO_FLUSH_ON_TX_ABRT
   `undef IC_BUS_CLEAR_FEATURE
   `undef IC_CAP_LOADING
   `undef IC_CLK_FREQ
   `undef IC_CLK_FREQ_OPTIMIZATION
   `undef IC_CLK_TYPE
   `undef IC_CLOCK_PERIOD
   `undef IC_CLR_ACTIVITY_OS
   `undef IC_CLR_ACTIVITY_RS
   `undef IC_CLR_GEN_CALL_OS
   `undef IC_CLR_GEN_CALL_RS
   `undef IC_CLR_INTR_OS
   `undef IC_CLR_INTR_RS
   `undef IC_CLR_RD_REQ_OS
   `undef IC_CLR_RD_REQ_RS
   `undef IC_CLR_RESTART_DET_RS
   `undef IC_CLR_RX_DONE_OS
   `undef IC_CLR_RX_DONE_RS
   `undef IC_CLR_RX_OVER_OS
   `undef IC_CLR_RX_OVER_RS
   `undef IC_CLR_RX_UNDER_OS
   `undef IC_CLR_RX_UNDER_RS
   `undef IC_CLR_START_DET_OS
   `undef IC_CLR_START_DET_RS
   `undef IC_CLR_STOP_DET_OS
   `undef IC_CLR_STOP_DET_RS
   `undef IC_CLR_TX_ABRT_OS
   `undef IC_CLR_TX_ABRT_RS
   `undef IC_CLR_TX_OVER_OS
   `undef IC_CLR_TX_OVER_RS
   `undef IC_COMP_PARAM_1_IN
   `undef IC_COMP_PARAM_1_OS
   `undef IC_COMP_PARAM_UFM_1_IN
   `undef IC_COMP_TYPE_OS
   `undef IC_COMP_VERSION_OS
   `undef IC_CON_IN
   `undef IC_CON_OS
   `undef IC_CON_RS
   `undef IC_DATA_CMD_OS
   `undef IC_DATA_CMD_RS
   `undef IC_DATA_FIFO_RS
   `undef IC_DATA_RS
   `undef IC_DATA_TX_CMD_RS
   `undef IC_DEFAULT_ACK_GENERAL_CALL
   `undef IC_DEFAULT_FS_SPKLEN
   `undef IC_DEFAULT_HS_SPKLEN
   `undef IC_DEFAULT_SDA_HOLD
   `undef IC_DEFAULT_SDA_RX_HOLD
   `undef IC_DEFAULT_SDA_SETUP
   `undef IC_DEFAULT_SDA_TX_HOLD
   `undef IC_DEFAULT_SLAVE_ADDR
   `undef IC_DEFAULT_TAR_SLAVE_ADDR
   `undef IC_DEFAULT_UFM_SPKLEN
   `undef IC_DEVICE_ID
   `undef IC_DEVICE_ID_BYTE
   `undef IC_DEVICE_ID_VALUE
   `undef IC_DMA_CR_OS
   `undef IC_DMA_CR_RS
   `undef IC_DMA_RDLR_OS
   `undef IC_DMA_RDLR_RS
   `undef IC_DMA_TDLR_OS
   `undef IC_DMA_TDLR_RS
   `undef IC_EMPTYFIFO_HOLD_MASTER_EN
   `undef IC_ENABLE_IN
   `undef IC_ENABLE_OS
   `undef IC_ENABLE_RS
   `undef IC_ENABLE_RS_INT
   `undef IC_ENABLE_STATUS_OS
   `undef IC_ENABLE_STATUS_RS
   `undef IC_FIRST_DATA_BYTE_STATUS
   `undef IC_FS_HCNT_IN
   `undef IC_FS_HCNT_OS
   `undef IC_FS_HCNT_RS
   `undef IC_FS_LCNT_IN
   `undef IC_FS_LCNT_OS
   `undef IC_FS_LCNT_RS
   `undef IC_FS_MAX_SPKLEN
   `undef IC_FS_SCL_HIGH_COUNT
   `undef IC_FS_SCL_LOW_COUNT
   `undef IC_FS_SPKLEN_LO_LIMIT
   `undef IC_FS_SPKLEN_OS
   `undef IC_FS_SPKLEN_RS
   `undef IC_GENERAL_CALL
   `undef IC_HAS_APB3_IF_SIGNALS
   `undef IC_HAS_ASYNC_CLK
   `undef IC_HAS_ASYNC_FIFO
   `undef IC_HAS_DMA
   `undef IC_HAS_POSITIVE_REG_TIMEOUT_WIDTH
   `undef IC_HAS_SLVERR_RESP_EN
   `undef IC_HCNT_LO_LIMIT
   `undef IC_HC_COUNT_VALUES
   `undef IC_HIGHSPEED_MODE_EN
   `undef IC_HS_CODE
   `undef IC_HS_HCNT_IN
   `undef IC_HS_HCNT_OS
   `undef IC_HS_HCNT_RS
   `undef IC_HS_LCNT_IN
   `undef IC_HS_LCNT_OS
   `undef IC_HS_LCNT_RS
   `undef IC_HS_MADDR_IN
   `undef IC_HS_MADDR_OS
   `undef IC_HS_MADDR_RS
   `undef IC_HS_MASTER_CODE
   `undef IC_HS_MAX_SPKLEN
   `undef IC_HS_SCL_HIGH_COUNT
   `undef IC_HS_SCL_LOW_COUNT
   `undef IC_HS_SPKLEN_LO_LIMIT
   `undef IC_HS_SPKLEN_OS
   `undef IC_HS_SPKLEN_RS
   `undef IC_INTR_IO
   `undef IC_INTR_MASK_OS
   `undef IC_INTR_MASK_RS
   `undef IC_INTR_POL
   `undef IC_INTR_STAT_OS
   `undef IC_INTR_STAT_RS
   `undef IC_LCNT_LO_LIMIT
   `undef IC_MASTER_MODE
   `undef IC_MAX_SPEED_MODE
   `undef IC_OPTIONAL_SAR
   `undef IC_OPTIONAL_SAR_DEFAULT
   `undef IC_PERSISTANT_SLV_ADDR_DEFAULT
   `undef IC_RAND_SEED
   `undef IC_RAW_INTR_STAT_OS
   `undef IC_RAW_INTR_STAT_RS
   `undef IC_RESTART_EN
   `undef IC_RUN_FOR_ONE_HOUR
   `undef IC_RXFLR_OS
   `undef IC_RX_BUFFER_DEPTH
   `undef IC_RX_BUFFER_MOD_DEPTH
   `undef IC_RX_FULL_GEN_NACK
   `undef IC_RX_FULL_HLD_BUS_EN
   `undef IC_RX_TL
   `undef IC_RX_TL_IN
   `undef IC_RX_TL_OS
   `undef IC_RX_TL_RS
   `undef IC_SAR_IN
   `undef IC_SAR_OPT_IN
   `undef IC_SAR_OPT_RS
   `undef IC_SAR_OS
   `undef IC_SAR_RS
   `undef IC_SCL_SDA_TIMEOUT_RS
   `undef IC_SCL_STUCK_TIMEOUT_DEFAULT
   `undef IC_SDA_HOLD_OS
   `undef IC_SDA_HOLD_RS
   `undef IC_SDA_RX_HOLD_RS
   `undef IC_SDA_SETUP_OS
   `undef IC_SDA_SETUP_RS
   `undef IC_SDA_STUCK_TIMEOUT_DEFAULT
   `undef IC_SDA_TX_HOLD_RS
   `undef IC_SLAVE_DISABLE
   `undef IC_SLV_ADDR_10BIT
   `undef IC_SLV_DATA_NACK_ONLY
   `undef IC_SLV_DATA_NACK_ONLY_RS
   `undef IC_SLV_RESTART_DET_EN
   `undef IC_SMBUS
   `undef IC_SMBUS_ARP
   `undef IC_SMBUS_ASSGN_ADDR_CMD
   `undef IC_SMBUS_CLK_LOW_MEXT_DEFAULT
   `undef IC_SMBUS_CLK_LOW_SEXT_DEFAULT
   `undef IC_SMBUS_CON_EXT_RS
   `undef IC_SMBUS_DEVICE_DEFAULT_ADDRESS
   `undef IC_SMBUS_GEN_GET_UDID_CMD
   `undef IC_SMBUS_GEN_RESET_CMD
   `undef IC_SMBUS_HAS_UDID_HC
   `undef IC_SMBUS_HOST_SLAVE_ADDRESS
   `undef IC_SMBUS_INTR_RS
   `undef IC_SMBUS_PREPARE_TO_ARP_CMD
   `undef IC_SMBUS_RD_DEVICE_DEFAULT_ADDRESS
   `undef IC_SMBUS_RST_IDLE_CNT_DEFAULT
   `undef IC_SMBUS_RST_IDLE_CNT_RS
   `undef IC_SMBUS_SUSPEND_ALERT
   `undef IC_SMBUS_SUS_ALERT_RS
   `undef IC_SMBUS_TIMEOUT_RS
   `undef IC_SMBUS_UDID_BYTE_COUNT
   `undef IC_SMBUS_UDID_BYTE_COUNT_LOG2
   `undef IC_SMBUS_UDID_BYTE_COUNT_PLS1
   `undef IC_SMBUS_UDID_HC
   `undef IC_SMBUS_UDID_LSB_DEFAULT
   `undef IC_SMBUS_UDID_LSB_RS
   `undef IC_SMBUS_UDID_MSB
   `undef IC_SMBUS_UDID_RS
   `undef IC_SPEED_SIM
   `undef IC_SPKLEN_RS
   `undef IC_SRESET_RS
   `undef IC_SS_HCNT_IN
   `undef IC_SS_HCNT_OS
   `undef IC_SS_HCNT_RS
   `undef IC_SS_LCNT_IN
   `undef IC_SS_LCNT_OS
   `undef IC_SS_LCNT_RS
   `undef IC_SS_SCL_HIGH_COUNT
   `undef IC_SS_SCL_LOW_COUNT
   `undef IC_START_BYTE
   `undef IC_STATUS_IN
   `undef IC_STATUS_OS
   `undef IC_STATUS_RS
   `undef IC_STAT_FOR_CLK_STRETCH
   `undef IC_STOP_DET_IF_MASTER_ACTIVE
   `undef IC_SYNC_DEPTH
   `undef IC_TAR_IN
   `undef IC_TAR_IN_RAL
   `undef IC_TAR_OS
   `undef IC_TAR_RS
   `undef IC_TAR_RS_INT
   `undef IC_TXFLR_OS
   `undef IC_TX_ABRT_SOURCE_OS
   `undef IC_TX_ABRT_SOURCE_RS
   `undef IC_TX_BUFFER_DEPTH
   `undef IC_TX_BUFFER_MOD_DEPTH
   `undef IC_TX_CMD_BLOCK
   `undef IC_TX_CMD_BLOCK_DEFAULT
   `undef IC_TX_TL
   `undef IC_TX_TL_IN
   `undef IC_TX_TL_OS
   `undef IC_TX_TL_RS
   `undef IC_UFM_SCL_HIGH_COUNT
   `undef IC_UFM_SCL_LOW_COUNT
   `undef IC_UFM_TBUF_CNT_DEFAULT
   `undef IC_ULTRA_FAST_MODE
   `undef IC_USE_COUNTS
   `undef IC_VERIF_EN
   `undef IC_VERSION_ID
   `undef IC_VERSION_ID_IN
   `undef IC_VERSION_ID_RS
   `undef IC_VMT_MODEL_INCLUDED
   `undef IDENT
   `undef MAX_APB_DATA_WIDTH
   `undef POW_2_REG_TIMEOUT_WIDTH
   `undef REG_TIMEOUT_RST_OS
   `undef REG_TIMEOUT_VALUE
   `undef REG_TIMEOUT_WIDTH
   `undef RM_BCM01
   `undef RM_BCM02
   `undef RM_BCM03
   `undef RM_BCM05
   `undef RM_BCM05_ATV
   `undef RM_BCM06
   `undef RM_BCM06_ATV
   `undef RM_BCM07
   `undef RM_BCM07_ATV
   `undef RM_BCM08
   `undef RM_BCM09
   `undef RM_BCM09_DP
   `undef RM_BCM09_ECC
   `undef RM_BCM10
   `undef RM_BCM11
   `undef RM_BCM12
   `undef RM_BCM15
   `undef RM_BCM16
   `undef RM_BCM21
   `undef RM_BCM21_A
   `undef RM_BCM21_ATV
   `undef RM_BCM21_CG
   `undef RM_BCM22
   `undef RM_BCM22_ATV
   `undef RM_BCM23
   `undef RM_BCM23_ATV
   `undef RM_BCM24
   `undef RM_BCM24_AP
   `undef RM_BCM25
   `undef RM_BCM25_ATV
   `undef RM_BCM26
   `undef RM_BCM27
   `undef RM_BCM28
   `undef RM_BCM29
   `undef RM_BCM30
   `undef RM_BCM31
   `undef RM_BCM32
   `undef RM_BCM35
   `undef RM_BCM36
   `undef RM_BCM36_NHS
   `undef RM_BCM37
   `undef RM_BCM38
   `undef RM_BCM38_ADP
   `undef RM_BCM38_AP
   `undef RM_BCM38_ECC
   `undef RM_BCM39
   `undef RM_BCM40
   `undef RM_BCM41
   `undef RM_BCM42
   `undef RM_BCM43
   `undef RM_BCM43_NRO
   `undef RM_BCM44
   `undef RM_BCM44_NRO
   `undef RM_BCM46_A
   `undef RM_BCM46_AA
   `undef RM_BCM46_B
   `undef RM_BCM46_C
   `undef RM_BCM46_D
   `undef RM_BCM46_E
   `undef RM_BCM47
   `undef RM_BCM48
   `undef RM_BCM48_DM
   `undef RM_BCM48_SV
   `undef RM_BCM49
   `undef RM_BCM49_SV
   `undef RM_BCM50
   `undef RM_BCM51
   `undef RM_BCM52
   `undef RM_BCM53
   `undef RM_BCM54
   `undef RM_BCM55
   `undef RM_BCM56
   `undef RM_BCM57
   `undef RM_BCM58
   `undef RM_BCM59
   `undef RM_BCM60
   `undef RM_BCM62
   `undef RM_BCM63
   `undef RM_BCM64
   `undef RM_BCM64_TD
   `undef RM_BCM65
   `undef RM_BCM65_ATV
   `undef RM_BCM65_TD
   `undef RM_BCM66
   `undef RM_BCM71
   `undef RM_BCM72
   `undef RM_BCM73
   `undef RM_BCM74
   `undef RM_BCM76
   `undef RM_BCM85
   `undef RM_BCM86
   `undef RM_BCM87
   `undef RM_BCM90
   `undef RM_BCM95
   `undef RM_BCM95_E
   `undef RM_BCM95_I
   `undef RM_BCM95_IE
   `undef RM_BCM98
   `undef RM_BCM99
   `undef RM_BCM99_N
   `undef RM_BVM01
   `undef RM_BVM02
   `undef RM_SVA01
   `undef RM_SVA02
   `undef RM_SVA03
   `undef RM_SVA04
   `undef RM_SVA05
   `undef RM_SVA06
   `undef RM_SVA07
   `undef RM_SVA99
   `undef RX_ABW
   `undef RX_ABW_P1
   `undef SLAVE_INTERFACE_TYPE
   `undef SLVERR_RESP_EN
   `undef SMB_ALERT_ADDRESS
   `undef SYNC
   `undef TX_ABW
   `undef TX_ABW_P1
`define cb_dummy_parameter_definition 1
`undef  cb_dummy_parameter_definition

//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm21.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm21.v#11 $
// Author      : Doug Lee    2/20/05
// Description : DW_apb_i2c_bcm21.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: ac735329
//
////////////////////////////////////////////////////////////////////////////////



module DW_apb_i2c_bcm21 (
    clk_d,
    rst_d_n,
    data_s,
    data_d
    );

parameter WIDTH        = 1;  // RANGE 1 to 1024
parameter F_SYNC_TYPE  = 2;  // RANGE 0 to 4
parameter VERIF_EN     = 1;  // RANGE 0 to 5
parameter SVA_TYPE     = 1;


input                   clk_d;      // clock input from destination domain
input                   rst_d_n;    // active low asynchronous reset from destination domain
input  [WIDTH-1:0]      data_s;     // data to be synchronized from source domain
output [WIDTH-1:0]      data_d;     // data synchronized to destination domain



wire   [WIDTH-1:0]      data_s_int;

`ifndef SYNTHESIS
  `ifdef DWC_BCM_SNPS_ASSERT_ON
wire                    clk_d_stopped;
    `ifndef DWC_BCM_SV
wire   [63:0]           clk_d_period;
    `else
real                    clk_d_period;
    `endif
  `else
    `ifdef DW_MODEL_MISSAMPLES
wire                    clk_d_stopped;
      `ifndef DWC_BCM_SV
wire   [63:0]           clk_d_period;
      `else
real                    clk_d_period;
      `endif
    `endif
  `endif
`endif


`ifndef SYNTHESIS
`ifndef DWC_DISABLE_CDC_METHOD_REPORTING
  initial begin
    if ((F_SYNC_TYPE > 0)&&(F_SYNC_TYPE < 8))
       $display("Information: *** Instance %m module is using the <Double Register Synchronizer (1)> Clock Domain Crossing Method ***");
  end

`endif
`endif



`ifdef SYNTHESIS
  assign data_s_int = data_s;
`else
  `ifdef DW_MODEL_MISSAMPLES
  initial begin
    $display("Information: %m: *** Running with DW_MODEL_MISSAMPLES defined, VERIF_EN is: %0d ***",
                        VERIF_EN);
  end

reg  [WIDTH-1:0]        last_data_dyn, data_s_delta_t;
reg  [WIDTH-1:0]        last_data_s, last_data_s_q, last_data_s_qq;
reg  [WIDTH-1:0]        data_select; initial data_select = 0;




  generate if ((VERIF_EN % 2) == 1) begin : GEN_HO_VE_ODD
    if ((F_SYNC_TYPE & 7) == 1) begin : GEN_HO_FST_EQ_1
      always @ (negedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_EVEN
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (negedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_EVEN
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
    end else begin : GEN_HO_FST_NE_1
      always @ (posedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_EVEN
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (posedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_EVEN
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
    end
  end else begin : GEN_HO_VE_EVEN
    if ((F_SYNC_TYPE & 7) == 1) begin : GEN_HO_FST_EQ_1
      always @ (posedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_ODD
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (posedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_ODD
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
    end else begin : GEN_HO_FST_NE_1
      always @ (negedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_ODD
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (negedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_ODD
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
    end
  end endgenerate

  generate if ((F_SYNC_TYPE & 7) == 1) begin : GEN_LDSQ_FST_EQ_1
    always @ (negedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_even
      if (rst_d_n == 1'b0) begin
        last_data_s_q  <= {WIDTH{1'b0}};
      end else begin
        if (clk_d_stopped == 1'b1)
          last_data_s_q <= data_s;
        else
          last_data_s_q <= last_data_s;
      end
    end // PROC_missample_hist_even
  end else begin : GEN_LDSQ_FST_NE_1
    always @ (posedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_even
      if (rst_d_n == 1'b0) begin
        last_data_s_q  <= {WIDTH{1'b0}};
      end else begin
        if (clk_d_stopped == 1'b1)
          last_data_s_q <= data_s;
        else
          last_data_s_q <= last_data_s;
      end
    end // PROC_missample_hist_even
  end endgenerate


  generate if (VERIF_EN == 0) begin : GEN_DSI_VE_EQ_0

    assign data_s_int = data_s;

  end else if ((VERIF_EN == 2) || (VERIF_EN == 3)) begin : GEN_DSI_VE_EQ_2_OR_3

    reg  [WIDTH-1:0] data_select_2; initial data_select_2 = 0;
    wire [WIDTH-1:0] data_s_sel_0, data_s_sel_1;
    if (WIDTH <= 32) begin : GEN_D_SEL_W_LTE_32
      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s) begin
  `ifdef DWC_BCM_SV
          data_select = $urandom;
          data_select_2 = $urandom;
  `else
          data_select = $random;
          data_select_2 = $random;
  `endif
        end
      end  // PROC_mk_next_data_select
    end else begin : GEN_D_SEL_W_GT_32
  function [WIDTH-1:0] wide_random;
    input [31:0]        in_width;   // should match "WIDTH" parameter -- need one input to satisfy Verilog function requirement

    reg   [WIDTH-1:0]   temp_result;
    reg   [31:0]        rand_slice;
    integer             i, j, base;


    begin
`ifdef DWC_BCM_SV
      temp_result = $urandom;
`else
      temp_result = $random;
`endif
      if (((WIDTH / 32) + 1) > 1) begin
        for (i=1 ; i < ((WIDTH / 32) + 1) ; i=i+1) begin
          base = i << 5;
`ifdef DWC_BCM_SV
          rand_slice = $urandom;
`else
          rand_slice = $random;
`endif
          for (j=0 ; ((j < 32) && (base+j < in_width)) ; j=j+1) begin
            temp_result[base+j] = rand_slice[j];
          end
        end
      end

      wide_random = temp_result;
    end
  endfunction  // wide_random

  initial begin : seed_random_PROC
    integer seed, init_rand;
    `ifdef DW_MISSAMPLE_SEED
      if (`DW_MISSAMPLE_SEED != 0)
        seed = `DW_MISSAMPLE_SEED;
      else
        seed = 32'h0badbeef;
    `else
      seed = 32'h0badbeef;
    `endif

`ifdef DWC_BCM_SV
    init_rand = $urandom(seed);
`else
    init_rand = $random(seed);
`endif
  end // seed_random_PROC

      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s) begin
          data_select = wide_random(WIDTH);
          data_select_2 = wide_random(WIDTH);
        end
      end  // PROC_mk_next_data_select
    end
    assign data_s_sel_0 = (clk_d_stopped==1'b1) ? data_s : ((data_s & ~data_select) | (last_data_dyn & data_select));
    assign data_s_sel_1 = (clk_d_stopped==1'b1) ? data_s : ((last_data_s_q & ~data_select) | (last_data_s_qq & data_select));
    assign data_s_int = ((data_s_sel_0 & ~data_select_2) | (data_s_sel_1 & data_select_2));

  end else begin : GEN_DSI_VE_EQ_1_OR_4_OR_5

    if (WIDTH <= 32) begin : GEN_D_SEL_W_LTE_32
      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s)
  `ifdef DWC_BCM_SV
          data_select = $urandom;
  `else
          data_select = $random;
  `endif
      end  // PROC_mk_next_data_select
    end else begin : GEN_D_SEL_W_GT_32
  function [WIDTH-1:0] wide_random;
    input [31:0]        in_width;   // should match "WIDTH" parameter -- need one input to satisfy Verilog function requirement

    reg   [WIDTH-1:0]   temp_result;
    reg   [31:0]        rand_slice;
    integer             i, j, base;


    begin
`ifdef DWC_BCM_SV
      temp_result = $urandom;
`else
      temp_result = $random;
`endif
      if (((WIDTH / 32) + 1) > 1) begin
        for (i=1 ; i < ((WIDTH / 32) + 1) ; i=i+1) begin
          base = i << 5;
`ifdef DWC_BCM_SV
          rand_slice = $urandom;
`else
          rand_slice = $random;
`endif
          for (j=0 ; ((j < 32) && (base+j < in_width)) ; j=j+1) begin
            temp_result[base+j] = rand_slice[j];
          end
        end
      end

      wide_random = temp_result;
    end
  endfunction  // wide_random

  initial begin : seed_random_PROC
    integer seed, init_rand;
    `ifdef DW_MISSAMPLE_SEED
      if (`DW_MISSAMPLE_SEED != 0)
        seed = `DW_MISSAMPLE_SEED;
      else
        seed = 32'h0badbeef;
    `else
      seed = 32'h0badbeef;
    `endif

`ifdef DWC_BCM_SV
    init_rand = $urandom(seed);
`else
    init_rand = $random(seed);
`endif
  end // seed_random_PROC

      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s)
          data_select = wide_random(WIDTH);
      end  // PROC_mk_next_data_select
    end
    assign data_s_int = (clk_d_stopped==1'b1) ? data_s : (data_s & ~data_select) | (last_data_dyn & data_select);

  end endgenerate

// { START Latency Accurate modeling
  initial begin : set_setup_hold_delay_PROC
    `ifndef DW_HOLD_MUX_DELAY
      `define DW_HOLD_MUX_DELAY  1
      if (((F_SYNC_TYPE & 7) == 2) && (VERIF_EN == 5))
        $display("Information: %m: *** Warning: `DW_HOLD_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_HOLD_MUX_DELAY);
    `endif

    `ifndef DW_SETUP_MUX_DELAY
      `define DW_SETUP_MUX_DELAY  1
      if (((F_SYNC_TYPE & 7) == 2) && (VERIF_EN == 5))
        $display("Information: %m: *** Warning: `DW_SETUP_MUX_DELAY is not defined so it is being set to: %0d ***", `DW_SETUP_MUX_DELAY);
    `endif
  end // set_setup_hold_delay_PROC

  initial begin
    if (((F_SYNC_TYPE & 7) == 2) && (VERIF_EN == 5))
      $display("Information: %m: *** Running with Latency Accurate MISSAMPLES defined, VERIF_EN is: %0d ***", VERIF_EN);
  end

  reg [WIDTH-1:0] setup_mux_ctrl, hold_mux_ctrl;
  initial setup_mux_ctrl = {WIDTH{1'b0}};
  initial hold_mux_ctrl  = {WIDTH{1'b0}};
  
  wire [WIDTH-1:0] data_s_q;
  reg clk_d_q;
  initial clk_d_q = 1'b0;
  reg [WIDTH-1:0] setup_mux_out, d_muxout;
  reg [WIDTH-1:0] d_ff1, d_ff2;
  integer i,j,k;
  
  
  //Delay the destination clock
  always @ (posedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b1;

  always @ (negedge clk_d)
  #`DW_HOLD_MUX_DELAY clk_d_q = 1'b0;
  
  //Delay the source data
  assign #`DW_SETUP_MUX_DELAY data_s_q = (!rst_d_n) ? {WIDTH{1'b0}}:data_s;

  //setup_mux_ctrl controls the data entering the flip flop 
  always @ (data_s or data_s_q or setup_mux_ctrl) begin
    for (i=0;i<=WIDTH-1;i=i+1) begin
      if (setup_mux_ctrl[i])
        setup_mux_out[i] = data_s_q[i];
      else
        setup_mux_out[i] = data_s[i];
    end
  end

  always @ (posedge clk_d_q or negedge rst_d_n) begin
    if (rst_d_n == 1'b0)
      d_ff2 <= {WIDTH{1'b0}};
    else
      d_ff2 <= setup_mux_out;
  end

  always @ (posedge clk_d or negedge rst_d_n) begin
    if (rst_d_n == 1'b0) begin
      d_ff1          <= {WIDTH{1'b0}};
      setup_mux_ctrl <= {WIDTH{1'b0}};
      hold_mux_ctrl  <= {WIDTH{1'b0}};
    end
    else begin
      d_ff1          <= setup_mux_out;
    `ifdef DWC_BCM_SV
      setup_mux_ctrl <= $urandom;  //randomize mux_ctrl
      hold_mux_ctrl  <= $urandom;  //randomize mux_ctrl
    `else
      setup_mux_ctrl <= $random;  //randomize mux_ctrl
      hold_mux_ctrl  <= $random;  //randomize mux_ctrl
    `endif
    end
  end


//hold_mux_ctrl decides the clock triggering the flip-flop
always @(hold_mux_ctrl or d_ff2 or d_ff1) begin
      for (k=0;k<=WIDTH-1;k=k+1) begin
        if (hold_mux_ctrl[k])
          d_muxout[k] = d_ff2[k];
        else
          d_muxout[k] = d_ff1[k];
      end
end
// END Latency Accurate modeling }


 //Assertions
`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS
generate if ( ((F_SYNC_TYPE & 7) == 2) && (VERIF_EN == 5) ) begin : GEN_ASSERT_FST2_VE5
  sequence p_num_d_chng;
  @ (posedge clk_d) 1'b1 ##0 (data_s != d_ff1); //Number of times input data changed
  endsequence
  
  sequence p_num_d_chng_hmux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))); //Number of times hold_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_num_d_chng_smux1;
  @ (posedge clk_d) 1'b1 ##0 ((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))); //Number of times setup_mux_ctrl was asserted when the input data changed
  endsequence
  
  sequence p_hold_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(hold_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(hold_mux_ctrl & (data_s ^ d_ff1))) ##1 ((data_d & temp_var1) == (temp_var & temp_var1));
          //Number of times output data was advanced due to hold violation
  endsequence
  
  sequence p_setup_vio;
  reg [WIDTH-1:0]temp_var, temp_var1;
  @ (posedge clk_d) (((data_s != d_ff1) && (|(setup_mux_ctrl & (data_s ^ d_ff1)))), temp_var = data_s, temp_var1 =(setup_mux_ctrl & (data_s ^ d_ff1))) ##2 ((data_d & temp_var1) != (temp_var & temp_var1));
          //Number of times output data was delayed due to setup violation
  endsequence

  cp_num_d_chng           : cover property  (p_num_d_chng);    
  cp_num_d_chng_hld_mux1  : cover property  (p_num_d_chng_hmux1);
  cp_num_d_chng_set_mux1  : cover property  (p_num_d_chng_smux1);
  cp_hold_vio             : cover property  (p_hold_vio);
  cp_setup_vio            : cover property  (p_setup_vio);        
 end
endgenerate
`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

  `else
  assign data_s_int = data_s;
  `endif
`endif


// spyglass disable_block Ac_glitch03
// SMD: Reports clock domain crossings subject to glitches
// SJ: The possible glitch only occur in test mode, which does not affect the normal function.
// spyglass disable_block Ac_conv04
// SMD: Checks all the control-bus clock domain crossings which do not follow gray encoding
// SJ: The clock domain crossing bus is between the register file and the read-mux of a RAM, which do not need a gray encoding.

generate
    if ((F_SYNC_TYPE & 7) == 0) begin : GEN_FST0
      assign data_d  =  data_s;
    end
    if ((F_SYNC_TYPE & 7) == 1) begin : GEN_FST1
      reg    [WIDTH-1:0]      sample_meta_n;
      reg    [WIDTH-1:0]      sample_syncl;
      wire   [WIDTH-1:0]      next_sample_syncm1;
      wire   [WIDTH-1:0]      next_sample_syncl;

// spyglass disable_block Clock_check04
// SMD: Use rising edge flipflop
// SJ: The module was intentionally implemented to use negative edge clocking flip-flops cells.
      always @ (negedge clk_d or negedge rst_d_n) begin : negedge_registers_PROC
// spyglass enable_block Clock_check04
        if (rst_d_n == 1'b0) begin
          sample_meta_n    <= {WIDTH{1'b0}};
        end else begin
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
          sample_meta_n    <= data_s_int;
// spyglass enable_block W391
        end
      end

      assign next_sample_syncm1 = sample_meta_n;
      assign next_sample_syncl = next_sample_syncm1;

      always @ (posedge clk_d or negedge rst_d_n) begin : posedge_registers_PROC
        if (rst_d_n == 1'b0) begin
          sample_syncl     <= {WIDTH{1'b0}};
        end else begin
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
          sample_syncl     <= next_sample_syncl;
// spyglass enable_block W391
        end
      end

      assign data_d = sample_syncl;
    end
    if ((F_SYNC_TYPE & 7) == 2) begin : GEN_FST2
      reg    [WIDTH-1:0]      sample_meta;
      reg    [WIDTH-1:0]      sample_syncl;
      wire   [WIDTH-1:0]      next_sample_meta;
      wire   [WIDTH-1:0]      next_sample_syncm1;
      wire   [WIDTH-1:0]      next_sample_syncl;

      assign next_sample_meta      = data_s_int;

`ifdef SYNTHESIS
      assign next_sample_syncm1 = sample_meta;
`else
  `ifdef DW_MODEL_MISSAMPLES
      if (((F_SYNC_TYPE & 7) == 2) && (VERIF_EN == 5)) begin : GEN_NXT_SMPL_SM1_FST2_VE5
        assign next_sample_syncm1 = d_muxout;
      end else begin : GEN_NXT_SMPL_SM1_ELSE
        assign next_sample_syncm1 = sample_meta;
      end
  `else
        assign next_sample_syncm1 = sample_meta;
  `endif
`endif
      assign next_sample_syncl = next_sample_syncm1;
      always @ (posedge clk_d or negedge rst_d_n) begin : posedge_registers_PROC
        if (rst_d_n == 1'b0) begin
          sample_meta     <= {WIDTH{1'b0}};
          sample_syncl     <= {WIDTH{1'b0}};
        end else begin
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
          sample_meta     <= next_sample_meta;
          sample_syncl     <= next_sample_syncl;
// spyglass enable_block W391
        end
      end

      assign data_d = sample_syncl;
    end
    if ((F_SYNC_TYPE & 7) == 3) begin : GEN_FST3
      reg    [WIDTH-1:0]      sample_meta;
      reg    [WIDTH-1:0]      sample_syncm1;
      reg    [WIDTH-1:0]      sample_syncl;
      wire   [WIDTH-1:0]      next_sample_meta;
      wire   [WIDTH-1:0]      next_sample_syncm1;
      wire   [WIDTH-1:0]      next_sample_syncl;

      assign next_sample_meta      = data_s_int;

      assign next_sample_syncm1 = sample_meta;
      assign next_sample_syncl  = sample_syncm1;
      always @ (posedge clk_d or negedge rst_d_n) begin : posedge_registers_PROC
        if (rst_d_n == 1'b0) begin
          sample_meta     <= {WIDTH{1'b0}};
          sample_syncm1    <= {WIDTH{1'b0}};
          sample_syncl     <= {WIDTH{1'b0}};
        end else begin
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
          sample_meta     <= next_sample_meta;
          sample_syncm1    <= next_sample_syncm1;
          sample_syncl     <= next_sample_syncl;
// spyglass enable_block W391
        end
      end

      assign data_d = sample_syncl;
    end
    if ((F_SYNC_TYPE & 7) == 4) begin : GEN_FST4
      reg    [WIDTH-1:0]      sample_meta;
      reg    [WIDTH-1:0]      sample_syncm1;
      reg    [WIDTH-1:0]      sample_syncm2;
      reg    [WIDTH-1:0]      sample_syncl;
      wire   [WIDTH-1:0]      next_sample_meta;
      wire   [WIDTH-1:0]      next_sample_syncm1;
      wire   [WIDTH-1:0]      next_sample_syncm2;
      wire   [WIDTH-1:0]      next_sample_syncl;

      assign next_sample_meta      = data_s_int;

      assign next_sample_syncm1 = sample_meta;
      assign next_sample_syncm2 = sample_syncm1;
      assign next_sample_syncl  = sample_syncm2;
      always @ (posedge clk_d or negedge rst_d_n) begin : posedge_registers_PROC
        if (rst_d_n == 1'b0) begin
          sample_meta     <= {WIDTH{1'b0}};
          sample_syncm1    <= {WIDTH{1'b0}};
          sample_syncm2    <= {WIDTH{1'b0}};
          sample_syncl     <= {WIDTH{1'b0}};
        end else begin
// spyglass disable_block W391
// SMD: Design has a clock driving it on both edges
// SJ: This module is configured such that both edges of the same clock are used for different flip-flops.
          sample_meta     <= next_sample_meta;
          sample_syncm1    <= next_sample_syncm1;
          sample_syncm2    <= next_sample_syncm2;
          sample_syncl     <= next_sample_syncl;
// spyglass enable_block W391
        end
      end

      assign data_d = sample_syncl;
    end
endgenerate



// spyglass enable_block Ac_glitch03
// spyglass enable_block Ac_conv04

`ifndef SYNTHESIS
  `ifdef DWC_BCM_SNPS_ASSERT_ON

`ifdef DWC_BCM_CDC_COVERAGE_REPORT
  generate if (SVA_TYPE == 0) begin : CDC_COVERAGE_REPORT
    reg clk_d_mod;
    reg rst_n_mod;

    assign clk_d_mod = (F_SYNC_TYPE==1) ? ~clk_d : clk_d;

    genvar i;
    for (i=0; i<WIDTH; i=i+1) begin : DATA_S
      property LtoHMonitor;
        @(posedge clk_d_mod) disable iff (!rst_d_n 
 
 
                                         )
          $rose(data_s[i]);
      endproperty
      COVER_LOW_TO_HIGH_TRANSITION: cover property (LtoHMonitor);

      property HtoLMonitor;
        @(posedge clk_d_mod) disable iff (!rst_d_n 
 
 
                                         )
          $fell(data_s[i]);
      endproperty
      COVER_HIGH_TO_LOW_TRANSITION: cover property (HtoLMonitor);
    end
  end endgenerate
`endif


  generate
    if (SVA_TYPE == 0) begin : GEN_SVATP_EQ_0
    `ifdef DW_MODEL_MISSAMPLES
      DW_apb_i2c_bvm02
      
        U_CLK_DET (
        .clk         (clk_d        ),
        .rst_n       (rst_d_n      ),
        .clk_stopped (clk_d_stopped),
        .clk_period  (clk_d_period )
      );

    `endif
    end
    if (SVA_TYPE == 1) begin : GEN_SVATP_EQ_1
      DW_apb_i2c_bvm02
      
        U_CLK_DET (
        .clk         (clk_d        ),
        .rst_n       (rst_d_n      ),
        .clk_stopped (clk_d_stopped),
        .clk_period  (clk_d_period )
      );

      DW_apb_i2c_sva01 #(WIDTH, (F_SYNC_TYPE & 7)) P_SYNC_HS (.*);
    end
    if (SVA_TYPE == 2) begin : GEN_SVATP_EQ_2
    `ifdef DW_MODEL_MISSAMPLES
      DW_apb_i2c_bvm02
      
        U_CLK_DET (
        .clk         (clk_d        ),
        .rst_n       (rst_d_n      ),
        .clk_stopped (clk_d_stopped),
        .clk_period  (clk_d_period )
      );

    `endif
      DW_apb_i2c_sva05 #(WIDTH, (F_SYNC_TYPE & 7)) P_SYNC_GC (.*);
    end
  endgenerate
  `else
    `ifdef DW_MODEL_MISSAMPLES
  DW_apb_i2c_bvm02
   U_CLK_DET (
    .clk         (clk_d        ),
    .rst_n       (rst_d_n      ),
    .clk_stopped (clk_d_stopped),
    .clk_period  (clk_d_period )
  );
    `endif
  `endif
`endif


endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #19 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_sync.v#19 $ 
//
//
//
//
//
// File    : DW_apb_i2c_sync.v
// Author  : Hani Saleh
// Created : Sep, 2002
// Abstract: This module performs the synchronization of signals
//           Traveling from the pclk to the ic_clk domain
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

// -----------------------------------------------------------
// -- Macros
// -----------------------------------------------------------


module DW_apb_i2c_sync
  (
   ic_rst_n,
                         ic_clk,
                         //Signals from pclk domain
                         ic_enable,
                         ic_master,
                         ic_10bit_mst,
                         ic_hs,
                         ic_fs,
                         ic_ss,
                         tx_empty,
                         ic_10bit_slv,
                         ic_rstrt_en,
                         ic_slave_en,
                         p_det_ifaddr,
                         ic_sda_hold,
                         ic_ack_general_call,
                         //signals to ic_clk domain
                         ic_10bit_slv_sync,
                         ic_enable_sync,
                         ic_abort_sync,
                         ic_master_sync,
                         ic_hs_sync,
                         ic_fs_sync,
                         ic_ss_sync,
                         ic_10bit_mst_sync,
                         tx_empty_sync,
                         tx_empty_sync_hl,
                         ic_rstrt_en_sync,
                         ic_slave_en_sync,
                         p_det_ifaddr_sync, 
                         ic_ack_general_call_sync,
                         ic_sda_tx_hold_sync,
                         ic_sda_rx_hold_sync   
                         );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input ic_clk;    // module clock: runs i2c module
   input ic_rst_n;  // I2C module asynchronous reset input active low


   input [`IC_ENABLE_RS_INT-1:0] ic_enable; // logic 1: enable i2c module
   input ic_master; //logic 1: IC module is a Master; logic 0: slave
   input ic_10bit_mst; // logic 1: IC 10-bit address transfer mode
                       // logic 0: IC 7-bit address transfer mode
   input ic_10bit_slv; // logic 1: IC 10-bit address transfer mode
                       // logic 0: IC 7-bit address transfer modeg
   input ic_hs;  //logic 1: IC is in High Speed mode (3.4 Mb/s)
   input ic_fs;  //logic 1: IC is in Fast Speed mode (400 kb/s)
   input ic_ss;  //logic 1: IC is in Standard Speed mode (100 kb/s)
   input tx_empty; // tx fifo empty
   input                             ic_rstrt_en;//logic 1:Master can generate re-starts in general
   input                             ic_slave_en;//1: slave is enabled, 0:disabled
   input                             p_det_ifaddr;//Programmable option to generate STOP interrupt only if slave is addressed

// Adding IC_SDA_RX_HOLD_RS (8 bits) for calculating hold time while I2C acts as reciever
   input [`IC_SDA_HOLD_RS-1:0]         ic_sda_hold;
   input                               ic_ack_general_call;


   //outputs

   output tx_empty_sync;//tx_empty signal synchronized to ic_clk
   output ic_10bit_slv_sync ;//ic_10bit_slv signal synchronized to ic_clk
   output ic_enable_sync;//ic_enable signal synchronized to ic_clk
   output ic_abort_sync;//ic_abort signal synchronized to ic_clk
   output ic_master_sync;//ic_master signal synchronized to ic_clk
   output ic_hs_sync ;//ic_hs signal synchronized to ic_clk
   output ic_fs_sync ;//ic_fs signal synchronized to ic_clk
   output ic_ss_sync ;//ic_ss signal synchronized to ic_clk
   output ic_10bit_mst_sync;//ic_10bit_mst signal synchronized to ic_clk
   output ic_rstrt_en_sync;//logic 1:Master can generate re-starts in general
   output tx_empty_sync_hl;//logic 1:high to low edge detection of tx_empty_sync
   output ic_slave_en_sync;//1: slave is enabled, 0:disabled
   output p_det_ifaddr_sync;//Programmable option to generate STOP interrupt only if slave is addressed



   output [`IC_SDA_TX_HOLD_RS-1:0]         ic_sda_tx_hold_sync;  // SDA Hold time while I2C acts as transmitter
   output [`IC_SDA_RX_HOLD_RS-1:0]      ic_sda_rx_hold_sync;  // SDA Hold time while I2C acts as reciever
   output                               ic_ack_general_call_sync;

   // ----------------------------------------------------------
   // -- local registers
   // ----------------------------------------------------------
   reg              tx_empty_sync_r;

   // ----------------------------------------------------------
   // -- local wires
   // ----------------------------------------------------------
   wire      ic_10bit_slv_sync ;
   wire      ic_enable_sync;
   wire      ic_abort_sync;
   wire      ic_master_sync;
   wire      ic_hs_sync ;
   wire      ic_fs_sync ;
   wire      ic_ss_sync ;
   wire      ic_10bit_mst_sync ;
   wire      tx_empty_sync;
   wire      tx_empty_int;
   wire      ic_rstrt_en_sync;
   wire      ic_slave_en_sync;
   wire      p_det_ifaddr_sync;
   wire      ic_ack_general_call_sync;

   wire [`IC_SDA_HOLD_RS-1:0] ic_sda_hold_sync;

   wire [`IC_SDA_TX_HOLD_RS-1:0]         ic_sda_tx_hold_sync;
   wire [`IC_SDA_RX_HOLD_RS-1:0]      ic_sda_rx_hold_sync;



   // ----------------------------------------------------------
   // -- Synchronization registers for input from pclk domain
   // ----------------------------------------------------------

   wire [`IC_ENABLE_RS_INT-1:0] p2icl_ic_enable; 
   wire      sp2icl_ic_enable_sync;
   wire      sp2icl_ic_abort_sync;
   assign p2icl_ic_enable = ic_enable;
   assign ic_enable_sync = sp2icl_ic_enable_sync;
   assign ic_abort_sync = sp2icl_ic_abort_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_enable0_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_enable[0])
        ,.data_d              (sp2icl_ic_enable_sync)
      );

      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_enable1_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_enable[1])
        ,.data_d              (sp2icl_ic_abort_sync)
      );


   wire      p2icl_ic_ack_general_call;
   wire      sp2icl_ic_ack_general_call_sync;
   assign p2icl_ic_ack_general_call = ic_ack_general_call;
   assign ic_ack_general_call_sync = sp2icl_ic_ack_general_call_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_ack_general_call_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_ack_general_call)
        ,.data_d              (sp2icl_ic_ack_general_call_sync)
      );

      wire   ic_master_inv;
      wire   ic_master_sync_inv;
      assign ic_master_inv  = ~ic_master;
      assign ic_master_sync = ~ic_master_sync_inv;

      wire   p2icl_ic_master_inv;
      wire   sp2icl_ic_master_sync_inv;
      assign p2icl_ic_master_inv = ic_master_inv;
      assign ic_master_sync_inv = sp2icl_ic_master_sync_inv;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_master_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_master_inv)
        ,.data_d              (sp2icl_ic_master_sync_inv)
      );



   wire   ic_hs_inv;
   wire   ic_hs_sync_inv;
   assign ic_hs_inv  = ~ic_hs;
   assign ic_hs_sync = ~ic_hs_sync_inv;

   wire   p2icl_ic_hs_inv;
   wire   sp2icl_ic_hs_sync_inv;
   assign p2icl_ic_hs_inv = ic_hs_inv;
   assign ic_hs_sync_inv = sp2icl_ic_hs_sync_inv;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_hs_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_hs_inv)
        ,.data_d              (sp2icl_ic_hs_sync_inv)
      );


   wire      p2icl_ic_fs;
   wire      sp2icl_ic_fs_sync;
   assign p2icl_ic_fs = ic_fs;
   assign ic_fs_sync = sp2icl_ic_fs_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_fs_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_fs)
        ,.data_d              (sp2icl_ic_fs_sync)
      );


   wire      p2icl_ic_ss;
   wire      sp2icl_ic_ss_sync;
   assign p2icl_ic_ss = ic_ss;
   assign ic_ss_sync = sp2icl_ic_ss_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_ss_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_ss)
        ,.data_d              (sp2icl_ic_ss_sync)
      );

         wire   ic_10bit_mst_inv;
         wire   ic_10bit_mst_sync_inv;
         assign ic_10bit_mst_inv  = ~ic_10bit_mst;
         assign ic_10bit_mst_sync = ~ic_10bit_mst_sync_inv;

         wire   p2icl_ic_10bit_mst_inv;
         wire   sp2icl_ic_10bit_mst_sync_inv;
         assign p2icl_ic_10bit_mst_inv = ic_10bit_mst_inv;
         assign ic_10bit_mst_sync_inv = sp2icl_ic_10bit_mst_sync_inv;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_10bit_mst_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_10bit_mst_inv)
        ,.data_d              (sp2icl_ic_10bit_mst_sync_inv)
      );


         wire   tx_empty_inv;
         wire   tx_empty_int_inv;
         assign tx_empty_inv  = ~tx_empty;
         assign tx_empty_int  = ~tx_empty_int_inv;

         wire   p2icl_tx_empty_inv;
         wire   sp2icl_tx_empty_int_inv;
         assign p2icl_tx_empty_inv = tx_empty_inv;
         assign tx_empty_int_inv = sp2icl_tx_empty_int_inv;

      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_tx_empty_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_tx_empty_inv)
        ,.data_d              (sp2icl_tx_empty_int_inv)
      );

         wire   ic_10bit_slv_inv;
         wire   ic_10bit_slv_sync_inv;
         assign ic_10bit_slv_inv  = ~ic_10bit_slv;
         assign ic_10bit_slv_sync = ~ic_10bit_slv_sync_inv;

         wire   p2icl_ic_10bit_slv_inv;
         wire   sp2icl_ic_10bit_slv_sync_inv;
         assign p2icl_ic_10bit_slv_inv = ic_10bit_slv_inv;
         assign ic_10bit_slv_sync_inv = sp2icl_ic_10bit_slv_sync_inv;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_10bit_slv_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_10bit_slv_inv)
        ,.data_d              (sp2icl_ic_10bit_slv_sync_inv)
      );



         wire   ic_rstrt_en_inv;
         wire   ic_rstrt_en_sync_inv;
         assign ic_rstrt_en_inv  = ~ic_rstrt_en;
         assign ic_rstrt_en_sync = ~ic_rstrt_en_sync_inv;

         wire   p2icl_ic_rstrt_en_inv;
         wire   sp2icl_ic_rstrt_en_sync_inv;
         assign p2icl_ic_rstrt_en_inv = ic_rstrt_en_inv;
         assign ic_rstrt_en_sync_inv = sp2icl_ic_rstrt_en_sync_inv;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_rstrt_en_inv_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_rstrt_en_inv)
        ,.data_d              (sp2icl_ic_rstrt_en_sync_inv)
      );





         wire   p2icl_ic_slave_en;
         wire   sp2icl_ic_slave_en_sync;
         assign p2icl_ic_slave_en = ic_slave_en;
         assign ic_slave_en_sync = sp2icl_ic_slave_en_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_slave_en_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_slave_en)
        ,.data_d              (sp2icl_ic_slave_en_sync)
      );


         wire   p2icl_p_det_ifaddr;
         wire   sp2icl_p_det_ifaddr_sync;
         assign p2icl_p_det_ifaddr = p_det_ifaddr;
         assign p_det_ifaddr_sync = sp2icl_p_det_ifaddr_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_p_det_ifaddr_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_p_det_ifaddr)
        ,.data_d              (sp2icl_p_det_ifaddr_sync)
      );















  
   wire [`IC_SDA_HOLD_RS-1:0]         p2icl_ic_sda_hold;
   wire [`IC_SDA_HOLD_RS-1:0]         sp2icl_ic_sda_hold_sync;
   assign p2icl_ic_sda_hold = ic_sda_hold;
   assign ic_sda_hold_sync = sp2icl_ic_sda_hold_sync;
      DW_apb_i2c_bcm21
       #(
        .WIDTH       (`IC_SDA_HOLD_RS), 
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_p2icl_ic_sda_hold_icsyzr
      (
         .clk_d               (ic_clk)
        ,.rst_d_n             (ic_rst_n)
        ,.data_s              (p2icl_ic_sda_hold)
        ,.data_d              (sp2icl_ic_sda_hold_sync)
      );

  
   assign {ic_sda_rx_hold_sync, ic_sda_tx_hold_sync} = ic_sda_hold_sync;
   assign tx_empty_sync = tx_empty_int;

   // ----------------------------------------------------------
   // -- Edge detection circuitry for input from pclk domain
   // ----------------------------------------------------------
   always @(posedge ic_clk or negedge ic_rst_n) begin : EDGE_DET_PROC
      if(ic_rst_n == 1'b0) begin
         tx_empty_sync_r    <= 1'b1;
      end else begin
         tx_empty_sync_r    <= tx_empty_int;
      end
   end
   assign tx_empty_sync_hl =  ~tx_empty_int & tx_empty_sync_r;

//   assign ic_sda_hold_sync = (`IC_CLK_TYPE == `IDENT) ? ic_sda_hold : ic_sda_hold_sync1;













endmodule // DW_apb_i2c_sync
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #23 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_regfile.v#23 $ 
//
//
// File    : DW_apb_i2c_regfile.v
//
//
// Abstract: Register Block module for the DW_apb_i2c macrocell
//
// ------------------------------------------------------------

// ------------------------------------------------------------
// -- Register address offset macros
// -- All registers are on 32-bit boundaries
// ------------------------------------------------------------

`define IC_CON_OS             8'h00
`define IC_TAR_OS             8'h04
`define IC_SAR_OS             8'h08
`define IC_HS_MADDR_OS        8'h0c
`define IC_DATA_CMD_OS        8'h10
`define IC_SS_HCNT_OS         8'h14
`define IC_SS_LCNT_OS         8'h18
`define IC_FS_HCNT_OS         8'h1c
`define IC_FS_LCNT_OS         8'h20
`define IC_HS_HCNT_OS         8'h24
`define IC_HS_LCNT_OS         8'h28
`define IC_INTR_STAT_OS       8'h2c
`define IC_INTR_MASK_OS       8'h30
`define IC_RAW_INTR_STAT_OS   8'h34
`define IC_RX_TL_OS           8'h38
`define IC_TX_TL_OS           8'h3c
`define IC_CLR_INTR_OS        8'h40
`define IC_CLR_RX_UNDER_OS    8'h44
`define IC_CLR_RX_OVER_OS     8'h48
`define IC_CLR_TX_OVER_OS     8'h4c
`define IC_CLR_RD_REQ_OS      8'h50
`define IC_CLR_TX_ABRT_OS     8'h54
`define IC_CLR_RX_DONE_OS     8'h58
`define IC_CLR_ACTIVITY_OS    8'h5c
`define IC_CLR_STOP_DET_OS    8'h60
`define IC_CLR_START_DET_OS   8'h64
`define IC_CLR_GEN_CALL_OS    8'h68
`define IC_ENABLE_OS          8'h6c
`define IC_STATUS_OS          8'h70
`define IC_TXFLR_OS           8'h74
`define IC_RXFLR_OS           8'h78
`define IC_TX_ABRT_SOURCE_OS  8'h80


`define IC_DMA_CR_OS          8'h88
`define IC_DMA_TDLR_OS        8'h8c
`define IC_DMA_RDLR_OS        8'h90

`define IC_SDA_SETUP_OS        8'h94
`define IC_ACK_GENERAL_CALL_OS 8'h98
`define IC_ENABLE_STATUS_OS    8'h9C

// jduarte 20110105 begin
// CRM 9000368180
// Added register addresses for setting length of suppressed spike
// in ic_clk cycles
`define IC_FS_SPKLEN_OS       8'ha0
`define IC_HS_SPKLEN_OS       8'ha4
// jduarte 20110105 end


`define REG_TIMEOUT_RST_OS    8'hf0

`define IC_COMP_PARAM_1_OS    8'hf4
`define IC_COMP_VERSION_OS    8'hf8
`define IC_COMP_TYPE_OS       8'hfc

`define IC_SDA_HOLD_OS        8'h7c



module DW_apb_i2c_regfile (
   pclk
                           ,presetn
                           ,wr_en
                           ,rd_en
                           ,slave_rdy
                           ,slave_err
                           ,penable_int
                           ,byte_en
                           ,reg_addr
                           ,ipwdata
                           ,iprdata
                           ,ic_clr_intr_en
                           ,ic_clr_rx_under_en
                           ,ic_clr_rx_over_en
                           ,ic_clr_tx_over_en
                           ,ic_clr_rd_req_en
                           ,ic_clr_tx_abrt_en
                           ,ic_clr_rx_done_en
                           ,ic_clr_activity_en
                           ,ic_clr_stop_det_en
                           ,ic_clr_start_det_en
                           ,ic_clr_gen_call_en
                           ,mst_activity
                           ,slv_activity
                           ,activity
                           ,ic_tx_abrt_source
                           ,psel
                           ,ic_en
                           ,slv_rx_aborted_sync
                           ,slv_fifo_filled_and_flushed_sync
                           ,ic_tar
                           ,ic_sar
                           ,ic_hs_maddr
                           ,ic_fs_hcnt
                           ,ic_fs_lcnt
                           ,ic_intr_mask
                           ,ic_rx_tl_int
                           ,ic_tx_tl
                           ,ic_enable
                           ,ic_hcnt
                           ,ic_lcnt
                           ,// jduarte 20110105 begin
                           // CRM 9000368180
                           // Added outputs for length of suppressed spike
                           // in ic_clk cycles
                           // The same value is used for FS and SS (ic_fs_spklen)
                           ic_fs_spklen
                           ,ic_hs_spklen
                           // jduarte 20110105 end   
                           ,ic_intr_stat
                           ,ic_raw_intr_stat
                           ,ic_hs
                           ,ic_fs
                           ,ic_ss
                           ,ic_master
                           ,ic_10bit_mst
                           ,ic_10bit_slv
                           ,ic_slave_en
                           ,p_det_ifaddr
                           ,tx_empty_ctrl
                           ,rx_pop_data
                           ,tx_push_data
                           ,fifo_rst_n
                           ,tx_fifo_rst_n
                           ,tx_pop_sync
                           ,rx_push_sync
                           ,rx_pop
                           ,tx_push
                           ,tx_empty
                           ,rx_full
                           ,tx_full
                           ,rx_empty
                           //misc.
                           ,tx_abrt_flg_edg
                           ,abrt_in_rcve_trns
                           ,slv_clr_leftover_flg_edg
                           ,ic_rstrt_en                           
                           ,ic_sda_setup
                           ,ic_sda_hold
                           ,ic_ack_general_call
                           );

   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------

   input pclk;                                           // APB clock
   input presetn;                                        // APB async reset
   input wr_en;                                          // write enable
   input rd_en;                                          // read enable
   input                              penable_int;       // internal penable signal
   input [3:0]                       byte_en;            // active byte lane
   input [`IC_ADDR_SLICE_LHS-2:0]     reg_addr;          // register address offset
   input [`MAX_APB_DATA_WIDTH-1:0]    ipwdata;           // internal APB write data
   input [`IC_INTR_STAT_RS-1:0]       ic_intr_stat;
   input [`IC_RAW_INTR_STAT_RS-1:0]   ic_raw_intr_stat;
   input [`IC_DATA_FIFO_RS-1:0]       rx_pop_data;       // data from the rx fifo
   input                              tx_abrt_flg_edg;   // tx aborted transfer
   input                              abrt_in_rcve_trns;     // user abort occured during receive transfer
   input                              slv_clr_leftover_flg_edg;
   input                              tx_pop_sync;       // pclk sync tx fifo pop
   input                              rx_push_sync;      // pclk sync rx fifo push
   input                              tx_empty;          // tx fifo empty status
   input                              rx_full;           // rx fifo full status
   input                              tx_full;           // tx fifo full status
   input                              rx_empty;          // rx fifo empty status
   input                              mst_activity;      // IC module I2C Master activity status
   input                              slv_activity;      // IC module I2C Slave activity status
   input                              activity;          // IC module I2C activity status
   input  [`IC_TX_ABRT_SOURCE_RS-1:0] ic_tx_abrt_source; // tx_abrt sources combined signals
   input                              psel;

   input                              ic_en;
   input                              slv_rx_aborted_sync;    // Slave-Rx aborted due to IC_ENABLE
   input                              slv_fifo_filled_and_flushed_sync; // Slave-Rx data discarded due to IC_ENABLE

   output [`IC_DATA_TX_CMD_RS-1:0]    tx_push_data;         // data to the tx fifo
   output                             rx_pop;               // rx fifo pop
   output                             tx_push;              // tx fifo push
   output                             slave_rdy;            // slave ready signal
   output                             slave_err;            // slave error signal
   output                             fifo_rst_n;           // sync reset for fifo controllers
   output                             tx_fifo_rst_n;        // sync reset for tx controllers
   output [`MAX_APB_DATA_WIDTH-1:0]   iprdata;              // internal APB read data
   output [`IC_ENABLE_RS_INT-1:0]     ic_enable;            // ic is enabled
   output                             ic_clr_intr_en;       // clear all inturrepts
   output                             ic_clr_rx_under_en;   // clear rx_under int.
   output                             ic_clr_rx_over_en;    // clear rx_over int.
   output                             ic_clr_tx_over_en;    // clear tx_over
   output                             ic_clr_rd_req_en;     // clear rd_req int.
   output                             ic_clr_tx_abrt_en;    // clear tx_abrt int.
   output                             ic_clr_rx_done_en;    // clear rx_done int.
   output                             ic_clr_activity_en;   // clear activity int.
   output                             ic_clr_stop_det_en;   // clear stop_det int.
   output                             ic_clr_start_det_en;  // clear start_det int
   output                             ic_clr_gen_call_en;   // clear gen_call int
   output [`IC_TAR_RS_INT-1:0]        ic_tar;               //Target address
   output [`IC_SAR_RS-1:0]            ic_sar;               //slave module address
                                                            // ic_sar_opt_en name is used for decoding signal
                                                            //slave address
   output [`IC_HS_MADDR_RS-1:0]       ic_hs_maddr;//High speed master unique code
   output [`IC_FS_HCNT_RS-1:0]        ic_fs_hcnt;//Fast Speed mode High count register value
   output [`IC_FS_LCNT_RS-1:0]        ic_fs_lcnt;//Fast Speed mode low count register value
   output [`IC_INTR_MASK_RS-1:0]      ic_intr_mask;//Interrupt mask register
   output [`RX_ABW-1:0]               ic_rx_tl_int;//receive threshold
   output [`IC_HS_HCNT_RS-1:0]        ic_hcnt;//Holds the high count of the active mode
   output [`IC_HS_LCNT_RS-1:0]        ic_lcnt;//Holds the low count of the active mode
   output [`IC_TX_TL_RS-1:0]          ic_tx_tl;//transmit empty level
   // jduarte 20110105 begin
   // CRM 9000368180
   // Added outputs for length of suppressed spike
   // in ic_clk cycles
   // The same value is used for FS and SS (ic_fs_spklen)
   output [`IC_FS_SPKLEN_RS-1:0]      ic_fs_spklen;
   output [`IC_HS_SPKLEN_RS-1:0]      ic_hs_spklen;
   // jduarte 20110105 end   
   output                             ic_hs;// ic is in high speed mode
   output                             ic_fs;// ic is in fast speed mode
   output                             ic_ss;// ic is in std. speed mode
   output                             ic_master;// ic is master, logic 0:slave
   output                             ic_10bit_mst;//ic master address is 10 bit
   output                             ic_10bit_slv;//ic slave address is 10 bit
   output                             ic_rstrt_en;// Master can generate re-starts in general
   output                             ic_slave_en;//1: slave is enabled, 0:disabled
   output                             p_det_ifaddr;// programmable option to detect Stop interrupt only if slave is addressed
   output                             tx_empty_ctrl;// TX FIFO empty interrupt control

   output [`IC_SDA_SETUP_RS-1:0]      ic_sda_setup;

// Adding IC_SDA_RX_HOLD_RS (8 bits) for calculating hold time while I2C acts as reciever
// ic_sda_hold[15:0] Used as transmit hold time
// ic_sda_hold[23:16] Used as recieve hold time
   output [`IC_SDA_HOLD_RS-1:0]       ic_sda_hold; 
   output                             ic_ack_general_call;

   // ----------------------------------------------------------
   // -- local registers and wires
   // ----------------------------------------------------------
   //wires
   wire [7:0]                         rx_fifo_depth;
   wire [7:0]                         tx_fifo_depth;
   // read write enable signals
   wire                               ic_tx_abrt_source_en;

   wire                               wr_en_int;
   wire                               reg_wr_en;
   wire                               reg_rd_en;
   wire                               ic_con_en;
   wire                               ic_con_we;
   wire                               ic_tar_en;
   wire                               ic_tar_we;
   wire                               ic_sar_en;
   wire                               ic_sar_we;
   wire                               ic_hs_maddr_en;
   wire                               ic_hs_maddr_we;
   wire                               ic_data_cmd_en;
   wire                               ic_ss_hcnt_en;
   wire                               ic_ss_lcnt_en;
   wire                               ic_fs_hcnt_en;
   wire                               ic_fs_lcnt_en;
   wire                               ic_hs_hcnt_en;
   wire                               ic_hs_lcnt_en;
   wire                               ic_ss_hcnt_we;
   wire                               ic_ss_lcnt_we;
   wire                               ic_fs_hcnt_we;
   wire                               ic_fs_lcnt_we;
   wire                               ic_hs_hcnt_we;
   wire                               ic_hs_lcnt_we;
   // jduarte 20110105 begin
   // CRM 9000368180
   // Added enable and write enable control signals for registers
   // setting the length of suppressed spike
   wire                               ic_fs_spklen_en;
   wire                               ic_fs_spklen_we;
   wire                               ic_hs_spklen_en;
   wire                               ic_hs_spklen_we;   
   // jduarte 20110105   
   wire                               ic_intr_stat_en;
   wire                               ic_intr_mask_en;
   wire                               ic_intr_mask_we;
   wire                               ic_raw_intr_stat_en;
   wire                               ic_rx_tl_en;
   wire                               ic_rx_tl_we;
   wire                               ic_tx_tl_en;
   wire                               ic_tx_tl_we;
   wire                               ic_clr_intr_en;
   wire                               ic_clr_rx_over_en;
   wire                               ic_clr_rx_under_en;
   wire                               ic_clr_tx_over_en;
   wire                               ic_clr_tx_abrt_en;
   wire                               ic_clr_rx_done_en;
   wire                               ic_clr_rd_req_en;
   wire                               ic_clr_activity_en;
   wire                               ic_clr_stop_det_en;
   wire                               ic_clr_start_det_en;
   wire                               ic_clr_gen_call_en;
   wire                               ic_enable_en;
   wire                               ic_enable_we;

   wire                               ic_status_en;
   wire                               ic_txflr_en;
   wire                               ic_rxflr_en;

   wire                               ic_comp_param_1_en;
   wire                               ic_comp_version_en;
   wire                               ic_comp_type_en;
   wire                               ic_sda_setup_en;
   wire                               ic_sda_setup_we;
   wire                               ic_ack_general_call_en;
   wire                               ic_ack_general_call_we;
   wire                               ic_enable_status_en;
   wire [`IC_ENABLE_STATUS_RS-1:0]    ic_enable_status;
   wire                               ic_sda_hold_en;
   wire                               ic_sda_hold_we;

   wire [31:0]                        ic_comp_param_1;
   wire [31:0]                        ic_comp_version;
   wire [31:0]                        ic_comp_type;

   wire [1:0]                         speed;
   wire [`IC_STATUS_RS-1:0]           ic_status;

   wire [`IC_CON_RS-1:0]              ic_con;
   // Registers defintion
   reg [`IC_CON_RS-1:0]               ic_con_pre;
// reuse-pragma   endSub IC_CON_PRE 

   wire [`IC_TAR_RS_INT-1:0]          ic_tar;
   reg [`IC_TAR_RS-1:0]               ic_tar_reg;
   reg [`IC_SAR_RS-1:0]               ic_sar;

   reg [`IC_SS_HCNT_RS-1:0]           r_ic_ss_hcnt;
   reg [`IC_SS_LCNT_RS-1:0]           r_ic_ss_lcnt;
   reg [`IC_FS_HCNT_RS-1:0]           r_ic_fs_hcnt;
   reg [`IC_FS_LCNT_RS-1:0]           r_ic_fs_lcnt;
   reg [`IC_HS_HCNT_RS-1:0]           r_ic_hs_hcnt;
   reg [`IC_HS_LCNT_RS-1:0]           r_ic_hs_lcnt;

   reg [`IC_HS_MADDR_RS-1:0]          ic_hs_maddr;
// jduarte 20110105 begin
// CRM 9000368180
// Added registers for setting length of suppressed spike
// in ic_clk cycles
// The same value is used for FS and SS (r_ic_fs_spklen)
   reg [`IC_FS_SPKLEN_RS-1:0]         r_ic_fs_spklen;
   reg [`IC_HS_SPKLEN_RS-1:0]         r_ic_hs_spklen;
// jduarte 20110105 end
   
   wire [`IC_SS_HCNT_RS-1:0]          hcr_ic_ss_hcnt;
   wire [`IC_SS_LCNT_RS-1:0]          hcr_ic_ss_lcnt;
   wire [`IC_FS_HCNT_RS-1:0]          hcr_ic_fs_hcnt;
   wire [`IC_FS_LCNT_RS-1:0]          hcr_ic_fs_lcnt;
   wire [`IC_HS_HCNT_RS-1:0]          hcr_ic_hs_hcnt;
   wire [`IC_HS_LCNT_RS-1:0]          hcr_ic_hs_lcnt;

   wire [`IC_SS_HCNT_RS-1:0]          ic_ss_hcnt;
   wire [`IC_SS_LCNT_RS-1:0]          ic_ss_lcnt;
   wire [`IC_FS_HCNT_RS-1:0]          ic_fs_hcnt;
   wire [`IC_FS_LCNT_RS-1:0]          ic_fs_lcnt;
   wire [`IC_HS_HCNT_RS-1:0]          ic_hs_hcnt;
   wire [`IC_HS_LCNT_RS-1:0]          ic_hs_lcnt;
// jduarte 20110105 begin
// CRM 9000368180
// Added wires for length of suppressed spike
// in ic_clk cycles
// The same value is used for FS and SS (ic_fs_spklen)
   wire [`IC_FS_SPKLEN_RS-1:0]        ic_fs_spklen;
   wire [`IC_HS_SPKLEN_RS-1:0]        ic_hs_spklen;
// jduarte 20110105 end

   wire                               fifo_rst_n;
   wire                               fix_a, fix_b, fix_c;
   reg                                fifo_rst_n_int;

   reg [`IC_INTR_MASK_RS-1:0]         ic_intr_mask;
   wire [`IC_ENABLE_RS_INT-1:0]       ic_enable;
   reg [`IC_ENABLE_RS-1:0]            ic_enable_reg;

   reg [`TX_ABW:0]                    ic_txflr;
   reg [`TX_ABW:0]                    ic_txflr_flushed;
   reg [`RX_ABW:0]                    ic_rxflr;
   reg [`IC_SDA_SETUP_RS-1:0]         ic_sda_setup;

// Adding IC_SDA_RX_HOLD_RS (8 bits) for calculating hold time while I2C acts as reciever
   reg [`IC_SDA_HOLD_RS-1:0]          ic_sda_hold;
   reg                                ic_ack_general_call;


   reg [`IC_HS_HCNT_RS-1:0]           ic_hcnt;//not real regs, to be used in always block
   reg [`IC_HS_LCNT_RS-1:0]           ic_lcnt;//not real regs, to be used in always block
   reg [`IC_RX_TL_RS-1:0]             ic_rx_tl;
   wire [`RX_ABW-1:0]                 ic_rx_tl_int;
   reg [`IC_TX_TL_RS-1:0]             ic_tx_tl;
   reg [`MAX_APB_DATA_WIDTH-1:0]      iprdata;
   reg                                activity_r;
   reg                                mst_activity_r;
   reg                                slv_activity_r;

   reg [`REG_TIMEOUT_WIDTH-1:0]       reg_timeout_rst; // register timeout reset value reg.
   reg [`REG_TIMEOUT_WIDTH-1:0]       reg_timeout;     // register timeout counter register
   reg                                slave_err;       // slave error register.
   reg                                reg_timeout_err_r; // Register timeout delayed.
   wire                               slave_err_int;   // slave error internal wire.
   wire                               slave_errors;    // OR-ed error signals.
   wire                               reg_timeout_err; // register timeout counter flag.
   wire                               slvrd_err;       // read command in slave mode error.
   wire                               mstslv_err;      // Master & Slave simultaneously enabled.
   wire                               reg_ready_low;   // register not ready.
   reg                                slave_rdy;     // slave ready register.
   wire                               psetup_ph;       // slave ready.

   wire                               reg_timeout_rst_en;       // Reg timeout register address decoding enable.
   wire                               reg_timeout_rst_we;       // Reg timeout register write enable.


   wire [`IC_TAR_RS-1:0]               ic_tar_int;
   wire [`IC_SAR_RS-1:0]               ic_sar_int;
   wire [`IC_INTR_MASK_RS-1:0]         ic_intr_mask_int;
   wire [`IC_SDA_HOLD_RS-1:0]          ic_sda_hold_int;

   wire               ic_hs;
   wire               ic_fs;
   wire               ic_ss;

   // ------------------------------------------------------
   // -- Address decoder
   //
   //  Decodes the register address offset input(reg_addr)
   //  to produce enable (select) signals for each of the
   //  SW-registers in the macrocell
   // ------------------------------------------------------
   assign ic_con_en                 = ({2'b00,reg_addr} == (`IC_CON_OS                >> 2));
   assign ic_tar_en                 = ({2'b00,reg_addr} == (`IC_TAR_OS                >> 2));
   assign ic_sar_en                 = ({2'b00,reg_addr} == (`IC_SAR_OS                >> 2));
   assign ic_data_cmd_en            = ({2'b00,reg_addr} == (`IC_DATA_CMD_OS           >> 2));
   assign ic_ss_hcnt_en             = ({2'b00,reg_addr} == (`IC_SS_HCNT_OS            >> 2));
   assign ic_ss_lcnt_en             = ({2'b00,reg_addr} == (`IC_SS_LCNT_OS            >> 2));
   assign ic_fs_hcnt_en             = ({2'b00,reg_addr} == (`IC_FS_HCNT_OS            >> 2));
   assign ic_fs_lcnt_en             = ({2'b00,reg_addr} == (`IC_FS_LCNT_OS            >> 2));
   assign ic_hs_maddr_en            = ({2'b00,reg_addr} == (`IC_HS_MADDR_OS           >> 2));
   assign ic_hs_hcnt_en             = ({2'b00,reg_addr} == (`IC_HS_HCNT_OS            >> 2));
   assign ic_hs_lcnt_en             = ({2'b00,reg_addr} == (`IC_HS_LCNT_OS            >> 2));
   assign ic_intr_stat_en           = ({2'b00,reg_addr} == (`IC_INTR_STAT_OS          >> 2));
   assign ic_intr_mask_en           = ({2'b00,reg_addr} == (`IC_INTR_MASK_OS          >> 2));
   assign ic_raw_intr_stat_en       = ({2'b00,reg_addr} == (`IC_RAW_INTR_STAT_OS      >> 2));
   assign ic_rx_tl_en               = ({2'b00,reg_addr} == (`IC_RX_TL_OS              >> 2));
   assign ic_tx_tl_en               = ({2'b00,reg_addr} == (`IC_TX_TL_OS              >> 2));
   assign ic_clr_intr_en            = ({2'b00,reg_addr} == (`IC_CLR_INTR_OS           >> 2));
   assign ic_clr_rx_under_en        = ({2'b00,reg_addr} == (`IC_CLR_RX_UNDER_OS       >> 2));
   assign ic_clr_rx_over_en         = ({2'b00,reg_addr} == (`IC_CLR_RX_OVER_OS        >> 2));
   assign ic_clr_tx_over_en         = ({2'b00,reg_addr} == (`IC_CLR_TX_OVER_OS        >> 2));
   assign ic_clr_rd_req_en          = ({2'b00,reg_addr} == (`IC_CLR_RD_REQ_OS         >> 2));
   assign ic_clr_tx_abrt_en         = ({2'b00,reg_addr} == (`IC_CLR_TX_ABRT_OS        >> 2));
   assign ic_clr_rx_done_en         = ({2'b00,reg_addr} == (`IC_CLR_RX_DONE_OS        >> 2));
   assign ic_clr_activity_en        = ({2'b00,reg_addr} == (`IC_CLR_ACTIVITY_OS       >> 2));
   assign ic_clr_stop_det_en        = ({2'b00,reg_addr} == (`IC_CLR_STOP_DET_OS       >> 2));
   assign ic_clr_start_det_en       = ({2'b00,reg_addr} == (`IC_CLR_START_DET_OS      >> 2));
   assign ic_clr_gen_call_en        = ({2'b00,reg_addr} == (`IC_CLR_GEN_CALL_OS       >> 2));
   assign ic_enable_en              = ({2'b00,reg_addr} == (`IC_ENABLE_OS             >> 2));
   assign ic_status_en              = ({2'b00,reg_addr} == (`IC_STATUS_OS             >> 2));
   assign ic_txflr_en               = ({2'b00,reg_addr} == (`IC_TXFLR_OS              >> 2));
   assign ic_rxflr_en               = ({2'b00,reg_addr} == (`IC_RXFLR_OS              >> 2));
   assign ic_tx_abrt_source_en      = ({2'b00,reg_addr} == (`IC_TX_ABRT_SOURCE_OS     >> 2));
   assign ic_comp_param_1_en        = ({2'b00,reg_addr} == (`IC_COMP_PARAM_1_OS       >> 2));
   assign ic_comp_version_en        = ({2'b00,reg_addr} == (`IC_COMP_VERSION_OS       >> 2));
   assign ic_comp_type_en           = ({2'b00,reg_addr} == (`IC_COMP_TYPE_OS          >> 2));
   assign ic_sda_setup_en           = ({2'b00,reg_addr} == (`IC_SDA_SETUP_OS          >> 2));
   assign ic_ack_general_call_en    = ({2'b00,reg_addr} == (`IC_ACK_GENERAL_CALL_OS   >> 2));
   assign ic_enable_status_en       = ({2'b00,reg_addr} == (`IC_ENABLE_STATUS_OS      >> 2));
   assign ic_sda_hold_en            = ({2'b00,reg_addr} == (`IC_SDA_HOLD_OS           >> 2));

// configure wr_en_int for error_response disable by assigning values fom wr_en.
   assign wr_en_int       = penable_int & wr_en;
   //#reg_wr_en_signal goes high in the last cycle of a write transfer if timeout error is not triggered.
   //#reg_rd_en_signal is active when register is ready and when rd_en=1 in case
   //#it is the first transaction cycle or it is the cycle where reg_ready_low_signal has just gone low.
   assign reg_wr_en       = wr_en & penable_int & slave_rdy & (!reg_timeout_err_r);
   assign reg_rd_en       = rd_en & (!reg_ready_low) & ( !penable_int | (!slave_rdy & (!reg_timeout_err)) );


//# ------------------------------------------------------
//#  Write enable signals for writeable SW-registers.
//# ------------------------------------------------------
   assign ic_con_we       = ic_con_en       & wr_en_int;
   assign ic_tar_we       = ic_tar_en       & wr_en_int;
   assign ic_sar_we       = ic_sar_en       & wr_en_int;
   assign ic_hs_maddr_we  = ic_hs_maddr_en  & wr_en_int;

   assign ic_ss_hcnt_we   = ic_ss_hcnt_en   & wr_en_int;
   assign ic_ss_lcnt_we   = ic_ss_lcnt_en   & wr_en_int;
   assign ic_fs_hcnt_we   = ic_fs_hcnt_en   & wr_en_int;
   assign ic_fs_lcnt_we   = ic_fs_lcnt_en   & wr_en_int;
   assign ic_hs_hcnt_we   = ic_hs_hcnt_en   & wr_en_int;
   assign ic_hs_lcnt_we   = ic_hs_lcnt_en   & wr_en_int;

   assign ic_intr_mask_we = ic_intr_mask_en & wr_en_int;
   assign ic_rx_tl_we     = ic_rx_tl_en     & wr_en_int;
   assign ic_tx_tl_we     = ic_tx_tl_en     & wr_en_int;
   assign ic_enable_we    = ic_enable_en    & wr_en_int;
   assign ic_sda_setup_we = ic_sda_setup_en & wr_en_int;
   assign ic_sda_hold_we  = ic_sda_hold_en  & wr_en_int;
   assign ic_ack_general_call_we = ic_ack_general_call_en & wr_en_int;

   assign rx_pop     = (byte_en[0] == 1'b1 && ic_data_cmd_en == 1'b1 && reg_rd_en == 1'b1) ? 1'b1 : 1'b0;
   assign tx_push    = (byte_en[1] == 1'b1 && ic_data_cmd_en == 1'b1 && reg_wr_en == 1'b1) ? 1'b1 : 1'b0;

// jduarte 20110105 begin
// CRM 9000368180
// Added enable and write enable control signals for registers
// setting the length of suppressed spike
   assign ic_fs_spklen_en = ({2'b00,reg_addr} == (`IC_FS_SPKLEN_OS >> 2));
   assign ic_fs_spklen_we = ic_fs_spklen_en & wr_en_int;
   assign ic_hs_spklen_en = ({2'b00,reg_addr} == (`IC_HS_SPKLEN_OS >> 2));
   assign ic_hs_spklen_we = ic_hs_spklen_en & wr_en_int;

   assign reg_timeout_rst_en = ({2'b00,reg_addr} == (`REG_TIMEOUT_RST_OS >> 2));
   assign reg_timeout_rst_we = reg_timeout_rst_en & wr_en_int;

  // ------------------------------------------------------
  // -- SLAVE_RDY REGISTER
  // Register that indicates ready status of slave
  // A high on the register in Access phase indicates end of transaction.
  // ------------------------------------------------------
  assign reg_ready_low   = ic_data_cmd_en  & ( (tx_full & wr_en) | (rx_empty & rd_en) );
  
  always @ (posedge pclk or negedge presetn) begin : SLAVE_RDY_PROC
    if (presetn == 1'b0) begin
        slave_rdy <= 1'b1;
    end else begin
      if ((ic_data_cmd_en == 1'b0) || (mstslv_err == 1'b1) || (slvrd_err ==1'b1))   begin
        slave_rdy <= 1'b1;
      end else if (reg_timeout_err == 1'b1) begin
        slave_rdy <= 1'b1;
      end else begin
        if (psetup_ph == 1'b1) begin  
          slave_rdy <= !(reg_ready_low);
        end else begin
          if (reg_ready_low == 1'b0) begin  
            slave_rdy <= 1'b1;  
          end    
        end  
      end
    end
  end // SLAVE_RDY_PROC

  assign psetup_ph = (penable_int == 1'b0); 


  // ------------------------------------------------------
  // -- REG_TIMEOUT REGISTER
  // CountDown Register for transfer timeout when slave is not able to complete transfer
  // The counter counts down from a reset value until slave becomes ready or timeout is reached.
  // ------------------------------------------------------
  always @ (posedge pclk or negedge presetn) begin : REG_TIMEOUT_PROC
    if (presetn == 1'b0) begin
      reg_timeout <= `REG_TIMEOUT_VALUE;
    end else begin
      if (penable_int == 1'b0) begin
        reg_timeout <= reg_timeout_rst;
      end else if ((slave_rdy == 1'b0) && (penable_int == 1'b1)) begin
        if (reg_timeout != {(`REG_TIMEOUT_WIDTH){1'b0}}) begin
          reg_timeout <= reg_timeout - {{(`REG_TIMEOUT_WIDTH-1){1'b0}}, 1'b1};
        end
      end
    end // RESET not active
  end // IC_HAS_POSITIVE_REG_TIMEOUT_WIDTH

  assign mstslv_err    = ((ic_con_en==1'b1) && (wr_en==1'b1) && (ic_enable[0]==1'b0) && (byte_en[0]==1'b1) && (ipwdata[0]!=ipwdata[6])) ? 1'b1 : 1'b0;
 
  assign slvrd_err     = ((ic_data_cmd_en==1'b1) && (wr_en==1'b1) && (ic_enable[0]==1'b1) && (ic_con[6]==1'b0) && (byte_en[1]==1'b1) && (ipwdata[8]==1'b1)) ? 1'b1 : 1'b0;

  // assign reg_timeout_err = !(|reg_timeout);
  assign reg_timeout_err = (reg_timeout_rst == {{(`REG_TIMEOUT_WIDTH-1){1'b0}}, 1'b1}) ? (reg_ready_low & penable_int & ic_data_cmd_en) : ((reg_timeout == {{(`REG_TIMEOUT_WIDTH-1){1'b0}}, 1'b1}) && (ic_data_cmd_en == 1'b1) && (penable_int == 1'b1));

  assign slave_errors  = ((mstslv_err | slvrd_err | (reg_timeout_err & ic_data_cmd_en))==1'b1) ? 1'b1 : 1'b0;
  assign slave_err_int = slave_err;
 
  always @(posedge pclk or negedge presetn) begin : SLAVE_ERR_PROC
    if(presetn == 1'b0) begin
      slave_err <= 1'b0;
      reg_timeout_err_r <= 1'b0;
    end else begin
      reg_timeout_err_r <= reg_timeout_err;   
      if (slave_err_int == 1'b1) begin
        slave_err <= 1'b0;
      end else begin
        slave_err <= (slave_errors & psel);
      end        
      // slave_err <= slave_err_int ? 1'b0 : ( slave_errors & psel & (!penable) );
    end
  end // SLAVE_ERR_PROC      


// jduarte 20110105   
   
  // ------------------------------------------------------
  // -- Status Register - Read Only
  //
  //  5-bit register
  //
  //  The bits of this regsiter 'ic_status' reflect the status
  //  of the FIFO buffers and the activity of I2C bus.
  //  Registers bits are set/reset by hardware.
  //
  //  This register is split into the following bit fields
  //
  //  [4] - RFF  - Receive FIFO Full Status
  //  [3] - RFNE - Receive FIFO Not Empty Status
  //  [2] - TFE  - Transmit FIFO Empty Status
  //  [1] - TFNE - Transmit FIFO Not Full Status
  //  [0] - Activity - I2C activity  Status
  //
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin : activity_r_PROC
    if(presetn == 1'b0) begin
      activity_r     <=  1'b0;
      mst_activity_r <=  1'b0;
      slv_activity_r <=  1'b0;
    end else begin
      activity_r     <= activity;
      slv_activity_r <= slv_activity;
      mst_activity_r <= mst_activity;
    end
  end



  assign ic_status[6]  = (slv_activity_r == 1'b1);
  assign ic_status[5]  = (mst_activity_r == 1'b1);
  assign ic_status[4]  = (rx_full     == 1'b1);
  assign ic_status[3]  = (rx_empty    == 1'b0);
  assign ic_status[2]  = (tx_empty    == 1'b1);
  assign ic_status[1]  = (tx_full     == 1'b0);
  assign ic_status[0]  = (activity_r  == 1'b1);

  // ------------------------------------------------------
  // ic_enable_status register - Read-only
  //
  // The bit of this register reflect the status of the
  // operating status of the DW_apb_i2c, particularly in
  // response to the setting of the IC_ENABLE bit to "0".
  //
  // [0] - ic_en
  // [1] - slave receive aborted (negative ACK)
  // [2] - slave RxFIFO filled and flushed
  // ------------------------------------------------------

  assign ic_enable_status[0] = ic_en;
  assign ic_enable_status[1] = slv_rx_aborted_sync;
  assign ic_enable_status[2] = slv_fifo_filled_and_flushed_sync;

  // ------------------------------------------------------
  // -- Tx FIFO level Register - Read Only
  //
  //  This register contains the number of valid data
  //  entries in the transmit FIFO buffer.
  //  Registers bits are set/reset by hardware.
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin : IC_TXFLR_PROC
    if(presetn == 1'b0) begin
      ic_txflr <= { `TX_ABW+1{1'b0} };
    end else begin
      if((ic_enable[0] == 1'b0)  
        || (tx_fifo_rst_n == 1'b0)
       ) begin
        ic_txflr <= { `TX_ABW+1{1'b0} };
      end else begin
        if(tx_push == 1'b1 && tx_pop_sync == 1'b0 && ic_txflr < `IC_TX_BUFFER_DEPTH) begin
          // When data is pushed in the Tx FIFO increment this register
          // Do let this register value exceed the Tx FIFO depth
          ic_txflr <= ic_txflr + {{(`TX_ABW){1'b0}},1'b1};
        end
        else if(tx_push == 1'b0 && tx_pop_sync == 1'b1 && ic_txflr != 0) begin
          // When data is poped from the Tx FIFO decrement this register
          // Do let this register value go below zero
          ic_txflr <= ic_txflr - {{(`TX_ABW){1'b0}},1'b1};
        end
        else if(tx_push == 1'b1 && tx_pop_sync == 1'b1 && ic_txflr == `IC_TX_BUFFER_DEPTH) begin
          // If data is pushed and poped simultaneously from the Tx FIFO if Tx-FIFO is full, 
          // consider only pop but not push since FIFO is already full.
          ic_txflr <= ic_txflr - {{(`TX_ABW){1'b0}},1'b1};
        end
      end
    end
  end

 // ------------------------------------------------------
  // -- Tx FIFO level flushed Register - Read Only
  //
  //  This register contains the number of valid data
  //  entries flushed from the transmit FIFO buffer.
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin : IC_TXFLR_BKP_PROC
    if(presetn == 1'b0) begin
      ic_txflr_flushed <= { `TX_ABW+1{1'b0} };
    end else begin
      if(ic_enable[0] == 1'b0) begin
        ic_txflr_flushed <= { `TX_ABW+1{1'b0} };
      end
      else if (tx_abrt_flg_edg) begin
        if(abrt_in_rcve_trns)
          ic_txflr_flushed <= ic_txflr + {{(`TX_ABW){1'b0}},1'b1};
        else 
          ic_txflr_flushed <= ic_txflr;
      end
    end
  end

  // ------------------------------------------------------
  // -- Rx FIFO level Register - Read Only
  //
  //  This register contians the number of valid data
  //  entries in the receive FIFO buffer.
  //  Registers bits are set/reset by hardware.
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin : IC_RXFLR_PROC
    if(presetn == 1'b0) begin
      ic_rxflr <= { `RX_ABW+1{1'b0} };
    end else begin
       if((ic_enable[0] == 1'b0)
          || (fifo_rst_n == 1'b0)
         ) begin       
        ic_rxflr <= { `RX_ABW+1{1'b0} };
      end else begin
        if(rx_push_sync == 1'b1 && rx_pop == 1'b0 && ic_rxflr < `IC_RX_BUFFER_DEPTH) begin
          // When data is pushed in the Rx FIFO increment this register
          // Do let this register value exceed the Rx FIFO depth
          ic_rxflr <= ic_rxflr + {{(`RX_ABW){1'b0}},1'b1};
        end else begin
          if(rx_push_sync == 1'b0 && rx_pop == 1'b1 && ic_rxflr != 0) begin
            // When data is poped from the Rx FIFO decrement this register
            // Do let this register value go below zero
            ic_rxflr <= ic_rxflr - {{(`RX_ABW){1'b0}},1'b1};
          end
        end
      end
    end
  end


  // ------------------------------------------------------
  // -- IC_ENABLE register
  //
  // -- Write control for 'icenable'
  // -- Can be written unless IC_ENABLE = '0'
  // -- Can never write a zero.
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin:IC_ENABLE_PROC
     if(presetn == 1'b0) begin
          ic_enable_reg <= {`IC_ENABLE_RS{1'b0}};
     end else begin
        if ((ic_enable_we == 1'b1) && (byte_en[0] == 1'b1)) begin
           //ic_enable_reg[`IC_ENABLE_RS-1:0] <= ipwdata[`IC_ENABLE_RS-1:0];
           // 9000521680 : Abort
           ic_enable_reg[0] <= ipwdata[0];
           if (!ic_enable_reg[1] & ipwdata[1])
             ic_enable_reg[1] <= ic_enable[0];
           else if (tx_abrt_flg_edg)
             ic_enable_reg[1] <= 1'b0;
        end
        else if (tx_abrt_flg_edg)
          ic_enable_reg[1] <= 1'b0;
     end
  end
  assign ic_enable = ic_enable_reg[`IC_ENABLE_RS_INT-1:0];

      

  // ------------------------------------------------------
  // -- IC_CON register
  //
  // -- Write control for 'ic_con'
  // -- Can't be written unless IC_ENABLE[0] = '0'
  // -- Can never write a zero.
  // -- If I2C_DYNAMIC_TAR_UPDATE mode is enabled IC_CON[4] is read only
  // ------------------------------------------------------

//  always @(posedge pclk or negedge presetn) begin: IC_CON_PROC
//     if(presetn == 1'b0) begin
//        ic_con_pre <= {`IC_SLAVE_DISABLE, `IC_RESTART_EN,`IC_10BITADDR_MASTER,`IC_10BITADDR_SLAVE,`IC_MAX_SPEED_MODE,`IC_MASTER_MODE};
//     end else begin
//        if ((ic_con_we == 1'b1) && (byte_en[0] == 1'b1) && (ic_enable[0] == 1'b0))
//          begin
//             if ((ipwdata[2:1] != 2'b00) && ( ipwdata[2:1] <= (`IC_MAX_SPEED_MODE)))
//               ic_con_pre[2:1] <= ipwdata[2:1];
//             else
//               ic_con_pre[2:1] <= `IC_MAX_SPEED_MODE;

//             ic_con_pre[0] <= ipwdata[0];
//             ic_con_pre[3] <= ipwdata[3];
//             ic_con_pre[`IC_CON_RS-1:5] <= ipwdata[`IC_CON_RS-1:5];

//             if(`I2C_DYNAMIC_TAR_UPDATE)
//              ic_con_pre[4] <= `IC_10BITADDR_MASTER;
//             else
//               ic_con_pre[4] <= ipwdata[4];
//          end
//     end
//  end

  always @(posedge pclk or negedge presetn) begin: IC_CON_PROC
    if(presetn == 1'b0) begin
       ic_con_pre <= {2'b00, `IC_SLAVE_DISABLE, `IC_RESTART_EN,`IC_10BITADDR_MASTER,`IC_10BITADDR_SLAVE,`IC_MAX_SPEED_MODE,`IC_MASTER_MODE};
    end
    else begin
      if ((ic_con_we == 1'b1) && (ic_enable[0] == 1'b0)) begin
        if (byte_en[1:0] == 2'b10) begin
          ic_con_pre[`IC_CON_RS-1] <= ipwdata[0];
        end
        else if((byte_en[3:0] != 4'b0100) && (byte_en[3:0] != 4'b1000) && (byte_en[3:0] != 4'b1100))  begin
          ic_con_pre[0] <= ipwdata[0];

          if ((ipwdata[2:1] != 2'b00) && ( ipwdata[2:1] <= (`IC_MAX_SPEED_MODE)))
            ic_con_pre[2:1] <= ipwdata[2:1];
          else
            ic_con_pre[2:1] <= `IC_MAX_SPEED_MODE;

          ic_con_pre[3] <= ipwdata[3];

            ic_con_pre[4] <= ipwdata[4];

          ic_con_pre[7:5] <= ipwdata[7:5];

          if (byte_en[1:0] == 2'b11)
            ic_con_pre[`IC_CON_RS-1] <= ipwdata[8];
        end   
      end
    end
  end


   assign ic_con[8:0] = ic_con_pre[8:0];







   assign speed = ic_con[2:1];



   // ------------------------------------------------------
   // -- IC_TAR register
   //
   // -- Write control for 'ic_sar'
   // -- Can't be written unless IC_ENABLE[0] = '0'
   // -- Or a dy_wr_mode_en (i.e. dynamic tar update) occurs
   // -- Can never write a zero.
   // ------------------------------------------------------
   // Reset value for bit 12, address format, 10 or 7 bit.

   // 9000234850 : False FM_1_4: Do not assign signal/variable to
   // asynchronous set/reset.
   always @(posedge pclk or negedge presetn) begin: IC_TAR_REG_PROC
     if(presetn == 1'b0)
       ic_tar_reg <= {
                  2'b0,
                  `IC_DEFAULT_TAR_SLAVE_ADDR
        };
     else begin
       if ( (
         (!ic_enable[0]) ) && (ic_tar_we == 1'b1)) begin
         case(byte_en)
           4'b0001 : ic_tar_reg[7:0] <= ipwdata[7:0];
           4'b0010 : ic_tar_reg[`IC_TAR_RS-1:8] <= ipwdata[`IC_TAR_RS-1-8:0];
           4'b0011 : ic_tar_reg[`IC_TAR_RS-1:0] <= ipwdata[`IC_TAR_RS-1:0];
           4'b1111 : ic_tar_reg[`IC_TAR_RS-1:0] <= ipwdata[`IC_TAR_RS-1:0];
           default : ic_tar_reg[`IC_TAR_RS-1:0] <= ic_tar_int[`IC_TAR_RS-1:0];
         endcase 
       end
     end
   end


   assign ic_tar_int = ic_tar_reg;
   assign ic_tar     = ic_tar_reg[`IC_TAR_RS_INT-1:0];

   // -- IC_SAR register
   //
   // -- Write control for 'ic_sar'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin: IC_SAR_REG_PROC
     if(presetn == 1'b0)
       ic_sar <= `IC_SAR_IN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_sar_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : ic_sar[7:0] <= ipwdata[7:0];
             4'b0010 : ic_sar[`IC_SAR_RS-1:8] <= ipwdata[`IC_SAR_RS-1-8:0];
             4'b0011 : ic_sar[`IC_SAR_RS-1:0] <= ipwdata[`IC_SAR_RS-1:0];
             4'b1111 : ic_sar[`IC_SAR_RS-1:0] <= ipwdata[`IC_SAR_RS-1:0];
             default : ic_sar[`IC_SAR_RS-1:0] <= ic_sar_int[`IC_SAR_RS-1:0];
           endcase
        end
     end
   end
    
   assign ic_sar_int = ic_sar;


   // ------------------------------------------------------
   // -- IC_HS_MADDR register
   //
   // -- Write control for 'ic_hs_maddr'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin:IC_HS_MADDR_PROC
      if(presetn == 1'b0) begin
         ic_hs_maddr <= `IC_HS_MADDR_IN;
      end else begin
         if ((ic_hs_maddr_we == 1'b1) && (byte_en[0] == 1'b1) && (ic_enable[0] == 1'b0)) begin
            ic_hs_maddr[`IC_HS_MADDR_RS-1:0] <= ipwdata[`IC_HS_MADDR_RS-1:0];
         end
      end
   end


   assign tx_push_data    = (byte_en == 4'b0010) ? { ipwdata[0],   8'h00 } : ipwdata[8:0];
  // jduarte end 20101108

  // Need to eliminate the registers when they are not required.
   assign hcr_ic_ss_hcnt = r_ic_ss_hcnt  ;
   assign hcr_ic_ss_lcnt = r_ic_ss_lcnt  ;
   assign hcr_ic_fs_hcnt = r_ic_fs_hcnt  ;
   assign hcr_ic_fs_lcnt = r_ic_fs_lcnt  ;
   assign hcr_ic_hs_hcnt = r_ic_hs_hcnt  ;
   assign hcr_ic_hs_lcnt = r_ic_hs_lcnt  ;


   assign ic_ss_hcnt = hcr_ic_ss_hcnt ;
   assign ic_ss_lcnt = hcr_ic_ss_lcnt ;
   assign ic_fs_hcnt = hcr_ic_fs_hcnt ;
   assign ic_fs_lcnt = hcr_ic_fs_lcnt ;
   assign ic_hs_hcnt = hcr_ic_hs_hcnt ;
   assign ic_hs_lcnt = hcr_ic_hs_lcnt ;
   // jduarte 20110105 begin  
   // CRM 9000368180
   assign ic_fs_spklen = r_ic_fs_spklen;   
   assign ic_hs_spklen = r_ic_hs_spklen;   
   // jduarte 20110105 end  

   //spyglass disable_block W415a
   //SMD: Signal may be multiply assigned (beside initialization) in the same scope
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   //spyglass disable_block STARC05-2.2.3.3
   //SMD: Do not assign over the same signal in an always construct for sequential circuits
   //SJ:  This implmentation is as per the design requirement. 
   //     There will not be any functional issue.
   // ------------------------------------------------------
   // -- IC_SS_HCNT register
   //
   // -- Write control for 'ic_ss_hcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_SS_HCNT_REG_PROC
     if(presetn == 1'b0) begin
       r_ic_ss_hcnt <= `IC_SS_HCNT_IN;
     end
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_ss_hcnt_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_ss_hcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_SS_HCNT_RS-1-8:0], ic_ss_hcnt[7:0]} >= `IC_HCNT_LO_LIMIT)
                    r_ic_ss_hcnt[`IC_SS_HCNT_RS-1:8] <= ipwdata[`IC_SS_HCNT_RS-1-8:0];
                  else
                    r_ic_ss_hcnt <= `IC_HCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_ss_hcnt[`IC_SS_HCNT_RS-1:0] <= (ipwdata[`IC_SS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT) ? ipwdata[`IC_SS_HCNT_RS-1:0]: `IC_HCNT_LO_LIMIT;
             4'b1111 : r_ic_ss_hcnt[`IC_SS_HCNT_RS-1:0] <= (ipwdata[`IC_SS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT) ? ipwdata[`IC_SS_HCNT_RS-1:0]: `IC_HCNT_LO_LIMIT;
             default : r_ic_ss_hcnt[`IC_SS_HCNT_RS-1:0] <= ic_ss_hcnt[`IC_SS_HCNT_RS-1:0];
           endcase
        end
     end
   end

   // ------------------------------------------------------
   // -- IC_SS_LCNT register
   //
   // -- Write control for 'ic_ss_lcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_SS_LCNT_REG_PROC
       if(presetn == 1'b0) begin
       r_ic_ss_lcnt <= `IC_SS_LCNT_IN;
     end
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_ss_lcnt_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_ss_lcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_SS_LCNT_RS-1-8:0], ic_ss_lcnt[7:0]} >= `IC_LCNT_LO_LIMIT)
                    r_ic_ss_lcnt[`IC_SS_LCNT_RS-1:8] <= ipwdata[`IC_SS_LCNT_RS-1-8:0];
                  else
                    r_ic_ss_lcnt <= `IC_LCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_ss_lcnt[`IC_SS_LCNT_RS-1:0] <= (ipwdata[`IC_SS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT)? ipwdata[`IC_SS_LCNT_RS-1:0]: `IC_LCNT_LO_LIMIT;
             4'b1111 : r_ic_ss_lcnt[`IC_SS_LCNT_RS-1:0] <= (ipwdata[`IC_SS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT) ? ipwdata[`IC_SS_LCNT_RS-1:0] : `IC_LCNT_LO_LIMIT;
             default : r_ic_ss_lcnt[`IC_SS_LCNT_RS-1:0] <= ic_ss_lcnt[`IC_SS_LCNT_RS-1:0];
           endcase
        end
     end
   end

   // ------------------------------------------------------
   // -- IC_FS_HCNT register
   //
   // -- Write control for 'ic_fs_hcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_FS_HCNT_REG_PROC
     if(presetn == 1'b0)
       r_ic_fs_hcnt <= `IC_FS_HCNT_IN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_fs_hcnt_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_fs_hcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_FS_HCNT_RS-1-8:0], ic_fs_hcnt[7:0]} >= `IC_HCNT_LO_LIMIT)
                    r_ic_fs_hcnt[`IC_FS_HCNT_RS-1:8] <= ipwdata[`IC_FS_HCNT_RS-1-8:0];
                  else
                    r_ic_fs_hcnt <= `IC_HCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_fs_hcnt[`IC_FS_HCNT_RS-1:0] <= (ipwdata[`IC_FS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT)? ipwdata[`IC_FS_HCNT_RS-1:0]: `IC_HCNT_LO_LIMIT;
             4'b1111 : r_ic_fs_hcnt[`IC_FS_HCNT_RS-1:0] <= (ipwdata[`IC_FS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT) ? ipwdata[`IC_FS_HCNT_RS-1:0] : `IC_HCNT_LO_LIMIT;
             default : r_ic_fs_hcnt[`IC_FS_HCNT_RS-1:0] <= ic_fs_hcnt[`IC_FS_HCNT_RS-1:0];

           endcase
        end
     end
   end




   // ------------------------------------------------------
   // -- IC_FS_LCNT register
   //
   // -- Write control for 'ic_fs_lcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_FS_LCNT_REG_PROC
     if(presetn == 1'b0)
       r_ic_fs_lcnt <= `IC_FS_LCNT_IN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_fs_lcnt_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_fs_lcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_FS_LCNT_RS-1-8:0], ic_fs_lcnt[7:0]} >= `IC_LCNT_LO_LIMIT)
                    r_ic_fs_lcnt[`IC_FS_LCNT_RS-1:8] <= ipwdata[`IC_FS_LCNT_RS-1-8:0];
                  else
                    r_ic_fs_lcnt <= `IC_LCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_fs_lcnt[`IC_FS_LCNT_RS-1:0] <= (ipwdata[`IC_FS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT)? ipwdata[`IC_FS_LCNT_RS-1:0]: `IC_LCNT_LO_LIMIT;
             4'b1111 : r_ic_fs_lcnt[`IC_FS_LCNT_RS-1:0] <= (ipwdata[`IC_FS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT) ? ipwdata[`IC_FS_LCNT_RS-1:0] : `IC_LCNT_LO_LIMIT;
             default : r_ic_fs_lcnt[`IC_FS_LCNT_RS-1:0] <= ic_fs_lcnt[`IC_FS_LCNT_RS-1:0];
           endcase
        end
     end
   end

   // ------------------------------------------------------
   // -- IC_HS_HCNT register
   //
   // -- Write control for 'ic_hs_hcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_HS_HCNT_REG_PROC
     if(presetn == 1'b0)
       r_ic_hs_hcnt <= `IC_HS_HCNT_IN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_hs_hcnt_we == 1'b1)) begin
           case(byte_en)

             4'b0001 : r_ic_hs_hcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_HS_HCNT_RS-1-8:0], ic_hs_hcnt[7:0]} >= `IC_HCNT_LO_LIMIT)
                    r_ic_hs_hcnt[`IC_HS_HCNT_RS-1:8] <= ipwdata[`IC_HS_HCNT_RS-1-8:0];
                  else
                    r_ic_hs_hcnt <= `IC_HCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_hs_hcnt[`IC_HS_HCNT_RS-1:0] <= (ipwdata[`IC_HS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT)? ipwdata[`IC_HS_HCNT_RS-1:0]: `IC_HCNT_LO_LIMIT;
             4'b1111 : r_ic_hs_hcnt[`IC_HS_HCNT_RS-1:0] <= (ipwdata[`IC_HS_HCNT_RS-1:0] >= `IC_HCNT_LO_LIMIT) ? ipwdata[`IC_HS_HCNT_RS-1:0] : `IC_HCNT_LO_LIMIT;
             default : r_ic_hs_hcnt[`IC_HS_HCNT_RS-1:0] <= ic_hs_hcnt[`IC_HS_HCNT_RS-1:0];
           endcase
        end
     end
   end




   // ------------------------------------------------------
   // -- IC_HS_LCNT register
   //
   // -- Write control for 'ic_hs_lcnt'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_HS_LCNT_REG_PROC
     if(presetn == 1'b0)
       r_ic_hs_lcnt <= `IC_HS_LCNT_IN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_hs_lcnt_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_hs_lcnt[7:0] <= ipwdata[7:0];
             4'b0010 :
               begin
                  if({ipwdata[`IC_HS_LCNT_RS-1-8:0], ic_hs_lcnt[7:0]} >= `IC_LCNT_LO_LIMIT)
                    r_ic_hs_lcnt[`IC_HS_LCNT_RS-1:8] <= ipwdata[`IC_HS_LCNT_RS-1-8:0];
                  else
                    r_ic_hs_lcnt <= `IC_LCNT_LO_LIMIT;
               end

             4'b0011 : r_ic_hs_lcnt[`IC_HS_LCNT_RS-1:0] <= (ipwdata[`IC_HS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT)? ipwdata[`IC_HS_LCNT_RS-1:0]: `IC_LCNT_LO_LIMIT;
             4'b1111 : r_ic_hs_lcnt[`IC_HS_LCNT_RS-1:0] <= (ipwdata[`IC_HS_LCNT_RS-1:0] >= `IC_LCNT_LO_LIMIT) ? ipwdata[`IC_HS_LCNT_RS-1:0] : `IC_LCNT_LO_LIMIT;
             default : r_ic_hs_lcnt[`IC_HS_LCNT_RS-1:0] <= ic_hs_lcnt[`IC_HS_LCNT_RS-1:0];
           endcase
        end
     end
   end

  //spyglass enable_block STARC05-2.2.3.3
  //spyglass enable_block W415a

   // jduarte 20110105 begin  
   // CRM 9000368180
   // ic_fs_spklen and ic_hs_spklen registers
   // maximum width of these registers is set to 8 bit because
   // maximum value of IC_FS_SPKLEN and IC_HS_SPKLEN is set to 255
   
   // ------------------------------------------------------
   // -- IC_FS_SPKLEN register
   //
   // -- Write control for 'ic_fs_spklen'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_FS_SPKLEN_REG_PROC
     if(presetn == 1'b0) begin
       r_ic_fs_spklen <= `IC_DEFAULT_FS_SPKLEN;
     end
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_fs_spklen_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0] <= (ipwdata[`IC_FS_SPKLEN_RS-1:0] >= `IC_FS_SPKLEN_LO_LIMIT)? ipwdata[`IC_FS_SPKLEN_RS-1:0]: `IC_FS_SPKLEN_LO_LIMIT; 
             4'b0011 : r_ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0] <= (ipwdata[`IC_FS_SPKLEN_RS-1:0] >= `IC_FS_SPKLEN_LO_LIMIT)? ipwdata[`IC_FS_SPKLEN_RS-1:0]: `IC_FS_SPKLEN_LO_LIMIT;
             4'b1111 : r_ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0] <= (ipwdata[`IC_FS_SPKLEN_RS-1:0] >= `IC_FS_SPKLEN_LO_LIMIT)? ipwdata[`IC_FS_SPKLEN_RS-1:0]: `IC_FS_SPKLEN_LO_LIMIT;
             default : r_ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0] <= ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0];
           endcase
        end
     end
    end

   
   // ------------------------------------------------------
   // -- IC_HS_SPKLEN register
   //
   // -- Write control for 'ic_hs_spklen'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_HS_SPKLEN_REG_PROC
     if(presetn == 1'b0)
       r_ic_hs_spklen <= `IC_DEFAULT_HS_SPKLEN;
     else begin
        if ((ic_enable[0] == 1'b0) && (ic_hs_spklen_we == 1'b1)) begin
           case(byte_en)
             4'b0001 : r_ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0] <= (ipwdata[`IC_HS_SPKLEN_RS-1:0] >= `IC_HS_SPKLEN_LO_LIMIT)? ipwdata[`IC_HS_SPKLEN_RS-1:0]: `IC_HS_SPKLEN_LO_LIMIT;
             4'b0011 : r_ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0] <= (ipwdata[`IC_HS_SPKLEN_RS-1:0] >= `IC_HS_SPKLEN_LO_LIMIT)? ipwdata[`IC_HS_SPKLEN_RS-1:0]: `IC_HS_SPKLEN_LO_LIMIT;
             4'b1111 : r_ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0] <= (ipwdata[`IC_HS_SPKLEN_RS-1:0] >= `IC_HS_SPKLEN_LO_LIMIT)? ipwdata[`IC_HS_SPKLEN_RS-1:0]: `IC_HS_SPKLEN_LO_LIMIT;
             default : r_ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0] <= ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0];
           endcase
        end
     end
   end


   
   // ------------------------------------------------------
   // -- REG_TIMEOUT_RST register
   //
   // -- Write control for 'REG_TIMEOUT_RST'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : REG_TIMEOUT_RST_PROC
     if(presetn == 1'b0)
         reg_timeout_rst <= `REG_TIMEOUT_VALUE;
     else if ((ic_enable[0] == 1'b0) && (reg_timeout_rst_we == 1'b1)) begin
       if (byte_en[0]==1'b1) reg_timeout_rst[`REG_TIMEOUT_WIDTH-1:0] <= ipwdata[`REG_TIMEOUT_WIDTH-1:0];
     end
   end


     
   // jduarte 20110105 end  



   // ------------------------------------------------------
   // -- IC_INTR_MASK register
   //
   // -- Write control for 'ic_intr_mask'
   // -- Can be written unless IC_ENABLE[0] = '0'
   // -- Can never write a zero.
   // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin:IC_INTR_MASK_PROC
      if(presetn == 1'b0) begin
        ic_intr_mask <= 15'h8ff;
      end else begin

        if (ic_intr_mask_we == 1'b1) begin
          case(byte_en)
            4'b0001 : begin
                        ic_intr_mask[7:0] <= ipwdata[7:0];
                      end
            4'b0010 : begin
                        ic_intr_mask[`IC_INTR_MASK_RS-4:8] <= ipwdata[`IC_INTR_MASK_RS-4-8:0];
                        ic_intr_mask[14] <= 1'b0;
                        ic_intr_mask[13] <= 1'b0;

                         ic_intr_mask[12] <= 1'b0;
                      end
            4'b0011 : begin
                        ic_intr_mask[`IC_INTR_MASK_RS-4:0] <= ipwdata[`IC_INTR_MASK_RS-4:0];
                        ic_intr_mask[14] <= 1'b0;

                        ic_intr_mask[13] <= 1'b0;

                        ic_intr_mask[12] <= 1'b0;
                      end
            4'b1111 : begin
                        ic_intr_mask[`IC_INTR_MASK_RS-4:0] <= ipwdata[`IC_INTR_MASK_RS-4:0];
                        ic_intr_mask[14] <= 1'b0;
                        ic_intr_mask[13] <= 1'b0;

                        ic_intr_mask[12] <= 1'b0;
                      end
            default : ic_intr_mask[`IC_INTR_MASK_RS-1:0] <= ic_intr_mask_int[`IC_INTR_MASK_RS-1:0];
          endcase
        end

      end
   end // block: IC_INTR_MASK_PROC

   assign ic_intr_mask_int = ic_intr_mask;

// ------------------------------------------------------
// -- IC_RX_TL register
//
// -- Write control for 'ic_rx_tl'
// -- This can never have a value greater that the rx_fifo_depth
// -- This is restricted to a maximum of 8 bits
// ------------------------------------------------------
  assign rx_fifo_depth = `IC_RX_BUFFER_DEPTH - 9'h01;
  assign ic_rx_tl_int  = ic_rx_tl[`RX_ABW-1:0];

  always @(posedge pclk or negedge presetn) begin : IC_RX_TL_PROC
    if (presetn == 1'b0) begin
      ic_rx_tl <= `IC_RX_TL_IN;
    end else begin
      if ((ic_rx_tl_we == 1'b1) && (byte_en[0] == 1'b1)) begin
        if (ipwdata[`IC_RX_TL_RS-1:0] <= rx_fifo_depth) begin
          ic_rx_tl <= ipwdata[`IC_RX_TL_RS-1:0];
        end else begin
          ic_rx_tl <= rx_fifo_depth;
        end
      end
    end
  end

// ------------------------------------------------------
// -- IC_TX_TL register
//
// -- Write control for 'ic_tx_tl'
//- This can never have a value greater than the tx_fifo_depth.
//- This is restricted to a maximum of 8 bits in width
// ------------------------------------------------------
   assign tx_fifo_depth = `IC_TX_BUFFER_DEPTH - 9'h01;

   always @(posedge pclk or negedge presetn) begin : IC_TX_TL_PROC
     if(presetn == 1'b0) begin
       ic_tx_tl <= `IC_TX_TL_IN;
     end else begin
       if ((ic_tx_tl_we == 1'b1) && (byte_en[0] == 1'b1)) begin
         if (ipwdata[`IC_TX_TL_RS-1:0] <= tx_fifo_depth) begin
           ic_tx_tl <= ipwdata[`IC_TX_TL_RS-1:0];
         end else begin
           ic_tx_tl <= tx_fifo_depth;
         end
       end
     end
   end



  // ------------------------------------------------------
  // SDA Setup register writes from the APB interface
  // This 8-bit register controls the minimum amount of
  // clock cycles the SCL is forced low when it is stretched
  // during Slave reads such that the data contents can be
  // fetched.
  // See pg 32, I2C Spec v2.1.
  // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : IC_SDA_SETUP_REG_PROC
     if(presetn == 1'b0)
       ic_sda_setup <= `IC_DEFAULT_SDA_SETUP;
     else begin
       if(ic_sda_setup_we == 1'b1 && byte_en[0] == 1'b1 && ic_enable[0] == 1'b0 ) begin
         ic_sda_setup[`IC_SDA_SETUP_RS-1:0] <= ipwdata[`IC_SDA_SETUP_RS-1:0];
       end
     end // else presetn
   end
  // ------------------------------------------------------
  // SDA Hold register writes from the APB interface
  // This 24-bit register which contains two parts:
  // IC_SDA_TX_HOLD which is IC_SDA_HOLD[15:0] and IC_SDA_RX_HOLD which is IC_SDA_HOLD[23:16]
  // IC_SDA_TX_HOLD is used whenever I2C acts as trasmitter to delay the change in SDA after SCL goes LOW.
  // IC_SDA_RX_HOLD is used whenever I2C acts as reciever to internally delay SDA line while SCL is HIGH.
  // ------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin : IC_SDA_HOLD_REG_PROC
     if(presetn == 1'b0) begin
       ic_sda_hold <= `IC_DEFAULT_SDA_HOLD;
     end
     else begin
       if(ic_sda_hold_we == 1'b1 && ic_enable[0] == 1'b0) begin
           case(byte_en)
             4'b1111 : ic_sda_hold[`IC_SDA_HOLD_RS-1:0]                      <= ipwdata[`IC_SDA_HOLD_RS-1:0];
             default : ic_sda_hold[`IC_SDA_HOLD_RS-1:0]                      <= ic_sda_hold_int[`IC_SDA_HOLD_RS-1:0];
           endcase
       end
     end // else presetn
   end
   
    assign ic_sda_hold_int = ic_sda_hold; 

  // ------------------------------------------------------
  // ACK_GENERAL_CALL register writes from the APB interface.
  // This 1-bit register controls whether, in Slave mode
  // **only**, if the I2C will assert the ACK bit whenever
  // a general call address is received.
  // ------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : ACK_GENERAL_PROC
     if(presetn==1'b0)
       ic_ack_general_call <= `IC_DEFAULT_ACK_GENERAL_CALL;
     else begin
       if(ic_ack_general_call_we==1'd1 && byte_en[0])
         ic_ack_general_call <= ipwdata[0];
     end // else presetn
   end // always




//##################################################################################
//# Identification Registers for DesignWare Peripherals
//##################################################################################

// The following signals include fixed version, type info registers and cc_constant values which will be pre-defined and constant.
  assign ic_comp_param_1[31:24] = 8'b0;
  assign ic_comp_param_1[23:16] = `ENCODED_IC_TX_BUFFER_DEPTH;
  assign ic_comp_param_1[15:8]  = `ENCODED_IC_RX_BUFFER_DEPTH;
  assign ic_comp_param_1[7]     = `IC_ADD_ENCODED_PARAMS;
  assign ic_comp_param_1[6]     = `IC_HAS_DMA;
  assign ic_comp_param_1[5]     = `IC_INTR_IO;
  assign ic_comp_param_1[4]     = `IC_HC_COUNT_VALUES;
  assign ic_comp_param_1[3:2]   = `IC_MAX_SPEED_MODE;
  assign ic_comp_param_1[1:0]   = `ENCODED_APB_DATA_WIDTH;
  assign ic_comp_version        = `IC_VERSION_ID;
  assign ic_comp_type           = 32'h44570140;

  // ------------------------------------------------------
  // -- APB read data mux
  //
  // -- The data from the selected register is
  // -- placed on a zero-padded 32-bit read data bus.
  // ------------------------------------------------------
  always @ (*)
  begin: IPRDATA_PROC
    iprdata = {32{1'b0}};
    case (1'b1)
      ic_hs_maddr_en       : iprdata[`IC_HS_MADDR_RS-1:0]       = ic_hs_maddr ;
      ic_hs_hcnt_en        : iprdata[`IC_HS_HCNT_RS-1:0]        = ic_hs_hcnt  ;
      ic_hs_lcnt_en        : iprdata[`IC_HS_LCNT_RS-1:0]        = ic_hs_lcnt  ;
      ic_fs_hcnt_en        : iprdata[`IC_FS_HCNT_RS-1:0]        = ic_fs_hcnt  ;
      ic_fs_lcnt_en        : iprdata[`IC_FS_LCNT_RS-1:0]        = ic_fs_lcnt  ;

      // jduarte 20110105 begin
      // CRM 9000368180
      ic_fs_spklen_en      : iprdata[`IC_FS_SPKLEN_RS-1:0]      = ic_fs_spklen[`IC_FS_SPKLEN_RS-1:0];   
      ic_hs_spklen_en      : iprdata[`IC_HS_SPKLEN_RS-1:0]      = ic_hs_spklen[`IC_HS_SPKLEN_RS-1:0];   
      // jduarte 20110105 end
      reg_timeout_rst_en   : iprdata[`REG_TIMEOUT_WIDTH-1:0]    = reg_timeout_rst[`REG_TIMEOUT_WIDTH-1:0];   
      ic_con_en            : begin 
                              iprdata[`IC_CON_RS-1:0] =  ic_con;
                             end
      ic_sar_en            : iprdata[`IC_SAR_RS-1:0]            = ic_sar;
      ic_tar_en            : begin
                              iprdata[11:0]           = ic_tar_reg[11:0] ;
                             end

      ic_data_cmd_en       : iprdata[`IC_DATA_RS-1:0]           = rx_pop_data;
      ic_ss_hcnt_en        : iprdata[`IC_SS_HCNT_RS-1:0]        = ic_ss_hcnt;
      ic_ss_lcnt_en        : iprdata[`IC_SS_LCNT_RS-1:0]        = ic_ss_lcnt;
      ic_intr_stat_en      : iprdata[`IC_INTR_STAT_RS-1:0]      = ic_intr_stat;
      ic_intr_mask_en      : iprdata[`IC_INTR_MASK_RS-1:0]      = ic_intr_mask;
      ic_raw_intr_stat_en  : iprdata[`IC_RAW_INTR_STAT_RS-1:0]  = ic_raw_intr_stat;
      ic_rx_tl_en          : iprdata[`IC_RX_TL_RS-1:0]          = ic_rx_tl;
      ic_tx_tl_en          : iprdata[`IC_TX_TL_RS-1:0]          = ic_tx_tl;
      ic_enable_en         : iprdata[`IC_ENABLE_RS-1:0]         = ic_enable_reg;
      ic_status_en         : begin
                            iprdata[`IC_STATUS_RS-1:0]          = ic_status;
                            end
      ic_txflr_en          : iprdata[`TX_ABW:0]                 = ic_txflr;
      ic_rxflr_en          : iprdata[`RX_ABW:0]                 = ic_rxflr;
      ic_clr_gen_call_en   : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[11];
      ic_clr_start_det_en  : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[10];
      ic_clr_stop_det_en   : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[9];
      ic_clr_activity_en   : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[8];
      ic_clr_rx_done_en    : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[7];
      ic_clr_tx_abrt_en    : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[6];
      ic_clr_rd_req_en     : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[5];
      ic_clr_tx_over_en    : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[3];
      ic_clr_rx_over_en    : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[1];
      ic_clr_rx_under_en   : iprdata[`IC_CLR_INTR_RS-1:0]       = ic_raw_intr_stat[0];
      ic_clr_intr_en       : iprdata[`IC_CLR_INTR_RS-1:0]       = |ic_raw_intr_stat;
      ic_tx_abrt_source_en : iprdata[`IC_TX_ABRT_SOURCE_RS+6+`TX_ABW:0] = {ic_txflr_flushed,{6{1'b0}},ic_tx_abrt_source};
      ic_comp_param_1_en   : iprdata[31:0]                      = ic_comp_param_1;
      ic_comp_version_en   : iprdata[31:0]                      = ic_comp_version;
      ic_comp_type_en      : iprdata[31:0]                      = ic_comp_type;
      ic_sda_setup_en      : iprdata[31:0]                      = {24'd0, ic_sda_setup};
      ic_sda_hold_en       : iprdata[`IC_SDA_HOLD_RS-1:0]       = ic_sda_hold;

      ic_ack_general_call_en:iprdata[0]                         = ic_ack_general_call;

      ic_enable_status_en  : iprdata[`IC_ENABLE_STATUS_RS-1:0]  = ic_enable_status;
    endcase
  end

   // ------------------------------------------------------
   // -- Synchronous reset for rx and tx fifos
   //
   //  The fifo read and write pointers are reset when
   //  presetn is activated and when the IC_ENABLE[0]
   //  is cleared.
   // ------------------------------------------------------
   assign fifo_rst_n = ((ic_enable_we  == 1'b0) && (ic_enable[0] == 1'b1) 
                         && (tx_abrt_flg_edg == 1'b0)
                       ) ||
                       ((ic_enable_we  == 1'b1) && (ipwdata[0] == 1'b1) && (ic_enable[0] == 1'b1) 
                          && (tx_abrt_flg_edg == 1'b0) 
                        && (byte_en[0] == 1'b1))
                        || ((ic_enable_we == 1'b1) && (byte_en[0] != 1'b1)
                          && ((ic_enable[0]==1'b1) ? (tx_abrt_flg_edg == 1'b0) : 1'b1)
                        );

   // ------------------------------------------------------
   // Fix for STAR 9000108249
   // Whenever a Tx-abort occurs, the TxFIFO is now *HELD* in
   // a flushed/reset state. This forces further writes into
   // the TxFIFO to be completely ignored, thereby avoiding
   // the condition where the DW_apb_i2c can potentially stall
   // (as per STAR - not transmitting when TXFLR is > 0).
   //
   // To re-enable successful writes into the TxFIFO, without
   // toggling IC_ENABLE, a READ of the IC_CLR_TX_ABRT register
   // is required.
   // ------------------------------------------------------

   // assign tx_fifo_rst_n = fifo_rst_n && (slv_clr_leftover_flg_edg == 1'b0);
   assign tx_fifo_rst_n = (fifo_rst_n_int & ic_enable[0])
                         && (slv_clr_leftover_flg_edg == 1'b0)
                         ;

   assign fix_a = ic_clr_tx_abrt_en | fifo_rst_n_int
                  ;
   assign fix_b = fix_a & fifo_rst_n; 
   assign fix_c = ~ic_enable[0] | fix_b;

   always @(posedge pclk or negedge presetn) begin : FIFO_RST_N_PROC
     if(!presetn)
       fifo_rst_n_int <= 1'd0;
     else
       fifo_rst_n_int <= fix_c;
   end // always
   

   // ------------------------------------------------------
   // -- Control signal generation
   //
   // -- The control signals to indicate mode and speed
   // -- Register decode assignments
   // ------------------------------------------------------
   assign ic_hs        = (speed == 2'b11)
   ;
   assign ic_fs        = (speed == 2'b10)
   ;
   assign ic_ss        = (speed == 2'b01);
   assign ic_master    = (ic_con[0] == 1'b1);
   assign ic_10bit_mst = (ic_con[4] == 1'b1);
   assign ic_10bit_slv = (ic_con[3] == 1'b1);
   assign ic_rstrt_en  = (ic_con[5] == 1'b1);
   assign ic_slave_en  = (ic_con[6] == 1'b0);
   assign p_det_ifaddr = (ic_con[7] == 1'b1);
   assign tx_empty_ctrl = (ic_con[8] == 1'b1);
   // ------------------------------------------------------
   // -- Count registers mux
   //
   // -- The data from the appropriate register is
   // -- passed to the DW_apb_i2c_clk_gen.v.
   // ------------------------------------------------------
   always @(ic_ss_hcnt or ic_ss_lcnt 
           or ic_ss or ic_fs_hcnt or ic_fs_lcnt
            or ic_hs_hcnt or ic_hs_lcnt or ic_hs
            ) begin: IC_COUNT_MUX_PROC
     begin
        if(ic_ss == 1'b1)
          begin
             ic_hcnt = ic_ss_hcnt;
             ic_lcnt = ic_ss_lcnt;
          end
        else if(ic_hs == 1'b1)
          begin
             ic_hcnt = ic_hs_hcnt;
             ic_lcnt = ic_hs_lcnt;
          end
        else
          begin
             ic_hcnt = ic_fs_hcnt;
             ic_lcnt = ic_fs_lcnt;
          end
     end
   end
endmodule



//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

//
// Filename    : DW_apb_i2c_bcm05.v
// Revision    : $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_bcm05.v#3 $
// Author      : Vikas Gokhale       5/17/04
// Description : DW_apb_i2c_bcm05.v Verilog module for DW_apb_i2c
//
// DesignWare IP ID: 15919a8c
//
////////////////////////////////////////////////////////////////////////////////


module DW_apb_i2c_bcm05 (
        clk,
        rst_n,
        init_n,
        inc_req_n,
        other_addr_g,
        word_count,
        empty,
        almost_empty,
        half_full,
        almost_full,
        full,
        error,
        this_addr,
        this_addr_g,
        next_word_count,
        next_empty_n,
        next_full,
        next_error
        );

parameter DEPTH         =  8;   // RANGE 4 to 16777216
parameter ADDR_WIDTH    =  3;   // RANGE 2 to 24
parameter COUNT_WIDTH   =  4;   // RANGE 3 to 25
parameter AE_LVL        =  2;   // RANGE 1 to DEPTH-1
parameter AF_LVL        =  2;   // RANGE 1 to DEPTH-1
parameter ERR_MODE      =  0;   // RANGE 0 to 1
parameter SYNC_DEPTH    =  2;   // RANGE 1 to 4
parameter IO_MODE       =  1;   // RANGE 0 to 1

parameter PIPE_GRAY     = 0;    // RANGE 0 to 1
parameter VERIF_EN      = 1;    // RANGE 0 to 5

localparam GRAY_VERIF_EN     = ((VERIF_EN==2)?4:((VERIF_EN==3)?1:VERIF_EN));
   

input                                 clk;              // clock input
input                                 rst_n;            // active low async reset
input                                 init_n;           // active low sync. reset
input                                 inc_req_n;        // active high request to advance
input  [COUNT_WIDTH-1 : 0]            other_addr_g;     // Gray pointer form oppos. I/F
output [COUNT_WIDTH-1 : 0]            word_count;       // Local word count output
output                                empty;            // Empty status flag
output                                almost_empty;     // Almost Empty status flag
output                                half_full;        // Half full status flag
output                                almost_full;      // Almost full status flag
output                                full;             // Full status flag
output                                error;            // Error status flag
output [ADDR_WIDTH-1 : 0]             this_addr;        // Local RAM address
output [COUNT_WIDTH-1 : 0]            this_addr_g;      // Gray coded pointer to other domain
output [COUNT_WIDTH-1 : 0]            next_word_count;  // Look ahead word count
output                                next_empty_n;     // Look ahead empty flag (active low)
output                                next_full;        // Look ahead full flag
output                                next_error;       // Look ahead error flag



 
localparam [COUNT_WIDTH-1 : 0] A_EMPTY_VECTOR  = AE_LVL;
localparam [COUNT_WIDTH-1 : 0] A_FULL_VECTOR   = DEPTH - AF_LVL;
localparam [COUNT_WIDTH-1 : 0] HLF_FULL_VECTOR = (DEPTH+1)/2;
localparam [COUNT_WIDTH-1 : 0] FULL_COUNT_BUS  = DEPTH;
localparam [COUNT_WIDTH-1 : 0] BUS_LOW         = 0;
localparam [COUNT_WIDTH-1 : 0] RESIDUAL_VALUE_BUS = ((1 << COUNT_WIDTH ) - ((DEPTH == (1 << (COUNT_WIDTH - 1)))? (DEPTH * 2) : 
                           ((DEPTH + 2) - (DEPTH & 1))) );
localparam [COUNT_WIDTH-1 : 0] OFFSET_RESIDUAL_BUS = (((((1 << COUNT_WIDTH ) - ((DEPTH == (1 << (COUNT_WIDTH - 1)))? (DEPTH * 2) : 
                           ((DEPTH + 2) - (DEPTH & 1))) ))/2 ));
localparam [COUNT_WIDTH-1 : 0] START_VALUE_BUS = ((((1 << COUNT_WIDTH ) - ((DEPTH == (1 << (COUNT_WIDTH - 1)))? (DEPTH * 2) : 
                           ((DEPTH + 2) - (DEPTH & 1))) ))/2 );
localparam [COUNT_WIDTH-1 : 0] END_VALUE_BUS = ((1 << COUNT_WIDTH ) -  1 - (((((1 << COUNT_WIDTH ) - ((DEPTH == (1 << (COUNT_WIDTH - 1)))? (DEPTH * 2) : 
                           ((DEPTH + 2) - (DEPTH & 1))) ))/2 )));
localparam [COUNT_WIDTH-1 : 0] COUNT_SIZED_ONE = 1;
localparam [ADDR_WIDTH-1 : 0]  ADDR_SIZED_ONE  = 1;
localparam [ADDR_WIDTH-1 : 0]  MODULUSM1 = (DEPTH==(1 << (COUNT_WIDTH-1)))? 0 :
                                            DEPTH + 1 - (DEPTH & 1);

localparam [COUNT_WIDTH-1 : 0] START_VALUE_GRAY_BUS = (START_VALUE_BUS  ^ (START_VALUE_BUS >> 1));

wire  [COUNT_WIDTH-1 : 0]       next_count_int;
wire  [ADDR_WIDTH-1 : 0]        next_this_addr_int;
wire  [COUNT_WIDTH-1 : 0]       next_this_addr_g_int;
wire                            next_empty_int;
wire                            next_almost_empty_int;
wire                            next_half_full_int;
wire                            next_almost_full_int;
wire                            next_full_int;

wire                            next_almost_empty;
wire                            next_half_full;
wire                            next_almost_full;
wire                            error_seen;
wire                            next_error_int;

wire  [COUNT_WIDTH-1 : 0]       count;

wire                            next_empty;

wire  [COUNT_WIDTH-1 : 0]       raw_sync;
wire  [COUNT_WIDTH-1 : 0]       other_addr_g_sync;

wire  [COUNT_WIDTH-1 : 0]       next_this_addr_g;
wire  [COUNT_WIDTH-1 : 0]       other_addr_decoded;

wire                            advance;
wire  [COUNT_WIDTH   : 0]       succesive_count_big;
wire  [COUNT_WIDTH-1 : 0]       succesive_count;
wire  [ADDR_WIDTH   : 0]        succesive_addr_big;
wire  [ADDR_WIDTH-1 : 0]        succesive_addr;

wire  [COUNT_WIDTH-1 : 0]       advanced_count;
reg   [COUNT_WIDTH-1 : 0]       next_word_count_int;
wire  [ADDR_WIDTH-1 : 0]        next_this_addr;

wire  [COUNT_WIDTH  : 0]        temp1;

wire  [COUNT_WIDTH-1 : 0]       wrd_count_p1;

wire  [COUNT_WIDTH-1 : 0]       wr_addr;
wire  [COUNT_WIDTH-1 : 0]       rd_addr;

wire                            at_end;
wire                            at_end_n;

reg  [COUNT_WIDTH-1 : 0]        count_int;
reg  [ADDR_WIDTH-1 : 0]         this_addr_int;
reg  [COUNT_WIDTH-1 : 0]        this_addr_g_int;
reg  [COUNT_WIDTH-1 : 0]        word_count_int;
 
reg                             empty_int;
reg                             almost_empty_int;
reg                             half_full_int;
reg                             almost_full_int;
reg                             full_int;
reg                             error_int;


 

  assign next_almost_empty     = (next_word_count_int <= A_EMPTY_VECTOR) ? 1'b1 : 1'b0;
  assign next_half_full        = (next_word_count_int >= HLF_FULL_VECTOR) ? 1'b1 : 1'b0; 
  assign next_almost_full      = (next_word_count_int >= A_FULL_VECTOR) ? 1'b1 : 1'b0; 
  assign next_empty            = (next_word_count_int == BUS_LOW) ? 1'b1 : 1'b0; 
  assign next_full_int         = (next_word_count_int == FULL_COUNT_BUS) ? 1'b1 : 1'b0; 

  assign error_seen            = !inc_req_n && at_end;

generate
  if (ERR_MODE == 0) begin : GEN_em_eq_0
    assign next_error_int        = error_seen || error_int;
  end else begin :              GET_em_ne_0
    assign next_error_int        = error_seen;
  end
endgenerate

  assign next_count_int        = advanced_count ^ START_VALUE_BUS;
  assign next_this_addr_int    = next_this_addr;

generate
 if (PIPE_GRAY==0) begin : GEN_PG_EQ_0
  assign next_this_addr_g_int  = next_this_addr_g ^ START_VALUE_GRAY_BUS;
 end else begin : GEN_NXT_NE_0
  reg [COUNT_WIDTH-1 : 0] next_this_addr_g_int_dly;
  always @ (posedge clk or negedge rst_n) begin : pipe_gray_PROC
    if (!rst_n)
       next_this_addr_g_int_dly <= {COUNT_WIDTH{1'b0}};
    else if (!init_n)
       next_this_addr_g_int_dly <= {COUNT_WIDTH{1'b0}};
    else
       next_this_addr_g_int_dly <= next_this_addr_g ^ START_VALUE_GRAY_BUS;
  end

  assign next_this_addr_g_int  = next_this_addr_g_int_dly;
 end
endgenerate

  assign next_empty_int        = ~next_empty;
  assign next_almost_empty_int = ~next_almost_empty;
  assign next_half_full_int    = next_half_full;
  assign next_almost_full_int  = next_almost_full;
 

// spyglass disable_block CheckDelayTimescale-ML
// SMD: Delay is used without defining timescale compiler directive
// SJ: The design incorporates delays for behavioral simulation. Timescale compiler directive is assumed to be defined in the test bench.
  always @ (posedge clk or negedge rst_n) begin : state_regs_PROC
     if (!rst_n) begin
       count_int <=  {COUNT_WIDTH{1'b0}};
       this_addr_int <=  {ADDR_WIDTH{1'b0}};
       this_addr_g_int <=  {COUNT_WIDTH{1'b0}};
       word_count_int <=  {COUNT_WIDTH{1'b0}};
       empty_int <=  1'b0;
       almost_empty_int <=  1'b0;
       half_full_int <=  1'b0;
       almost_full_int <=  1'b0;
       full_int <=  1'b0;
       error_int <=  1'b0;
     end else if (!init_n) begin
       count_int <=  {COUNT_WIDTH{1'b0}};
       this_addr_int <=  {ADDR_WIDTH{1'b0}};
       this_addr_g_int <=  {COUNT_WIDTH{1'b0}};
       word_count_int <=  {COUNT_WIDTH{1'b0}};
       empty_int <=  1'b0;
       almost_empty_int <=  1'b0;
       half_full_int <=  1'b0;
       almost_full_int <=  1'b0;
       full_int <=  1'b0;
       error_int <=  1'b0;
     end else begin
       count_int <=  next_count_int ;
       this_addr_int <=  next_this_addr_int ;
       this_addr_g_int <=  next_this_addr_g_int ;
       word_count_int <=  next_word_count_int ;
       empty_int <=  next_empty_int;
       almost_empty_int <=  next_almost_empty_int;
       half_full_int <=  next_half_full_int;
       almost_full_int <=  next_almost_full_int;
       full_int <=  next_full_int;
       error_int <=  next_error_int;
     end
    end
// spyglass enable_block CheckDelayTimescale-ML

  assign other_addr_g_sync  = raw_sync ^ START_VALUE_GRAY_BUS;

  assign count              = count_int ^ START_VALUE_BUS;
  assign word_count         = word_count_int;

  assign empty              = ~empty_int;
  assign almost_empty       = ~almost_empty_int;
  assign half_full          = half_full_int;
  assign almost_full        = almost_full_int;
  assign full               = full_int;
  assign error              = error_int;

generate
  if (IO_MODE == 0) begin :     GEN_iom_eq_0
    assign at_end         = ~empty_int;
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
    assign at_end_n       =  empty_int;
// spyglass enable_block W528
    assign rd_addr        = advanced_count;
    assign wr_addr        = other_addr_decoded;
  end else begin :              GEN_iom_ne_0
    assign at_end         =  full_int;
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
    assign at_end_n       = ~full_int;
// spyglass enable_block W528
    assign rd_addr        = other_addr_decoded;
    assign wr_addr        = advanced_count;
  end
endgenerate

  assign next_word_count    = init_n ? next_word_count_int : ({COUNT_WIDTH{1'b0}});
  assign next_empty_n       = ~next_empty && init_n;
  assign next_full          = next_full_int && init_n;
  assign next_error         = next_error_int && init_n;


  DW_apb_i2c_bcm21
   #(COUNT_WIDTH, SYNC_DEPTH+8, GRAY_VERIF_EN, 2) U_sync(
    .clk_d(clk),
    .rst_d_n(rst_n),
    .data_s(other_addr_g),
    .data_d(raw_sync) );

  // Gray Code encoder
  
  function [COUNT_WIDTH-1:0] func_bin2gray ;
    input [COUNT_WIDTH-1:0]             f_b;    // input
    begin 
      func_bin2gray  = f_b ^ ( f_b >> 1 ); 
    end
  endfunction

  assign next_this_addr_g = func_bin2gray ( advanced_count );

// spyglass disable_block Ac_conv01
// SMD: Checks sequential convergence of same-domain signals synchronized in the same destination domain
// SJ: The bus being synchronized and then decoded (i.e. other_addr_decoded), is a Gray transition coded bus and is therefore safe to be followed by converging logic.
// spyglass disable_block Ac_conv02
// SMD: Checks combinational convergence of same-domain signals synchronized in the same destination domain
// SJ: The bus being synchronized and then decoded (i.e. other_addr_decoded), is a Gray transition coded bus and is therefore safe to be followed by converging logic.
  // Gray Code decoder
  
  function [COUNT_WIDTH-1:0] func_gray2bin ;
    input [COUNT_WIDTH-1:0]             f_g;    // input
    reg   [COUNT_WIDTH-1:0]             f_b;
    integer                     f_i;
    begin 
      f_b = {COUNT_WIDTH{1'b0}};
      for (f_i=COUNT_WIDTH-1 ; f_i >= 0 ; f_i=f_i-1) begin
        if (f_i < COUNT_WIDTH-1)
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
          f_b[f_i] = f_g[f_i] ^ f_b[f_i+1];
// spyglass enable_block SelfDeterminedExpr-ML
        else
          f_b[f_i] = f_g[f_i];
      end // for (i
      func_gray2bin  = f_b; 
    end
  endfunction

  assign other_addr_decoded = func_gray2bin ( other_addr_g_sync );
// spyglass enable_block Ac_conv01
// spyglass enable_block Ac_conv02
 
  assign advance            = ~inc_req_n && (~at_end);

  assign advanced_count = (advance == 1'b1)? succesive_count : count;
  assign next_this_addr = (advance == 1'b1)? succesive_addr : this_addr_int;

// spyglass disable_block W164b
// SMD: Identifies assignments in which the LHS WIDTH is greater than the RHS WIDTH
// SJ: In most cases, the expressions in the code are written such that the LHS result is one bit larger than the RHS operands (or they should be at the very least). This is the most conservative approach in having one more bit on the left-hand side (LHS) than the two operands of an expression on the right-hand side (RHS).
  assign temp1              = wr_addr - rd_addr;
// spyglass enable_block W164b
  assign wrd_count_p1       = temp1[COUNT_WIDTH-1 : 0];


  assign succesive_count_big = count+COUNT_SIZED_ONE;
  assign succesive_addr_big  = this_addr_int+ADDR_SIZED_ONE;

generate
  if ((1 << ADDR_WIDTH) != DEPTH) begin : GEN_NXT_W_CNT_NOT_PWR2
    always @( wrd_count_p1 or rd_addr or wr_addr) begin : mk_this_non_pwr_2_addr_PROC
      reg [COUNT_WIDTH : 0] next_word_count_int_big;

      if (rd_addr > wr_addr)
        next_word_count_int_big = wrd_count_p1 - RESIDUAL_VALUE_BUS;
      else
// spyglass disable_block W164b
// SMD: Identifies assignments in which the LHS WIDTH is greater than the RHS WIDTH
// SJ: In most cases, the expressions in the code are written such that the LHS result is one bit larger than the RHS operands (or they should be at the very least). This is the most conservative approach in having one more bit on the left-hand side (LHS) than the two operands of an expression on the right-hand side (RHS).
        next_word_count_int_big = wrd_count_p1;
// spyglass enable_block W164b

      next_word_count_int = next_word_count_int_big[COUNT_WIDTH-1 : 0];
    end

    assign succesive_count = (this_addr_int != MODULUSM1)? succesive_count_big[COUNT_WIDTH-1:0] :
                                                        START_VALUE_BUS;
    assign succesive_addr  = (this_addr_int != MODULUSM1)? succesive_addr_big[ADDR_WIDTH-1:0]  :
                                                        BUS_LOW[ADDR_WIDTH-1 : 0];
    assign this_addr       = this_addr_int;
  end

  if ((1 << ADDR_WIDTH) == DEPTH) begin : GEN_NXT_W_CNT_PWR2
    always @( wrd_count_p1 ) begin : hook_up_pwr_2_wc_PROC
        next_word_count_int = wrd_count_p1;
    end

    assign succesive_count = succesive_count_big[COUNT_WIDTH-1:0];
    assign succesive_addr  = succesive_addr_big[ADDR_WIDTH-1:0];
    assign this_addr       = count[ADDR_WIDTH-1 : 0];
  end
endgenerate

    assign this_addr_g = this_addr_g_int;

endmodule
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DW_apb_i2c
// Component Version: 2.02a
// Release Type     : GA
//  ------------------------------------------------------------------------

// 
// Release version :  2.02a
// File Version     :        $Revision: #20 $ 
// Revision: $Id: //dwh/DW_ocb/DW_apb_i2c/amba_dev/src/DW_apb_i2c_intctl.v#20 $ 
//
//
// File    : DW_apb_i2c_intctl.v
//
//
// Author  : Hani Saleh
// Created : Tue Jun 18 15:57:39 BST 2002
// Abstract: Interrupt Control module for the DW_apb_i2c macrocell
//
//        1: Contains Interrupt status and raw status registers
//
//        2: Drives all interrupt signals from the I2C.
//
// -------------------------------------------------------------------
// -------------------------------------------------------------------

module DW_apb_i2c_intctl 
  (
   // APB bus interface
   pclk,
                           presetn,
                           // DW_apb_i2c_biu interface
                           rd_en,
                           // internal i2c interrupt flags
                           rx_underflow,
                           rx_overflow,  
                           rx_almost_full,
                           tx_overflow,  
                           tx_almost_empty,
                           gen_tx_almost_empty,
                           mst_activity,
                           slv_activity,
                           slv_rx_aborted,
                           slv_fifo_filled_and_flushed,
                           tx_empty_ctrl,
                           ic_rx_under_intr,
                           ic_rx_over_intr,  
                           ic_rx_full_intr, 
                           ic_tx_over_intr,  
                           ic_tx_empty_intr,
                           ic_rd_req_intr,   
                           ic_tx_abrt_intr,  
                           ic_rx_done_intr,  
                           ic_activity_intr, 
                           ic_stop_det_intr, 
                           ic_start_det_intr,
                           ic_gen_call_intr,
                           //from the toggle module
                           ic_disable,   
                           tx_abrt_flg,   
                           rx_done_flg,   
                           ic_rd_req_flg, 
                           p_det_flg, 
                           s_det_flg, 
                           rx_gen_call_flg,
                           slv_clr_leftover_flg,
                           set_tx_empty_en_flg,
                           tx_abrt_source,//tx_abrt sources combined signals
                           //regfile interface signals
                           ic_clr_intr_en,
                           ic_clr_rx_under_en,
                           ic_clr_rx_over_en,
                           ic_clr_tx_over_en,
                           ic_clr_rd_req_en,
                           ic_clr_tx_abrt_en,
                           ic_clr_rx_done_en,
                           ic_clr_activity_en,
                           ic_clr_stop_det_en,
                           ic_clr_start_det_en,
                           ic_clr_gen_call_en,
                           ic_enable,
                           ic_intr_mask,
                           ic_intr_stat,
                           ic_raw_intr_stat,
                           tx_abrt_flg_edg,
                           mst_activity_sync,
                           slv_activity_sync,
                           activity,
                           slv_rx_aborted_sync,
                           slv_fifo_filled_and_flushed_sync,
                           slv_clr_leftover_flg_edg,
                           set_tx_empty_en_flg_edg,
                           ic_tx_abrt_source,
                           ic_ack_general_call, 
                           //to top level outputs
                           ic_en
                           );
   // ------------------------------------------------------
   // -- Port declaration
   // ------------------------------------------------------
   // INPUTS
   input pclk;       // APB clock 
   input presetn;    // APB async reset
   input rd_en;      // read enable
   input rx_overflow;  
   input rx_underflow; 
   input rx_almost_full; // rx fifo almost full status
   input tx_overflow;  
   input tx_almost_empty; 
   input gen_tx_almost_empty; 
   input mst_activity;
   input slv_activity;
   input slv_rx_aborted;
   input slv_fifo_filled_and_flushed;
   input tx_empty_ctrl;
 
   //inputs from the toggle module
   input ic_disable;
   input tx_abrt_flg;//if pclk is async. to ic_clk, this signal toggles on tx_abrt signal
   input rx_done_flg;//if pclk is async. to ic_clk, this signal toggles on rx_done signal
   input ic_rd_req_flg;//if pclk is async. to ic_clk, this signal toggles on ic_rd_req signal
   input p_det_flg;//if pclk is async. to ic_clk, this signal toggles on p_det signal
   input s_det_flg;//if pclk is async. to ic_clk, this signal toggles on s_det signal
   input rx_gen_call_flg;//if pclk is async. to ic_clk, this signal toggles on rx_gen_call signal
   input [`IC_TX_ABRT_SOURCE_RS-1:0] tx_abrt_source;//tx_abrt sources combined signals
   input slv_clr_leftover_flg;//
   input set_tx_empty_en_flg;
   
   input ic_clr_intr_en;
   input ic_clr_rx_under_en;
   input ic_clr_rx_over_en;
   input ic_clr_tx_over_en;
   input ic_clr_rd_req_en;
   input ic_clr_tx_abrt_en;
   input ic_clr_rx_done_en;
   input ic_clr_activity_en;
   input ic_clr_stop_det_en;
   input ic_clr_start_det_en;
   input ic_clr_gen_call_en;
   input ic_enable;
   input [`IC_INTR_MASK_RS-1:0]      ic_intr_mask;
   
   //OUTPUTS
   //active high inturrepts
   output                            ic_rx_over_intr;  
   output                            ic_rx_under_intr; 
   output                            ic_rx_full_intr;
   output                            ic_tx_over_intr;  
   output                            ic_tx_abrt_intr;  
   output                            ic_rx_done_intr;  
   output                            ic_rd_req_intr;
   output                            ic_tx_empty_intr; 
   output                            ic_activity_intr; 
   output                            ic_stop_det_intr;
   output                            ic_start_det_intr;
   output                            ic_gen_call_intr;
   //active low inturrepts
   
   output [`IC_RAW_INTR_STAT_RS-1:0] ic_raw_intr_stat;
   output [`IC_INTR_STAT_RS-1:0]     ic_intr_stat;
   output [`IC_TX_ABRT_SOURCE_RS-1:0] ic_tx_abrt_source;//register that indicates tx_abrt source

   // Register that indicates if general call sequenes should be ACKD'd.
   input                             ic_ack_general_call;

   output                            ic_en;//logic 1: ic is enabled
   output                            tx_abrt_flg_edg;//this output is used to flush the tx fifo buffer
   output        mst_activity_sync;
   output        slv_activity_sync;
   output                            activity;//syncronouse acticity signal 
   output                            slv_rx_aborted_sync;
   output                            slv_fifo_filled_and_flushed_sync;
   output                            slv_clr_leftover_flg_edg;
   output                            set_tx_empty_en_flg_edg;

   // ------------------------------------------------------
   // -- local registers and wires
   // ------------------------------------------------------
   reg                               ic_en;//logic 1: ic is enabled
   reg                               ic_gen_call_intr;
   reg                               ic_start_det_intr;
   reg                               ic_stop_det_intr;
   reg                               ic_activity_intr;
   reg                               ic_rx_done_intr;
   reg                               ic_tx_abrt_intr;
   reg                               ic_rd_req_intr;
   reg                               ic_tx_empty_intr;
   reg                               ic_tx_over_intr;
   reg                               ic_rx_full_intr;
   reg                               ic_rx_over_intr;
   reg                               ic_rx_under_intr;
  
   
   reg [`IC_INTR_STAT_RS-1:0]        ic_intr_stat_int;
   reg                               raw_rx_under;
   reg                               raw_rx_over;
   wire                              raw_rx_full;
   //reg                               raw_rx_full;
   reg                               raw_tx_over;
   wire                              raw_tx_empty;
   //reg                               raw_tx_empty;
   reg                               raw_rd_req;
   reg                               raw_tx_abrt;
   reg                               raw_rx_done;
   reg                               raw_activity;
   reg                               raw_stop_det;
   reg                               raw_start_det;
   reg                               raw_gen_call;
   
   //synchronization registers
   wire                              slv_rx_aborted_sync;
   wire                              slv_fifo_filled_and_flushed;
   
   reg                               tx_abrt_flg_sync_q;
   reg                               rx_done_flg_sync_q;   
   reg                               ic_rd_req_flg_sync_q;  
   reg                               p_det_flg_sync_q;
   reg                               s_det_flg_sync_q;
   reg                               rx_gen_call_flg_sync_q;   
   reg                               slv_clr_leftover_flg_sync_q;
   reg                               set_tx_empty_en_flg_sync_q;

   reg [`IC_TX_ABRT_SOURCE_RS-1:0]   tx_abrt_source_sync_q;//tx_abrt sources combined signals


   reg [`IC_TX_ABRT_SOURCE_RS-1:0]   ic_tx_abrt_source;//register that indicates tx_abrt source
   
   //wires
   wire [`IC_TX_ABRT_SOURCE_RS-1:0]  tx_abrt_source_sync;//tx_abrt sources combined signals
   wire [`IC_TX_ABRT_SOURCE_RS-1:0]  tx_abrt_source_edg;//tx_abrt sources combined signals
   wire                              mst_activity_sync; 
   wire                              slv_activity_sync; 
   wire                              ic_disable_sync; 
   
   wire                              tx_abrt_flg_sync;
   wire                              rx_done_flg_sync;  
   wire                              ic_rd_req_flg_sync;   
   wire                              p_det_flg_sync;
   wire                              s_det_flg_sync;
   wire                              rx_gen_call_flg_sync;
   wire                              slv_clr_leftover_flg_sync;
   wire                              set_tx_empty_en_flg_sync;

   wire                              tx_abrt_flg_edg;
   wire                              rx_done_flg_edg; 
   wire                              ic_rd_req_flg_edg;   
   wire                              p_det_flg_edg;
   wire                              s_det_flg_edg;
   wire                              rx_gen_call_flg_edg;   
   wire                              slv_clr_leftover_flg_edg;   
   wire                              set_tx_empty_en_flg_edg;   

   wire                              activity;
   //wires to avoid reading from output ports (RMM rule)
   wire [`IC_INTR_STAT_RS-1:0]       ic_intr_stat;

   
  
   // ----------------------------------------------------------
   // -- Synchronization registers for flags input from ic_clk domain
   // ----------------------------------------------------------
   

   wire [`IC_TX_ABRT_SOURCE_RS-1:0]  ic2pl_tx_abrt_source;
   wire [`IC_TX_ABRT_SOURCE_RS-1:0]  sic2pl_tx_abrt_source_sync;
   assign ic2pl_tx_abrt_source = tx_abrt_source;
   assign tx_abrt_source_sync = sic2pl_tx_abrt_source_sync;

      DW_apb_i2c_bcm21
       #(
        .WIDTH       (`IC_TX_ABRT_SOURCE_RS),
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_tx_abrt_source_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_tx_abrt_source)
        ,.data_d              (sic2pl_tx_abrt_source_sync)
      );


   wire                              ic2pl_tx_abrt_flg;
   wire                              sic2pl_tx_abrt_flg_sync;
   assign ic2pl_tx_abrt_flg = tx_abrt_flg;
   assign tx_abrt_flg_sync = sic2pl_tx_abrt_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_tx_abrt_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_tx_abrt_flg)
        ,.data_d              (sic2pl_tx_abrt_flg_sync)
      );


   wire                              ic2pl_rx_done_flg;
   wire                              ic2pl_ic_rd_req_flg;
   wire                              sic2pl_rx_done_flg_sync;  
   wire                              sic2pl_ic_rd_req_flg_sync;  
   assign ic2pl_rx_done_flg = rx_done_flg;
   assign ic2pl_ic_rd_req_flg = ic_rd_req_flg;
   assign rx_done_flg_sync = sic2pl_rx_done_flg_sync;
   assign ic_rd_req_flg_sync = sic2pl_ic_rd_req_flg_sync;

      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_rx_done_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_rx_done_flg)
        ,.data_d              (sic2pl_rx_done_flg_sync)
      );

      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_ic_rd_req_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_ic_rd_req_flg)
        ,.data_d              (sic2pl_ic_rd_req_flg_sync)
      );


   wire                               ic2pl_p_det_flg;
   wire                               sic2pl_p_det_flg_sync;
   assign ic2pl_p_det_flg = p_det_flg;
   assign p_det_flg_sync = sic2pl_p_det_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_p_det_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_p_det_flg)
        ,.data_d              (sic2pl_p_det_flg_sync)
      );


   wire                              ic2pl_s_det_flg;
   wire                              sic2pl_s_det_flg_sync;
   assign ic2pl_s_det_flg = s_det_flg;
   assign s_det_flg_sync = sic2pl_s_det_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_s_det_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_s_det_flg)
        ,.data_d              (sic2pl_s_det_flg_sync)
      );


   wire                              ic2pl_rx_gen_call_flg;
   wire                              sic2pl_rx_gen_call_flg_sync;
   assign ic2pl_rx_gen_call_flg = rx_gen_call_flg;
   assign rx_gen_call_flg_sync = sic2pl_rx_gen_call_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_rx_gen_call_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_rx_gen_call_flg)
        ,.data_d              (sic2pl_rx_gen_call_flg_sync)
      );


   wire                              ic2pl_slv_clr_leftover_flg;
   wire                              sic2pl_slv_clr_leftover_flg_sync;
   assign ic2pl_slv_clr_leftover_flg = slv_clr_leftover_flg;
   assign slv_clr_leftover_flg_sync = sic2pl_slv_clr_leftover_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_slv_clr_leftover_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_slv_clr_leftover_flg)
        ,.data_d              (sic2pl_slv_clr_leftover_flg_sync)
      );


   wire                              ic2pl_set_tx_empty_en_flg;
   wire                              sic2pl_set_tx_empty_en_flg_sync;
   assign ic2pl_set_tx_empty_en_flg = set_tx_empty_en_flg;
   assign set_tx_empty_en_flg_sync = sic2pl_set_tx_empty_en_flg_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_set_tx_empty_en_flg_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_set_tx_empty_en_flg)
        ,.data_d              (sic2pl_set_tx_empty_en_flg_sync)
      );
































    
   // ----------------------------------------------------------
   // -- Edge detection circuitry for input from ic_clk domain
   // ----------------------------------------------------------
   always @(posedge pclk or negedge presetn) begin : EDGE_DET_PROC
      if(presetn == 1'b0) begin
         tx_abrt_flg_sync_q <= 1'b0;   
         rx_done_flg_sync_q <= 1'b0;
         ic_rd_req_flg_sync_q <= 1'b0;
         p_det_flg_sync_q <= 1'b0;
         s_det_flg_sync_q <= 1'b0; 
         rx_gen_call_flg_sync_q <= 1'b0;
         slv_clr_leftover_flg_sync_q <= 1'b0;
         tx_abrt_source_sync_q <=  {`IC_TX_ABRT_SOURCE_RS{1'b0}};
         set_tx_empty_en_flg_sync_q <= 1'b0;
      end else begin
         tx_abrt_flg_sync_q <= tx_abrt_flg_sync;   
         rx_done_flg_sync_q <= rx_done_flg_sync;   
         ic_rd_req_flg_sync_q <= ic_rd_req_flg_sync; 
         p_det_flg_sync_q <= p_det_flg_sync; 
         s_det_flg_sync_q <= s_det_flg_sync;
         rx_gen_call_flg_sync_q <= rx_gen_call_flg_sync;
         slv_clr_leftover_flg_sync_q <= slv_clr_leftover_flg_sync;
         tx_abrt_source_sync_q <= tx_abrt_source_sync;
         set_tx_empty_en_flg_sync_q <= set_tx_empty_en_flg_sync;
      end
   end


   assign tx_abrt_source_edg       = ((~tx_abrt_source_sync_q       & tx_abrt_source_sync)       |(tx_abrt_source_sync_q       & (~tx_abrt_source_sync))      );   
   assign tx_abrt_flg_edg          = ((~tx_abrt_flg_sync_q          & tx_abrt_flg_sync)          |(tx_abrt_flg_sync_q          & (~tx_abrt_flg_sync))         );   
   assign rx_done_flg_edg          = ((~rx_done_flg_sync_q          & rx_done_flg_sync)          |(rx_done_flg_sync_q          & (~rx_done_flg_sync))         );
   assign ic_rd_req_flg_edg        = ((~ic_rd_req_flg_sync_q        & ic_rd_req_flg_sync)        |(ic_rd_req_flg_sync_q        & (~ic_rd_req_flg_sync))       ); 
   assign p_det_flg_edg            = ((~p_det_flg_sync_q            & p_det_flg_sync)            |(p_det_flg_sync_q            & (~p_det_flg_sync))           );
   assign s_det_flg_edg            = ((~s_det_flg_sync_q            & s_det_flg_sync)            |(s_det_flg_sync_q            & (~s_det_flg_sync))           );
   assign rx_gen_call_flg_edg      = ((~rx_gen_call_flg_sync_q      & rx_gen_call_flg_sync)      |(rx_gen_call_flg_sync_q      & (~rx_gen_call_flg_sync))     );
   assign slv_clr_leftover_flg_edg = ((~slv_clr_leftover_flg_sync_q & slv_clr_leftover_flg_sync) |(slv_clr_leftover_flg_sync_q & (~slv_clr_leftover_flg_sync)));
   assign set_tx_empty_en_flg_edg  = ((~set_tx_empty_en_flg_sync_q  & set_tx_empty_en_flg_sync)  |(set_tx_empty_en_flg_sync_q  & (~set_tx_empty_en_flg_sync)) );

   

   wire                              ic2pl_mst_activity; 
   wire                              sic2pl_mst_activity_sync;
   assign ic2pl_mst_activity = mst_activity;
   assign mst_activity_sync = sic2pl_mst_activity_sync;
   DW_apb_i2c_bcm21
    #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_mst_activity_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_mst_activity)
        ,.data_d              (sic2pl_mst_activity_sync)
      );


   wire                              ic2pl_slv_activity; 
   wire                              sic2pl_slv_activity_sync;
   assign ic2pl_slv_activity = slv_activity;
   assign slv_activity_sync = sic2pl_slv_activity_sync;
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_slv_activity_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_slv_activity)
        ,.data_d              (sic2pl_slv_activity_sync)
      );


















   assign activity     = mst_activity_sync | slv_activity_sync;

   wire                      ic2pl_ic_disable;
   wire                      sic2pl_ic_disable_sync;
   assign ic2pl_ic_disable = ic_disable;
   assign ic_disable_sync  = sic2pl_ic_disable_sync;
   DW_apb_i2c_bcm41
    #(
        .RST_VAL     (1),
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm41_ic2pl_ic_disable_psyzr(
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_ic_disable)
        ,.data_d              (sic2pl_ic_disable_sync)
      );




   // ----------------------------------------------------------
   // -- Generate top level signals
   // ----------------------------------------------------------
   //pclk domain top level signals
   always @(posedge pclk or negedge presetn) begin : IC_EN_PROC
      if(presetn == 1'b0) 
        begin
           ic_en <= 1'b0;
        end else 
          begin
             ic_en <= ic_enable | activity | (!ic_disable_sync);
          end
   end


   wire                              ic2pl_slv_rx_aborted;
   wire                              sic2pl_slv_rx_aborted_sync;
   assign ic2pl_slv_rx_aborted = slv_rx_aborted;
   assign slv_rx_aborted_sync = sic2pl_slv_rx_aborted_sync;
   wire                              ic2pl_slv_fifo_filled_and_flushed;
   wire                              sic2pl_slv_fifo_filled_and_flushed_sync;
   assign ic2pl_slv_fifo_filled_and_flushed = slv_fifo_filled_and_flushed;
   assign slv_fifo_filled_and_flushed_sync = sic2pl_slv_fifo_filled_and_flushed_sync;
   // ------------------------------------------------------
   // Generate the PCLK-synchronised versions of:
   // - slv_rx_aborted
   // ------------------------------------------------------
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_slv_rx_aborted_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_slv_rx_aborted)
        ,.data_d              (sic2pl_slv_rx_aborted_sync)
      );

   // ------------------------------------------------------
   // Generate the PCLK-synchronised versions of:
   // - slv_fifo_filled_and_flushed
   // ------------------------------------------------------
      DW_apb_i2c_bcm21
       #(
        .F_SYNC_TYPE (`IC_SYNC_DEPTH),
        .VERIF_EN    (`IC_VERIF_EN)
      ) 
      U_DW_apb_i2c_bcm21_ic2pl_slv_fifo_filled_and_flushed_psyzr
      (
         .clk_d               (pclk)
        ,.rst_d_n             (presetn)
        ,.data_s              (ic2pl_slv_fifo_filled_and_flushed)
        ,.data_d              (sic2pl_slv_fifo_filled_and_flushed_sync)
      );


   // ------------------------------------------------------
   // -- Raw Interrupt Status Register - Read Only
   //
   //  This register contains the raw status of all
   //  DW_apb_i2c interrupts.
   //  Registers bits are set by hardware.
   // ------------------------------------------------------

   // tx fifo empty interrupt
   // is set and cleared under hardware control
   assign raw_tx_empty = ic_en & (tx_empty_ctrl ? gen_tx_almost_empty : tx_almost_empty);
   // rx fifo full interrupt
   // is set and cleared under hardware control
   assign raw_rx_full = rx_almost_full & ic_en;
   

    // tx fifo overflow interrupt is set by hardware
    // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_tx_fifo_overflow_PROC
      if (presetn == 1'b0)
        raw_tx_over <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_tx_over <= 1'b0;
              else
          if (tx_overflow == 1'b1)
            raw_tx_over <= 1'b1;
          else 
            if ((ic_clr_tx_over_en == 1'b1 || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_tx_over <= 1'b0;
   end
   
    // rx fifo overflow interrupt is set by hardware
    // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_rx_fifo_overflow_PROC
      if (presetn == 1'b0)
        raw_rx_over <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_rx_over <= 1'b0;
        else
          if (rx_overflow == 1'b1)
            raw_rx_over <= 1'b1;
          else
            if ((ic_clr_rx_over_en == 1'b1  || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_rx_over <= 1'b0;
    end
   
    // rx fifo underflow interrupt is set by hardware
    // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_rx_fifo_underflow_PROC
      if (presetn == 1'b0)
        raw_rx_under <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_rx_under <= 1'b0;
              else
          if (rx_underflow == 1'b1)
            raw_rx_under <= 1'b1;
          else 
            if ((ic_clr_rx_under_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_rx_under <= 1'b0;
   end
   
   // rx read request interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_rx_rd_req_PROC
      if (presetn == 1'b0)
        raw_rd_req <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_rd_req <= 1'b0;
        else
          if (ic_rd_req_flg_edg == 1'b1)
            raw_rd_req <= 1'b1;
          else 
            if ((ic_clr_rd_req_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_rd_req <= 1'b0;
   end
   
   // tx abrt interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_tx_abrt_PROC
      if (presetn == 1'b0)
        begin
           raw_tx_abrt <= 1'b0;
        end
      else
        if (ic_en == 1'b0)
          begin
             raw_tx_abrt <= 1'b0;
          end
      
        else
          begin
             if (tx_abrt_flg_edg == 1'b1)
               raw_tx_abrt <= 1'b1;
             else 
               if ((ic_clr_tx_abrt_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
                 raw_tx_abrt <= 1'b0;


          end // else: !if(ic_en == 1'b0)

   end

   // ic_tx_abrt_source register is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_ic_tx_abrt_source_PROC
      if (presetn == 1'b0)
        begin
           ic_tx_abrt_source <= {`IC_TX_ABRT_SOURCE_RS{1'b0}};
        end
      else if ((ic_clr_tx_abrt_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1)
               ic_tx_abrt_source <= {`IC_TX_ABRT_SOURCE_RS{1'b0}};
      else
        begin
           if(tx_abrt_source_edg[0] == 1'b1)  ic_tx_abrt_source[0] <= 1'b1;
           if(tx_abrt_source_edg[1] == 1'b1)  ic_tx_abrt_source[1] <= 1'b1;
           if(tx_abrt_source_edg[2] == 1'b1)  ic_tx_abrt_source[2] <= 1'b1;
           if(tx_abrt_source_edg[3] == 1'b1)  ic_tx_abrt_source[3] <= 1'b1;
           if(tx_abrt_source_edg[4] == 1'b1)  ic_tx_abrt_source[4] <= 1'b1;
           if(tx_abrt_source_edg[5] == 1'b1)  ic_tx_abrt_source[5] <= 1'b1;
           if(tx_abrt_source_edg[6] == 1'b1)  ic_tx_abrt_source[6] <= 1'b1;
           if(tx_abrt_source_edg[7] == 1'b1)  ic_tx_abrt_source[7] <= 1'b1;
           if(tx_abrt_source_edg[8] == 1'b1)  ic_tx_abrt_source[8] <= 1'b1;
           if(tx_abrt_source_edg[9] == 1'b1)  ic_tx_abrt_source[9] <= 1'b1;
           if(tx_abrt_source_edg[10] == 1'b1) ic_tx_abrt_source[10] <= 1'b1;
           if(tx_abrt_source_edg[11] == 1'b1) ic_tx_abrt_source[11] <= 1'b1;
           if(tx_abrt_source_edg[12] == 1'b1) ic_tx_abrt_source[12] <= 1'b1;
           if(tx_abrt_source_edg[13] == 1'b1) ic_tx_abrt_source[13] <= 1'b1;
           if(tx_abrt_source_edg[14] == 1'b1) ic_tx_abrt_source[14] <= 1'b1;
           if(tx_abrt_source_edg[15] == 1'b1) ic_tx_abrt_source[15] <= 1'b1;
           if(tx_abrt_source_edg[16] == 1'b1) ic_tx_abrt_source[16] <= 1'b1;
        end
   end
   // rx done interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_rx_done_PROC
      if (presetn == 1'b0)
        raw_rx_done <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_rx_done <= 1'b0;
        else
          if (rx_done_flg_edg == 1'b1)
            raw_rx_done <= 1'b1;
          else 
            if ((ic_clr_rx_done_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_rx_done <= 1'b0;
   end

   // ic activity interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_activity_PROC
      if (presetn == 1'b0)
        raw_activity <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_activity <= 1'b0;
              else
          if (activity == 1'b1)
            raw_activity <= 1'b1;
          else 
            if ((ic_clr_activity_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_activity <= 1'b0;
   end
   
   // ic start_det interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : raw_start_det_PROC
      if (presetn == 1'b0)
        raw_start_det <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_start_det <= 1'b0;
        else
          if (s_det_flg_edg == 1'b1)
            raw_start_det <= 1'b1;
          else 
            if ((ic_clr_start_det_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_start_det <= 1'b0;
   end
   
   // ic stop_det interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : RAW_STOP_DET_PROC
      if (presetn == 1'b0)
        raw_stop_det <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_stop_det <= 1'b0;
        else
          //          if (stop_det_sync == 1'b1)
          if (p_det_flg_edg == 1'b1)
            raw_stop_det <= 1'b1;
          else 
            if ((ic_clr_stop_det_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_stop_det <= 1'b0;
   end




   // ic gen_call interrupt is set by hardware
   // and cleared by a SW-read.
   always @(posedge pclk or negedge presetn) begin : RAW_GEN_CALL_PROC
      if (presetn == 1'b0)
        raw_gen_call <= 1'b0;
      else
        if (ic_en == 1'b0)
          raw_gen_call <= 1'b0;
        else
   // STAR 9000093547, 11/3/2008, JS
   // gen call interrupt will not assert if i2c is programmed to
   // NACK a gen call sequence.
          if ((rx_gen_call_flg_edg == 1'b1) 
              & ic_ack_general_call
            )
            raw_gen_call <= 1'b1;
          else 
            if ((ic_clr_gen_call_en == 1'b1   || ic_clr_intr_en == 1'b1) && rd_en == 1'b1) 
              raw_gen_call <= 1'b0;
   end

// MOH interrupt set and cleared by hardware
   
   //ic_raw_intr_stat generation

   assign          ic_raw_intr_stat[14] = 1'b0;
   assign          ic_raw_intr_stat[13] = 1'b0;
   assign          ic_raw_intr_stat[12] = 1'b0;
   assign          ic_raw_intr_stat[11] = raw_gen_call;
   assign          ic_raw_intr_stat[10] = raw_start_det;
   assign          ic_raw_intr_stat[9] = raw_stop_det;
   assign          ic_raw_intr_stat[8] = raw_activity;
   assign          ic_raw_intr_stat[7] = raw_rx_done;
   assign          ic_raw_intr_stat[6] = raw_tx_abrt;
   assign          ic_raw_intr_stat[5] = raw_rd_req;
   assign          ic_raw_intr_stat[4] = raw_tx_empty;
   assign          ic_raw_intr_stat[3] = raw_tx_over;
   assign          ic_raw_intr_stat[2] = raw_rx_full;
   assign          ic_raw_intr_stat[1] = raw_rx_over;
   assign          ic_raw_intr_stat[0] = raw_rx_under;
   
   
   // ------------------------------------------------------
   // -- Interrupt Status Register - Read Only
   //
   //  This register contains the status of all
   //  DW_apb_i2c interrupts after masking.
   // ------------------------------------------------------
   always @(ic_intr_mask or ic_raw_intr_stat) begin : ISR_PROC
        ic_intr_stat_int = ic_intr_mask & ic_raw_intr_stat;
   end
   assign ic_intr_stat = ic_intr_stat_int;
   

   // ------------------------------------------------------
   // -- Active High Interrupt Outputs
   //
   //  DW_apb_i2c interrupts can be active high or low
   //  depending on configuration parameter IC_INTR_POL
   // ------------------------------------------------------

   always @(posedge pclk or negedge presetn) begin : REGISTER_INTR_1_PROC
     if (presetn == 1'b0) begin
         ic_gen_call_intr    <= 1'd0;
         ic_start_det_intr   <= 1'd0;
         ic_stop_det_intr    <= 1'd0;
         ic_activity_intr    <= 1'd0;
         ic_rx_done_intr     <= 1'd0;
         ic_tx_abrt_intr     <= 1'd0;
         ic_rd_req_intr      <= 1'd0;
         ic_tx_empty_intr    <= 1'd0;
         ic_tx_over_intr     <= 1'd0;
         ic_rx_full_intr     <= 1'd0;
         ic_rx_over_intr     <= 1'd0;
         ic_rx_under_intr    <= 1'd0;
     end
     else begin
         ic_gen_call_intr    <= ic_intr_stat_int[11];
         ic_start_det_intr   <= ic_intr_stat_int[10];
         ic_stop_det_intr    <= ic_intr_stat_int[9] ;
         ic_activity_intr    <= ic_intr_stat_int[8] ;
         ic_rx_done_intr     <= ic_intr_stat_int[7] ;
         ic_tx_abrt_intr     <= ic_intr_stat_int[6] ;
         ic_rd_req_intr      <= ic_intr_stat_int[5] ;
         ic_tx_empty_intr    <= ic_intr_stat_int[4] ;
         ic_tx_over_intr     <= ic_intr_stat_int[3] ;
         ic_rx_full_intr     <= ic_intr_stat_int[2] ;
         ic_rx_over_intr     <= ic_intr_stat_int[1] ;
         ic_rx_under_intr    <= ic_intr_stat_int[0] ;
     end
   end

endmodule // DW_apb_i2c_intctl

