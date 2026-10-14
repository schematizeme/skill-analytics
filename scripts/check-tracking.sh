#!/usr/bin/env bash
# check-tracking.sh — gate do tracking plan: confronta os eventos do código com o plano versionado.
#
# Motivo: o tracking plan é um CONTRATO (schematize-analytics → references/plano-de-tracking.md).
# Evento que o código dispara e o plano não declara é dado sem dono; propriedade com PII é vazamento
# de dado pessoal para terceiro (LGPD); nome fora do padrão quebra a análise. O gate pega isso na CI.
# Entrada: $1 = diretório do projeto (default .). Opções: --plan <arquivo>  (default: tracking-plan.yml
#   | tracking-plan.yaml | tracking/plan.yml no diretório). Plano em YAML restrito (veja a reference):
#     events:
#       - name: cadastro_concluido
#         owner: time-growth
#         properties: [metodo, plano]
# Saída: achados em stdout (`regra  arquivo:linha  mensagem`). Exit 0 passa · 1 reprova · 2 nada a verificar
#   (sem plano E sem evento no código; "nada verificado" não é aprovação).
# Waiver rastreável: `# tracking-ok: <motivo>` (ou `// tracking-ok: <motivo>`) na linha ou na anterior.
set -euo pipefail

DIR="."; PLANO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --plan) PLANO="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) DIR="$1"; shift ;;
  esac
done
[ -d "$DIR" ] || { echo "diretório inexistente: $DIR" >&2; exit 2; }

if [ -z "$PLANO" ]; then
  for c in tracking-plan.yml tracking-plan.yaml tracking/plan.yml; do
    [ -f "$DIR/$c" ] && { PLANO="$DIR/$c"; break; }
  done
fi

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
ACHADOS="$TMP/achados"; : >"$ACHADOS"
ach() { printf '%s\t%s\t%s\n' "$1" "$2" "$3" >>"$ACHADOS"; }

PADRAO='^[a-z][a-z0-9]*(_[a-z0-9]+)+$'                       # objeto_acao, snake_case, >= 2 segmentos
PII_CHAVE='^(e_?mail|cpf|cnpj|rg|telefone|phone|celular|whatsapp|nome|nome_completo|full_name|first_name|last_name|sobrenome|endereco|address|cep|zip|nascimento|birth(day|date)?|data_nascimento|ip|ip_address|senha|password|passwd|token|cartao|card_number|pan)$'

