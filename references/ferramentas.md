# Ferramentas de analytics — comparar por critério, decidir por ADR

> Parte da skill **schematize-analytics**. Versões e licenças mudam: o número mora em
> `references/stack-versoes.md`, com data e fonte.

Nenhuma ferramenta é "a da casa". A escolha é por repo/produto, por critério abaixo, registrada em
ADR (`schematize-docs`). Duas coisas pesam mais do que a lista de recursos: **onde o dado mora** e
**se a ferramenta se contenta com ID opaco**.

## 1. Perfil de cada uma (resumo)

| Ferramenta | Perfil | Quando é o fit | Cuidado |
|---|---|---|---|
| **Plausible** | métricas agregadas, sem cookie, script minúsculo; versão hospedada e self-hosted (Community Edition) | site/landing/blog; saber de onde vem o tráfego e que páginas convertem, sem banner | sem retenção por usuário; funil e eventos custom existem, análise de coorte não |
| **Umami** | semelhante ao Plausible, self-hosted simples (Node + Postgres), licença MIT | quer self-host barato e controle total do dado | idem: audiência agregada; menos recursos de produto |
| **PostHog** | plataforma de produto: eventos, funil, retenção, coorte, session replay, feature flags, experimentos, tudo no mesmo lugar; cloud (US/UE) ou self-host | produto web/app que precisa de funil, retenção e experimento com flags no mesmo modelo de dado | self-host em escala é operação séria; replay e identidade pedem consentimento e mascaramento |
| **GA4** | gratuito, integração com Google Ads/BigQuery | vive de mídia paga no ecossistema Google | dado vai para o Google (transferência, perfilamento): exige consentimento e ADR; retenção de eventos limitada; exportação ao BigQuery para análise séria; <!-- reverificar --> regras de consent mode vigentes |

Também existem Matomo, Mixpanel, Amplitude, Fathom e outras: avalie com os mesmos critérios.

## 2. Critérios (preencha no ADR)

1. **Pergunta que a ferramenta precisa responder.** Audiência (de onde vem, o que lê) ou produto
   (ativação, retenção, funil, experimento)? Quem só precisa da primeira não deveria carregar a
   segunda.
2. **Residência e operador.** Onde o dado fica (BR, UE, EUA), quem é o operador, há contrato e
   mecanismo de transferência internacional? Self-hosted mantém tudo sob controle, ao custo de operar.
3. **Identidade.** Funciona só com ID opaco, sem e-mail? Aceita `distinct_id` seu? Permite
   `cookieless`/memória e desligar IP e fingerprint?
4. **Controles de privacidade.** Exclusão por ID (direito do titular), retenção configurável,
   mascaramento de replay, descarte de IP, opt-out por API.
5. **Exportação e saída.** Dá para tirar o dado bruto (API, S3, warehouse) para o pipeline da
   `schematize-data`? Preso à interface = preso ao fornecedor.
6. **Custo total.** Assinatura por evento cresce com sucesso; self-host custa operação (banco
   analítico, upgrade, backup). Estime com o volume previsto, não o atual.
7. **Peso no front.** Tamanho do script e impacto em Core Web Vitals (`schematize-web →
   references/performance.md`); carregamento depois do consentimento e fora do caminho crítico.
8. **Licença.** Código aberto de verdade (MIT, AGPL) ou fonte disponível? Self-host comercial muda
   com a licença; leia o arquivo `LICENSE` do repo.

## 3. Como coletar

- **Client + proxy first-party:** o navegador envia para `https://seudominio/a/...`, que repassa à
  ferramenta. Menos bloqueio, sem domínio de terceiro na CSP, IP tratado por você.
- **Server-side:** eventos de fato (`pedido_pago`, `assinatura_cancelada`) emitidos pelo backend, com
  o ID opaco, depois do fato commitado (padrão Outbox quando a perda importa,
  `schematize-data → references/pipelines.md`). Mais confiável que o navegador.
- **Híbrido:** gesto/visualização no cliente (descartável), fato de negócio no servidor (confiável).
  Mesmo nome de evento e mesmo plano nos dois lados; dedupe por `event_id` se houver dupla emissão.
- **Identificação:** `identify` com o ID opaco **depois** de autenticado e com consentimento; antes,
  anônimo. Logout reseta o ID anônimo.
- **Bloqueadores** (adblock, ITP) subestimam o cliente; por isso métrica de receita vem do servidor.

## 4. Anti-padrões

- Instalar GA4 "por padrão" e descobrir depois que precisava de banner, ADR e transferência.
- Duas ferramentas contando a mesma coisa (cada uma com número diferente) sem dizer qual é a fonte.
- Chave de prd no ambiente de dev; replay gravando campo de senha.
- Dado de analytics virando CRM (e-mail "só para segmentar"): finalidade desviada.
