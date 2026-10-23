#!/usr/bin/env python3
"""Validador independente e limitado da semantica dos programas do TP1.

NAO e o EduMIPS64: interpreta o subconjunto usado nos .s, verificando
resultado e numero de instrucoes dinamicas. NAO mede ciclos nem hazards.
"""
from __future__ import annotations
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
MASK = (1 << 64) - 1


def assinar(x: int) -> int:
    x &= MASK
    return x if x < (1 << 63) else x - (1 << 64)


def carregar(arquivo: Path):
    secao = None
    dados, codigo = {}, []
    end = 0
    rotulos_dados, rotulos_codigo = {}, {}
    for linha in arquivo.read_text(encoding='utf-8').splitlines():
        linha = linha.split(';', 1)[0].strip()
        if not linha:
            continue
        if linha.lower() in ('.data', '.code'):
            secao = linha.lower()
            continue
        match = re.match(r'^([\w]+):\s*(.*)$', linha)
        if match:
            rotulo, linha = match.groups()
            (rotulos_dados if secao == '.data' else rotulos_codigo)[rotulo.lower()] = end if secao == '.data' else len(codigo)
            if not linha:
                continue
        if secao == '.data':
            t, *rest = linha.split(None, 1)
            if t.lower() == '.word':
                for item in rest[0].split(','):
                    dados[end] = assinar(int(item.strip(), 0))
                    end += 8
            elif t.lower() == '.space':
                n = int(rest[0]); assert n % 8 == 0
                for _ in range(n // 8):
                    dados[end] = 0
                    end += 8
            else:
                raise ValueError(f'Diretiva nao suportada: {linha}')
        elif secao == '.code':
            op, *args = re.split(r'\s+', linha, maxsplit=1)
            codigo.append((op.upper(), [p.strip() for p in args[0].split(',')] if args else []))
        else:
            raise ValueError(f'Instrucao fora de .data/.code: {linha}')
    return dados, codigo, rotulos_dados, rotulos_codigo


def executar(arquivo: Path):
    dados, codigo, labels, saltos = carregar(arquivo)
    regs = [0] * 32
    ic = 0
    pc = 0

    def r(t):
        m = re.fullmatch(r'R(\d+)', t, re.IGNORECASE)
        if not m:
            raise ValueError(f'Registrador invalido: {t}')
        return int(m[1])

    def valor(t):
        return labels[t.lower()] if t.lower() in labels else int(t, 0)

    while 0 <= pc < len(codigo):
        ic += 1
        if ic > 1_000_000:
            raise RuntimeError(f'Possivel loop infinito em {arquivo}')
        op, a = codigo[pc]
        nxt = pc + 1
        if op == 'DADDI':
            regs[r(a[0])] = assinar(regs[r(a[1])] + valor(a[2]))
        elif op == 'DADD':
            regs[r(a[0])] = assinar(regs[r(a[1])] + regs[r(a[2])])
        elif op == 'DMUL':
            regs[r(a[0])] = assinar(regs[r(a[1])] * regs[r(a[2])])
        elif op == 'DSLL':
            regs[r(a[0])] = assinar((regs[r(a[1])] & MASK) << valor(a[2]))
        elif op in ('LD', 'SD'):
            m = re.fullmatch(r'([+-]?\d+)\((R\d+)\)', a[1], flags=re.IGNORECASE)
            if not m: raise ValueError(f'Endereco invalido: {a[1]}')
            address = regs[r(m[2])] + int(m[1]); assert address % 8 == 0
            if address not in dados: raise ValueError(f'Acesso fora da .data: {address}')
            if op == 'LD': regs[r(a[0])] = dados[address]
            else: dados[address] = regs[r(a[0])]
        elif op in ('BEQ', 'BNE'):
            test = regs[r(a[0])] == regs[r(a[1])]
            if test == (op == 'BEQ'):
                nxt = saltos[a[2].lower()]
        elif op == 'SYSCALL':
            assert a == ['0']
            break
        else:
            raise ValueError(f'Opcode nao suportado: {op}')
        regs[0] = 0
        pc = nxt
    else:
        raise RuntimeError('Programa acabou sem SYSCALL 0')
    return dados, regs, labels, ic


def verificar():
    casos = [
        ('programas/programa1_soma_vetores.s', 'C', [11,22,33,44,55], 52),
        ('programas/programa2_contagem.s', 'resultado', [3], 43),
        ('programas/programa3_matrizes_original.s', 'C', [58,64,139,154], 217),
        ('programas/programa3_matrizes_otimizado.s', 'C', [58,64,139,154], 151),
    ]
    for n in (5,10,20,50):
        casos.append((f'experimentos_tamanho/programa1_n{n:02}.s', 'C', [11*i for i in range(1,n+1)], 7+9*n))
    falhas = 0
    for arquivo, nome, esperado, ic_esp in casos:
        memoria, _, rotulos, ic = executar(ROOT / arquivo)
        inicio = rotulos[nome.lower()]
        resultado = [memoria[inicio + 8*i] for i in range(len(esperado))]
        ok = resultado == esperado and ic == ic_esp
        print(f'{"OK" if ok else "FALHA"}: {arquivo} | IC={ic} (esperado {ic_esp}) | saida={resultado if len(resultado)<9 else str(resultado[:4])+" ... "+str(resultado[-2:])}')
        falhas += not ok
    if falhas:
        raise SystemExit(f'{falhas} teste(s) falharam')
    print('8/8 testes funcionais e contagens dinamicas consistentes. Isto nao valida ciclos, stalls nem montagem no EduMIPS64.')


if __name__ == '__main__':
    verificar()
