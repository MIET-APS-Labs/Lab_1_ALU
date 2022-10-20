`timescale 1ns / 1ps

`include "myCPU_params.v"
`include "decoder_defines.v"

module decoder_riscv (
    input [`WORD_LEN-1:0] fetched_instr_i,  // Instruction for decoding, read from instr_rom

    output logic [1:0] ex_op_a_sel_o,  // MUX control signal for selecting first operand for ALU
    output [2:0] ex_op_b_sel_o,  // MUX control signal for selecting second operand for ALU
    output [`ALU_OP_LEN-1:0] alu_op_o,  // ALU operation

    output mem_req_o,  // Data memory request (part of load-store unit)
    output mem_we_o,  // Data memory write enable (active 1)
    output [2:0] mem_size_o,  // Selecting data memory read/write size (part of load-store unit)

    output gpr_we_a_o,   // Reg file write enable
    output wb_src_sel_o, //  MUX control signal for selecting data to write into reg file

    output logic illegal_instr_o,  // Illegal instruction signal
    output branch_o,  // Conditional branch instruction signal
    output jal_o,  // Unconditional branch instruction signal jal
    output jalr_o  // Unconditional branch instruction signal jalr
);

  always_comb begin
    if (fetched_instr_i[`INSTR_INSTR_LEN] == `INSTR_LEN) begin

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
          // Write in reg file in rd result of ALU calculation over rs 1 and rs2

          wb_src_sel_o <= 0;
          ex_op_a_sel_o <= 0;
          ex_op_b_sel_o <= 0;
          gpr_we_a_o <= 1;

          case (fetched_instr_i[`R_TYPE_FUNCT_3])
            `OP_FUNCT_3_ADD_SUB: begin
              case (fetched_instr_i[`R_TYPE_FUNCT_7])
                `OP_FUNCT_7_ADD: begin
                  alu_op_o <= `ADD;
                end
                `OP_FUNCT_7_SUB: begin
                  alu_op_o <= `SUB;
                end
                default: begin
                  illegal_instr_o <= 1;
                end
              endcase

            end
            `OP_FUNCT_3_XOR: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_XOR) begin
                alu_op_o <= `XOR;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            `OP_FUNCT_3_OR: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_OR) begin
                alu_op_o <= `OR;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            `OP_FUNCT_3_AND: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_AND) begin
                alu_op_o <= `AND;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            `OP_FUNCT_3_SLL: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_SLL) begin
                alu_op_o <= `SLL;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            `OP_FUNCT_3_SRL_SRA: begin
              case (fetched_instr_i[`R_TYPE_FUNCT_7])
                `OP_FUNCT_7_SRL: begin
                  alu_op_o <= `SRL;
                end
                `OP_FUNCT_7_SRA: begin
                  alu_op_o <= `SRA;
                end
                default: begin
                  illegal_instr_o <= 1;
                end
              endcase

            end
            `OP_FUNCT_3_SLT: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_SLT) begin
                alu_op_o <= `SLT;
              end else begin
                illegal_instr_o <= 1;
              end

            end
            `OP_FUNCT_3_SLTU: begin
              if (fetched_instr_i[`R_TYPE_FUNCT_7] === OP_FUNCT_7_SLTU) begin
                alu_op_o <= `SLTU;
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
            // Write in reg file in rd result of ALU calculation over rs 1 and imm

        end

        `LUI_OPCODE: begin

        end

        `LOAD_OPCODE: begin
          // case (fetched_instr_i[`I_TYPE_FUNCT_3])
          //   `LOAD_FUNCT_3_LB: begin

          //   end
          //   default: 
          // endcase
        end

        `STORE_OPCODE: begin

        end

        `BRANCH_OPCODE: begin

        end

        `JAL_OPCODE: begin

        end

        `JALR_OPCODE: begin

        end

        `AUIPC_OPCODE: begin

        end

        `MISC_MEM_OPCODE: begin

        end

        `SYSTEM_OPCODE: begin

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
