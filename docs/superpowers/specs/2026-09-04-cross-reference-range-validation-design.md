# Validação de range em check-cross-references

**Route:** full process
**Data:** 2026-09-04

## Problem

`skills/writing-plans/scripts/check-cross-references` aceita citações de range
malformadas e as reporta como resolvidas. O parser reconhece a forma
`arquivo:início-fim` desde `skills/writing-plans/scripts/check-cross-references:386`,
mas a validação em
`skills/writing-plans/scripts/check-cross-references:409-410` compara apenas o
número **final** contra o total de linhas do arquivo. O número inicial nunca é
validado contra coisa alguma.

Medido por execução em 2026-09-04, com controle, contra este checkout:

| Citação | Exit | Deveria |
|---|---|---|
| `README.md` com range `10-5` (invertido) | 0 | 1 |
| `README.md` com range `0-5` (linha zero) | 0 | 1 |
| `README.md` com `0` (linha zero, sem range) | 0 | 1 |
| `README.md` com range `5-200`, arquivo de 171 linhas naquela data | 1 | 1 |

O último é o controle: ele prova que o instrumento funciona e que os três
primeiros passam de verdade, em vez de não terem sido examinados. **A medição
usou `README.md` porque estava à mão; o controle depende do arquivo ter menos de
200 linhas e deixaria de ser controle em silêncio se ele crescesse.** Por isso
AC7 e AC8 são satisfeitos por fixtures que a própria suíte cria, com tamanho
conhecido por construção, nunca por arquivo do repositório.

**Segundo defeito, na mesma região.** As três chamadas que registram uma
citação irresolvida — `skills/writing-plans/scripts/check-cross-references:400`,
`:407` e `:412` — formatam a mensagem como `` `{rel}:{first}` ``, descartando o
número final. No controle acima, a citação inválida era o `200` e a mensagem
nomeou a linha `5`. Quem lê o erro recebe um número que existe no arquivo e
procura o defeito no lugar errado.

**Quem isso afeta.** O script roda entre o conserto de uma spec ou plano e o
re-despacho do reviewer, em `skills/brainstorming/SKILL.md` e
`skills/writing-plans/SKILL.md`, para poupar uma rodada de reviewer. Uma
citação malformada que ele aprova custa exatamente a rodada que ele existe para
economizar.

**Fora de escopo.** Esta spec trata apenas da validação de range e da mensagem
de erro. Não altera a forma canônica de citação, não introduz exigência de
fragmento literal, não toca em nenhuma skill, e não faz parte do modelo de
evidência — que é assunto de
[`2026-09-04-evidence-model-v2-design.md`](2026-09-04-evidence-model-v2-design.md)
e não depende desta para ser escrito, embora dependa dela para ser implementado.

## Acceptance Criteria

- **AC1** — Uma citação cujo número inicial é `0`, sem range, é reportada como
  irresolvida e o script sai com código 1.
- **AC2** — Uma citação cujo número inicial é `0` com range (`0-N`) é reportada
  como irresolvida e o script sai com código 1.
- **AC3** — Uma citação cujo número inicial é maior que o final (`N-M` com
  `N > M`) é reportada como irresolvida e o script sai com código 1.
- **AC4** — Uma citação cujo número final excede o total de linhas do arquivo
  continua sendo reportada como irresolvida, com saída 1. É guarda de regressão:
  é o único caso da classe que já funciona.
- **AC5** — Uma citação com `1 <= início <= fim <= total de linhas` continua
  resolvendo, e o script sai com código 0. A forma `N-N` é aceita.
- **AC6** — Toda entrada de citação irresolvida produzida a partir de uma
  referência reconhecida por `CITATION`
  (`skills/writing-plans/scripts/check-cross-references:386`) preserva a citação
  completa como foi escrita, incluindo o número final quando há range. **Nenhuma
  delas reconstrói a mensagem apenas como `{rel}:{first}`.** O critério é
  enunciado como invariante sobre o conjunto, e não sobre uma contagem: quantas
  chamadas existem é fato do estado-base, descrito em `## Problem` e em
  `## Codebase Findings`, e a correção acrescenta uma quarta que cai sob a mesma
  regra.
