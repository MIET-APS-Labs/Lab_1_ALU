`define SEGMENTS_NUM 7
`define DIGITS_NUM 8

module miriscv_top #(
    parameter RAM_SIZE      = 256,  // WORDS
    parameter RAM_INIT_FILE = ""
) (


    input CLK100MHZ,

    input [15:0] SW,

    input PS2_CLK,
    input PS2_DATA,

    output [15:0] LED,

    output [`SEGMENTS_NUM-1:0] C,
    output [  `DIGITS_NUM-1:0] AN

    // clock, reset
    // input clk_i,
    // input rst_n_i,

    // input  [`WORD_LEN-2:0] int_req_ext_i,  // INT 31 connected to PS/2 Keyboard valid data reg
    // output [`WORD_LEN-2:0] int_fin_ext_o,


    // input logic ps2_clk_i,
    // input logic ps2_data_i,

    // output core_prog_finished
);


  logic [`SEGMENTS_NUM-1:0] HEX_o;
  logic [`DIGITS_NUM-1:0] DIG_o;

  logic clk_i;
  logic rst_n_i;

  logic [`WORD_LEN-2:0] int_req_ext_i;  // INT 31 connected to PS/2 Keyboard valid data reg
  logic [`WORD_LEN-2:0] int_fin_ext_o;

  logic ps2_clk_i;
  logic ps2_data_i;

  logic core_prog_finished;

  assign clk_i = CLK100MHZ;

  assign C = HEX_o;
  assign AN = DIG_o;

  assign rst_n_i = SW[15];

  assign int_req_ext_i[5] = SW[5];

  assign LED[14:0] = int_fin_ext_o[14:0];
  assign LED[15] = core_prog_finished;

  assign ps2_clk_i = PS2_CLK;
  assign ps2_data_i = PS2_DATA;



  logic [31:0] instr_rdata_core;
  logic [31:0] instr_addr_core;

  logic [31:0] data_rdata_core;
  logic        data_req_core;
  logic        data_we_core;
  logic [31:0] data_addr;
  logic [31:0] data_wdata_core;

  logic [31:0] data_rdata_ram;
  logic        data_req_ram;
  logic        data_we_ram;
  logic [ 3:0] data_be_ram;
  logic [31:0] data_wdata;

  miriscv_core core (
      .clk_i(clk_i),
      .arstn_i(rst_n_i),
      .prog_finished(core_prog_finished),

      .instr_rdata (instr_rdata_core),
      .instr_addr_o(instr_addr_core),

      .data_rdata_i(data_rdata_core),
      .data_req_o  (data_req_core),
      .data_we_o   (data_we_core),
      .data_be_o   (data_be_ram),
      .data_addr_o (data_addr),
      .data_wdata_o(data_wdata),

      .mcause_i(mcause),
      .INT(INT),
      .mie_o(mie),
      .INT_RST(INT_RST)
  );


  logic [`RD_SEL_LEN-1:0] RDsel;
  logic we_led;
  logic we_keyboard;

  addr_decoder #(
      .RAM_SIZE(RAM_SIZE)
  ) my_addr_dec (
      .req_i (data_req_core),
      .we_i  (data_we_core),
      .addr_i(data_addr),

      .RDsel_o(RDsel),

      .req_m_o(data_req_ram),  //  memory control pins
      .we_m_o (data_we_ram),

      .we_d0_o(we_led),
      .we_d1_o(we_keyboard)
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
      .data_addr_i (data_addr),
      .data_wdata_i(data_wdata)
  );

  led_control led (
      .clk_200_i(clk_i),
      .wdata_i(data_wdata),
      .addr_i(data_addr),  // byte addressable
      .we_i(we_led),

      .HEX_o(HEX_o),
      .DIG_o(DIG_o)
  );

  logic keyboard_valid_data_int;

  ps2_keyboard_control ps2_keyboard (
      .clk_200_i(clk_i),

      .wdata_i(data_wdata),
      .addr_i(data_addr),  // byte addressable
      .we_i(we_keyboard),

      .ps2_clk_i (ps2_clk_i),
      .ps2_data_i(ps2_data_i),

      .valid_data_rst_i(int_fin_o[31]),

      .data_o(data_rdata_keyboard),

      .valid_data_int_o(keyboard_valid_data_int)
  );

  always_comb begin
    case (RDsel)
      `RDATA_MEM: begin
        data_rdata_core <= data_rdata_ram;
      end
      `RDATA_KEYBOARD: begin
        data_rdata_core <= data_rdata_keyboard;
      end
      default: begin
      end
    endcase

  end

  logic INT_RST;
  logic [`WORD_LEN-1:0] mie;
  logic [`WORD_LEN-1:0] mcause;
  logic INT;
  logic [`WORD_LEN-1:0] int_req_i;
  assign int_req_i = {keyboard_valid_data_int, int_req_ext_i};

  logic [`WORD_LEN-1:0] int_fin_o;
  assign int_fin_ext_o = int_fin_o[`WORD_LEN-2:0];
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
