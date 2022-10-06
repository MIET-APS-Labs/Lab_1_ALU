`timescale 1ns / 1ps

module SIMD_add #(
    parameter VEC_LEN = 32,
    parameter OPERAND_DIGIT = 16,
    parameter OPERAND_NUM = VEC_LEN / OPERAND_DIGIT
) (
    input [VEC_LEN-1:0] vec1,
    input [VEC_LEN-1:0] vec2,
    input sub,

    output [OPERAND_NUM-1:0] carry_out,
    output [VEC_LEN-1:0] res
);

  genvar i;
  generate
    for (i = 0; i < OPERAND_NUM; i = i + 1) begin
      N_bit_full_adder #(OPERAND_DIGIT) adder (
          .A(vec1[(i+1)*OPERAND_DIGIT-1:i*OPERAND_DIGIT]),
          .B(vec2[(i+1)*OPERAND_DIGIT-1:i*OPERAND_DIGIT]),
          .sub (sub),

          .carry_out(carry_out[i]),
          .res(res[(i+1)*OPERAND_DIGIT-1:i*OPERAND_DIGIT])
      );
    end
  endgenerate

endmodule
