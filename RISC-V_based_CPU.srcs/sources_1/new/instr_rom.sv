`timescale 1ns / 1ps

module instr_rom #(
    parameter WIDTH = 32,
    parameter DEPTH = 64,
    parameter INIT_FILE = ""
) (
    input [$clog2(DEPTH)-1:0] addr,
    output [WIDTH-1:0] rd
);
  logic [WIDTH-1:0] ROM[0:DEPTH-1];

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin : use_init_file
      initial begin
        $readmemb(INIT_FILE, ROM, 0, DEPTH - 1);
      end

    end else begin : init_bram_to_zero
      integer rom_index;
      initial begin
        for (rom_index = 0; rom_index < DEPTH; rom_index = rom_index + 1)
          ROM[rom_index] = {DEPTH{1'b0}};
      end

    end
  endgenerate

  assign rd = ROM[addr];
endmodule
