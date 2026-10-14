# Trabalho Prático 1: EduMIPS64

Arquitetura de Computadores II, GCC123/PCC507
Grupo 6:

> Bernado Henrique Diniz Felix
> Guilherme dos Santos Cordeiro
> Guilherme Genicy Camargos Silva
> Filipe Rezende Silva
> Luis Felipe Costa Teixeira

## 1. Introdução e construção do simulador

Neste trabalho, usamos o EduMIPS64 para acompanhar o que acontece com cada instrução dentro do pipeline. Não basta o programa dar o resultado certo: queremos entender quando uma instrução consegue avançar, quando precisa esperar e como essa espera aumenta o número de ciclos. Para isso, comparamos o código com forwarding desligado e ligado e conferimos os resultados nos registradores.

O EduMIPS64 simula parte do conjunto de instruções MIPS64 e foi feito para estudar arquitetura de computadores. Ele permite executar uma instrução por vez e ver os registradores, a memória e os estágios do pipeline. Isso ajuda a entender casos como o nosso `LD` seguido de `DADD`: a soma depende do dado carregado e pode precisar esperar por ele.

### 1.1 Histórico e tecnologias

O projeto começou em 2006 com estudantes da Universidade de Catania, na Itália. A ideia inicial era criar uma alternativa ao WinMIPS64 que não ficasse limitada ao Windows. Por isso, o simulador foi desenvolvido em Java e depois passou a seguir como um projeto próprio de software livre.

A parte que simula a CPU é escrita em Java. Na versão Desktop tradicional, a interface usa Swing. Na versão Web que usamos, a interface usa React e o núcleo Java é compilado para JavaScript, rodando em um Web Worker. Também existe uma distribuição com Electron. O que muda entre essas opções é principalmente a forma de acessar e visualizar o simulador.

### 1.2 Desktop e Web

| Aspecto | Desktop tradicional | Web utilizada neste trabalho |
|---|---|---|
| Acesso | Aplicação Java local | Navegador em `web.edumips.org` |
| Interface | Janelas e menus Swing | Editor e painéis de execução |
| Acompanhamento | Quadros de ciclos, registradores e memória | Painéis Stats, Pipeline, Registers, Memory e Cycles |
| Experimentos | Configurações do simulador local | Configurações acessíveis pelo botão de engrenagem |

Usamos somente a versão Web. Portanto, as comparações deste relatório são entre configurações do simulador, não entre Desktop e Web nem entre processadores reais.

### 1.3 Visualização do pipeline

O painel Pipeline mostra onde as instruções estão naquele ciclo. Já o painel Cycles mostra o caminho que cada uma percorreu ao longo da execução. Por isso, colocamos os prints de Cycles no relatório: neles conseguimos ver as instruções avançando e os pontos marcados como RAW. Quando o programa termina, o Pipeline fica vazio, mas o histórico em Cycles continua disponível.

| Estágio | Função no pipeline inteiro analisado |
|---|---|
| IF | Busca da instrução |
| ID | Decodificação e leitura dos operandos; decisão dos desvios neste simulador |
| EX | Operação da ALU ou cálculo do endereço efetivo |
| MEM | Acesso à memória de dados quando necessário |
| WB | Escrita do resultado no registrador de destino, quando a instrução possui esse resultado |

Passar por MEM não significa que toda instrução acessa a memória. O `DADD`, por exemplo, faz a soma em EX e apenas passa por MEM antes de escrever o resultado em WB. Esses cinco estágios são do modelo analisado, não uma regra para todo processador que execute MIPS64.

## 2. Descrição da ISA utilizada

### 2.1 Registradores e tamanho das instruções

No MIPS64 temos 32 registradores inteiros, de `R0` a `R31`, e 32 de ponto flutuante, de `F0` a `F31`, todos de 64 bits. O `R0` sempre vale zero. Também existem registradores especiais, como o PC, que indica o endereço da instrução a buscar, e HI e LO. Nos nossos microexperimentos, usamos apenas os registradores inteiros.

Os registradores são de 64 bits, mas as instruções usadas têm 32 bits. São duas coisas diferentes: a instrução diz qual operação fazer e quais registradores usar; o registrador guarda o dado da operação. Então, um `DADD` de 32 bits pode mandar somar valores de 64 bits. A versão Web permite consultar a codificação da instrução depois de carregá-la.

### 2.2 Características RISC e formatos