- **AC7** — `tests/hooks/test-check-cross-references.sh` carrega, para cada um
  de AC1 a AC4, um par de casos: o documento limpo de AC5, que passa, e o mesmo
  documento com aquela citação quebrada, que falha. AC5 é o lado limpo comum aos
  quatro pares, não um par próprio — um caso válido não tem metade quebrada.
- **AC8** — `tests/hooks/test-check-cross-references.sh` carrega um caso que
  falha se a mensagem de erro de um range inválido omitir o número final,
  cobrindo AC6.

## Implicit Requirements

- **IR1** — Nenhuma citação hoje presente em `docs/`, `skills/`, `CLAUDE.md`,
  `AGENTS.md` ou `CHANGELOG.md` passa a ser reprovada pela regra nova. A
  contagem é verificada por execução do script corrigido sobre o corpus, não
  estimada.
- **IR2** — A mudança não introduz dependência externa.
- **IR3** — O caso de baseline pinado em `tests/hooks/test-check-cross-references.sh:34`
  continua verde: nenhum documento já commitado muda de veredito por esta
  correção. Se algum mudar, é violação de IR1 e a causa se investiga antes de
  ajustar o teste.
- **IR4** — `CHANGELOG.md` recebe entrada em `[Unreleased]`, exigida por
  `scripts/check-changelog.sh` para mudança sob `skills/`.
- **IR5** — Os casos de AC7 e AC8 rodam contra o repositório descartável que
  `tests/hooks/test-check-cross-references.sh:47-54` constrói, com seu
  `src/verify.ts` de 20 linhas conhecidas, e nunca contra arquivo do
  repositório, cujo tamanho muda sem aviso.

## Codebase Findings

