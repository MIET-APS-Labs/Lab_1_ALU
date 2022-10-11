`timescale 1ns / 1ps

`define SWITCHES_NON_RST 16'b1000000000000010   // = 2
`define SWITCHES_RST 16'b0000000000000000   // = 0

module cpu_top_testbench ();

  logic [6:0] hex;
  logic [7:0] dig;
  logic [15:0] leds;

  logic [15:0] sw;

  logic CLK;
  parameter PERIOD = 20;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  always begin
    sw = `SWITCHES_NON_RST;
    #100000;
    sw = `SWITCHES_RST;
    #100000;
  end

  RISC_V_based_CPU_top dut (
      .CLK100MHZ(CLK),
      .SW(sw),

      .C  (hex),
      .AN (dig),
      .LED(leds)
  );
endmodule
