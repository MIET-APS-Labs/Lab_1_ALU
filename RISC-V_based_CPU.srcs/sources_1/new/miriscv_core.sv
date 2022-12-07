`timescale 1ns / 1ps

`include "defines_riscv.v"

module miriscv_core (
    input clk_i,
    input arstn_i,

    output prog_finished,

    // Instructions ports
    input logic [`WORD_LEN-1:0] instr_rdata,
    output [`WORD_LEN-1:0] instr_addr_o,

    // Data memory ports
    input  logic [`WORD_LEN-1:0] data_rdata_i,  // requested data address 
    output                       data_req_o,    // 1 - request to memory
    output                       data_we_o,     // 1 - request for write
    output       [          3:0] data_be_o,     // choose bytes from word to request
    output       [         31:0] data_addr_o,   // address of request
    output       [         31:0] data_wdata_o,  // data to write

    input [`WORD_LEN-1:0] mcause_i,  // from Interrupt controller
    input INT,  // from Interrupt controller - reports about Interrupt occurs and must be handled
    output [`WORD_LEN-1:0] mie_o,  // to Interrupt controller
    output INT_RST  // to Interrupt controller -  reports that Interrupt handled
);

  assign prog_finished = (illegal_instr || !arstn_i);

  // Main decoder
  logic stall;
  logic [1:0] ex_op_a_sel;
  logic [2:0] ex_op_b_sel;
  logic [`ALU_OP_WIDTH-1:0] alu_op;

  logic mem_req;
  logic mem_we;
  logic [2:0] mem_size;

  logic gpr_we_a;
  logic wb_src_sel;

  logic illegal_instr;
  logic branch;
  logic jal;
  logic [`JALR_LEN-1:0] jalr;

  logic csr;
  logic [`CSR_OP_LEN-1:0] CSRop;

  decoder_riscv main_decoder (
      .fetched_instr_i(instr_rdata),
      .stall(stall),
      .en_pc_n(en_pc_n),
      .ex_op_a_sel_o(ex_op_a_sel),
      .ex_op_b_sel_o(ex_op_b_sel),
      .alu_op_o(alu_op),

      .mem_req_o (mem_req),
      .mem_we_o  (mem_we),
      .mem_size_o(mem_size),

      .gpr_we_a_o  (gpr_we_a),
      .wb_src_sel_o(wb_src_sel),

      .illegal_instr_o(illegal_instr),
      .branch_o(branch),
      .jal_o(jal),
      .jalr_o(jalr),

      .int_i(INT),
      .int_rst_o(INT_RST),


      .csr_o  (csr),
      .CSRop_o(CSRop)
  );


  // Control and Status Registers

  logic [`WORD_LEN-1:0] mtvec, mepc;
  logic [`WORD_LEN-1:0] csr_read_data;

  ctrl_status_reg my_csr (
      .clk_i(clk_i),
      .op_i(CSRop),
      .mcause_i(mcause_i),

      .PC(PC),

      .adr(instr_rdata[`I_TYPE_IMM]),
      .wd(reg_read_data1),  // Write Data

      .mie_o  (mie_o),
      .mtvec_o(mtvec),
      .mepc_o (mepc),

      .rd(csr_read_data)
  );

  // Registers file

  logic [`WORD_LEN-1:0] reg_read_data1, reg_read_data2;
  logic [`WORD_LEN-1:0] reg_write_data;

  assign reg_write_data = csr ? csr_read_data : (wb_src_sel ? data_read : ALU_res);

  reg_file #(`WORD_LEN,
  `RF_DEPTH
  ) my_reg_file (
      .clk(clk_i),
      .adr1(instr_rdata[`INSTR_RS_1]),
      .adr2(instr_rdata[`INSTR_RS_2]),
      .adr3(instr_rdata[`INSTR_A3]),
      .wd3(reg_write_data),
      .we3(gpr_we_a),
      .arst_n(arstn_i),

      .rd1(reg_read_data1),
      .rd2(reg_read_data2)
  );

  // instr_rdata address
  assign instr_addr_o = PC;


  // Data memory

  logic [`WORD_LEN-1:0] data_read;

  // Load-store unit

  miriscv_lsu load_store_unit (
      .clk_i(clk_i),

      // core protocol
      .lsu_addr_i(ALU_res),
      .lsu_we_i(mem_we),
      .lsu_size_i(mem_size),
      .lsu_data_i(reg_read_data2),
      .lsu_req_i(mem_req),
      .lsu_stall_req_o(stall),
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
    {(`WORD_LEN - `I_TYPE_IMM_LEN) {instr_rdata[`I_TYPE_IMM+(`I_TYPE_IMM_LEN-1)]}},
    instr_rdata[`I_TYPE_IMM]
  };


  // imm_S sign extender

  logic [`WORD_LEN-1:0] imm_S;
  assign imm_S = {
    {(`WORD_LEN - `S_TYPE_IMM_11_5_LEN - `S_TYPE_IMM_4_0_LEN) {instr_rdata[`S_TYPE_IMM_11_5+(`S_TYPE_IMM_11_5_LEN-1)]}},
    instr_rdata[`S_TYPE_IMM_11_5],
    instr_rdata[`S_TYPE_IMM_4_0]
  };


  // imm_J sign extender

  logic [`WORD_LEN-1:0] imm_J;
  assign imm_J = {
    {(`WORD_LEN - `J_TYPE_IMM_LEN) {instr_rdata[`J_TYPE_IMM_20]}},
    instr_rdata[`J_TYPE_IMM_20],
    instr_rdata[`J_TYPE_IMM_19_12],
    instr_rdata[`J_TYPE_IMM_11],
    instr_rdata[`J_TYPE_IMM_10_1],
    1'b0
  };


  // imm_U sign extender

  logic [`WORD_LEN-1:0] imm_U;
  assign imm_U = {instr_rdata[`U_TYPE_IMM_31_12], {(`WORD_LEN - `U_TYPE_IMM_31_12_LEN) {1'b0}}};


  // imm_B sign extender

  logic [`WORD_LEN-1:0] imm_B;
  assign imm_B = {
    {(`WORD_LEN - `B_TYPE_IMM_LEN) {instr_rdata[`B_TYPE_IMM_12]}},
    instr_rdata[`B_TYPE_IMM_12],
    instr_rdata[`B_TYPE_IMM_11],
    instr_rdata[`B_TYPE_IMM_10_5],
    instr_rdata[`B_TYPE_IMM_4_1],
    1'b0
  };

  //  Program Counter

  logic en_pc_n;
  logic [`WORD_LEN-1:0] PC;
  logic [`WORD_LEN-1:0] PC_increaser;
  logic [`WORD_LEN-1:0] PC_increaser_select_imm;
  assign PC_increaser_select_imm = branch ? imm_B : imm_J;
  assign PC_increaser = ((branch && comp) || jal) ? PC_increaser_select_imm : `PC_NEXT_INSTR_INCREASE;
  always_ff @(posedge clk_i, negedge arstn_i) begin
    if (!arstn_i || illegal_instr) begin
      PC <= 1'b0;
    end else if (!en_pc_n) begin
      case (jalr)
        `JALR_MUX_PC_INC: begin
          PC <= PC + PC_increaser;
        end
        `JALR_MUX_PC_RD1_IMM: begin
          PC <= reg_read_data1 + imm_I;
        end
        `JALR_MUX_PC_MEPC: begin
          PC <= mepc;
        end
        `JALR_MUX_PC_MTVEC: begin
          PC <= mtvec;
        end
        default: begin
        end
      endcase
    end
  end





  // ALU

  logic comp;
  logic [`WORD_LEN-1:0] ALU_res, ALU_A_operand, ALU_B_operand;

  always_comb begin
    ALU_A_operand <= 0;
    case (ex_op_a_sel)
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
    case (ex_op_b_sel)
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
      .ALUOp(alu_op),

      .Flag  (comp),
      .Result(ALU_res)
  );

endmodule
