---
description: schematize-analytics — desenha um experimento A/B antes de ligar: hipótese, métrica, MDE, amostra, guardrails, SRM e regra de parada.
argument-hint: "[mudança a testar]"
---

# /analytics-experiment — decidir com método

1. **Vale testar?** Calcule a amostra (`references/experimentacao.md` §3) contra o tráfego real. Se
   levar meses, proponha alternativa (qualitativo, antes/depois com ressalva).
2. Escreva o **desenho** num arquivo (§2): hipótese, métrica primária única, guardrails, população e
   unidade de aleatorização (conta em produto multi-tenant), MDE, alfa, poder, duração (ciclos
   semanais completos), **regra de parada fixa** e plano de análise.
3. Aleatorização **determinística** por ID opaco + sal; exposição registrada quando a variante é vista
   (evento no tracking plan). Sem consentimento: controle, sem registro.
4. Na leitura: **SRM primeiro** (§4). SRM reprova o resultado; corrija a causa e rode de novo.
5. Sem peeking (§5); múltiplas comparações corrigidas (§6); segmento não planejado é hipótese nova.
6. Decida com o guardrail (§7), registre resultado e decisão, **remova a flag** e o ramo perdedor
   (`references/feature-flags.md`).
