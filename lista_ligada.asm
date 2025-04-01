# Codigo que define as funcoes para criar uma lista ligada de inteiros
		.data
	.align 2
cabeca: .word 0 # Cabeca da lista ligada de inteiros, inicializada como 0

		.text
	.align 2
	.globl main

# Definicao da struct da lista ligada de inteiros
# typedef struct no_{
#	NO* no_ant;
#	int num;
#} NO;

main:
	jal remove_no

	li a0 11
	jal s0, novo_no
	
	li a0 3
	jal s0, novo_no
	
	li a0 20
	jal s0, novo_no
	
	jal remove_no
	li a7, 1
	ecall
	
	jal valor_cabeca
	li a7, 1
	ecall
	
	j end

novo_no:  # Adiciona um novo no na lista ligada. Deve ser chamado com um registrador de retorno definido (ra é usado dentro desse procedimento)
		# a0 -> novo valor que será adicionado no no
	mv t0, a0  # Salva o valor na variavel temporaria t0
	li a0, 8  # Aloca o tamanho da struct NO na heap
	jal malloc  # Chama o procedimento que simula um malloc
	
	mv t1, a0  # Salva o valor do endereco alocado na variavel temporaria t1
	lw t2, cabeca  # Carrega o endereco do NO da cabeca da lista em t2
	
	sw t2, 0(t1)  # Coloca nos primeiros 4 bytes o ponteiros para o NO anterior
	sw t0, 4(t1)  # Coloca nos ultimos 4 bytes o valor especificado pelo usuario
	
	la t3, cabeca  # Carrega o endereco do ponteiro cabeca da lista em t3
	sw t1, 0(t3)  # Atualiza o valor da cabeca
	
	# Se for o primero NO, o valor salvo no ponteiro NO* no_ant será 0
	mv ra, s0
	ret

remove_no:  # Remove o no salvo na cabeca da lista ligada. Retorna no a0 o valor do NO removido
	lw t0, cabeca  # Carrega o endereco do NO da cabeca da lista, que sera removido, em t0
	beq t0, zero, ret  # Caso seja o primeiro NO, retorna
	
	lw t1, 0(t0)  # Carrega o endereco do proximo NO da lista em t1
	lw a0, 4(t0)  # Carrega o valor do NO removido em t2
	
	la t3, cabeca  # Carrega o endereco do ponteiro cabeca da lista em t3
	sw t1, 0(t3)  # Atualiza o valor da cabeca
	
	ret
	
valor_cabeca:  # Retorna o valor do NO cabeca no registrador a0
	lw t0, cabeca  # Carrega o endereco do NO da cabeca da lista em t0
	beq t0, zero, ret  # Caso seja o primeiro NO, retorna
	
	lw a0, 4(t0)  # Carrega o valor do NO cabeca em a0
	ret
									
malloc:  # Aloca a0 bytes na heap e retorna o endereço alocado em a0
	li a7, 9  
	ecall

	jalr ra
	
end:  # Encerra o programa
	li a7, 10
	ecall