Uma característica RISC presente no código é a separação entre cálculo e acesso à memória. O `DADD` soma valores dos registradores, não busca diretamente um valor na memória. Se o dado está na memória, primeiro usamos um load para trazê-lo ao registrador. Para guardar um resultado de volta na memória, usamos um store. Isso fica claro no experimento 4.3, em que o `LD` carrega o valor 7 antes da soma.

| Formato | Campos da codificação clássica | Aplicação |
|---|---|---|
| R | opcode: 6; rs: 5; rt: 5; rd: 5; shamt: 5; funct: 6 bits | Operação entre registradores, como `DADD` |
| I | opcode: 6; rs: 5; rt: 5; imediato: 16 bits | `DADDI`, `LD` e desvio `BNE` |
| J | opcode: 6; campo de destino: 26 bits | Saltos como `J`; não utilizado nos microexperimentos |

O opcode ajuda a identificar o que a instrução faz; no tipo R, o campo funct também participa dessa identificação. Os campos de registrador dizem quais registradores usar, não carregam seus conteúdos. Já o imediato muda de função conforme a instrução: em `DADDI R1,R0,10`, ele é o número 10 a somar; em `LD R1,0(R2)`, ele é o deslocamento zero do endereço.

### 2.3 Instruções e diretivas utilizadas

| Elemento | Efeito e finalidade |
|---|---|
| `DADDI rt,rs,imm` | Soma inteira de 64 bits com imediato e resultado em `rt` |
| `DADD rd,rs,rt` | Soma inteira de 64 bits entre fontes `rs` e `rt`, com resultado em `rd` |
| `LD rt,offset(base)` | Lê 64 bits da memória no endereço `base + offset` e escreve em `rt` |
| `SD rt,offset(base)` | Grava os 64 bits de `rt` na memória no endereço `base + offset` |
| `DMUL rd,rs,rt` | Multiplica inteiros de 64 bits e coloca os 64 bits inferiores do resultado em `rd` |
| `DSLL rd,rt,sa` | Desloca bits para a esquerda; usamos deslocamento 3 para multiplicar um índice por 8 |
| `BEQ rs,rt,Fim` | Desvia quando os valores dos registradores são iguais |
| `BNE rs,rt,Loop` | Desvia para `Loop` se os valores lidos forem diferentes |
| `SYSCALL 0` | Solicita o encerramento da simulação |
| `.data` | Inicia a seção de dados |
| `.word 7` | Reserva e inicializa um dado de 64 bits no EduMIPS64 |
| `.space n` | Reserva `n` bytes para armazenar resultados |
| `.code` | Inicia a seção de instruções |

`.data`, `.word` e `.code` organizam o arquivo, mas não entram no pipeline como instruções. No EduMIPS64, `.word` reserva 64 bits, então usamos `valor: .word 7` para o dado do load. Para encerrar, usamos `SYSCALL 0` em vez de `HALT`, evitando o aviso de compatibilidade do montador.

Não há instrução lógica explícita nestes microexperimentos. A comparação de valores realizada por `BNE` faz parte do controle de fluxo, não de uma operação lógica que produza resultado em um registrador.

### 2.4 Uso dos registradores

| Experimento | Registradores e funções |
|---|---|
| 4.1 | `R1` a `R4`: resultados independentes 10, 20, 30 e 40; `R0`: zero |
| 4.2 | `R1` a `R4`: cadeia de resultados dependentes; `R0`: zero |
| 4.3 original | `R2`: endereço de `valor`; `R1`: dado carregado; `R4`: parcela inicialmente zero; `R3`: resultado |
| 4.3 com instrução independente | Mesmas funções da versão original e `R5`: resultado independente 100 |
| 4.4 | `R1`: contador regressivo; `R2`: número de iterações realizadas; `R0`: zero para inicialização e comparação |

Em `LD R1,0(R2)`, o `R2` guarda o endereço de onde queremos ler. O processador soma esse endereço com zero, busca o dado na memória e coloca o valor em `R1`. Portanto, `R2` é a base do endereço e `R1` recebe o dado. Um store faria o contrário: pegaria um valor do registrador e o gravaria na memória.

## 3. Metodologia experimental

### 3.1 Organização dos experimentos

Usamos códigos pequenos para estudar um problema de cada vez. Primeiro, quatro instruções sem dependência; depois, uma cadeia RAW; em seguida, um load seguido de soma; por último, um laço com desvio. Em cada comparação OFF/ON, mantivemos o mesmo código. No 4.3 também testamos uma segunda versão, com uma instrução independente entre o load e a soma.

