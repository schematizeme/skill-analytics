# Tracking plan — o contrato de eventos

> Parte da skill **schematize-analytics**. Gate: `scripts/check-tracking.sh`.

Evento é API entre o produto e quem analisa. Sem plano, cada time inventa nome, propriedade e
significado; em seis meses `signup`, `Sign Up`, `cadastro` e `user_registered` coexistem e ninguém
sabe qual vale. O **tracking plan** é o arquivo versionado, no mesmo repo do código que dispara o
evento, que declara o que existe.

## 1. Formato (`tracking-plan.yml`)

```yaml
version: 1
events:
  - name: cadastro_concluido      # objeto_acao
    owner: time-growth            # time responsável (obrigatório)
    description: Conta criada e primeiro fator verificado.
    properties: [metodo, plano]   # lista FECHADA, inline
```

O gate lê esse subconjunto de YAML (uma linha `- name:`, `owner:` e `properties: [...]` inline por
evento). Campos extras como `description` são livres e documentam. Procura o plano em
`tracking-plan.yml`, `tracking-plan.yaml` ou `tracking/plan.yml`; ou `--plan <arquivo>`.

## 2. Nome: `objeto_acao`

- snake_case minúsculo, **dois ou mais segmentos**, objeto primeiro e ação no fim, no passado ou como
  fato consumado: `pedido_pago`, `convite_aceito`, `plano_alterado`, `exportacao_solicitada`.
- Descreve **o que aconteceu no domínio**, não o gesto da interface: `pedido_pago`, não
  `botao_pagar_clicado`. Gesto de UI só quando o próprio gesto é a pergunta (teste de design).
- Sem espaço, maiúscula, acento, versão no nome (`_v2`) nem nome de tela. Prefixo de produto só se a
  conta de analytics for compartilhada.

## 3. Propriedades

- **Lista fechada por evento.** Propriedade fora do plano reprova (`propriedade-nao-declarada`):
  a lista aberta é onde PII entra "só desta vez".
- Nome também em snake_case, tipo estável (número é número em todo evento), unidade no nome quando
  houver (`valor_centavos`, `duracao_ms`).
- **Proibido** (reprova em `pii-na-propriedade`/`pii-no-plano`): e-mail, CPF/CNPJ, RG, telefone, nome,
  endereço, CEP, nascimento, IP bruto, senha, token, número de cartão. Ver
  `references/consentimento-lgpd.md` §3.
- Categoria em vez de valor livre: `plano: "pro"`, não texto digitado pelo usuário. Texto livre
  carrega PII sem ninguém ver.
- Propriedades de contexto comuns (ambiente, versão do app, locale, tenant opaco) vêm do SDK, uma
  vez, e ficam no plano como bloco `global` documentado, não repetidas por evento.

## 4. Dono e ciclo de vida

| Estado | O que significa | Regra |
|---|---|---|
| proposto | está no plano, ninguém dispara | PR de plano aprovado por quem vai analisar |
| ativo | código dispara | evento no plano **e** no código |
| depreciado | substituído por outro | `description` aponta o substituto e a data; disparo continua até a remoção |
| removido | saiu do plano e do código | dado histórico fica; SDK para de emitir |

- **Mudou o significado = evento novo.** Reaproveitar o nome corrompe a série histórica.
- Evento no plano que o código nunca dispara vira **aviso** do gate (plano morto): remova ou dispare.
- Todo evento tem `owner`: quem responde quando o número muda e decide quando aposentar.

## 5. Onde o plano vive e como entra na CI

- No repo do produto, ao lado do código. PR que adiciona `track(...)` e plano no mesmo diff.
- CI roda `bash scripts/check-tracking.sh .` e reprova. Waiver rastreável, com motivo e prazo no
  texto: `// tracking-ok: <motivo>` na linha ou na anterior (use para legado em migração, nunca para
  PII).
- Código gerado a partir do plano (funções tipadas `trackPedidoPago(valor, moeda)`) é o passo seguinte:
  o compilador passa a impedir evento e propriedade fora do plano. O gate continua como rede.

## 6. O que o gate pega e o que não pega

Pega por varredura estática: evento não declarado · nome fora do padrão (plano e código) · evento
sem dono · evento duplicado · PII por **nome de chave** (`email`, `cpf`, `telefone`...), por **valor
literal** (e-mail, CPF) e por leitura de campo do usuário (`user.email`) · `identify` com e-mail ·
SDK iniciado sem nenhum gate de consentimento no arquivo.

Não pega (revise à mão, `/analytics-review`): PII que viaja numa variável de nome neutro, URL com
dado pessoal em `page_view` automático, evento disparado por helper dinâmico (nome montado em
runtime), texto livre, a **base legal** em si. O gate é piso, não prova de conformidade.
