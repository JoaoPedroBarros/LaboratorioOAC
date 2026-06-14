parameter
			OPPADD	= 4'b0010,
			OPSUB		= 4'b0110,
			OPAND		= 4'b0000,
			OPOR		= 4'b0001,
			OPSLT		= 4'b0111,
			FUNADD	= 10'b0000000_000,
			FUNSUB	= 10'b0100000_000,
			FUNAND	= 10'b0000000_111,
			FUNOR		= 10'b0000000_110,
			FUNSLT	= 10'b0000000_010;
			
			
module ALUControl(
			input 	[9:0] Funct10,
			input		[1:0] ALUOp,
			output	[3:0] ALUCtrl
			);
			
always @(*)
	case (ALUOp)
			2'b00: ALUCtrl 	<= OPADD;
			2'b01: ALUCtrl		<= OPSUB;
			2'b10:
				case (Funct10)
					FUNADD:	ALUCtrl	<= OPADD;
					FUNSUB:	ALUCtrl	<= OPSUB;
					FUNAND:	ALUCtrl	<= OPAND;
					FUNOR:	ALUCtrl	<= OPOR;
					FUNSLT:	ALUCtrl	<= OPSLT;
					default:	ALUCtrl	<= 4'b0000;
				endcase
	endcase
endmodule		