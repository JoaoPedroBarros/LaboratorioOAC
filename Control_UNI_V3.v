`ifndef PARAM
	`include "../Parametros_Red.v"
`endif

//*
// * Bloco de Controle UNICICLO
//		"podado", com sinal oBranch acrescentado e Controlador da ULA unificado
//		Sem definição OrigAULA
//		Todas as saídas, exceto oALUControl com 1 bit somente
//		
// *
 

 module Control_UNI(
    input  [6:0]  iInstr, 
	 output			oBranch,
	 output 			ALUSrc, 
	 output			oRegWrite, 
	 output			oMemWrite, 
	 output			oMemRead,
	 output 			oMem2Reg, 
	 output [4:0]  oALUControl
);

wire [6:0]  Opcode 	= iInstr[ 6: 0];
wire [2:0]  Funct3	= iInstr[14:12];
wire [6:0]  Funct7	= iInstr[31:25];	

always @(*)
	case(Opcode)
		OPC_LOAD:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b1;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b1; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b010;
			end
			
		OPC_OPIMM:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b1;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 1'b0;
				case (Funct3)
					FUNCT3_ADD:			oALUControl <= OPADD;
					FUNCT3_SLL:			oALUControl <= OPSLL;
					FUNCT3_SLT:			oALUControl <= OPSLT;
					FUNCT3_SLTU:		oALUControl	<= OPSLTU;
					FUNCT3_SRL:			oALUControl <= OPSRL;
					FUNCT3_OR:			oALUControl <= OPOR;
					FUNCT3_AND:			oALUControl <= OPAND;			
				
					default: // instrucao invalida
						begin
							oBranch					<= 1'b0;
							ALUSrc 					<= 1'b0;
							oRegWrite				<= 1'b0;
							oMemWrite				<= 1'b0; 
							oMemRead 				<= 1'b0; 
							oALUControl				<= OPNULL;
							oMem2Reg 				<= 1'b0;
						end
				endcase
			end
			
		OPC_STORE:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b1;
				oRegWrite				<= 1'b0;
				oMemWrite				<= 1'b1; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 1'b0;
			end
		
		OPC_RTYPE:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b0;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 1'b0;
				case (Funct7)
					FUNCT7_ADD,  // ou qualquer outro 7'b0000000
					FUNCT7_SUB:	 // SUB ou SRA			
						case (Funct3)
							FUNCT3_ADD,
							FUNCT3_SUB:
								if(Funct7==FUNCT7_SUB)   oALUControl <= OPSUB;
								else 							 oALUControl <= OPADD;
							FUNCT3_SLL:			oALUControl <= OPSLL;
							FUNCT3_SLT:			oALUControl <= OPSLT;
							FUNCT3_SLTU:		oALUControl	<= OPSLTU;
							FUNCT3_SRL:			oALUControl <= OPSRL;
							FUNCT3_OR:			oALUControl <= OPOR;
							FUNCT3_AND:			oALUControl <= OPAND;			
							default: // instrucao invalida
								begin
									ALUSrc 					<= 1'b0;
									oRegWrite				<= 1'b0;
									oMemWrite				<= 1'b0; 
									oMemRead 				<= 1'b0; 
									oALUControl				<= OPNULL;
									oMem2Reg 				<= 1'b0;
								end
						endcase
				endcase
			end
		OPC_LUI:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b1;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPLUI;
				oMem2Reg 				<= 1'b0;
			end
			
		OPC_BRANCH:
			begin
				oBranch					<= 1'b1;
				ALUSrc 					<= 1'b0;
				oRegWrite				<= 1'b0;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 1'b0;
			end
			
		OPC_JALR:
			begin	
				oBranch					<= 1'b0;
				ALUSrc 				<= 1'b0;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b001;
			end
		
		OPC_JAL:
			begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b0;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b001;
			end
			      
		default: // instrucao invalida
        begin
				oBranch					<= 1'b0;
				ALUSrc 					<= 1'b0;
				oRegWrite				<= 1'b0;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPNULL;
				oMem2Reg 				<= 1'b0;
        end
		  
	endcase

endmodule
