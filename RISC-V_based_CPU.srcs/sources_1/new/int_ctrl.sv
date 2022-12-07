`timescale 1ns / 1ps

module int_ctrl (
    input clk_i,
    input arstn_i,

    input INT_RST,  // reports that Interrupt handled

    input [`WORD_LEN-1:0] mie_i,   // Machine interrup-enable register
    input [`WORD_LEN-1:0] int_req, // Machine interrup-enable register

    output [`WORD_LEN-1:0] mcause_o,  // Machine trap cause
    output INT,  // reports about Interrupt occurs and must be handled
    output [`WORD_LEN-1:0] int_fin
);



  logic [`WORD_LEN-1:0] dec_out;
  logic [`WORD_LEN-1:0] choosed_int;

  // Decoder
  always_comb begin
    dec_out <= `WORD_LEN'b0;
    case (clk_cntr)
      0: dec_out[0] <= 1'b1;
      1: dec_out[1] <= 1'b1;
      2: dec_out[2] <= 1'b1;
      3: dec_out[3] <= 1'b1;
      4: dec_out[4] <= 1'b1;
      5: dec_out[5] <= 1'b1;
      6: dec_out[6] <= 1'b1;
      7: dec_out[7] <= 1'b1;
      8: dec_out[8] <= 1'b1;
      9: dec_out[9] <= 1'b1;
      10: dec_out[10] <= 1'b1;
      11: dec_out[11] <= 1'b1;
      12: dec_out[12] <= 1'b1;
      13: dec_out[13] <= 1'b1;
      14: dec_out[14] <= 1'b1;
      15: dec_out[15] <= 1'b1;
      16: dec_out[16] <= 1'b1;
      17: dec_out[17] <= 1'b1;
      18: dec_out[18] <= 1'b1;
      19: dec_out[19] <= 1'b1;
      20: dec_out[20] <= 1'b1;
      21: dec_out[21] <= 1'b1;
      22: dec_out[22] <= 1'b1;
      23: dec_out[23] <= 1'b1;
      24: dec_out[24] <= 1'b1;
      25: dec_out[25] <= 1'b1;
      26: dec_out[26] <= 1'b1;
      27: dec_out[27] <= 1'b1;
      28: dec_out[28] <= 1'b1;
      29: dec_out[29] <= 1'b1;
      30: dec_out[30] <= 1'b1;
      31: dec_out[31] <= 1'b1;
      default: dec_out <= `WORD_LEN'b0;
    endcase
  end

  assign choosed_int = dec_out & (mie_i & int_req);

  assign int_fin = {`WORD_LEN{INT_RST}} & choosed_int;

  logic int_exist;
  assign int_exist = |choosed_int;

  logic int_store;
  always_ff @(posedge clk_i) begin
    int_store <= INT_RST ? 0 : int_exist;
  end

  assign INT = int_exist ^ int_store;

  parameter CNTR_LEN = $clog2(`WORD_LEN);
  logic [CNTR_LEN-1:0] clk_cntr;
  logic cntr_en_n;
  assign cntr_en_n = int_exist;

  logic cntr_rst;
  assign cntr_rst = INT_RST;

  always_ff @(posedge clk_i, negedge arstn_i) begin
    if (cntr_rst || !arstn_i) begin
      clk_cntr <= 1'b0;
    end else if (!cntr_en_n) begin
      clk_cntr <= clk_cntr + 1;
    end
  end

  assign mcause_o = {{1'b1}, {(`WORD_LEN - CNTR_LEN - 1) {1'b0}}, clk_cntr};

endmodule
