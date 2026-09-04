# Evidence model — evidência que casa com a afirmação

**Route:** full process
**Data:** 2026-09-04

## Problem

O projeto trata `path/file.ext:line` como forma universal de prova. A regra raiz
em [`CLAUDE.md`](../../../CLAUDE.md), seção "How you work here", diz *"Every claim about
this code carries a `path/file.ext:line`"*, e
[`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), seção "Step 3:
Every Task in the Plan", converte isso em veredito: *"a criterion with no
`path/file.ext:line` citation is NOT DELIVERED"*.

Isso produz três defeitos.

**Primeiro, o audit não consegue representar uma classe inteira de critério.**
Não existe linha que prove ausência. "Nenhuma dependência nova foi
introduzida", "o manifest continua JSON válido", "todos os links locais
resolvem" são estruturalmente `NOT DELIVERED`, porque nenhuma linha os prova e
nenhum teste unitário os cobre. Este repositório produz exatamente esses
critérios: é zero-dependency por regra, valida `.claude-plugin/plugin.json`, e
roda `scripts/check-links.sh`. **O gate mais forte do projeto não sabe registrar
a prova das propriedades que o projeto declara sobre si mesmo.**

**Segundo, `file:line` apodrece em documento persistente, e isso já foi
medido aqui.** [`CHANGELOG.md`](../../../CHANGELOG.md), seção "Open gaps", registra 32
citações `file:line` dentro da própria seção, três resolvendo para nada e pelo
menos uma resolvendo para linha errada e não-branca. A resposta do projeto até
hoje foi uma exceção local — a seção usa markdown link mais título — em vez de
um modelo.

**Terceiro, a promessa pública é tecnicamente falsa.** [`README.md`](../../../README.md)
abre prometendo que toda afirmação carrega uma citação `file:line`, e o mesmo
está em [`docs/README.en.md`](../../README.en.md) e, traduzido, em
[`docs/README.pt-BR.md`](../../README.pt-BR.md).

**Fora de escopo.** Não entra: o gate de anchor fragment (adiado, ver AC18);
adicionar citação a `systematic-debugging` ou a `verification-before-completion`
(medido: nenhum dos dois usa a forma hoje, e a segunda teve a forma da
evidência deliberadamente extraída na 1.9.0); harmonizar as quatro faces de
review; e qualquer alteração em `README.kimi.md` ou `README.opencode.md`, que
não carregam a promessa.

## The model

Três camadas, e a separação entre elas é o desenho:

| Camada | Responsabilidade |
|---|---|
| Spec | Define o *requirement* e declara a **evidence class** |
| Plan | Resolve o **verification instrument** daquela classe |
| Audit | **Reexecuta** o instrumento e verifica |

**Delivery evidence classes** — o que uma entrega precisa provar:

| Classe | Delivery evidence | Verification evidence |
|---|---|---|
| `behavioral` | Located range da implementação | Teste automatizado cobrindo, citado por range |
| `structural` | Located range do artefato versionado | Comando validador read-only |
| `negative` | Escopo do artefato (não é evidência, é onde olhar) | Comando read-only sobre o diff ou o repo |

**Source class é coisa separada e não é classe de entrega.** `external`
— dependência travada no lockfile mais a linha lida, ou a doc oficial da versão
travada — fundamenta *decisão de design*. Nunca concede `DELIVERED`.

**Cláusula de contenção, dois invariantes distintos:**

1. **Task eligibility.** Toda task do plano continua precisando deixar um
   deliverable versionado no branch.
2. **Evidence adequacy.** `command + result` prova uma propriedade *do
   deliverable ou do estado do branch*, e é **read-only**. Nunca transforma
   deploy, publish, migração em ambiente vivo, monitoramento ou outro efeito
   externo em task auditável.

**Referência commit-pinned sai do modelo de evidência corrente.** Vira
*provenance* — legítima em changelog, investigação histórica e registro já
executado; nunca prova de entrega em `HEAD`.

## Acceptance Criteria

- **AC1** `[structural]` — `check-cross-references` rejeita `:0`, `:0-N` e range
  invertido, validando `1 <= start <= end <= line_count`.
- **AC2** `[structural]` — a mensagem de erro do checker preserva o range
  completo, não apenas o número inicial.
- **AC3** `[behavioral]` — `tests/hooks/test-check-cross-references.sh` carrega
  controle positivo e negativo para cada caso de AC1 e para AC2.
- **AC4** `[structural]` — `docs/evidence-model.md` existe e define as três
  delivery classes, a source class, os dois invariantes da cláusula de
  contenção, a regra do menor range e o estatuto de *provenance* da referência
  commit-pinned.
- **AC5** `[structural]` — `docs/evidence-model.md` não contém nenhum bloco
  `## Output Format` nem regra operacional que uma skill precise abrir para
  executar.
- **AC6** `[structural]` — `CLAUDE.md` e `AGENTS.md` carregam o princípio curto
  de evidence-or-zero na forma nova, e os dois textos são idênticos entre si.
- **AC7** `[structural]` — `README.md`, `docs/README.en.md` e
  `docs/README.pt-BR.md` descrevem a promessa como evidência que casa com a
  afirmação, sem prometer `file:line` como forma universal.
- **AC8** `[structural]` — `brainstorming/SKILL.md` exige uma evidence class
  declarada por `AC` e por `IR`, e `references/coverage-map.md` deixa de definir
  testabilidade por `file:line`.
- **AC9** `[structural]` — `brainstorming/SKILL.md` mantém `## Codebase
  Findings` como located evidence com fragmento citado, e passa a pedir o menor
  fragmento que identifica o fato.
- **AC10** `[structural]` — `spec-document-reviewer-prompt.md` bloqueia critério
  sem evidence class declarada e critério que nenhuma evidência admissível pode
  resolver.
- **AC11** `[structural]` — `writing-plans/SKILL.md` faz o plano resolver o
  verification instrument de cada critério, e distingue *locator* (navegação) de
  *evidence* (prova).
- **AC12** `[structural]` — `writing-plans/SKILL.md` preserva o invariante de
  task eligibility com a redação nova, sem passar a admitir efeito externo.
- **AC13** `[structural]` — `plan-document-reviewer-prompt.md` bloqueia critério
  cujo verification instrument o plano não resolveu.
- **AC14** `[structural]` — a tabela de `final-branch-audit/SKILL.md` usa as
  colunas `Task | Criterion | Delivery evidence | Verification evidence |
  Verdict`.
- **AC15** `[behavioral]` — o audit emite `EVIDENCE CLASS MISMATCH — BLOCKING`
  ao discordar da classe declarada, devolvendo à spec ou ao humano, e nunca
  reclassifica por conta própria para conceder `DELIVERED`.
- **AC16** `[behavioral]` — o audit pode sempre exigir evidência adicional, e
  executa verification commands read-only por critério.
- **AC17** `[behavioral]` — critério de spec sem evidence class declarada é
  tratado como `legacy behavioral`, preservando exatamente o veredito anterior.
- **AC18** `[structural]` — `docs/review-scopes.md` declara que o final audit
  passa a executar criterion-specific read-only verification, sem assumir o
  papel do reviewer da suíte do projeto.
- **AC19** `[structural]` — `task-reviewer-prompt.md` consegue representar
  verificação de critério que não é arquivo de teste.
- **AC20** `[structural]` — `code-reviewer.md` e `re-review-prompt.md` admitem
  command evidence para achado transversal, mantendo located range para achado
  local.
- **AC21** `[structural]` — o item de `## Open gaps` sobre o gate de `file:line`
  é reescrito: a premissa expirou, e os três regimes — *ephemeral*, *live
  persistent*, *historical* — ficam registrados.
- **AC22** `[structural]` — a versão nos manifests é `2.0.0`, escrita por
  `scripts/bump-version.sh`.

## Implicit Requirements

- **IR1** `[structural]` — nenhum `SKILL.md` passa de 500 linhas.
  `writing-plans/SKILL.md` está em 471 e é o binding constraint; o que não
  couber vai para `references/`, nunca por compressão.
- **IR2** `[negative]` — a mudança não introduz dependência externa.
- **IR3** `[structural]` — `scripts/check-evidence-line.sh` continua verde: a
  forma `Command`/`exit`/`counts` não muda em nenhum carrier.
- **IR4** `[structural]` — `scripts/check-links.sh` continua verde com o
  documento novo e com os links acrescentados.
- **IR5** `[structural]` — o anchor fragment **não** é construído neste ciclo;
  nenhum gate novo passa a exigir fragmento em citação.
- **IR6** `[structural]` — `CHANGELOG.md` ganha entrada em `[Unreleased]` para
  cada arquivo tocado sob `skills/`, `scripts/` e `hooks/`.

## Codebase Findings

- **A regra raiz trata `path:line` como universal.** [`CLAUDE.md`](../../../CLAUDE.md) e
  [`AGENTS.md`](../../../AGENTS.md), ambos na seção "How you work here":
  *"Every claim about this code carries a `path/file.ext:line`."* Os dois
  arquivos carregam o texto idêntico.
- **O audit converte isso em veredito.**
  [`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), seção
  "Step 3: Every Task in the Plan": *"Evidence-or-zero: a criterion with no
  `path/file.ext:line` citation is NOT DELIVERED."* E na seção "Verdict Rules":
  *"Implementation cited, no covering test | NOT DELIVERED"*.
- **A tabela atual tem as colunas antigas.** Mesma skill, seção "Step 3":
  `| Task | Criterion | Implementation | Test | Verdict |`.
- **O auditor já é declarado não-confiante em relatório alheio.** Mesma skill,
  seção "Step 3": *"The plan, the ledger, the implementer reports, and any prior
  review approval are claims under audit — never evidence."* É a fonte do
  desenho híbrido restrito: o auditor não aceita a palavra de ninguém, mas
  também não pode conceder entrega reclassificando sozinho.
- **Um caminho de divergência registrada já existe.** Mesma skill, seção
  "Verdict Rules": *"Criterion delivered somewhere other than the plan said |
  DELIVERED — note the real location in the row"*. `EVIDENCE CLASS MISMATCH`
  segue essa forma, com veredito bloqueante em vez de concessivo.
- **O bug de range é real e foi medido por execução, com controle.**
  `skills/writing-plans/scripts/check-cross-references:386` define
  `CITATION = re.compile(r"`([^`\s]+\.[A-Za-z0-9_]+):(\d+)(?:-(\d+))?`")` — o
  range já é aceito. A validação em
  `skills/writing-plans/scripts/check-cross-references:409-415` faz
  `end = int(last) if last else first` e só compara `end > n`; `first` nunca é
  validado. Medido em 2026-09-04 contra este checkout, citando `README.md`
  (171 linhas) com os ranges `10-5`, `0-5` e `0`: os três retornam exit 0. O
  controle, o mesmo arquivo com o range `5-200`, retorna exit 1 com uma
  mensagem que nomeia a linha 5 quando o inválido é o 200 — é a evidência de
  AC2. **Esta própria spec demonstrou o defeito ao ser escrita:** o gate de
  citações do hook aceitou os três ranges inválidos que este parágrafo
  descrevia e reprovou apenas o controle, que era o único bem-formado.
- **A forma `command + result` já existe e tem gate de formato, não de
  conteúdo.** `scripts/check-evidence-line.sh:17-19` declara: *"It reads field
  names, never their content: `**exit:** [code]` and `**exit:** [the moon]` are
  identical to this check."* Roda no pre-commit em `githooks/pre-commit:40` e no
  CI em `.github/workflows/ci.yml:206`.
- **A forma dentro de `## Output Format` de subagente não pode ficar atrás de
  link.** `scripts/check-evidence-line.sh:6-10` registra a medição: *"a form
  inside a subagent's output block must not sit behind a link, because the agent
  filling the block does not follow it"*, medido 1/3 e depois 3/3 quando a forma
  voltou ao ponto de uso. É a fonte da decisão de manter inline o subconjunto
  que cada reviewer executa.
- **O contrato atual do audit exclui execução.**
  [`docs/review-scopes.md`](../../review-scopes.md), seção "Face": *"**No tests at
  all** — re-runs the *searches* against the spec"*. AC18 altera essa linha.
- **A promessa pública, medida.** `README.md` carrega `file:line` 5 vezes,
  `docs/README.en.md` 3 vezes, e `docs/README.pt-BR.md` carrega a forma
  traduzida `arquivo:linha` 3 vezes. `docs/README.kimi.md` e
  `docs/README.opencode.md` não carregam nenhuma das duas — remedido com
  `grep -a` para descartar classificação binária por acento.
- **O teto de tamanho e a folga real.** `scripts/check-skill-size.sh:34` fixa
  `MAX=500`. Medido em 2026-09-04: `writing-plans/SKILL.md` 471 linhas,
  `brainstorming/SKILL.md` 403, `final-branch-audit/SKILL.md` 372.
- **A premissa do item de Open gaps expirou.**
  [`CHANGELOG.md`](../../../CHANGELOG.md), seção "Open gaps", item que abre com *"The
  `file:line` form has no gate"*: diz *"Not built, and the condition is the
  whole point of the entry: the first code anchor found drifted turns this from
  a design into a defect"* — e o mesmo item registra que em 2026-08-26 um foi
  achado podre, no commit `f4a3444`, defendendo-se com *"executed plans were
  outside that scan"* e admitindo *"Whether they belong inside it is the half of
  this item that is actually open"*.
- **A testabilidade do coverage map ainda é definida por `file:line`.**
  [`brainstorming/references/coverage-map.md`](../../../skills/brainstorming/references/coverage-map.md),
  seção "Categories": *"A criterion no `file:line` can settle cannot be traced by
  the plan or the final audit"*. AC8 alcança esta linha.

## External Dependencies

None. O projeto é zero-dependency por regra de [`CLAUDE.md`](../../../CLAUDE.md), seção
"What does not belong here", e nada nesta mudança introduz uma. As únicas
ferramentas usadas — `python3`, `bash`, `git` — já são pressupostas pelos gates
existentes.

## Assumptions to Confirm

- **Nenhuma spec ou plano vivo neste repositório precisa de reescrita imediata
  de classe.** Verificado por listagem de `docs/superpowers/specs/` (5 arquivos,
  o mais recente de 2026-09-03) e pela regra de AC17, que trata critério sem
  classe como `legacy behavioral`. Não foi aberto cada um dos 5 para confirmar
  que nenhum depende do veredito antigo de um jeito que o fallback não cubra.
- **O universo de validação do anchor fragment segue indefinido.** É a metade
  declarada aberta do próprio item de Open gaps: planos executados entram ou não
  no escaneamento. AC21 registra a pergunta; não a responde.
- **O número de linhas que cada edição acrescenta a `writing-plans/SKILL.md`
  ainda não foi medido**, porque depende do texto final. IR1 é a guarda; se a
  edição passar de 29 linhas, o excedente vai para `references/`.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC22; o escopo veio decidido em conversa, não inferido |
| Domain and data model | Clear | Não há dado nem entidade: a mudança é normativa e de um script |
| Interaction flow | Clear | Sem interface; o "fluxo" é a cadeia spec → plan → audit, resolvida na seção The model |
| Non-functional attributes | Resolved | IR1 (teto de linhas), IR3 e IR4 (gates existentes verdes) |
| Integrations and external dependencies | Clear | IR2 e `## External Dependencies`: zero-dependency por regra |
| Edge cases and failures | Resolved | AC1–AC3 são exatamente os edge cases do parser; AC17 é o edge case da spec antiga |
| Constraints and tradeoffs | Resolved | IR1: `writing-plans` a 29 linhas do teto é a restrição que molda onde o texto mora |
| Terminology | Resolved | *evidence class* × *source class*, *locator* × *evidence*, *provenance* — separados na seção The model a pedido explícito |
| Completion signals | Resolved | Cada AC e IR carrega a própria classe; a spec aplica em si o modelo que define |
| Placeholders and vague adjectives | Clear | Nenhum adjetivo não quantificado sobreviveu: os números são medidos e datados |

### Decision record

| Pergunta | Resposta | Recomendação dada | Fonte declarada |
|---|---|---|---|
| Quem declara a evidence class? | Híbrido restrito: spec declara; auditor contesta com `EVIDENCE CLASS MISMATCH — BLOCKING`, nunca reclassifica para conceder | A spec declara | Padrão do projeto — `final-branch-audit/SKILL.md`, seção "Step 3", *"claims under audit — never evidence"* |
| Nível do bump? | MAJOR, com regra de fallback | MAJOR + fallback | Padrão do projeto — `CLAUDE.md`, seção "Versioning" |
| Onde mora o modelo? | `docs/evidence-model.md` canônico conceitual; regra operacional e Output Format ficam inline em cada skill | `docs/review-scopes.md` absorve | Padrão do projeto — `scripts/check-evidence-line.sh:6-10`, a medição 1/3 → 3/3 sobre forma atrás de link. **Recomendação recusada pelo parceiro**, que separou documentação conceitual de regra executável |
| Anchor fragment entra? | 4a agora (reescrever o item), 4b adiada | 4a obrigatório, 4b adiada | Padrão do projeto — `CLAUDE.md`, seção "How you work here", regra do Open gaps expirado |
| Source class é delivery class? | Não; `external` é evidência de design | *(não perguntada — trazida pelo parceiro)* | Decisão do parceiro |
| Onde o instrumento é resolvido? | No plano, não na spec nem no audit | *(não perguntada — trazida pelo parceiro)* | Decisão do parceiro |
