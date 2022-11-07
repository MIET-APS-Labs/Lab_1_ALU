`timescale 1ns / 1ps

`define BYTE_WIDTH 8

module instr_rom #(
    parameter WORD_LEN = 32,
    parameter DEPTH = 64,
    parameter INIT_FILE = ""
) (
    input  [WORD_LEN-1:0] adr,
    output [WORD_LEN-1:0] rd
);

  logic [WORD_LEN-1:0] ROM[0:DEPTH-1];

  logic [`WORD_LEN-1:0] shifted_adr;
  assign shifted_adr = adr >> $clog2(WORD_LEN / `BYTE_WIDTH);

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
          ROM[rom_index] = {`WORD_LEN{1'b0}};
      end

    end
  endgenerate

  parameter CORRECTED_ADR_LEN = $clog2(DEPTH);
  assign rd = ROM[shifted_adr[CORRECTED_ADR_LEN-1:0]];
endmodule
