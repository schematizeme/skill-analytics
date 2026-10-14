# schematize-analytics — analytics de produto privacy-first

> **Evento é contrato e dado pessoal é passivo.** Tracking plan versionado, consentimento LGPD, sem PII
> em evento, métricas com definição única, experimento A/B com método e feature flags com dono.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Por que ela existe

Quem mede produto costuma errar em quatro lugares: evento sem plano (cada time inventa o nome), PII
dentro da propriedade (e-mail "só para segmentar"), métrica sem definição (duas "ativações" com números
diferentes) e experimento lido com pressa (peeking, SRM ignorado). Esta skill fixa o contrato, o direito
de coletar e o método de decidir, e traz um gate que confronta o código com o plano.

## Instalar

### Pelo app schematize (recomendado)

```bash
schematize install analytics    # requer o CLI schematize instalado
```

### Manual

```bash
git clone https://github.com/schematizeme/skill-analytics.git /tmp/skill-analytics
bash /tmp/skill-analytics/install.sh .        # instala em .claude/ do projeto atual
```

## O que tem dentro

- **SKILL.md** — o contrato: 14 pisos inegociáveis, a fronteira com `data`, `observability`, `seo`, `web`
  e o mapa de references.
- **references/** — `plano-de-tracking`, `consentimento-lgpd`, `ferramentas`, `metricas`, `experimentacao`,
  `feature-flags` e `stack-versoes` (anexo volátil com data e fonte).
- **scripts/** — `check-tracking.sh`, o gate (exit 0 passa, 1 reprova, 2 nada a verificar), e o
  `check-tracking.test.sh` com vermelhos e verdes plantados.
- **assets/** — `CLAUDE.md` sempre-on, `tracking-plan.example.yml` e os comandos `/analytics-*`.

## Uso rápido

```bash
bash scripts/check-tracking.sh .          # plano x código
bash scripts/check-tracking.test.sh       # o vermelho do próprio gate
```

Não é parecer jurídico: base legal e texto de privacidade passam por revisão humana.

## Licença

MIT. Veja `LICENSE`.
