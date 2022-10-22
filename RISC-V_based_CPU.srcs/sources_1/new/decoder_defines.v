// opcodes

`define OP_OPCODE 5'b01_100

`define OP_FUNCT_3_ADD_SUB 1'h0
`define OP_FUNCT_3_XOR 1'h4
`define OP_FUNCT_3_OR 1'h6
`define OP_FUNCT_3_AND 1'h7
`define OP_FUNCT_3_SLL 1'h1
`define OP_FUNCT_3_SRL_SRA 1'h5
`define OP_FUNCT_3_SLT 1'h2
`define OP_FUNCT_3_SLTU 1'h3

`define OP_FUNCT_7_ADD 2'h00
`define OP_FUNCT_7_SUB 2'h20
`define OP_FUNCT_7_XOR 2'h00
`define OP_FUNCT_7_OR 2'h00
`define OP_FUNCT_7_AND 2'h00
`define OP_FUNCT_7_SLL 2'h00
`define OP_FUNCT_7_SRL 2'h00
`define OP_FUNCT_7_SRA 2'h20
`define OP_FUNCT_7_SLT 2'h00
`define OP_FUNCT_7_SLTU 2'h00


`define OP_IMM_OPCODE 5'b00_100

`define OP_IMM_FUNCT_3_ADDI 1'h0
`define OP_IMM_FUNCT_3_XORI 1'h4
`define OP_IMM_FUNCT_3_ORI 1'h6
`define OP_IMM_FUNCT_3_ANDI 1'h7
`define OP_IMM_FUNCT_3_SLLI 1'h1
`define OP_IMM_FUNCT_3_SRLI 1'h5
`define OP_IMM_FUNCT_3_SRAI 1'h5
`define OP_IMM_FUNCT_3_SLTI 1'h2
`define OP_IMM_FUNCT_3_SLTIU 1'h3

`define OP_IMM_FUNCT_7_SLLI 2'h00
`define OP_IMM_FUNCT_7_SRLI 2'h00
`define OP_IMM_FUNCT_7_SRAI 2'h20


`define LUI_OPCODE 5'b01_101


`define LOAD_OPCODE 5'b00_000

`define LOAD_FUNCT_3_LB 1'h0
`define LOAD_FUNCT_3_LH 1'h1
`define LOAD_FUNCT_3_LW 1'h2
`define LOAD_FUNCT_3_LBU 1'h4
`define LOAD_FUNCT_3_LHU 1'h5


`define STORE_OPCODE 5'b01_000

`define STORE_FUNCT_3_SB 1'h0
`define STORE_FUNCT_3_SH 1'h1
`define STORE_FUNCT_3_SW 1'h2


`define BRANCH_OPCODE 5'b11_000

`define BRANCH_FUNCT_3_BEQ 1'h0
`define BRANCH_FUNCT_3_BNE 1'h1
`define BRANCH_FUNCT_3_BLT 1'h4
`define BRANCH_FUNCT_3_BGE 1'h5
`define BRANCH_FUNCT_3_BLTU 1'h6
`define BRANCH_FUNCT_3_BGEU 1'h7


`define JAL_OPCODE 5'b11_011


`define JALR_OPCODE 5'b11_001
`define JALR_FUNCT_3_SLTU 1'h0


`define AUIPC_OPCODE 5'b00_101


`define MISC_MEM_OPCODE 5'b00_011


`define SYSTEM_OPCODE 5'b11_100

// dmem type load store
`define LDST_B 3'b000
`define LDST_H 3'b001
`define LDST_W 3'b010
`define LDST_BU 3'b100
`define LDST_HU 3'b101

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