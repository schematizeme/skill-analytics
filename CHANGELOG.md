# Changelog — schematize-analytics

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.1.0] — 2026-10-14
Primeira versão. Medição de comportamento de produto vivia espalhada: privacidade/LGPD na base e na
`schematize-data`, telemetria técnica na `schematize-observability`, tráfego orgânico na `schematize-seo`.
Faltava a dona de quem decide **o que medir, com que direito e com que método** — e o resultado era evento
sem dono, e-mail dentro de propriedade, "ativação" com três definições e teste A/B encerrado no primeiro
p < 0,05.

### Adicionado
- `SKILL.md` com 14 pisos: tracking plan como contrato, nome `objeto_acao`, sem PII, consentimento, first-party,
  métrica de definição única, retenção por coorte, desenho de experimento antes de rodar, flags com dono, ambientes
  separados, telemetria técnica fora, ADR.
- `references/`: `plano-de-tracking`, `consentimento-lgpd`, `ferramentas` (PostHog, Plausible, Umami, GA4),
  `metricas`, `experimentacao` (amostra, SRM, peeking, guardrails), `feature-flags`, `stack-versoes` (anexo volátil).
- Gate `scripts/check-tracking.sh` (evento não declarado, propriedade fora do plano, nome fora do padrão, evento sem
  dono/duplicado, PII por chave/valor/campo do usuário, `identify` com PII, SDK sem consentimento) e
  `check-tracking.test.sh` com casos vermelhos e verdes plantados; PII de teste montada em tempo de execução.
- Comandos `/analytics-help`, `-load`, `-claude`, `-handoff`, `-cc`, `-plan`, `-review`, `-consent`, `-metric`,
  `-experiment`; `assets/CLAUDE.md` e `assets/tracking-plan.example.yml`.