Na seção 4, separamos o comportamento esperado do que apareceu no simulador. Essa parte foi organizada depois das execuções, então não temos um registro de todas as previsões escrito antes da primeira simulação.

| Experimento | Dependências e hazards analisados | Comportamento teórico esperado |
|---|---|---|
| 4.1 | Nenhuma dependência entre as quatro operações | Sobreposição sem stalls de dados |
| 4.2 | RAW em `R1`, `R2` e `R3` | Espera sem forwarding; encaminhamento dos resultados da ALU com forwarding |
| 4.3 | RAW de endereço em `R2` e load-use em `R1` | O load-use pode exigir espera mesmo com forwarding; uma instrução independente pode ocupar esse intervalo |
| 4.4 | RAW no contador usado pelo branch; hazard de controle | Espera pelo operando do desvio e descarte do caminho sequencial nos desvios tomados |

Ter dependência não significa necessariamente parar. Na cadeia de somas do 4.2, por exemplo, uma instrução precisa do resultado da anterior, mas o forwarding entrega esse valor sem bolha. No load-use do 4.3, o dado fica pronto mais tarde e ainda há uma espera. WAR e WAW também precisam ser analisadas junto da ordem de execução, não apenas pelo nome dos registradores.

### 3.2 Configurações mantidas constantes

| Parâmetro | Configuração |
|---|---|
| Interface | EduMIPS64 Web em `https://web.edumips.org/` |
| Forwarding | OFF e ON, em execuções separadas |
| Branch Delay Slot | Desligado |
| Cache L1 de instruções | 1024 bytes; bloco de 16 bytes; associatividade 1 |
| Cache L1 de dados | 1024 bytes; bloco de 16 bytes; associatividade 1 |
| Entrada do experimento 4.3 | Dado `valor = 7` |
| Entrada do experimento 4.4 | Contador inicial 10 |
| Encerramento | `SYSCALL 0` em todos os códigos |

Não registramos o identificador exato da versão Web nas capturas. Os parâmetros usados estão na tabela, mas uma atualização do simulador pode mudar algum resultado. Também usamos as latências do próprio EduMIPS64, não as de outros exercícios da disciplina.

### 3.3 Procedimento de execução e coleta

1. Selecionar o arquivo `.s` do microexperimento e inserir seu conteúdo no editor.
2. Abrir Settings, selecionar Simulation e definir CPU Forwarding como OFF ou ON, mantendo Branch Delay Slot desligado.
3. Carregar o programa com Load, reiniciando o estado para evitar aproveitar resultados de outra execução.
4. Usar Single Step para acompanhar ciclos específicos ou Run All para executar até o término.
5. Conferir o resultado funcional no painel Registers e, quando aplicável, os dados em Memory.
6. Registrar IC, CC, CPI e contadores de stalls no painel Stats.
7. Capturar também o painel Cycles, que mostra o percurso temporal das instruções.
8. Repetir com a outra configuração de forwarding, sem modificar o código ou a entrada.

Montamos as tabelas juntando os números de cada execução. O EduMIPS64 não gera essa comparação OFF/ON pronta: ele mostra os resultados de uma execução por vez em Stats. Os prints de Cycles mostram onde as esperas aconteceram.

### 3.4 Métricas e limites da análise

Foram utilizadas as seguintes relações:

```text
CPI = CC / IC
Speedup = CC_referência / CC_comparado
```

Comparamos o desempenho pelo número de ciclos, considerando o mesmo período de clock. Não usamos o tempo que o navegador levou para executar. Também contamos o `SYSCALL 0`, porque ele aparece no total de instruções do simulador.

Para estas sequências inteiras, a referência sem stalls é `IC + 4`, correspondente aos cinco estágios. No laço, a contribuição líquida de controle foi calculada por:

```text
Penalidade líquida de controle = CC - (IC + 4) - stalls RAW
Proporção de controle = penalidade líquida de controle / CC
```

No nosso laço, os contadores WAW e structural stalls ficaram em zero. Por isso, tiramos do total os ciclos do pipeline ideal e as esperas RAW para analisar o que sobrou de penalidade de controle, conferindo com o diagrama. Esse número foi calculado por nós, pois o painel Web não mostrou um contador separado de branch stalls. Não usamos essa conta como regra para qualquer pipeline.


# 4. Parte I: Microexperimentos Obrigatórios

## Configuração e método

