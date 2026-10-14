---
description: schematize-analytics — cria ou evolui o tracking-plan.yml (evento objeto_acao, dono, propriedades fechadas) ANTES do código.
argument-hint: "[funcionalidade ou evento a medir]"
---

# /analytics-plan — o plano vem antes do `track(...)`

1. Pergunte a **decisão** que o evento vai apoiar (sem decisão, não há evento). Se for métrica
   existente, leia a ficha (`references/metricas.md`).
2. Leia o `tracking-plan.yml` atual (ou crie a partir de
   `.claude/skills/schematize-analytics/assets/tracking-plan.example.yml`).
3. Para cada evento novo: nome `objeto_acao` no passado (`references/plano-de-tracking.md` §2), `owner`,
   `description` (o fato de domínio, não o clique) e `properties` **fechadas**, sem PII
   (`references/consentimento-lgpd.md` §3). Mudou o significado de um evento existente: **evento novo**
   e o antigo vira depreciado.
4. Prefira emitir o fato de negócio **no servidor** (`references/ferramentas.md` §3).
5. Rode o gate e mostre a saída:
   `bash .claude/skills/schematize-analytics/scripts/check-tracking.sh .`
6. Entregue plano e código no mesmo diff. Nenhum `track(...)` sem entrada no plano.
