`timescale 1ns / 1ps

//***********************************
// Address space

//  PS/2 Keyboard control
//  0x80003008 - reset
//  0x80003004 - valid data
//  0x80003000 - keyboard key code

// Led control
//  0x80001010 - controller reset: 0x00-0x07 -> 0x00, 0x08 -> 0xFF, 0x09 -> 0xFF
//  0x8000100C - mode of choosing displays, 0xFF - mode isn't used, 0x00 - 0x07 - choosed display, that starts blinking
//  0x80001008 - on/off of individual seven-segment displays (eg. 0xFF - all displays turns on, 0x00 - all turns off)
//  0x80001000 – 0x80001007 - nums to disp on LEDs

// RAM
// RAM_SIZE
// 0x000003FC - 0x00000000

module addr_decoder #(
    parameter RAM_SIZE = 256  // WORDS
) (
    input req_i,
    input we_i,
    input [`WORD_LEN-1:0] addr_i,

    output logic [`RD_SEL_LEN-1:0] RDsel_o,

    output logic req_m_o,  //  memory control pins
    output logic we_m_o,

    output logic we_d0_o,
    output logic we_d1_o
);

  always_comb begin
    RDsel_o <= `RD_SEL_LEN'b0;
    req_m_o <= 1'b0;
    we_m_o  <= 1'b0;
    we_d0_o <= 1'b0;
    we_d1_o <= 1'b0;

    if (addr_i < RAM_SIZE) begin
      req_m_o <= req_i;
      we_m_o  <= we_i;
      RDsel_o <= `RDATA_MEM;
    end else if ((addr_i >= `WORD_LEN'h80001000) & (addr_i <= `WORD_LEN'h80001010)) begin
      we_d0_o <= we_i;
    end else if ((addr_i >= `WORD_LEN'h80003000) & (addr_i <= `WORD_LEN'h80003008)) begin
      we_d1_o <= we_i;
      RDsel_o <= `RDATA_KEYBOARD;
    end
  end

endmodule
