`timescale 1ns / 1ps

`define WORD_LEN 32
`define RF_WIDTH 32

// Max tests num = 999
`define TESTS_NUM 12

module rf_testbench ();

  logic CLK;

  logic WE;
  logic [$clog2(`WORD_LEN)-1-1:0] WA3;
  logic [`WORD_LEN-1:0] WD;

  logic [$clog2(`WORD_LEN)-1-1:0] RA1;
  logic [$clog2(`WORD_LEN)-1-1:0] RA2;
  logic [`WORD_LEN-1:0] RD1;
  logic [`WORD_LEN-1:0] RD2;

  reg_file #(`WORD_LEN, `RF_WIDTH
  ) dut (
      .clk (CLK),
      .adr1(RA1),
      .adr2(RA2),
      .adr3(WA3),
      .wd  (WD),
      .we3 (WE),

      .rd1(RD1),
      .rd2(RD2)
  );


  // Note: CLK must be defined as a reg when using this method
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

      WE   = 1'b1;
      WD   = data;
      WA3  = i;

      @(posedge CLK);
      #1;
      WE  = 0'b1;
      RA1 = i;
      @(posedge CLK);
      #1;
      if (RD1 == data) begin
        $display("PASSED: Write/Read correct: Addres = %d, Data = %b", i, data);
      end else begin
        $display("FAILED: Write/Read error: Addres = %d, Data = %b", i, data);
      end
    end


  end

endmodule
