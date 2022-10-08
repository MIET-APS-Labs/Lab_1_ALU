`define WORD_LEN 32

//////////////////////////////////////////////
//  ALU Defines

`define ALU_OP_LEN 5
`define ALU_OP_NUM 16

// ALU op code format flag_sub_opcode


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

// Instuction format
// B[31]_C[30]_WS[29:28]_ALUop[27:23]_RA1[22:18]_RA2[17:13]_CONST[12:5]_WA[4:0]


//////////////////////////////////////////////
//  Instruction parts

`define INSTR_WA 4:0

`define INSTR_CONST 12:5
`define CONST_LEN 8

`define INSTR_RA2 17:13
`define INSTR_RA1 22:18

`define INSTR_ALUop 27:23

`define INSTR_WS 29:28

`define INSTR_C 30
`define INSTR_B 31


//////////////////////////////////////////////

