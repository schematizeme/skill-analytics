# Experimentação A/B — decidir com método

> Parte da skill **schematize-analytics**. Ferramenta de flag/experimento: `references/ferramentas.md`
> e `references/feature-flags.md`.

Experimento controlado responde "esta mudança **causa** a melhoria?". Feito errado, produz confiança
falsa — pior que não testar. O desenho inteiro é escrito **antes** de rodar.

## 1. Quando testar e quando não

- Teste quando há **tráfego suficiente** para detectar o efeito em tempo razoável e a decisão muda
  conforme o resultado.
- **Não teste:** tráfego pequeno demais (use pesquisa qualitativa, teste de usabilidade, métrica antes
  e depois com ressalva), correção de bug óbvia, obrigação legal, mudança irreversível por natureza.
- Cálculo prévio diz se vale: se a amostra necessária leva meses, o experimento não decide nada.

## 2. Desenho (registre num arquivo antes de ligar)

1. **Hipótese:** "Se [mudança], então [métrica] [sobe/desce] porque [mecanismo]."
2. **Métrica primária** única, do `references/metricas.md`; **secundárias** só para interpretar.
3. **Guardrails:** o que não pode piorar (erro, latência, cancelamento, receita por usuário).
4. **População e unidade de aleatorização:** quem entra (critério de elegibilidade aplicado **antes**
   da atribuição) e a unidade (usuário, conta/tenant, sessão). Em produto multi-tenant a unidade
   costuma ser a **conta**, para um time inteiro ver a mesma variante.
5. **MDE** (menor efeito que vale detectar), nível de significância (típico 0,05), poder (típico 0,8).
6. **Tamanho de amostra** e duração calculados (§3), cobrindo pelo menos um ciclo semanal completo.
7. **Regra de parada** fixa: data ou tamanho; não "quando der significante".
8. **Plano de análise:** teste estatístico, correções, segmentos permitidos (poucos, declarados).

## 3. Tamanho de amostra (proporção, dois braços)

Por braço, aproximação com variância combinada:

```
n ≈ 2 · (z_{1-α/2} + z_{poder})² · p̄(1 − p̄) / d²
```

com `d` = diferença absoluta mínima, `p̄` = média das taxas. Para α = 0,05 bilateral e poder 0,8,
`(1,96 + 0,84)² ≈ 7,84`.

Exemplo: taxa base 10 %, MDE de +2 p.p. (para 12 %): `p̄ = 0,11`, `p̄(1−p̄) = 0,0979`,
`n ≈ 2 · 7,84 · 0,0979 / 0,02² ≈ 3.840` **por braço**. Metade do efeito (MDE de 1 p.p.) exige cerca de
**quatro vezes** a amostra. Use calculadora/biblioteca estatística para o caso real; a ordem de
grandeza acima basta para saber se o teste cabe no tráfego.

## 4. SRM — a primeira checagem de qualquer leitura

**Sample Ratio Mismatch:** a divisão observada entre braços difere da planejada além do acaso (esperava
50/50 e veio 52/48 com amostra grande). Teste qui-quadrado de aderência contra a razão planejada;
`p < 0,001` (limiar comum) = **SRM**.

- SRM **invalida** o resultado: há viés no pipeline (bug de atribuição, redirect que perde tráfego,
  bot, filtro aplicado só a um braço, evento que não dispara numa variante).
- Corrija a causa e **rode de novo**. Não "ajuste" nem analise mesmo assim.

## 5. Peeking e parada

- Olhar o p-valor todo dia e parar quando cruza 0,05 **infla o falso positivo** (pode passar de 20 %).
- Escolha **uma**: (a) horizonte fixo, só se lê no fim; ou (b) método sequencial/bayesiano **projetado
  para olhar continuamente** (teste sequencial, limites de gasto de alfa), no plano antes de ligar.
- Rodar além do planejado "para ver se melhora" é a mesma falha.

## 6. Múltiplas comparações

Muitas métricas, segmentos ou variantes aumentam a chance de um falso positivo. Declare **uma**
primária; corrija (Bonferroni, Holm, controle de FDR) quando houver várias; trate achado em
segmento não planejado como **hipótese para o próximo experimento**.

## 7. Guardrails e decisão

- Resultado positivo na primária **com** guardrail estável: lança. Positivo com guardrail degradado:
  decisão humana explícita, registrada.
- Inconclusivo (intervalo cobre zero e o MDE): **não** é "não funcionou"; é "não sabemos". Registre o
  intervalo, não só o p-valor; decida pelo custo/risco, ou aumente a amostra num novo experimento.
- Efeito de novidade e de aprendizado: mudança visível ganha cliques no começo; deixe estabilizar.
- **Interferência:** usuários que se influenciam (rede, marketplace, tenant compartilhado) violam a
  independência; aleatorize por cluster (conta).

## 8. Higiene

- Aleatorização **determinística** por ID opaco + sal do experimento (a mesma pessoa vê a mesma
  variante), sem depender de cookie quando houver login.
- Exposição registrada no momento em que a variante é **vista**, não na atribuição (evento
  `experimento_exposto` com `experimento` e `variante` no plano).
- Um usuário em muitos experimentos simultâneos: mantenha camadas/ortogonalidade ou exclusão mútua
  quando as mudanças interagem.
- Experimento é **dado de usuário sob consentimento**: sem consentimento, atribua a variante controle
  e não registre, ou use medição agregada.
- Ao fim: **encerre e remova** a flag e o código da variante perdedora (`references/feature-flags.md`).
- Resultado e decisão num registro (ADR leve) para o time não repetir o teste.
