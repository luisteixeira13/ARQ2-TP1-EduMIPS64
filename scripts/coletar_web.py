#!/usr/bin/env python3
"""Captura assistida: o OPERADOR executa EduMIPS64 Web e transcreve Stats. Não simula CPU."""
from pathlib import Path
from datetime import datetime, timezone
import csv
import sys
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'resultados/tabelas/medicoes_web_coleta_manual.csv'
IMAGES=ROOT/'resultados/imagens/coleta_web'
CASES=[(n,f) for n in (10,20,50) for f in ('OFF','ON')]+[(0,'ON')]
COLS=['arquivo','N','forwarding','IC','CC','RAW','WAW','estruturais','branch_stalls','CPI','build_web','coletado_em_utc','evidencia_stats','evidencia_memoria','saida_conferida','origem']
def inteiro(pergunta,empty=False):
 while True:
  val=input(pergunta).strip()
  if empty and val=='':return ''
  if val.isdigit():return int(val)
  print('Informe um número inteiro não negativo.')
def add(row):
 old=[]
 if OUT.exists():
  with OUT.open(newline='',encoding='utf-8') as f:old=list(csv.DictReader(f))
 old=[x for x in old if (x['arquivo'],x['forwarding'])!=(row['arquivo'],row['forwarding'])]
 old.append(row)
 with OUT.open('w',newline='',encoding='utf-8') as f:
  w=csv.DictWriter(f,COLS);w.writeheader();w.writerows(old)
def main():
 try:from playwright.sync_api import sync_playwright
 except ImportError:sys.exit('Instale: python3 -m pip install playwright && python3 -m playwright install chromium')
 IMAGES.mkdir(exist_ok=True,parents=True)
 print('EduMIPS64 Web real: CPU Forwarding conforme o caso, Branch Delay Slot OFF; I/D cache 1024 B, bloco 16 B, assoc. 1.')
 build=input('Build exato exibido em Help > About (ou deixe em branco): ').strip() or 'Não identificado'
 with sync_playwright() as p:
  browser=p.chromium.launch(headless=False)
  page=browser.new_page(viewport={'width':1680,'height':1000})
  try:page.goto('https://web.edumips.org/',wait_until='domcontentloaded',timeout=60000)
  except Exception as e:
   print('Não foi possível acessar web.edumips.org:',e);browser.close();return 1
  for n,fw in CASES:
   file=(ROOT/'programas/programa3_matrizes_otimizado.s' if n==0 else ROOT/f'experimentos_tamanho/programa1_n{n:02}.s')
   prefix=f'programa3_otimizado_{fw}' if n==0 else f'programa1_n{n:02}_{fw}'
   print('\n>>>',file,'/ Forwarding',fw)
   print('No editor Web, abra este arquivo .s, configure forwarding, Load Program e Run All. Espere terminar.')
   if n:print('IC independente esperado:',7+9*n, '| C começa em',hex(16*n),'e termina em',11*n)
   else:print('Memory esperado: 0x60=3A, 0x68=40, 0x70=8B, 0x78=9A.')
   input('Abra Statistics e tecle ENTER para tirar print: ')
   ps=IMAGES/f'{prefix}_stats.png';page.screenshot(path=str(ps))
   if n:
    print('TRANSCRITAR do painel Statistics, sem copiar projeções do relatório:')
    ic=inteiro('  Instructions: ');cc=inteiro('  Cycles: ')
    raw=inteiro('  RAW stalls: ');waw=inteiro('  WAW stalls: ')
    st=inteiro('  Structural stalls: ')
    if ic!=7+9*n:print('ALERTA: IC diverge! Confira o arquivo carregado antes de aceitar.')
    branch='N/D'
    cpi=round(cc/ic,6) if ic else ''
   else:ic=cc=raw=waw=st=cpi='';branch='N/D'
   print('Agora expanda Memory, role até a saída C e confira todos os valores.')
   input('Com a saída C visível, tecle ENTER para registrar print: ')
   pm=IMAGES/f'{prefix}_memory.png';page.screenshot(path=str(pm))
   resposta=input('Saída C conferida e correta? (s/n): ').strip().lower()
   row=dict(arquivo=str(file.relative_to(ROOT)),N=n or '',forwarding=fw,IC=ic,CC=cc,RAW=raw,WAW=waw,estruturais=st,branch_stalls=branch,CPI=cpi,build_web=build,coletado_em_utc=datetime.now(timezone.utc).isoformat(),evidencia_stats=str(ps.relative_to(ROOT)),evidencia_memoria=str(pm.relative_to(ROOT)),saida_conferida='sim' if resposta=='s' else 'não',origem='Execução real no EduMIPS64 Web, transcrita pelo operador')
   add(row);print('CSV salvo:',OUT)
   print('Use Stop/Reset antes de alternar a configuração para o próximo caso.')
  browser.close()
 print('Capturas e CSV produzidos. Só as seis linhas com N>0 contêm métricas transcritas pelo operador.')
 return 0
if __name__=='__main__':raise SystemExit(main())
