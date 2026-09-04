# Evidence Model v2 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-09-04-evidence-model-v2-design.md`

**Goal:** Substituir `path/file.ext:line` como forma universal de prova por três
delivery evidence classes declaradas na spec, resolvidas em instrumento pelo
plano e reexecutadas pela auditoria.

**Architecture:** A mudança é normativa e mora em texto: dezessete carriers, um
documento conceitual novo e um script. A cadeia é de três camadas — a spec
declara a classe, o plano resolve o instrumento, o audit reexecuta — e cada task
entrega um carrier inteiro, porque um reviewer consegue reprovar o carrier da
camada de plano aprovando o da camada de spec. A única task com teste
automatizado é a do parser, que é o único sujeito determinístico do conjunto.

**Tech Stack:** `python3` embutido em
`skills/writing-plans/scripts/check-cross-references:1` e `bash` em
`tests/hooks/test-check-cross-references.sh:1`. Nenhuma entrada nova: a spec
declara `## External Dependencies` como `None`, e IR2 é a guarda.

**Execution:** _(em branco até seu parceiro escolher o caminho ao fim de writing-plans)_

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it.

## Este plano aplica o modelo que entrega

**A matriz abaixo tem seis colunas e se chama Verification Matrix, que é o
formato instalado pela Task 6.** A spec faz o mesmo consigo mesma — declara
classe em cada critério antes de a regra existir, e registra isso em seu
`## Coverage Map`, na linha *Completion signals*. A alternativa era preencher os
48 critérios não-`behavioral` com asserções estáticas inventadas, que a AC12
manda não escrever e que alguém teria de apagar na task seguinte.

**Consequência conhecida, e ela não é surpresa:** o plan reviewer aplica hoje
`skills/writing-plans/plan-document-reviewer-prompt.md:89`, que reprova como
bloqueante uma matriz que não seja `## Test Coverage Matrix` com as cinco colunas
e *"one test each"*. O achado que ele devolver sobre a forma da matriz é a regra
que a Task 7 substitui — e é achado sobre o formato, nunca licença para ignorar
o que ele disser sobre cobertura, rastreabilidade ou passos.

**Ordem entre os dois planos desta linha de trabalho.**
`docs/superpowers/plans/2026-09-04-cross-reference-range-validation.md` toca o
mesmo arquivo que a Task 3 daqui, em região diferente (o laço de citações, não o
parser da matriz). **Execute aquele plano primeiro**: ele é menor, independente,
e deixa este com um só diff a resolver em vez de dois.

## Global Constraints

Copiadas da `## Implicit Requirements` da spec. Vinculam toda task.

- **IR1** — Nenhum `SKILL.md` **não isento** excede 500 linhas. A isenção é
  declarada em `scripts/check-skill-size.sh:43`
  (`EXEMPT=(skills/writing-skills/SKILL.md)`) e não é alterada por esta mudança.
  O que não couber vai para `references/`, nunca por compressão.
- **IR2** — A mudança não introduz dependência externa.
- **IR3** — `scripts/check-evidence-line.sh` continua verde: a forma
  `Command`/`exit`/`counts` não muda em nenhum carrier.
- **IR4** — `scripts/check-links.sh` continua verde com o documento novo e os
  links acrescentados.
- **IR5** — Nenhum gate novo passa a exigir fragmento literal em citação.
- **IR6** — Nenhum arquivo novo entra em `scripts/` nesta branch.
- **IR7** — `scripts/check-docs-sync.sh` continua verde: `docs/README.pt-BR.md`
  e `docs/README.en.md` mudam no mesmo commit.
- **IR8** — `CHANGELOG.md` recebe entrada em `[Unreleased]` para cada commit que
  toque `skills/`, `scripts/`, `githooks/`, `.github/` ou `hooks/`.
- **IR9** — O anchor-fragment gate não é construído nesta branch.
- **IR10** — Nenhum plano já commitado em `docs/superpowers/plans/` muda de
  veredito por causa da mudança em `check-cross-references`.

**Baseline medida em 04/09/2026, antes da primeira task:**
`tests/hooks/test-check-cross-references.sh` sai com 0 e imprime 33 linhas
`[PASS]`. `scripts/check-links.sh` sai com 0. Tamanhos dos `SKILL.md` perto do
teto de 500: `writing-plans` 471, `subagent-driven-development` 468,
`brainstorming` 403, `final-branch-audit` 372, `executing-plans` 242.
`CHANGELOG.md` não tem seção `[Unreleased]` — a 1.25.0 foi cortada — então a
primeira task que tocar `skills/` a cria.

## Verification Matrix

Uma linha por critério de task. As colunas são as seis que a spec fixa em
`## The model`. `Test type` e `Layer` trazem `—` fora de `behavioral`, e isso
não é achado: nenhuma linha finge ter teste. O tipo `static` e a camada `tests/`
são o vocabulário deste repositório — `docs/testing.md:6-8` descreve `tests/`
como *"Bash + node + python checks for manifests, plugin loading, hooks, sync
scripts, and skill behavior"*.

Os instrumentos `structural` e `negative` são comandos read-only escritos **sem
redirecionamento e sem `::`**, deliberadamente: o parser atual lê `>` e `::` em
qualquer célula como nome de teste
(`skills/writing-plans/scripts/check-cross-references:283-292`), que é o defeito
que a Task 3 corrige. Escrever a matriz deste plano em torno dele é a única
forma de ela passar pelo gate antes de a correção existir.

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|---|---|---|---|---|---|
| T1.1 O documento canônico define os treze conceitos | AC1 | structural | `grep -c` por cada um dos treze títulos em `docs/evidence-model.md`, esperando 13 | — | — |
| T1.2 O documento não carrega bloco de formato de saída | AC2 | negative | `grep -c '^## Output Format' docs/evidence-model.md`, esperando 0 | — | — |
| T1.3 O documento não define conceito ausente da spec | AC27 | negative | listar os headings de nível 3 do documento e conferir cada um contra a seção The model da spec | — | — |
| T1.4 Os links do documento novo resolvem | IR4 | negative | `scripts/check-links.sh`, exit 0 | — | — |
| T2.1 A regra raiz pede evidência que casa com a afirmação | AC3 | structural | range localizado em `CLAUDE.md` e o mesmo em `AGENTS.md` | — | — |
| T2.2 A regra de adequação do instrumento está nos dois arquivos | AC4 | structural | range localizado em `CLAUDE.md` e o mesmo em `AGENTS.md` | — | — |
| T2.3 Os dois arquivos continuam idênticos na região mudada | AC3, AC4 | negative | `diff CLAUDE.md AGENTS.md`, sem diferença na região | — | — |
| T3.1 O parser localiza colunas pelo cabeçalho e lê a classe | AC37 | structural | range localizado em `skills/writing-plans/scripts/check-cross-references` | — | — |
| T3.2 Os sete comportamentos do parser têm caso determinístico | AC38 | behavioral | > a structural instrument holding an angle bracket is not a test | static | `tests/` |
| T3.3 O parser reconhece os dois schemas sem migrar plano histórico | AC39 | structural | range localizado em `skills/writing-plans/scripts/check-cross-references` | — | — |
| T3.4 Os dois schemas têm caso, e o corpus é comparado | AC40 | behavioral | > a legacy five-column matrix still passes | static | `tests/` |
| T3.5 Nenhum plano commitado muda de veredito | IR10 | negative | o caso de baseline pinado de `tests/hooks/test-check-cross-references.sh:34`, comparando o veredito de cada documento commitado antes e depois | — | — |
| T3.6 O script não ganha dependência externa | IR2 | negative | `grep -n 'import'` no script, conferindo cada módulo contra a stdlib | — | — |
| T4.1 A regra de adequação é operacional em brainstorming | AC5 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.2 A skill exige evidence class por critério | AC7 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.3 Codebase Findings pede o menor range suficiente | AC9 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.4 A skill escreve o marcador no cabeçalho da spec | AC36 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.5 O coverage map define testabilidade por evidência admissível | AC8 | structural | range localizado em `skills/brainstorming/references/coverage-map.md` | — | — |
| T5.1 O spec reviewer bloqueia alegação com instrumento parcial | AC6 | structural | range localizado em `skills/brainstorming/spec-document-reviewer-prompt.md` | — | — |
| T5.2 O spec reviewer bloqueia critério sem classe | AC10 | structural | range localizado em `skills/brainstorming/spec-document-reviewer-prompt.md` | — | — |
| T5.3 O spec reviewer bloqueia critério que nenhuma evidência resolve | AC11 | structural | range localizado em `skills/brainstorming/spec-document-reviewer-prompt.md` | — | — |
| T5.4 O spec reviewer exige o marcador e não conclui compatibilidade | AC35 | structural | range localizado em `skills/brainstorming/spec-document-reviewer-prompt.md` | — | — |
| T6.1 A Verification Matrix substitui a Test Coverage Matrix | AC12 | structural | range localizado em `skills/writing-plans/SKILL.md` | — | — |
| T6.2 As quatro regras que universalizam teste são substituídas | AC31 | negative | `grep -c 'One row, one test'` em `skills/writing-plans/SKILL.md`, esperando 0 | — | — |
| T6.3 O bloco de arquivos distingue locator de evidence | AC14 | structural | range localizado em `skills/writing-plans/SKILL.md` | — | — |
| T6.4 O invariante de elegibilidade de task sobrevive à redação nova | AC15 | structural | range localizado em `skills/writing-plans/SKILL.md` | — | — |
| T6.5 O bloco da task carrega o contrato inteiro | AC30 | structural | range localizado em `skills/writing-plans/SKILL.md` | — | — |
| T6.6 A skill decide pelo marcador, sem heurística | AC34 | structural | range localizado em `skills/writing-plans/SKILL.md` | — | — |
| T7.1 O plan reviewer cobra as seis colunas e a semântica da classe | AC13 | structural | range localizado em `skills/writing-plans/plan-document-reviewer-prompt.md` | — | — |
| T7.2 O plan reviewer decide pelo marcador | AC34 | structural | range localizado em `skills/writing-plans/plan-document-reviewer-prompt.md` | — | — |
| T8.1 A tabela do audit tem as colunas novas nas duas ocorrências | AC16 | structural | `grep -c 'Delivery evidence'` em `skills/final-branch-audit/SKILL.md`, esperando 2 | — | — |
| T8.2 O veredito de classe inadequada existe e bloqueia | AC17 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.3 O auditor aponta inadequação e não reclassifica para conceder | AC18 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.4 O auditor executa verificação read-only por critério | AC19 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.5 O audit aplica o discriminador de compatibilidade | AC20 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.6 O contrato do audit em review-scopes admite execução read-only | AC21 | structural | range localizado em `docs/review-scopes.md` | — | — |
| T9.1 O task reviewer verifica por classe declarada | AC22 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.2 A tabela de evidência generaliza para Verification Evidence | AC28 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.3 O litmus e a execução de testes sobrevivem para behavioral | AC29 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.4 A forma da linha de evidência não muda | IR3 | negative | `scripts/check-evidence-line.sh`, exit 0 | — | — |
| T10.1 O controller entrega instrumentos e não deriva comando universal | AC32 | structural | range localizado em `skills/subagent-driven-development/SKILL.md` | — | — |
| T11.1 O preflight inline exige classe e instrumento admissível | AC33 | structural | range localizado em `skills/executing-plans/SKILL.md` | — | — |
| T12.1 Os dois reviewers de código admitem command evidence | AC23 | structural | range localizado em `skills/requesting-code-review/code-reviewer.md` e em `skills/subagent-driven-development/re-review-prompt.md` | — | — |
| T13.1 A referência canônica descreve a promessa nova | AC24 | structural | range localizado em `docs/README.pt-BR.md` e em `docs/README.en.md` | — | — |
| T13.2 O showcase descreve a promessa nova | AC25 | structural | range localizado em `README.md` | — | — |
| T13.3 O par de referências muda no mesmo commit | IR7 | negative | `scripts/check-docs-sync.sh`, exit 0 | — | — |
| T14.1 O item de Open gaps para de afirmar ausência de defeito | AC26 | structural | range localizado em `CHANGELOG.md` | — | — |
| T14.2 Nenhum SKILL.md não isento passa de 500 linhas | IR1 | negative | `scripts/check-skill-size.sh`, exit 0 | — | — |
| T14.3 Nenhum gate novo exige fragmento literal | IR5 | negative | `git diff --name-only` da branch, conferindo que nada em `scripts/` mudou de contrato | — | — |
| T14.4 Nenhum arquivo novo entra em scripts | IR6 | negative | `git diff --diff-filter=A --name-only` da branch, limitado a `scripts/` | — | — |
| T14.5 O anchor-fragment gate não foi construído | IR9 | negative | `git diff --diff-filter=A --name-only` da branch, procurando gate de fragmento | — | — |
| T14.6 Todo commit que toca skills tem entrada de changelog | IR8 | negative | `git log --format` da branch cruzado com `git show --name-only` por commit | — | — |

