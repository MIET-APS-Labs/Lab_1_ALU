`timescale 1ns / 1ps

`include "myCPU_params.v"

module RISC_V_based_CPU_top (
    input CLK100MHZ,
    input [15:0] SW,

    output [ 6:0] C,
    output [ 7:0] AN,
    output [15:0] LED
);
  logic rst;
  assign rst = SW[15];

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
    case (instruction[`C_COBRA_INSTR_WS])
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
      .adr1(instruction[`C_COBRA_INSTR_RA1]),
      .adr2(instruction[`C_COBRA_INSTR_RA2]),
      .adr3(instruction[`C_COBRA_INSTR_WA]),
      .wd3 (reg_write_data),
      .we3 (instruction[`C_COBRA_INSTR_WS_1] | instruction[`C_COBRA_INSTR_WS_2]),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );

  // Const value sign extender

  logic [`WORD_LEN-1:0] const_val_ext;
  assign const_val_ext = {
    {(`WORD_LEN - `CONST_LEN) {instruction[`C_COBRA_INSTR_CONST+(`CONST_LEN-1)]}},
    instruction[`C_COBRA_INSTR_CONST]
  };




  //  Program Counter

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH);
  bit [COUNTER_WIDTH-1:0] PC;
  always_ff @(posedge CLK100MHZ) begin
    if (~rst) begin
      //$display("\nReseted reg_read_data1 = %b\n", reg_read_data1);
      PC <= 0;
    end else begin
      //$display("SW: %b\nReset: %b\nProgram counter: %d", SW, rst, PC);
      if ((instruction[`C_COBRA_INSTR_C] & ALU_flag) | instruction[`C_COBRA_INSTR_B]) begin
        PC <= PC + const_val_ext;
      end else begin
        PC <= PC + 1;
      end
    end

    // B[31] C[30] WS[29:28] ALUop[27:23] RA1[22:18] RA2[17:13] CONST[12:5] WA[4:0]
    // $display(
    //     "PC = %d; B = %b; C = %b; WS = %b; ALUop = %b; RA1 = %b; RA2 = %b; CONST = %b; WA = %b",
    //     PC, instruction[`C_COBRA_INSTR_B], instruction[`C_COBRA_INSTR_C], instruction[`C_COBRA_INSTR_WS],
    //     instruction[`C_COBRA_INSTR_ALUop], instruction[`C_COBRA_INSTR_RA1], instruction[`C_COBRA_INSTR_RA2],
    //     instruction[`C_COBRA_INSTR_CONST], instruction[`C_COBRA_INSTR_WA]);

  end




  // Switches value sign extender

  logic [`WORD_LEN-1:0] sw_val_ext;
  assign sw_val_ext = {{(`WORD_LEN - 15) {SW[14]}}, SW[14:0]};





  // ALU

  logic ALU_flag;
  logic [`WORD_LEN-1:0] ALU_res;
  alu #(`WORD_LEN, `ALU_OP_LEN) my_alu (
      .A(reg_read_data1),
      .B(reg_read_data2),
      .ALUOp(instruction[`C_COBRA_INSTR_ALUop]),

      .Flag  (ALU_flag),
      .Result(ALU_res)
  );




  assign LED[5:0]  = PC;
  assign LED[15:6] = reg_read_data1[9:0];


  disp_HEX my_disp_HEX (
      .CLK(CLK100MHZ),
      .num(reg_read_data1),
      .rst(rst),

      .HEX(C),
      .DIG(AN)
  );

endmodule
