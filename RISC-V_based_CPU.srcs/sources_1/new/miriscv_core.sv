`timescale 1ns / 1ps

`include "defines_riscv.v"

module miriscv_core (
    input clk_i,
    input arstn_i,

    // Instructions ports
    input logic [`WORD_LEN-1:0] instr_rdata_i,
    output [`WORD_LEN-1:0] instr_addr_o,

    // Data memory ports
    input  logic [`WORD_LEN-1:0] data_rdata_i,  // requested data address 
    output                       data_req_o,    // 1 - request to memory
    output                       data_we_o,     // 1 - request for write
    output       [          3:0] data_be_o,     // choose bytes from word to request
    output       [         31:0] data_addr_o,   // address of request
    output       [         31:0] data_wdata_o   // data to write
);


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
      .fetched_instr_i(instr_rdata_i),
      .en_pc_n(en_pc_n),
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


  // Registers file

  logic [`WORD_LEN-1:0] reg_read_data1;
  logic [`WORD_LEN-1:0] reg_read_data2;

  logic [`WORD_LEN-1:0] reg_write_data;

  assign reg_write_data = wb_src_sel_o ? data_read : ALU_res;

  reg_file #(`WORD_LEN,
  `RF_DEPTH
  ) my_reg_file (
      .clk (CLK100MHZ),
      .adr1(instr_rdata_i[`INSTR_RS_1]),
      .adr2(instr_rdata_i[`INSTR_RS_2]),
      .adr3(instr_rdata_i[`INSTR_A3]),
      .wd3 (reg_write_data),
      .we3 (gpr_we_a_o),
      .rst (arstn_i),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );

  // instr_rdata_i address
  assign instr_addr_o = PC;


  // Data memory

  logic [`WORD_LEN-1:0] data_read;

  // Load-store unit

  miriscv_lsu load_store_unit (
      .clk_i(clk_i),

      // core protocol
      .lsu_addr_i(ALU_res),
      .lsu_we_i  (mem_we_o),
      .lsu_size_i(mem_size_o),
      .lsu_data_i(reg_read_data2),
      .lsu_req_i (mem_req_o),
      .lsu_data_o(data_read),

      // memory protocol
      .data_rdata_i(data_rdata_i),
      .data_req_o(data_req_o),
      .data_we_o(data_we_o),
      .data_be_o(data_be_o),
      .data_addr_o(data_addr_o),
      .data_wdata_o(data_wdata_o)
  );

  // imm_I sign extender

  logic [`WORD_LEN-1:0] imm_I;
  assign imm_I = {
    {(`WORD_LEN - `I_TYPE_IMM_LEN) {instr_rdata_i[`I_TYPE_IMM+(`I_TYPE_IMM_LEN-1)]}},
    instr_rdata_i[`I_TYPE_IMM]
  };


  // imm_S sign extender

  logic [`WORD_LEN-1:0] imm_S;
  assign imm_S = {
    {(`WORD_LEN - `S_TYPE_IMM_11_5_LEN - `S_TYPE_IMM_4_0_LEN) {instr_rdata_i[`S_TYPE_IMM_11_5+(`S_TYPE_IMM_11_5_LEN-1)]}},
    instr_rdata_i[`S_TYPE_IMM_11_5],
    instr_rdata_i[`S_TYPE_IMM_4_0]
  };


  // imm_J sign extender

  logic [`WORD_LEN-1:0] imm_J;
  assign imm_J = {
    {(`WORD_LEN - `J_TYPE_IMM_LEN) {instr_rdata_i[`J_TYPE_IMM_20]}},
    instr_rdata_i[`J_TYPE_IMM_20],
    instr_rdata_i[`J_TYPE_IMM_19_12],
    instr_rdata_i[`J_TYPE_IMM_11],
    instr_rdata_i[`J_TYPE_IMM_10_1],
    1'b0
  };


  // imm_U sign extender

  logic [`WORD_LEN-1:0] imm_U;
  assign imm_U = {instr_rdata_i[`U_TYPE_IMM_31_12], {(`WORD_LEN - `U_TYPE_IMM_31_12_LEN) {1'b0}}};


  // imm_B sign extender

  logic [`WORD_LEN-1:0] imm_B;
  assign imm_B = {
    {(`WORD_LEN - `B_TYPE_IMM_LEN) {instr_rdata_i[`B_TYPE_IMM_12]}},
    instr_rdata_i[`B_TYPE_IMM_12],
    instr_rdata_i[`B_TYPE_IMM_11],
    instr_rdata_i[`B_TYPE_IMM_10_5],
    instr_rdata_i[`B_TYPE_IMM_4_1],
    1'b0
  };

  //  Program Counter

  logic en_pc_n;
  logic [`WORD_LEN-1:0] PC;
  logic [`WORD_LEN-1:0] PC_increaser;
  logic [`WORD_LEN-1:0] PC_increaser_select_imm;
  assign PC_increaser_select_imm = branch_o ? imm_B : imm_J;
  assign PC_increaser = ((branch_o && comp) || jal_o) ? PC_increaser_select_imm : `PC_NEXT_INSTR_INCREASE;
  always_ff @(posedge CLK100MHZ) begin
    if (arstn_i || illegal_instr_o) begin
      //PROG_FINISHED <= 1;
      PC <= 0;
    end else if (!en_pc_n) begin
      //PROG_FINISHED <= 0;
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
