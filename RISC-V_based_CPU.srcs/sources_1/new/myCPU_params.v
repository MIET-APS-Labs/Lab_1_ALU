`define WORD_LEN 32

//////////////////////////////////////////////
//  ALU Defines

`define ALU_OP_LEN 5
`define ALU_OP_NUM 16

// ALU op code format flag_sub_opcode
`define ADD 5'b 00000
`define SUB 5'b 01000

// comparisons
`define SLT 5'b 01001
`define SLTU 5'b 01010

// shifts
`define SLL 5'b 00001
`define SRL 5'b 00011
`define SRA 5'b 00100

// logic

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


//////////////////////////////////////////////
//  CYBERcobra 3000 Pro 2.0 Instuction format
// B[31] C[30] WS[29:28] ALUop[27:23] RA1[22:18] RA2[17:13] CONST[12:5] WA[4:0]

`define C_COBRA_INSTR_WA 4:0

`define C_COBRA_INSTR_CONST 12:5
`define CONST_LEN 8

`define C_COBRA_INSTR_RA2 17:13
`define C_COBRA_INSTR_RA1 22:18

`define C_COBRA_INSTR_ALUop 27:23

`define C_COBRA_INSTR_WS_2 28
`define C_COBRA_INSTR_WS_1 29
`define C_COBRA_INSTR_WS 29:28

`define C_COBRA_INSTR_C 30
`define C_COBRA_INSTR_B 31


//////////////////////////////////////////////

