# Métricas de produto — definição única

> Parte da skill **schematize-analytics**. Gate: o evento que alimenta a métrica está no tracking
> plan (`references/plano-de-tracking.md`).

Métrica sem definição escrita vira duas métricas com o mesmo nome. Cada uma abaixo tem **dono**,
**fórmula**, **janela**, **população**, **fonte** e **versão**, num arquivo do repo (`metricas.md` ou
catálogo de métricas) e um único lugar de cálculo (query/view versionada na `schematize-data`).

## 1. Ficha de métrica (modelo)

```
nome:        usuarios_ativados_7d
definição:   usuários que fizeram `projeto_criado` E `convite_enviado` em até 7 dias do `cadastro_concluido`
numerador:   usuários da coorte que cumpriram o critério
denominador: usuários que fizeram `cadastro_concluido` no período
janela:      7 dias corridos, fuso America/Sao_Paulo
exclui:      contas internas, bots, contas de teste
fonte:       tabela analytics.eventos (view v_ativacao), dono: time-growth
versão:      2 (2026-10-14: critério passou de 1 para 2 ações)
```

Mudou fórmula, janela ou população: **versão nova** e anotação no gráfico; a série antiga não é
reescrita em silêncio.

## 2. Ativação

- É o **momento em que o usuário recebe o valor** pela primeira vez, definido por um evento de valor,
  não por "criou conta" ou "fez login". Ex.: primeira fatura emitida, primeiro dashboard com dado.
- Ache o evento pela análise (que comportamento no início separa quem fica de quem some) e fixe-o.
  Depois mede-se: **taxa de ativação** = ativados na janela / cadastros da coorte; **tempo até a
  ativação** (mediana, não média).

## 3. Retenção por coorte

- **Coorte** = usuários agrupados pelo período de entrada (semana do cadastro). Retenção no dia/semana
  N = fração da coorte que voltou e fez a **ação de valor** naquele período.
- Leia a **curva** de cada coorte: ela achata (produto tem núcleo fiel) ou cai a zero (não tem)?
  Média global mistura coortes velhas e novas e esconde as duas coisas.
- Defina "ativo" pela ação de valor, não por abrir o app. Retenção por abrir é vaidade.
- Retenção de **receita** (líquida, de coorte, com expansão e cancelamento) é outra métrica, com a
  fonte no financeiro/ledger (`schematize-payments`), não em evento de navegador.

## 4. Funil

- Sequência **ordenada** de eventos do plano com **janela de conversão** explícita (ex.: 24 h entre
  passos). Sem janela, o funil conta gente que voltou em outro mês.
- Mede-se conversão passo a passo e a queda maior; investigue a queda com segmentação (dispositivo,
  origem, versão), não só com o número.
- Funil de interface depende de evento de cliente (sujeito a bloqueio); passo de receita vem do
  servidor.

## 5. North Star e métricas de controle

- **North Star:** uma métrica que captura o valor entregue ao usuário e que o time consegue mover
  (ex.: "projetos com ao menos 2 colaboradores ativos na semana"). Não é receita nem cadastros.
- Acompanhe com **inputs** (alavancas que o time controla: ativação, frequência, amplitude de uso) e
  **guardrails** (o que não pode piorar: latência, taxa de erro, cancelamento, reclamação).
- Revise a North Star quando o produto muda; registre em ADR.

## 6. Armadilhas

- **Métrica de vaidade:** cadastros acumulados, pageviews totais, downloads. Cresce sozinha.
- **Média sobre cauda longa:** use mediana e percentis.
- **Sobrevivente:** olhar só quem ficou superestima a retenção; mantenha o denominador da coorte.
- **Sazonalidade e fim de semana:** compare semana com semana equivalente.
- **Identidade partida:** o mesmo usuário em dois dispositivos conta como dois sem `identify` correto
  com o ID opaco.
- **Conta interna** no dado: filtro obrigatório e único (propriedade/lista), nunca ad hoc por query.
- **Dashboard como fonte da verdade:** o dashboard mostra; a definição mora no repo e na camada de
  dados.

## 7. Onde calcular

A métrica é calculada **uma vez**, em modelo versionado (view/dbt/SQL no repo) sobre o evento bruto
que cumpre o contrato do plano; dashboards só leem. Qualidade do dado (esquema do evento, atraso,
duplicata) é da `schematize-data → references/qualidade.md`.
