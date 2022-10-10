`timescale 1ns / 1ps

`define WORD_LEN 32
`define RF_WIDTH 32

// Max tests num = 999
`define TESTS_NUM 12

module rf_testbench ();

  logic CLK;

  logic WE3;
  logic [$clog2(`WORD_LEN)-1:0] WA3;
  logic [`WORD_LEN-1:0] WD3;

  logic [$clog2(`WORD_LEN)-1:0] RA1;
  logic [$clog2(`WORD_LEN)-1:0] RA2;
  logic [`WORD_LEN-1:0] RD1;
  logic [`WORD_LEN-1:0] RD2;

  reg_file #(`WORD_LEN,
  `RF_WIDTH
  ) dut (
      .clk (CLK),
      .adr1(RA1),
      .adr2(RA2),
      .adr3(WA3),
      .wd3 (WD3),
      .we3 (WE3),

      .rd1(RD1),
      .rd2(RD2)
  );

  parameter PERIOD = 10;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  initial begin

    int data;
    for (integer i = 0; i < `RF_WIDTH; i++) begin
      @(posedge CLK);
      #1;
      data = $urandom();  //returns 32 bit random

      WE3   = 1'b1;
      WD3   = data;
      WA3  = i;

      @(posedge CLK);
      #1;
      WE3  = 1'b0;
      RA1 = i;
      @(posedge CLK);
      #1;
      if (RD1 == data) begin
        $display("PASSED: Write/Read correct: Addres = %d, Test data = %b, Read data = %b", i,
                 data, RD1);
      end else begin
        $display("FAILED: Write/Read correct: Addres = %d, Test data = %b, Read data = %b", i,
                 data, RD1);
      end
    end
    $finish;

  end

endmodule
