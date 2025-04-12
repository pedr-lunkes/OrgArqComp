#################################################
# CÁLCULADORA SEQUENCIAL - TRABALHO 1           #
# ALUNOS:                              N°USP:   #
# - Dante Brito Lourenço               15447326 #
# - João Gabriel Pieroli da Silva      15678578 #
# - Pedro Henrique de Sousa Prestes    15507819 #
# - Pedro Lunkes Villela	       15484287 #
#################################################

							#################################################
		.data					# ÁREA DE DADOS DO CÓDIGO                       #
							#################################################
							
		.align 2				# Interpreta o(s) dado(s) na memória como word
cabeca:		.word 0					# Cabeça da lista ligada de inteiros
		.align 0				# Interpreta o(s) dado(s) na memória como byte
prompt_num: 	.asciz "Digite um número: "		# Mensagem pedindo um número  
prompt_char: 	.asciz "Digite um caractere: "		# Mensagem pedindo caracter
prompt_no_undo:	.asciz "Não há operações anteriores."	# Mensagem de ausência de operações anteriores
prompt_invalid:	.asciz "Operação inválida."		# Mensagem para caso o usuário queira uma operação inválida
div_zero_warn: 	.asciz "Divisão por 0 não é permitida."	# Mensagem de erro por conta de divisão por 0
barra_n:	.asciz "\n"				# Mensagem de \n
		.text					# Receber inputs do usuário
		.align 2				# Interpreta o(s) dado(s) na memória como word
		.globl main				# Define o início do programa na label 'main'
							
							################################################
main:							# INÍCIO DO PROGRAMA                           #
							################################################
#################################################
# Label referente ao primeiro input             #
#################################################
primeiro_input:
		#################################################
		# Imprime msg para digitar o número             #
		#################################################
		
		li a7, 4				# Serviço 4 = impressão de string
		la a0, prompt_num			# a0 recebe o endereço da mensagem em que se pede de número
		ecall					# Syscall = sem retorno
		
		#################################################
		# Recebe o primeiro inteiro, o operando 1       #
		#################################################
		
		li a7, 5				# Serviço 5 = leitura de inteiro
		ecall					# Syscall = retorna o inteiro lido em a0
		add s1, a0, zero			# s1 recebe o conteúdo do inteiro recebido do usuário

#################################################
# Label referente ao input de operação e novo   #
# operando                                      #
#################################################
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
		
		li a7, 12				# Serviço 12 = leitura de char, sem necessidade de enter
		ecall					# Syscall = retorna o caracter lido em a0
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
# Label referente à verificação quanto à        #
# validade da operação desejada                 #
#################################################
verifica_op:
		#################################################
		# Compara com as quatro operações: +, -, *, /   #
		#################################################
		li t0, '+'				# t0 recebe o caracter '+'
		beq s0, t0, op_valida			# Se a operação desejada for '+', vai na label para realizá-la
		li t0, '-'				# t0 recebe o caracter '-'
		beq s0, t0, op_valida			# Se a operação desejada for '-', vai na label para realizá-la
		li t0, '*'				# t0 recebe o caracter '*'
		beq s0, t0, op_valida			# Se a operação desejada for '*', vai na label para realizá-la
		li t0, '/'				# t0 recebe o caracter '/'
		beq s0, t0, op_valida			# Se a operação desejada for '/', vai na label para realizá-la

		#################################################
		# Se for inválida, imprime uma mensagem e volta #
		# para o loop                                   #
		#################################################
		
		li a7, 4				# Serviço 4 = imprimir string
		la a0, prompt_invalid			# a0 recebe o endereço da mensagem para operação inválida
		ecall					# Syscall = imprime, sem retorno

		li a7, 4				# Serviço 4 = imprimir string
		la a0, barra_n				# a0 recebe o endereço da mensagem de \n
		ecall					# Syscall = imprime, sem um retorno
	
		j padrao_input				# Dá um jump para receber novamente o caracter da operação 
		
