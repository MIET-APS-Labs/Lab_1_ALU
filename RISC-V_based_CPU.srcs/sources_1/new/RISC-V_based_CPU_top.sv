`timescale 1ns / 1ps

`include "myCPU_params.v"

module RISC_V_based_CPU (
    input clk,
    input rst,
    input [15:0] SW,
    output [32:0] HEX
);

  // Const value sign extender

  logic [`WORD_LEN-1:0] const_val_ext;
  initial begin
    const_val_ext = 0;
  end
  always_comb begin
    const_val_ext[`WORD_LEN-1:0] <= {{(`WORD_LEN - 8) {instruction[7]}}, instruction[7:0]};
  end



  //  Program Counter

  logic const_increase_clk = (instruction[`INSTR_C] & ALU_flag) | instruction[`INSTR_B];
  logic [`WORD_LEN - 1:0] clk_increase_num = const_increase_clk ? const_val_ext : 1;

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH) - 1;
  logic [COUNTER_WIDTH-1:0] clk_cntr = {COUNTER_WIDTH{1'b0}};
  always_ff @(posedge clk) begin
    if (rst) begin
      clk_cntr <= {COUNTER_WIDTH{1'b0}};
    end else begin
      clk_cntr <= clk_cntr + clk_increase_num;
    end
  end




  // Instruction read-only memory

  logic [`WORD_LEN-1:0] instruction;
  instr_rom #(`INSTR_WIDTH, `INSTR_DEPTH) my_instr_rom (
      .addr(clk_cntr),
      .rd  (instruction)
  );



  // Switches value sign extender

  logic [`WORD_LEN-1:0] sw_val_ext;
  always_comb begin
    sw_val_ext[`WORD_LEN-1:0] <= {{(`WORD_LEN - 16) {SW[15]}}, SW[15:0]};
  end




  // Registers file

  logic [`WORD_LEN-1:0] reg_read_data1;
  logic [`WORD_LEN-1:0] reg_read_data2;

  logic [`WORD_LEN-1:0] reg_write_data;

  always_comb begin
    case (instruction[`INSTR_WS])
      2'b00: begin
        reg_write_data = const_val_ext;
      end
      2'b01: begin
        reg_write_data = sw_val_ext;
      end
      2'b10: begin
        reg_write_data = ALU_res;
      end

      default: begin
        reg_write_data = 0;
      end
    endcase
  end

  reg_file #(`WORD_LEN,
  `RF_WIDTH
  ) my_reg_file (
      .clk (clk),
      .adr1(instruction[`INSTR_RA1]),
      .adr2(instruction[`INSTR_RA2]),
      .adr3(instruction[`INSTR_WA]),
      .wd3 (reg_write_data),
      .we3 (instruction[29]),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );





  // ALU

  logic ALU_flag;
  logic [`WORD_LEN-1:0] ALU_res;
  alu #(`WORD_LEN, `ALU_OP_LEN) my_alu (
      .A(reg_read_data1),
      .B(reg_read_data2),
      .ALUOp(instruction[`INSTR_ALUop]),

      .Flag  (ALU_flag),
      .Result(ALU_res)
  );

  assign HEX = reg_read_data1;

endmodule
