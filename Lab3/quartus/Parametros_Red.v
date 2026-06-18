`ifndef PARAM_RED
`define PARAM_RED

localparam
    ON   = 1'b1,
    OFF  = 1'b0,
    ZERO = 32'h00000000,

/* Operações da ULA */
    OPAND = 5'd0,
    OPOR  = 5'd1,
    OPADD = 5'd3,
    OPSUB = 5'd4,
    OPSLT = 5'd5,
    OPSLL = 5'd7,
    OPLUI = 5'd10,
	 OPNULL = 5'd31,

/* Opcodes */
    OPC_LOAD   = 7'b0000011, // lw
    OPC_OPIMM  = 7'b0010011, // addi, slli
    OPC_STORE  = 7'b0100011, // sw
    OPC_RTYPE  = 7'b0110011, // add, sub, and, or, slt, sll
    OPC_LUI    = 7'b0110111, // lui
    OPC_BRANCH = 7'b1100011, // beq
    OPC_JALR   = 7'b1100111, // jalr
    OPC_JAL    = 7'b1101111, // jal

/* Funct7 */
    FUNCT7_ADD = 7'b0000000,
    FUNCT7_SUB = 7'b0100000,
    FUNCT7_SLL = 7'b0000000,
    FUNCT7_SLT = 7'b0000000,
    FUNCT7_OR  = 7'b0000000,
    FUNCT7_AND = 7'b0000000,

/* Funct3 */
    FUNCT3_LW   = 3'b010,
    FUNCT3_SW   = 3'b010,

    FUNCT3_ADD  = 3'b000,
    FUNCT3_SUB  = 3'b000,
    FUNCT3_SLL  = 3'b001,
    FUNCT3_SLT  = 3'b010,
    FUNCT3_OR   = 3'b110,
    FUNCT3_AND  = 3'b111,

    FUNCT3_BEQ  = 3'b000,
    FUNCT3_JALR = 3'b000,

/* Endereços */
    BEGINNING_TEXT = 32'h0040_0000,
    TEXT_WIDTH     = 10 + 2,              // 1024 words = 4096 bytes
    END_TEXT       = BEGINNING_TEXT + 2**TEXT_WIDTH - 1,

    BEGINNING_DATA = 32'h1001_0000,
    DATA_WIDTH     = 10 + 2,              // 1024 words = 4096 bytes
    END_DATA       = BEGINNING_DATA + 2**DATA_WIDTH - 1,

    STACK_ADDRESS  = 32'h1001_03FC,
    GLOBAL_POINTER = 32'h1001_0000;

`endif