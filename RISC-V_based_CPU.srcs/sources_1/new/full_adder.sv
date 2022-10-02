`timescale 1ns / 1ps

module full_adder (
    input logic A,
    input logic B,
    input logic carry_in,

    output logic carry_out,
    output logic res
);


  assign res = A ^ B ^ carry_in;
  assign carry_out = (A & B) | (A & carry_in) | (B & carry_in);

endmodule
