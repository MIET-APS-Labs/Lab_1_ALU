`timescale 1ns / 1ps

`include "myCPU_params.v"

module RISC_V_based_CPU_top (
    input CLK100MHZ,
    input [15:0] SW,

    output [`WORD_LEN-1:0] RD1_OUT,

    output [ 6:0] C,
    output [ 7:0] AN,
    output [15:0] LED
);
  logic rst;
  assign rst = SW[0];

  // Instruction read-only memory

  logic [`WORD_LEN-1:0] instruction;
  instr_rom #(`INSTR_WIDTH, `INSTR_DEPTH) my_instr_rom (
      .addr(PC),
      .rd  (instruction)
  );


  // Registers file

  logic [`WORD_LEN-1:0] reg_read_data1;
  logic [`WORD_LEN-1:0] reg_read_data2;

  logic [`WORD_LEN-1:0] reg_write_data;

  always_comb begin
    case (instruction[`INSTR_WS])
      2'b01: begin
        reg_write_data = sw_val_ext;
      end
      2'b10: begin
        reg_write_data = const_val_ext;
      end
      2'b11: begin
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
      .clk (CLK100MHZ),
      .adr1(instruction[`INSTR_RA1]),
      .adr2(instruction[`INSTR_RA2]),
      .adr3(instruction[`INSTR_WA]),
      .wd3 (reg_write_data),
      .we3 (instruction[`INSTR_WS+1] | instruction[-1+`INSTR_WS]),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );

  // Const value sign extender

  logic [`WORD_LEN-1:0] const_val_ext;
  assign const_val_ext = {
    {(`WORD_LEN - `CONST_LEN) {instruction[`INSTR_CONST+(`CONST_LEN-1)]}}, instruction[`INSTR_CONST]
  };




  //  Program Counter

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH);
  bit [COUNTER_WIDTH-1:0] PC;
  always_ff @(posedge CLK100MHZ, posedge rst) begin
    if (rst) begin
      PC <= {COUNTER_WIDTH{1'b0}};
    end else begin
      $display("SW: %b\nReset: %b\nProgram counter: %d", SW, rst, PC);
      if ((instruction[`INSTR_C] & ALU_flag) | instruction[`INSTR_B]) begin
        PC <= PC + const_val_ext;
      end else begin
        PC <= PC + 1;
      end
    end
  end

  assign LED[5:0]  = PC;
  assign LED[15:6] = reg_read_data1[9:0];
  assign RD1_OUT = reg_read_data1;


  // Switches value sign extender

  logic [`WORD_LEN-1:0] sw_val_ext;
  assign sw_val_ext = {{(`WORD_LEN - 15) {SW[15]}}, SW[15:1]};





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

  disp_HEX my_disp_HEX (
      .CLK(CLK100MHZ),
      .num(reg_read_data1),
      .HEX(C),
      .DIG(AN)
  );

endmodule