# ---------- 1. o plano ----------
: >"$TMP/plano.tsv"
if [ -n "$PLANO" ]; then
  [ -f "$PLANO" ] || { echo "plano inexistente: $PLANO" >&2; exit 2; }
  awk '
    function flush() { if (nome != "") printf "%s\t%s\t%s\t%d\n", nome, (owner==""?"-":owner), (props==""?"-":props), ln; nome=""; owner=""; props="" }
    /^[[:space:]]*-[[:space:]]*name:/ { flush(); ln=NR; s=$0; sub(/^[[:space:]]*-[[:space:]]*name:[[:space:]]*/,"",s); gsub(/["\047[:space:]]/,"",s); nome=s; next }
    /^[[:space:]]+owner:/ { s=$0; sub(/^[[:space:]]+owner:[[:space:]]*/,"",s); gsub(/["\047]/,"",s); sub(/[[:space:]]+$/,"",s); owner=s; next }
    /^[[:space:]]+properties:/ { s=$0; sub(/^[[:space:]]+properties:[[:space:]]*/,"",s); gsub(/[\[\]"\047]/,"",s); gsub(/,/," ",s); gsub(/[[:space:]]+/," ",s); sub(/^ /,"",s); sub(/ $/,"",s); props=s; next }
    END { flush() }
  ' "$PLANO" >"$TMP/plano.tsv"
  PREL="$PLANO"
  while IFS=$'\t' read -r nome owner props ln; do
    if ! [[ "$nome" =~ $PADRAO ]]; then ach nome-fora-do-padrao "$PREL:$ln" "evento '$nome' no plano fora de objeto_acao em snake_case minúsculo"; fi
    [ "$owner" != "-" ] || ach evento-sem-dono "$PREL:$ln" "evento '$nome' sem owner no plano"
    [ "$props" != "-" ] || props=""
    for p in $props; do
      pl="$(printf '%s' "$p" | tr 'A-Z' 'a-z')"
      if [[ "$pl" =~ $PII_CHAVE ]]; then ach pii-no-plano "$PREL:$ln" "propriedade '$p' do evento '$nome' é dado pessoal"; fi
    done
  done <"$TMP/plano.tsv"
  dup="$(cut -f1 "$TMP/plano.tsv" | sort | uniq -d | head -1 || true)"
  [ -z "$dup" ] || ach evento-duplicado "$PREL" "evento '$dup' declarado mais de uma vez"
fi

# ---------- 2. chamadas no código ----------
find "$DIR" \( -name node_modules -o -name .git -o -name dist -o -name build -o -name versions -o -name vendor -o -name .next -o -name target -o -name .venv \) -prune -o \
  -type f \( -name '*.js' -o -name '*.jsx' -o -name '*.ts' -o -name '*.tsx' -o -name '*.mjs' -o -name '*.cjs' -o -name '*.py' -o -name '*.rb' -o -name '*.go' -o -name '*.rs' -o -name '*.ex' -o -name '*.exs' -o -name '*.cs' -o -name '*.kt' -o -name '*.swift' -o -name '*.dart' -o -name '*.php' -o -name '*.vue' -o -name '*.svelte' -o -name '*.html' \) -print 2>/dev/null | sort >"$TMP/arquivos"

: >"$TMP/chamadas.tsv"
while IFS= read -r arq; do
  awk -v F="${arq#"$DIR"/}" '
    BEGIN {
      ev = "(^|[^A-Za-z0-9_])(track|trackEvent|track_event|capture|logEvent|log_event|plausible|umami\\.track|gtag\\([[:space:]]*[\"\047]event[\"\047][[:space:]]*,)[[:space:]]*\\(?[[:space:]]*[\"\047][^\"\047]+[\"\047]"
    }
    { linhas[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        l = linhas[i]
        if (l ~ /\([[:space:]]*$/ && i < NR) { nx = linhas[i+1]; sub(/^[[:space:]]+/, "", nx); l = l " " nx }
        if (match(l, ev)) {
          trecho = substr(l, RSTART)
          depth = 0; corpo = ""; j = i; atual = trecho
          while (1) {
            n = length(atual)
            for (k = 1; k <= n; k++) { c = substr(atual, k, 1); if (c == "(") depth++; else if (c == ")") depth-- }
            corpo = corpo " " atual
            if (depth <= 0 || j - i >= 12 || j >= NR) break
            j++; atual = linhas[j]
          }
          waiver = (l ~ /(#|\/\/)[[:space:]]*tracking-ok:/) || (i > 1 && linhas[i-1] ~ /(#|\/\/)[[:space:]]*tracking-ok:/)
          gsub(/\t/, " ", corpo)
          printf "CALL\t%s\t%d\t%d\t%s\n", F, i, waiver, corpo
        }
        if (l ~ /(identify|setUserProperties|set_user_properties|alias)[[:space:]]*\(/ ) {
          waiver = (l ~ /(#|\/\/)[[:space:]]*tracking-ok:/) || (i > 1 && linhas[i-1] ~ /(#|\/\/)[[:space:]]*tracking-ok:/)
          gsub(/\t/, " ", l)
          printf "IDENT\t%s\t%d\t%d\t%s\n", F, i, waiver, l
        }
        if (l ~ /(posthog\.init|posthog\.setup|gtag\([[:space:]]*["\047]config["\047]|fbq\([[:space:]]*["\047]init["\047]|ga\([[:space:]]*["\047]create["\047]|mixpanel\.init|amplitude\.init)/) {
          waiver = (l ~ /(#|\/\/)[[:space:]]*tracking-ok:/) || (i > 1 && linhas[i-1] ~ /(#|\/\/)[[:space:]]*tracking-ok:/)
          printf "INIT\t%s\t%d\t%d\t%s\n", F, i, waiver, ""
        }
      }
    }
  ' "$arq" >>"$TMP/chamadas.tsv"
done <"$TMP/arquivos"

ncalls="$(grep -c '^CALL' "$TMP/chamadas.tsv" || true)"
if [ -z "$PLANO" ] && [ "$ncalls" -eq 0 ]; then
  echo "nada para verificar: sem tracking plan e sem chamada de evento em $DIR (isto NÃO é aprovação)"; exit 2
fi
[ -n "$PLANO" ] || ach plano-ausente "$DIR" "há $ncalls chamada(s) de evento mas nenhum tracking-plan.yml (o plano é o contrato)"

declare -A USADOS=()
while IFS=$'\t' read -r tipo arq ln waiver corpo; do
  [ "$tipo" = CALL ] || continue
  loc="$arq:$ln"
  [ "$waiver" = 1 ] && continue
  nome="$(printf '%s' "$corpo" | sed -E "s/^[^\"']*[\"']([^\"']+)[\"'].*/\1/")"
  USADOS["$nome"]=1
  if ! [[ "$nome" =~ $PADRAO ]]; then ach nome-fora-do-padrao "$loc" "evento '$nome' fora de objeto_acao em snake_case minúsculo"; fi
  declarado=""
  if [ -n "$PLANO" ]; then
    declarado="$(awk -F'\t' -v n="$nome" '$1==n {print "1\t" $3; exit}' "$TMP/plano.tsv")"
    [ -n "$declarado" ] || ach evento-nao-declarado "$loc" "evento '$nome' disparado e ausente do tracking plan"
  fi
  # propriedades: chaves de objeto depois do nome do evento
  resto="$(printf '%s' "$corpo" | sed -E "s/^[^\"']*[\"'][^\"']+[\"']//")"
  chaves="$(printf '%s' "$resto" | grep -oE "[\"']?[A-Za-z_][A-Za-z0-9_]*[\"']?[[:space:]]*:" | sed -E "s/[\"'[:space:]:]//g" | sort -u || true)"
  decl_props=" ${declarado#*$'\t'} "; [ "$decl_props" != " - " ] || decl_props="  "
  for k in $chaves; do
    kl="$(printf '%s' "$k" | tr 'A-Z' 'a-z')"
    if [[ "$kl" =~ $PII_CHAVE ]]; then ach pii-na-propriedade "$loc" "evento '$nome' envia '$k' (dado pessoal) — LGPD: sem PII em evento"; continue; fi
    if [ -n "$declarado" ] && [[ "$decl_props" != *" $k "* ]]; then
      ach propriedade-nao-declarada "$loc" "propriedade '$k' do evento '$nome' ausente do plano"
    fi
  done
  if printf '%s' "$resto" | grep -qE '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}|[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}'; then
    ach pii-no-valor "$loc" "evento '$nome' carrega e-mail ou CPF literal"
  fi
  if printf '%s' "$resto" | grep -qE '\.(e_?mail|cpf|cnpj|phone|telefone|celular)\b'; then
    ach pii-no-valor "$loc" "evento '$nome' lê campo de dado pessoal (email/cpf/telefone) do usuário"
  fi
done <"$TMP/chamadas.tsv"

while IFS=$'\t' read -r tipo arq ln waiver corpo; do
  [ "$waiver" = 1 ] && continue
  if [ "$tipo" = IDENT ] && printf '%s' "$corpo" | grep -qiE 'e_?mail|cpf|phone|telefone|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}'; then
    ach pii-no-identify "$arq:$ln" "identify com e-mail/CPF/telefone: use o ID interno opaco (identidade != e-mail)"
  fi
  if [ "$tipo" = INIT ]; then
    if ! grep -qiE 'consent|opt_?in|opt_?out|cookieless|persistence[^,]*memory|consentimento|disable_persistence' "$DIR/$arq"; then
      ach sdk-sem-consentimento "$arq:$ln" "SDK de analytics iniciado sem gate de consentimento nem modo sem cookie no mesmo arquivo"
    fi
  fi
done <"$TMP/chamadas.tsv"

# declarado e não usado: aviso (não reprova)
avisos=0
if [ -n "$PLANO" ] && [ "$ncalls" -gt 0 ]; then
  while IFS=$'\t' read -r nome _ _ ln; do
    [ -n "${USADOS[$nome]:-}" ] || { echo "AVISO  $PLANO:$ln  evento '$nome' declarado e nunca disparado (plano morto?)"; avisos=$((avisos+1)); }
  done <"$TMP/plano.tsv"
fi

if [ -s "$ACHADOS" ]; then
  sort -u "$ACHADOS" | awk -F'\t' '{ printf "ERRO   %-26s %s  %s\n", $1, $2, $3 }'
  echo "check-tracking: $(sort -u "$ACHADOS" | wc -l) achado(s) — reprovado"; exit 1
fi
echo "check-tracking: ok ($ncalls chamada(s) conferida(s) contra o plano; $avisos aviso(s))"
exit 0
