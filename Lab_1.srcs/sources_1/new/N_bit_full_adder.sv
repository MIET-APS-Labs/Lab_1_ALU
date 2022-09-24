`timescale 1ns / 1ps


module N_bit_full_adder #(
    parameter DIGIT = 32
) (
    input [DIGIT-1:0] num1,
    input [DIGIT-1:0] num2,

    output wire carry_out,
    output reg [DIGIT-1:0] result
);

  wire [DIGIT-1:0] carry;
  genvar i;
  generate
    full_adder f (
        num1[0],
        num2[0],
        0,
        carry[0],
        result[0]
    );

    for (i = 1; i < DIGIT; i = i + 1) begin
      full_adder f (
          num1[i],
          num2[i],
          carry[i-1],
          carry[i],
          result[i]
      );
    end
    assign carry_out = carry[DIGIT-1];
  endgenerate




endmodule