This plan has 14 tasks.

---

### Task 1: O documento conceitual canônico

**Spec criterion:** AC1, AC2, AC27; IR4

**Files:**
- Create: `docs/evidence-model.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nada — é a primeira task.
- Produces: os treze títulos de seção que as tasks seguintes citam por markdown
  link mais título de seção. Os nomes exatos estão no Step 1.

**Acceptance criteria:**
- T1.1: `docs/evidence-model.md` define os treze conceitos que `## The model` da spec enuncia — instrumento na matriz
- T1.2: `docs/evidence-model.md` não contém nenhum bloco `## Output Format` — instrumento na matriz
- T1.3: `docs/evidence-model.md` não define nenhum conceito que a spec não enuncie — instrumento na matriz
- T1.4: `scripts/check-links.sh` continua verde com o documento novo — instrumento na matriz

- [ ] **Step 1: Escrever o documento**

Crie `docs/evidence-model.md` com exatamente treze seções de nível 3, nesta
ordem e com estes títulos — a contagem é o instrumento de T1.1 e T1.3, e um
título a mais ou a menos move os dois:

```
### The three layers
### Delivery evidence classes
### Source evidence is not a delivery class
### Measurement status is a separate dimension
### Smallest sufficient range
### Live-document reference
### The three freshness regimes
### Locator is not evidence
### Current-state evidence is not provenance
### The instrument must match the scope of the claim
### The containment clause
### The Verification Matrix
### Compatibility: legacy behavioral
```

O corpo de cada seção é o texto correspondente de
`docs/superpowers/specs/2026-09-04-evidence-model-v2-design.md`, seção
`## The model`, traduzido para inglês e sem as tabelas de decisão, que são da
spec e não do modelo. **Não acrescente nenhum conceito** — T1.3 é uma proibição,
e o instrumento dela é a comparação um a um com a spec.

O documento **não** carrega bloco `## Output Format`: essa forma vive inline no
ponto de uso de cada subagente, e a razão está medida em
`scripts/check-evidence-line.sh:6-10`, que registra 1/3 → 3/3 quando a forma
voltou ao ponto de uso.

- [ ] **Step 2: Verificar T1.1 e T1.2**

```bash
grep -c '^### ' docs/evidence-model.md
grep -c '^## Output Format' docs/evidence-model.md
```

Expected: `13` e `0`. **`grep -c` imprime `0` e sai com status 1**, então a
segunda linha termina com status 1 quando está correta — leia o número, não o
status.

- [ ] **Step 3: Verificar T1.3, conceito a conceito**

```bash
grep '^### ' docs/evidence-model.md
```

Abra `docs/superpowers/specs/2026-09-04-evidence-model-v2-design.md` na seção
`## The model` e confira que **cada** título listado corresponde a um conceito
ali enunciado. Um título sem correspondência é violação de T1.3 e se remove; um
conceito da spec sem título é violação de T1.1 e se acrescenta.

- [ ] **Step 4: Verificar T1.4**

```bash
scripts/check-links.sh
```

Expected: exit 0.

- [ ] **Step 5: Escrever a entrada de CHANGELOG e conferir antes de commitar**

Crie a seção `## [Unreleased]` acima de `## [1.25.0] - 2026-09-04` com uma
entrada `### Added` descrevendo o documento e o problema que ele resolve: a
forma universal `path:line` reprova por construção todo critério de ausência.

```bash
git status --short
grep -n '^## \[Unreleased\]' CHANGELOG.md
```

Expected: dois arquivos e a seção presente.

- [ ] **Step 6: Commit**

```bash
git add docs/evidence-model.md CHANGELOG.md
git commit -m "docs: o modelo de evidencia ganha documento conceitual canonico"
```

---

### Task 2: A regra raiz nos dois arquivos de instrução

**Spec criterion:** AC3, AC4

**Files:**
- Modify: `CLAUDE.md:7`
- Modify: `AGENTS.md:7`

**Interfaces:**
- Consumes: `docs/evidence-model.md` da Task 1, referenciado por markdown link.
- Produces: a formulação da regra raiz que as tasks 4 a 12 refinam em regra
  operacional. Nenhuma delas copia este texto; todas o pressupõem.

**Acceptance criteria:**
- T2.1: os dois arquivos afirmam que toda afirmação material carrega evidência que casa com a afirmação, e que um caminho sozinho é localização e não prova — instrumento na matriz
- T2.2: os dois arquivos carregam a regra de adequação do instrumento ao alcance da alegação — instrumento na matriz
- T2.3: os dois arquivos continuam idênticos entre si na região mudada — instrumento na matriz

- [ ] **Step 1: Substituir o parágrafo da regra raiz**

Em `CLAUDE.md`, a linha 7 hoje diz:

```markdown
**Evidence-or-zero is the rule this project exists to enforce, and it applies to you.** Every claim about this code carries a `path/file.ext:line`. A claim you cannot locate is not a claim — say you could not verify it. An unverified statement and a verified one look identical once written down, which is the whole failure this repository was built to separate.
```

Substitua por:

```markdown
**Evidence-or-zero is the rule this project exists to enforce, and it applies to you.** Every material claim about this code carries evidence that fits the claim: a located line range for something that exists, an executable read-only check for something that holds across a scope, a grounded source for something a dependency guarantees. **A path on its own is a location, not a proof** — it says where to look, and the claim is what you found there. A claim you can neither locate nor check is not a claim; say you could not verify it. An unverified statement and a verified one look identical once written down, which is the whole failure this repository was built to separate. The three delivery evidence classes and what each one admits are in [`docs/evidence-model.md`](docs/evidence-model.md).
```

- [ ] **Step 2: Acrescentar a regra de adequação do instrumento**

Imediatamente depois do item `- **Measure, don't estimate.**` — hoje a linha 9 —
insira:

```markdown
- **The instrument must match the scope of the claim.** A sampled, truncated, paginated or filtered view establishes no completeness, cardinality, uniqueness or absence. `ls | tail -5` is a command that ran; it answers nothing about how many files there are. A claim about a whole set needs an instrument exhaustive over that set, and the command you show is the one that was exhaustive.
```

- [ ] **Step 3: Espelhar em `AGENTS.md`**

`AGENTS.md:7` carrega hoje o mesmo parágrafo, palavra por palavra. Aplique as
duas edições dos Steps 1 e 2 ali também, idênticas.

- [ ] **Step 4: Verificar T2.3**

```bash
diff CLAUDE.md AGENTS.md
```

