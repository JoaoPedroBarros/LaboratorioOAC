
`ifndef PARAM_RED
    `include "../Parametros_Red.v"
`endif

module RegisterFile(
	input wire clk,
	input wire reset,
	input wire RegWrite,
	input wire [4:0] disp,
	input wire [4:0] rs1,
	input wire [4:0] rs2,
	input wire [4:0] rd,
	input wire [31:0] WriteData,
	output wire [31:0] DispData,
	output wire [31:0] ReadData1,
	output wire [31:0] ReadData2

);

	reg [31:0] registers[31:0];
	integer i;
	
	assign ReadData1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
	assign ReadData2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];
	assign DispData = (disp == 5'b00000) ? 32'b0 : registers[disp];
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			for(i = 0; i < 32; i = i+1) begin
				registers[i] <= 32'b0;
			end
			registers[2] <= STACK_ADDRESS;
			registers[3] <= GLOBAL_POINTER;
			
		end else if(RegWrite && rd != 5'b00000) begin
			registers[rd] <= WriteData;
		end
	end

endmodule