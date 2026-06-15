module Uniciclo (
    input logic clockCPU, clockMem,
    input logic reset,
    output logic [31:0] PC,
    output logic [31:0] Instr,
    input  logic [4:0] regin,
    output logic [31:0] regout
);
    
    // DECLARAÇÃO DOS SINAIS INTERNOS
	 
    // Sinais de controle de 1 bit
    logic EscreveMem;
    logic Mem2Reg;

    // Barramento de dados de 32 bits
    logic [31:0] SaidaULA;
    logic [31:0] ReadData1;
    logic [31:0] ReadData2;
    logic [31:0] ReadData;   // Este sinal vai receber a saída da Memória de Dados
    logic [31:0] WriteData;
    logic [31:0] SaidaImediato;


    // ATUALIZAÇÃO DO PC
    always @(posedge clockCPU or posedge reset) begin
        if(reset) begin
            PC <= 32'h0040_0000;
        end else begin
            PC <= PC + 4;
        end
    end



    // 1) MEMÓRIA DE INSTRUÇÕES: 1024 words
    ramI MemC (
        .address(PC[11:2]),
        .clock(clockMem),
        .data(32'b0),
        .wren(1'b0),
        .q(Instr)
    );

    // 2) MEMÓRIA DE DADOS: 1024 words
    ramD MemD (
        .address(SaidaULA[11:2]),
        .clock(clockMem),
        .data(ReadData2),
        .wren(EscreveMem),
        .q(ReadData)
    );
     
     

    // MULTIPLEXADOR ESCRITA REG (Mux do Mem2Reg)
   
    assign WriteData = (Mem2Reg) ? ReadData : SaidaULA;
    
endmodule