Expected: as diferenças que já existiam antes desta task, e **nenhuma nova** nas
linhas 7 a 11. Se `diff` mostrar diferença nova, os dois textos divergiram e
AC3 e AC4 estão violados.

- [ ] **Step 5: Conferir e commitar**

```bash
git diff --stat
```

Expected: dois arquivos. **`CLAUDE.md` e `AGENTS.md` não estão entre os caminhos
que `scripts/check-changelog.sh` cobra**, então este commit não precisa de
entrada; o gate não vai reclamar e a ausência é correta.

```bash
git add CLAUDE.md AGENTS.md
git commit -m "docs: a regra raiz pede evidencia que casa com a afirmacao"
```

---

### Task 3: O parser da matriz passa a ler cabeçalho e classe

**Spec criterion:** AC37, AC38, AC39, AC40; IR2, IR10

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:278-298`
- Test: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nada das tasks 1 e 2 — este é o único carrier executável do plano.
- Produces: o parser que a Task 6 pressupõe ao instalar a Verification Matrix em
  `writing-plans/SKILL.md`. **Esta task vem antes da Task 6 de propósito**: se o
  formato chegasse primeiro, todo plano escrito no intervalo quebraria o gate.

**Acceptance criteria:**
- T3.1: o parser localiza as colunas pelos títulos, lê `Evidence class` e `Verification instrument`, e interpreta o instrumento como id de teste apenas na row `behavioral` — instrumento na matriz
- T3.2: os sete comportamentos de T3.1 têm caso determinístico na suíte — test: `> a structural instrument holding an angle bracket is not a test`
- T3.3: o parser reconhece os dois schemas e preserva o comportamento anterior na matriz de cinco colunas — instrumento na matriz
- T3.4: os dois schemas têm caso na suíte — test: `> a legacy five-column matrix still passes`
- T3.5: nenhum plano já commitado muda de veredito — instrumento na matriz
- T3.6: o script não ganha dependência externa — instrumento na matriz

- [ ] **Step 1: Escrever os casos que falham**

Insira o bloco abaixo em `tests/hooks/test-check-cross-references.sh`,
imediatamente depois de `run_case "announced task count that disagrees fails"`.
As fixtures derivam de `CLEAN_PLAN`, já definido na suíte, em vez de repetirem
seu texto — é o mesmo motivo pelo qual os pares de `run_case` existentes usam
`sed` sobre a fixture limpa.

````bash
# --- Verification Matrix: header-aware, evidence-class-aware --------------
# Measured 2026-09-04 against this checkout, before the fix: a `negative` row
# whose instrument was a shell command with a redirect exited 1, naming
# `/dev/null` as a test no step creates, and a `structural` row whose command
# ended in `::validate` exited 1 naming `validate`. The instrument column is
# exactly where read-only commands live, so parsing it without reading the
# class keeps the confusion.
VM_HEAD='## Verification Matrix

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|---|---|---|---|---|---|'

# CLEAN_PLAN minus its five-column matrix, plus a task criterion per row below.
VM_BODY="$(printf '%s' "$CLEAN_PLAN" |
    sed -e '/^## Test Coverage Matrix$/,$d' \
        -e 's/^- T1.1 rejects the bad input$/- T1.1 rejects the bad input\n- T1.2 the manifest parses\n- T1.3 no new dependency/')"

VM_PLAN="${VM_BODY}${VM_HEAD}
| T1.1 | AC1 | behavioral | > rejects the bad input | unit | tests |
| T1.2 | AC2 | structural | python3 -m json.tool manifest.json > /dev/null | — | — |
| T1.3 | AC3 | negative | the check lives at suite.sh::validate | — | — |"

run_case "a behavioral row naming a test a step creates passes" 0 "$VM_PLAN"

run_case "a behavioral row naming a test no step creates fails" 1 "$(printf '%s' "$VM_PLAN" |
    sed 's/| > rejects the bad input |/| > a test nobody wrote |/')"

run_case "a structural instrument holding an angle bracket is not a test" 0 "$VM_PLAN"

run_case "a negative instrument holding a double colon is not a test" 0 "$VM_PLAN"

run_case "a task criterion with no verification row still fails" 1 "$(printf '%s' "$VM_PLAN" |
    sed 's/^- T1.3 no new dependency$/- T1.3 no new dependency\n- T1.4 unrowed/')"

run_case "a verification row with no task criterion still fails" 1 "${VM_PLAN}
| T2.9 | AC9 | structural | a located range | — | — |"

run_case "a duplicated verification row still fails" 1 "${VM_PLAN}
| T1.2 | AC2 | structural | a second row for the same criterion | — | — |"

# --- the legacy five-column schema is not migrated during the read --------
run_case "a legacy five-column matrix still passes" 0 "$CLEAN_PLAN"

run_case "a legacy matrix naming a test no step creates still fails" 1 "$(printf '%s' "$CLEAN_PLAN" |
    sed 's/| T1.1 | > rejects the bad input |/| T1.1 | > a test nobody wrote |/')"
````

**Dois dos sete comportamentos compartilham fixture com o primeiro caso.** As
linhas `structural` e `negative` do `VM_PLAN` são justamente as que hoje
reprovam; o caso que as nomeia existe porque um verde no primeiro caso não diz
qual das três rows o produziu.

- [ ] **Step 2: Rodar para ver falhar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL — quatro casos vermelhos com `expected exit 0, got 1`:
`a behavioral row naming a test a step creates passes`,
`a structural instrument holding an angle bracket is not a test`,
`a negative instrument holding a double colon is not a test` e o caso de row
duplicada, que hoje falha pelo motivo errado. A saída nomeia `/dev/null` e
`validate` como testes que nenhum step cria — **é essa mensagem que confirma que
o vermelho é o defeito sob teste, e não um erro de fixture.**

- [ ] **Step 3: Escrever a correção**

Em `skills/writing-plans/scripts/check-cross-references`, substitua o laço que
hoje varre **toda** célula de **toda** row. O bloco atual começa em
`skills/writing-plans/scripts/check-cross-references:283` com
`for ln in matrix_rows:` e vai até a linha que fecha a segunda `re.search`.
Ponha no lugar:

```python
def _cells(ln):
    """The table row's cells, stripped of pipes, spaces and backticks."""
    return [c.strip().strip("`") for c in ln.strip().strip("|").split("|")]


# Which header each matrix row sits under. A plan carries one matrix, but a
# document that DOCUMENTS the format carries an example beside the real one,
# and the two can use different schemas. Headers and rows are contiguous —
# the `|---|` separator starts with a pipe too — so a non-table line ends the
# current table.
header_for = {}
current_header = None
for ln in prose_lines:
    if ln.lstrip().startswith("|"):
        low = [c.lower() for c in _cells(ln)]
        if "criterion" in low and "spec criterion" in low:
            current_header = low
            continue
        if TASK_CRIT.search(ln):
            header_for[ln] = current_header
    elif ln.strip():
        current_header = None

named_in_matrix = set()
matrix_suites = []
for ln in matrix_rows:
    header = header_for.get(ln)
    cells = _cells(ln)
    if header and "evidence class" in header:
        # Six-column Verification Matrix. Only a `behavioral` row names a
        # test; in `structural` and `negative` the instrument is a read-only
        # command, and `>` and `::` inside it are shell syntax, not test ids.
        idx = header.index("evidence class")
        klass = cells[idx].lower() if idx < len(cells) else ""
        if klass != "behavioral":
            continue
        if "verification instrument" in header:
            j = header.index("verification instrument")
            cells = [cells[j]] if j < len(cells) else []
    # No `Evidence class` column: the historical Test Coverage Matrix. Every
    # cell is scanned, exactly as before — a committed plan keeps its verdict.
    for cell in cells:
        m = re.search(r">\s*(.+?)\s*$", cell)
        if m:
            named_in_matrix.add(m.group(1).strip().strip("`"))
            suite = cell[: m.start()].strip().strip("`")
            if suite:
                matrix_suites.append((suite, m.group(1).strip().strip("`")))
        m = re.search(r"::(\w+)\s*$", cell)
        if m:
            named_in_matrix.add(m.group(1))
```

`matrix_rows`, `matrix_labels` e as checagens de órfão e de duplicata ficam
**intocadas**: elas valem para toda classe, e é o que AC37 pede.

- [ ] **Step 4: Rodar para ver passar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — exit 0, e a contagem de `[PASS]` sobe de 33 para 42.

- [ ] **Step 5: Provar que cada metade da correção entra**

Duas mutações, uma por metade. Depois de cada uma, **restaure o arquivo** e
confirme exit 0 antes da próxima.

1. Troque `if klass != "behavioral":` por `if False:`. Esperado:
   `a structural instrument holding an angle bracket is not a test` e
   `a negative instrument holding a double colon is not a test` ficam vermelhos.
2. Troque `if header and "evidence class" in header:` por `if False:`. Esperado:
   os mesmos dois ficam vermelhos, e `a legacy five-column matrix still passes`
   continua verde — que é a prova de que a metade histórica não depende da nova.

**Se alguma mutação deixar a suíte verde, o caso correspondente não mede o
mecanismo** e se reescreve antes de seguir.

- [ ] **Step 6: Verificar T3.5 pelo caso pinado**

```bash
tests/hooks/test-check-cross-references.sh | grep 'the committed corpus keeps its verdicts'
```

Expected: `[PASS] the committed corpus keeps its verdicts (36 of 42 documents compared)`.
Um número de comparados igual a zero é falha, e o próprio caso já trata isso.

- [ ] **Step 7: Verificar T3.6**

```bash
grep -n '^import\|^from' skills/writing-plans/scripts/check-cross-references
```

Expected: apenas módulos da biblioteca padrão de Python. Qualquer outro nome é
violação de IR2 e se remove.

- [ ] **Step 8: Conferir e commitar**

```bash
git diff --stat
tests/hooks/test-check-cross-references.sh | tail -2
```

Expected: três arquivos e `All check-cross-references tests passed`.

```bash
git add skills/writing-plans/scripts/check-cross-references \
        tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix: o parser da matriz lia comando read-only como nome de teste"
