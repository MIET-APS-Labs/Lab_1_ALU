`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// ALU based on RISC-V, extended with simple SIMD commands
//////////////////////////////////////////////////////////////////////////////////

// ALU op code format flag_sub_opcode
`define ADD 5'b 00000
`define SUB 5'b 01000

`define SLT 5'b 01001
`define SLTU 5'b 01010

`define SLL 5'b 00001
`define SRL 5'b 00011
`define SRA 5'b 00100

`define XOR 5'b 00101
`define OR 5'b 00110
`define AND 5'b 00111

`define BEQ 5'b 10000
`define BNE 5'b 10001
`define BLT 5'b 11000
`define BGE 5'b 11001
`define BLTU 5'b 11010
`define BGEU 5'b 11011

//  SIMD op codes
`define SIMD_ADD 5'b 10010	
`define SIMD_SUB 5'b 11100

module alu #(
    parameter WORD_LEN = 32,
    parameter ALU_OP_LEN = 5,
    parameter SIMD_OPERAND_NUM = 2,
    parameter SIMD_OPERAND_DIGIT = 16
) (
    input [  WORD_LEN-1:0] A,
    input [  WORD_LEN-1:0] B,
    input [ALU_OP_LEN-1:0] ALUOp,

    output reg Flag,
    output reg [WORD_LEN-1:0] Result
);

  logic [WORD_LEN-1:0] adder_res;
  logic adder_carry_out;

  N_bit_full_adder #(WORD_LEN) adder (
      .A  (A),
      .B  (B),
      .sub (ALUOp[ALU_OP_LEN-2]),

      .carry_out(adder_carry_out),
      .res(adder_res)
  );

  logic [SIMD_OPERAND_NUM-1:0] SIMD_carry;
  logic [WORD_LEN-1:0] SIMD_res;

  SIMD_add #(WORD_LEN, SIMD_OPERAND_DIGIT, SIMD_OPERAND_NUM) SIMD_adder (
      .vec1(A),
      .vec2(B),
      .sub (ALUOp[ALU_OP_LEN-2]),

      .carry_out(SIMD_carry),
      .res(SIMD_res)
  );

  always_comb begin
    case (ALUOp)
      `ADD: begin  // Add numbers
        Result = adder_res;
        Flag   = adder_carry_out;
      end

      `SUB: begin  // Substract numbers
        Result = adder_res;
        Flag   = 0;
      end

      `SLT: begin  // Set less then
        Result = adder_res[WORD_LEN-1];
        Flag   = 0;
      end

      `SLTU: begin  // Set less then unsigned
        Result = adder_res[WORD_LEN-1];
        Flag   = 0;
      end

      `SLL: begin  // Shift left logic
        Result = (A << B);
        Flag   = 0;
      end

      `SRL: begin  // Shift right logic
        Result = (A >> B);
        Flag   = 0;
      end

      `SRA: begin  // Shift right arithmetic
        Result = ($signed(A) >>> B);
        Flag   = 0;
      end

      `XOR: begin
        Result = (A ^ B);
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

      `BEQ: begin  // Branch equal
        Result = 0;
        Flag   = (A == B);
      end

      `BNE: begin  // Branch not equal
        Result = 0;
        Flag   = (A != B);
      end

      `BLT: begin  // Branch less then
        Result = 0;
        Flag   = adder_res[WORD_LEN-1];
      end

      `BGE: begin  // Branch greater equal
        Result = 0;
        Flag   = ~adder_res[WORD_LEN-1];
      end

      `BLTU: begin  // Branch less then unsigned
        Result = 0;
        Flag   = adder_res[WORD_LEN-1];
      end

      `BGEU: begin  // Branch greater equal unsigned
        Result = 0;
        Flag   = ~adder_res[WORD_LEN-1];
      end

      `SIMD_ADD: begin
        Result = SIMD_res;
        Flag   = 0;
      end

      `SIMD_SUB: begin
        Result = SIMD_res;
        Flag   = 0;
      end

      default: begin
        Result = 0;
        Flag   = 0;
      end
    endcase
  end
endmodule
