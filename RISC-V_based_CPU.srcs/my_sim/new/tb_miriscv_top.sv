`timescale 1ns / 1ps

`define DEBUG_ON 1

module tb_miriscv_top ();

  parameter HF_CYCLE = 2.5;  // 200 MHz clock
  parameter RST_WAIT = 10;  // 10 ns reset
  parameter RAM_SIZE = 256;  // WORDS

  // clock, reset
  logic clk;
  logic rst_n;

  logic [`WORD_LEN-1:0] instruction;
  assign instruction = dut.core.instr_rdata_i;

  logic [`WORD_LEN-1:0] PC;
  assign PC = dut.core.PC;

  logic lsu_req_i, lsu_we_i, lsu_stall_req_o, data_req_o, data_we_o;
  assign lsu_req_i = dut.core.load_store_unit.lsu_req_i;
  assign lsu_we_i = dut.core.load_store_unit.lsu_we_i;
  assign lsu_stall_req_o = dut.core.load_store_unit.lsu_stall_req_o;
  assign data_req_o = dut.core.load_store_unit.data_req_o;
  assign data_we_o = dut.core.load_store_unit.data_we_o;

  logic [`WORD_LEN-1:0] lsu_data_o, lsu_data_i, data_addr_o;
  assign lsu_data_o  = dut.core.load_store_unit.lsu_data_o;
  assign lsu_data_i  = dut.core.load_store_unit.lsu_data_i;
  assign data_addr_o = dut.core.load_store_unit.data_addr_o;

  logic [`WORD_LEN -1:0] ALU_A_operand, ALU_B_operand;
  assign ALU_A_operand = dut.core.ALU_A_operand;
  assign ALU_B_operand = dut.core.ALU_B_operand;

  logic prog_finished;

  miriscv_top #(
      .RAM_SIZE     (RAM_SIZE),
      .RAM_INIT_FILE("prog.txt")
  ) dut (
      .clk_i(clk),
      .rst_n_i(rst_n),
      .core_prog_finished(prog_finished)
  );

  logic program_started;

  initial begin

    int i = 0;
    while (dut.ram.RAM[i] >= {`WORD_LEN{1'b0}}) begin
      $display("%d) RAM = %h", i, dut.ram.RAM[i]);
      i++;
    end


    clk   = 1'b0;
    rst_n = 1'b0;
    #RST_WAIT;

    rst_n = 1'b1;
    #RST_WAIT;
    program_started = 1'b1;

    while (!prog_finished) begin
      clk = ~clk;
      #HF_CYCLE;
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
          debug_iter, dut.core.instr_rdata_i, dut.core.illegal_instr_o, dut.core.reg_write_data,
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
