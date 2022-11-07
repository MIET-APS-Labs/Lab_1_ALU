`timescale 1ns / 1ps

`define WORD_LEN 32
`define NEXT_INSTR_INCREASE 4
`define INSTR_DEPTH 64

`define PROG_FILE_NAME "prog.txt"

module instr_rom_testbench ();

  logic CLK;
  parameter PERIOD = 20;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  logic [`WORD_LEN-1:0] instruction_init;
  instr_rom #(`WORD_LEN, `INSTR_DEPTH, `PROG_FILE_NAME) dut_init (
      .adr(clk_cntr),
      .rd (instruction_init)
  );

  logic [`WORD_LEN-1:0] instruction_nullifyed;
  instr_rom dut_nullifyed (
      .adr(clk_cntr),
      .rd (instruction_nullifyed)
  );

  int                   fd;  // save prog file descriptot
  logic [`WORD_LEN-1:0] new_data;  // store new value from file

  parameter COUNTER_WIDTH = $clog2(`INSTR_DEPTH);
  logic [`WORD_LEN-1:0] clk_cntr;
  initial begin
    $display("\nCheck nullifyed Instr ROM\n");
    clk_cntr <= 0;
    for (int i = 0; i < `INSTR_DEPTH; i += `NEXT_INSTR_INCREASE) begin
      @(negedge CLK);
      #5;
      if (instruction_nullifyed == 0) begin
        $display("%d) SUCCESS:  Instruction = %h", clk_cntr, instruction_nullifyed);
      end else begin
        $display("%d) FAILED:  Instruction = %h", clk_cntr, instruction_nullifyed);
      end
      clk_cntr <= clk_cntr + `NEXT_INSTR_INCREASE;
    end

    fd = $fopen(`PROG_FILE_NAME, "r");
    if (fd) begin
      $display("\nFile %s opened SUCCESSFULLY", `PROG_FILE_NAME);
    end else begin
      $display("\nFile %s NOT opened", `PROG_FILE_NAME);
    end

    clk_cntr <= 0;
    $display("\nCheck Instr ROM initialized with mem init file\n");
    for (int i = 0; i < `INSTR_DEPTH; i += `NEXT_INSTR_INCREASE) begin
      $fscanf(fd, "%h", new_data);
      @(negedge CLK);
      #5;
      if (instruction_init == new_data) begin
        $display("%d) SUCCESS:  Instruction = %h", clk_cntr, instruction_init);
      end else begin
        $display("%d) FAILED:  Instruction = %h, File data = %h", clk_cntr, instruction_init,
                 new_data);
      end
      clk_cntr <= clk_cntr + `NEXT_INSTR_INCREASE;
    end
    $fclose(fd);
    $finish;
  end

endmodule
