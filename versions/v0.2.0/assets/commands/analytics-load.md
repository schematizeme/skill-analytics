---
description: schematize-analytics — carrega à força TODO o corpo normativo de analytics de produto e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-analytics`. A partir daqui, nesta sessão,
isto **não é opcional**.

1. **Leia na íntegra, sem trabalhar de memória.** Caminho:
   `.claude/skills/schematize-analytics/references/*.md` (projeto) ou
   `~/.claude/skills/schematize-analytics/references/*.md` (global):
   - `plano-de-tracking.md` — `tracking-plan.yml`, nome `objeto_acao`, propriedades fechadas, dono,
     ciclo de vida, o que o gate pega.
   - `consentimento-lgpd.md` — finalidade, base legal, opt-in, o que é PII, ID opaco, retenção,
     first-party, ambientes.
   - `ferramentas.md` — PostHog, Plausible, Umami, GA4: critérios, coleta client/server/proxy.
   - `metricas.md` — ficha de métrica, ativação, retenção por coorte, funil, North Star.
   - `experimentacao.md` — hipótese, MDE, amostra, SRM, peeking, guardrails.
   - `feature-flags.md` — tipos, ciclo de vida, kill switch, dívida de flag.
   - `stack-versoes.md` — anexo volátil: versões, licenças, o que foi verificado e quando.
2. **Rode o gate no repo atual** antes de opinar:
   `bash .claude/skills/schematize-analytics/scripts/check-tracking.sh .`
3. **Aplique daqui em diante** a todo evento que você escrever ou tocar, e diga qual piso está
   aplicando quando ele mudar o que você ia fazer. Nunca coloque PII em evento; nunca dispare evento
   fora do plano.
