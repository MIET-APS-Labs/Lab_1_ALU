`timescale 1ns / 1ps

module reg_file #(
    parameter WORD_LEN   = 32,
    parameter WIDTH  = 32
) (
    input clk,
    input [$clog2(WIDTH)-1:0] adr1,  // address
    input [$clog2(WIDTH)-1:0] adr2,  // address
    input [$clog2(WIDTH)-1:0] adr3,  // address
    input [WORD_LEN:0] wd,  // Write Data
    input we3,  // Write Enable

    output [WORD_LEN:0] rd1,  // Read Data
    output [WORD_LEN:0] rd2   // Read Data
);
  logic [WORD_LEN-1:0] RAM[0:WIDTH-1];

  assign rd1 = (adr1 == 0) ? 0 : RAM[adr1];
  assign rd2 = RAM[adr2];

  always_ff @(posedge clk) begin
    if (we3 && adr3) begin
      RAM[adr3] <= wd;
    end
  end

endmodule
