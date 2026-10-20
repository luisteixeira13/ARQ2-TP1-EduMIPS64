# Experimento da secao 12 - variacao de tamanho

Foram preparados quatro programas com o MESMO algoritmo de soma de vetores (programa 1): N=5, 10, 20 e 50.
Apenas os valores de entrada, o tamanho do espaco de C e N sao alterados; a rotina Assembly e identica.

Entradas: `A = [1,2,...,N]` e `B = [10,20,...,10*N]`.
Resultado esperado: `C = [11,22,33,...,11*N]`, com N elementos.

Para cada N, execute com Forwarding OFF e ON, Branch Delay Slot OFF, as MESMAS configuracoes de cache do primeiro experimento.
Registre IC, CC, RAW/WAW/Structural stalls, CPI e possiveis outros stalls mostrados pelo Stats.
Tire prints de Stats e Memory, identificando arquivo, N e Forwarding no nome.

O arquivo N=5 e uma copia funcional da entrada inicial. A copia aqui serve para padronizar os quatro cenarios.
Nao preencha colunas de medicao antes da simulacao.
