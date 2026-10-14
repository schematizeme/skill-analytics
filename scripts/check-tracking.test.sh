#!/usr/bin/env bash
# Vermelho primeiro do gate check-tracking.sh. Cada caso é um mini-projeto com UM defeito (ou nenhum).
# PII e segredos de teste são montados em tempo de execução: nada de literal sensível no repo
# (o push protection do GitHub bloqueia, e o scanner da casa também).
#
# EXCEÇÃO DECLARADA (piso da schematize-shell, strict mode): harness de teste roda `set -u` sem `-e`
# — precisa continuar depois de um caso vermelho para reportar todos, em vez de parar no primeiro.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-tracking.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
ok=0; fail=0; D=""

novo() { D="$TMP/$1"; mkdir -p "$D"; NOME="$1"; }
f() { mkdir -p "$(dirname "$D/$1")"; cat >"$D/$1"; }
esperar() {
  local esp="$1" agulha="$2" saida rc
  saida="$(bash "$G" "$D" 2>&1)"; rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $NOME: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  ✖ $NOME: exit certo, saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ✔ $NOME"; ok=$((ok+1))
}

# valores sensíveis falsos, montados em runtime
EMAIL="fulano""@""exemplo"".com"
CPF="123"".456"".789""-09"

plano_bom() {
  f tracking-plan.yml <<'FIX'
version: 1
events:
  - name: cadastro_concluido
    owner: time-growth
    properties: [metodo, plano]
  - name: pedido_pago
    owner: time-receita
    properties: [valor_centavos, moeda]
FIX
}

echo "== verdes =="
novo verde-conforme; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "passkey", plano: "free" });
analytics.track("pedido_pago", { valor_centavos: 1990, moeda: "BRL" });
FIX
esperar 0 "ok"

novo verde-multilinha; plano_bom
f src/b.ts <<'FIX'
posthog.capture(
  "cadastro_concluido",
  {
    metodo: "email_otp",
    plano: "pro",
  },
);
FIX
esperar 0 "ok"

novo verde-waiver; plano_bom
f src/c.ts <<'FIX'
// tracking-ok: evento legado em migração, ADR-12
track("legado_clicado", { x: 1 });
track("cadastro_concluido", { metodo: "passkey" });
FIX
esperar 0 "ok"

novo verde-sdk-com-consentimento; plano_bom
f src/d.ts <<'FIX'
if (consentimento.analytics) {
  posthog.init("chave", { persistence: "memory" });
}
track("cadastro_concluido", { metodo: "passkey" });
FIX
esperar 0 "ok"

novo verde-identify-opaco; plano_bom
f src/e.ts <<'FIX'
posthog.identify(user.id);
track("pedido_pago", { moeda: "BRL" });
FIX
esperar 0 "ok"

echo "== vermelhos =="
novo vermelho-evento-nao-declarado; plano_bom
f src/a.ts <<'FIX'
track("compra_feita", { moeda: "BRL" });
FIX
esperar 1 "evento-nao-declarado"

novo vermelho-nome-camelcase; plano_bom
f src/a.ts <<'FIX'
track("cadastroConcluido", { metodo: "x" });
FIX
esperar 1 "nome-fora-do-padrao"

novo vermelho-nome-sem-objeto; plano_bom
f src/a.ts <<'FIX'
track("clique", {});
FIX
esperar 1 "nome-fora-do-padrao"

novo vermelho-pii-chave-email; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x", email: usuario.contato });
FIX
esperar 1 "pii-na-propriedade"

novo vermelho-pii-chave-telefone-multilinha; plano_bom
f src/a.ts <<'FIX'
analytics.track(
  "cadastro_concluido",
  {
    telefone: x,
  },
);
FIX
esperar 1 "pii-na-propriedade"

novo vermelho-pii-valor-email-literal; plano_bom
printf 'track("cadastro_concluido", { metodo: "%s" });\n' "$EMAIL" | f src/a.ts
esperar 1 "pii-no-valor"

novo vermelho-pii-valor-cpf-literal; plano_bom
printf 'track("cadastro_concluido", { plano: "%s" });\n' "$CPF" | f src/a.ts
esperar 1 "pii-no-valor"

novo vermelho-pii-valor-campo-usuario; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: user.email });
FIX
esperar 1 "pii-no-valor"

novo vermelho-propriedade-nao-declarada; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x", utm_campanha_secreta: "y" });
FIX
esperar 1 "propriedade-nao-declarada"

novo vermelho-identify-com-email; plano_bom
f src/a.ts <<'FIX'
posthog.identify(user.email);
FIX
printf 'x\n' >/dev/null
esperar 1 "pii-no-identify"

novo vermelho-sdk-sem-consentimento; plano_bom
f src/a.ts <<'FIX'
posthog.init("chave", { api_host: "https://eu.i.posthog.com" });
FIX
esperar 1 "sdk-sem-consentimento"

novo vermelho-plano-ausente
f src/a.ts <<'FIX'
track("cadastro_concluido", {});
FIX
esperar 1 "plano-ausente"

novo vermelho-plano-evento-sem-dono
f tracking-plan.yml <<'FIX'
events:
  - name: cadastro_concluido
    properties: [metodo]
FIX
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x" });
FIX
esperar 1 "evento-sem-dono"

novo vermelho-plano-com-pii
f tracking-plan.yml <<'FIX'
events:
  - name: cadastro_concluido
    owner: time-growth
    properties: [metodo, cpf]
FIX
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x" });
FIX
esperar 1 "pii-no-plano"

novo vermelho-plano-nome-ruim
f tracking-plan.yml <<'FIX'
events:
  - name: Cadastro
    owner: time-growth
    properties: []
FIX
f src/a.ts <<'FIX'
track("cadastro_concluido", {});
FIX
esperar 1 "nome-fora-do-padrao"

novo vermelho-plano-duplicado
f tracking-plan.yml <<'FIX'
events:
  - name: cadastro_concluido
    owner: a
    properties: []
  - name: cadastro_concluido
    owner: b
    properties: []
FIX
f src/a.ts <<'FIX'
track("cadastro_concluido", {});
FIX
esperar 1 "evento-duplicado"

echo "== nada a verificar / borda =="
novo vazio
f README.md <<'FIX'
sem codigo de analytics
FIX
esperar 2 "nada para verificar"

novo aviso-plano-morto; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x" });
FIX
esperar 0 "AVISO"

novo ignora-node-modules; plano_bom
f src/a.ts <<'FIX'
track("cadastro_concluido", { metodo: "x" });
FIX
f node_modules/lib/x.js <<'FIX'
track("evento_de_terceiro_xyz", {});
FIX
esperar 0 "ok"

echo
echo "check-tracking.test: $ok ok, $fail falha(s)"
[ "$fail" -eq 0 ]
