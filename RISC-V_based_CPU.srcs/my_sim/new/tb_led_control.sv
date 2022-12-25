`timescale 1ns / 1ps

`define WORD_LEN 32
`define BYTE_WIDTH 8

//***********************************
// Address space
//  Using 4 WORDS
//  0x80001000 – 0x80001007 - nums to disp on LEDs
//  0x80001008 - on/off of individual seven-segment displays (eg. 0xFF - all displays turns on, 0x00 - all turns off)
//  0x80001009 - mode of choosing displays, 0xFF - mode isn't used, 0x00 - 0x07 - choosed display, that starts blinking
//  0x8000100A - controller reset: 0x00-0x07 -> 0x00, 0x08 -> 0xFF, 0x09 -> 0xFF

// Bytes addressing in words
//  _ _ _ _ | _ _ _ _ | _ _ _ _ | _ _ _ _ | _ _ _ _ |
//  0 1 2 3   4 5 6 7   8 9 A B   C D E F  10 11 12 13

`define REG_BYTES_NUM 11

`define SEGMENTS_NUM 7
`define DIGITS_NUM 8

`define BITS_IN_NUM_LEN 4

`define ADDR_LEN 5 // $clog2(14) + 1
`define BE_LEN 4 // `WORD_LEN / `BYTE_WIDTH

module tb_led_control ();
  parameter HF_CYCLE = 2.5;  // 200 MHz clock
  parameter RST_WAIT = 10;  // 10 ns reset

  // clock
  logic clk;
  always begin
    clk = 1'b0;
    #(HF_CYCLE);
    clk = 1'b1;
    #(HF_CYCLE);
  end


  logic [`WORD_LEN-1:0] wdata;
  logic [`ADDR_LEN-1:0] addr;  // byte addressable
  logic we;

  logic [`SEGMENTS_NUM-1:0] HEX;
  logic [`DIGITS_NUM-1:0] DIG;

  led_control dut (
      .clk_200_i(clk),
      .wdata_i(wdata),
      .addr_i(addr),  // byte addressable
      .we_i(we),

      .HEX_o(HEX),
      .DIG_o(DIG)
  );

  initial begin
    @(negedge clk);
    addr = `ADDR_LEN'h10;
    wdata = {{`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0},{`BYTE_WIDTH{1'b1}}};
    we    = 1'b1;  // reset
    #RST_WAIT;
    wdata = `WORD_LEN'b0;
    #RST_WAIT;
    we = 1'b0;

    @(negedge clk);
    addr = `ADDR_LEN'h0;  // load 8 numbers
    wdata = {{`BYTE_WIDTH'd1}, {`BYTE_WIDTH'd2}, {`BYTE_WIDTH'd3}, {`BYTE_WIDTH'd4}};
    we = 1'b1;
    @(negedge clk);
    addr  = `ADDR_LEN'h4;
    wdata = {{`BYTE_WIDTH'd5}, {`BYTE_WIDTH'd6}, {`BYTE_WIDTH'd7}, {`BYTE_WIDTH'd0}};
    @(negedge clk);
    we = 1'b0;

    @(negedge clk);
    addr  = `ADDR_LEN'h8;  // load all segments enable
    wdata = {{(`WORD_LEN - `BYTE_WIDTH) {1'b0}}, {`BYTE_WIDTH{1'b1}}};
    we    = 1'b1;
    @(negedge clk);
    we = 1'b0;

    #2000;  // wait for display nums

    @(negedge clk);
    addr  = `ADDR_LEN'hC;  // load choosing 2nd segment
    wdata = {{(`WORD_LEN - `BYTE_WIDTH) {1'b1}}, {`BYTE_WIDTH'h1}};
    we    = 1'b1;
    @(negedge clk);
    we = 1'b0;

    #2000;  // wait for display blinking

    @(negedge clk);
    addr = `ADDR_LEN'hA;
    wdata = {{`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0}, {`BYTE_WIDTH{1'b1}}};
    we = 1'b1;
    #RST_WAIT;
    wdata = `WORD_LEN'b0;  // reset
    we    = 1'b0;
    #RST_WAIT;

    $finish;
  end
endmodule
