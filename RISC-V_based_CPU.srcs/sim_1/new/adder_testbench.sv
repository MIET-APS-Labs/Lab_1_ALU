`timescale 1ns / 1ps

`define WORD_LEN 32
// Max tests num = 999
`define TESTS_NUM 12

module adder_testbench ();

  reg [`WORD_LEN-1:0] A, B;
  reg sub;

  wire carry;
  wire [`WORD_LEN-1:0] res;
  N_bit_full_adder dut (
      .num1(A),
      .num2(B),
      .sub (sub),

      .carry_out(carry),
      .result(res)
  );

  initial begin
    $display("Testing SUM");
    sub = 0;
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A = 1000 - i * (2 + i % 2);
      B = i + 100 + i % 2;
      #100;
      if (res == (A + B)) begin
        $display("%d) PASSED %d + %d = %d", i, A, B, res);
      end else begin
        $display("%d) FAILED %d + %d = %d", i, A, B, res);
      end
    end

    $display("Testing SUB");
    sub = 1;
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A = 1000 - i * (2 + i % 2);
      B = i + 100 + i % 2;
      #100;
      if (res == (A - B)) begin
        $display("%d) PASSED %d - %d = %d", i, A, B, res);
      end else begin
        $display("%d) FAILED %d - %d = %d", i, A, B, res);
      end
    end

    #10;
    $finish;
  end

endmodule
