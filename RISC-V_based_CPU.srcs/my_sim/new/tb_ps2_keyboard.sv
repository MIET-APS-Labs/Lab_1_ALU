`timescale 1ns / 1ps

`define WORD_LEN 32
`define BYTE_WIDTH 8

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

`define KEYBOARD_ACTIONS_NUM 4

module tb_ps2_keyboard ();

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

  logic ps2_clk;
  logic ps2_data;
  logic ps2_comm_start;

  // PS/2 Clock
  parameter PS2_CYCLE = 100000;  // 10 KHz clock
  always begin
    if (ps2_comm_start) begin
      ps2_clk = 1'b1;
      #(PS2_CYCLE);
      ps2_clk = 1'b0;
      #(PS2_CYCLE);
    end else begin
      ps2_clk = 1'b0;
      #(HF_CYCLE);
    end

  end

  logic [`WORD_LEN-1:0] data;



  ps2_keyboard_control dut (
      .clk_200_i(clk),

      .wdata_i(wdata),
      .addr_i(addr),  // byte addressable
      .we_i(we),

      .ps2_clk_i(ps2_clk),
      .ps2_data_i(ps2_data),
      .data_o(data)
  );

  logic [`BYTE_WIDTH-1:0] ps2_data_tx[`KEYBOARD_ACTIONS_NUM-1:0];
  logic [`BYTE_WIDTH-1:0] release_key_code = 8'hF0;

  initial begin
    int i;
    int j;
    ps2_data_tx[0] = `BYTE_WIDTH'h3a;
    ps2_data_tx[1] = `BYTE_WIDTH'h43;
    ps2_data_tx[2] = `BYTE_WIDTH'h24;
    ps2_data_tx[3] = `BYTE_WIDTH'h2c;
    ps2_comm_start = 1'b0;
    ps2_data = 1'b1;

    @(negedge clk);
    addr = `ADDR_LEN'h8;
    wdata = {{`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0}, {`BYTE_WIDTH'b0},{`BYTE_WIDTH{1'b1}}};
    we    = 1'b1;  // reset
    #RST_WAIT;
    wdata = `WORD_LEN'b0;
    #RST_WAIT;
    we = 1'b0;

    for (i = 0; i < `KEYBOARD_ACTIONS_NUM; i++) begin
      ps2_comm_start = 1'b1;
      ps2_data = 1'b0;
      @(negedge ps2_clk);
      for (j = 0; j < `BYTE_WIDTH; j++) begin  // PRESS
        @(posedge ps2_clk);
        ps2_data = ps2_data_tx[i][j];
      end
      @(posedge ps2_clk);
      $display("\n%d) %b\n", i, ^ps2_data_tx[i]);
      ps2_data = ~(^ps2_data_tx[i]);
      @(posedge ps2_clk);
      ps2_data = 1'b1;
      @(posedge ps2_clk);
      ps2_comm_start = 1'b0;

      #(10 * PS2_CYCLE);

      ps2_comm_start = 1'b1;
      ps2_data = 1'b0;
      @(negedge ps2_clk);
      for (j = 0; j < `BYTE_WIDTH; j++) begin  //RELEASE KEY CODE
        @(posedge ps2_clk);
        ps2_data = release_key_code[j];
      end
      @(posedge ps2_clk);
      ps2_data = ~(^release_key_code);
      @(posedge ps2_clk);
      ps2_data = 1'b1;
      @(posedge ps2_clk);
      #PS2_CYCLE;


      ps2_data = 1'b0;
      @(negedge ps2_clk);
      for (j = 0; j < `BYTE_WIDTH; j++) begin  //RELEASE 
        @(posedge ps2_clk);
        ps2_data = ps2_data_tx[i][j];
      end
      @(posedge ps2_clk);
      ps2_data = ~(^ps2_data_tx[i]);
      @(posedge ps2_clk);
      ps2_data = 1'b1;
      @(posedge ps2_clk);
      ps2_comm_start = 1'b0;

      #(10 * PS2_CYCLE);

      @(negedge clk);
      addr = `ADDR_LEN'h4;  // read valid data
      #(HF_CYCLE);

      @(negedge clk);
      addr = `ADDR_LEN'h0;  // read key code
      #(HF_CYCLE);
    end
    $finish;
  end


endmodule
