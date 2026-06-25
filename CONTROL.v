`ifndef PARAM_RED
    `include "../Parametros_Red.v"
`endif

module CONTROL(
    input  logic [31:0] iInstr,
    input  logic        iRst,
    input  logic        iClk,

    output logic        oRegWrite,
    output logic        oMemWrite,
    output logic        oMemRead,
    output logic        EscrevePCCond,
    output logic        EscrevePC,
    output logic        IouD,
    output logic        EscreveIR,
    output logic        EscrevePCB,
    output logic [1:0]  OrigAULA,
    output logic [1:0]  OrigBULA,
    output logic [1:0]  oMem2Reg,
    output logic [1:0]  oOrigPC,
    output logic [4:0]  oALUControl,
    output logic [3:0]  oEstado
);

	 logic [6:0] Opcode;
    logic [2:0] Funct3;
    logic [6:0] Funct7;

    assign Opcode = iInstr[6:0];
    assign Funct3 = iInstr[14:12];
    assign Funct7 = iInstr[31:25];

	 logic [3:0] state;
	 logic [3:0] nextState;
	 
   // =========================
   // Estágio Sequencial
   // =========================	
	always @(posedge iClk or posedge iRst) begin
		if(iRst)
			state <= ST_FETCH;
		else
			state <= nextState;
	end
	
   // =========================
   // Transição de Estados
   // =========================
	always @(*) begin
		case (state)
			ST_FETCH:   nextState = ST_FETCH1;	
			ST_FETCH1:  nextState = ST_DECODE;
			ST_DECODE: begin
				case (Opcode)
					OPC_STORE,
					OPC_LOAD:   nextState = ST_LWSW;
					OPC_RTYPE:  nextState = ST_RTYPE;
					OPC_BRANCH: nextState = ST_BEQ;
					OPC_JAL:    nextState = ST_JAL;
					OPC_OPIMM:  nextState = ST_IMMTYPE;
					OPC_JALR:   nextState = ST_JALR;
					OPC_LUI:    nextState = ST_LUI;
				endcase
			end
			ST_LWSW: begin
				case (Opcode)
					OPC_LOAD:   nextState = ST_LW;
					OPC_STORE:  nextState = ST_SW;
				endcase
			end
			ST_LW:      nextState = ST_LW1;
			ST_LW1:     nextState = ST_LW2;
			//ST_LW2:     nextState = ST_FETCH;
			ST_SW:      nextState = ST_SW1;
			//ST_SW1:     nextState = ST_FETCH;
			ST_RTYPE:   nextState = ST_RESC;
			//ST_RESC:    nextState = ST_FETCH;
			//ST_BEQ:     nextState = ST_FETCH;		
			//ST_JAL:     nextState = ST_FETCH;
			ST_IMMTYPE: nextState = ST_RESC;
			//ST_JALR:    nextState = ST_FETCH;
			//ST_LUI:     nextState = ST_FETCH;
			default:		nextState = ST_FETCH;
		endcase
	end

   // =================================
   // Definição dos Sinais de Controle
   // =================================	
	always @(*) begin
		case (state)
			ST_FETCH: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b1;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b1;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b1;
				EscrevePCB			= 1'b1;
				OrigAULA 			= 2'b10;
				OrigBULA 			= 2'b01;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_FETCH;
			end
			
			ST_FETCH1: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b1;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b1;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b1;
				EscrevePCB			= 1'b1;
				OrigAULA 			= 2'b10;
				OrigBULA 			= 2'b01;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_FETCH1;
			end
			
			ST_DECODE: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b10;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPNULL;
				oEstado				= ST_DECODE;				
			end
			ST_LWSW: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b01;
				OrigBULA 			= 2'b10;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_LWSW;
			end
			ST_LW: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b1;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b1;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_LW;
			end
			ST_LW1: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b1;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b1;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_LW1;
			end
			ST_LW2: begin
				oRegWrite 			= 1'b1;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b10;
				oOrigPC 				= 2'b00;
				oALUControl			= OPNULL;
				oEstado				= ST_LW2;
			end
			ST_SW: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b1;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b1;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPNULL;
				oEstado				= ST_SW;
			end
			ST_SW1: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b1;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b1;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPNULL;
				oEstado				= ST_SW1;
			end
			ST_RTYPE: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b01;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oEstado				= ST_RTYPE;
				case (Funct3)
                FUNCT3_ADD: begin
                    if (Funct7 == FUNCT7_SUB)
								oALUControl = OPSUB;
                    else
                        oALUControl = OPADD;
                end

                FUNCT3_SLL: begin
                    oALUControl = OPSLL;
                end

                FUNCT3_SLT: begin
                    oALUControl = OPSLT;
                end

                FUNCT3_OR: begin
                    oALUControl = OPOR;
                end

                FUNCT3_AND: begin
                    oALUControl = OPAND;
                end

                default: begin
                    oALUControl = OPNULL;
                end
            endcase
			end
			ST_RESC: begin
				oRegWrite 			= 1'b1;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPNULL;
				oEstado				= ST_RESC;
			end
			ST_BEQ: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b1;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b01;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b01;
				oALUControl			= OPSUB;
				oEstado				= ST_BEQ;
			end		
			ST_JAL: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b1;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b00;
				OrigBULA 			= 2'b00;
				oMem2Reg 			= 2'b01;
				oOrigPC 				= 2'b01;
				oALUControl			= OPNULL;
				oEstado				= ST_JAL;
			end
			ST_IMMTYPE: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b01;
				OrigBULA 			= 2'b10;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oEstado				= ST_IMMTYPE;
            case (Funct3)
                FUNCT3_ADD: begin
                    oALUControl = OPADD;
                end

                FUNCT3_SLL: begin
                    oALUControl = OPSLL;
                end

                default: begin
                    oALUControl = OPNULL;
                end
            endcase
			end
			ST_JALR: begin
				oRegWrite 			= 1'b0;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b1;
				IouD 					= 1'b1;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b01;
				OrigBULA 			= 2'b10;
				oMem2Reg 			= 2'b01;
				oOrigPC 				= 2'b01;
				oALUControl			= OPADD;
				oEstado				= ST_JALR;
			end
			ST_LUI: begin
				oRegWrite 			= 1'b1;
				oMemWrite 			= 1'b0;
				oMemRead  			= 1'b0;
				EscrevePCCond 		= 1'b0;
				EscrevePC 			= 1'b0;
				IouD 					= 1'b0;
				EscreveIR 			= 1'b0;
				EscrevePCB			= 1'b0;
				OrigAULA 			= 2'b11;
				OrigBULA 			= 2'b10;
				oMem2Reg 			= 2'b00;
				oOrigPC 				= 2'b00;
				oALUControl			= OPADD;
				oEstado				= ST_LUI;
			end
		endcase
	end
endmodule