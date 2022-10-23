`timescale 1ns / 1ps

// dmem type load store
`define LDST_B 3'b000
`define LDST_H 3'b001
`define LDST_W 3'b010
`define LDST_BU 3'b100
`define LDST_HU 3'b101

`define BYTE_LEN 8

module data_mem #(
    parameter WORD_LEN = 32,
    parameter MEM_SIZE_OPT_BIT = 3,
    parameter WIDTH = 256
) (
    input clk,
    input [WORD_LEN-1:0] adr,  // read/write address
    input [WORD_LEN-1:0] wd,  // Write Data
    input we,  // Write Enable
    input [MEM_SIZE_OPT_BIT-1:0] size,  // Write Enable

    output logic [WORD_LEN-1:0] rd  // Read Data

);
  logic [WORD_LEN-1:0] RAM[0:WIDTH-1];

  always_comb begin
    case (size)
      `LDST_B: begin
        rd <= {{(`WORD_LEN - `BYTE_LEN) {0}}, RAM[adr[$clog2(WIDTH)+1:2]][`BYTE_LEN-1:0]};
      end

      `LDST_H: begin
        rd <= {{(`WORD_LEN / 2) {0}}, RAM[adr[$clog2(WIDTH)+1:2]][`WORD_LEN/2-1:0]};
      end

      `LDST_W: begin
        rd <= RAM[adr[$clog2(WIDTH)+1:2]];
      end

      `LDST_BU: begin
        rd <= {{(`WORD_LEN - `BYTE_LEN) {0}}, RAM[adr[$clog2(WIDTH)+1:2]][`BYTE_LEN-1:0]};
      end

      `LDST_HU: begin
        rd <= {{(`WORD_LEN / 2) {0}}, RAM[adr[$clog2(WIDTH)+1:2]][`WORD_LEN/2-1:0]};
      end
      default: begin
        rd <= `WORD_LEN'b0;
      end
    endcase
  end


  always_ff @(posedge clk) begin
    if (we) begin
      case (size)
        `LDST_B: begin
          RAM[adr[$clog2(WIDTH)+1:2]][`BYTE_LEN-1:0] <= wd[`BYTE_LEN-1:0];
        end

        `LDST_H: begin
          RAM[adr[$clog2(WIDTH)+1:2]][`WORD_LEN/2-1:0] <= wd[`WORD_LEN/2-1:0];
        end

        `LDST_W: begin
          RAM[adr[$clog2(WIDTH)+1:2]] <= wd;
        end

        `LDST_BU: begin
          RAM[adr[$clog2(WIDTH)+1:2]][`BYTE_LEN-1:0] <= wd[`BYTE_LEN-1:0];
        end

        `LDST_HU: begin
          RAM[adr[$clog2(WIDTH)+1:2]][`WORD_LEN/2-1:0] <= wd[`WORD_LEN/2-1:0];
        end
        default: begin
        end
      endcase
      //$display("\nDATA_MEM In write case: adr = %b; wd = %b; RAM[adr3] = %b\n", adr[$clog2(WIDTH)+1:2], wd, adr[$clog2(WIDTH)+1:2]);
    end
  end
endmodule
