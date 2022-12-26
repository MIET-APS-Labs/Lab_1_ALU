`timescale 1ns / 1ps

//***********************************
// Address space
//  Using 2 WORDS
//  0x80003000 - keyboard key code
//  0x80003004 - valid data
//  0x80003008 - reset

// Bytes addressing in words
//  _ _ _ _ | _ _ _ _
//  0 1 2 3   4 5 6 7

`define ADDR_LEN 4 // $clog2(`8) + 1

`define C_KEY_CODE_REG 4'h0
`define C_VALID_REG 4'h4
`define C_RST_REG 4'h8

module ps2_keyboard_control (
    input clk_200_i,

    input [`WORD_LEN-1:0] wdata_i,
    input [`ADDR_LEN-1:0] addr_i,  // byte addressable
    input we_i,

    input ps2_clk_i,
    input ps2_data_i,

    input valid_data_rst_i,

    output logic [`WORD_LEN-1:0] data_o,

    output logic valid_data_int_o
);

  logic [7:0] keyboard_data;

  ps2_keyboard my_keyboard (
      .a_rst_i(rst_reg[0]),
      .clk_200_i(clk_200_i),
      .ps2_clk_i(ps2_clk_i),
      .ps2_data_i(ps2_data_i),
      .valid_data_rst_i(valid_data_rst_i),

      .valid_data_o(valid_data_int_o),
      .data_o(keyboard_data)
  );

  logic [`WORD_LEN-1:0] rst_reg;

  // enum {
  //   C_KEY_CODE_REG = `ADDR_LEN'h0,
  //   C_VALID_REG = `ADDR_LEN'h04,
  //   C_RST_REG = `ADDR_LEN'h08
  // } C_ADDR;

  // Reset control
  always_ff @(posedge clk_200_i) begin
    if (we_i) begin
      if (addr_i == `C_RST_REG) begin
        rst_reg <= wdata_i;
      end
    end
  end


  always_comb begin
    if (!rst_reg[0]) begin
      if (addr_i == `C_KEY_CODE_REG) begin
        data_o <= {{(`WORD_LEN - `BYTE_WIDTH) {1'b0}}, keyboard_data};
      end else begin
        data_o <= `WORD_LEN'b0;
      end
    end
  end

endmodule
