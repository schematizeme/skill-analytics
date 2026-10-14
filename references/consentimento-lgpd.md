# Consentimento, LGPD e minimização em analytics

> Parte da skill **schematize-analytics**. Não é parecer jurídico: texto de privacidade e base legal
> passam por revisão humana (`schematize-institutional`). Verificação das fontes em
> `references/stack-versoes.md`.

## 1. Comece pela finalidade

Analytics de produto responde "o produto funciona e onde as pessoas travam?". Essa finalidade
declarada define o que se coleta; o que não serve a ela não se coleta (princípio da necessidade da
LGPD). "Pode servir depois" não é finalidade.

## 2. Base legal por finalidade (LGPD, art. 7º)

| Coleta | Base usual | Observação |
|---|---|---|
| Cookie/identificador estritamente necessário à função pedida (sessão, carrinho, segurança) | execução de contrato ou legítimo interesse | sem banner de consentimento para isso |
| Medição agregada de audiência, **sem** identificador persistente e **sem** cruzar com outros dados | legítimo interesse (com teste de balanceamento documentado) | o guia da ANPD aceita legítimo interesse para cookies analíticos em vários contextos |
| Analytics que identifica o titular, segue entre sessões/sites, cruza com terceiros, faz perfilamento | **consentimento** | opt-in explícito, granular, revogável |
| Publicidade, remarketing, pixel de terceiro | **consentimento** | legítimo interesse tende a não se sustentar |
| Gravação de sessão, mapa de calor com conteúdo da tela | consentimento + mascaramento | campo de formulário mascarado por padrão |

- Escolha **registrada em ADR** por finalidade (`schematize-docs`), com quem decidiu e a data.
- **Consentimento válido**: livre, informado, inequívoco e para finalidade determinada. Caixa
  pré-marcada e "continuar navegando" não valem. **Recusar tem de ser tão fácil quanto aceitar**
  (mesmo nível, mesma tela). Guarde a prova: o quê, quando, qual versão do texto.
- Revogar é gesto simples e permanente na interface, e o SDK para na hora (não no próximo deploy).
- O guia orientativo da ANPD sobre cookies é interpretativo, não regulamento. Mudança de orientação:
  reverifique antes de fechar a política (`<!-- reverificar -->` no anexo).

## 3. O que é PII e fica fora do evento

Dado pessoal é qualquer informação que identifique ou torne identificável uma pessoa. Em analytics:

- **Direto:** e-mail, CPF/CNPJ, RG, telefone, nome, endereço, CEP, data de nascimento, foto.
- **Indireto/técnico:** IP completo, identificador de dispositivo de publicidade, fingerprint,
  token/sessão, número de cartão, texto livre digitado.
- **Combinação:** CEP + data de nascimento + gênero reidentifica; "anonimizado" que se reverte com
  uma tabela de apoio é **pseudonimizado**, e continua dado pessoal.

Regras:
1. **Nunca** em nome de evento, propriedade, URL (query/path), título de página ou `identify`.
   O gate reprova por chave, por valor literal e por leitura de campo do usuário.
2. O usuário é o **ID interno opaco** (ULID/UUIDv7) — identidade ≠ e-mail
   (`schematize-engineering → references/iam.md`). Nunca derive o ID de e-mail por hash fraco: hash
   de e-mail sem sal é re-identificável por tabela.
3. **URL limpa antes de enviar:** remova `?email=`, `?token=`, `?cpf=` do `page_view` automático. Reset
   token e link mágico nunca chegam a analytics.
4. **IP:** descarte ou trunque no ponto de coleta; geolocalização por cidade/país basta.
5. **Texto livre** (busca, feedback, mensagem) não vira propriedade. Registre o fato (`busca_realizada`,
   `resultados_n`), não a string.
6. Atributo sensível (saúde, religião, orientação, biometria, dado de criança) **não é analytics**:
   exige base própria, ADR e, em geral, não deveria sair do sistema de origem.

## 4. Minimização e retenção

- Colete o mínimo da finalidade; amostre quando a pergunta permitir.
- **Retenção definida e curta** por tipo (evento bruto x agregado). Exclusão automática no vencimento;
  a ferramenta precisa suportar (verifique em `references/ferramentas.md`).
- **Direitos do titular** (acesso, correção, eliminação): se o ID opaco liga ao titular, haja caminho
  de exclusão por ID nos dados de analytics. Se não há ligação possível, registre isso.
- Compartilhamento com terceiro (SaaS de analytics) é transferência: contrato de operador e, se o
  servidor estiver fora do Brasil, mecanismo de transferência internacional. Prefira região UE/BR ou
  self-hosted; registre no ADR.
- Incidente com dado pessoal em analytics (PII que vazou para a ferramenta) segue o rito de
  incidente da casa: conter (parar a coleta, excluir o dado), avaliar, comunicar quando exigido.

## 5. First-party e sem cookie

- Servir o script e receber o evento **no seu domínio** (proxy reverso `/a/` ou subdomínio próprio)
  reduz bloqueio, mantém o dado sob seu controle e corta vazamento para terceiros. Não é salvo-conduto
  legal: continua sendo coleta de dado pessoal quando há identificador.
- **Sem cookie e sem identificador persistente** (Plausible, Umami e o modo `cookieless`/memória do
  PostHog): medição agregada, sem banner necessário na maioria dos casos. Troca: não há retenção por
  usuário nem funil entre sessões. Decida pela pergunta que o produto precisa responder.
- Server-side (evento emitido pelo backend no fato consumado, `pedido_pago`) é mais confiável que o
  navegador e não sofre bloqueio; carrega o ID opaco, nunca o e-mail.

## 6. Ambientes

- Projeto/chave de analytics **separados** por ambiente. Dev, hml e CI usam sink descartável ou
  projeto de teste; nunca a chave de prd (poluição de métrica e vazamento).
- Dados de prd não vão para demo, seed nem print em documento.
- E-mail sintético de teste segue a regra da casa de rota nula (`schematize-engineering →
  references/efeitos-externos.md`).

## 7. Banner e UX (implementação no `schematize-web`)

Gate de consentimento no carregamento do SDK: sem opt-in, o SDK não inicia (ou inicia em modo memória
sem persistência). Estado do consentimento guardado e versionado; troca de versão do texto repete o
pedido. Acessibilidade do banner (foco, teclado, WCAG 2.2) é do `schematize-web`.
