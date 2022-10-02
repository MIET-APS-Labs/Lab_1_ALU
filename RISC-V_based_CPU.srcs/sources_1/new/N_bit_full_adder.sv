`timescale 1ns / 1ps


module N_bit_full_adder #(
    parameter DIGIT = 32
) (
    input [DIGIT-1:0] num1,
    input [DIGIT-1:0] num2,
    input sub,

    output logic carry_out,
    output logic [DIGIT-1:0] result
);

  logic [DIGIT-1:0] num2_real = sub ? ~num2 + 1 : num2;

  logic [DIGIT-1:0] carry;
  genvar i;
  generate
    full_adder f (
        num1[0],
        num2_real[0],
        0,
        carry[0],
        result[0]
    );

    for (i = 1; i < DIGIT; i = i + 1) begin
      full_adder f (
          num1[i],
          num2_real[i],
          carry[i-1],
          carry[i],
          result[i]
      );
    end
    assign carry_out = carry[DIGIT-1];
  endgenerate




endmodule
