`timescale 1ns / 1ps

`define DIGIT_BIT_LEN 4

`define DIG_0 8'b11111110
`define DIG_1 8'b11111101
`define DIG_2 8'b11111011
`define DIG_3 8'b11110111
`define DIG_4 8'b11101111
`define DIG_5 8'b11011111
`define DIG_6 8'b10111111
`define DIG_7 8'b01111111


module disp_HEX #(
    parameter DIGITS_NUM = 8,
    parameter SEGMENTS_NUM = 7,
    parameter CLK_DIV = 1000
) (
    input clk_200_i,
    input [(DIGITS_NUM * `DIGIT_BIT_LEN)-1:0] num,
    input rst,
    output logic [SEGMENTS_NUM-1:0] HEX,
    output logic [DIGITS_NUM-1:0] DIG
);

  logic [11:0] clk_cntr = 0;

  initial begin
    DIG <= 8'hff;
    refresh_cntr <= 0;
  end


  logic [$clog2(DIGITS_NUM):0] refresh_cntr;

  always @(posedge clk_200_i, posedge rst) begin
    if (rst) begin
      clk_cntr <= 0;
    end else if (clk_cntr >= CLK_DIV) begin
      clk_cntr <= 0;
    end else begin
      clk_cntr <= clk_cntr + 1;
    end
  end


  always @(posedge clk_200_i, posedge rst) begin
    //$display("clk_cntr = %b, CLK_divided = %b", clk_cntr, CLK_divided);
    if (rst) begin
      refresh_cntr <= 0;
      DIG <= `DIG_0;
    end else if (clk_cntr == CLK_DIV) begin
      if (refresh_cntr >= (DIGITS_NUM - 1)) begin
        refresh_cntr <= 0;
        DIG <= `DIG_0;
      end else begin
        refresh_cntr <= refresh_cntr + 1;
        DIG <= {DIG[0+:DIGITS_NUM-1], 1'b1};
      end
    end
  end

  always_comb begin
    //$display("disp_HEX clk_cntr: %b", clk_cntr);
    if (!rst) begin
      case (DIG)
        `DIG_0: begin
          case (num[3:0])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_1: begin
          case (num[7:4])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_2: begin
          case (num[11:8])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_3: begin
          case (num[15:12])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_4: begin
          case (num[19:16])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_5: begin
          case (num[23:20])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_6: begin
          case (num[27:24])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end

        `DIG_7: begin
          case (num[31:28])
            // Including HEX
            // 4'b1111: HEX <= 7'b0001110;
            // 4'b1110: HEX <= 7'b0000110;
            // 4'b1101: HEX <= 7'b0100001;
            // 4'b1100: HEX <= 7'b1000110;
            // 4'b1011: HEX <= 7'b0000011;
            // 4'b1010: HEX <= 7'b0001000;

            4'b1001: HEX <= 7'b0010000;
            4'b1000: HEX <= 7'b0000000;
            4'b0111: HEX <= 7'b1111000;
            4'b0110: HEX <= 7'b0000010;
            4'b0101: HEX <= 7'b0010010;
            4'b0100: HEX <= 7'b0011001;
            4'b0011: HEX <= 7'b0110000;
            4'b0010: HEX <= 7'b0100100;
            4'b0001: HEX <= 7'b1111001;
            4'b0000: HEX <= 7'b1000000;
            default: HEX <= 7'b1111111;
          endcase
        end
      endcase
    end else begin
      HEX <= 7'b1111111;
    end
  end
endmodule