Executamos os códigos no EduMIPS64 Web, mudando somente `CPU Forwarding` entre OFF e ON. Mantivemos `Branch Delay Slot` desligado e as mesmas configurações de cache. Todos os códigos terminam com `SYSCALL 0`, que também entra na contagem de instruções.

Para calcular o CPI, dividimos os ciclos pelas instruções: `CPI = CC / IC`. Os números vieram do painel Stats. Já a penalidade de controle foi calculada à parte, porque não apareceu como um contador separado nesse painel.

## 4.1 Experimento 1: Pipeline sem dependências

**Objetivo.** Ver como quatro instruções avançam quando nenhuma precisa do resultado da outra.

**Arquivo:** [exp1_pipeline_ideal.s](microexperimentos/exp1_pipeline_ideal.s)

Cada `DADDI` soma uma constante com `R0` e grava em um registrador diferente: `R1`, `R2`, `R3` e `R4`. Como `R0` sempre vale zero, nenhuma precisa esperar um valor produzido pela outra. Depois dessas quatro operações, o `SYSCALL 0` encerra o programa.

**Diagrama de ciclos observado no EduMIPS64 (forwarding OFF):**

![Pipeline das quatro instruções independentes e SYSCALL](resultados/imagens/exp1_off_ciclos.jpg)

| Instrução | Entrada em IF | Saída em WB |
|---|---:|---:|
| `I1 DADDI` | 1 | 5 |
| `I2 DADDI` | 2 | 6 |
| `I3 DADDI` | 3 | 7 |
| `I4 DADDI` | 4 | 8 |
| `I5 SYSCALL` | 5 | 9 |

**Previsão.** Não devem ocorrer stalls RAW. O resultado deve ser igual com forwarding OFF e ON.

**Observado.** As quatro operações produziram `R1=10`, `R2=20`, `R3=30` e `R4=40`.

| Forwarding | IC | CC | RAW stalls | WAW stalls | Structural stalls | CPI |
|---|---:|---:|---:|---:|---:|---:|
| OFF | 5 | 9 | 0 | 0 | 0 | 1,80 |
| ON | 5 | 9 | 0 | 0 | 0 | 1,80 |

Foram cinco instruções contando o encerramento, executadas em nove ciclos: `5 + 4 = 9`. O CPI ficou `9/5 = 1,80`. Ele não chega a 1 porque o código é curto e ainda precisamos dos ciclos para encher e esvaziar o pipeline. No diagrama, entra uma instrução nova por ciclo, sem paradas. Como não há resultado para adiantar entre essas operações, ligar o forwarding não mudou nada.

**Execução com forwarding OFF:**

![Experimento 1 com forwarding OFF](resultados/imagens/exp1_off.jpg)

**Execução com forwarding ON:**

![Experimento 1 com forwarding ON](resultados/imagens/exp1_on.jpg)

Diagrama de ciclos da execução:

![Ciclos: Experimento 1 com forwarding ON](resultados/imagens/exp1_on_ciclos.jpg)

## 4.2 Experimento 2: Dependências RAW e forwarding

**Objetivo.** Ver o que muda quando cada soma precisa do resultado da anterior, com e sem forwarding.

**Arquivo:** [exp2_raw_forwarding.s](microexperimentos/exp2_raw_forwarding.s)

| Produtora | Consumidora | Registrador |
|---|---|---|
| `I1 DADDI` | `I2 DADD` | `R1` |
| `I2 DADD` | `I3 DADD` | `R2` |
| `I3 DADD` | `I4 DADD` | `R3` |

**Previsão.** `I2` precisa de `R1`, produzido por `I1`; `I3` precisa de `R2`, produzido por `I2`; e `I4` precisa de `R3`, produzido por `I3`. Sem forwarding, esperamos paradas até esses valores serem escritos nos registradores. Com forwarding, o resultado da ALU pode seguir direto para a operação que precisa dele.

**Observado.** O resultado final foi `R1=10`, `R2=10`, `R3=10` e `R4=10` nas duas configurações.

| Forwarding | IC | CC | RAW stalls | CPI |
|---|---:|---:|---:|---:|
| OFF | 5 | 15 | 6 | 3,00 |
| ON | 5 | 9 | 0 | 1,80 |

Com forwarding OFF, apareceram duas esperas em cada uma das três dependências: `3 × 2 = 6` stalls. O total ficou `5 + 4 + 6 = 15` ciclos, com CPI `15/5 = 3,00`. Com forwarding ON, as seis esperas desapareceram e o código terminou em nove ciclos, com CPI `9/5 = 1,80`. O resultado continuou igual; só mudou o tempo para chegar nele. O ganho foi `15/9 = 1,67` vezes.

