---
name: schematize-analytics
metadata:
  version: 0.1.0
description: >-
  Analytics de produto privacy-first: tracking plan, consentimento LGPD sem PII, métricas, A/B. Use ao instrumentar evento ou métrica. Gate check-tracking.sh. Dados: schematize-data.
---
<!-- cross-skill: efeitos-externos.md, iam.md, observabilidade.md -> schematize-engineering -->

# Analytics de produto da casa (schematize-analytics)

Número sem definição é opinião com gráfico. Esta skill é a **DONA** da medição de **comportamento de
produto**: o que se mede (tracking plan versionado, como contrato), com que direito (consentimento
LGPD, sem PII em evento), com que ferramenta (first-party, privacy-first), com que definição
(ativação, retenção, funil, North Star) e com que método de decisão (experimento A/B e feature flag).
A tese: **evento é contrato e dado pessoal é passivo** — todo evento sem dono, sem nome padrão ou com
e-mail dentro é dívida que o time paga na análise errada e na auditoria da LGPD.

**Versão:** skill `schematize-analytics` v0.1.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é **transversal** (não é linguagem): detalha a medição de produto que a base exige em privacidade e dados (`schematize-engineering` → `references/dados-eventos.md`, `references/seguranca.md`). **Onde divergir da base em piso, a base manda**; aqui mora o *como*, o padrão e o gate." cmd="analytics" -->Esta skill é **transversal** (não é linguagem): detalha a medição de produto que a base exige em privacidade e dados (`schematize-engineering` → `references/dados-eventos.md`, `references/seguranca.md`). **Onde divergir da base em piso, a base manda**; aqui mora o *como*, o padrão e o gate.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/analytics-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Fronteira com as outras skills

