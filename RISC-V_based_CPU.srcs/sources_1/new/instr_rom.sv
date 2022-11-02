`timescale 1ns / 1ps

`define BYTE_WIDTH 8

module instr_rom #(
    parameter WORD_LEN = 32,
    parameter DEPTH = 512,
    parameter INIT_FILE = ""
) (
    input [$clog2(DEPTH)-1:0] adr,
    output [WORD_LEN-1:0] rd
);

  // use a 2-dimensional packed array
  //to model individual bytes
  logic [`BYTE_WIDTH-1:0] ROM[DEPTH-1:0];

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin : use_init_file
      initial begin
        $readmemh(INIT_FILE, ROM);
      end

    end else begin : init_bram_to_zero
      integer rom_index;
      initial begin
        for (rom_index = 0; rom_index < DEPTH; rom_index = rom_index + 1)
          ROM[rom_index] = {`BYTE_WIDTH{1'b0}};
      end

    end
  endgenerate

  parameter WORD_BYTE_LEN = WORD_LEN / `BYTE_WIDTH;
  logic [0:WORD_BYTE_LEN-1][`BYTE_WIDTH-1:0] word_o;
  generate
    genvar iter_w_o;
    for (iter_w_o = 0; iter_w_o < WORD_BYTE_LEN; iter_w_o++) begin
      assign word_o[iter_w_o] = ROM[adr+iter_w_o];
    end
  endgenerate

  assign rd = word_o;
endmodule
