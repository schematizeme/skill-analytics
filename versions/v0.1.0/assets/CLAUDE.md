# Piso de analytics de produto (schematize-analytics) — sempre-on

Evento é contrato; dado pessoal é passivo. Telemetria de comportamento, nunca de pessoa identificável.

1. **Tracking plan é o contrato.** Todo evento disparado está no `tracking-plan.yml` versionado, com
   `owner` e propriedades fechadas. Evento fora do plano reprova na CI. Mudou o significado: evento novo.
2. **Nome `objeto_acao`**, snake_case minúsculo, fato consumado (`pedido_pago`). Nada de `click`,
   camelCase, `Button Clicked`.
3. **Sem PII em evento, propriedade, URL ou `identify`:** e-mail, CPF, telefone, nome, endereço, IP bruto,
   token. O usuário é o **ID interno opaco** (identidade ≠ e-mail). Texto livre não vira propriedade.
4. **Consentimento antes da coleta não essencial.** Opt-in livre e granular, recusar tão fácil quanto
   aceitar, prova guardada. Preferir medição sem cookie e first-party (proxy/server-side).
5. **Métrica tem uma definição só** (fórmula, janela, população, fonte, dono). Retenção por coorte com
   ação de valor; ativação é evento de valor, não login. Eventos de receita vêm do servidor.
6. **Experimento se desenha antes:** hipótese, métrica primária, MDE, amostra, guardrails, regra de
   parada. Sem peeking; **SRM invalida** o resultado.
7. **Flag tem dono, data de remoção e kill switch**; flag de permissão é autorização, não flag.
8. **Chave de analytics separada por ambiente**; dev/hml/CI nunca escrevem no projeto de prd.
9. Telemetria técnica (latência, erro, SLO) vai para a observabilidade, não para analytics.
10. Escolha de ferramenta e de base legal em ADR; texto de privacidade com revisão jurídica humana.
11. <!-- herdado:engineering/efeito-externo:invariantes -->**Cap por execução** (`MAIL_MAX_PER_RUN`, default 50) com abort; **fail-closed** (ambiente ausente/desconhecido ⇒ não-prd; só o valor exato de produção entrega de verdade); **chave sandbox** fora de prd. Todo endereço sintético (fixture, seed, persona, demo, carga) é `<papel>+<run-id>-<n>@test.<domain>` — domínio em **rota nula** (null MX RFC 7505 + SPF `-all` + DMARC `p=reject`) ou TLD reservado (`.test`/`.invalid`/`.example`); **VETADO** `@gmail.com`, domínio de cliente/terceiro, e-mail de pessoa real (**inclusive o seu**) e o domínio de produção. A recusa é **erro**, nunca warning nem sucesso silencioso. Entregar de verdade fora de prd exige **as cinco** (ADR + allowlist ≤5 + cap + janela + subdomínio separado). Motivo: bounce/complaint em massa **queima IP e domínio** e derruba o transacional de prd — inclusive o **OTP de login** — com semanas de warm-up e utilidade zero (o incidente dos 5.000 e-mails só existiu porque nada contava).<!-- /herdado -->
12. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

Mídia: imagem/visual gerado nunca por modelo Claude; detecte Codex/Gemini e pergunte qual usar.

Gate: `bash .claude/skills/schematize-analytics/scripts/check-tracking.sh .` — waiver rastreável
`// tracking-ok: <motivo>`.
