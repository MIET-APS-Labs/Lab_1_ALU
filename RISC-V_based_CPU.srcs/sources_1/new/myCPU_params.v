`define WORD_LEN 32

`define RESET_ADDR 32'h00000000

`define PC_NEXT_INSTR_INCREASE 4

//////////////////////////////////////////////
//  ALU Defines

`define ALU_OP_LEN 5
`define ALU_OP_NUM 16

// ALU op code format flag_sub_opcode
`define ALU_ADD 5'b 00000
`define ALU_SUB 5'b 01000

// comparisons
`define ALU_SLT 5'b 01001
`define ALU_SLTU 5'b 01010

// shifts
`define ALU_SLL 5'b 00001
`define ALU_SRL 5'b 00011
`define ALU_SRA 5'b 00100

// logic

`define ALU_XOR 5'b 00101
`define ALU_OR 5'b 00110
`define ALU_AND 5'b 00111

`define ALU_BEQ 5'b 10000
`define ALU_BNE 5'b 10001
`define ALU_BLT 5'b 11000
`define ALU_BGE 5'b 11001
`define ALU_BLTU 5'b 11010
`define ALU_BGEU 5'b 11011

//  SIMD op codes
`define ALU_SIMD_ADD 5'b 10010	
`define ALU_SIMD_SUB 5'b 11100

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


//////////////////////////////////////////////
// RISC-V Instuction format

`define INSTR_OPCODE 6:3
`define INSTR_INSTR_LEN 2:0

`define INSTR_LEN 2'b11

// R-type instruction format
// funct7[31:25] rs2[24:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
`define R_TYPE_FUNCT_7 31:25
`define R_TYPE_RS_2 24:20
`define R_TYPE_RS_1 19:15
`define R_TYPE_FUNCT_3 14:12
`define R_TYPE_RD 11:7

// I-type instruction format
// imm[31:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
`define I_TYPE_IMM_LEN 12
`define I_TYPE_IMM 31:20
`define I_TYPE_RS_1 19:15
`define I_TYPE_FUNCT_3 14:12
`define I_TYPE_ALT_FUNCT_7 31:25
`define I_TYPE_RD 11:7

// S-type instruction format
// imm[11:5]_[31:25] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:0]_[11:7] opcode[6:0]
`define S_TYPE_IMM_11_5_LEN 7
`define S_TYPE_IMM_11_5 31:25
`define S_TYPE_RS_2 24:20
`define S_TYPE_RS_1 19:15
`define S_TYPE_FUNCT_3 14:12
`define S_TYPE_IMM_4_0_LEN 5
`define S_TYPE_IMM_4_0 11:7

// B-type instruction format
// imm[12|10:5]_[31:25] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:1|11]_[11:7] opcode[6:0]
`define B_TYPE_IMM_LEN 13
`define B_TYPE_IMM_12 31
`define B_TYPE_IMM_10_5 30:25
`define B_TYPE_RS_2 24:20
`define B_TYPE_RS_1 19:15
`define B_TYPE_FUNCT_3 14:12
`define B_TYPE_IMM_4_1 11:8
`define B_TYPE_IMM_11 7

// U-type instruction format
// imm[31:12]_[31:12] rd[11:7] opcode[6:0]
`define U_TYPE_IMM_31_12_LEN 20
`define U_TYPE_IMM_31_12 31:12
`define U_TYPE_RD 11:7

// J-type instruction format
// imm[20|10:1|11|19:12]_[31:12] rd[11:7] opcode[6:0]
`define J_TYPE_IMM_LEN 20
`define J_TYPE_IMM_20 31
`define J_TYPE_IMM_10_1 30:21
`define J_TYPE_IMM_11 20
`define J_TYPE_IMM_19_12 19:12
`define J_TYPE_RD 11:7



//////////////////////////////////////////////
// MUX Cases
// operand a selection
`define OP_A_RS1 2'b00
`define OP_A_CURR_PC 2'b01
`define OP_A_ZERO 2'b10

// operand b selection
`define OP_B_RS2 3'b000
`define OP_B_IMM_I 3'b001
`define OP_B_IMM_U 3'b010
`define OP_B_IMM_S 3'b011
`define OP_B_INCR 3'b100

// writeback source selection
`define WB_EX_RESULT 1'b0
`define WB_LSU_DATA 1'b1