- **O parser já aceita range, e essa metade está correta.**
  `skills/writing-plans/scripts/check-cross-references:386`:
  `CITATION = re.compile(r"`([^`\s]+\.[A-Za-z0-9_]+):(\d+)(?:-(\d+))?`")` — o
  grupo opcional `(?:-(\d+))?` é o número final.
- **A validação ignora o número inicial.**
  `skills/writing-plans/scripts/check-cross-references:409-410`:
  `end = int(last) if last else first` seguido de `if end > n:`. Não há
  comparação de `first` contra `1`, contra `n`, nem contra `end`.
- **As três mensagens descartam o número final.**
  `skills/writing-plans/scripts/check-cross-references:400`, `:407` e `:412`
  usam o mesmo formato `` f"`{rel}:{first}` — …" ``.
- **A suíte já tem o helper e a filosofia que AC7 precisa.**
  `tests/hooks/test-check-cross-references.sh:57` define
  `run_case() {` com a assinatura nome/exit esperado/documento, e
  `tests/hooks/test-check-cross-references.sh:10-12` declara: *"The cases that
  matter are the pairs: a clean document must PASS and the same document with
  ONE reference broken must FAIL. A gate that only ever fails is a gate nobody
  can distinguish from a broken invocation."*
- **O caso de fim-de-arquivo já existe e é o único da classe.**
  `tests/hooks/test-check-cross-references.sh:103`:
  `run_case "spec citing past the end of a file fails" 1 …`. É a razão de AC4
  ser guarda de regressão e não comportamento novo.
- **Existe um baseline pinado que compara vereditos antes e depois.**
  `tests/hooks/test-check-cross-references.sh:34`:
  `BASE_REF="${BASE_REF:-0aa28b760dad693a544b39f5e7dbe9929d519071}"`, com o
  comentário de que ele existe para asseverar que a mudança não moveu o veredito
  de nenhum documento commitado. É o instrumento de IR3.
- **O script roda entre o conserto e o re-despacho, nos dois carriers.**
  [`writing-plans/SKILL.md`](../../../skills/writing-plans/SKILL.md), section "Plan
  Review", e [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md),
  section "After the Design" — neste a instrução está no bloco `**Spec Review:**`,
  que é rótulo em negrito e não heading, então a âncora é a seção que o contém.
  As duas dão a mesma razão com uma palavra de diferença, e por isso nenhuma
  forma verbatim serve às duas: `skills/brainstorming/SKILL.md:253` diz *"the
  cheapest defect this document can carry"* e `skills/writing-plans/SKILL.md:334`
  diz *"the cheapest defect this plan can carry"*.
- **O gate roda em CI.** `.github/workflows/ci.yml:90`:
  `run: tests/hooks/test-check-cross-references.sh`.

## External Dependencies

None. A correção fica no bloco `python3` já embutido no script; nenhuma
dependência é acrescentada. O projeto é zero-dependency por regra de
[`CLAUDE.md`](../../../CLAUDE.md), section "What does not belong here".

## Assumptions to Confirm

None. Toda afirmação desta spec foi resolvida abrindo o arquivo ou executando o
script. A única pergunta que poderia ter virado assunção — quantas citações
existentes a regra nova reprovaria — é respondível pela árvore e por isso virou
IR1, verificada por execução sobre o corpus em vez de declarada.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC6; o comportamento desejado veio enunciado caso a caso |
| Domain and data model | Clear | Não há dado nem entidade: o script lê texto e devolve exit code |
| Interaction flow | Clear | Uma invocação, uma saída; sem estado entre execuções |
| Non-functional attributes | Clear | O script já roda em fração de segundo por documento; a mudança acrescenta duas comparações inteiras por citação |
| Integrations and external dependencies | Clear | IR2 e `## External Dependencies`: nenhuma |
| Edge cases and failures | Resolved | AC1–AC5 **são** os edge cases: zero, zero com range, invertido, além do fim, e o válido que precisa continuar passando |
| Constraints and tradeoffs | Resolved | IR1 e IR3: a regra nova não pode reprovar corpus existente, e há instrumento pinado que mede isso |
| Terminology | Resolved | "início" e "fim" do range em vez de `first`/`last`, que no código nomeiam o grupo da regex e não a semântica |
| Completion signals | Resolved | Cada AC é um par documento/exit code, verificável por `run_case` |
| Placeholders and vague adjectives | Clear | Nenhum: os quatro casos medidos estão na tabela do `## Problem`, com data |

### Decision record

| Pergunta | Resposta | Recomendação dada | Fonte declarada |
|---|---|---|---|
| `N-N` é válido ou se canonicaliza para `N`? | Aceito como válido; `N` continua a forma preferida, sem gate que force a troca → AC5 | Aceitar `N-N` sem canonicalizar | Padrão do projeto — `skills/writing-plans/scripts/check-cross-references:386`, cujo grupo opcional `(?:-(\d+))?` já aceita a forma sem restringir os dois números a serem diferentes; recusá-la reprovaria citação que hoje resolve corretamente, contra IR1 |
| Esta spec carrega evidence classes? | Não — o vocabulário é definido por outra spec e ainda não existe | Seguir a convenção vigente | Padrão do projeto — [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md), section "After the Design", cuja tabela de seções obrigatórias hoje pede critério settleable por citação |
| A correção espera o modelo de evidência? | Não. É defeito autônomo, e [`2026-09-04-evidence-model-v2-design.md`](2026-09-04-evidence-model-v2-design.md) depende dela para ser implementada, não para ser escrita | Fatiar em duas specs | Padrão do projeto — [`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), section "The Traceability Table", em que critério de spec sem task vira `LOST IN TRANSLATION — BLOCKING`, sem escape para partição de escopo |