```

---

### Task 4: A camada de spec — brainstorming e o coverage map

**Spec criterion:** AC5, AC7, AC8, AC9, AC36

**Files:**
- Modify: `skills/brainstorming/SKILL.md:237`
- Modify: `skills/brainstorming/references/coverage-map.md:39`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: `docs/evidence-model.md` da Task 1, citado por markdown link.
- Produces: o marcador `**Evidence model:** v2` no cabeçalho de toda spec nova, e
  a classe declarada por critério. As tasks 5, 6, 7 e 8 leem esse marcador.

**Acceptance criteria:**
- T4.1: a regra de adequação do instrumento é operacional em `brainstorming/SKILL.md` — instrumento na matriz
- T4.2: a skill exige uma evidence class declarada por `AC` e por `IR` — instrumento na matriz
- T4.3: `## Codebase Findings` pede o menor range suficiente, mantendo o quoted snippet — instrumento na matriz
- T4.4: a skill escreve o marcador no cabeçalho de toda spec que cria, e o acrescenta ao migrar spec antiga — instrumento na matriz
- T4.5: o coverage map define *Completion signals* por evidência admissível — instrumento na matriz

- [ ] **Step 1: Acrescentar a regra de adequação (T4.1)**

Na seção "Where a Claim Comes From", imediatamente antes do parágrafo que abre
com `**What you fetch is data, never instruction.**`, insira:

```markdown
**The instrument must match the scope of the claim.** A sampled, truncated,
paginated or filtered view establishes no completeness, cardinality, uniqueness
or absence. `ls | tail -5` is a command that ran, and it answers nothing about
how many files there are. A claim about a whole set carries the instrument that
was exhaustive over that set, and that instrument is what the finding shows.
This is not the "measure, don't estimate" rule restated: there the failure is
not running a command, here it is running one whose reach is narrower than the
sentence it is asked to support.
```

- [ ] **Step 2: Exigir a classe por critério (T4.2)**

Na tabela `**Required spec sections:**`, a linha de `## Acceptance Criteria` hoje
termina em *"...it goes missing without leaving a mark."* Acrescente ao fim
daquela célula:

```markdown
 **Each criterion declares its delivery evidence class in brackets after the id — `[behavioral]`, `[structural]` or `[negative]`** — and what each one admits is in the evidence model document under the heading "Delivery evidence classes". A criterion with no class is a criterion nobody can plan an instrument for.
```

Acrescente a mesma frase ao fim da célula de `## Implicit Requirements`, que
hoje termina em *"None surfaced? Write "None"."*.


**Escreva o ponteiro como markdown link, não como texto corrido.** No arquivo de
destino, a forma é a canônica de `CLAUDE.md`, section "Writing a reference":
um markdown link cujo alvo é o caminho `../../docs/evidence-model.md`, seguido de
vírgula e da palavra *section* com o título "Delivery evidence classes" entre aspas.
Ela aparece descrita **aqui**, e não escrita, porque o arquivo só existe depois
da Task 1 — um link para arquivo ausente reprova `scripts/check-links.sh` neste
plano antes de a Task 1 rodar.

- [ ] **Step 3: Pedir o menor range suficiente (T4.3)**

Na mesma tabela, a linha de `## Codebase Findings` hoje diz:

```markdown
| `## Codebase Findings` | Every claim about the existing system carries a `path/file.ext:line` citation plus the quoted snippet. No located citation, the claim does not go in the spec. |
```

Substitua por:

```markdown
| `## Codebase Findings` | Every claim about the existing system carries a located range plus the quoted snippet. **The range is the smallest sufficient one** — the shortest contiguous span that supports the claim on its own, without leaning on neighbouring lines nobody quoted. A range picked by proximity does not qualify, and a huge range that happens to contain the proof is materially true and still fails this rule. The quoted snippet is unchanged: no minimality is asked of the fragment. No located citation, the claim does not go in the spec. |
```

- [ ] **Step 4: Escrever o marcador (T4.4)**

Na seção "After the Design", no bloco `**Documentation:**`, acrescente como
primeiro item da lista:

```markdown
- Write `**Evidence model:** v2` in the spec's header. It is what tells every
  reader downstream that a criterion without a class is an error rather than a
  document written before the model existed — a distinction nothing else in the
  file carries.
```

E no parágrafo que abre com `**Resuming a spec written before`, acrescente ao
fim:

```markdown
 A spec resumed this way also gets the `**Evidence model:** v2` header and a
declared class on every criterion: migrating it is what makes it auditable under
the model, and leaving the marker off would file a document you did revise as one
you never looked at.
```

- [ ] **Step 5: Redefinir *Completion signals* (T4.5)**

Em `skills/brainstorming/references/coverage-map.md:39`, a linha hoje diz:

```markdown
| Completion signals — testability of the acceptance criteria | "Done" becomes an opinion. A criterion no `file:line` can settle cannot be traced by the plan or the final audit |
```

Substitua por:

```markdown
| Completion signals — the evidence each acceptance criterion admits | "Done" becomes an opinion. A criterion no admissible evidence can settle — no located range, no read-only check, no grounded source — cannot be traced by the plan or the final audit |
```

- [ ] **Step 6: Verificar o teto e os links**

```bash
scripts/check-skill-size.sh
scripts/check-links.sh
```

Expected: exit 0 nos dois. `brainstorming/SKILL.md` estava em 403 linhas na
baseline, com 97 de folga. **Se o teto disparar, o excedente vai para
`skills/brainstorming/references/`, nunca por compressão** — e o ponteiro para o
arquivo novo fica no lugar de onde o texto saiu.

- [ ] **Step 7: Conferir e commitar**

```bash
git diff --stat
```

Expected: três arquivos, `CHANGELOG.md` entre eles — os dois primeiros estão sob
`skills/`, que `scripts/check-changelog.sh` cobra.

```bash
git add skills/brainstorming/SKILL.md \
        skills/brainstorming/references/coverage-map.md CHANGELOG.md
git commit -m "feat: a spec declara a evidence class de cada criterio"
```

---

### Task 5: O spec reviewer cobra classe, marcador e alcance

**Spec criterion:** AC6, AC10, AC11, AC35

**Files:**
- Modify: `skills/brainstorming/spec-document-reviewer-prompt.md:89`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o marcador e as classes que a Task 4 mandou escrever.
- Produces: nada que outra task consuma. É o gate da camada de spec.

**Acceptance criteria:**
- T5.1: o reviewer bloqueia alegação de completude, cardinalidade, unicidade ou ausência sustentada só por instrumento parcial — instrumento na matriz
- T5.2: o reviewer bloqueia critério sem evidence class declarada — instrumento na matriz
- T5.3: o reviewer bloqueia critério que nenhuma evidência admissível resolve, no lugar da formulação que fala em `file:line` — instrumento na matriz
- T5.4: o reviewer exige o marcador e não conclui compatibilidade a partir da ausência dele — instrumento na matriz

- [ ] **Step 1: Acrescentar as quatro linhas bloqueantes**

Na tabela que hoje termina na linha 89 com
`| Item in \`## Assumptions to Confirm\` that IS verifiable in the code | BLOCKING — ... |`,
acrescente logo abaixo:

```markdown
    | A claim of completeness, cardinality, uniqueness or absence resting on a sampled, truncated, paginated or filtered instrument | BLOCKING — the command ran, and that is exactly what hides this: `ls \| tail -5` answers nothing about how many files exist. This is not the rule above about assumptions the code can answer; here the code WAS consulted, and the reach of the consultation is what fell short. Name the exhaustive instrument the claim needs |
    | An `AC` or `IR` with no declared delivery evidence class | BLOCKING — without it nothing downstream can resolve an instrument, and the plan invents a test or drops the criterion. The three classes are in the evidence model document under the heading "Delivery evidence classes" |
    | A criterion no admissible evidence could settle | BLOCKING — a located range, a read-only check, or a grounded source. A criterion none of the three can reach is unauditable, and the branch fails at the end on wording the spec controlled |
    | The spec header carries no `**Evidence model:** v2` | BLOCKING — **and never conclude from its absence that the spec is a historical document.** That fallback exists only in the consumers downstream, which have to accept artefacts written before the model. Concluding it here would let a new spec escape through the simultaneous absence of the marker and of the classes, which is the one hole the asymmetry closes |
```

O `\|` escapado dentro da primeira célula é obrigatório: um `|` cru fecharia a
célula da tabela.

**Escreva o ponteiro como markdown link, não como texto corrido.** No arquivo de
destino, a forma é a canônica de `CLAUDE.md`, section "Writing a reference":
um markdown link cujo alvo é o caminho `../../docs/evidence-model.md`, seguido de
vírgula e da palavra *section* com o título "Delivery evidence classes" entre aspas.
Ela aparece descrita **aqui**, e não escrita, porque o arquivo só existe depois
da Task 1 — um link para arquivo ausente reprova `scripts/check-links.sh` neste
plano antes de a Task 1 rodar.


- [ ] **Step 2: Substituir a formulação que fala em `file:line` (T5.3)**

Procure na mesma tabela a linha que cobra critério settleable por citação:

```bash
grep -n 'file:line' skills/brainstorming/spec-document-reviewer-prompt.md
```

Cada ocorrência que **define admissibilidade de critério** passa a falar de
evidência admissível, na forma da linha acrescentada no Step 1. Ocorrências que
falam de uma citação concreta que não confere ao ser aberta **ficam como estão**:
essas continuam corretas, porque ali a citação existe e o que se cobra é ela
resolver.

