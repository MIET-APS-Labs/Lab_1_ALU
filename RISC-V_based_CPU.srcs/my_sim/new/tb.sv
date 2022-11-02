`timescale 1ns / 1ps

`define BYTE_WIDTH 8

`define WORD_LEN 32
`define DEPTH 10

module tb ();
  logic [`DEPTH-1:0][`BYTE_WIDTH-1:0] RAM;
  initial begin
    RAM = 80'hca_fe_fa_ce_ca_fe_fa_ce_ca_fe;

    $display("RAM = 0x%0h\n", RAM);

    for (int i = 0; i < $size(RAM); i++) begin  //through words
      $display("RAM[%0d] = %b (0x%0h)", i, RAM[i], RAM[i]);
    end
//    $display("\n");
//    for (int i = 0; i < $size(RAM); i++) begin  //through words
//      for (int j = 0; j < $size(RAM[i]); j++) begin  //through bytes
//        $display("RAM[%0d][%0d] = %b (0x%0h)", i, j, RAM[i][j], RAM[i][j]);
//      end
//    end
    $display("RAM[7:4] =  %b (0x%0h)\n", RAM[7:4], RAM[7:4]);
    $display("RAM[4][0] =  %b\n", RAM[4][0]);
    // for (int i = 0; i < $size(RAM); i++) begin  //through words
    //   for (int j = 0; j < $size(RAM[i]); j++) begin  //through bytes
    //     for (int k = 0; k < $size(RAM[i][j]); k++) begin  //through bits
    //       $display("RAM[%0d][%0d][%0d] = %b (0x%0h)", i, j, k, RAM[i][j][k], RAM[i][j][k]);
    //     end
    //   end
    // end

  end
endmodule
