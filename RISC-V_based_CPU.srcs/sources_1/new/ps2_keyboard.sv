`timescale 1ns / 1ps


module ps2_keyboard (
    input a_rst_i,
    input clk_200_i,
    input ps2_clk_i,
    input ps2_data_i,
    input valid_data_rst_i,

    output logic valid_data_o,
    output [7:0] data_o
);

  // CLK divider 200 MHz -> 50 MHz
  // CLK divider 100 MHz -> 50 MHz for test on FPGA
  logic clk_50;
  //logic [2:0] clk_cntr_4;
  logic [1:0] clk_cntr_2;
  //parameter DIVISOR = 3'd4;
  parameter DIVISOR = 3'd2;
  assign clk_50 = clk_cntr_2[1];
  always_ff @(posedge clk_200_i) begin
    if (a_rst_i) begin
      clk_cntr_2 <= 2'b0;
    end else begin
      if (clk_cntr_2 >= DIVISOR) begin
        clk_cntr_2 <= 2'b1;
      end else begin
        clk_cntr_2 <= clk_cntr_2 + 1;
      end
    end
  end

  // Detect poor ps2_clk_i negedge with register
  logic [9:0] ps2_clk_detect;
  always_ff @(posedge clk_50, posedge a_rst_i) begin
    if (a_rst_i) begin
      ps2_clk_detect <= 10'd0;
    end else begin
      ps2_clk_detect <= {ps2_clk_i, ps2_clk_detect[9:1]};
    end
  end
  logic ps2_clk_negedge;
  assign ps2_clk_negedge = &ps2_clk_detect[4:0] && &(~ps2_clk_detect[9:5]);



  // Finite state machine for controlling communication process
  logic [1:0] state;
  localparam IDLE = 2'd0;
  localparam RECEIVE_DATA = 2'd1;
  localparam CHECK_PARITY_STOP_BITS = 2'd2;
  always_ff @(negedge ps2_clk_i, posedge a_rst_i)
    if (a_rst_i) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          if (!ps2_data_i) begin
            state = RECEIVE_DATA;
          end
        end
        RECEIVE_DATA: begin
          if (count_bit == 10) begin
            state = CHECK_PARITY_STOP_BITS;
          end
        end
        CHECK_PARITY_STOP_BITS: begin
          state = IDLE;
        end
        default: begin
          state = IDLE;
        end
      endcase
    end

  // Receiving data
  logic [8:0] shift_reg;
  assign data_o = shift_reg[7:0];
  always @(posedge clk_50, posedge a_rst_i) begin
    if (a_rst_i) begin
      shift_reg <= 9'b0;
    end else if (ps2_clk_negedge && ((state == RECEIVE_DATA))) begin
      shift_reg <= {ps2_data_i, shift_reg[8:1]};
    end
  end


  // Counting received bits
  logic [3:0] count_bit;
  always @(posedge clk_50, posedge a_rst_i) begin
    if (a_rst_i) begin
      count_bit <= 4'b0;
    end else if (ps2_clk_negedge) begin
      if (state == RECEIVE_DATA) begin
        count_bit <= count_bit + 4'b1;
      end else begin
        count_bit <= 4'b0;
      end
    end
  end


  // Check parity bit and stop bit
  function parity_calc;
    input [7:0] a;
    parity_calc = ~(a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[4] ^ a[5] ^ a[6] ^ a[7]);
  endfunction
  always @(posedge clk_200_i, posedge a_rst_i) begin
    if (a_rst_i || valid_data_rst_i) begin
      valid_data_o <= 1'b0;
    end else if (ps2_clk_negedge) begin
      if (ps2_data_i && parity_calc(
              shift_reg[7:0]
          ) == shift_reg[8] && state == CHECK_PARITY_STOP_BITS)
        valid_data_o <= 1'b1;
    end else begin
      //valid_data_o <= 1'b0;
    end
  end

endmodule
