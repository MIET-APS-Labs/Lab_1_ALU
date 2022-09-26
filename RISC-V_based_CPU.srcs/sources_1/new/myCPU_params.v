`define WORD_LEN 32

//////////////////////////////////////////////
//  ALU Defines

`define ALU_OP_LEN 5
`define ALU_OP_NUM 16

//  ALU op codes
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

//  SIMD op codes
`define SIMD_ADD 5'b01001	
`define SIMD_SUB 5'b01010	

//  SIMD Rules
`define SIMD_OPERAND_DIGIT 16
`define SIMD_OPERAND_NUM 2
/////////////////////////////////////////////

//////////////////////////////////////////////
//  Register File Defines

`define RF_WIDTH 32
//////////////////////////////////////////////

//////////////////////////////////////////////
//  Instruction ROM Defines

`define INSTR_WIDTH 32
`define INSTR_DEPTH 64
//////////////////////////////////////////////