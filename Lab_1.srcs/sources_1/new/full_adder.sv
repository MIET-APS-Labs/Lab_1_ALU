`timescale 1ns / 1ps

module full_adder (
    input wire A,
    input wire B,
    input wire carry_in,

    output wire carry_out,
    output wire res
);


  assign res = A ^ B ^ carry_in;
  assign carry_out = (A & B) | (A & carry_in) | (B & carry_in);

endmodule
