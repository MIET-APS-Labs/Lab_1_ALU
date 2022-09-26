`timescale 1ns / 1ps

`include "myCPU_params.v"

module RISC_V_based_CPU (
    input  clk,
    input  rst,
    input  data_in,
    output data_out
);

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH) - 1;
  logic [COUNTER_WIDTH-1:0] clk_cntr = {COUNTER_WIDTH{1'b0}};
  always @(posedge clk) begin
    clk_cntr <= clk_cntr + 1'b1;
  end

  logic [`WORD_LEN-1:0] instruction;

  instr_rom #(`INSTR_WIDTH, `INSTR_DEPTH) my_instr_rom (
      .addr(clk_cntr),
      .rd  (instruction)
  );

  logic [`WORD_LEN-1:0] reg_read_data1;
  logic [`WORD_LEN-1:0] reg_read_data2;

  logic [`WORD_LEN-1:0] reg_write_data;
  logic reg_write_en;
  assign reg_write_en = instruction[29] | instruction[28];
  reg_file #(`WORD_LEN,
  `RF_WIDTH
  ) my_reg_file (
      .clk (clk),
      .adr1(instruction[22:18]),
      .adr2(instruction[17:13]),
      .adr3(instruction[4:0]),
      .wd  (reg_write_data),
      .we3 (reg_write_en),

      .rd1(RD1),
      .rd2(RD2)
  );

  logic ALU_flag;
  logic [`WORD_LEN-1:0] ALU_res;
  alu #(`WORD_LEN, `ALU_OP_LEN) my_alu (
      .A(reg_read_data1),
      .B(reg_read_data2),
      .ALUOp(instruction[27:23]),

      .Flag  (ALU_flag),
      .Result(ALU_res)
  );

endmodule
