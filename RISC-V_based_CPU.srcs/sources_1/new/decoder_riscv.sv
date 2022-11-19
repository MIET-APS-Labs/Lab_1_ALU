`timescale 1ns / 1ps

// R-type instruction format
// funct7[31:25] rs2[24:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
typedef struct packed {
  logic [31:25] funct7;
  logic [24:20] rs2;
  logic [19:15] rs1;
  logic [14:12] funct3;
  logic [11:7]  rd;
  logic [6:0]   opcode;
} R_type_instr_t;


// I-type instruction format
// imm[31:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
// I*-type funct7[31:25] shamt[24:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
typedef struct packed {
  logic [31:20] imm;
  logic [19:15] rs1;
  logic [14:12] funct3;
  logic [11:7]  rd;
  logic [6:0]   opcode;
} I_type_instr_t;

typedef struct packed {
  logic [31:25] funct7;
  logic [24:20] shamt;
  logic [19:15] rs1;
  logic [14:12] funct3;
  logic [11:7]  rd;
  logic [6:0]   opcode;
} I_type_alt_instr_t;


// S-type instruction format
// imm[11:5]_[31:25] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:0]_[11:7] opcode[6:0]
typedef struct packed {
  logic [31:25] imm_11_5;
  logic [24:20] rs2;
  logic [19:15] rs1;
  logic [14:12] funct3;
  logic [11:7]  imm_4_0;
  logic [6:0]   opcode;
} S_type_instr_t;


// B-type instruction format
// imm[12|10:5]_[31:25] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:1|11]_[11:7] opcode[6:0]
typedef struct packed {
  logic [31:25] imm_12_10_5;
  logic [24:20] rs2;
  logic [19:15] rs1;
  logic [14:12] funct3;
  logic [11:7]  imm_4_1_11;
  logic [6:0]   opcode;
} B_type_instr_t;


module decoder_riscv (
    input [`WORD_LEN-1:0] fetched_instr_i,  // Instruction for decoding, read from instr_rom

    input stall,

    output en_pc_n,

    output logic [1:0] ex_op_a_sel_o,  // MUX control signal for selecting first operand for ALU
    output logic [2:0] ex_op_b_sel_o,  // MUX control signal for selecting second operand for ALU
    output logic [`ALU_OP_WIDTH-1:0] alu_op_o,  // ALU operation

    output logic mem_req_o,  // Data memory request (part of load-store unit)
    output logic mem_we_o,  // Data memory write enable (active 1)
    output logic [2:0] mem_size_o,  // Selecting data memory read/write size (part of load-store unit)

    output logic gpr_we_a_o,   // Reg file write enable
    output logic wb_src_sel_o, //  MUX control signal for selecting data to write into reg file

    output logic illegal_instr_o,  // Illegal instruction signal
    output logic branch_o,  // Conditional branch instruction signal
    output logic jal_o,  // Unconditional branch instruction signal jal
    output logic jalr_o  // Unconditional branch instruction signal jalr
);

  assign en_pc_n = stall;

  always_comb begin
    if ((fetched_instr_i[`INSTR_INSTR_LEN] == `INSTR_LEN_CODE) && (fetched_instr_i != `NOP_INSTR)) begin

      ex_op_a_sel_o <= 0;
      ex_op_b_sel_o <= 0;
      alu_op_o <= 0;

      mem_req_o <= 0;
      mem_we_o <= 0;
      mem_size_o <= 0;

      gpr_we_a_o <= 0;
      wb_src_sel_o <= 0;

      illegal_instr_o <= 0;
      branch_o <= 0;
      jal_o <= 0;
      jalr_o <= 0;

      case (fetched_instr_i[`INSTR_OPCODE])
        `OP_OPCODE: begin
          // Write in reg file at rd result of ALU calculation over rs 1 and rs2
          R_type_instr_t r_fetch_instr;
          r_fetch_instr = fetched_instr_i;

          wb_src_sel_o <= `WB_EX_RESULT;
          ex_op_a_sel_o <= `OP_A_RS1;
          ex_op_b_sel_o <= `OP_B_RS2;
          gpr_we_a_o <= 1;

          case (r_fetch_instr.funct3)
            `OP_FUNCT_3_ADD_SUB: begin
              case (r_fetch_instr.funct7)
                `OP_FUNCT_7_ADD: begin
                  alu_op_o <= `ALU_ADD;
                end
                `OP_FUNCT_7_SUB: begin
                  alu_op_o <= `ALU_SUB;
                end
                default: begin
                  illegal_instr_o <= 1;
                end
              endcase

            end

            `OP_FUNCT_3_XOR: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_XOR) begin
                alu_op_o <= `ALU_XOR;
              end else begin
                illegal_instr_o <= 1;
              end

            end

            `OP_FUNCT_3_OR: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_OR) begin
                alu_op_o <= `ALU_OR;
              end else begin
                illegal_instr_o <= 1;
              end

            end

            `OP_FUNCT_3_AND: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_AND) begin
                alu_op_o <= `ALU_AND;
              end else begin
                illegal_instr_o <= 1;
              end

            end

            `OP_FUNCT_3_SLL: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_SLL) begin
                alu_op_o <= `ALU_SLL;
              end else begin
                illegal_instr_o <= 1;
              end

            end

            `OP_FUNCT_3_SRL_SRA: begin
              case (r_fetch_instr.funct7)
                `OP_FUNCT_7_SRL: begin
                  alu_op_o <= `ALU_SRL;
                end
                `OP_FUNCT_7_SRA: begin
                  alu_op_o <= `ALU_SRA;
                end
                default: begin
                  illegal_instr_o <= 1;
                end
              endcase

            end

            `OP_FUNCT_3_SLT: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_SLT) begin
                alu_op_o <= `ALU_SLT;
              end else begin
                illegal_instr_o <= 1;
              end

            end

            `OP_FUNCT_3_SLTU: begin
              if (r_fetch_instr.funct7 === `OP_FUNCT_7_SLTU) begin
                alu_op_o <= `ALU_SLTU;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            default: begin
              illegal_instr_o <= 1;
            end
          endcase

        end
        `OP_IMM_OPCODE: begin
          // Write in reg file at rd result of ALU calculation over rs 1 and imm

          I_type_instr_t i_fetch_instr;
          i_fetch_instr = fetched_instr_i;

          wb_src_sel_o <= `WB_EX_RESULT;
          ex_op_a_sel_o <= `OP_A_RS1;
          ex_op_b_sel_o <= `OP_B_IMM_I;
          gpr_we_a_o <= 1;

          case (i_fetch_instr.funct3)
            `OP_IMM_FUNCT_3_ADDI: begin
              alu_op_o <= `ALU_ADD;
            end

            `OP_IMM_FUNCT_3_XORI: begin
              alu_op_o <= `ALU_XOR;
            end

            `OP_IMM_FUNCT_3_ORI: begin
              alu_op_o <= `ALU_OR;
            end

            `OP_IMM_FUNCT_3_ANDI: begin
              alu_op_o <= `ALU_AND;
            end

            `OP_IMM_FUNCT_3_SLLI: begin
              I_type_alt_instr_t i_alt_fetch_instr;
              i_alt_fetch_instr = fetched_instr_i;
              if (i_alt_fetch_instr.funct7 === `OP_IMM_FUNCT_7_SLLI) begin
                alu_op_o <= `ALU_SLL;
              end else begin
                illegal_instr_o <= 1;
              end
            end

            `OP_IMM_FUNCT_3_SRLI: begin
              I_type_alt_instr_t i_alt_fetch_instr;
              i_alt_fetch_instr = fetched_instr_i;
              if (i_alt_fetch_instr.funct7 === `OP_IMM_FUNCT_7_SRLI) begin
                alu_op_o <= `ALU_SRL;
              end else begin
                illegal_instr_o <= 1;
              end
            end

            `OP_IMM_FUNCT_3_SRAI: begin
              I_type_alt_instr_t i_alt_fetch_instr;
              i_alt_fetch_instr = fetched_instr_i;
              if (i_alt_fetch_instr.funct7 === `OP_IMM_FUNCT_7_SRAI) begin
                alu_op_o <= `ALU_SRA;
              end else begin
                illegal_instr_o <= 1;
              end
            end

            `OP_IMM_FUNCT_3_SLTI: begin
              alu_op_o <= `ALU_SLT;
            end

            `OP_IMM_FUNCT_3_SLTIU: begin
              alu_op_o <= `ALU_SLTU;
            end

            default: begin
              illegal_instr_o <= 1;
            end
          endcase
        end

        `LUI_OPCODE: begin
          // Write in reg file at rd value of immediate operand U-type (shifted left by 12 bits)

          wb_src_sel_o <= `WB_EX_RESULT;
          ex_op_a_sel_o <= `OP_A_ZERO;
          ex_op_b_sel_o <= `OP_B_IMM_U;
          gpr_we_a_o <= 1;
          alu_op_o <= `ALU_ADD;
        end

        `LOAD_OPCODE: begin
          // Write in reg file at rd data from data memory at rs1+imm
          I_type_instr_t i_fetch_instr;
          i_fetch_instr = fetched_instr_i;

          wb_src_sel_o <= `WB_LSU_DATA;
          ex_op_a_sel_o <= `OP_A_RS1;
          ex_op_b_sel_o <= `OP_B_IMM_I;
          gpr_we_a_o <= 1;
          mem_req_o <= 1;
          mem_we_o <= 0;

          case (i_fetch_instr.funct3)
            `LOAD_FUNCT_3_LB: begin
              mem_size_o <= `LDST_B;
            end

            `LOAD_FUNCT_3_LH: begin
              mem_size_o <= `LDST_H;
            end

            `LOAD_FUNCT_3_LW: begin
              mem_size_o <= `LDST_W;
            end

            `LOAD_FUNCT_3_LBU: begin
              mem_size_o <= `LDST_BU;
            end

            `LOAD_FUNCT_3_LHU: begin
              mem_size_o <= `LDST_HU;
            end

            default: begin
              illegal_instr_o <= 1;
            end
          endcase
        end

        `STORE_OPCODE: begin
          // Write in data memory at rs1+imm data from rs2 
          S_type_instr_t s_fetch_instr;
          s_fetch_instr = fetched_instr_i;

          ex_op_a_sel_o <= `OP_A_RS1;
          ex_op_b_sel_o <= `OP_B_IMM_S;
          mem_req_o <= 1;
          mem_we_o <= 1;

          case (s_fetch_instr.funct3)
            `STORE_FUNCT_3_SB: begin
              mem_size_o <= `LDST_B;
            end

            `STORE_FUNCT_3_SH: begin
              mem_size_o <= `LDST_H;
            end

            `STORE_FUNCT_3_SW: begin
              mem_size_o <= `LDST_W;
            end

            default: begin
              illegal_instr_o <= 1;
            end
          endcase
        end

        `BRANCH_OPCODE: begin
          // If compare result of rs1 and rs2 true, then increase PC by the imm value
          B_type_instr_t b_fetch_instr;
          b_fetch_instr = fetched_instr_i;

          ex_op_a_sel_o <= `OP_A_RS1;
          ex_op_b_sel_o <= `OP_B_RS2;
          branch_o <= 1;

          case (b_fetch_instr.funct3)
            `BRANCH_FUNCT_3_BEQ: begin
              alu_op_o <= `ALU_BEQ;
            end

            `BRANCH_FUNCT_3_BNE: begin
              alu_op_o <= `ALU_BNE;
            end

            `BRANCH_FUNCT_3_BLT: begin
              alu_op_o <= `ALU_BLT;
            end

            `BRANCH_FUNCT_3_BGE: begin
              alu_op_o <= `ALU_BGE;
            end

            `BRANCH_FUNCT_3_BLTU: begin
              alu_op_o <= `ALU_BLTU;
            end

            `BRANCH_FUNCT_3_BGEU: begin
              alu_op_o <= `ALU_BGEU;
            end

            default: begin
              illegal_instr_o <= 1;
            end
          endcase
        end

        `JAL_OPCODE: begin
          // Write in reg file at rd next PC adres, increase PC by the imm value

          wb_src_sel_o <= `WB_EX_RESULT;
          ex_op_a_sel_o <= `OP_A_CURR_PC;
          ex_op_b_sel_o <= `OP_B_INCR;
          gpr_we_a_o <= 1;

          alu_op_o <= `ALU_ADD;

          jal_o <= 1;
        end

        `JALR_OPCODE: begin
          // Write in reg file at rd next PC adres, increase PC by the imm value
          I_type_instr_t i_fetch_instr;
          i_fetch_instr = fetched_instr_i;

          if (i_fetch_instr.funct3 === `JALR_FUNCT_3_SLTU) begin
            wb_src_sel_o <= `WB_EX_RESULT;
            ex_op_a_sel_o <= `OP_A_CURR_PC;
            ex_op_b_sel_o <= `OP_B_INCR;
            gpr_we_a_o <= 1;

            alu_op_o <= `ALU_ADD;

            jalr_o <= 1;
          end else begin
            illegal_instr_o <= 1;
          end
        end

        `AUIPC_OPCODE: begin
          // Write in reg file at rd result of addition of immediate operand U-type and PC

          wb_src_sel_o <= `WB_EX_RESULT;
          ex_op_a_sel_o <= `OP_A_CURR_PC;
          ex_op_b_sel_o <= `OP_B_IMM_U;
          gpr_we_a_o <= 1;

          alu_op_o <= `ALU_ADD;
        end

        `MISC_MEM_OPCODE: begin
          illegal_instr_o <= 0;
        end

        `SYSTEM_OPCODE: begin
          illegal_instr_o <= 0;
        end
        default: begin
          illegal_instr_o <= 1;
        end
      endcase

    end else begin
      illegal_instr_o <= 1;
    end
  end
endmodule
