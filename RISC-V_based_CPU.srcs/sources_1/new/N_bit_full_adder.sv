`timescale 1ns / 1ps


module N_bit_full_adder #(
    parameter WORD_LEN = 32
) (
    input [WORD_LEN-1:0] A,
    input [WORD_LEN-1:0] B,
    input sub,

    output carry_out,
    output [WORD_LEN-1:0] res
);

  logic [WORD_LEN-1:0] B_real;
  assign B_real = sub ? ~B + 1 : B;
  
  logic [WORD_LEN-1:0] carry;
  genvar i;
  generate
    full_adder f (
        A[0],
        B_real[0],
        0,
        carry[0],
        res[0]
    );

    for (i = 1; i < WORD_LEN; i = i + 1) begin
      full_adder f (
          A[i],
          B_real[i],
          carry[i-1],
          carry[i],
          res[i]
      );
    end
    assign carry_out = carry[WORD_LEN-1];
  endgenerate

endmodule
