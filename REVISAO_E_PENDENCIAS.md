# Coleta Web concluída

As seis execuções de N=10,20,50 foram realizadas no EduMIPS64 Web, build production 1.4.0-223-gce45a8d9. Branch Delay Slot OFF; caches L1 I/D 1024 bytes, blocos 16 bytes, associatividade 1. Apenas forwarding foi alternado.

- Medições: resultados/tabelas/medicoes_tamanho_secao12.csv.
- Capturas reais integrais: resultados/imagens/n{10,20,50}_{OFF,ON}.jpg.
- Matriz otimizada ON: resultados/imagens/programa3_ON_memoria_completa.jpg.
- Memória observada: resultados/tabelas/memoria_programa3_ON_observada.csv.
- Configurações e versão: settings_OFF.jpg, settings_ON.jpg e edumips_about.jpg.

Programa 3 ON: 172 ciclos, 151 instruções, RAW=6, WAW=0, Structural=0. C=[[58,64],[139,154]]. Branch stalls N/D: não exibidos separadamente.

N=5 e os demais resultados anteriores foram preservados; não foram reexecutados nesta revisão. O build anterior continua desconhecido. Os arquivos de projeção e a figura composta são históricos; não devem substituir as novas medições/capturas. O arquivo CSV com nome antigo “preencher_apos_simulacao” agora contém os resultados reais para compatibilidade.
