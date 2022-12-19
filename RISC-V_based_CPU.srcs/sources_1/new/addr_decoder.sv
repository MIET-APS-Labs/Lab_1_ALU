`timescale 1ns / 1ps

//***********************************
// Address space
// Led control
//  0x80001000 – 0x80001007 - nums to disp on LEDs
//  0x80001008 - on/off of individual seven-segment displays (eg. 0xFF - all displays turns on, 0x00 - all turns off)
//  0x8000100C - mode of choosing displays, 0xFF - mode isn't used, 0x00 - 0x07 - choosed display, that starts blinking
//  0x80001010 - controller reset: 0x00-0x07 -> 0x00, 0x08 -> 0xFF, 0x09 -> 0xFF

//  PS/2 Keyboard control
//  0x80003000 - keyboard key code
//  0x80003004 - valid data
//  0x80003008 - reset

`define PERIPHERAL_DEV_NUM 3

module addr_decoder (
    input req,
    input we,
    input [`WORD_LEN-1:0] addr,

    output [$clog2(`PERIPHERAL_DEV_NUM)-1:0] RDsel,

    output req_m,
    output we_m,

    output we_d0,
    output we_d1,
    output we_d2
);


endmodule
