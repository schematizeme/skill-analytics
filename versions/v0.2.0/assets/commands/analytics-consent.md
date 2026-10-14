---
description: schematize-analytics — desenha o consentimento de analytics: base legal por finalidade, opt-in, modo sem cookie, prova e revogação.
argument-hint: "[produto ou finalidade]"
---

# /analytics-consent — com que direito se mede

1. Liste as **finalidades** de coleta (audiência agregada, funil de produto, replay, publicidade).
2. Para cada uma, proponha a **base legal** pela tabela de `references/consentimento-lgpd.md` §2 e
   marque o que depende de **revisão jurídica humana** (`schematize-institutional`). Registre a escolha
   em ADR (`schematize-docs`).
3. Decida **coleta sem cookie** quando a pergunta do produto permitir (`references/ferramentas.md`).
4. Para o que exige opt-in: gate no carregamento do SDK, granularidade por finalidade, recusar tão
   fácil quanto aceitar, prova (o quê, quando, versão do texto), revogação imediata. Banner e
   acessibilidade são do `schematize-web`.
5. Inventarie PII que hoje vaza (URL, propriedades, `identify`) com o gate
   (`scripts/check-tracking.sh`) e corrija.
6. Defina retenção e caminho de exclusão por ID opaco. Entregue o ADR e a lista de pendências humanas.
