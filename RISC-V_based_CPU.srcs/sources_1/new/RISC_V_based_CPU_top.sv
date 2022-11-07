`timescale 1ns / 1ps

`include "defines_riscv.v"

module RISC_V_based_CPU_top (
    input CLK100MHZ,
    input [15:0] SW,

    output [15:0] LED,

    output [6:0] C,
    output [7:0] AN,

    output logic PROG_FINISHED
);
  logic rst;
  assign rst = ~SW[15];


  // Main decoder

  logic [1:0] ex_op_a_sel_o;
  logic [2:0] ex_op_b_sel_o;
  logic [`ALU_OP_WIDTH-1:0] alu_op_o;

  logic mem_req_o;
  logic mem_we_o;
  logic [2:0] mem_size_o;

  logic gpr_we_a_o;
  logic wb_src_sel_o;

  logic illegal_instr_o;
  logic branch_o;
  logic jal_o;
  logic jalr_o;

  decoder_riscv main_decoder (
      .fetched_instr_i(instruction),

      .ex_op_a_sel_o(ex_op_a_sel_o),
      .ex_op_b_sel_o(ex_op_b_sel_o),
      .alu_op_o(alu_op_o),

      .mem_req_o (mem_req_o),
      .mem_we_o  (mem_we_o),
      .mem_size_o(mem_size_o),

      .gpr_we_a_o  (gpr_we_a_o),
      .wb_src_sel_o(wb_src_sel_o),

      .illegal_instr_o(illegal_instr_o),
      .branch_o(branch_o),
      .jal_o(jal_o),
      .jalr_o(jalr_o)
  );



  // Instruction read-only memory

  logic [`WORD_LEN-1:0] instruction;
  instr_rom #(`WORD_LEN, `INSTR_DEPTH, "prog.txt") my_instr_rom (
      .adr(PC),
      .rd (instruction)
  );


  // Registers file

  logic [`WORD_LEN-1:0] reg_read_data1;
  logic [`WORD_LEN-1:0] reg_read_data2;

  logic [`WORD_LEN-1:0] reg_write_data;

  assign reg_write_data = wb_src_sel_o ? data_read : ALU_res;

  reg_file #(`WORD_LEN,
  `RF_DEPTH
  ) my_reg_file (
      .clk (CLK100MHZ),
      .adr1(instruction[`INSTR_RS_1]),
      .adr2(instruction[`INSTR_RS_2]),
      .adr3(instruction[`INSTR_A3]),
      .wd3 (reg_write_data),
      .we3 (gpr_we_a_o),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );


  // Data memory

  logic [`WORD_LEN-1:0] data_read;

  data_mem #(`WORD_LEN, `MEM_TYPE_LOAD_STORE_BIT,
  `MEM_DEPTH
  ) my_data_mem (
      .clk(CLK100MHZ),
      .adr(ALU_res[$clog2(`MEM_DEPTH)+1:2]),  // read/write address
      .wd(reg_read_data2),  // Write Data
      .we(mem_we_o),  // Write Enable
      .size(mem_req_o & mem_size_o),  // Write Enable

      .rd(data_read)  // Read Data
  );


  // imm_I sign extender

  logic [`WORD_LEN-1:0] imm_I;
  assign imm_I = {
    {(`WORD_LEN - `I_TYPE_IMM_LEN) {instruction[`I_TYPE_IMM+(`I_TYPE_IMM_LEN-1)]}},
    instruction[`I_TYPE_IMM]
  };


  // imm_S sign extender

  logic [`WORD_LEN-1:0] imm_S;
  assign imm_S = {
    {(`WORD_LEN - `S_TYPE_IMM_11_5_LEN - `S_TYPE_IMM_4_0_LEN) {instruction[`S_TYPE_IMM_11_5+(`S_TYPE_IMM_11_5_LEN-1)]}},
    instruction[`S_TYPE_IMM_11_5],
    instruction[`S_TYPE_IMM_4_0]
  };


  // imm_J sign extender

  logic [`WORD_LEN-1:0] imm_J;
  assign imm_J = {
    {(`WORD_LEN - `J_TYPE_IMM_LEN) {instruction[`J_TYPE_IMM_20]}},
    instruction[`J_TYPE_IMM_20],
    instruction[`J_TYPE_IMM_19_12],
    instruction[`J_TYPE_IMM_11],
    instruction[`J_TYPE_IMM_10_1],
    1'b0
  };


  // imm_U sign extender

  logic [`WORD_LEN-1:0] imm_U;
  assign imm_U = {instruction[`U_TYPE_IMM_31_12], {(`WORD_LEN - `U_TYPE_IMM_31_12_LEN) {0}}};


  // imm_B sign extender

  logic [`WORD_LEN-1:0] imm_B;
  assign imm_B = {
    {(`WORD_LEN - `B_TYPE_IMM_LEN) {instruction[`B_TYPE_IMM_12]}},
    instruction[`B_TYPE_IMM_12],
    instruction[`B_TYPE_IMM_11],
    instruction[`B_TYPE_IMM_10_5],
    instruction[`B_TYPE_IMM_4_1],
    1'b0
  };





  // // Switches value sign extender

  // logic [`WORD_LEN-1:0] sw_val_ext;
  // assign sw_val_ext = {{(`WORD_LEN - 15) {SW[14]}}, SW[14:0]};




  //  Program Counter

  logic   [`WORD_LEN-1:0] PC;
  logic [`WORD_LEN-1:0] PC_increaser;
  logic [`WORD_LEN-1:0] PC_increaser_select_imm;
  assign PC_increaser_select_imm = branch_o ? imm_B : imm_J;
  assign PC_increaser = ((branch_o && comp) || jal_o) ? PC_increaser_select_imm : `PC_NEXT_INSTR_INCREASE;
  always_ff @(posedge CLK100MHZ) begin
    if (rst || illegal_instr_o) begin
      PROG_FINISHED <= 1;
      PC <= 0;
    end else begin
      PROG_FINISHED <= 0;
      if (jalr_o) begin
        PC <= reg_read_data1 + imm_I;
      end else begin
        PC <= PC + PC_increaser;
      end
    end
  end





  // ALU

  logic comp;
  logic [`WORD_LEN-1:0] ALU_res;
  logic [`WORD_LEN-1:0] ALU_A_operand;
  logic [`WORD_LEN-1:0] ALU_B_operand;

  always_comb begin
    ALU_A_operand <= 0;
    case (ex_op_a_sel_o)
      `OP_A_RS1: begin
        ALU_A_operand <= reg_read_data1;
      end
      `OP_A_CURR_PC: begin
        ALU_A_operand <= PC;
      end
      `OP_A_ZERO: begin
        ALU_A_operand <= 0;
      end
      default: begin
        ALU_A_operand <= 0;
      end
    endcase
  end

  always_comb begin
    ALU_B_operand <= 0;
    case (ex_op_b_sel_o)
      `OP_B_RS2: begin
        ALU_B_operand <= reg_read_data2;
      end
      `OP_B_IMM_I: begin
        ALU_B_operand <= imm_I;
      end
      `OP_B_IMM_U: begin
        ALU_B_operand <= imm_U;
      end
      `OP_B_IMM_S: begin
        ALU_B_operand <= imm_S;
      end
      `OP_B_INCR: begin
        ALU_B_operand <= `PC_NEXT_INSTR_INCREASE;
      end
      default: begin
        ALU_B_operand <= 0;
      end
    endcase
  end

  alu #(`WORD_LEN, `ALU_OP_WIDTH) my_alu (
      .A(ALU_A_operand),
      .B(ALU_B_operand),
      .ALUOp(alu_op_o),

      .Flag  (comp),
      .Result(ALU_res)
  );




  //assign LED[5:0]  = PC;
  //assign LED[15:6] = reg_read_data1[9:0];


  disp_HEX my_disp_HEX (
      .CLK(CLK100MHZ),
      .num(reg_read_data1),
      .rst(rst),

      .HEX(C),
      .DIG(AN)
  );
endmodule
