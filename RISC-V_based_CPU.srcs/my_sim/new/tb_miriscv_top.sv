`timescale 1ns / 1ps

`define DEBUG_ON 0

`define INT_LINE_5 5
`define INT_LINE_19 19

`define SEGMENTS_NUM 7
`define DIGITS_NUM 8

module tb_miriscv_top ();

  parameter HF_CYCLE = 2.5;  // 200 MHz clock
  parameter RST_WAIT = 10;  // 10 ns reset
  parameter RAM_SIZE = 256;  // WORDS

  // clock, reset
  logic clk;
  logic rst_n;

  always begin
    clk = 1'b0;
    #(HF_CYCLE);
    clk = 1'b1;
    #(HF_CYCLE);
  end

  logic ps2_clk;
  logic ps2_data;
  logic ps2_comm_start;
  // PS/2 Clock
  parameter PS2_CYCLE = 500;  // (10 KHz clock) -> 1 MHz for test
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

  logic [`WORD_LEN-2:0] int_req;  // INT 0 connected to PS/2 Keyboard valid data reg
  logic [`WORD_LEN-2:0] int_fin;

  logic [`SEGMENTS_NUM-1:0] HEX;
  logic [`DIGITS_NUM-1:0] DIG;

  logic prog_finished;

  miriscv_top #(
      .RAM_SIZE     (RAM_SIZE),
      .RAM_INIT_FILE("prog.txt")
  ) dut (
      .clk_i  (clk),
      .rst_n_i(rst_n),

      .int_req_ext_i(int_req),
      .int_fin_ext_o(int_fin),

      .HEX_o(HEX),
      .DIG_o(DIG),

      .ps2_clk_i (ps2_clk),
      .ps2_data_i(ps2_data),

      .core_prog_finished(prog_finished)
  );

  logic program_started;
  logic [`BYTE_WIDTH-1:0] ps2_data_tx = 8'h3a;
  logic [`BYTE_WIDTH-1:0] release_key_code = 8'hF0;
  initial begin

    int i = 0;
    while (dut.ram.RAM[i] >= {`WORD_LEN{1'b0}}) begin
      $display("%d) RAM = %h", i, dut.ram.RAM[i]);
      i++;
    end

    int_req = 0;

    rst_n   = 1'b0;
    #RST_WAIT;

    rst_n = 1'b1;
    #RST_WAIT;
    program_started = 1'b1;
    i = 0;

    #100;  // wait for init CSR

    while (!prog_finished) begin
      i++;
      if (!(i % 137)) begin
        int_req[`INT_LINE_5] = 1'b1;
        @(posedge int_fin[`INT_LINE_5]);
        #(2 * HF_CYCLE);
        int_req[`INT_LINE_5] = 1'b0;
      end

      if (!(i % 227)) begin
        // int_req[`INT_LINE_19] = 1'b1;
        // @(posedge int_fin[`INT_LINE_19]);
        // #(2 * HF_CYCLE);
        // int_req[`INT_LINE_19] = 1'b0;

        ps2_comm_start = 1'b1;
        ps2_data = 1'b0;
        @(negedge ps2_clk);
        for (i = 0; i < `BYTE_WIDTH; i++) begin  // PRESS
          @(posedge ps2_clk);
          ps2_data = ps2_data_tx[i];
        end
        @(posedge ps2_clk);
        ps2_data = ~(^ps2_data_tx);  // sending parity bit
        @(posedge ps2_clk);
        ps2_data = 1'b1;  // sending stop bit
        @(posedge ps2_clk);
        ps2_comm_start = 1'b0;

        #(10 * PS2_CYCLE);

        ps2_comm_start = 1'b1;
        ps2_data = 1'b0;
        @(negedge ps2_clk);
        for (i = 0; i < `BYTE_WIDTH; i++) begin  //RELEASE KEY CODE
          @(posedge ps2_clk);
          ps2_data = release_key_code[i];
        end
        @(posedge ps2_clk);
        ps2_data = ~(^release_key_code);  // sending parity bit
        @(posedge ps2_clk);
        ps2_data = 1'b1;
        @(posedge ps2_clk);
        #PS2_CYCLE;


        ps2_data = 1'b0;
        @(negedge ps2_clk);
        for (i = 0; i < `BYTE_WIDTH; i++) begin  //RELEASE 
          @(posedge ps2_clk);
          ps2_data = ps2_data_tx[i];
        end
        @(posedge ps2_clk);
        ps2_data = ~(^ps2_data_tx);  // sending parity bit
        @(posedge ps2_clk);
        ps2_data = 1'b1;  // sending stop bit
        @(posedge ps2_clk);
        ps2_comm_start = 1'b0;

        #(10 * PS2_CYCLE);
      end
      #(HF_CYCLE);
    end
    //clk = clk ? 0 : clk;  // Make last negedge to show last debug info
    $finish;
  end

  //  Debug print
  int debug_iter = 0;
  always_ff @(posedge clk) begin
    if (`DEBUG_ON && program_started) begin
      $display(
          "\n%d) \nInstruction = %h\nIllegal instruction = %b\nWD3 = %h\nRD1 = %h\nRD2 = %h\nReset = %b\nProgram counter = %h\n!Enable PC = %b",
          debug_iter, dut.core.instr_rdata, dut.core.illegal_instr, dut.core.reg_write_data,
          dut.core.reg_read_data1, dut.core.reg_read_data2, dut.core.arstn_i, dut.core.PC,
          dut.core.en_pc_n);

      $display(
          "\nlsu_req_i = %h\nlsu_stall_req_o = %h\nlsu_data_o = %h\ndata_req_o = %h\ndata_we_o = %h\ndata_addr_o %h",
          dut.core.load_store_unit.lsu_req_i, dut.core.load_store_unit.lsu_stall_req_o,
          dut.core.load_store_unit.lsu_data_o, dut.core.load_store_unit.data_req_o,
          dut.core.load_store_unit.data_we_o, dut.core.load_store_unit.data_addr_o);

      debug_iter++;
    end
  end

endmodule
