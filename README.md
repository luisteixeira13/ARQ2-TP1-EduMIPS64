# ARQ2: Trabalho Prático 1 no EduMIPS64

Repositório do TP1 de Arquitetura de Computadores II, GCC123/PCC507, UFLA. Reúne o enunciado, os códigos em Assembly MIPS64, os resultados medidos e os prints das execuções.

## Relatório e enunciado

- [Relatório em Markdown, até a seção 10](secao4_microexperimentos.md)
- [Enunciado do TP1](enunciado/TP1_EduMIPS64.pdf)
- [Como executar os três programas](programas/README.md)
- [Medições iniciais dos programas](resultados/tabelas/medicoes_programas.csv)
- [Medições auditadas (originais e otimizada)](resultados/tabelas/medicoes_programas_auditadas.csv)
- [Comparação do Programa 3](resultados/tabelas/comparacao_programa3_secao10.csv)

O trabalho está em andamento. O relatório em Markdown reúne as seções 1 a 10, incluindo a versão original e a otimizada do Programa 3, com medições e análise do pipeline. **As seções 11 a 14, os experimentos com diferentes tamanhos de entrada e o PDF final ainda estão pendentes.**

## Organização

```text
enunciado/               PDF fornecido pelo professor
microexperimentos/      Códigos dos quatro experimentos e variação load-use
experimentos_tamanho/    Códigos N=5,10,20,50 preparados (execução pendente)
programas/              Soma de vetores, contagem e matrizes original/otimizada
resultados/imagens/     Prints de estatísticas, ciclos e saídas na memória
resultados/tabelas/     Medições em CSV e Excel
secao4_microexperimentos.md  Relatório das seções 1 a 10
```

## Microexperimentos

| Arquivo | O que testa |
|---|---|
| [exp1_pipeline_ideal.s](microexperimentos/exp1_pipeline_ideal.s) | Quatro instruções independentes |
| [exp2_raw_forwarding.s](microexperimentos/exp2_raw_forwarding.s) | Cadeia RAW com forwarding OFF e ON |
| [exp3_load_use.s](microexperimentos/exp3_load_use.s) | Load seguido imediatamente pelo consumidor |
| [exp3_load_use_reordered.s](microexperimentos/exp3_load_use_reordered.s) | Instrução independente entre load e soma |
| [exp4_branch_hazard.s](microexperimentos/exp4_branch_hazard.s) | Laço com desvio condicional |

## Programas

| Arquivo | Resultado do teste |
|---|---|
| [programa1_soma_vetores.s](programas/programa1_soma_vetores.s) | `[11,22,33,44,55]` |
| [programa2_contagem.s](programas/programa2_contagem.s) | 3 ocorrências do valor 4 |
| [programa3_matrizes_original.s](programas/programa3_matrizes_original.s) | `[[58,64],[139,154]]` |
| [programa3_matrizes_otimizado.s](programas/programa3_matrizes_otimizado.s) | `[[58,64],[139,154]]`, com redução do número de ciclos |

## Execução rápida

1. Abra [EduMIPS64 Web](https://web.edumips.org/).
2. Abra um arquivo `.s` em Program > Open.
3. Em Settings > Simulation, escolha CPU Forwarding OFF ou ON e mantenha Branch Delay Slot desligado.
4. Use Load e depois Run All. Para acompanhar um ciclo por vez, use Single Step.
5. Confira Stats, Cycles e, nos programas, Memory.

As comparações usam o mesmo código e as mesmas entradas em OFF e ON. As saídas são gravadas na memória, não impressas no console. Os prints e a interpretação de cada execução estão no relatório.


## Estado das evidências

O painel Stats e as tabelas documentam os microexperimentos e os programas principais. A captura `resultados/imagens/programa3_otimizado_ON_memoria.png` existente está cortada antes da matriz C: **é necessário substituí-la por um print com os endereços 0x60 a 0x78** para completar a evidência visual da execução com forwarding ON. Os programas de `experimentos_tamanho/` não possuem ainda resultados medidos.
