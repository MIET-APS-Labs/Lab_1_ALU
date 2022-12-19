`timescale 1ns / 1ps

//***********************************
// Address space
//  Using 4 WORDS
//  0x80001000 – 0x80001007 - nums to disp on LEDs
//  0x80001008 - on/off of individual seven-segment displays (eg. 0xFF - all displays turns on, 0x00 - all turns off)
//  0x8000100C - mode of choosing displays, 0xFF - mode isn't used, 0x00 - 0x07 - choosed display, that starts blinking
//  0x80001010 - controller reset: 0x00-0x07 -> 0x00, 0x08 -> 0xFF, 0x09 -> 0xFF

// Bytes addressing in words
//  _ _ _ _ | _ _ _ _ | _ _ _ _ | _ _ _ _ | _ _ _ _ |
//  0 1 2 3   4 5 6 7   8 9 A B   C D E F  10 11 12 13


`define SEGMENTS_NUM 7
`define DIGITS_NUM 8
`define DIGIT_BIT_LEN 4

`define NUM_TO_DISP_LEN 32

`define DISP_ON_OFF_REG_LEN 8
`define MODE_REG_LEN 8
`define RST_REG_LEN 8

`define BITS_IN_NUM_LEN 4

`define ADDR_LEN 5 // $clog2(`14) + 1
`define BE_LEN 4 // `WORD_LEN / `BYTE_WIDTH

//`define CLK_DIV 100000000
`define CLK_DIV 10

module led_control (
    input clk_200_i,
    input [`WORD_LEN-1:0] wdata_i,
    input [`ADDR_LEN-1:0] addr_i,  // byte addressable
    input we_i,

    output logic [`SEGMENTS_NUM-1:0] HEX_o,
    output logic [  `DIGITS_NUM-1:0] DIG_o
);

  logic [`WORD_LEN-1:0] num_reg_1;
  logic [`WORD_LEN-1:0] num_reg_2;
  logic [`WORD_LEN-1:0] disp_on_off_reg;
  logic [`WORD_LEN-1:0] mode_reg;
  logic [`WORD_LEN-1:0] rst_reg;

  enum {
    C_NUM_1_REG = `ADDR_LEN'h0,
    C_NUM_2_REG = `ADDR_LEN'h04,
    C_DISP_REG  = `ADDR_LEN'h08,
    C_MODE_REG  = `ADDR_LEN'h0C,
    C_RST_REG   = `ADDR_LEN'h10
  } C_ADDR;

  always_ff @(posedge clk_200_i) begin
    if (rst_reg[0]) begin
      num_reg_1 <= `WORD_LEN'b0;
      num_reg_2 <= `WORD_LEN'b0;
      disp_on_off_reg <= `WORD_LEN'b0;
      mode_reg <= {`WORD_LEN{1'b1}};
    end
    if (we_i) begin
      if (addr_i == C_NUM_1_REG) begin
        num_reg_1 <= wdata_i;
      end else if (addr_i == C_NUM_2_REG) begin
        num_reg_2 <= wdata_i;
      end else if (addr_i == C_DISP_REG) begin
        disp_on_off_reg <= wdata_i;
      end else if (addr_i == C_MODE_REG) begin
        mode_reg <= wdata_i;
      end else if (addr_i == C_RST_REG) begin
        rst_reg <= wdata_i;
      end
    end
  end


  logic [`NUM_TO_DISP_LEN-1:0] num_to_disp;
  logic [`DIGITS_NUM-1:0] dig_to_disp;
  logic disp_rst;

  disp_HEX #(
      .DIGITS_NUM(`DIGITS_NUM),
      .SEGMENTS_NUM(`SEGMENTS_NUM),
      .CLK_DIV(`CLK_DIV / 10)
  ) my_disp (
      .clk_200_i(clk_200_i),
      .num(num_to_disp),
      .rst(disp_rst),
      .HEX(HEX_o),
      .DIG(DIG_o)
  );

  // CLK prescaler for choose display mode
  logic [25:0] clk_cntr = 0;  //200 MHz -> 2 Hz

  always @(posedge clk_200_i) begin
    if (rst_reg[0]) begin
      clk_cntr <= 0;
    end else if (clk_cntr >= `CLK_DIV) begin
      clk_cntr <= 0;
    end else begin
      clk_cntr <= clk_cntr + 1;
    end
  end

  logic prescaled_clk;
  assign prescaled_clk = (clk_cntr == `CLK_DIV);


  // displaying numbers
  always_ff @(posedge prescaled_clk, posedge rst_reg[0]) begin
    if (!rst_reg[0]) begin
      if (mode_reg[`MODE_REG_LEN-1:0] != `DIGITS_NUM'hff) begin  // blinking
        case (mode_reg[`MODE_REG_LEN-1:0])
          `DIGITS_NUM'h0: begin
            //dig_to_disp[0] = ~dig_to_disp[0];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 1) {1'b0}}, dig_to_disp[0]};
          end
          `DIGITS_NUM'h1: begin
            //dig_to_disp[1] = ~dig_to_disp[1];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 2) {1'b0}}, dig_to_disp[1], 1'b0};
          end
          `DIGITS_NUM'h2: begin
            //dig_to_disp[2] = ~dig_to_disp[2];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 3) {1'b0}}, dig_to_disp[2], {2'b0}};
          end
          `DIGITS_NUM'h3: begin
            //dig_to_disp[3] = ~dig_to_disp[3];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 4) {1'b0}}, dig_to_disp[3], {3'b0}};
          end
          `DIGITS_NUM'h4: begin
            //dig_to_disp[4] = ~dig_to_disp[4];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 5) {1'b0}}, dig_to_disp[4], {4'b0}};
          end
          `DIGITS_NUM'h5: begin
            //dig_to_disp[5] = ~dig_to_disp[5];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 6) {1'b0}}, dig_to_disp[5], {5'b0}};
          end
          `DIGITS_NUM'h6: begin
            //dig_to_disp[6] = ~dig_to_disp[6];
            disp_rst <= ~disp_rst;
            dig_to_disp = {{(`DIGITS_NUM - 7) {1'b0}}, dig_to_disp[6], {6'b0}};
          end
          `DIGITS_NUM'h7: begin
            //dig_to_disp[7] = ~dig_to_disp[7];
            disp_rst <= ~disp_rst;
            dig_to_disp = {dig_to_disp[7], {7'b0}};
          end
          default: begin
            dig_to_disp = `DIGITS_NUM'b0;
          end
        endcase
      end else begin
        disp_rst <= 1'b0;
        dig_to_disp = disp_on_off_reg[`DISP_ON_OFF_REG_LEN-1:0];
      end

      num_to_disp = {`NUM_TO_DISP_LEN{1'b1}};

      if (dig_to_disp[0]) begin
        num_to_disp[0+:`BITS_IN_NUM_LEN] <= num_reg_1[0+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[1]) begin
        num_to_disp[`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_1[8+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[2]) begin
        num_to_disp[2*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_1[16+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[3]) begin
        num_to_disp[3*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_1[24+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[4]) begin
        num_to_disp[4*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_2[0+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[5]) begin
        num_to_disp[5*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_2[8+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[6]) begin
        num_to_disp[6*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_2[16+:`BITS_IN_NUM_LEN];
      end
      if (dig_to_disp[7]) begin
        num_to_disp[7*`BITS_IN_NUM_LEN+:`BITS_IN_NUM_LEN] <= num_reg_2[24+:`BITS_IN_NUM_LEN];
      end
    end else begin
      disp_rst <= 1'b1;
    end
  end

endmodule
