# Programas da seção 5

Abra o EduMIPS64 Web em https://web.edumips.org/.

1. Abra o arquivo `.s` em Program > Open ou copie seu conteúdo para o editor.
2. Em Settings > Simulation, escolha CPU Forwarding OFF ou ON.
3. Mantenha Branch Delay Slot desligado.
4. Clique em Load e depois Run All.
5. Quando terminar, abra Memory e confira a saída.
6. Para comparar OFF e ON, carregue novamente o mesmo código, sem mudar as entradas.

| Arquivo | Resultado esperado | Onde conferir |
|---|---|---|
| `programa1_soma_vetores.s` | `[11,22,33,44,55]` | C, endereços 0x50 a 0x70 |
| `programa2_contagem.s` | `3` | resultado em 0x40; também R6 |
| `programa3_matrizes_original.s` | `[[58,64],[139,154]]` | C, endereços 0x60 a 0x78 |

Memory mostra valores em hexadecimal:

- Vetores: 0B, 16, 21, 2C, 37 = 11, 22, 33, 44, 55.
- Matrizes: 3A, 40, 8B, 9A = 58, 64, 139, 154.

Cada elemento ocupa oito bytes. Na soma e na contagem, N deve ser não negativo e compatível com o espaço reservado. O programa 3 tem dimensões fixas: A 2x3 e B 3x2.

O programa 3 é a versão original. A versão otimizada ainda não faz parte desta etapa.
