`timescale 1ns / 1ps

module instr_rom #(
    parameter WIDTH = 32,
    parameter DEPTH = 64
) (
    input logic [$clog2(DEPTH)-1:0] addr,
    output logic [WIDTH-1:0] rd
);
  logic [WIDTH-1:0] ROM[0:DEPTH-1];
  initial $readmemb("prog.txt", ROM, 0, DEPTH - 1);
  assign rd = ROM[addr];
endmodule
