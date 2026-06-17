module Uniciclo (
    input  logic        clockCPU, clockMem,
    input  logic        reset,
    output logic [31:0] PC,
    output logic [31:0] Instr,
    input  logic [4:0]  regin,
    output logic [31:0] regout
);

    logic EscreveMem;
    logic Zero;
    logic RegWrite;
    logic Branch;
    logic ALUScr;
    logic MemRed;
    logic BranchZero;

    logic [1:0] Mem2Reg;
    logic [1:0] OrigPC;

    logic [31:0] SaidaULA;
    logic [31:0] ReadData1;
    logic [31:0] ReadData2;
    logic [31:0] ReadData;
    logic [31:0] WriteData;
    logic [31:0] SaidaImediato;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] Instrucao;

    logic [4:0] ALUOp;

    logic [31:0] PCmais4;
    logic [31:0] PCBranch;
    logic [31:0] PCJalr;
    logic [31:0] PCNext;

    assign PCmais4  = PC + 32'd4;
    assign PCBranch = PC + SaidaImediato;
    assign PCJalr   = (ReadData1 + SaidaImediato) & (!1);
	 assign BranchZero = Branch & Zero;


    always @(*) begin
        case (OrigPC)
            2'b00: PCNext = PCmais4;
				2'b01:
					case(BranchZero)
						1'b0: PCNext = PCmais4;
						1'b1: PCNext = PCBranch;
					endcase	
            2'b10: PCNext = PCJalr;
            default: PCNext = PCmais4;
        endcase
    end

    always @(posedge clockCPU or posedge reset) begin
        if (reset)
            PC <= 32'h0040_0000;
        else
            PC <= PCNext;
    end

    ramI MemC (
        .address(PC[11:2]),
        .clock(clockMem),
        .data(32'b0),
        .wren(1'b0),
        .q(Instr)
    );

    ramD MemD (
        .address(SaidaULA[11:2]),
        .clock(clockMem),
        .data(ReadData2),
        .wren(EscreveMem),
        .q(ReadData)
    );

    ULA ULA_inst (
        .A(A),
        .B(B),
        .ALUControl(ALUOp),
        .Result(SaidaULA),
        .Zero(Zero)
    );

    ImmGen GeraImm (
        .iInstrucao(Instrucao),
        .oImm(SaidaImediato)
    );

    RegisterFile BancoReg (
        .clk(clockCPU),
        .reset(reset),
        .RegWrite(RegWrite),
        .disp(regin),
        .rs1(Instrucao[19:15]),
        .rs2(Instrucao[24:20]),
        .rd(Instrucao[11:7]),
        .WriteData(WriteData),
        .DispData(regout),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    Control_UNI BlocoControle (
        .iInstr(Instrucao),
        .iBranchZero(BranchZero),
        .oBranch(Branch),
        .ALUSrc(ALUScr),
        .oRegWrite(RegWrite),
        .oMemWrite(EscreveMem),
        .oMemRead(MemRed),
        .oMem2Reg(Mem2Reg[1:0]),
        .oOrigPC(OrigPC[1:0]),
        .oALUControl(ALUOp)
    );

    always @(*) begin
        case (Mem2Reg)
            2'b00: WriteData = SaidaULA;
            2'b01: WriteData = ReadData;
            2'b10: WriteData = PCmais4;
            default: WriteData = 32'b0;
        endcase
    end

    always @(*) begin
        case (ALUScr)
            1'b0: B = ReadData2;
            1'b1: B = SaidaImediato;
            default: B = 32'b0;
        endcase
    end

endmodule