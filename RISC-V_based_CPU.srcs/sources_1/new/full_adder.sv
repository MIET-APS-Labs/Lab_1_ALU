`timescale 1ns / 1ps

module full_adder (
    input A,
    input B,
    input carry_in,

    output carry_out,
    output res
);

  assign res = A ^ B ^ carry_in;
  assign carry_out = (A & B) | (A & carry_in) | (B & carry_in);

endmodule
