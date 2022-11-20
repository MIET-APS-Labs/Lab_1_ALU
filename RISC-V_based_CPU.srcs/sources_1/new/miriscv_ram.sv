module miriscv_ram #(
    parameter RAM_SIZE      = 256,  // WORDS
    parameter RAM_INIT_FILE = ""
) (
    // clock, reset
    input clk_i,
    input rst_n_i,

    // instruction memory interface
    output logic [`WORD_LEN-1:0] instr_rdata_o,
    input        [`WORD_LEN-1:0] instr_addr_i,

    // data memory interface
    output logic [`WORD_LEN-1:0] data_rdata_o,
    input                        data_req_i,
    input                        data_we_i,
    input        [          3:0] data_be_i,
    input        [`WORD_LEN-1:0] data_addr_i,
    input        [`WORD_LEN-1:0] data_wdata_i
);

  reg [`WORD_LEN-1:0]    RAM [0:RAM_SIZE-1];

  //Init RAM
  integer ram_index;

  initial begin
    if (RAM_INIT_FILE != "") begin
      $readmemh(RAM_INIT_FILE, RAM);
    end else begin
      for (ram_index = 0; ram_index < RAM_SIZE / 4 - 1; ram_index = ram_index + 1) begin
        RAM[ram_index] = {32{1'b0}};
      end
    end
  end

  parameter ADDR_SHIFT_LEN = $clog2(`WORD_LEN / `BYTE_WIDTH);

  //Instruction port
  assign instr_rdata_o = RAM[(instr_addr_i%RAM_SIZE)>>ADDR_SHIFT_LEN];

  logic [`WORD_LEN-1:0] word_addressable_address;
  assign word_addressable_address = (data_addr_i % RAM_SIZE) >> ADDR_SHIFT_LEN;

  always @(posedge clk_i) begin
    if (!rst_n_i) begin
      data_rdata_o <= 32'b0;
    end else if (data_req_i) begin
      data_rdata_o <= RAM[word_addressable_address];

      if (data_we_i && data_be_i[0]) RAM[word_addressable_address][7:0] <= data_wdata_i[7:0];

      if (data_we_i && data_be_i[1]) RAM[word_addressable_address][15:8] <= data_wdata_i[15:8];

      if (data_we_i && data_be_i[2]) RAM[word_addressable_address][23:16] <= data_wdata_i[23:16];

      if (data_we_i && data_be_i[3])
        RAM[word_addressable_address][`WORD_LEN-1:24] <= data_wdata_i[`WORD_LEN-1:24];

    end
  end


endmodule