#################################################
# Label referente a operação válida             #
#################################################
op_valida:		
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
		# Antes de salvar na lista, testa divisão por 0 #
		#################################################
		li t0, '/'				# O registrador temporário recebe o caracter da divisão
		beq s0, t0, testa_div_zero		# Se for divisão, deve-se testar a divisão por 0
		

#################################################
# Label para voltar se a divisão não for por 0  #
#################################################
salvar_no:	
		#################################################
		# Chamada da função que armazena os resultados  #
		# ao longo das operações realizadas		#
		#################################################
		
		add a0, s1, zero			# a0 recebe o registrador em que estava o primeiro operando e no qual os resultados se acumulam
		jal novo_no				# Chamada da função que armazena esse valor em um novo nó
		
		#################################################
		# Passa os argumentos para a operação           #
		#################################################
		
		add a0, s0, zero			# a0 recebe o conteúdo de s0, a operação
		add a1, s1, zero			# a1 recebe o conteúdo de s1, o operando 1
		add a2, s2, zero			# a2 recebe o conteúdo de s2, o operando 2
		jal operacao				# Chama a função para efetuar a operação
		
		#################################################
		# Guarda o resultado e volta ao loop            #
		#################################################
		
		add s1, a0, zero			# s1, que representa o operando 1, recebe o resultado obtido da operação
		j padrao_input				# Dá um jump para receber a próxima operação e operando 2

#################################################
# Tratamento para o caso de divisão por 0       #
#################################################
testa_div_zero:

	#################################################
	# Se s2 não for 0, volta para salvar o valor   #
	#################################################
	
	bne s2, zero, salvar_no				# Só continua o código para salvar o nó, caso s2 seja diferente de 0, se for 0, imprime mensagem de erro
	
	#################################################
	# Imprime o warning e pede novos valores        #
	#################################################
	
	li a7, 4					# Serviço 4 = impressão de string
	la a0, div_zero_warn				# a0 recebe o endereço da string de aviso de divisão por 0
	ecall						# Syscall = impressão da string, sem retorno
	
	la a0, barra_n					# a0 recebe o endereço da string com \n
	ecall						# Syscall = impressão de string, sem retorno
	
	j padrao_input					# Volta para receber novamente o caracter de operação e operando2
	
#################################################
# Label referente ao algoritmo para desfazer a  #
# operação, voltando ao valor anterior          #
#################################################
undo:
		#################################################
		# Remoção do nó da lista encadeada              #
		#################################################
		
		jal remove_no				# Chama a função que remove o nó e guarda em a0 o novo último elemento da lista encadeada
		li a7, 1				# Serviço 1 = imprimir inteiro
		ecall					# Syscall = imprime o inteiro, sem retorno
		add s1, a0, zero			# s1, que representa o operando1, é atualizado com o valor anterior obtido
		
		#################################################
		# Impressão do \n e volta ao loop               #
		#################################################
		
		li a7, 4				# Serviço 4 = imprimir string
		la a0, barra_n				# a0 recebe o endereço da mensagem com o \n
		ecall					# Syscall = imprime, sem retorno
		
		j padrao_input				# Dá um jump para receber a próxima operação e operando 2
		
#################################################
# Label que leva ao encerramento do programa    #
#################################################
encerra:
		li a7, 10				# Serviço 10 = encerra o programa
		ecall					# Syscall = finaliza, indicando que deu tudo certo
		
