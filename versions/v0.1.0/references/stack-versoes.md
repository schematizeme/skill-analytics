# Anexo volátil — versões, licenças e fatos de analytics

> Parte da skill **schematize-analytics**. **Fonte volátil:** versão, licença, limite de plano e
> orientação regulatória mudam. O corpo normativo diz **princípio**; o fato mora aqui, com data e fonte.
>
> **Verificado em: 2026-10-14.** Cadência: revisão trimestral e antes de cada release da skill.
> Método: API de releases e `LICENSE` dos repositórios no GitHub (`gh api`), e uma busca web para os
> fatos regulatórios e de produto fechado. O que veio só de blog de terceiros está marcado.

## Ferramentas (código aberto, verificado nos repositórios)

| Ferramenta | Release corrente (2026-10-14) | Licença | Fonte | Nota |
|---|---|---|---|---|
| **Umami** | v3.4.0 (2026-09-17) | MIT | `umami-software/umami` (API do GitHub) | self-host Node + banco relacional |
| **Plausible Analytics (Community Edition)** | v3.2.1 (2026-05-15) | AGPL-3.0 | `plausible/analytics` (API do GitHub) | AGPL: leia as implicações antes de modificar e servir |
| **PostHog** | sem tag de produto estável na API de releases (a API devolve releases de `desktop-` e `agent-`) <!-- reverificar o esquema de versão --> | MIT, exceto o diretório `ee/` sob licença própria | `PostHog/posthog` (`LICENSE` lido; a API devolve "NOASSERTION" por ser licença mista) | o que está sob `ee/` não é MIT: confira antes de self-host comercial |
| **GrowthBook** | v5.1.0 (2026-09-22) | <!-- reverificar --> | `growthbook/growthbook` | experimentação e flags, self-host ou cloud |
| **Unleash** | v8.2.0 (2026-09-08) | <!-- reverificar --> | `Unleash/unleash` | feature flags |
| **OpenFeature (spec)** | v0.9.0 | Apache-2.0 <!-- reverificar --> | `open-feature/spec` | padrão aberto de avaliação de flag |

## Produto fechado e planos (não verificado no site oficial)

- **GA4:** retenção de dados de evento para Explorações com padrão de **2 meses** e máximo de
  **14 meses** na versão gratuita, configurável em Admin > Configurações de dados > Retenção; não
  é retroativa e não afeta os relatórios padrão. Fonte: blogs de terceiros (analyticsmania.com,
  optizent.com e outros), um deles divergente sobre o padrão. <!-- reverificar na Central de Ajuda do Google Analytics -->
- **Preços e limites** de PostHog Cloud, Plausible hospedado, Amplitude, Mixpanel: não verificados;
  consulte a página de preços no momento da decisão. <!-- reverificar -->
- **Consent mode do Google** (sinais de consentimento para tags): requisitos vigentes
  <!-- reverificar -->.

## Regulatório (LGPD / ANPD)

- Guia orientativo **"Cookies e Proteção de Dados Pessoais"** da ANPD, publicado em outubro de 2022
  (versão em PDF em gov.br/anpd). Pontos usados: consentimento não é a base adequada para cookies
  estritamente necessários; consentimento é o mais adequado para cookies não essenciais; caixas
  pré-marcadas e consentimento tácito não são recomendados; legítimo interesse pode servir a cookies
  analíticos em vários contextos; para publicidade tende a não servir. Fonte: resumos de escritórios
  de advocacia e do próprio PDF indexado na busca; o PDF não foi lido na íntegra nesta rodada.
  <!-- reverificar -->
- Blogs de 2026 comentam um guia definitivo sobre consentimento para cookies "esperado": **não
  confirmado**. <!-- reverificar -->
- Regulamento sobre transferência internacional e comunicação de incidente à ANPD: tratado em
  `schematize-incident` (prazo e forma devem ser verificados lá). <!-- reverificar -->

## O que foi executado nesta rodada

- `scripts/check-tracking.test.sh`: casos vermelhos e verdes plantados contra `check-tracking.sh`
  (sem dependência além de bash, awk, sed e grep).
- Nenhum SDK de analytics foi instalado nem exercitado contra ferramenta real.
