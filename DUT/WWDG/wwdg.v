module wwdg 
  (
  input  wire        PCLK,    // PCLK for timer operation
  input  wire        PRESETn, // Reset

  input  wire        PSEL,    // Device select

  input  [3:0]        PSTRB,    // 

  input  wire [15:0] PADDR,   // Address
  input  wire        PENABLE, // Transfer control
  input  wire        PWRITE,  // Write control
  input  wire [31:0] PWDATA,  // Write data
  input  wire        wwdg_hw_start , //through option byte to start wwdg

  output wire [31:0] PRDATA,  // Read data
  output wire        PREADY,
  output wire        PSLVERR,
  
  output wire        WDOGINT,   // Watchdog interrupt 
  output wire        WDGRESET   // Timer interrupt output
  );

// Signals for read/write controls
wire          read_enable;
wire          write_enable;
wire          write_enable00;
wire          write_enable04;
wire          write_enable08;

reg    [31:0] read_mux_word;

reg    [7:0]  cr;
reg    [9:0]  cfr;
wire   [6:0]  wr;
wire   [1:0]  wdg_tb;
wire          ewi;
reg           ewif;

reg   [14:0]  ckcnt;
wire          wdten;

wire          ckcnt_eqmx;
wire          wr_cr;
wire          wdt_rst_tmp;
reg           wdt_rst;

assign wdten   =  cr[7] | wwdg_hw_start;
assign wr      = cfr[6:0];   //windows value for compare to cr[6:0]
assign wdg_tb  = cfr[8:7];
assign ewi     = cfr[9];
 
// Start of main code
// Read and write control signals
assign  read_enable  = PSEL & PENABLE &  (~PWRITE); // assert for whole APB read transfer
assign  write_enable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
assign  write_enable00 = write_enable & (PADDR[6:2] == 5'b00000);
assign  write_enable04 = write_enable & (PADDR[6:2] == 5'b00001);
assign  write_enable08 = write_enable & (PADDR[6:2] == 5'b00010);

//----------------------------------------------------------
wire   [31:0] pwdata;

assign pwdata[31:0] = (PSTRB[3:0] == 4'b1111) ? PWDATA[31:0] 
                    : (PSTRB[3:0] == 4'b1100) ? {16'h0,PWDATA[31:16]} 
                    : (PSTRB[3:0] == 4'b0011) ? {16'h0,PWDATA[15:0]} 
                    : (PSTRB[3:0] == 4'b0001) ? {24'h0,PWDATA[7:0]} 
                    : (PSTRB[3:0] == 4'b0010) ? {24'h0,PWDATA[15:8]} 
                    : (PSTRB[3:0] == 4'b0100) ? {24'h0,PWDATA[23:16]} 
                    : (PSTRB[3:0] == 4'b1000) ? {24'h0,PWDATA[31:24]} 
                    : 32'h0;
//---------------------------------------------------------------------


always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      cr <= 8'h7f ; 
    else if (write_enable00) begin
    //  cr[6:0] <= PWDATA[6:0];
      cr[6:0] <= pwdata[6:0];
   //   cr[7] <= PWDATA[7] ? 1'b1 : cr[7];
      cr[7] <= pwdata[7] ? 1'b1 : cr[7];
    end else if (ckcnt_eqmx)            //4096 x 2*wg_tb cycles
      cr[6:0] <= cr[6:0] - 1'b1;
  end

always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      cfr <= 10'h07f ;  
    else if (write_enable04) begin
    //  cfr[8:0] <= PWDATA[8:0];
      cfr[8:0] <= pwdata[8:0];
   //   cfr[9] <= PWDATA[9] ? 1'b1 : cfr[9];
      cfr[9] <= pwdata[9] ? 1'b1 : cfr[9];
    end  
  end  

always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      ewif <= 1'b0 ;  
  //  else if ((ckcnt_eqmx && (cr[6:0] == 7'h41)) || (write_enable00 && (PWDATA[6:0] == 7'h40)))   
    else if ((ckcnt_eqmx && (cr[6:0] == 7'h41)) || (write_enable00 && (pwdata[6:0] == 7'h40)))   
      ewif <= 1'b1 ;  
 //   else if (write_enable08 & (~PWDATA[0])) begin
    else if (write_enable08 & (~pwdata[0])) begin
      ewif<= 1'b0;
    end  
  end 

  // Second level of read mux
  always @(*)
  begin
    case (PADDR[6:2])
      5'b00000:   read_mux_word = {{24{1'b0}},cr };   
      5'b00001:   read_mux_word = {{22{1'b0}},cfr };   
      5'b00010:   read_mux_word = {{31{1'b0}},ewif};   
      default : read_mux_word = {32{1'b0}};
    endcase
  end

  // Output read data to APB
  assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    ckcnt <= 15'h0000 ;
  else if ((!wdten) | wr_cr) 
    ckcnt <= 15'h0000 ;
  else if (ckcnt_eqmx)
    ckcnt <= 15'h0000 ;
  else 
    ckcnt <= ckcnt + 1'd1;

assign ckcnt_eqmx = wdg_tb == 2'b00 ? ckcnt[11:0] == 12'hfff  :
                    wdg_tb == 2'b01 ? ckcnt[12:0] == 13'h1fff :
                    wdg_tb == 2'b10 ? ckcnt[13:0] == 14'h3fff :
                                      ckcnt       == 15'h7fff ;
 
assign wr_cr = write_enable00;  

assign wdt_rst_tmp  = ((wr_cr && (cr[6:0] >  wr[6:0])) || ~cr[6]) && wdten ;
 
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
       wdt_rst        <= 1'b0; 
  else if (wdt_rst_tmp)
       wdt_rst        <= 1'b1; 

assign WDGRESET = wdt_rst;

assign WDOGINT = ewi & ewif;

endmodule




