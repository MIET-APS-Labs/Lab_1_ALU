`timescale 1ns / 1ps

`define WORD_LEN 32

`define INSTR_WIDTH 32
`define INSTR_DEPTH 64

module instr_rom_testbench ();

  logic CLK;
  parameter PERIOD = 20;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  logic [`WORD_LEN-1:0] instruction;
  instr_rom dut (
      .addr(clk_cntr),
      .rd  (instruction)
  );

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH);
  bit [COUNTER_WIDTH-1:0] clk_cntr;
  initial begin
    for (int i = 0; i < `INSTR_DEPTH; i++) begin
      @(posedge CLK);
      #5;
      $display("%d) Instruction = %b", clk_cntr, instruction);
      clk_cntr <= clk_cntr + 1;
    end
      $finish;
  end
endmodule
