`timescale 1ns / 1ps

`define SWITCHES_NUM 16'b0000000000000100   // = 2

module cpu_top_testbench ();

  logic [6:0] hex;
  logic [7:0] dig;
  logic [15:0] leds;

  logic [31:0] out;

  logic CLK;
  parameter PERIOD = 20;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  RISC_V_based_CPU_top dut (
      .CLK100MHZ(CLK),
      .SW(`SWITCHES_NUM),

      .RD1_OUT(out),

      .C  (hex),
      .AN (dig),
      .LED(leds)
  );
endmodule