**Execução com forwarding OFF:**

![Experimento 2 com forwarding OFF](resultados/imagens/exp2_off.jpg)

Diagrama de ciclos da execução:

![Ciclos: Experimento 2 com forwarding OFF](resultados/imagens/exp2_off_ciclos.jpg)

**Execução com forwarding ON:**

![Experimento 2 com forwarding ON](resultados/imagens/exp2_on.jpg)

Diagrama de ciclos da execução:

![Ciclos: Experimento 2 com forwarding ON](resultados/imagens/exp2_on_ciclos.jpg)

## 4.3 Experimento 3: Dependência após carregamento

**Objetivo.** Entender por que uma soma logo depois de um load ainda pode precisar de uma bolha, mesmo com forwarding, e testar uma instrução independente nesse intervalo.

**Versão original:** [exp3_load_use.s](microexperimentos/exp3_load_use.s)  
**Versão com instrução independente:** [exp3_load_use_reordered.s](microexperimentos/exp3_load_use_reordered.s)

Na versão original, `LD R1,0(R2)` busca o valor 7 na memória e coloca em `R1`. Logo depois, `DADD R3,R1,R4` precisa desse valor para somar. O problema é o momento em que ele fica pronto: o load só entrega o dado no final de MEM, enquanto a soma seguinte já precisaria dele em EX. O forwarding não consegue entregar um dado antes de ele existir, então ainda aparece uma bolha. Sem forwarding, a soma espera a escrita no banco de registradores.

Na segunda versão, colocamos `DADDI R5,R0,100` entre o load e a soma. Ela não usa `R1`, então consegue executar enquanto esperamos o dado do load. Nas duas versões, `R3` continua recebendo `7 + 0 = 7`. A diferença é que a segunda também deixa `R5 = 100`.

| Versão | Forwarding | IC | CC | RAW stalls | CPI |
|---|---|---:|---:|---:|---:|
| Original | OFF | 4 | 12 | 4 | 3,00 |
| Original | ON | 4 | 9 | 1 | 2,25 |
| Reordenada | OFF | 5 | 12 | 3 | 2,40 |
| Reordenada | ON | 5 | 9 | 0 | 1,80 |

Na versão original sem forwarding, tivemos duas esperas para o `LD` usar o endereço preparado em `R2` e mais duas para a soma usar `R1`: quatro stalls no total. Com forwarding, a espera pelo endereço desapareceu, mas sobrou uma no load-use. Ao inserir a instrução independente, essa última espera também desapareceu com forwarding ON. Mesmo assim, as duas versões levaram nove ciclos: acrescentamos uma instrução que ocupou o lugar da bolha. O CPI caiu de `9/4 = 2,25` para `9/5 = 1,80`, mas o tempo em ciclos não diminuiu.

| Comparação | Speedup por ciclos |
|---|---:|
| Original OFF → ON | `12/9 = 1,33` |
| Reordenada OFF → ON | `12/9 = 1,33` |
| Original ON → Reordenada ON | `9/9 = 1,00` |

A `DADDI R5` serve aqui para testar esse preenchimento. Para otimizar um programa de verdade, o melhor seria mover uma instrução útil que já estivesse no código, em vez de acrescentar uma operação só para ocupar o intervalo.

**Versão original, forwarding OFF:**

![Load-use original com forwarding OFF](resultados/imagens/exp3_original_off.jpg)

Diagrama de ciclos da execução:

![Ciclos: Load-use original com forwarding OFF](resultados/imagens/exp3_original_off_ciclos.jpg)

**Versão original, forwarding ON:**

![Load-use original com forwarding ON](resultados/imagens/exp3_original_on.jpg)

Diagrama de ciclos da execução:

![Ciclos: Load-use original com forwarding ON](resultados/imagens/exp3_original_on_ciclos.jpg)

**Versão com instrução independente, forwarding OFF:**

![Load-use reordenado com forwarding OFF](resultados/imagens/exp3_reordenada_off.jpg)

Diagrama de ciclos da execução:

![Ciclos: Load-use reordenado com forwarding OFF](resultados/imagens/exp3_reordenada_off_ciclos.jpg)

**Versão com instrução independente, forwarding ON:**

![Load-use reordenado com forwarding ON](resultados/imagens/exp3_reordenada_on.jpg)

Diagrama de ciclos da execução:

