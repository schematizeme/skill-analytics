---
description: schematize-analytics — define uma métrica com definição única (fórmula, janela, população, fonte, dono) e a North Star.
argument-hint: "[métrica ou pergunta de negócio]"
---

# /analytics-metric — um nome, uma definição

1. Parta da **pergunta de decisão**; sem decisão, não há métrica.
2. Preencha a **ficha** de `references/metricas.md` §1: definição, numerador, denominador, janela e
   fuso, exclusões (contas internas, bots), fonte e dono, versão.
3. Para **ativação**, ache o evento de valor e fixe-o; para **retenção**, use coorte e ação de valor
   (`references/metricas.md` §2-3); para **funil**, passos ordenados com janela de conversão.
4. Confira que cada evento usado **está no tracking plan**; falta algum: `/analytics-plan`.
5. Se for a **North Star**, defina também os inputs e os guardrails; registre em ADR.
6. Aponte o **único lugar de cálculo** (view/modelo versionado, `schematize-data`). Dashboards só leem.