#################################################
# Função 'operação', a qual determina a operação#
# aritmética a ser realizada, fazendo um desvio #
# para a respectiva operação.                   #
#################################################
# ARGUMENTOS:
# a0 = caracter da operação
# a1 = inteiro, operando1
# a2 = inteiro, operando2
# RETORNOS:
# a0 = resultado obtido da operação
operacao:
		#################################################
		# Switch case com a determinada operação        #
		#################################################
		
		li t0, '+'				# O registrador temporário recebe o char '+', indicando soma
		beq a0, t0, soma			# Compara o caracter de operação recebido do usuário com o temporário. Se for igual, desvia para o label da respectiva operação
		li t0, '-'				# O registrador temporário recebe o char '-', indicando subtração
		beq a0, t0, subtracao			# Compara o caracter de operação recebido do usuário com o temporário. Se for igual, desvia para o label da respectiva operação	
		li t0, '*'				# O registrador temporário recebe o char '*', indicando multiplicação
		beq, a0, t0, multiplicacao		# Compara o caracter de operação recebido do usuário com o temporário. Se for igual, desvia para o label da respectiva operação		
		li t0, '/'				# O registrador temporário recebe o char '/', indicando divisão inteira
		beq a0, t0, divisao			# Compara o caracter de operação recebido do usuário com o temporário. Se for igual, desvia para o label da respectiva operação
		
		
		j caractere_invalido			# Se não achou a operação, é um caractere invalido, vai para o label desse tratamento
		
#################################################
# Label para a operação soma de a1 e a2         #
# a0 recebe o resultado da operação.            #
#################################################
soma:		
		add a0, a1, a2				# Soma os operando1 e operando2, salvos em a1 e a2, armazenando em a0 o resultado
		j operacao_fim				# Dá um jump para o pós-realização da operação
		
#################################################
# Label para a operação subtração de a1 e a2    #
# a0 recebe o resultado da operação.            #
#################################################
subtracao:	
		sub a0, a1, a2				# Subtrai do operando1, o operando2, salvos em a1 e a2, armazenando em a0 o resultado
		j operacao_fim				# Dá um jump para o pós-realização da operação
		
#################################################
# Label para a operação multiplicação de a1 e a2#
# a0 recebe o resultado da operação.            #
#################################################
multiplicacao:	
		mul a0, a1, a2				# Multiplica o operando1 com o operando2, salvos em a1 e a2, armazendo em a0 o resultado
		j operacao_fim				# Dá um jump para o pós-realização da operação
		
#################################################
# Label para a operação divisão inteira de a1 e #
# a2. a0 recebe o resultado da operação.        #
#################################################
divisao:	
		div a0, a1, a2				# Divisão inteira do operando1 pelo operando2, salvos em a1 e a2, armazenando em a0 o resultado
		j operacao_fim				# Dá um jump para o pós-realização da operação

#################################################
# Tratamento para o caracter inválido           #
#################################################
caractere_invalido:
		li a7, 4				# Serviço 4 = impressão de string
		la a0, prompt_invalid			# a0 recebe o endereço da string de caracter de operação inválido
		ecall					# Syscall = impressão da mensagem, mas sem retorno
		
#################################################
# Pós-realizada a operação, imprime o resultado #
#################################################
operacao_fim:

		#################################################
		# Imprime o resultado e o \n                    #
		#################################################
		li a7, 1				# Serviço 1 = impressão de inteiro, a0 é o argumento
		ecall					# Syscall = impressão, mas sem retorno
		
		add t0, a0, zero			# Salva o número no t0 para poder usar a0, no argumento da syscall
		li a7, 4				# Serviço 4 = impressão de string
		la a0, barra_n				# a0 recebe o endereço da string "\n"
		ecall					# Syscall = impressão da string, sem retorno
		
		#################################################
		# Ajusta o retorno e volta à chamada da função  #
		#################################################
		add a0, t0, zero			# O registrador a0 recebe de volta o resultado obtido da operação
		jr ra					# Retorna para o local de chamada da função

#################################################
# Funções referentes à linked list, sejam elas: #
# - novo_no = adiciona um novo nó à lista       #
# - remove_no = remove o último nó adicionado   #
# na lista e retorna o valor inteiro nele       #
# armazenado.                                   #
# - remove_no_except = tratamento do caso em    #
# que não há mais elementos na lista.           #    
#################################################

