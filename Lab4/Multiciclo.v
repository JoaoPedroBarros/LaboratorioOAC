module Multiciclo (
    input  logic        clockCPU, clockMem,
    input  logic        reset,
    output logic [31:0] PC,
    output logic [31:0] Instr,
    input  logic [4:0]  regin,
    output logic [31:0] regout,
    output logic [3:0]  estado
);

    // Controle
    logic RegWrite;
    logic EscreveMem;
    logic LeMem;
    logic EscrevePCCond;
    logic EscrevePC;
    logic IouD;
    logic EscreveIR;
    logic EscrevePCB;

    logic [1:0] OrigAULA;
    logic [1:0] OrigBULA;
    logic [1:0] Mem2Reg;
    logic [1:0] OrigPC;
    logic [4:0] ALUControl;

    // Datapath
    logic Zero;
    logic PCWrite;

    logic [31:0] IR;
    logic [31:0] MDR;
    logic [31:0] A;
    logic [31:0] B;
    logic [31:0] PCBack;

    logic [31:0] ReadData1;
    logic [31:0] ReadData2;
    logic [31:0] WriteData;

    logic [31:0] SaidaImediato;
    logic [31:0] ALUA;
    logic [31:0] ALUB;
    logic [31:0] ALUResult;
    logic [31:0] SaidaULAReg;

    logic [31:0] PCNext;

    // Memória
    logic [31:0] wIouD;
    logic [31:0] MemInstr;
    logic [31:0] MemData;
    logic [31:0] leituraM;
    logic [9:0]  enderecoM;

    assign Instr = IR;

    // PC só escreve se for incondicional ou beq com Zero
    assign PCWrite = EscrevePC | (EscrevePCCond & Zero);

    // =========================
    // MUX IouD
    // =========================
    always @(*) begin
        case (IouD)
            1'b0: wIouD = PC;
            1'b1: wIouD = SaidaULAReg;
            default: wIouD = PC;
        endcase
    end

    assign enderecoM = wIouD[11:2];

    // =========================
    // Memórias
    // =========================
    ramI MemC (
        .address(enderecoM),
        .clock(clockMem),
        .data(B),
        .wren(EscreveMem & ~wIouD[16]),
        .q(MemInstr)
    );

    ramD MemD (
        .address(enderecoM),
        .clock(clockMem),
        .data(B),
        .wren(EscreveMem & wIouD[16]),
        .q(MemData)
    );

    assign leituraM = wIouD[16] ? MemData : MemInstr;

    // =========================
    // MUX Mem2Reg
    // =========================
    always @(*) begin
        case (Mem2Reg)
            2'b00: WriteData = SaidaULAReg;
            2'b01: WriteData = PC;
            2'b10: WriteData = MDR;
            default: WriteData = 32'b0;
        endcase
    end

    // =========================
    // MUX OrigAULA
    // =========================
    always @(*) begin
        case (OrigAULA)
            2'b00: ALUA = PCBack;
            2'b01: ALUA = A;
            2'b10: ALUA = PC;
            default: ALUA = 32'b0;
        endcase
    end

    // =========================
    // MUX OrigBULA
    // =========================
    always @(*) begin
        case (OrigBULA)
            2'b00: ALUB = B;
            2'b01: ALUB = 32'd4;
            2'b10: ALUB = SaidaImediato;
            2'b11: ALUB = SaidaImediato;
            default: ALUB = 32'b0;
        endcase
    end

    // =========================
    // MUX OrigPC
    // =========================
    always @(*) begin
        case (OrigPC)
            2'b00: PCNext = ALUResult;
            2'b01: PCNext = SaidaULAReg;
            2'b10: PCNext = ALUResult & 32'hFFFF_FFFE; // jalr
            default: PCNext = ALUResult;
        endcase
    end

    // =========================
    // Registradores internos
    // =========================
    always @(posedge clockCPU or posedge reset) begin
        if (reset) begin
            PC          <= 32'h0040_0000;
            PCBack      <= 32'h0040_0000;
            IR          <= 32'b0;
            MDR         <= 32'b0;
            A           <= 32'b0;
            B           <= 32'b0;
            SaidaULAReg <= 32'b0;
        end else begin
            MDR         <= leituraM;
            A           <= ReadData1;
            B           <= ReadData2;
            SaidaULAReg <= ALUResult;

            if (EscreveIR)
                IR <= leituraM;

            if (EscrevePCB)
                PCBack <= PC;

            if (PCWrite)
                PC <= PCNext;
        end
    end

    // =========================
    // ULA
    // =========================
    ULA ULA_inst (
        .A(ALUA),
        .B(ALUB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .Zero(Zero)
    );

    // =========================
    // Gerador de imediato
    // =========================
    ImmGen GeraImm (
        .iInstrucao(IR),
        .oImm(SaidaImediato)
    );

    // =========================
    // Banco de registradores
    // =========================
    RegisterFile BancoReg (
        .clk(clockCPU),
        .reset(reset),
        .RegWrite(RegWrite),
        .disp(regin),
        .rs1(IR[19:15]),
        .rs2(IR[24:20]),
        .rd(IR[11:7]),
        .WriteData(WriteData),
        .DispData(regout),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // =========================
    // Controle com estado interno
    // =========================
    CONTROL Controle_inst (
        .iInstr(IR),
        .iRst(reset),
        .iClk(clockCPU),

        .oRegWrite(RegWrite),
        .oMemWrite(EscreveMem),
        .oMemRead(LeMem),
        .EscrevePCCond(EscrevePCCond),
        .EscrevePC(EscrevePC),
        .IouD(IouD),
        .EscreveIR(EscreveIR),
        .EscrevePCB(EscrevePCB),
        .OrigAULA(OrigAULA),
        .OrigBULA(OrigBULA),
        .oMem2Reg(Mem2Reg),
        .oOrigPC(OrigPC),
        .oALUControl(ALUControl),
        .oEstado(estado)
    );

endmodule