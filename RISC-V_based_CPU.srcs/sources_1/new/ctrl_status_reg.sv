`timescale 1ns / 1ps

`define ADR_LEN 12

`define REGS_NUM 5

`define MIE_ADR 32'h304
`define MTVEC_ADR 32'h305
`define MSCRATCH_ADR 32'h340
`define MEPC_ADR 32'h341
`define MCAUSE_ADR 32'h342

`define OP_WRITE_REG_SRC 1:0
`define OP_INT_HANDLE_POS 2

module ctrl_status_reg (
    input clk_i,
    input [`CSR_OP_LEN-1:0] op_i,
    input [`WORD_LEN-1:0] mcause_i,  // Machine trap cause

    input [`WORD_LEN-1:0] PC,

    input [ `ADR_LEN-1:0] adr,
    input [`WORD_LEN-1:0] wd,   // Write Data

    output [`WORD_LEN-1:0] mie_o,    // Machine interrup-enable register
    output [`WORD_LEN-1:0] mtvec_o,  // Machine trap-handler BASE REGISTER
    output [`WORD_LEN-1:0] mepc_o,   // Machine exception program counter

    output logic [`WORD_LEN-1:0] rd
);

  logic [`WORD_LEN-1:0] mie, mtvec, mepc, mcause;
  logic [`WORD_LEN-1:0] mscratch;  // Scratch register for machine trap handlers
  assign mie_o   = mie;
  assign mtvec_o = mtvec;
  assign mepc_o  = mepc;

  // MUX
  always_comb begin
    case (adr)
      `MIE_ADR: begin
        rd <= mie;
      end
      `MTVEC_ADR: begin
        rd <= mtvec;
      end
      `MSCRATCH_ADR: begin
        rd <= mscratch;
      end
      `MEPC_ADR: begin
        rd <= mepc;
      end
      `MCAUSE_ADR: begin
        rd <= mcause;
      end
      default: begin

      end
    endcase
  end


  logic int_occur;
  assign int_occur = op_i[`OP_INT_HANDLE_POS];

  // DE-MUX
  logic [`WORD_LEN-1:0] reg_write_data;
  always_ff @(posedge clk_i, posedge int_occur) begin
    if (int_occur) begin
      mepc   <= PC;
      mcause <= mcause_i;
    end else begin
      if (op_i[1] | op_i[0]) begin
        case (adr)
          `MIE_ADR: begin
            mie <= reg_write_data;
          end
          `MTVEC_ADR: begin
            mtvec <= reg_write_data;
          end
          `MSCRATCH_ADR: begin
            mscratch <= reg_write_data;
          end
          `MEPC_ADR: begin
            mepc <= reg_write_data;
          end
          `MCAUSE_ADR: begin
            mcause <= reg_write_data;
          end
          default: begin
            mie <= mie;
            mtvec <= mtvec;
            mscratch <= mscratch;
            mepc <= mepc;
            mcause <= mcause;
          end
        endcase
      end
    end
  end

  // MUX 4-1
  always_comb begin
    case (op_i[`OP_WRITE_REG_SRC])
      `CSR_OP_WRITE_REG_ZERO: begin
        reg_write_data <= {`WORD_LEN{1'b0}};
      end
      `CSR_OP_WRITE_REG_WD: begin
        reg_write_data <= wd;
      end
      `CSR_OP_WRITE_REG_NOT_WD_AND_RD: begin
        reg_write_data <= ~wd & rd;
      end
      `CSR_OP_WRITE_REG_WD_OR_RD: begin
        reg_write_data <= wd | rd;
      end
      default: begin
      end
    endcase
  end

endmodule