#################################################
# Função 'novo_no' cria um nó com o resultado   #   
# da operação e adiciona-o à linked list        #
#################################################
# ARGUMENTOS:.
# a0 = valor do resultado, a ser guardado no nó
# da lista
# RETORNOS: 
# N/A
novo_no:
		#################################################
		# Alocação de memória                           #
		#################################################
		
		add t0, a0, zero		  	# Salva o valor na variavel temporária t0
		li a0, 8  				# a0 recebe o tamanho da struct NO na heap
		li a7, 9  				# Serviço 9 = alocação de memória
		ecall					# Syscall = alocação de memória na heap, de tamanho a0, retorna o endereço da memória alocada em a0
	
		
		add t1, a0, zero 			# Salva o valor do endereço alocado na variável temporária t1
		lw t2, cabeca  				# Carrega o endereço do NO da cabeça da lista em t2
		
		#################################################
		# Escrita na memória memória alocada            #
		# Primeiros 4 bytes = endereço do nó anterior   #
		# Últimos 4 bytes = o valor do resultado        #
		#################################################
		
		sw t2, 0(t1) 				# Coloca nos primeiros 4 bytes o ponteiros para o NO anterior
		sw t0, 4(t1)  				# Coloca nos últimos 4 bytes o valor especificado pelo usuário
	
		#################################################
		# Atualiza o valor do nó cabeça com o nó novo e #
		# retorna para a chamada da função              #
		#################################################
		
		la t3, cabeca  				# Carrega o endereço do ponteiro cabeça da lista em t3
		sw t1, 0(t3) 				# Atualiza o valor da cabeca, com o novo nó
	
		mv a0, t0				# Restaura o valor de a0, com o valor original
		jr ra					# Volta para o local da chamada da função

#################################################
# A função 'remove_no' remove o último nó da    #
# lista, retornando o valor inteiro desse nó    #
#################################################
# ARGUMENTOS:.
# N/A
# RETORNOS: 
# a0 = valor do último nó, que estava na lista
remove_no:
		#################################################
		# Recebe o endereço do nó cabeça (último nó da  #
		# lista), tratando caso a lista seja vazia      #
		#################################################
		
		lw t0, cabeca  				# Carrega o endereco do NO da cabeca da lista, que será removido, em t0
		beq t0, zero, remove_no_except 		# Caso seja o primeiro NO, retorna 0

		#################################################
		# Lê as informações armazenadas na struct NO:   #
		# - 4 primeiros bytes = endereço do nó anteiror #
		# - 4 últimos bytes = valor armazenado no NO,   #
		# guardando-o em a0.                            #
		#################################################
		
		lw t1, 0(t0)  				# Carrega o endereço do NO anterior da lista (penúltimo) em t1
		lw a0, 4(t0)  				# Carrega o valor do NO removido em a0
		
		#################################################
		# Atualiza a cabeça da lista e retorna          #
		#################################################
		
		la t3, cabeca 				# Carrega o endereco do ponteiro cabeca da lista em t3
		sw t1, 0(t3)  				# Atualiza o valor da cabeca com o que era o penúltimo nó (agora, pós-remoção, passa a ser o último)
		jr ra					# Retorna para o local da chamada da função
		
#################################################
# A função 'remove_no_except' faz o tratamento  #
# para quando a lista não possui mais elementos #
#################################################
# ARGUMENTOS:.
# N/A
# RETORNOS: 
# a0 = retorna 0, já que a lista está vazia
remove_no_except:
		
		#################################################
		# Printa a mensagem de lista vazia e o \n       #
		#################################################
		
		li a7, 4				# Serviço 4 = impressão de string
		la a0, prompt_no_undo			# a0 recebe o endereço da string de que a lista de resultados está vazia
		ecall					# Syscall = impressão, mas sem retorno
		
		la a0, barra_n				# a0 recebe o endereço da string com \n
		ecall					# Syscall = impressão, mas sem retorno
		
		#################################################
		# Ajusta o retorno para 0 e volta à chamada     #
		#################################################
		
		li a0, 0				# Por padrão, deixa a0 como 0, assim, imprime-se 0, como resultado padrão para essa situação
		jr ra					# Retorna para o local de chamada da função

		
