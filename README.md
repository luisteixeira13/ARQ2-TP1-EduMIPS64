# ARQ2: Trabalho Prático 1 - EduMIPS64

- [Relatório PDF final](relatorio.pdf)
- [Medições reais da seção 12](resultados/tabelas/medicoes_tamanho_secao12.csv)


Os códigos .s e os cinco integrantes foram preservados. A seção 12 usa agora medições reais da Web para N=10,20,50 OFF/ON. A memória completa da matriz otimizada ON foi capturada. As evidências anteriores permanecem arquivadas.

Para reproduzir: Program > Open, Settings > Simulation, Branch Delay Slot OFF, caches I/D 1024/16/1, selecionar forwarding e usar Load > Run All até STOPPED. Ler Stats e Memory. Não tratar misses de cache como stalls de pipeline; branch stalls separados não estão disponíveis.
