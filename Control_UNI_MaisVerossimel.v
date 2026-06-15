`ifndef PARAM
	`include "../Parametros_Red.v"
`endif

//*
// * Bloco de Controle UNICICLO
//		Ficar o mais idêntico possível ao esquema da diretriz
//		A ideia é que o bloco controlador fique separado,
//		Tenha o sinal de Branch,
//		A origem A da ULA não dependa do Controle,
//		OrigemB da ULA seja ALUSrc e tenha 1 bit só
//		Mem2Reg tenha 1 bit somente
// *
 

 module Control_UNI(
    input  [6:0]  iInstr, 
	 output			oBranch,
 	 output			oMemRead,
	 output 			oMem2Reg, 
	 output [1:0]	oALUOp,
 	 output			oMemWrite, 
	 output 			oALUSrc,
 	 output			oRegWrite

);

wire [6:0]  Opcode 	= iInstr[ 6: 0];
//wire [2:0]  Funct3	= iInstr[14:12];
//wire [6:0]  Funct7	= iInstr[31:25];	

always @(*)
	case(Opcode)
		OPC_LOAD:
			begin
				oBranch					<= 1'b0;			
				oMemRead 				<= 1'b1; 
				oMem2Reg 				<= 1'b1;
				oALUOp					<= 2'b00;
				oMemWrite				<= 1'b0;
				oALUSrc					<= 1'b1;
				oRegWrite				<= 1'b1;
			end
			
		OPC_OPIMM:
			begin
				oBranch					<= 1'b0;
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 1'b0;
				//oALUOp					<=	
				oMemWrite				<= 1'b0;
				oALUSrc	 				<= 1'b1;
				oRegWrite				<= 1'b1;

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
							oOrigAULA  				<= 2'b00;
							oOrigBULA 				<= 2'b00;
							oRegWrite				<= 1'b0;
							oMemWrite				<= 1'b0; 
							oMemRead 				<= 1'b0; 
							oALUControl				<= OPNULL;
							oMem2Reg 				<= 3'b000;
						end
				endcase
			end
			
		OPC_AUIPC:
			begin
				oBranch					<= 1'b0;		
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 1'b0;
				oALUOp					<=	2'b00;
				oMemWrite				<= 1'b0; 
				oALUSrc 					<= 1'b1;
				oRegWrite				<= 1'b1;
			end
			
		OPC_STORE:
			begin
				oBranch					<= 1'b0;			
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 1'b0;
				oALUOp					<= 2'b00;
				oMemWrite				<= 1'b1;
				oALUSrc					<= 1'b1;
				oRegWrite				<= 1'b0;
			end
		
		OPC_RTYPE:
			begin
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b00;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oMem2Reg 				<= 3'b000;
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
									oOrigAULA  				<= 2'b00;
									oOrigBULA 				<= 2'b00;
									oRegWrite				<= 1'b0;
									oMemWrite				<= 1'b0; 
									oMemRead 				<= 1'b0; 
									oALUControl				<= OPNULL;
									oMem2Reg 				<= 3'b000;
								end
						endcase
				endcase
			end
		OPC_LUI:
			begin
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b01;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPLUI;
				oMem2Reg 				<= 3'b000;
			end
			
		OPC_BRANCH:
			begin
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b00;
				oRegWrite				<= 1'b0;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b000;
			end
			
		OPC_JALR:
			begin	
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b00;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b001;
			end
		
		OPC_JAL:
			begin
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b00;
				oRegWrite				<= 1'b1;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPADD;
				oMem2Reg 				<= 3'b001;
			end
			      
		default: // instrucao invalida
        begin
				oOrigAULA  				<= 2'b00;
				oOrigBULA 				<= 2'b00;
				oRegWrite				<= 1'b0;
				oMemWrite				<= 1'b0; 
				oMemRead 				<= 1'b0; 
				oALUControl				<= OPNULL;
				oMem2Reg 				<= 3'b000;
        end
		  
	endcase

endmodule
