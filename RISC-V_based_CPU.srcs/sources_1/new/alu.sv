`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// ALU based on RISC-V, extended with simple SIMD commands
//////////////////////////////////////////////////////////////////////////////////

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
      `ALU_ADD: begin  // Add numbers
        Result = adder_res;
        Flag   = adder_carry_out;
      end

      `ALU_SUB: begin  // Substract numbers
        Result = adder_res;
        Flag   = 0;
      end

      `ALU_SLT: begin  // Set less then
        Result = adder_res[WORD_LEN-1];
        Flag   = 0;
      end

      `ALU_SLTU: begin  // Set less then unsigned
        Result = adder_res[WORD_LEN-1];
        Flag   = 0;
      end

      `ALU_SLL: begin  // Shift left logic
        Result = (A << B);
        Flag   = 0;
      end

      `ALU_SRL: begin  // Shift right logic
        Result = (A >> B);
        Flag   = 0;
      end

      `ALU_SRA: begin  // Shift right arithmetic
        Result = ($signed(A) >>> B);
        Flag   = 0;
      end

      `ALU_XOR: begin
        Result = (A ^ B);
        Flag   = 0;
      end

      `ALU_OR: begin
        Result = (A | B);
        Flag   = 0;
      end

      `ALU_AND: begin
        Result = (A & B);
        Flag   = 0;
      end

      `ALU_BEQ: begin  // Branch equal
        Result = 0;
        Flag   = (A == B);
      end

      `ALU_BNE: begin  // Branch not equal
        Result = 0;
        Flag   = (A != B);
      end

      `ALU_BLT: begin  // Branch less then
        Result = 0;
        Flag   = adder_res[WORD_LEN-1];
      end

      `ALU_BGE: begin  // Branch greater equal
        Result = 0;
        Flag   = ~adder_res[WORD_LEN-1];
      end

      `ALU_BLTU: begin  // Branch less then unsigned
        Result = 0;
        Flag   = adder_res[WORD_LEN-1];
      end

      `ALU_BGEU: begin  // Branch greater equal unsigned
        Result = 0;
        Flag   = ~adder_res[WORD_LEN-1];
      end

      `ALU_SIMD_ADD: begin
        Result = SIMD_res;
        Flag   = 0;
      end

      `ALU_SIMD_SUB: begin
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
