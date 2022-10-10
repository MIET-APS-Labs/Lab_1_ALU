`timescale 1ns / 1ps

`include "myCPU_params.v"
`include "decoder_defines.v"

module riscv_decode (
    input [`WORD_LEN-1:0] fetched_instr_i,

    output logic [1:0] ex_op_a_sel_o,
    output [2:0] ex_op_b_sel_o,
    output [`ALU_OP_LEN-1:0] alu_op_o,
    output mem_req_o,
    output mem_we_o,
    output [2:0] mem_size_o,
    output gpr_we_a_o,
    output wb_src_sel_o,
    output logic illegal_instr_o,
    output branch_o,
    output jal_o,
    output jalr_o
);

  always_comb begin
    if (fetched_instr_i[`INSTR_INSTR_LEN] == `INSTR_LEN) begin
      illegal_instr_o <= 0;
      case (fetched_instr_i[`INSTR_OPCODE])
        `LOAD_OPCODE: begin

        end
        `MISC_MEM_OPCODE: begin

        end
        `OP_IMM_OPCODE: begin

        end
        `AUIPC_OPCODE: begin

        end
        `STORE_OPCODE: begin

        end
        `OP_OPCODE: begin

        end
        `LUI_OPCODE: begin

        end
        `BRANCH_OPCODE: begin

        end
        `JALR_OPCODE: begin

        end
        `JAL_OPCODE: begin

        end
        `SYSTEM_OPCODE: begin

        end
        default: begin

        end
      endcase

    end else begin
      illegal_instr_o <= 1;
    end


  end


endmodule
