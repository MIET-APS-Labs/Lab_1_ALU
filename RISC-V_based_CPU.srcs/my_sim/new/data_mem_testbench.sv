`timescale 1ns / 1ps

`define WORD_LEN 32
`define MEM_DEPTH 256
`define MEM_TYPE_LOAD_STORE_BIT_NUM 3

`define BYTE_WIDTH 8

// dmem type load store
`define LDST_B 3'b000
`define LDST_H 3'b001
`define LDST_W 3'b010
`define LDST_BU 3'b100
`define LDST_HU 3'b101

module data_mem_testbench ();
  logic CLK;

  logic [$clog2(`MEM_DEPTH)-1:0] ADR;
  logic [`WORD_LEN-1:0] WD;
  logic WE;

  logic [`MEM_TYPE_LOAD_STORE_BIT_NUM-1:0] MEM_SIZE;
  logic [`WORD_LEN-1:0] RD;


  logic [`WORD_LEN-1:0] data_read;

  byte_data_mem #(`WORD_LEN, `MEM_TYPE_LOAD_STORE_BIT_NUM, `MEM_DEPTH) dut (
      .clk (CLK),
      .adr (ADR),
      .wd  (WD),
      .we  (WE),
      .size(MEM_SIZE),

      .rd(RD)
  );

  parameter PERIOD = 10;
  always begin
    CLK = 1'b0;
    #(PERIOD / 2) CLK = 1'b1;
    #(PERIOD / 2);
  end

  initial begin

    check_write_read_equal(`LDST_B);
    check_write_read_equal(`LDST_H);
    check_write_read_equal(`LDST_W);
    check_write_read_equal(`LDST_BU);
    check_write_read_equal(`LDST_HU);

    $finish;

  end

  int data, i, passed_num, failed_num;
  logic [`WORD_LEN-1:0] data_to_write;
  task check_write_read_equal(input [`MEM_TYPE_LOAD_STORE_BIT_NUM-1:0] task_mem_size);

    MEM_SIZE   = task_mem_size;
    passed_num = 0;
    failed_num = 0;
    $display("\nCheck Write/Read Equality, Mem size = %d\n", task_mem_size);
    for (i = 0; i < `MEM_DEPTH; i += (`WORD_LEN / `BYTE_WIDTH)) begin
      ADR = i;

      @(posedge CLK);
      #1;
      data = $urandom();  //returns 32 bit random

      case (task_mem_size)
        `LDST_B: begin
          data_to_write = {
            {(`WORD_LEN - `BYTE_WIDTH) {data[`BYTE_WIDTH-1]}}, data[`BYTE_WIDTH-1:0]
          };
        end

        `LDST_H: begin
          data_to_write = {
            {(`WORD_LEN / 2) {data[`WORD_LEN/2-1]}},
            data[`WORD_LEN/2-1:`BYTE_WIDTH],
            data[`BYTE_WIDTH-1:0]
          };
        end

        `LDST_W: begin
          data_to_write = data;
        end

        `LDST_BU: begin
          data_to_write = {{(`WORD_LEN - `BYTE_WIDTH) {1'b0}}, data[`BYTE_WIDTH-1:0]};
        end

        `LDST_HU: begin
          data_to_write = {
            {(`WORD_LEN / 2) {1'b0}}, data[`WORD_LEN/2-1:`BYTE_WIDTH], data[`BYTE_WIDTH-1:0]
          };
        end
        default: begin
          data_to_write = `WORD_LEN'b0;
        end
      endcase

      WD = data_to_write;
      WE = 1'b1;  // writing data
      @(posedge CLK);
      #1;

      WE = 1'b0;  //reading data
      if (RD === data_to_write) begin
        passed_num++;
        $display("PASSED: Write/Read correct: Addres = %d, Test data = %b, Read data = %b", i,
                 data_to_write, RD);
      end else begin
        failed_num++;
        $display("FAILED: Write/Read invalid: Addres = %d, Test data = %b, Read data = %b", i,
                 data_to_write, RD);
      end
    end
    $display("\nTotal PASSED num = %d, FAILED num = %d\n", passed_num, failed_num);
  endtask : check_write_read_equal

endmodule