![Ciclos: Load-use reordenado com forwarding ON](resultados/imagens/exp3_reordenada_on_ciclos.jpg)

## 4.4 Experimento 4: Hazard de controle

**Objetivo.** Ver como o desvio do laço e a espera pelo seu registrador afetam os ciclos, com e sem forwarding.

**Arquivo:** [exp4_branch_hazard.s](microexperimentos/exp4_branch_hazard.s)

Começamos com `R1 = 10` e `R2 = 0`. A cada volta, somamos 1 em `R2` e tiramos 1 de `R1`. O `BNE R1,R0,Loop` manda voltar enquanto `R1` for diferente de zero. Assim, executamos o teste dez vezes: voltamos nas primeiras nove e saímos na última. No final, conferimos `R1 = 0` e `R2 = 10`.

Antes de decidir se volta, o `BNE` precisa ler o novo `R1`, que acabou de ser alterado pelo `DADDI`. Esse teste acontece em ID. Como o simulador não tem forwarding direto para ID, ainda precisamos de uma espera por teste com forwarding ON. Com OFF, são duas. Também tivemos duas esperas extras, com OFF, entre zerar `R2` e fazer seu primeiro incremento. Portanto, os stalls RAW foram `10 × 2 + 2 = 22` com OFF e `10 × 1 = 10` com ON.

| Forwarding | IC | CC | RAW stalls | CPI |
|---|---:|---:|---:|---:|
| OFF | 33 | 68 | 22 | 2,06 |
| ON | 33 | 56 | 10 | 1,70 |

Além de esperar pelo valor de `R1`, temos a penalidade de voltar para o início do laço. Para separar essa parte, usamos os 33 comandos executados e tiramos do total os quatro ciclos de enchimento/esvaziamento e os stalls RAW. Como não há contador separado de branch stalls no painel Web, essa é uma conta feita a partir dos resultados:

| Forwarding | Penalidade líquida de controle |
|---|---:|
| OFF | `68 - 33 - 4 - 22 = 9` ciclos |
| ON | `56 - 33 - 4 - 10 = 9` ciclos |

Sobraram nove ciclos de penalidade de controle nas duas configurações, um para cada volta tomada nesta execução. O forwarding reduziu a espera pelos dados, de 22 para 10 stalls, mas não eliminou a penalidade de mudar o caminho do programa. Por isso, o total caiu de 68 para 56 ciclos.

Esses nove ciclos representam `9/68 × 100 = 13,24%` do total com OFF e `9/56 × 100 = 16,07%` com ON. A porcentagem aumentou, mas isso não significa que o desvio ficou pior: continuou custando nove ciclos, só que agora o total é menor. A parcela de controle no CPI foi `9/33 = 0,27` ciclo por instrução nos dois casos.

O speedup OFF→ON foi `68/56 = 1,21`.

**Execução com forwarding OFF:**

![Desvio condicional com forwarding OFF](resultados/imagens/exp4_off.jpg)

Trecho final do diagrama de ciclos (a execução completa excede a área visível).

![Ciclos: Desvio condicional com forwarding OFF](resultados/imagens/exp4_off_ciclos.jpg)

**Execução com forwarding ON:**

![Desvio condicional com forwarding ON](resultados/imagens/exp4_on.jpg)

Trecho final do diagrama de ciclos (a execução completa excede a área visível).

![Ciclos: Desvio condicional com forwarding ON](resultados/imagens/exp4_on_ciclos.jpg)

## Síntese das medições

| Experimento | Configuração | IC | CC | RAW stalls | WAW stalls | Structural stalls | CPI |
|---|---|---:|---:|---:|---:|---:|---:|
| 4.1 | OFF | 5 | 9 | 0 | 0 | 0 | 1,80 |
| 4.1 | ON | 5 | 9 | 0 | 0 | 0 | 1,80 |
| 4.2 | OFF | 5 | 15 | 6 | 0 | 0 | 3,00 |
| 4.2 | ON | 5 | 9 | 0 | 0 | 0 | 1,80 |
| 4.3 original | OFF | 4 | 12 | 4 | 0 | 0 | 3,00 |
| 4.3 original | ON | 4 | 9 | 1 | 0 | 0 | 2,25 |
| 4.3 reordenada | OFF | 5 | 12 | 3 | 0 | 0 | 2,40 |
| 4.3 reordenada | ON | 5 | 9 | 0 | 0 | 0 | 1,80 |
| 4.4 | OFF | 33 | 68 | 22 | 0 | 0 | 2,06 |
| 4.4 | ON | 33 | 56 | 10 | 0 | 0 | 1,70 |