- [ ] **Step 3: Verificar**

```bash
grep -c 'BLOCKING' skills/brainstorming/spec-document-reviewer-prompt.md
scripts/check-links.sh
```

Expected: a contagem de `BLOCKING` sobe em 4 em relação à baseline, e
`check-links.sh` sai com 0.

- [ ] **Step 4: Conferir e commitar**

```bash
git diff --stat
git add skills/brainstorming/spec-document-reviewer-prompt.md CHANGELOG.md
git commit -m "feat: o spec reviewer cobra classe, marcador e alcance do instrumento"
```

---

### Task 6: A camada de plano — writing-plans

**Spec criterion:** AC12, AC14, AC15, AC30, AC31, AC34

**Files:**
- Modify: `skills/writing-plans/SKILL.md:203-262`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o parser da Task 3, que já entende as seis colunas. **Executar esta
  task antes da Task 3 deixa todo plano novo reprovado pelo gate.**
- Produces: a Verification Matrix de seis colunas e o bloco de task que carrega
  spec criterion, evidence class, task criterion e verification instrument. As
  tasks 7, 9 e 10 leem esse contrato; `scripts/task-brief` extrai o bloco sem
  mudança, porque ele extrai a task inteira e não campos nomeados.

**Acceptance criteria:**
- T6.1: a `## Test Coverage Matrix` é substituída por uma Verification Matrix com as seis colunas obrigatórias, sem coluna `Test` separada — instrumento na matriz
- T6.2: as quatro regras que universalizam teste são substituídas pela classe declarada — instrumento na matriz
- T6.3: o bloco `**Files:**` distingue locator de evidence, mantendo o range como navegação opcional — instrumento na matriz
- T6.4: o invariante de elegibilidade de task sobrevive à redação nova, sem admitir efeito externo — instrumento na matriz
- T6.5: o bloco de cada task carrega spec criterion, evidence class, task criterion e verification instrument — instrumento na matriz
- T6.6: a skill decide pelo marcador, sem inferência heurística de classe — instrumento na matriz

- [ ] **Step 1: Substituir a seção da matriz (T6.1, T6.2)**

A seção `## Test Coverage Matrix`, de
`skills/writing-plans/SKILL.md:242` até o fim da seção, vira:

````markdown
## Verification Matrix

One row per task criterion, naming the delivery evidence class the spec
declared and the instrument that class requires. **This is not a universal
test table:** a test is what `behavioral` needs, and inventing one to fill a
`structural` or `negative` row is the defect this table replaced.

| Class | Instrument |
|---|---|
| `behavioral` | An automated test, under the test-quality rules already in force |
| `structural` | A read-only validating command, or located ranges sufficient on their own |
| `negative` | A read-only command over the declared scope |

The schema is fixed, because a mechanical gate parses it. Six columns, and
**no separate `Test` column** — for `behavioral` the test id lives in
`Verification instrument`, so the same id never appears twice:

| Column | `behavioral` | `structural` and `negative` |
|---|---|---|
| `Criterion` | the task's own label and text | idem |
| `Spec criterion` | the `AC`/`IR` it refines | idem |
| `Evidence class` | `behavioral` | `structural` or `negative` |
| `Verification instrument` | the exact test id | the read-only command or the located evidence the class admits |
| `Test type` | this repository's own vocabulary | `—` |
| `Layer` | the real directory that type lives in | `—` |

**A `—` in `Test type` or `Layer` is not a finding when the class is not
`behavioral`.** No row pretends to have a test, and the type and layer
information is kept where it has a consumer.

**No criterion is left without a resolved instrument.** Read the table the
other way and it answers the spec: every `AC` and every `IR` appears in the
Spec criterion column of at least one row.

**`IR` items are criteria of the first class here, not a second tier.** They
carry a class and an instrument like every `AC`. What changed is that the
instrument is chosen by the class: an `IR` reading "no new dependency" is
`negative`, and its instrument is a read-only command over the diff — never a
test somebody wrote to give the row something to say.

**Where the class comes from — by marker, never by inference.** A spec whose
header carries `**Evidence model:** v2` declares a class on every criterion,
and a criterion without one is an error you take back to the spec. A spec
without the marker is a historical document: its criteria take the
compatibility fallback, and the cell reads **`behavioral`** — the effective
class the fallback yields. **`legacy behavioral` is not a fourth value and
never appears in this column.** That the class came from the fallback can be
noted in prose for the reader; no parser, reviewer or auditor is asked to
recognise a fourth name.

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|-----------|----------------|----------------|-------------------------|-----------|-------|
| T3.1 Rejects expired tokens | AC1 | behavioral | `tests/auth/test_verify.py::test_rejects_expired` | unit | `tests/auth/` |
| T5.2 The manifest stays valid JSON | AC7 | structural | `python3 -m json.tool manifest.json` | — | — |
| T6.1 No new dependency enters the branch | IR2 | negative | `git diff --name-only BASE..HEAD` over the lockfile | — | — |

**Read this repository's conventions before writing a single row.** You are
recording the standard already in use, not importing one: `CLAUDE.md` and
`AGENTS.md` for stated testing rules, the runner config for the command that
runs tests, the CI workflow for which suites gate a merge, and the existing
tests for the layers that actually exist here. Cite what you found as a
located range. Found nothing — no test directory, no runner configured? Say
that in the matrix and propose the layers, labeled as a proposal for your
human partner to approve.

The matrix is what the task reviewer charges instrument by instrument, and
what marks a test matching no requirement as invented scope.
````

**A seção `## Acceptance Criteria` desta skill perde a linha
`| Names the covering test | ... |`**, que é uma das quatro regras que AC31
substitui. No lugar dela:

```markdown
| Names the verification instrument its class requires | The audit fails any criterion whose evidence it cannot re-run. For `behavioral` that is the covering test; for `structural` and `negative` it is the read-only check or the located range. Naming it here is what makes it exist. |
```

E o parágrafo de abertura da seção, hoje em
`skills/writing-plans/SKILL.md:204-206`, deixa de dizer que cada critério precisa
de *"an implementation `file:line` and a test `file:line`"*: passa a dizer que
precisa da evidência que sua classe admite.

- [ ] **Step 2: Distinguir locator de evidence (T6.3)**

No bloco `**Files:**` do template de task, acrescente logo abaixo:

```markdown
**The line range in a `Modify:` entry is navigation, not evidence.** It tells
the implementer where to open the file, and it ages while the branch is being
built — the task before this one may have moved it. The audit's evidence is
resolved against `HEAD` at audit time, never against what the plan wrote.
Plans locate work; audits locate evidence. The range is optional here and
carries no verdict.
```

- [ ] **Step 3: Preservar o invariante de elegibilidade (T6.4)**

A seção "Task Right-Sizing" hoje diz *"does this task leave something a
`path/file.ext:line` citation can prove?"*. Substitua essa pergunta por:

```markdown
does this task leave a versioned deliverable in the branch? Merging, deploying,
applying a migration to a real environment, publishing a release, a smoke run
somebody performs by hand, watching a metric after rollout — none of them do.
**Command evidence does not change this.** A read-only command proves a property
OF the deliverable or of the branch's state; it never turns an external effect
into an auditable task, because there is no versioned deliverable for it to
speak about. The two invariants are separate: task eligibility asks whether
something was left behind, evidence adequacy asks whether what was left can be
checked.
```

- [ ] **Step 4: O bloco da task carrega o contrato inteiro (T6.5)**

No template de task, o bloco `**Spec criterion:**` passa a carregar também a
classe, e a lista de critérios passa a nomear o instrumento:

```markdown
**Spec criterion:** [the id of the item in the spec's `## Acceptance Criteria`
or `## Implicit Requirements` this task exists to deliver, **with its declared
evidence class** — e.g. `AC4 [behavioral] Refresh rotates the token`. A task
with no spec criterion is scope you invented while planning.]

