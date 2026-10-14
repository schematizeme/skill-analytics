---
description: schematize-analytics — revisa a instrumentação contra o piso: roda o gate check-tracking.sh e lê o que a máquina não lê.
argument-hint: "[diretório do projeto]"
---

# /analytics-review — evento é contrato, dado pessoal é passivo

## 1. A máquina primeiro

```bash
bash .claude/skills/schematize-analytics/scripts/check-tracking.sh "${ARGUMENTS:-.}"
```
`0` passa · `1` reprova · `2` **nada para verificar** — que não é aprovação.

O gate cobre: evento disparado e ausente do plano · propriedade fora do plano · nome fora de
`objeto_acao` · evento sem dono ou duplicado · PII por chave, por valor literal e por campo do usuário ·
`identify` com e-mail/CPF/telefone · SDK iniciado sem gate de consentimento. Waiver:
`// tracking-ok: <motivo>`.

## 2. Depois, o que a máquina não lê

- **PII em variável de nome neutro**, URL do `page_view` com query sensível, texto livre como
  propriedade, nome de evento montado em runtime.
- **Consentimento:** o SDK só inicia após o opt-in (ou em modo memória/sem cookie)? Recusar é tão fácil
  quanto aceitar? Há prova do consentimento? A base legal por finalidade está em ADR?
- **Identidade:** `distinct_id` é o ID interno opaco, nunca derivado de e-mail por hash simples?
- **Coleta:** first-party/proxy? Eventos de receita no servidor? Sem chave de prd em dev/hml/CI?
- **Métricas:** cada métrica tem ficha (fórmula, janela, população, fonte, dono)? Duas definições para o
  mesmo nome?
- **Experimentos ativos:** desenho escrito antes, amostra calculada, SRM checado, sem peeking, guardrails?
- **Flags:** dono e data de remoção; kill switch; flag velha a remover.
- **Retenção e direitos do titular:** prazo definido; caminho de exclusão por ID.
- **Separação:** telemetria técnica foi para a observabilidade, não para cá?

## 3. Feche

Achado vira correção no mesmo PR ou item de checklist com dono. O vermelho do próprio gate:
`bash scripts/check-tracking.test.sh`.
