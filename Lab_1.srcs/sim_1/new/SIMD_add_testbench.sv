`timescale 1ns / 1ps

// Max tests num = 999
// Max operand = 65535

`define TESTS_NUM 12
`define WORD_LEN 32
`define SIMD_OPERAND_DIGIT 16
`define SIMD_OPERAND_NUM 2

module SIMD_add_testbench ();

  reg [`WORD_LEN-1:0] A, B;
  reg sub;

  wire adder_carry_out;
  wire [`WORD_LEN-1:0] adder_res;

  N_bit_full_adder #(`WORD_LEN) adder (
      .num1(A),
      .num2(B),
      .sub (sub),

      .carry_out(adder_carry_out),
      .result(adder_res)
  );

  wire [`SIMD_OPERAND_NUM-1:0] SIMD_carry;
  wire [`WORD_LEN-1:0] SIMD_res;

  SIMD_add #(`WORD_LEN, `SIMD_OPERAND_DIGIT, `SIMD_OPERAND_NUM) dut (
      .num1(A),
      .num2(B),
      .sub (sub),

      .carry_out(SIMD_carry),
      .result(SIMD_res)
  );

  initial begin
    $display("\n\n*******************************************");
    $display("Testing SUM");
    sub = 0;
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A[`SIMD_OPERAND_DIGIT-1:0] = 1000 + i * (2 + i % 2);
      A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] = 40000 - i * 100 * (2 + i % 2);

      B[`SIMD_OPERAND_DIGIT-1:0] = i + 100 + i % 2;
      B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] = 25000 - i * 100 + i % 2;
      #100;
      if ((SIMD_res[`SIMD_OPERAND_DIGIT-1:0] == (A[`SIMD_OPERAND_DIGIT-1:0] + B[`SIMD_OPERAND_DIGIT-1:0])) & (SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] == (A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] + B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT]))) begin
        $display("%d) GOOD %d + %d = %d     %d + %d = %d    Source: %b", i,
                 A[`SIMD_OPERAND_DIGIT-1:0], B[`SIMD_OPERAND_DIGIT-1:0],
                 SIMD_res[`SIMD_OPERAND_DIGIT-1:0], A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT], SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 SIMD_res);
      end else begin
        $display("%d) BAD %d + %d = %d     %d + %d = %d    Source: %b", i,
                 A[`SIMD_OPERAND_DIGIT-1:0], B[`SIMD_OPERAND_DIGIT-1:0],
                 SIMD_res[`SIMD_OPERAND_DIGIT-1:0], A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT], SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 SIMD_res);
      end
    end

    $display("\n\n*******************************************");
    $display("Testing SUB");
    sub = 1;
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A[`SIMD_OPERAND_DIGIT-1:0] = 1000 + i * (2 + i % 2);
      A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] = 40000 - i * 100 * (2 + i % 2);

      B[`SIMD_OPERAND_DIGIT-1:0] = i + 100 + i % 2;
      B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] = 2500 - i * 100 + i % 2;
      #100;
      if ((SIMD_res[`SIMD_OPERAND_DIGIT-1:0] == (A[`SIMD_OPERAND_DIGIT-1:0] - B[`SIMD_OPERAND_DIGIT-1:0])) & (SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] == (A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT] - B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT]))) begin
        $display("%d) GOOD %d - %d = %d     %d - %d = %d    Source: %b", i,
                 A[`SIMD_OPERAND_DIGIT-1:0], B[`SIMD_OPERAND_DIGIT-1:0],
                 SIMD_res[`SIMD_OPERAND_DIGIT-1:0], A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT], SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 SIMD_res);
      end else begin
        $display("%d) BAD %d - %d = %d     %d - %d = %d    Source: %b", i,
                 A[`SIMD_OPERAND_DIGIT-1:0], B[`SIMD_OPERAND_DIGIT-1:0],
                 SIMD_res[`SIMD_OPERAND_DIGIT-1:0], A[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 B[`WORD_LEN-1:`SIMD_OPERAND_DIGIT], SIMD_res[`WORD_LEN-1:`SIMD_OPERAND_DIGIT],
                 SIMD_res);
      end
    end

    #10;
    $finish;
  end

endmodule