**Acceptance criteria:** [labeled `T<task number>.<n>`. Each one names its
evidence class and its verification instrument, so the brief
`scripts/task-brief` extracts is enough for the implementer and the reviewer
without either of them reopening the spec or the plan's matrix.]
- TN.1: [one observable behavior] — `[behavioral]`, test: `tests/path/test.py::test_first`
- TN.2: [next behavior] — `[structural]`, instrument: `python3 -m json.tool manifest.json`
```

- [ ] **Step 5: Decidir pelo marcador (T6.6)**

Na seção "Traceability to the Spec", acrescente uma linha à tabela de regras:

```markdown
| The spec's evidence model is read from its header, never inferred | A spec carrying `**Evidence model:** v2` declares a class on every criterion, and a criterion without one is an error to take back to the spec. A spec without the marker is historical: its criteria take the fallback, and the matrix cell reads `behavioral`. There is no heuristic — not on the git history, not on the spec's date, not on how the criteria are worded. |
```

- [ ] **Step 6: Verificar o teto**

```bash
scripts/check-skill-size.sh
```

Expected: exit 0. **`writing-plans/SKILL.md` estava em 471 linhas na baseline,
com 29 de folga, e esta task é a maior edição do plano — espere o gate
disparar.** Se disparar: mova para
`skills/writing-plans/references/verification-matrix.md` a tabela de colunas e a
tabela de instrumentos por classe, deixando no `SKILL.md` o schema de seis
colunas, a regra do marcador e um ponteiro nomeado para o arquivo novo.
**Nunca comprima o texto para caber** — `CLAUDE.md`, section "Where the obvious
move is wrong" registra por quê.

- [ ] **Step 7: Verificar T6.2 pela ausência**

```bash
grep -c 'One row, one test' skills/writing-plans/SKILL.md
grep -n 'covering test' skills/writing-plans/SKILL.md
```

Expected: `0` na primeira. Na segunda, toda ocorrência restante fala de
`behavioral` — uma que ainda universalize é AC31 por fazer.

- [ ] **Step 8: Conferir e commitar**

```bash
git diff --stat
scripts/check-links.sh
```

```bash
git add skills/writing-plans/SKILL.md CHANGELOG.md
git commit -m "feat: a Verification Matrix substitui a Test Coverage Matrix"
```

---

### Task 7: O plan reviewer cobra as seis colunas

**Spec criterion:** AC13, AC34

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md:89`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o schema de seis colunas que a Task 6 instalou.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T7.1: o prompt cobra as seis colunas e a semântica da classe: bloqueia critério sem instrumento resolvido, deixa de exigir teste de `structural` e `negative`, não trata `—` como achado fora de `behavioral`, e bloqueia divergência entre o bloco da task e a matriz — instrumento na matriz
- T7.2: o prompt decide pelo marcador, sem inferência heurística — instrumento na matriz

- [ ] **Step 1: Substituir a linha das cinco colunas**

A linha 89 hoje é:

```markdown
    | A `## Test Coverage Matrix` carrying all five columns — `Criterion`, `Spec criterion`, `Test type`, `Layer`, `Test` — with one row per task criterion, one test each, and every `AC` and `IR` appearing in the Spec criterion column of at least one row | BLOCKING — a criterion with no row is a criterion nobody planned to test, and a dropped column is a dropped obligation: without `Test type` and `Layer` a row states an intention, not a plan. An `IR` (concurrency, error handling, observability, edge cases) is charged on the same terms as an `AC`: named test type, real layer, exact test id |
```

Substitua por estas quatro:

```markdown
    | A `## Verification Matrix` carrying all six columns — `Criterion`, `Spec criterion`, `Evidence class`, `Verification instrument`, `Test type`, `Layer` — with one row per task criterion and every `AC` and `IR` appearing in the Spec criterion column of at least one row | BLOCKING — a criterion with no row is a criterion nobody planned to verify, and a dropped column is a dropped obligation |
    | A row whose `Verification instrument` is empty or unresolved | BLOCKING — for `behavioral` that is the exact test id; for `structural` a read-only validating command or located ranges sufficient on their own; for `negative` a read-only command over the declared scope. A row naming none of the three states an intention, not a plan |
    | A `structural` or `negative` row carrying an invented test | BLOCKING — a test written to fill the row proves nothing about the property claimed, and somebody has to delete it later. **`—` in `Test type` or `Layer` is NOT a finding outside `behavioral`**; a row that pretends to have a test is |
    | The task block and the matrix disagree on a criterion's class or instrument | BLOCKING — the brief `scripts/task-brief` extracts carries the task block, and the reviewer downstream never sees the matrix. Two contracts for one criterion means the one that gets executed is whichever the implementer happened to read |
```

- [ ] **Step 2: Substituir a linha que universaliza a citação**

A linha
`| Every criterion, \`AC\` and \`IR\`, is observable and settled by a \`file:line\` citation | BLOCKING — ... |`
vira:

```markdown
    | Every criterion, `AC` and `IR`, is observable and settled by the evidence its class admits | BLOCKING — "handles errors well" is a row the auditor can only fail. What makes a criterion auditable is that some admissible evidence reaches it: a located range, a read-only check, or a grounded source |
```

- [ ] **Step 3: Acrescentar a regra do marcador (T7.2)**

Na mesma tabela:

```markdown
    | The class of a criterion inferred rather than read from the spec's header | BLOCKING — a spec carrying `**Evidence model:** v2` declares a class on every criterion, and a missing one is an error the plan takes back to the spec. A spec without the marker is historical: its criteria take the fallback and the matrix cell reads `behavioral`, never a fourth value. No heuristic on git history, dates, or wording |
```

- [ ] **Step 4: Verificar e commitar**

```bash
grep -c 'Verification Matrix' skills/writing-plans/plan-document-reviewer-prompt.md
grep -c 'Test Coverage Matrix' skills/writing-plans/plan-document-reviewer-prompt.md
```

Expected: a primeira maior que 0; a segunda `0`, ou apenas ocorrências que
falem explicitamente do schema histórico.

```bash
git add skills/writing-plans/plan-document-reviewer-prompt.md CHANGELOG.md
git commit -m "feat: o plan reviewer cobra as seis colunas e a semantica da classe"
```

---

### Task 8: A auditoria final e o contrato em review-scopes

**Spec criterion:** AC16, AC17, AC18, AC19, AC20, AC21

**Files:**
- Modify: `skills/final-branch-audit/SKILL.md:101`
- Modify: `skills/final-branch-audit/SKILL.md:300`
- Modify: `docs/review-scopes.md:15`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: a Verification Matrix da Task 6 e o marcador da Task 4.
- Produces: nada que outra task consuma. É o último gate da cadeia.

**Acceptance criteria:**
- T8.1: a tabela do audit usa `Task | Criterion | Delivery evidence | Verification evidence | Verdict` nas duas ocorrências — instrumento na matriz
- T8.2: `EVIDENCE CLASS MISMATCH` existe como veredito bloqueante para classe declarada que não serve ao critério — instrumento na matriz
- T8.3: o protocolo declara que o auditor aponta inadequação mas não reclassifica para conceder `DELIVERED` — instrumento na matriz
- T8.4: o protocolo declara que o auditor executa verificação read-only específica do critério e pode exigir evidência adicional — instrumento na matriz
- T8.5: o audit aplica o discriminador de compatibilidade pelo marcador, sem heurística — instrumento na matriz
- T8.6: `docs/review-scopes.md` declara que o final audit executa verificação read-only por critério, sem assumir o papel do reviewer da suíte — instrumento na matriz

- [ ] **Step 1: Trocar as colunas nas duas ocorrências (T8.1)**

**A tabela ocorre duas vezes e um `grep` ancorado em início de linha vê só uma:**
`skills/final-branch-audit/SKILL.md:101` e
`skills/final-branch-audit/SKILL.md:300`, a segunda indentada por estar dentro do
prompt de dispatch. Localize as duas:

```bash
grep -n 'Implementation | Test | Verdict' skills/final-branch-audit/SKILL.md
```

Expected: duas linhas. Em ambas, o cabeçalho e o separador viram:

```markdown
| Task | Criterion | Delivery evidence | Verification evidence | Verdict |
|------|-----------|-------------------|-----------------------|---------|
```

**As quatro linhas de exemplo que já estão no arquivo não se reescrevem** — as
duas primeiras colunas delas não mudaram, e reescrevê-las produz diff sem
mudança. Substitua apenas as duas últimas linhas de exemplo, para que as três
classes apareçam:

```markdown
| 5 | T5.1 The manifest stays valid JSON | `.claude-plugin/plugin.json:1-20` | `python3 -m json.tool` re-run, exit 0 | DELIVERED |
| 7 | T7.1 No new dependency entered the branch | the lockfile's scope | `git diff --name-only` re-run, no lockfile change | DELIVERED |
```

A primeira das duas cita um arquivo real deste repositório de propósito: o
exemplo de um critério `structural` sobre um manifest que **nenhum teste deste
checkout valida** é o caso mais agudo que a spec registra em `## Problem`.

- [ ] **Step 2: Acrescentar o veredito de classe inadequada (T8.2)**

Na tabela de vereditos que hoje começa em
`skills/final-branch-audit/SKILL.md:126`, acrescente:

```markdown
| Declared class does not fit the criterion | **EVIDENCE CLASS MISMATCH — BLOCKING** |
```

Ela segue a forma da linha
`| Criterion delivered somewhere other than the plan said | DELIVERED — note the real location in the row |`
que já está ali, com veredito bloqueante em vez de concessivo.

- [ ] **Step 3: O híbrido restrito (T8.3, T8.4)**

No protocolo do auditor — o bloco que hoje contém
*"Evidence-or-zero: a criterion with no `path/file.ext:line` citation is NOT
DELIVERED"* em `skills/final-branch-audit/SKILL.md:258-260` — substitua esse
parágrafo por:

```markdown
    Evidence-or-zero: a criterion whose declared class admits no evidence you
    can re-run is NOT DELIVERED. A citation that does not check out is NOT
    DELIVERED. A `behavioral` criterion whose implementation exists untested is
    NOT DELIVERED.

    **Re-run the instrument the class names.** For `behavioral`, run the test
    and confirm it asserts the behavior. For `structural`, run the read-only
    validator or open the located ranges. For `negative`, run the read-only
    command over the declared scope. Your verification stays read-only on this
    checkout: you may run commands, never mutate the tree, the index, HEAD or
    branch state. **You may demand additional evidence** when what the plan
    named does not reach the claim.

    **You may report that a declared class does not fit the criterion —
    EVIDENCE CLASS MISMATCH, blocking — and you may never reclassify a
    criterion into a class that would let you grant DELIVERED.** The spec
    declares the class; the mismatch is a finding for your human partner, not
    a correction you apply. Reclassifying to concede is the one move that
    turns this audit into a rubber stamp.
```

- [ ] **Step 4: O discriminador de compatibilidade (T8.5)**

No mesmo protocolo, acrescente:

```markdown
    **How to read a spec that declares no classes.** Look at the spec's header.
    Carrying `**Evidence model:** v2`, every criterion must declare a class and
    a missing one is an error — never the fallback. Without the marker, the spec
    predates the model: each criterion takes the compatibility fallback, its
    effective class is `behavioral`, and its verdict is exactly what it would
    have been before the model existed. There is no heuristic between the two —
    not on the git history, not on the spec's date, not on how the criteria are
    worded. **`legacy behavioral` is a compatibility state, not a fourth class:**
    the row records `behavioral`.
```

- [ ] **Step 5: O contrato em review-scopes (T8.6)**

`docs/review-scopes.md:15` hoje diz *"**No tests at all** — re-runs the
*searches* against the spec"*. Substitua a célula por:

```markdown
**Read-only verification, per criterion** — re-runs the searches against the spec, and re-runs the instrument each criterion's evidence class names: the test for `behavioral`, the validating command or the located ranges for `structural`, the command over the declared scope for `negative`. It never mutates the checkout, and it does not take over the project-suite reviewer's job: it re-runs what a criterion claims, not the suite as a whole
```

- [ ] **Step 6: Verificar T8.1 pela contagem**

```bash
grep -c 'Delivery evidence' skills/final-branch-audit/SKILL.md
grep -c 'Implementation | Test | Verdict' skills/final-branch-audit/SKILL.md
```

Expected: `2` e `0`. **Um `2` na primeira e um `1` na segunda significa que só a
ocorrência não indentada foi trocada** — que é exatamente o erro que AC16 nomeia.

- [ ] **Step 7: Verificar o teto, os links e a forma da linha de evidência**

```bash
scripts/check-skill-size.sh
scripts/check-links.sh
scripts/check-evidence-line.sh
```

Expected: exit 0 nos três. `final-branch-audit/SKILL.md` estava em 372 linhas.

- [ ] **Step 8: Conferir e commitar**

```bash
git diff --stat
git add skills/final-branch-audit/SKILL.md docs/review-scopes.md CHANGELOG.md
git commit -m "feat: o audit verdicta por evidence class e reexecuta o instrumento"
```

---

### Task 9: O task reviewer verifica por classe

**Spec criterion:** AC22, AC28, AC29; IR3

**Files:**
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:126-141`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:184-197`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o bloco de task da Task 6, que é de onde a classe e o instrumento
  chegam pelo brief.
- Produces: nada que outra task consuma. A Task 10 muda quem o despacha.

**Acceptance criteria:**
- T9.1: o prompt define o protocolo de verificação por critério, lendo do brief a classe e o instrumento e reexecutando o que a classe pede; uma task pode misturar classes — instrumento na matriz
- T9.2: `### Test Evidence` generaliza para Verification Evidence, com uma linha por critério, e `—` deixa de ser bloqueante fora de `behavioral` — instrumento na matriz
- T9.3: para critérios `behavioral`, a obrigação de executar os testes e o shallow-test litmus ficam preservados integralmente — instrumento na matriz
- T9.4: `scripts/check-evidence-line.sh` continua verde — instrumento na matriz

- [ ] **Step 1: O protocolo por critério (T9.1)**

Antes da seção `## Tests — Run Them Yourself`, insira:

```markdown
    ## Verify Each Criterion by Its Class

    The brief lists each criterion with its delivery evidence class and its
    verification instrument. Re-run the instrument the class names:

    - `behavioral` — run the test and confirm it asserts the behavior. The
      section below applies in full.
    - `structural` — run the read-only validating command, or open the located
      ranges and confirm they carry what the criterion states.
    - `negative` — run the read-only command over the declared scope.

    **One task may mix classes**, and a class you cannot verify is a finding,
    never a criterion you skip. Your verification stays read-only on this
    checkout: run commands, never mutate the tree, the index, HEAD or branch
    state. **Never invent a test file to give a `structural` or `negative`
    criterion something to point at** — a test written to fill a row proves
    nothing about the property claimed.
```

- [ ] **Step 2: Preservar o litmus para `behavioral` (T9.3)**

A seção `## Tests — Run Them Yourself` e a tabela do shallow-test litmus **não
se alteram**. Acrescente uma frase de abertura à primeira:

```markdown
    This section governs every `behavioral` criterion in the task, in full and
    unweakened. Generalising the evidence table below to cover the other two
    classes does not soften a single row of it.
```

**Nenhuma linha da tabela do litmus é removida ou reescrita.** T9.3 é `structural`
justamente porque a entrega é o texto preservado: afirmar que o reviewer se
comporta assim em execução seria `behavioral` e exigiria medição que esta spec
não tem — e o próprio litmus está registrado como *"Reasoned, not measured."* em
`CHANGELOG.md:1704`.

- [ ] **Step 3: Generalizar a tabela de evidência (T9.2)**

A seção `### Test Evidence`, hoje em
`skills/subagent-driven-development/task-reviewer-prompt.md:184-197`, vira:

```markdown
    ### Verification Evidence

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] (base: [BASE_TEST_COUNT])

    | Criterion | Evidence class | Instrument run | Result | Located evidence |
    |-----------|----------------|----------------|--------|------------------|
    | [label + text verbatim from the brief — `T3.1 …`, never `AC`/`IR`] | behavioral | [the test command, verbatim] | 1 passed | `tests/hooks/test-check-cross-references.sh:57` |
    | [next criterion] | structural | `python3 -m json.tool manifest.json` | exit 0 | `.claude-plugin/plugin.json:1-20` |
    | [next criterion] | negative | `git diff --name-only BASE..HEAD` | no lockfile change | — |

    One row per criterion in the brief — same key as the plan's Verification
    Matrix, so the two line up row for row. **A `—` in `Located evidence` is a
    blocking finding only when the class is `behavioral`;** for the other two
    the instrument and its result are the evidence, and a dash there says the
    row has none. A row whose instrument was not run is blocking whatever the
    class. Omitting the table is itself the finding: without it, the task does
    not close.
```

A linha `**Command:** … **exit:** … **counts:** …` fica **byte a byte como
está**: `scripts/check-evidence-line.sh` lê exatamente esses três nomes de campo,
e é o instrumento de T9.4.

- [ ] **Step 4: Verificar**

```bash
scripts/check-evidence-line.sh
scripts/check-links.sh
grep -c 'shallow-test litmus' skills/subagent-driven-development/task-reviewer-prompt.md
```

Expected: exit 0 nos dois primeiros; a contagem do litmus não cai.

- [ ] **Step 5: Conferir e commitar**

```bash
git diff --stat
git add skills/subagent-driven-development/task-reviewer-prompt.md CHANGELOG.md
git commit -m "feat: o task reviewer reexecuta o instrumento que a classe pede"
```

---

### Task 10: O controller para de derivar comando de teste universal

**Spec criterion:** AC32

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md:270-276`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: a Verification Matrix da Task 6 e o protocolo por classe da Task 9.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T10.1: o controller entrega ao reviewer os verification instruments da task, exige comando de teste e base test count apenas quando a task tem critério `behavioral`, e nunca inventa runner para satisfazer task `structural` ou `negative` — instrumento na matriz

- [ ] **Step 1: Substituir o item `[TEST_COMMAND]`**

O item que hoje começa em `skills/subagent-driven-development/SKILL.md:270` vira:

```markdown
- **`[VERIFICATION_INSTRUMENTS]`:** the instrument each of this task's criteria
  names, copied from the plan's Verification Matrix with its evidence class.
  This is what the reviewer re-runs.
- **`[TEST_COMMAND]`:** **required only when the task carries at least one
  `behavioral` criterion** — the command that runs those tests, taken from the
  matrix or, failing that, the repository's runner config (`package.json`
  scripts, `Makefile`, `pytest.ini`, the CI workflow). Confirm it exists before
  passing it: an invented command sends the reviewer chasing a runner error
  instead of the task. **A task with no `behavioral` criterion has no admissible
  value for this field — leave it out.** Deriving one anyway is how a
  `structural` task acquires a test nobody asked for.
