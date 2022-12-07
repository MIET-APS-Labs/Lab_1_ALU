module miriscv_top #(
    parameter RAM_SIZE      = 256,  // WORDS
    parameter RAM_INIT_FILE = ""
) (
    // clock, reset
    input clk_i,
    input rst_n_i,

    input  [`WORD_LEN-1:0] int_req_i,
    output [`WORD_LEN-1:0] int_fin_o,

    output core_prog_finished
);

  logic [31:0] instr_rdata_core;
  logic [31:0] instr_addr_core;

  logic [31:0] data_rdata_core;
  logic        data_req_core;
  logic        data_we_core;
  logic [ 3:0] data_be_core;
  logic [31:0] data_addr_core;
  logic [31:0] data_wdata_core;

  logic [31:0] data_rdata_ram;
  logic        data_req_ram;
  logic        data_we_ram;
  logic [ 3:0] data_be_ram;
  logic [31:0] data_addr_ram;
  logic [31:0] data_wdata_ram;

  logic        data_mem_valid;
  assign data_mem_valid  = (data_addr_core >= RAM_SIZE) ? 1'b0 : 1'b1;

  assign data_rdata_core = (data_mem_valid) ? data_rdata_ram : 1'b0;
  assign data_req_ram    = (data_mem_valid) ? data_req_core : 1'b0;
  assign data_we_ram     = data_we_core;
  assign data_be_ram     = data_be_core;
  assign data_addr_ram   = data_addr_core;
  assign data_wdata_ram  = data_wdata_core;

  miriscv_core core (
      .clk_i(clk_i),
      .arstn_i(rst_n_i),
      .prog_finished(core_prog_finished),

      .instr_rdata (instr_rdata_core),
      .instr_addr_o(instr_addr_core),

      .data_rdata_i(data_rdata_core),
      .data_req_o  (data_req_core),
      .data_we_o   (data_we_core),
      .data_be_o   (data_be_core),
      .data_addr_o (data_addr_core),
      .data_wdata_o(data_wdata_core),

      .mcause_i(mcause),
      .INT(INT),
      .mie_o(mie),
      .INT_RST(INT_RST)
  );

  miriscv_ram #(
      .RAM_SIZE     (RAM_SIZE),
      .RAM_INIT_FILE(RAM_INIT_FILE)
  ) ram (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),

      .instr_rdata_o(instr_rdata_core),
      .instr_addr_i (instr_addr_core),

      .data_rdata_o(data_rdata_ram),
      .data_req_i  (data_req_ram),
      .data_we_i   (data_we_ram),
      .data_be_i   (data_be_ram),
      .data_addr_i (data_addr_ram),
      .data_wdata_i(data_wdata_ram)
  );

  logic INT_RST;
  logic [`WORD_LEN-1:0] mie;
  logic [`WORD_LEN-1:0] mcause;
  logic INT;

  int_ctrl my_interrupt (
      .clk_i  (clk_i),
      .arstn_i(rst_n_i),

      .INT_RST(INT_RST),  // reports that Interrupt handled

      .mie_i(mie),  // Machine interrup-enable register
      .int_req(int_req_i),  // Machine interrup-enable register

      .mcause_o(mcause),  // Machine trap cause
      .INT(INT),  // reports about Interrupt occurs and must be handled
      .int_fin(int_fin_o)
  );



endmodule
