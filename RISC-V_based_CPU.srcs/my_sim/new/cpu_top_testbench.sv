`timescale 1ns / 1ps

`define SWITCHES_NON_RST 16'b1111111111111111 
`define SWITCHES_RST 16'b0111111111111111   
`define INSTR_DEPTH 64

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

  initial begin
    sw = `SWITCHES_RST;
    @(negedge CLK);
    sw = `SWITCHES_NON_RST;
    @(negedge CLK);


    while (!prog_finished) begin
      @(posedge CLK);
    end

    $finish;
  end


  miriscv_core dut (
      .CLK100MHZ(CLK),
      .SW(sw),

      .C  (hex),
      .AN (dig),
      .LED(leds),

      .PROG_FINISHED(prog_finished)
  );


  //  Debug print
  int debug_iter = 0;
  always_ff @(posedge CLK) begin
    if (`DEBUG_ON) begin
      $display(
          "\n%d) SW = %b\nInstruction = %h\nIllegal instruction = %b\nWD3 = %h\nRD1 = %h\nRD2 = %h\nReset = %b\nProgram counter = %h",
          debug_iter, sw, dut.instruction, dut.illegal_instr_o, dut.reg_write_data,
          dut.reg_read_data1, dut.reg_read_data2, dut.rst, dut.PC);

      debug_iter++;
    end
  end

endmodule