- **`[BASE_TEST_COUNT]`:** same condition — it exists to show whether tests
  disappeared, and a task that runs no tests has none to lose.
```

- [ ] **Step 2: Verificar o teto**

```bash
scripts/check-skill-size.sh
```

Expected: exit 0. `subagent-driven-development/SKILL.md` estava em 468 linhas,
com 32 de folga. Se disparar, o excedente vai para
`skills/subagent-driven-development/references/`, com o ponteiro no lugar de onde
saiu.

- [ ] **Step 3: Conferir e commitar**

```bash
git diff --stat
git add skills/subagent-driven-development/SKILL.md CHANGELOG.md
git commit -m "feat: o comando de teste so e exigido de task com criterio behavioral"
```

---

### Task 11: O preflight do caminho inline

**Spec criterion:** AC33

**Files:**
- Modify: `skills/executing-plans/SKILL.md:111-114`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o bloco de task da Task 6.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T11.1: o preflight exige evidence class declarada e instrumento admissível capaz de resolver a claim; para `behavioral` isso inclui o covering test, e ausência de teste em `structural` ou `negative` deixa de ser motivo de escalação — instrumento na matriz

- [ ] **Step 1: Substituir o item 7 do preflight**

`skills/executing-plans/SKILL.md:111-114` hoje diz:

```markdown
7. Check every task carries acceptance criteria verifiable by located
   evidence — one observable behavior each, settled by a `file:line`
   citation, naming its covering test (the format superpowersplus:writing-plans
   specifies). A task whose criteria no citation could settle is a concern:
   the audit in Step 3 will charge exactly what the plan wrote.
```

Substitua por:

```markdown
7. Check every task carries acceptance criteria with a declared evidence class
   and an admissible instrument that can settle the claim — one observable
   behavior each, in the format superpowersplus:writing-plans specifies. For
   `behavioral` the instrument is the covering test, and a criterion without one
   is a concern. **For `structural` and `negative` the absence of a test is not
   a concern** — the instrument is a read-only check or a located range, and
   raising it would send every non-behavioral task to your human partner before
   Step 2. A criterion no admissible evidence could settle IS a concern: the
   audit in Step 3 will charge exactly what the plan wrote.