# 5. Parte II: Programas desenvolvidos

Usamos os conceitos dos microexperimentos em três programas: soma de vetores, contagem de ocorrências e multiplicação de matrizes. Todos trabalham com inteiros de 64 bits e deixam a saída na memória. Assim, conseguimos conferir o resultado sem acrescentar rotinas de impressão à execução.

As entradas estão na seção `.data` de cada arquivo. Os três códigos foram executados até o fim com forwarding OFF e ON, mantendo Branch Delay Slot desligado. O resultado foi igual nas duas configurações. Os prints abaixo mostram a memória depois das execuções com forwarding ON.

## 5.1 Programa 1: Soma de dois vetores

**Arquivo:** [programa1_soma_vetores.s](programas/programa1_soma_vetores.s)

O programa percorre dois vetores e soma os elementos da mesma posição. Em cada volta, lê `A[i]` e `B[i]`, calcula a soma e grava em `C[i]`.

```text
A = [1, 2, 3, 4, 5]
B = [10, 20, 30, 40, 50]
N = 5

C[0] = 1 + 10 = 11
C[1] = 2 + 20 = 22
C[2] = 3 + 30 = 33
C[3] = 4 + 40 = 44
C[4] = 5 + 50 = 55

Saída esperada e observada: C = [11, 22, 33, 44, 55]
```

O trecho principal é:

```asm
LD R5, 0(R1)
LD R6, 0(R2)
DADD R7, R5, R6
SD R7, 0(R3)
```

`R1`, `R2` e `R3` guardam os endereços atuais de A, B e C. Os loads trazem os valores para `R5` e `R6`; a soma escreve em `R7`; e o store grava em C. Depois, avançamos os três endereços em oito bytes, porque cada elemento ocupa 64 bits.

`R4` começa com N e diminui uma unidade por volta. `BNE R4,R0,Loop` mantém o laço enquanto houver elementos. Um `BEQ` inicial evita entrar se N for zero. `R8` guarda o endereço da variável N durante a inicialização.

As dependências são do próprio algoritmo: a soma precisa dos loads, o store precisa da soma e o branch precisa do contador atualizado. O programa tem acesso à memória, operação aritmética, repetição, RAW e desvio condicional.

**Print da saída na memória:**

![Resultado da soma dos vetores no EduMIPS64](resultados/imagens/programa1_on_memoria.jpg)

C começa em `0x50`. Os valores `0B`, `16`, `21`, `2C` e `37` são 11, 22, 33, 44 e 55 em decimal. A coluna Code mostra a reserva `.space 40`; a coluna Value mostra os dados gravados pelo programa.

## 5.2 Programa 2: Contagem de ocorrências

**Arquivo:** [programa2_contagem.s](programas/programa2_contagem.s)

O programa conta quantas vezes o alvo aparece no vetor. Em cada posição, decide se aumenta o contador ou segue sem contar.

```text
vetor = [4, 7, 4, 2, 4, 9]
alvo = 4
N = 6

O valor 4 aparece nas posições 0, 2 e 4.
Saída esperada e observada: resultado = 3
```

A decisão acontece neste trecho:

```asm
LD R5, 0(R1)
BNE R5, R3, Proximo
DADDI R6, R6, 1
```

`R3` guarda o alvo e `R5` recebe o elemento. Se forem diferentes, o desvio pula o incremento; se forem iguais, `R6` aumenta. Ao ler 7, por exemplo, não contamos. Ao ler 4, contamos uma ocorrência.

`R1` avança oito bytes por volta e `R2` conta os elementos restantes. `R4` é usado para carregar os endereços de N, alvo e resultado. No fim, gravamos `R6` em `resultado`. O teste inicial de N permite terminar com contador zero quando não há elementos.

Temos dois testes no laço: comparar o elemento com o alvo e verificar se o vetor terminou. O primeiro usa imediatamente o dado do load, formando uma RAW em `R5`. O segundo depende da atualização de `R2`. Isso permite analisar hazards de dados e de controle sem inserir dependências artificiais.

**Print da saída na memória:**

![Resultado da contagem no EduMIPS64](resultados/imagens/programa2_on_memoria.jpg)

No endereço `0x40`, `resultado` ficou com 3. `R6` também mostra 3. A coluna Code mantém `.word 0`, o valor inicial do arquivo, mas Value confirma o resultado gravado pelo store.

