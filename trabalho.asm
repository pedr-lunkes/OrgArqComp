							#################################################
		.data					# ÁREA DE DADOS DO CÓDIGO                       #
							#################################################
							
		.align 2				# Interpreta o(s) dado(s) na memória como word
cabeca:		.word 0					# Cabeça da lista ligada de inteiros
		.align 0				# Interpreta o(s) dado(s) na memória como byte
prompt_num: 	.asciz "Digite um número: "		# Mensagem pedindo um número  
prompt_char: 	.asciz "Digite um caractere: "		# Mensagem pedindo caracter
prompt_no_undo:	.asciz "Não há operações anteriores."	# Mensagem de ausência de operações anteriores
barra_n:	.asciz "\n"				# Mensagem de \n
		.text					# Receber inputs do usuário
		.align 2				# Interpreta o(s) dado(s) na memória como word
		.globl main				# Define o início do programa na label 'main'
							
							################################################
main:							# INÍCIO DO PROGRAMA                           #
							################################################
primeiro_input:
		#################################################
		# Imprime msg para digitar o número             #
		#################################################
		li a7, zero, 4			# Serviço 4 = impressão de string
		la a0, prompt_num			# a0 recebe o endereço da mensagem em que se pede de número
		ecall					# Syscall = sem retorno
		
		#################################################
		# Recebe o primeiro inteiro, o operando 1       #
		#################################################
		li a7, 5				# Serviço 5 = leitura de inteiro
		ecall					# Syscall = retorna o inteiro em a0
		add s1, a0, zero			# s1 recebe o conteúdo do inteiro recebido do usuário
		
padrao_input:
		#################################################
		# Imprime msg para digitar a operação           #
		#################################################
		li a7, 4				# Serviço 4 = impressão de string
		la a0, prompt_char			# a0 recebe o endereço da mensagem em que se pede a operação
		ecall					# Syscall = sem retorno
		
		#################################################
		# Lê o char de operação                         #
		#################################################
		li a7, 12				# Serviço ?? (Nunca vi)
		ecall					# Syscall = retorna o caracter em a0
		add s0, a0, zero			# s0 recebe o conteúdo do caracter recebido do usuário
		
		#################################################
		# Imprime o \n                                  #
		#################################################
		li a7, 4				# Serviço 4 = impressão de string
		la a0, barra_n				# a0 recebe o endereço da mensagem que contém o \n
		ecall					# Syscall = sem retorno
		
		#################################################
		# Faz as comparações do caracter lido, checando #
		# se é para desfazer ou encerrar o programa     #
		#################################################
		li t0, 'u'				# O registrador temporário recebe o caracter 'u'
		beq s0, t0, undo			# Compara o caracter recebido com 'u', se for igual, avança para label 'undo'
		li t0, 'f'				# O registrador temporário recebe o caracter 'f'
		beq s0, t0, encerra			# Compara o caracter recebido com 'f', se for igual, avança para label 'encerra'
		
		#################################################
		# Imprime msg para digitar um novo número       #
		#################################################
		li a7, 4				# Serviço 4 = impressão de string
		la a0, prompt_num			# a0 recebe o endereço da mensagem em que se pede de número
		ecall					# Syscall = sem retorno
		
		#################################################
		# Recebe o segundo inteiro, o operando 2        #
		#################################################
		li a7, 5				# Serviço 5 = leitura de inteiro
		ecall					# Syscall = retorna o inteiro em a0
		add s2, a0, zero			# s2 recebe o conteúdo do inteiro recebido do usuário
		
		#################################################
		# Chamada da função que armazena os resultados  #
		# ao longo das operações realizadas		#
		#################################################

		add a0, s1, zero			# a0 recebe o registrador em que estava o primeiro operando e no qual os resultados se acumulam
		jal novo_no				# Chamada da função que armazena esse valor em um novo nó
		
		# Passa os argumentos para operação
		add a0, s0, zero
		add a1, s1, zero
		add a2, s2, zero
		jal operacao
		
		# Passa o último valor como n1
		mv s1, a0
		j padrao_input
		
undo:
		# Remove o no e printa o seu valor
		jal remove_no
		li a7, 1
		ecall
		
		# Passa o último valor como n1
		mv s1, a0
		
		# Imprime /n
		li a7, 4
		la a0, barra_n
		ecall
		
		j padrao_input
encerra:
		li a7, 10
		ecall
		
# Função operação: faz alguma operação aritmética da calculadora
# Argumentos: a0 -> op; a1 -> n1; a2 -> n2
# Retorno: a0 -> res
operacao:
		# Switch case com a determinada operação
		li t0, '+'
		beq a0, t0, soma
		li t0, '-'
		beq a0, t0, subtracao
		li t0, '*'
		beq, a0, t0, multiplicacao
		li t0, '/'
		beq a0, t0, divisao
		
		# Operações da função
soma:		add a0, a1, a2	
		j operacao_fim
subtracao:	sub a0, a1, a2	
		j operacao_fim
multiplicacao:	mul a0, a1, a2	
		j operacao_fim
divisao:	div a0, a1, a2  

operacao_fim:
		# Printa o número na tela com \n e retorna
		li a7, 1
		ecall
		
		mv t0, a0	# Salva o número no t0 para poder usar a0
		li a7, 4
		la a0, barra_n
		ecall
		
		mv a0, t0	# Move para o registrador de retorno novamente 
		jr ra
		
#######################
# Funções referentes a linked list

# Função novo_no: adiciona um novo no na linked list.
# Argumentos: a0 -> valor
# Retorno: N/A
novo_no:
		mv t0, a0  	# Salva o valor na variavel temporaria t0
		li a0, 8  	# Aloca o tamanho da struct NO na heap
		li a7, 9  	# Faz a alocação de memória
		ecall
	
		mv t1, a0  	# Salva o valor do endereco alocado na variavel temporaria t1
		lw t2, cabeca  	# Carrega o endereco do NO da cabeca da lista em t2
	
		sw t2, 0(t1) 	# Coloca nos primeiros 4 bytes o ponteiros para o NO anterior
		sw t0, 4(t1)  	# Coloca nos ultimos 4 bytes o valor especificado pelo usuario
	
		la t3, cabeca  	# Carrega o endereco do ponteiro cabeca da lista em t3
		sw t1, 0(t3) 	# Atualiza o valor da cabeca
	
		mv a0, t0	# Restaura o valor de a0
		jr ra

# Função remove_no: remove um novo no da linked list e retorna seu valor
# Argumentos: N/A
# Retorno: a0 -> valor do ultimo no
remove_no:
		lw t0, cabeca  	# Carrega o endereco do NO da cabeca da lista, que sera removido, em t0
		beq t0, zero, remove_no_except # Caso seja o primeiro NO, retorna 0

		lw t1, 0(t0)  	# Carrega o endereco do proximo NO da lista em t1
		lw a0, 4(t0)  	# Carrega o valor do NO removido em a0
	
		la t3, cabeca 	# Carrega o endereco do ponteiro cabeca da lista em t3
		sw t1, 0(t3)  	# Atualiza o valor da cabeca
		jr ra
remove_no_except:
		li a7, 4
		la a0, prompt_no_undo
		ecall
		
		la a0, barra_n
		ecall
		
		li a0, 0
		jr ra

		
