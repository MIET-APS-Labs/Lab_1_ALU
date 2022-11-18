`timescale 1ns / 1ps

`define BYTE_WIDTH 8

// Data mem bounds
`define DATA_MEM_START 32'h25000000
`define DATA_MEM_STOP 32'h25000400

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

  logic [WORD_LEN-1:0] RAM[0:DEPTH-1];

  logic [`WORD_LEN-1:0] biased_adr;
  assign biased_adr = adr - `DATA_MEM_START;

  parameter SHIFT_LEN = $clog2(WORD_LEN / `BYTE_WIDTH);
  logic [`WORD_LEN-1:0] shifted_biased_adr;
  assign shifted_biased_adr = biased_adr >> SHIFT_LEN;

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
  logic start_bit;
  assign start_bit = adr % SHIFT_LEN;
  always_comb begin
    if ((adr >= `DATA_MEM_START) && (adr < `DATA_MEM_STOP)) begin
      case (size)
        `LDST_B: begin
          logic [WORD_LEN-1:0] choosed_word;
          logic [`BYTE_WIDTH-1:0] choosed_byte;

          choosed_word = RAM[shifted_biased_adr[CORRECTED_ADR_LEN-1:0]];
          choosed_byte = choosed_word[start_bit+:`BYTE_WIDTH];

          rd = {{(WORD_LEN - `BYTE_WIDTH) {choosed_byte[`BYTE_WIDTH-1]}}, choosed_byte};
        end

        `LDST_H: begin
          logic [WORD_LEN-1:0] choosed_word;
          logic [(WORD_LEN/2)-1:0] choosed_half;

          choosed_word = RAM[shifted_biased_adr[CORRECTED_ADR_LEN-1:0]];

          choosed_half = choosed_word[start_bit+:WORD_LEN/2];

          rd = {{(WORD_LEN / 2) {choosed_half[WORD_LEN/2-1]}}, choosed_half};
        end

        `LDST_W: begin
          rd = RAM[shifted_biased_adr[CORRECTED_ADR_LEN-1:0]];
        end

        `LDST_BU: begin
          logic [WORD_LEN-1:0] choosed_word;
          logic [`BYTE_WIDTH-1:0] choosed_byte;

          choosed_word = RAM[shifted_biased_adr[CORRECTED_ADR_LEN-1:0]];
          choosed_byte = choosed_word[start_bit+:`BYTE_WIDTH];

          rd = {{(WORD_LEN - `BYTE_WIDTH) {1'b0}}, choosed_byte};
        end

        `LDST_HU: begin
          logic [WORD_LEN-1:0] choosed_word;
          logic [(WORD_LEN/2)-1:0] choosed_half;

          choosed_word = RAM[shifted_biased_adr[CORRECTED_ADR_LEN-1:0]];

          choosed_half = choosed_word[start_bit+:WORD_LEN/2];

          rd = {{(WORD_LEN / 2) {1'b0}}, choosed_half};
        end
        default: begin
          rd = {WORD_LEN{1'b0}};
        end
      endcase
    end else begin
      rd = {`WORD_LEN{0}};
    end

  end

  always_ff @(posedge clk) begin
    if (we) begin
      if ((adr >= `DATA_MEM_START) && (adr < `DATA_MEM_STOP)) begin
        case (size)
          `LDST_B: begin
            RAM[shifted_biased_adr] <= {
              {(`WORD_LEN - `BYTE_WIDTH) {wd[`BYTE_WIDTH-1]}}, wd[`BYTE_WIDTH-1:0]
            };
          end

          `LDST_H: begin
            RAM[shifted_biased_adr] <= {
              {(`WORD_LEN / 2) {wd[(`WORD_LEN/2)-1]}}, wd[(`WORD_LEN/2)-1:0]
            };

          end

          `LDST_W: begin
            RAM[shifted_biased_adr] <= wd;
          end

          `LDST_BU: begin
            RAM[shifted_biased_adr] <= {{(`WORD_LEN - `BYTE_WIDTH) {1'b0}}, wd[`BYTE_WIDTH-1:0]};
          end

          `LDST_HU: begin
            RAM[shifted_biased_adr] <= {{(`WORD_LEN / 2) {1'b0}}, wd[(`WORD_LEN/2)-1:0]};
          end
          default: begin
          end
        endcase
      end
    end
  end

endmodule
