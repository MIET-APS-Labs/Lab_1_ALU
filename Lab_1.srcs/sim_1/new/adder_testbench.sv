`timescale 1ns / 1ps

// Max tests num = 999
`define TESTS_NUM 12
`define WORD_LEN 32

module adder_testbench ();

  reg [`WORD_LEN-1:0] A, B, B_sub;

  wire carry;
  wire [`WORD_LEN-1:0] res;
  N_bit_full_adder dut (
      .num1(A),
      .num2(B),
      .carry_out(carry),
      .result(res)
  );

  initial begin
    $display("Testing SUM");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A = 1000 - i * (2 + i % 2);
      B = i + 100 + i % 2;
      #100;
      if (res == (A + B)) begin
        $display("%d) GOOD %d + %d = %d", i, A, B, res);
      end else begin
        $display("%d) BAD %d + %d = %d", i, A, B, res);
      end
    end

    $display("Testing SUB");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A = 1000 - i * (2 + i % 2);
      B_sub = i + 100 + i % 2;
      B = (~B_sub + 1);
      #100;
      if (res == (A - B_sub)) begin
        $display("%d) GOOD %d - %d = %d", i, A, B_sub, res);
      end else begin
        $display("%d) BAD %d - %d = %d", i, A, B_sub, res);
      end
    end

    #10;
    $finish;
  end

endmodule
