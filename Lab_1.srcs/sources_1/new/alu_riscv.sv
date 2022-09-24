`timescale 1ns / 1ps


`define ADD 5'b00000
`define SUB 5'b01000
`define SLL 5'b00001
`define SLT 5'b00010
`define SLTU 5'b00011
`define XOR 5'b00100
`define SRL 5'b00101
`define SRA 5'b01101
`define OR 5'b00110
`define AND 5'b00111
`define BEQ 5'b11000
`define BNE 5'b11001
`define BLT 5'b11100
`define BGE 5'b11101
`define BLTU 5'b11110
`define BGEU 5'b11111

//  SIMD Commands
`define SIMD_ADD 5'b01001	
`define SIMD_SUB 5'b01010	

`define WORD_LEN 32


module alu_riscv (
    input wire [`WORD_LEN-1:0] A,
    input wire [`WORD_LEN-1:0] B,
    input wire [          4:0] ALUOp,

    output reg Flag,
    output reg [`WORD_LEN-1:0] Result
);

  wire [`WORD_LEN-1:0] adder_res;
  wire adder_carry_out;
  wire inverted_B;
  assign inverted_B = ((ALUOp == `SUB) | (ALUOp == `SLT) | (ALUOp == `BLT) | (ALUOp == `BGE));

  N_bit_full_adder #(`WORD_LEN) adder (
      .num1(A),
      .num2(inverted_B ? (~B + 1) : B),
      .carry_out(adder_carry_out),
      .result(adder_res)
  );

    SIMD_add #(`WORD_LEN) adder (
      .num1(A),
      .num2(inverted_B ? (~B + 1) : B),
      .carry_out(adder_carry_out),
      .result(adder_res)
  );



  always @* begin
    case (ALUOp)
      `ADD: begin
        Result = adder_res;
        Flag   = adder_carry_out;
      end

      `SUB: begin
        Result = adder_res;
        Flag   = 0;
      end

      `SLL: begin
        Result = (A << B);
        Flag   = 0;
      end

      `SLT: begin
        Result = adder_res[`WORD_LEN-1];
        Flag   = 0;
      end

      `SLTU: begin
        Result = (A < B);
        Flag   = 0;
      end

      `XOR: begin
        Result = (A ^ B);
        Flag   = 0;
      end

      `SRL: begin
        Result = (A >> B);
        Flag   = 0;
      end

      `SRA: begin
        Result = ($signed(A) >>> B);
        Flag   = 0;
      end

      `OR: begin
        Result = (A | B);
        Flag   = 0;
      end

      `AND: begin
        Result = (A & B);
        Flag   = 0;
      end

      `BEQ: begin
        Result = 0;
        Flag   = (A == B);
      end

      `BNE: begin
        Result = 0;
        Flag   = (A != B);
      end

      `BLT: begin
        Result = 0;
        Flag   = $signed(A < B);
      end

      `BGE: begin
        Result = 0;
        Flag   = $signed(A >= B);
      end

      `BLTU: begin
        Result = 0;
        Flag   = (A < B);
      end

      `BGEU: begin
        Result = 0;
        Flag   = (A >= B);
      end

      `SIMD_ADD: begin
        
      end

      `SIMD_SUB: begin
       
      end

      default: begin
        Result = 0;
        Flag   = 0;
      end
    endcase
  end
endmodule
