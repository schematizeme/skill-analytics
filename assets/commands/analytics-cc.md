---
description: schematize-analytics — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/` no par
**context + checklist** do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`), FEITO vs
ABERTO. Inclua: eventos adicionados ou alterados no plano, achados do `scripts/check-tracking.sh` que
ficaram abertos, waivers (`tracking-ok:`) com motivo, experimentos em curso e decisões de base legal
pendentes de revisão humana. Nunca inclua chave de API, dado pessoal ou export. Só então rode
`/compact`.
