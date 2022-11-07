`timescale 1ns / 1ps

`define BYTE_WIDTH 8

module data_mem #(
    parameter WORD_LEN = 32,
    parameter MEM_SIZE_OPT_BIT_NUM = 3,
    parameter DEPTH = 256
) (
    input clk,
    input [WORD_LEN-1:0] adr,  // read/write address
    input [WORD_LEN-1:0] wd,  // Write Data
    input we,  // Write Enable
    input [MEM_SIZE_OPT_BIT_NUM-1:0] size,  // Size of mem to operate

    output logic [WORD_LEN-1:0] rd  // Read Data

);

  logic [`WORD_LEN-1:0] RAM[0:DEPTH-1];

  parameter SHIFT_LEN = $clog2(WORD_LEN / `BYTE_WIDTH);
  logic [`WORD_LEN-1:0] shifted_adr;
  assign shifted_adr = adr >> SHIFT_LEN;

  parameter HALF_WORD_BYTE_LEN = (WORD_LEN / 2) / `BYTE_WIDTH;
  logic [HALF_WORD_BYTE_LEN-1:0][`BYTE_WIDTH-1:0] half_word_o;
  generate
    genvar iter_h_o;
    for (iter_h_o = 0; iter_h_o < HALF_WORD_BYTE_LEN; iter_h_o++) begin
      assign half_word_o[iter_h_o] = RAM[adr+iter_h_o];
    end
  endgenerate


  parameter WORD_BYTE_LEN = WORD_LEN / `BYTE_WIDTH;
  logic [WORD_BYTE_LEN-1:0][`BYTE_WIDTH-1:0] word_o;
  generate
    genvar iter_w_o;
    for (iter_w_o = 0; iter_w_o < WORD_BYTE_LEN; iter_w_o++) begin
      assign word_o[iter_w_o] = RAM[adr+iter_w_o];
    end
  endgenerate

  // Output sign extended different mem sizes
  parameter CORRECTED_ADR_LEN = $clog2(DEPTH);
  int START_BIT_NUM = adr % SHIFT_LEN;
  always_comb begin

    case (size)
      `LDST_B: begin
        logic [`WORD_LEN-1:0] choosed_word;
        logic [`WORD_LEN-1:0] choosed_byte;

        choosed_word = RAM[shifted_adr[CORRECTED_ADR_LEN-1:0]];
        choosed_byte = choosed_word[START_BIT_NUM+:`BYTE_WIDTH];

        rd = {{(WORD_LEN - `BYTE_WIDTH) {choosed_byte[`BYTE_WIDTH-1]}}, choosed_byte};
      end

      `LDST_H: begin
        logic [`WORD_LEN-1:0] choosed_word;
        logic [`WORD_LEN-1:0] choosed_half;

        choosed_word = RAM[shifted_adr[CORRECTED_ADR_LEN-1:0]];

        choosed_half = choosed_word[START_BIT_NUM+:WORD_LEN/2];

        rd = {{(WORD_LEN / 2) {choosed_half[WORD_LEN/2-1]}}, choosed_half};
      end

      `LDST_W: begin
        rd = RAM[shifted_adr[CORRECTED_ADR_LEN-1:0]];
      end

      `LDST_BU: begin
        logic [`WORD_LEN-1:0] choosed_word;
        logic [`WORD_LEN-1:0] choosed_byte;

        choosed_word = RAM[shifted_adr[CORRECTED_ADR_LEN-1:0]];
        choosed_byte = choosed_word[START_BIT_NUM+:`BYTE_WIDTH];

        rd = {{(WORD_LEN - `BYTE_WIDTH) {1'b0}}, choosed_byte};
      end

      `LDST_HU: begin
        logic [`WORD_LEN-1:0] choosed_word;
        logic [`WORD_LEN-1:0] choosed_half;

        choosed_word = RAM[shifted_adr[CORRECTED_ADR_LEN-1:0]];

        choosed_half = choosed_word[START_BIT_NUM+:WORD_LEN/2];

        rd = {{(WORD_LEN / 2) {1'b0}}, choosed_half};
      end
      default: begin
        rd = {WORD_LEN{1'b0}};
      end
    endcase
  end

  logic [HALF_WORD_BYTE_LEN-1:0][`BYTE_WIDTH-1:0] half_word_i;
  generate
    genvar iter_h_i;
    for (iter_h_i = 0; iter_h_i < HALF_WORD_BYTE_LEN; iter_h_i++) begin
      assign half_word_i[iter_h_i] = wd[`BYTE_WIDTH*(iter_h_i+1)-1:`BYTE_WIDTH*iter_h_i];
    end
  endgenerate


  logic [WORD_BYTE_LEN-1:0][`BYTE_WIDTH-1:0] word_i;
  generate
    genvar iter_w_i;
    for (iter_w_i = 0; iter_w_i < WORD_BYTE_LEN; iter_w_i++) begin
      assign word_i[iter_w_i] = wd[`BYTE_WIDTH*(iter_w_i+1)-1:`BYTE_WIDTH*iter_w_i];
    end
  endgenerate

  always_ff @(posedge clk) begin
    if (we) begin
      case (size)
        `LDST_B: begin
          RAM[adr] <= wd[`BYTE_WIDTH-1:0];
        end

        `LDST_H: begin
          for (int i = 0; i < HALF_WORD_BYTE_LEN; i++) begin
            RAM[adr+i] = half_word_i[i];
          end
        end

        `LDST_W: begin
          for (int i = 0; i < WORD_BYTE_LEN; i++) begin
            RAM[adr+i] = word_i[i];
          end
        end

        `LDST_BU: begin
          RAM[adr] = wd[`BYTE_WIDTH-1:0];
        end

        `LDST_HU: begin
          for (int i = 0; i < HALF_WORD_BYTE_LEN; i++) begin
            RAM[adr+i] = half_word_i[i];
          end
        end
        default: begin
        end
      endcase
      //$display("\nDATA_MEM In write case: adr = %b; wd = %b; RAM[adr] = %b\n", adr, wd, RAM[adr]);
    end
  end

endmodule
