`timescale 1ns / 1ps

`define BYTE_WIDTH 8

`define WORD_LEN 32
`define DEPTH 10

module tb ();
  initial begin
$display("%d %d %d", $clog2(3), $clog2(4), $clog2(10));
  end
endmodule
