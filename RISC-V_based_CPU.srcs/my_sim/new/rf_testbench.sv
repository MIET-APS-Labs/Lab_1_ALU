`timescale 1ns / 1ps

`define WORD_LEN 32
`define RF_DEPTH 32

// Max tests num = 999
`define TESTS_NUM 12

module rf_testbench ();

  logic CLK;

  logic WE3;
  logic [$clog2(`WORD_LEN)-1:0] WA3;
  logic [`WORD_LEN-1:0] WD3;

  logic [$clog2(`WORD_LEN)-1:0] RA1;
  logic [$clog2(`WORD_LEN)-1:0] RA2;

  logic RST;

  logic [`WORD_LEN-1:0] RD1;
  logic [`WORD_LEN-1:0] RD2;

  reg_file #(`WORD_LEN,
  `RF_DEPTH
  ) dut (
      .clk (CLK),
      .adr1(RA1),
      .adr2(RA2),
      .adr3(WA3),
      .wd3 (WD3),
      .we3 (WE3),
      .rst (RST),

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

    RST = 1'b1;  // Reset
    @(posedge CLK);
    #10;
    RST = 1'b0;
    $display("\nCheck nullifying all regs after reset");
    WE3 = 1'b0;  //reading data
    for (integer i = 0; i < `RF_DEPTH; i++) begin
      RA1 = i;
      @(posedge CLK);
      #1;
      if (RD1 == '0) begin
        $display("PASSED: Nullify correct: Addres = %d, Read data = %b", i, RD1);
      end else begin
        $display("FAILED: Nullify invalid: Addres = %d, Read data = %b", i, RD1);
      end
    end

    $display("\nCheck Write/Read\n");
    for (integer i = 0; i < `RF_DEPTH; i++) begin

      @(posedge CLK);
      #1;
      data = $urandom();  //returns 32 bit random
      WE3  = 1'b1;  // writing data
      WD3  = data;
      WA3  = i;
      @(posedge CLK);
      #1;

      WE3 = 1'b0;  //reading data
      RA1 = i;
      @(posedge CLK);
      #1;
      if (RD1 == data) begin
        $display("PASSED: Write/Read correct: Addres = %d, Test data = %b, Read data = %b", i,
                 data, RD1);
      end else begin
        $display("FAILED: Write/Read invalid: Addres = %d, Test data = %b, Read data = %b", i,
                 data, RD1);
      end
    end
    $finish;

  end

endmodule
