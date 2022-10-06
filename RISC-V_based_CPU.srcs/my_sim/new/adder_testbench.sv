`timescale 1ns / 1ps

`define WORD_LEN 32
// Max tests num = 999
`define TESTS_NUM 12

module adder_testbench ();

  logic [`WORD_LEN-1:0] A, B;
  logic sub;

  logic carry;
  logic [`WORD_LEN-1:0] res;
  N_bit_full_adder dut (
      .A(A),
      .B(B),
      .sub (sub),

      .carry_out(carry),
      .res(res)
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