| Assunto | Dono | Ponteiro |
|---|---|---|
| **O que medir do produto, tracking plan, consentimento de analytics, métricas de produto, experimento, flag** | **esta skill** | `references/*.md` abaixo |
| Pipeline, warehouse, modelagem do dado já coletado, qualidade e lineage, PII/LGPD no armazenamento | `schematize-data` | `schematize-data → references/pipelines.md`, `governanca.md`; aqui só o evento na origem |
| Telemetria **técnica** (traces, métricas de sistema, logs, SLO, alerta) | `schematize-observability` | `schematize-observability → references/padrao-otel.md`; aqui só comportamento de usuário |
| Tráfego orgânico, indexação, Search Console, medição de SEO | `schematize-seo` | `schematize-seo → references/medicao.md`; aqui o produto depois do clique |
| Implementação no front (banner de cookie, script, RSC, CSP, CWV do script de terceiro) | `schematize-web` | `schematize-web → references/seguranca.md`, `performance.md`; aqui o contrato do evento |
| Identidade do usuário (ID interno, nunca e-mail) | `schematize-iam` | `schematize-engineering → references/iam.md`; aqui só: o `distinct_id` é o ID opaco |
| Textos legais (política de privacidade, cookies) | `schematize-institutional` | scaffold com revisão jurídica humana; aqui o desenho técnico do consentimento |
| Vazamento de dado de tracking / incidente de privacidade | `schematize-incident` | `schematize-incident → references/lgpd.md`; aqui o que o plano deveria ter impedido |
| Evento de pagamento/cobrança (valor, estado) | `schematize-payments` | o dado financeiro é do ledger, não do tracking; aqui só o evento de comportamento |
| ADR (escolha de ferramenta, base legal) | `schematize-docs` | decisões que esta skill manda registrar |

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/analytics-help` | lista os comandos |
| `/analytics-load` | carrega à força o corpo normativo (plano, consentimento, ferramentas, métricas, experimento, flags) |
| `/analytics-plan` | cria ou evolui o `tracking-plan.yml` (evento `objeto_acao`, dono, propriedades) antes do código |
| `/analytics-review` | roda o gate `check-tracking.sh` e lê o que a máquina não lê (consentimento, ferramenta, definição) |
| `/analytics-consent` | desenha o consentimento: base legal por finalidade, opt-in do não essencial, modo sem cookie |
| `/analytics-metric` | define métrica com definição única (fórmula, janela, população, fonte) e a North Star |
| `/analytics-experiment` | desenha experimento A/B: hipótese, amostra, guardrails, SRM, regra de parada |
| `/analytics-claude` | cria/mescla o `CLAUDE.md` sempre-on de analytics na raiz do repo |
| `/analytics-cc` · `/analytics-handoff` | context compact / handoff arquivado |

## Como usar

1. **Plano antes do código** (`references/plano-de-tracking.md`): evento nasce no `tracking-plan.yml`,
   com dono e propriedades fechadas, nome `objeto_acao`. Só depois o `track(...)`.
2. **Rode o gate:** `bash scripts/check-tracking.sh .` — `0` passa · `1` reprova · `2` **nada para
   verificar** (que não é aprovação). Cruza código e plano: evento não declarado, propriedade fora do
   plano, nome fora do padrão, PII em chave, em valor ou em `identify`, SDK sem gate de consentimento.
3. **Consentimento e minimização** (`references/consentimento-lgpd.md`): base legal por finalidade,
   opt-in para o não essencial, sem PII em evento; preferir medição sem cookie.
4. **Ferramenta first-party** (`references/ferramentas.md`): PostHog, Plausible, Umami ou GA4 por
   critério objetivo e ADR; proxy no próprio domínio.
5. **Métrica com definição única** (`references/metricas.md`) e **decisão por experimento**
   (`references/experimentacao.md`, `references/feature-flags.md`).

Mapa de references:

| Tarefa | Reference |
|---|---|
| Formato do `tracking-plan.yml`, nome `objeto_acao`, propriedades, versionamento, dono, ciclo de vida do evento, o que o gate checa | `references/plano-de-tracking.md` |
| LGPD aplicada: finalidade, base legal (consentimento x legítimo interesse), opt-in, o que é PII, ID opaco, retenção, direitos do titular, ambientes | `references/consentimento-lgpd.md` |
| PostHog x Plausible x Umami x GA4: critérios, hospedagem, first-party/server-side, proxy, custo de decidir errado | `references/ferramentas.md` |
| Ativação, retenção por coorte, funil, North Star, definição única, armadilhas de dashboard | `references/metricas.md` |
| A/B: hipótese, MDE, tamanho de amostra, SRM, peeking, guardrails, múltiplas comparações, quando não testar | `references/experimentacao.md` |
| Feature flags: tipos, ciclo de vida, dívida de flag, flag x experimento, kill switch | `references/feature-flags.md` |
| Versões, licenças, o que foi verificado e quando (anexo volátil) | `references/stack-versoes.md` |

Assets prontos: `assets/tracking-plan.example.yml` (plano de exemplo no formato que o gate lê) ·
`assets/CLAUDE.md` (piso sempre-on) · `assets/commands/` (comandos).

## Pisos inegociáveis (vetam o atalho)

1. **Evento é contrato.** Todo evento disparado está no `tracking-plan.yml` versionado, com `owner` e
   propriedades fechadas. Evento fora do plano reprova na CI; mudança de significado é evento novo.
2. **Nome `objeto_acao`**, snake_case minúsculo, no passado ou fato consumado (`pedido_pago`,
   `cadastro_concluido`). Nada de `click`, `Button Clicked`, `evento1`, camelCase.
3. **Sem PII em evento, propriedade, URL ou `identify`.** E-mail, CPF, telefone, nome, endereço, IP
   bruto e token não entram. O usuário é o **ID interno opaco** (identidade ≠ e-mail).
4. **Consentimento antes da coleta não essencial.** Analytics que identifica, cruza ou segue o titular
   exige opt-in livre e granular, recusar tão fácil quanto aceitar e prova do consentimento. Medição
   agregada sem cookie e sem identificador persistente é o caminho de menor atrito.
5. **First-party e minimização.** Coleta pelo próprio domínio (proxy/server-side), só o necessário à
   finalidade declarada, com retenção definida. Terceiro recebe o mínimo; recebedor é operador com
   contrato.
6. **Métrica tem uma definição só**, escrita (fórmula, janela, população, fonte), com dono. Dois
   dashboards com o mesmo nome e números diferentes é incidente de dado.
7. **Retenção por coorte, não média global.** Ativação é um evento de valor definido, não "fez login".
   Uma North Star que o produto move, acompanhada de métricas de controle.
8. **Experimento se desenha antes de rodar:** hipótese, métrica primária, MDE, amostra calculada,
   guardrails e regra de parada **escritos antes**. Olhar e parar quando o p cruza 0,05 (peeking) é
   vetado; **SRM reprova o resultado** antes de qualquer leitura.
9. **Flag tem dono, data de remoção e kill switch.** Flag de experimento não vira configuração
   permanente; flag velha é dívida e é removida.
10. **Evento de ambiente não-prd nunca entra no projeto de prd.** Projeto/chave de analytics separados
    por ambiente; teste e CI usam sink descartável. Dados de prd não vão a ferramenta de demo.
11. **Telemetria técnica não é analytics.** Latência, erro e saturação vão para a observabilidade
    (`schematize-observability`); comportamento de usuário, para cá. Não misturar nem duplicar.
12. **Decisão de ferramenta e de base legal vira ADR** (`schematize-docs`), com revisão jurídica
    humana do texto de privacidade.
13. <!-- herdado:engineering/efeito-externo:invariantes -->**Cap por execução** (`MAIL_MAX_PER_RUN`, default 50) com abort; **fail-closed** (ambiente ausente/desconhecido ⇒ não-prd; só o valor exato de produção entrega de verdade); **chave sandbox** fora de prd. Todo endereço sintético (fixture, seed, persona, demo, carga) é `<papel>+<run-id>-<n>@test.<domain>` — domínio em **rota nula** (null MX RFC 7505 + SPF `-all` + DMARC `p=reject`) ou TLD reservado (`.test`/`.invalid`/`.example`); **VETADO** `@gmail.com`, domínio de cliente/terceiro, e-mail de pessoa real (**inclusive o seu**) e o domínio de produção. A recusa é **erro**, nunca warning nem sucesso silencioso. Entregar de verdade fora de prd exige **as cinco** (ADR + allowlist ≤5 + cap + janela + subdomínio separado). Motivo: bounce/complaint em massa **queima IP e domínio** e derruba o transacional de prd — inclusive o **OTP de login** — com semanas de warm-up e utilidade zero (o incidente dos 5.000 e-mails só existiu porque nada contava).<!-- /herdado -->
14. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Regra de mídia

Gráfico de dashboard sai do dado, em código (`schematize-design` para o visual). Imagem ou mídia
gerada **nunca** por modelo Claude: detecte Codex e Gemini disponíveis e **pergunte ao usuário qual
usar**. Nenhum disponível: avise sem rodeio que visual gerado pelo Claude tem qualidade inversamente
proporcional à de código (sai ruim de verdade) e ofereça alternativas — instalar Codex ou Gemini,
imagem de banco com licença comercial, ou asset do cliente. Claude é o melhor em código.

## Relação com as outras skills

- **`schematize-data`** — recebe o evento depois da coleta: contrato de dado, pipeline, warehouse,
  quarentena. O tracking plan é o contrato **na origem**; o de lá é o contrato **no trânsito**.
- **`schematize-observability`** — o outro tipo de telemetria: sistema, não pessoa.
- **`schematize-seo`** — o tráfego que chega; esta skill, o que o usuário faz depois.
- **`schematize-web`** — onde o script roda: CSP, carregamento, banner; o contrato do evento é daqui.
- **`schematize-engineering`** — a base: privacidade (LGPD), efeito externo, IAM, DoD e archive.
- **`schematize-docs`** — ADR e runbook das decisões desta skill.
