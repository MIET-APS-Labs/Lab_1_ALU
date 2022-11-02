`timescale 1ns / 1ps

`define SWITCHES_NON_RST 16'b1000000000000010   // = 2
`define SWITCHES_RST 16'b0000000000000000   // = 0
`define APPROX_INSTR_NUM 100

`define DEBUG_ON 1

module cpu_top_testbench ();

  logic [6:0] hex;
  logic [7:0] dig;
  logic [15:0] leds;

  logic [15:0] sw;

  logic prog_finished;

  logic CLK;
  parameter PERIOD = 20;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  assign sw = `SWITCHES_NON_RST;
  //  always begin
  //    sw = `SWITCHES_NON_RST;
  //    #100000;
  //    sw = `SWITCHES_RST;
  //    #100000;
  //  end

  initial begin
    for (int i = 0; i < `APPROX_INSTR_NUM; i++) begin
      if (prog_finished) begin
        $finish;
      end
      @(posedge CLK);
    end
    $finish;
  end

  RISC_V_based_CPU_top #(`DEBUG_ON) dut (
      .CLK100MHZ(CLK),
      .SW(sw),

      .C  (hex),
      .AN (dig),
      .LED(leds),

      .PROG_FINISHED(prog_finished)
  );
endmodule
