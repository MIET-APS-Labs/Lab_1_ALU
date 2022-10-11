`timescale 1ns / 1ps

`define SEGMENTS_NUM 7
`define DIGITS_NUM 8
`define HEX_DIGIT_MAX_NUM 16

`define DIG_0 8'b00000001
`define DIG_1 8'b00000010
`define DIG_2 8'b00000100
`define DIG_3 8'b00001000
`define DIG_4 8'b00010000
`define DIG_5 8'b00100000
`define DIG_6 8'b01000000
`define DIG_7 8'b10000000

`define CLK_DIV 1000

module disp_HEX #(
    parameter WORD_LEN = 32
) (
    input CLK,
    input [WORD_LEN-1:0] num,
    input rst,
    output logic [`SEGMENTS_NUM-1:0] HEX,
    output logic [`DIGITS_NUM-1:0] DIG
);

  logic [11:0] clk_cntr = 0;

  initial begin
    DIG_inv <= `DIG_0;
    refresh_cntr <= 0;
  end


  logic [$clog2(`DIGITS_NUM):0] refresh_cntr;
  logic [`DIGITS_NUM-1:0] DIG_inv;

  assign DIG = ~DIG_inv;

  always @(posedge CLK) begin
    if (~rst) begin
      clk_cntr <= 0;
    end else if (clk_cntr >= `CLK_DIV) begin
      clk_cntr <= 0;
    end else begin
      clk_cntr <= clk_cntr + 1;
    end
  end


  always @(posedge CLK) begin
    //$display("clk_cntr = %b, CLK_divided = %b", clk_cntr, CLK_divided);
    if (~rst) begin
      DIG_inv <= `DIG_0;
    end else if (clk_cntr == `CLK_DIV) begin
      if (refresh_cntr >= (`DIGITS_NUM - 1)) begin
        refresh_cntr <= 0;
        DIG_inv <= `DIG_0;
      end else begin
        refresh_cntr <= refresh_cntr + 1;
        DIG_inv <= DIG_inv << 1;
      end
    end
  end

  always @* begin
    //$display("disp_HEX clk_cntr: %b", clk_cntr);
    case (DIG_inv)
      `DIG_0: begin
        case (num[3:0])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_1: begin
        case (num[7:4])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_2: begin
        case (num[11:8])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_3: begin
        case (num[15:12])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_4: begin
        case (num[19:16])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_5: begin
        case (num[23:20])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_6: begin
        case (num[27:24])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end

      `DIG_7: begin
        case (num[31:28])
          4'b1111: HEX = 7'b0001110;
          4'b1110: HEX = 7'b0000110;
          4'b1101: HEX = 7'b0100001;
          4'b1100: HEX = 7'b1000110;
          4'b1011: HEX = 7'b0000011;
          4'b1010: HEX = 7'b0001000;

          4'b1001: HEX = 7'b0010000;
          4'b1000: HEX = 7'b0000000;
          4'b0111: HEX = 7'b1111000;
          4'b0110: HEX = 7'b0000010;
          4'b0101: HEX = 7'b0010010;
          4'b0100: HEX = 7'b0011001;
          4'b0011: HEX = 7'b0110000;
          4'b0010: HEX = 7'b0100100;
          4'b0001: HEX = 7'b1111001;
          4'b0000: HEX = 7'b1000000;
          default: HEX = 7'b1111111;
        endcase
      end
    endcase

  end
endmodule
