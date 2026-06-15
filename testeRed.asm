.data
a:      .word 2
b:      .word 4
c:      .word 0

.text
    # Carrega valores iniciais da memória
    	lui gp, 0x10010       # gp = 0x10010000

    	lw t0, 0(gp)          # t0 = 2
    	lw t1, 4(gp)          # t1 = 4

    # Teste ADD
    	add s0, t0, t1        # s0 = 2 + 4 = 6

    # Teste BEQ falso
   	beq t1, s0, ERRO      # 4 == 6? falso, não deve pular

    # Teste SUB
    	sub s1, t1, t0        # s1 = 4 - 2 = 2

    # Teste AND
    	and s2, t0, t1        # s2 = 2 & 4 = 0

    # Teste OR
    	or s3, t0, t1         # s3 = 2 | 4 = 6

    # Teste SLT
    	slt s4, t0, t1        # s4 = 1, pois 2 < 4

    # Teste ADDI
    	addi s5, t0, 10       # s5 = 2 + 10 = 12

    # Teste SLL
    	sll a0, t1, t0        # a0 = 4 << 2 = 16

    # Teste SLLI
    	slli a1, t0, 3        # a1 = 2 << 3 = 16

    # Teste LUI
    	lui a2, 0x12345       # a2 = 0x12345000

    # Teste SW
    	sw s0, 8(gp)          # mem[gp + 8] = 6, ou seja, c = 6

    # Teste LW após SW
    	lw a3, 8(gp)          # a3 = 6

    # Teste BEQ verdadeiro
    	beq a3, s0, BEQ_OK    # 6 == 6? verdadeiro, deve pular

    	addi a4, zero, 99     # se executar, BEQ falhou

BEQ_OK:
    	addi a5, zero, 1      # a5 = 1 indica que BEQ funcionou

    # Teste JAL
    	jal ra, JAL_OK        # pula para JAL_OK e salva retorno em ra

    		addi a6, zero, 99     # se executar, JAL falhou

JAL_OK:
    	addi a6, zero, 1      # a6 = 1 indica que JAL funcionou

    # Preparação para JALR
    	lui t2, 0x00400       # t2 = 0x00400000
	addi t2, t2, 0x078    # t2 = 0x00400078
	jalr zero, 0(t2)

    	addi a7, zero, 99     # se executar, JALR falhou

JALR_OK:
    	addi a7, zero, 1      # a7 = 1 indica que JALR funcionou

FIM:
    	jal zero, FIM         # loop infinito

ERRO:
    	addi t6, zero, -1     # t6 = 0xFFFFFFFF indica erro
    	jal zero, ERRO
