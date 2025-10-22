`ifndef AHBRAM_IF_SV
`define AHBRAM_IF_SV

interface ahbram_if;
  logic clk;
  logic rstn;

  initial begin : rstn_gen
    assert_reset(10);
  end

  task automatic assert_reset(int nclks = 1, int delay = 0);
    #(delay * 1ns);
    repeat(nclks) @(posedge clk);
    rstn <= 0;
    repeat(5) @(posedge clk);
    rstn <= 1;
  endtask

endinterface


`endif // AHBRAM_IF_SV