## 5.3 Programa 3: Multiplicação de matrizes

**Arquivo:** [programa3_matrizes_original.s](programas/programa3_matrizes_original.s)

Escolhemos a multiplicação de matrizes como o programa mais completo. Ele tem três laços, calcula endereços, lê operandos, multiplica, acumula e grava a resposta. Esta é a versão original; a versão otimizada será feita na etapa de otimização do trabalho.

A tem duas linhas e três colunas, B tem três linhas e duas colunas e C terá duas linhas e duas colunas:

```text
A = [1  2  3]     B = [ 7   8]
    [4  5  6]         [ 9  10]
                     [11  12]

C[0][0] = 1×7 + 2×9 + 3×11   = 58
C[0][1] = 1×8 + 2×10 + 3×12  = 64
C[1][0] = 4×7 + 5×9 + 6×11   = 139
C[1][1] = 4×8 + 5×10 + 6×12  = 154

Saída esperada e observada:
C = [ 58   64]
    [139  154]
```

Guardamos as matrizes por linhas: A como `[1,2,3,4,5,6]` e B como `[7,8,9,10,11,12]`. `R1`, `R2` e `R3` guardam suas bases. `R4`, `R5` e `R6` representam i, j e k. Os rótulos `Linha`, `Coluna` e `Produto` correspondem aos três laços:

```text
para i = 0 até 1:
    para j = 0 até 1:
        soma = 0
        para k = 0 até 2:
            soma = soma + A[i][k] × B[k][j]
        C[i][j] = soma
```

Para acessar o elemento certo, usamos:

```text
endereço de A[i][k] = base de A + (i×3 + k)×8
endereço de B[k][j] = base de B + (k×2 + j)×8
endereço de C[i][j] = base de C + (i×2 + j)×8
```

O fator 8 vem do tamanho do elemento. `DSLL` com deslocamento 3 multiplica o índice por oito. `R7` e `R8` auxiliam no cálculo dos endereços; `R14` guarda 2 e `R15` guarda 3, os limites dos laços. As dimensões são fixas nesta versão: alterar só os dados não muda esses limites.

Carregamos A em `R9` e B em `R10`. O cálculo central é:

```asm
DMUL R11, R9, R10
DADD R12, R12, R11
```

`R11` recebe o produto e `R12` acumula a soma. Ao terminar os três produtos de uma posição, o store grava `R12` em C. A multiplicação é inteira, não usa os registradores F nem a unidade de ponto flutuante.

Os endereços precisam ficar prontos antes dos loads; a multiplicação precisa dos dois dados; e a soma precisa do produto. Cada branch usa um índice recém-incrementado. Esses trechos servirão para estudar forwarding e reorganização nas próximas seções.

**Print da saída na memória:**

![Resultado das matrizes no EduMIPS64](resultados/imagens/programa3_on_memoria.jpg)

C começa em `0x60`. `3A`, `40`, `8B` e `9A` são 58, 64, 139 e 154. Os dois primeiros formam a primeira linha de C e os dois últimos formam a segunda.

## 5.4 Organização e requisitos dos códigos

Os arquivos ficam em `programas`, com `.data` para entradas e saídas e `.code` para as instruções. Os comentários explicam os registradores e os trechos principais. Os rótulos identificam os laços e os pontos de saída, e todos terminam com `SYSCALL 0`.

| Programa | Memória e cálculo | Repetição e decisão | Saída conferida |
|---|---|---|---|
| Soma de vetores | Dois loads, soma e store por posição | Contador e branch do laço | `[11,22,33,44,55]` |
| Contagem | Load e incremento do contador | Comparação com o alvo e branch do laço | `3` |
| Matrizes | Endereços, loads, produto, soma e store | Três laços com i, j e k | `[[58,64],[139,154]]` |

Todos carregaram sem erros e terminaram com a saída esperada com forwarding OFF e ON. Não inserimos NOPs para criar esperas: os hazards vêm das operações dos algoritmos. As matrizes ainda não foram reordenadas, pois esse código será a referência da otimização.

As entradas pequenas facilitam a conferência manual. Esses testes não cobrem todos os casos nem valores que provoquem overflow. Na soma e na contagem, N deve ser não negativo e não ultrapassar o espaço reservado. As matrizes têm dimensões fixas 2×3 e 3×2.

Guardamos as medições iniciais em [medicoes_programas.csv](resultados/tabelas/medicoes_programas.csv) para a análise das próximas seções.


