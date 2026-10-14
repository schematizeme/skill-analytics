# Feature flags — entrega controlada, não configuração eterna

> Parte da skill **schematize-analytics**. Experimento usa flag; flag nem sempre é experimento.

## 1. Quatro tipos, quatro vidas

| Tipo | Para quê | Vida útil | Quem muda |
|---|---|---|---|
| **Release** | esconder código pronto, ligar gradualmente (trunk-based) | dias a semanas; **remover** após 100 % estável | engenharia |
| **Experimento** | variante de A/B | duração do experimento, depois remover | produto/dados |
| **Operacional / kill switch** | desligar funcionalidade pesada ou arriscada em incidente | longa, **por design** | operação |
| **Permissão** | habilitar por plano/cliente | permanente | produto — mas isso é **autorização** (`schematize-iam`), não flag |

Confundir os tipos gera dívida: a flag de release que ninguém removeu vira configuração fantasma.

## 2. Regras

1. **Dono e data de remoção** em toda flag de release e de experimento (no próprio registro da flag).
2. **Padrão seguro:** valor default (ferramenta fora do ar, avaliação falhou) é o comportamento
   **estável conhecido**. Avaliação não bloqueia a requisição (timeout curto, cache local).
3. **Kill switch** para toda funcionalidade arriscada: desliga sem deploy, testado no runbook
   (`schematize-docs`). Faz parte da resposta a incidente (`schematize-incident`: mitigar antes de
   diagnosticar).
4. **Avaliação no servidor** quando a decisão tem consequência (preço, acesso, segurança); a flag no
   cliente é só aparência, pois o usuário a manipula.
5. **Aleatorização estável** por ID opaco; mesma variante para o mesmo usuário.
6. **Flag de permissão não é flag:** acesso a recurso por plano/tenant é regra de autorização com
   auditoria, no PDP (`schematize-engineering → references/iam.md`).
7. **Teste das duas ramificações:** a CI roda com a flag ligada e desligada nos caminhos críticos. Flag
   que nunca foi testada desligada não é rollback.
8. **Limpeza:** remova flag e ramo morto no mesmo ciclo em que chegar a 100 %; PR de remoção é
   trabalho planejado, não "depois". Relatório de flags antigas faz parte da revisão.
9. **Combinatória:** N flags independentes = 2^N estados; interações entre flags vivas ao mesmo tempo
   são testadas ou proibidas.

## 3. Ferramentas

Flag simples vive em configuração versionada; plataforma de flags (PostHog, Unleash, GrowthBook e
outras) entra quando há rollout percentual, segmentação ou experimento. Prefira o padrão aberto
OpenFeature como interface para não prender o código ao fornecedor. Critérios de decisão em
`references/ferramentas.md`; versões em `references/stack-versoes.md`.
