`ifndef PARAM_RED
    `include "../Parametros_Red.v"
`endif

module Control_UNI(
    input  logic [31:0] iInstr,
 
    output logic        oBranch,
    output logic        ALUSrc,
    output logic        oRegWrite,
    output logic        oMemWrite,
    output logic        oMemRead,
    output logic [1:0] oMem2Reg,
    output logic [1:0]  oOrigPC,
    output logic [4:0]  oALUControl
);

    logic [6:0] Opcode;
    logic [2:0] Funct3;
    logic [6:0] Funct7;

    assign Opcode = iInstr[6:0];
    assign Funct3 = iInstr[14:12];
    assign Funct7 = iInstr[31:25];

  always @(*)
    case (Opcode)

        OPC_LOAD: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b1;
            oRegWrite   = 1'b1;
            oMemWrite   = 1'b0;
            oMemRead    = 1'b1;
            oMem2Reg    = 2'b01;
            oOrigPC     = 2'b00;
            oALUControl = OPADD;
        end

        OPC_STORE: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b1;
            oRegWrite   = 1'b0;
            oMemWrite   = 1'b1;
            oMemRead    = 1'b0;
            oMem2Reg    = 2'b00;
            oOrigPC     = 2'b00;
            oALUControl = OPADD;
        end

        OPC_OPIMM: begin
            oBranch   = 1'b0;
            ALUSrc    = 1'b1;
            oMemWrite = 1'b0;
            oMemRead  = 1'b0;
            oMem2Reg  = 2'b00;
            oOrigPC   = 2'b00;

            case (Funct3)
                FUNCT3_ADD: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPADD;
                end

                FUNCT3_SLL: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPSLL;
                end

                default: begin
                    oRegWrite   = 1'b0;
                    oALUControl = OPNULL;
                end
            endcase
        end

        OPC_RTYPE: begin
            oBranch   = 1'b0;
            ALUSrc    = 1'b0;
            oMemWrite = 1'b0;
            oMemRead  = 1'b0;
            oMem2Reg  = 2'b00;
            oOrigPC   = 2'b00;

            case (Funct3)
                FUNCT3_ADD: begin
                    oRegWrite = 1'b1;
                    if (Funct7 == FUNCT7_SUB)
                        oALUControl = OPSUB;
                    else
                        oALUControl = OPADD;
                end

                FUNCT3_SLL: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPSLL;
                end

                FUNCT3_SLT: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPSLT;
                end

                FUNCT3_OR: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPOR;
                end

                FUNCT3_AND: begin
                    oRegWrite   = 1'b1;
                    oALUControl = OPAND;
                end

                default: begin
                    oRegWrite   = 1'b0;
                    oALUControl = OPNULL;
                end
            endcase
        end

       OPC_BRANCH: begin
			oBranch     = 1'b1;
			ALUSrc      = 1'b0;
			oRegWrite   = 1'b0;
			oMemWrite   = 1'b0;
			oMemRead    = 1'b0;
			oMem2Reg    = 2'b00;
			oOrigPC     = 2'b11;
			oALUControl = OPSUB;
	end

        OPC_LUI: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b1;
            oRegWrite   = 1'b1;
            oMemWrite   = 1'b0;
            oMemRead    = 1'b0;
            oMem2Reg    = 2'b00;
            oOrigPC     = 2'b00;
            oALUControl = OPLUI;
        end

        OPC_JAL: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b0;
            oRegWrite   = 1'b1;
            oMemWrite   = 1'b0;
            oMemRead    = 1'b0;
            oMem2Reg    = 2'b01;
            oOrigPC     = 2'b01;
            oALUControl = OPADD;
        end

        OPC_JALR: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b1;
            oRegWrite   = 1'b1;
            oMemWrite   = 1'b0;
            oMemRead    = 1'b0;
            oMem2Reg    = 2'b10;
            oOrigPC     = 2'b10;
            oALUControl = OPADD;
        end

        default: begin
            oBranch     = 1'b0;
            ALUSrc      = 1'b0;
            oRegWrite   = 1'b0;
            oMemWrite   = 1'b0;
            oMemRead    = 1'b0;
            oMem2Reg    = 1'b0;
            oOrigPC     = 2'b00;
            oALUControl = OPNULL;
        end

    endcase

endmodule