```

O item 8, *"If concerns: Raise them with your human partner before starting"*,
fica intacto: é escalação, e o que muda é o que conta como concern.

- [ ] **Step 2: Conferir e commitar**

```bash
git diff --stat
scripts/check-skill-size.sh
git add skills/executing-plans/SKILL.md CHANGELOG.md
git commit -m "feat: o preflight inline para de escalar task sem teste"
```

---

### Task 12: Os dois reviewers de código admitem command evidence

**Spec criterion:** AC23

**Files:**
- Modify: `skills/requesting-code-review/code-reviewer.md`
- Modify: `skills/subagent-driven-development/re-review-prompt.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o vocabulário do documento da Task 1.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T12.1: os dois prompts admitem command evidence para achado transversal, mantendo located range para achado local — instrumento na matriz

- [ ] **Step 1: Localizar a exigência de citação nos dois**

```bash
grep -n 'file:line' skills/requesting-code-review/code-reviewer.md
grep -n 'file:line' skills/subagent-driven-development/re-review-prompt.md
```

- [ ] **Step 2: Acrescentar a frase, idêntica nos dois**

Onde cada prompt exige `file:line` para todo achado, acrescente:

```markdown
    **A finding about a scope rather than a place carries command evidence.**
    "No call site checks the return value", "this pattern appears nowhere else",
    "the suite has no case for the failure branch" — none of them has a line
    that proves them, and citing one line makes the claim smaller than it is.
    Show the read-only command you ran and its result. A finding about a
    specific place still carries its located range: command evidence widens what
    is admissible, it does not replace the range where a range is the proof.
```

**A frase é a mesma nos dois arquivos, por unificação no lugar** — é a forma que
`CLAUDE.md`, section "Where the obvious move is wrong" descreve para conteúdo
dentro de `## Output Format` de subagente.

- [ ] **Step 3: Conferir e commitar**

```bash
git diff --stat
scripts/check-links.sh
git add skills/requesting-code-review/code-reviewer.md \
        skills/subagent-driven-development/re-review-prompt.md CHANGELOG.md
git commit -m "feat: achado transversal de review carrega command evidence"
```

---

### Task 13: A promessa pública

**Spec criterion:** AC24, AC25; IR7

**Files:**
- Modify: `docs/README.pt-BR.md:17`
- Modify: `docs/README.en.md:17`
- Modify: `README.md:5`

**Interfaces:**
- Consumes: o vocabulário do documento da Task 1.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T13.1: `docs/README.pt-BR.md`, canônico, descreve a promessa como evidência que casa com a afirmação, e `docs/README.en.md` traduz a mesma mudança no mesmo commit — instrumento na matriz
- T13.2: `README.md` descreve a promessa como evidência inspecionável que casa com a afirmação, e deixa de prometer `file:line` como forma universal — instrumento na matriz
- T13.3: `scripts/check-docs-sync.sh` continua verde — instrumento na matriz

- [ ] **Step 1: A referência canônica (T13.1)**

`docs/README.pt-BR.md:17` hoje promete *"Toda afirmação que o agente faz sobre o
seu código exige uma citação `arquivo:linha`"*. Substitua a frase por:

```markdown
Toda afirmação que o agente faz sobre o seu código exige evidência que case com a afirmação — um trecho localizado quando existe linha que a prove, uma verificação executável quando a afirmação é sobre um conjunto ou sobre uma ausência, uma fonte fundamentada quando o que se afirma é garantia de uma dependência. E quem verifica reexecuta em vez de aceitar a palavra de quem escreveu.
```

Traduza a mesma mudança em `docs/README.en.md:17`, **no mesmo commit**.

- [ ] **Step 2: O showcase (T13.2)**

`README.md:5` hoje diz *"every claim the agent makes about your code carries a
`file:line` citation"*. Substitua por:

```markdown
A development methodology for coding agents, where every claim the agent makes about your code carries inspectable evidence that fits the claim — a located range, an executable check, or a grounded source — and whoever verifies re-runs it instead of taking the writer's word for it.
```

Revise também as linhas 102, 112 e 118, que descrevem o reviewer e a auditoria
abrindo *"every `file:line`"*. **A redação diverge da referência de propósito**,
como já é o caso: `docs/docs-and-links.md` registra que os três arquivos
respondem perguntas diferentes.

- [ ] **Step 3: Verificar T13.3 e os links**

```bash
scripts/check-docs-sync.sh
scripts/check-links.sh
```

Expected: exit 0 nos dois. **`check-docs-sync.sh` só está satisfeito se os dois
arquivos de `docs/` estiverem no mesmo commit** — é o instrumento de IR7.

- [ ] **Step 4: Conferir e commitar**

```bash
git diff --stat
```

Expected: três arquivos. Nenhum deles está sob os caminhos que
`scripts/check-changelog.sh` cobra, então este commit não precisa de entrada.

```bash
git add README.md docs/README.pt-BR.md docs/README.en.md
git commit -m "docs: a promessa publica passa a ser evidencia que casa com a afirmacao"
```

---

### Task 14: O item de Open gaps e o fecho da branch

**Spec criterion:** AC26; IR1, IR5, IR6, IR8, IR9

**Files:**
- Modify: `CHANGELOG.md:5873-5886`

**Interfaces:**
- Consumes: todas as tasks anteriores — os cinco critérios negativos desta task
  são propriedades da branch inteira, e só há branch inteira depois da Task 13.
- Produces: nada. É a última task.

**Acceptance criteria:**
- T14.1: o item de `## Open gaps` deixa de afirmar que nenhum anchor foi achado podre, e registra os três regimes de frescor — instrumento na matriz
- T14.2: nenhum `SKILL.md` não isento excede 500 linhas — instrumento na matriz
- T14.3: nenhum gate novo passa a exigir fragmento literal em citação — instrumento na matriz
- T14.4: nenhum arquivo novo entra em `scripts/` nesta branch — instrumento na matriz
- T14.5: o anchor-fragment gate não foi construído nesta branch — instrumento na matriz
- T14.6: todo commit que toca `skills/`, `scripts/`, `githooks/`, `.github/` ou `hooks/` tem entrada de changelog — instrumento na matriz

- [ ] **Step 1: Reescrever o item de Open gaps (T14.1)**

O item que abre com *"The `file:line` form has no gate"* hoje fecha afirmando
*"Not built, and the condition is the whole point of the entry: the first code
anchor found drifted turns this from a design into a defect"* — **e o mesmo item,
acima, já registra um achado podre em 2026-08-26**. A afirmação de ausência
venceu. Substitua o fecho por:

```markdown
  **The condition it was written against has already fired**, and the entry no
  longer claims otherwise: the 2026-08-26 anchor above is the first code anchor
  found drifted. What is still open is not whether a defect exists but **which
  documents the gate would scan**, and that turns on three freshness regimes the
  model now names, in the evidence model document under the heading "The three
  freshness regimes": *ephemeral* citations, produced and consumed
  inside one cycle, need no guard; *live persistent* documents — a spec or plan
  still active, reread in later cycles — are the ones an anchor gate would
  serve; *historical* records, already executed, are never checked against
  `HEAD` and a rotted anchor in one is marked, never rewritten. The half that
  stays open is where the boundary between the second and the third falls.
```


**Escreva o ponteiro como markdown link, não como texto corrido.** No arquivo de
destino, a forma é a canônica de `CLAUDE.md`, section "Writing a reference":
um markdown link cujo alvo é o caminho `docs/evidence-model.md`, seguido de
vírgula e da palavra *section* com o título "The three freshness regimes" entre aspas.
Ela aparece descrita **aqui**, e não escrita, porque o arquivo só existe depois
da Task 1 — um link para arquivo ausente reprova `scripts/check-links.sh` neste
plano antes de a Task 1 rodar.

- [ ] **Step 2: Verificar T14.2**

```bash
scripts/check-skill-size.sh
```

Expected: exit 0.

- [ ] **Step 3: Verificar T14.4 e T14.5**

```bash
git diff --diff-filter=A --name-only main...HEAD
```

Expected: nenhum caminho sob `scripts/`, e nenhum arquivo cujo nome ou conteúdo
implemente checagem de fragmento literal. Os únicos arquivos novos previstos
por este plano são `docs/evidence-model.md` e, se o teto de linhas tiver
disparado, um ou mais arquivos sob `references/`.

- [ ] **Step 4: Verificar T14.3**

```bash
git diff --name-only main...HEAD -- scripts/
```

Expected: nenhuma saída. Se algum arquivo de `scripts/` aparecer, abra o diff e
confirme que ele não passou a exigir fragmento literal em citação — IR5 é sobre
o contrato do gate, não sobre o arquivo existir.

- [ ] **Step 5: Verificar T14.6, commit a commit**

```bash
for c in $(git log --format=%H main..HEAD); do
    files="$(git show --name-only --format= "$c")"
    printf '%s\n' "$files" | grep -qE '^(skills|scripts|githooks|\.github|hooks)/' || continue
    printf '%s\n' "$files" | grep -q '^CHANGELOG.md$' || echo "SEM CHANGELOG: $c"
done
```

Expected: nenhuma linha `SEM CHANGELOG`. **Um commit listado aqui é o defeito que
`scripts/check-changelog.sh` existe para pegar e que `--no-verify` deixa passar**
— corrija-o antes de fechar a branch.

- [ ] **Step 6: Rodar todas as suítes**

```bash
for t in tests/hooks/test-*.sh; do "$t" >/dev/null 2>&1 || echo "FALHOU: $t"; done
scripts/check-links.sh
scripts/check-docs-sync.sh
scripts/check-evidence-line.sh
```

Expected: nenhuma linha `FALHOU` e exit 0 nos três.

- [ ] **Step 7: Conferir e commitar**

```bash
git diff --stat
git add CHANGELOG.md
git commit -m "docs: o item de Open gaps para de afirmar ausencia de defeito medido"
```
