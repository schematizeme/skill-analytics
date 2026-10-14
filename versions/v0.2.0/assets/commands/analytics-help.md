---
description: Mapa da skill schematize-analytics (analytics de produto privacy-first — evento é contrato, dado pessoal é passivo).
---
**schematize-analytics** — analytics de produto: tracking plan como contrato, consentimento LGPD, métricas com definição única, experimento A/B e feature flags.

| Comando | O que faz |
|---|---|
| `/analytics-help` | esta lista |
| `/analytics-load` | carrega à força TODO o corpo normativo (plano, consentimento, ferramentas, métricas, experimento, flags) e passa a aplicá-lo |
| `/analytics-plan` | cria ou evolui o `tracking-plan.yml` (evento `objeto_acao`, dono, propriedades) antes do código |
| `/analytics-review` | roda `scripts/check-tracking.sh` e lê o que a máquina não lê (consentimento, ferramenta, definição) |
| `/analytics-consent` | desenha o consentimento: base legal por finalidade, opt-in, modo sem cookie |
| `/analytics-metric` | define métrica com definição única e a North Star |
| `/analytics-experiment` | desenha experimento A/B: hipótese, amostra, guardrails, SRM, regra de parada |
| `/analytics-claude` | cria ou mescla o `CLAUDE.md` sempre-on de analytics na raiz do repo |
| `/analytics-cc` · `/analytics-handoff` | context compact / handoff no archive |

Pareia com: `schematize-data` (pipeline e warehouse), `schematize-observability` (telemetria técnica),
`schematize-seo` (tráfego orgânico), `schematize-web` (implementação no front), `schematize-docs` (ADR).
