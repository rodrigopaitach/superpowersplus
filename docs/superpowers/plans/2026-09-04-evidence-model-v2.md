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

**Tech Stack:** `bash` em `tests/hooks/test-check-cross-references.sh:1` e
`python3` dentro de
`skills/writing-plans/scripts/check-cross-references`, que **é um script bash** —
a linha 1 é `#!/usr/bin/env bash` e o python abre num heredoc em
`skills/writing-plans/scripts/check-cross-references:104`. Nenhuma entrada nova: a spec
declara `## External Dependencies` como `None`, e IR2 é a guarda.

**Execution:** `inline` — session todos (not persisted). **O registro durável é o commit por
task**: cada task deste plano termina em `git commit`, então quem retomar depois de uma interrupção
lê `git log main..HEAD` para saber a última task fechada, e o todo perdido custa no máximo a task em
curso.

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
| T3.7 Os dois comentários do script deixam de declarar a regra antiga | AC44 | structural | range localizado em `skills/writing-plans/scripts/check-cross-references`, mais `grep -c 'name its covering test'` e `grep -c 'Matrix cells name a test'` esperando 0 nos dois | — | — |
| T4.1 A regra de adequação é operacional em brainstorming | AC5 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.2 A skill exige evidence class por critério | AC7 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.3 Codebase Findings pede o menor range suficiente | AC9 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.4 A skill escreve o marcador no cabeçalho da spec | AC36 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
| T4.5 O coverage map define testabilidade por evidência admissível | AC8 | structural | range localizado em `skills/brainstorming/references/coverage-map.md` | — | — |
| T4.6 As rows de AC e IR admitem a evidência da classe, e a matriz muda de nome | AC43 | structural | range localizado em `skills/brainstorming/SKILL.md`, mais `grep -c 'Test Coverage Matrix'` esperando 0 | — | — |
| T4.7 O checklist e o short path deixam de fixar a citação como forma da evidência | AC43 | structural | range localizado em `skills/brainstorming/SKILL.md` | — | — |
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
| T6.7 A abertura da seção de critérios e a linha do template deixam de exigir implementação mais teste | AC44 | structural | range localizado em `skills/writing-plans/SKILL.md`, mais `grep -c 'implementation .file:line. and a test'` esperando 0 — o padrão sem o `an` inicial casa a linha sozinha, e devolve 1 antes da mudança | — | — |
| T7.1 O plan reviewer cobra as seis colunas e a semântica da classe | AC13 | structural | range localizado em `skills/writing-plans/plan-document-reviewer-prompt.md` | — | — |
| T7.2 O plan reviewer decide pelo marcador | AC34 | structural | range localizado em `skills/writing-plans/plan-document-reviewer-prompt.md` | — | — |
| T7.3 As rows de deliverable e de critério passam a falar de evidência admissível | AC44 | structural | range localizado em `skills/writing-plans/plan-document-reviewer-prompt.md` | — | — |
| T8.1 A tabela do audit tem as colunas novas nas duas ocorrências | AC16 | structural | `grep -c 'Criterion . Delivery evidence . Verification evidence'` em `skills/final-branch-audit/SKILL.md`, esperando 2 — o `.` casa o pipe sem carregar um literal para dentro da célula, e a frase solta `Delivery evidence` não serviria: o Step 7 a usa numa terceira ocorrência, na definição das colunas | — | — |
| T8.2 O veredito de classe inadequada existe e bloqueia | AC17 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.3 O auditor aponta inadequação e não reclassifica para conceder | AC18 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.4 O auditor executa verificação read-only por critério | AC19 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.5 O audit aplica o discriminador de compatibilidade | AC20 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.6 O contrato do audit em review-scopes admite execução read-only | AC21 | structural | range localizado em `docs/review-scopes.md` | — | — |
| T8.7 A regra de abertura do audit exige a evidência que a classe admite | AC41 | structural | range localizado em `skills/final-branch-audit/SKILL.md`, mais `grep -c 'no located citation is NOT DELIVERED'` esperando 0 | — | — |
| T8.8 A definição das colunas nomeia a evidência da classe, e a regra de teste ausente passa a valer só para behavioral | AC46 | structural | range localizado em `skills/final-branch-audit/SKILL.md`, mais três contagens: `grep -c 'Delivery evidence.. and ..Verification evidence'` esperando 1, `grep -c 'A criterion with no test citation is NOT DELIVERED'` esperando 0, e `grep -c 'Untested is undelivered — for that class'` esperando 1 | — | — |
| T8.9 As Verdict Rules verdictam pelo instrumento da classe | AC46 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.10 O protocolo busca o instrumento que a classe nomeia, não sempre um teste | AC46 | structural | range localizado em `skills/final-branch-audit/SKILL.md` | — | — |
| T8.11 A introdução e a tabela de racionalizações seguem o modelo | AC46 | structural | range localizado em `skills/final-branch-audit/SKILL.md`, mais `grep -c 'Evidence is .file:line.'` esperando 0 | — | — |
| T8.12 As rows de task review e de re-review em review-scopes descrevem o protocolo novo | AC47 | structural | range localizado em `docs/review-scopes.md` | — | — |
| T9.1 O task reviewer verifica por classe declarada | AC22 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.2 A tabela de evidência generaliza para Verification Evidence | AC28 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.3 O litmus e a execução de testes sobrevivem para behavioral | AC29 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T9.4 A forma da linha de evidência não muda | IR3 | negative | `scripts/check-evidence-line.sh`, exit 0 | — | — |
| T9.5 O test command é exigido de task com critério behavioral | AC42 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md`, mais `grep -c 'REQUIRED: the command that runs'` esperando 0 — a declaração universal saiu | — | — |
| T9.6 Task só structural ou negative não recebe nem inventa test command | AC42 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md`, mais `grep -c 'has no admissible value for this field'` esperando 1 — a proibição entrou | — | — |
| T9.7 A referência de seção em review-scopes acompanha o rename desta task | AC47, IR4 | negative | `scripts/check-links.sh`, exit 0 | — | — |
| T9.8 A linha de propósito deixa de dizer que o reviewer re-roda os testes sempre | AC45 | structural | range localizado em `skills/subagent-driven-development/task-reviewer-prompt.md` | — | — |
| T10.1 O controller entrega instrumentos e não deriva comando universal | AC32 | structural | range localizado em `skills/subagent-driven-development/SKILL.md` | — | — |
| T10.2 A instrução de entregar test command e base count vira condicional | AC45 | structural | range localizado em `skills/subagent-driven-development/SKILL.md` | — | — |
| T10.3 O fix loop e a condição de despacho do re-review seguem a classe | AC45 | structural | range localizado em `skills/subagent-driven-development/SKILL.md`, mais `grep -c 'contains the covering tests'` esperando 0 | — | — |
| T11.1 O preflight inline exige classe e instrumento admissível | AC33 | structural | range localizado em `skills/executing-plans/SKILL.md` | — | — |
| T12.1 Os dois reviewers de código admitem command evidence | AC23 | structural | range localizado em `skills/requesting-code-review/code-reviewer.md` e em `skills/subagent-driven-development/re-review-prompt.md` | — | — |
| T13.1 A seção de testes e os placeholders do re-review viram condicionais | AC45 | structural | range localizado em `skills/subagent-driven-development/re-review-prompt.md`, mais `grep -c 'REQUIRED: the same command the task review ran'` esperando 0 | — | — |
| T13.2 A saída e o contrato de retorno do re-review reportam o instrumento da classe | AC45 | structural | range localizado em `skills/subagent-driven-development/re-review-prompt.md` | — | — |
| T13.3 O contrato do fix report exige os instrumentos aplicáveis | AC45 | structural | range localizado em `skills/subagent-driven-development/implementer-prompt.md` | — | — |
| T13.4 A forma da linha de evidência sobrevive ao rename | IR3 | negative | `scripts/check-evidence-line.sh`, exit 0 | — | — |
| T13.5 As referências de seção que esta task quebra são ajustadas no mesmo commit | AC47 | structural | `scripts/check-links.sh`, exit 0, com os dois renames e os dois ajustes no mesmo estado da árvore | — | — |
| T14.1 A referência canônica descreve a promessa nova | AC24 | structural | range localizado em `docs/README.pt-BR.md` e em `docs/README.en.md` | — | — |
| T14.2 O showcase descreve a promessa nova | AC25 | structural | range localizado em `README.md` | — | — |
| T14.3 O par de referências muda no mesmo commit | IR7 | negative | `scripts/check-docs-sync.sh` **com os dois arquivos já staged**, exit 0 — ele lê `git diff --cached` e sai 0 trivialmente sobre índice vazio | — | — |
| T15.1 O item de Open gaps para de afirmar ausência de defeito | AC26 | structural | range localizado em `CHANGELOG.md` | — | — |
| T15.2 Nenhum SKILL.md não isento passa de 500 linhas | IR1 | negative | `scripts/check-skill-size.sh`, exit 0 | — | — |
| T15.3 Nenhum gate novo exige fragmento literal | IR5 | negative | `git diff --name-only` da branch, conferindo que nada em `scripts/` mudou de contrato | — | — |
| T15.4 Nenhum arquivo novo entra em scripts | IR6 | negative | `git diff --diff-filter=A --name-only` da branch, limitado a `scripts/` | — | — |
| T15.5 O anchor-fragment gate não foi construído | IR9 | negative | `git diff --diff-filter=A --name-only` da branch, procurando gate de fragmento | — | — |
| T15.6 Todo commit que toca skills tem entrada de changelog | IR8 | negative | `git log --format` da branch cruzado com `git show --name-only` por commit | — | — |
| T16.1 Os dois controllers resolvem o modo a partir da source spec antes de executar | AC48 | structural | range localizado em `skills/executing-plans/SKILL.md` e em `skills/subagent-driven-development/SKILL.md` | — | — |
| T16.2 No modo v2 a classe é obrigatória e a ausência bloqueia antes do dispatch | AC48 | structural | range localizado nos dois controllers | — | — |
| T16.3 No modo legacy a classe efetiva é `behavioral` e a derivação pré-v2 de test command é preservada onde existia, sem inventar comando | AC48 | structural | range localizado nos dois controllers | — | — |
| T16.4 Plano sem source spec mantém o entry blocker e só entra em legacy após confirmação | AC48 | structural | range localizado nos dois controllers | — | — |
| T16.5 A autoridade é a source spec: v2 com matriz histórica bloqueia, legacy com Verification Matrix não | AC48 | structural | range localizado nos dois controllers | — | — |
| T16.6 Os três prompts consomem a decisão, com a cláusula idêntica, sem abrir spec nem plano e sem quarta classe | AC48 | structural | range localizado em `task-reviewer-prompt.md`, `implementer-prompt.md` e `re-review-prompt.md`, mais a conferência de identidade das três ocorrências | — | — |
| T16.7 O documento canônico carrega o conceito ampliado e a tabela de decisão dos doze casos | AC48 | structural | range localizado em `docs/evidence-model.md`, mais `grep -c` das doze linhas da tabela esperando 12 | — | — |
| T16.8 Os doze casos da tabela de decisão têm verificação determinística, e a regra que os dois controllers delegam está declarada onde eles apontam | AC48 | structural | `tests/compatibility-mode/run-tests.sh`, exit 0, mais range localizado em `docs/evidence-model.md`, seção "Compatibility: legacy behavioral" | — | — |
| T16.9 Nenhum plano ou spec histórico é modificado por esta task | AC48 | negative | `git diff --name-only` da branch limitado a `docs/superpowers/`, conferindo que só os dois artefatos desta linha de trabalho aparecem | — | — |
| T16.10 A suíte nova tem step de CI | AC48 | structural | range localizado em `.github/workflows/ci.yml` | — | — |

This plan has 16 tasks.

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

**Spec criterion:** AC37, AC38, AC39, AC40, AC44; IR2, IR10

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
- T3.7: os dois comentários do script deixam de declarar que todo task criterion nomeia um covering test e que toda célula da matriz nomeia um teste — instrumento na matriz

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

# CLEAN_PLAN without its matrix. Its task body declares T1.1 and carries the
# code block that creates `rejects the bad input`.
VM_BASE="$(printf '%s' "$CLEAN_PLAN" | sed '/^## Test Coverage Matrix$/,$d')"

VM_HEAD='## Verification Matrix

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|---|---|---|---|---|---|'

# ONE ROW PER FIXTURE. Three case names over one shared document would be three
# names for one measurement: any mutation that reddens the document reddens all
# three, and none of them says which branch broke.
BEHAVIORAL_ROW="$VM_BASE
$VM_HEAD
| T1.1 | AC1 | behavioral | > rejects the bad input | unit | tests |"

STRUCTURAL_ROW="$(printf '%s' "$VM_BASE" |
    sed 's|^- T1.1 rejects the bad input$|- T1.2 the manifest parses|')
$VM_HEAD
| T1.2 | AC2 | structural | python3 -m json.tool manifest.json > /dev/null | — | — |"

NEGATIVE_ROW="$(printf '%s' "$VM_BASE" |
    sed 's|^- T1.1 rejects the bad input$|- T1.3 no new dependency|')
$VM_HEAD
| T1.3 | AC3 | negative | the check lives at suite.sh::validate | — | — |"

# A `behavioral` row whose CRITERION cell carries an angle bracket. Only the
# instrument column may name a test, and this fixture is the only one that says
# so — it is what separates the two halves of the fix, which are nested.
BEHAVIORAL_WIDE="$(printf '%s' "$VM_BASE" |
    sed 's|^- T1.1 rejects the bad input$|- T1.4 rejects input > 100|')
$VM_HEAD
| T1.4 rejects input > 100 | AC4 | behavioral | > rejects the bad input | unit | tests |"

run_case "a behavioral row naming a test a step creates passes" 0 "$BEHAVIORAL_ROW"

run_case "a behavioral row naming a test no step creates fails" 1 "$(printf '%s' "$BEHAVIORAL_ROW" |
    sed 's/| > rejects the bad input |/| > a test nobody wrote |/')"

run_case "a structural instrument holding an angle bracket is not a test" 0 "$STRUCTURAL_ROW"

run_case "a negative instrument holding a double colon is not a test" 0 "$NEGATIVE_ROW"

run_case "only the instrument column of a behavioral row names a test" 0 "$BEHAVIORAL_WIDE"

run_case "a task criterion with no verification row still fails" 1 "$(printf '%s' "$BEHAVIORAL_ROW" |
    sed 's|^- T1.1 rejects the bad input$|- T1.1 rejects the bad input\n- T1.9 unrowed|')"

run_case "a verification row with no task criterion still fails" 1 "$BEHAVIORAL_ROW
| T2.9 | AC9 | structural | a located range | — | — |"

run_case "a duplicated verification row still fails" 1 "$BEHAVIORAL_ROW
| T1.1 | AC1 | behavioral | > rejects the bad input | unit | tests |"

# --- the legacy five-column schema is not migrated during the read --------
# A REAL five-column Test Coverage Matrix. CLEAN_PLAN cannot stand in for one:
# its matrix is `| Criterion | Test |`, two columns, whose header carries no
# `Spec criterion` and so never reaches either branch of the new code. Using it
# here would have been a case that names the five-column schema and exercises
# nothing about it — and a byte-identical duplicate of `clean plan passes`.
LEGACY_PLAN="$VM_BASE
## Test Coverage Matrix

| Criterion | Spec criterion | Test type | Layer | Test |
|---|---|---|---|---|
| T1.1 | AC1 | unit | tests | > rejects the bad input |"

run_case "a legacy five-column matrix still passes" 0 "$LEGACY_PLAN"

run_case "a legacy five-column matrix naming a test no step creates fails" 1 "$(printf '%s' "$LEGACY_PLAN" |
    sed 's/| > rejects the bad input |/| > a test nobody wrote |/')"
````

**Os sete comportamentos de AC37 estão nos oito primeiros casos**, um por
fixture. O quinto — `only the instrument column of a behavioral row names a
test` — não é um dos sete: ele existe para o Step 5, e sem ele as duas metades
da correção não se distinguem.

- [ ] **Step 2: Rodar para ver falhar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL — **exatamente três** casos vermelhos, todos com
`expected exit 0, got 1`:

- `a structural instrument holding an angle bracket is not a test` — a saída
  nomeia `/dev/null`
- `a negative instrument holding a double colon is not a test` — a saída nomeia
  `validate`
- `only the instrument column of a behavioral row names a test` — a saída nomeia
  `100`

**É a mensagem que confirma que o vermelho é o defeito sob teste e não erro de
fixture.** Os outros sete casos novos já passam, e cada um é guarda de regressão
declarada: os dois de row órfã, o de row duplicada, o de id de teste
inexistente, o de row `behavioral` bem-formada e os dois do schema histórico
exercitam caminhos que já funcionam. **Um quarto vermelho é sinal de fixture
errada, não de defeito a mais.**

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
Expected: PASS — exit 0, e a contagem de `[PASS]` sobe **em 10**, um por
`run_case` acrescentado. Confira o delta; o total absoluto muda toda vez que
alguém acrescenta um caso a esta suíte.

- [ ] **Step 5: Provar que cada metade da correção entra**

Duas mutações. **Elas são aninhadas, não independentes** — desligar a leitura
do cabeçalho desliga também a leitura da classe, que só roda dentro dela — e o
que se prova é que o conjunto de vermelhos da segunda **contém estritamente** o
da primeira. Depois de cada uma, **restaure o arquivo** e confirme exit 0 antes
da próxima.

1. Troque `if klass != "behavioral":` por `if False:`. Esperado: **dois**
   vermelhos — `a structural instrument holding an angle bracket is not a test`
   e `a negative instrument holding a double colon is not a test`.
   `only the instrument column of a behavioral row names a test` **continua
   verde**, porque o estreitamento para a coluna do instrumento ainda roda.
2. Troque `if header and "evidence class" in header:` por `if False:`. Esperado:
   **três** vermelhos — os dois acima mais
   `only the instrument column of a behavioral row names a test`, que agora cai
   no caminho histórico e volta a ler a célula do critério.
   `a legacy five-column matrix still passes` continua verde nas duas, que é a
   prova de que a metade histórica não depende da nova.

**O caso que separa as duas mutações é o terceiro.** Sem ele os dois conjuntos
de vermelhos são idênticos e o Step alegaria uma distinção que a suíte não mede.
Se as duas produzirem o mesmo conjunto, a fixture `BEHAVIORAL_WIDE` não está
entrando, e isso se investiga antes de seguir.

- [ ] **Step 6: Verificar T3.5 pelo caso pinado**

```bash
tests/hooks/test-check-cross-references.sh | grep 'the committed corpus keeps its verdicts'
```

Expected: uma linha `[PASS]`, **e nunca um par de números específico**. Os dois
que a linha imprime se movem em direções opostas: o total conta os `.md` na
árvore (`tests/hooks/test-check-cross-references.sh:495-497`) e sobe a cada
documento commitado; o comparado conta só os que o commit pinado carrega, porque
`tests/hooks/test-check-cross-references.sh:506` pula os demais, e está
congelado. Medido em 04/09/2026: o pin carrega 36 documentos, a árvore tem 44.
**A razão entre os dois cai a cada release** —
`tests/hooks/test-check-cross-references.sh:27-30` diz exatamente isso — e uma
queda do comparado é o único sinal desse arquivo que pede ação. O que se
confirma é o invariante: `[PASS]`, zero documentos movidos, comparados maior
que zero.

- [ ] **Step 7: Corrigir o comentário que declara a regra antiga (T3.7)**

`skills/writing-plans/scripts/check-cross-references:272-275` explica por que a
busca de teste olha só os blocos cercados, e a explicação se apoia na regra que
a Task 6 remove. **São quatro linhas, e a primeira delas entra intacta na
substituição** — trocar só três duplicaria `:272`:

```python
# Searching the whole document instead of the code blocks does NOT work:
# writing-plans requires every task criterion to name its covering test, so the
# criterion line carries the name even when a step renamed the test, and the
# check passes on the one defect it exists for.
```

Substitua as quatro linhas de `skills/writing-plans/scripts/check-cross-references:272-275` por:

```python
# Searching the whole document instead of the code blocks does NOT work:
# a `behavioral` criterion names its covering test on the criterion line, so
# that line carries the name even when a step renamed the test, and the check
# passes on the one defect it exists for.
```

**Há uma segunda ocorrência no mesmo arquivo, e a varredura de regressão a
achou.** `skills/writing-plans/scripts/check-cross-references:278` diz
`# Matrix cells name a test as \`> name\`, \`file.py::name\`, or \`file:line > name\`.`
— depois do Step 3 só a row `behavioral` nomeia teste. Troque por:

```python
# A `behavioral` row names its test as `> name`, `file.py::name`, or
# `file:line > name`. Rows of the other two classes name an instrument, and
# nothing here reads it.
```

**O comportamento do script não muda em nenhuma das duas** — são comentários. O
que muda é a razão declarada: ela deixa de afirmar uma regra universal que o
modelo substitui e passa a falar da classe onde a regra continua valendo.

- [ ] **Step 8: Verificar T3.6**

```bash
grep -n '^import\|^from' skills/writing-plans/scripts/check-cross-references
```

Expected: apenas módulos da biblioteca padrão de Python. Qualquer outro nome é
violação de IR2 e se remove.

- [ ] **Step 9: Conferir e commitar**

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

**Spec criterion:** AC5, AC7, AC8, AC9, AC36, AC43

**Files:**
- Modify: `skills/brainstorming/SKILL.md:32` — Step 7 (item 1 do `## Checklist`)
- Modify: `skills/brainstorming/SKILL.md:92` — Step 7 (a linha do short path)
- Modify: `skills/brainstorming/SKILL.md:235-237` — Step 2 edita as células de `:235` e `:236`, Step 6 as de `:235` e `:236` de novo, Step 3 a de `:237`
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
- T4.6: as rows de `## Acceptance Criteria` e `## Implicit Requirements` deixam de exigir critério settleable por `file:line` e a referência à matriz vira `Verification Matrix` — instrumento na matriz
- T4.7: o item 1 do `## Checklist` e a linha do short path deixam de fixar `path/file.ext:line` como forma da evidência — instrumento na matriz

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

**Há dois parágrafos que abrem com `**Resuming a spec written before`** —
`skills/brainstorming/SKILL.md:44`, na section "Checklist", sobre o coverage map,
e `skills/brainstorming/SKILL.md:242`, na section "After the Design", sobre as
seções obrigatórias da spec. **É o segundo**, que governa o conteúdo da spec.
Acrescente ao fim dele:

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

- [ ] **Step 6: As rows de critério admitem a evidência da classe (T4.6)**

Na tabela `**Required spec sections:**`, a célula de `## Acceptance Criteria`
hoje diz *"one observable behavior each, stated so a `file:line` citation could
settle it"*. Troque esse trecho por:

```markdown
one observable behavior each, stated so the evidence its declared class admits could settle it — a located range, a read-only check, or a grounded source
```

Na célula de `## Implicit Requirements`, o trecho *"written exactly like an
acceptance criterion — one observable behavior, settled by a `file:line`
citation"* vira:

```markdown
written exactly like an acceptance criterion — one observable behavior, settled by the evidence its class admits
```

E na mesma célula, a menção a `Test Coverage Matrix` vira `Verification Matrix`:
`writing-plans` refina cada `IR` em critérios de task que carregam o id dela
naquela tabela, e a tabela muda de nome na Task 6.

- [ ] **Step 7: O checklist e o short path (T4.7)**

O item 1 do `## Checklist` manda *"Record every finding as `path/file.ext:line`
+ the quoted snippet"*. Troque por:

```markdown
Record every finding as the smallest sufficient located range + the quoted snippet
```

E na seção "The Short Path", o item *"The investigation you already did, cited
`path/file.ext:line`"* vira:

```markdown
- The investigation you already did, cited as located ranges
```

**Nenhuma outra ocorrência de `file:line` neste arquivo muda.** As que restam —
a fonte de uma recomendação na escalation shape, e a descrição da saída de
`check-cross-references` — são evidência local legítima, e a spec diz isso em
AC43.

- [ ] **Step 8: Verificar o teto e os links**

```bash
scripts/check-skill-size.sh
scripts/check-links.sh
```

Expected: exit 0 nos dois. `brainstorming/SKILL.md` estava em 403 linhas na
baseline, com 97 de folga. **Se o teto disparar, o excedente vai para
`skills/brainstorming/references/`, nunca por compressão** — e o ponteiro para o
arquivo novo fica no lugar de onde o texto saiu.

- [ ] **Step 9: Conferir e commitar**

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

A tabela vai de `skills/brainstorming/spec-document-reviewer-prompt.md:84` a
`:91` — **não termina em `:89`**, que é a linha
`| Item in \`## Assumptions to Confirm\` that IS verifiable in the code | BLOCKING — ... |`;
depois dela ainda vêm duas rows. Acrescente as quatro abaixo **ao fim da
tabela**, depois de `:91`:

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

**Spec criterion:** AC12, AC14, AC15, AC30, AC31, AC34, AC44

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
- T6.7: o parágrafo de abertura de `## Acceptance Criteria` e a linha de exemplo do template de task deixam de exigir implementação `file:line` mais teste `file:line` — instrumento na matriz

- [ ] **Step 1: Substituir a seção da matriz (T6.1, T6.2)**

**`## Test Coverage Matrix` aparece DUAS vezes neste arquivo, e trocar só uma
não entrega a AC12.** `skills/writing-plans/SKILL.md:239` é a seção de regras,
tratada aqui; `skills/writing-plans/SKILL.md:120` é o mesmo heading **dentro do
template de plano**, no bloco cercado que vai de `skills/writing-plans/SKILL.md:80`
a `skills/writing-plans/SKILL.md:135`, e o Step 2 abaixo o trata. É a mesma falha
de segunda ocorrência que a AC16 nomeia para o audit, no arquivo que esta task
possui.

A seção de regras abre em `skills/writing-plans/SKILL.md:239` —
**o heading é essa linha, não `:242`, que é o segundo parágrafo** — e vai até o
fim da seção. Ela inteira, heading incluído, vira:

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

- [ ] **Step 2: Trocar a matriz dentro do template de plano (T6.1)**

`skills/writing-plans/SKILL.md:120-132` carrega o heading, a instrução e o
cabeçalho de cinco colunas com quatro rows de exemplo. **O range termina em
`:132`, a última row da tabela, e não em `:135`:** `:133` é linha em branco,
`:134` é o separador `---` e `:135` é a crase de fechamento do bloco cercado que
abre em `:80`. Substituir até `:135` engole a fence e joga `## Task Structure` e
tudo abaixo dela para dentro de um bloco de código — e nenhum step desta task
pega isso: `check-skill-size.sh` conta linhas, `check-links.sh` lê links, e os
greps do Step 8 só afirmam ausências. Depois da Task 7, todo
plano escrito a partir desse template é reprovado pelo próprio reviewer que a
Task 7 instala. Substitua o bloco inteiro por:

```markdown
## Verification Matrix

[One row per task criterion, across every task. The rules that govern this
table — the six columns, the instrument each evidence class requires, and
where the test types and layer names come from — are stated once in this
skill's "Verification Matrix" section below. Read it before filling this in.]

| Criterion | Spec criterion | Evidence class | Verification instrument | Test type | Layer |
|-----------|----------------|----------------|-------------------------|-----------|-------|
| T3.1 Rejects expired tokens | AC1 | behavioral | `tests/auth/test_verify.py::test_rejects_expired` | unit | `tests/auth/` |
| T5.1 Login survives a token refresh | AC3 | behavioral | `e2e/login.spec.ts > refreshes mid-session` | e2e | `e2e/` |
| T5.2 The manifest stays valid JSON | AC7 | structural | `python3 -m json.tool manifest.json` | — | — |
| T6.1 No new dependency enters the branch | IR2 | negative | `git diff --name-only BASE..HEAD` over the lockfile | — | — |
```

**A instrução dentro do template dizia "one row one test", sem vírgula** — é por
isso que um `grep` pela forma com vírgula da seção de regras passa por cima dela.
O Step 8 usa um instrumento que não escapa por isso.

- [ ] **Step 3: Distinguir locator de evidence (T6.3)**

No bloco `**Files:**` do template de task, acrescente logo abaixo:

```markdown
**The line range in a `Modify:` entry is navigation, not evidence.** It tells
the implementer where to open the file, and it ages while the branch is being
built — the task before this one may have moved it. The audit's evidence is
resolved against `HEAD` at audit time, never against what the plan wrote.
Plans locate work; audits locate evidence. The range is optional here and
carries no verdict.
```

- [ ] **Step 4: Preservar o invariante de elegibilidade (T6.4)**

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

- [ ] **Step 5: O bloco da task carrega o contrato inteiro (T6.5)**

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

- [ ] **Step 6: Decidir pelo marcador (T6.6)**

Na seção "Traceability to the Spec", acrescente uma linha à tabela de regras:

```markdown
| The spec's evidence model is read from its header, never inferred | A spec carrying `**Evidence model:** v2` declares a class on every criterion, and a criterion without one is an error to take back to the spec. A spec without the marker is historical: its criteria take the fallback, and the matrix cell reads `behavioral`. There is no heuristic — not on the git history, not on the spec's date, not on how the criteria are worded. |
```

- [ ] **Step 7: A abertura da seção de critérios e a linha do template (T6.7)**

Duas frases fora das quatro que AC31 enumera, medidas pela varredura.

`skills/writing-plans/SKILL.md:204-206` abre a seção `## Acceptance Criteria`
dizendo que o audit cobra *"one row per criterion, each needing an
implementation `file:line` and a test `file:line` before it counts as
delivered"*. Substitua o trecho por:

```markdown
one row per criterion, each needing the delivery evidence and the verification evidence its declared class admits before it counts as delivered
```

E a linha de exemplo do template de task, hoje
`- TN.1: [one observable behavior, stated so a \`file:line\` citation can settle
it]`, já foi substituída pelo Step 5 desta task, que dá ao critério a classe e o
instrumento. **Confirme que a substituição do Step 5 não deixou a cláusula
antiga em pé**; se deixou, remova-a aqui.

- [ ] **Step 8: Verificar o teto**

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

- [ ] **Step 9: Verificar T6.1 e T6.2 pela ausência**

```bash
grep -in 'test coverage matrix' skills/writing-plans/SKILL.md
grep -in 'one row.\?,\? one test' skills/writing-plans/SKILL.md
grep -n 'covering test' skills/writing-plans/SKILL.md
```

Expected: nada nas duas primeiras. **A segunda casa as duas grafias de
propósito**: a seção de regras escrevia *"One row, one test"* com vírgula e o
template escrevia *"one row one test"* sem, então um `grep` pela forma com
vírgula devolve `0` com o template inteiro de pé — passa exatamente no defeito
para o qual foi escrito. Na terceira, toda ocorrência restante fala de
`behavioral`; uma que ainda universalize é AC31 por fazer.

- [ ] **Step 10: Conferir e commitar**

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

**Spec criterion:** AC13, AC34, AC44

**Files:**
- Modify: `skills/writing-plans/plan-document-reviewer-prompt.md:89`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o schema de seis colunas que a Task 6 instalou.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T7.1: o prompt cobra as seis colunas e a semântica da classe: bloqueia critério sem instrumento resolvido, deixa de exigir teste de `structural` e `negative`, não trata `—` como achado fora de `behavioral`, e bloqueia divergência entre o bloco da task e a matriz — instrumento na matriz
- T7.2: o prompt decide pelo marcador, sem inferência heurística — instrumento na matriz
- T7.3: as rows sobre deliverable de task e sobre critério settleable passam a falar da evidência que a classe admite — instrumento na matriz

- [ ] **Step 1: Substituir a linha das cinco colunas**

A linha 89 hoje é:

```markdown
    | A `## Test Coverage Matrix` carrying all five columns — `Criterion`, `Spec criterion`, `Test type`, `Layer`, `Test` — with one row per task criterion, one test each, and every `AC` and `IR` appearing in the Spec criterion column of at least one row | BLOCKING — a criterion with no row is a criterion nobody planned to test, and a dropped column is a dropped obligation: without `Test type` and `Layer` a row states an intention, not a plan. An `IR` (concurrency, error handling, observability, edge cases) is charged on the same terms as an `AC`: named test type, real layer, exact test id |
```

Substitua por estas quatro:

```markdown
    | A `## Verification Matrix` carrying all six columns — `Criterion`, `Spec criterion`, `Evidence class`, `Verification instrument`, `Test type`, `Layer` — with one row per task criterion and every `AC` and `IR` appearing in the Spec criterion column of at least one row | BLOCKING — a criterion with no row is a criterion nobody planned to verify, and a dropped column is a dropped obligation |
    | A row whose `Verification instrument` is empty or unresolved | BLOCKING — for `behavioral` that is the exact test id; for `structural` a read-only validating command or the artifact whose located ranges will carry the evidence; for `negative` a read-only command over the declared scope. A row naming none of the three states an intention, not a plan. **A `structural` instrument that names a file without a line range is resolved, not unresolved**: at plan time those lines do not exist yet, and the range is the auditor's to resolve against `HEAD`. Plans locate work; audits locate evidence |
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

- [ ] **Step 4: As duas rows que falam em `file:line` universal (T7.3)**

A row `| No task's deliverable lives outside the repository | BLOCKING — the
test is the audit's own: does the task leave something a `path/file.ext:line`
citation can prove? ... |` passa a fazer a pergunta na forma que a Task 6
instala em `writing-plans`:

```markdown
does the task leave a versioned deliverable in the branch?
```

O resto da célula fica intacto — a lista de efeitos externos que não deixam
deliverable e a explicação do deadlock continuam corretas.

E a row `| Every criterion, `AC` and `IR`, is observable and settled by a
`file:line` citation | ... |` já foi substituída pelo Step 2 desta task.
**Confirme que ela não sobreviveu em duplicata**: a varredura mediu essa
formulação em dois arquivos, e este é o segundo.

- [ ] **Step 5: Verificar e commitar**

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

**Spec criterion:** AC16, AC17, AC18, AC19, AC20, AC21, AC41, AC46, AC47

**Files:**
- Modify: `skills/final-branch-audit/SKILL.md:10`
- Modify: `skills/final-branch-audit/SKILL.md:21-22`
- Modify: `skills/final-branch-audit/SKILL.md:101`
- Modify: `skills/final-branch-audit/SKILL.md:116-120`
- Modify: `skills/final-branch-audit/SKILL.md:126-134`
- Modify: `skills/final-branch-audit/SKILL.md:186-188`
- Modify: `skills/final-branch-audit/SKILL.md:363-364`
- Modify: `skills/final-branch-audit/SKILL.md:300`
- Modify: `docs/review-scopes.md:12`
- Modify: `docs/review-scopes.md:14`
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
- T8.7: a regra de abertura do arquivo deixa de exigir located citation universalmente e passa a exigir a evidência que a classe declarada admite — instrumento na matriz
- T8.8: a definição das colunas sob a tabela nomeia a evidência que cada classe admite, e a regra *"untested is undelivered"* passa a valer só para `behavioral` — instrumento na matriz. **São as duas propriedades do bloco que o step substitui, e a matriz mede as duas**
- T8.9: as rows de `## Verdict Rules` verdictam pelo instrumento que a classe admite — instrumento na matriz
- T8.10: o passo do protocolo que manda buscar o covering test passa a buscar o instrumento da classe — instrumento na matriz
- T8.11: a introdução e as duas rows da tabela de racionalizações seguem o modelo — instrumento na matriz
- T8.12: as rows de task review e de re-review em `docs/review-scopes.md` descrevem o protocolo novo — instrumento na matriz

**AC47 tem duas propriedades e três donos.** Esta task entrega a primeira — as
rows descrevendo o protocolo. A segunda, *as referências de seção continuam
resolvendo depois dos renames*, é entregue onde cada rename acontece: `T9.7`
para o rename de AC28, na Task 9, e `T13.5` para os dois renames de AC45, na
Task 13. **Consertar a referência antes do rename reprova `check-links.sh` no
commit de quem chegar primeiro**, então a metade não pode morar aqui.

- [ ] **Step 1: Corrigir a regra de abertura (T8.7)**

`skills/final-branch-audit/SKILL.md:21-22` hoje diz:

```markdown
**Evidence-or-zero.** A criterion with no located citation is NOT DELIVERED.
There is no "probably done", no "looks implemented", no partial credit.
```

**Esta é a primeira regra que o auditor lê, e ela decide todo veredito.** Deixada
como está, o topo do arquivo contradiz tudo o que os steps seguintes instalam, e
um critério `negative` — que por definição não tem citação localizada — é
reprovado antes de qualquer outra coisa. Substitua por:

```markdown
**Evidence-or-zero.** A criterion is NOT DELIVERED unless it carries the
delivery evidence AND the verification evidence its declared class admits: a
located range plus a covering test for `behavioral`, a located range plus a
read-only validator for `structural`, the declared scope plus a read-only
command for `negative`. There is no "probably done", no "looks implemented",
no partial credit. **The absence of a located citation is not itself the
failure** — it is the failure only where the class requires one, and reading it
as universal is what made every criterion about an absence structurally
undeliverable.
```

**Este step vem primeiro na task de propósito**: os steps seguintes instalam a
tabela e o protocolo que dependem desta regra, e corrigi-la por último deixaria o
arquivo contraditório durante a própria edição.

- [ ] **Step 2: Trocar as colunas nas duas ocorrências (T8.1)**

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

- [ ] **Step 3: Acrescentar o veredito de classe inadequada (T8.2)**

Na tabela de vereditos que hoje começa em
`skills/final-branch-audit/SKILL.md:126`, acrescente:

```markdown
| Declared class does not fit the criterion | **EVIDENCE CLASS MISMATCH — BLOCKING** |
```

Ela segue a forma da linha
`| Criterion delivered somewhere other than the plan said | DELIVERED — note the real location in the row |`
que já está ali, com veredito bloqueante em vez de concessivo.

- [ ] **Step 4: O híbrido restrito (T8.3, T8.4)**

No protocolo do auditor — o bloco que hoje contém
*"Evidence-or-zero: a criterion with no `path/file.ext:line` citation is NOT
DELIVERED"* em `skills/final-branch-audit/SKILL.md:259-261` (`:258` é linha em
branco) — substitua esse parágrafo por:

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

- [ ] **Step 5: O discriminador de compatibilidade (T8.5)**

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

- [ ] **Step 6: O contrato em review-scopes (T8.6)**

`docs/review-scopes.md:15` hoje diz *"**No tests at all** — re-runs the
*searches* against the spec"*. Substitua a célula por:

```markdown
**Read-only verification, per criterion** — re-runs the searches against the spec, and re-runs the instrument each criterion's evidence class names: the test for `behavioral`, the validating command or the located ranges for `structural`, the command over the declared scope for `negative`. It never mutates the checkout, and it does not take over the project-suite reviewer's job: it re-runs what a criterion claims, not the suite as a whole
```

- [ ] **Step 7: A definição das colunas (T8.8)**

`skills/final-branch-audit/SKILL.md:116-120`, logo abaixo da tabela, hoje diz:

```markdown
- **Implementation** and **Test** are `path/file.ext:line` — a path alone is
  not a citation, and neither is a commit SHA.
- Cite the line that DOES the thing, not the file that mentions it.
- A criterion with no test citation is NOT DELIVERED even when the
  implementation exists. Untested is undelivered.
```

**As colunas mudaram de nome no Step 2 e a definição delas não.** Substitua por:

```markdown
- **Delivery evidence** and **Verification evidence** carry what the declared
  class admits: a located range for `behavioral` and `structural`, the
  declared scope for `negative`; a covering test, a read-only validator, or a
  read-only command respectively. A path alone is not a located range, and
  neither is a commit SHA — a commit-pinned reference is provenance, never
  current-state evidence.
- Cite the line that DOES the thing, not the file that mentions it.
- **A `behavioral` criterion with no test citation is NOT DELIVERED even when
  the implementation exists. Untested is undelivered — for that class.** For
  `structural` and `negative` the verification evidence is the check you re-ran
  and what it returned, and demanding a test there fails a criterion nobody
  planned to test.
```

- [ ] **Step 8: As Verdict Rules (T8.9)**

A tabela em `skills/final-branch-audit/SKILL.md:126-134` verdicta por
implementação mais teste. As três primeiras rows viram:

```markdown
| Delivery and verification evidence both cited, both check out when re-run | DELIVERED |
| No evidence, or evidence that does not check out | NOT DELIVERED |
| Delivery evidence cited, verification evidence absent or not re-runnable | NOT DELIVERED |
```

**A row `| Implementation cited, no covering test | NOT DELIVERED |` sai.** Ela é
a única regra desta tabela que reprova sozinha todo critério `structural` e
`negative`, e é o que a torna a mais grave das cinco. As demais rows — linha
citada que não faz o que o critério diz, entrega em lugar diferente do planejado,
FALSE COMPLETION, OUT OF SCOPE — DECLARED — ficam **intactas**: nenhuma delas
pressupõe teste.

- [ ] **Step 9: O passo do protocolo que busca teste (T8.10)**

`skills/final-branch-audit/SKILL.md:186-188` é o passo 3 do protocolo de busca:

```markdown
3. Search for the covering test the same way. Open it and confirm it asserts
   the criterion's behavior — a test that never fails if the behavior breaks
   is not a covering test.
```

Substitua por:

```markdown
3. Re-run the verification instrument the criterion's class names. For
   `behavioral`, search for the covering test the same way, open it, and
   confirm it asserts the criterion's behavior — a test that never fails if
   the behavior breaks is not a covering test. For `structural`, run the
   read-only validator or open the located ranges. For `negative`, run the
   read-only command over the declared scope. **Report what you ran and what
   it returned**, never that it looked right.
```

Os passos 1, 2 e 4 ficam intactos: buscar o comportamento, abrir e ler, e só
então escrever a row valem para as três classes.

- [ ] **Step 10: A introdução e as racionalizações (T8.11)**

Duas pontas do arquivo, e nenhuma delas é a tabela.

`skills/final-branch-audit/SKILL.md:10` promete um relatório *"with `file:line`
citations the auditor located itself"*. Troque o trecho por:

```markdown
with evidence the auditor located and re-ran itself
```

E na tabela de racionalizações, `skills/final-branch-audit/SKILL.md:363-364`:

```markdown
| "I can see the feature works, that's evidence enough" | Evidence is what you located and re-ran. "I can see it" is the exact judgment the audit exists to replace. |
| "The implementation is there, the test is obvious" | For a `behavioral` criterion, untested is undelivered: write the row as NOT DELIVERED and let the fix wave add the test. For the other two classes the question is different — did you re-run the instrument the class names? |
```

**Uma tabela de racionalizações que ainda diz "Evidence is `file:line`" ensina o
auditor a recusar exatamente a evidência que o modelo passou a admitir** — e ela
é a última coisa que ele lê antes de escrever o relatório.

- [ ] **Step 11: As rows de task review e re-review em review-scopes (T8.12)**

`docs/review-scopes.md:12` descreve o que o task reviewer roda: *"The **task's**
test command, `[TEST_COMMAND]`, reported verbatim"*. Troque a célula por:

```markdown
The verification instrument each criterion names — the task's test command, `[TEST_COMMAND]`, reported verbatim where a `behavioral` criterion requires one; the read-only validator or command otherwise
```

`docs/review-scopes.md:14` descreve o re-review: *"**Re-runs** what already ran,
reporting command, ..."*. Troque o início por:

```markdown
**Re-runs** what already ran — the test command where the fix touched a `behavioral` criterion, the criterion's own read-only instrument otherwise — reporting
```

**Duas referências de seção deste arquivo pertencem à Task 13, e não a esta —
uma delas na primeira coluna da row que este step acabou de editar.** A row do
re-review referencia `section "Tests — Run Them Yourself"` na coluna do arquivo,
e a tabela de rótulos mais abaixo referencia `section "Test Run"`, ambas de
`re-review-prompt.md`; a Task 13 renomeia as duas seções. Este step muda a coluna
que **descreve** o que a face roda; a coluna que **aponta** para a seção fica
para lá. **Não a toque aqui.** Consertar a referência antes do rename existir reprova
`scripts/check-links.sh` no commit desta task, porque o título novo ainda não
está no arquivo apontado. Quem as ajusta é o Step 3 da Task 13, no mesmo commit
que renomeia — é a única ordem em que o gate fica verde nos dois commits.

- [ ] **Step 12: Verificar T8.1 e T8.7 pela contagem**

```bash
grep -c 'Criterion . Delivery evidence . Verification evidence' skills/final-branch-audit/SKILL.md
grep -c 'Implementation | Test | Verdict' skills/final-branch-audit/SKILL.md
grep -c 'no located citation is NOT DELIVERED' skills/final-branch-audit/SKILL.md
grep -c 'Implementation cited, no covering test' skills/final-branch-audit/SKILL.md
grep -c 'Evidence is `file:line`' skills/final-branch-audit/SKILL.md
grep -c 'Search for the covering test the same way' skills/final-branch-audit/SKILL.md
grep -c 'behavioral' skills/final-branch-audit/SKILL.md
```

Expected: `2`, `0`, `0`, `0`, `0`, `0` e **um número maior que zero** no último.
**O primeiro conta a row de cabeçalho inteira, não a frase `Delivery evidence`
solta:** o Step 7 instala uma terceira ocorrência dessa frase na definição das
colunas, e um `grep` pela frase devolveria `3` numa execução correta. **Os `.`
no lugar dos pipes são semântica de `grep`, não escapamento visual** — cada um
casa o `|` real da row de cabeçalho, e o padrão continua específico: medido, ele
devolve `0` contra a linha da definição das colunas, que não tem `Criterion`
antes.
O terceiro é T8.7, o quarto T8.9, o quinto T8.11 e o sexto T8.10. **`grep -c`
imprime `0` e sai com status 1**, então leia o número e não o status.

**O último grep é a metade positiva, e sem ele os cinco zeros não provam nada:**
apagar as regras antigas sem escrever as novas produz exatamente a mesma
saída. `behavioral` só aparece neste arquivo depois que os Steps 1 e 7 a 10
entram.

**Um `2` na primeira e um `1` na segunda significa que só a ocorrência não
indentada foi trocada** — que é exatamente o erro que AC16 nomeia.

- [ ] **Step 13: Verificar o teto, os links e a forma da linha de evidência**

```bash
scripts/check-skill-size.sh
scripts/check-links.sh
scripts/check-evidence-line.sh
```

Expected: exit 0 nos três. `final-branch-audit/SKILL.md` estava em 372 linhas.

- [ ] **Step 14: Conferir e commitar**

```bash
git diff --stat
git add skills/final-branch-audit/SKILL.md docs/review-scopes.md CHANGELOG.md
git commit -m "feat: o audit verdicta por evidence class e reexecuta o instrumento"
```

---

### Task 9: O task reviewer verifica por classe

**Spec criterion:** AC22, AC28, AC29, AC42, AC45, AC47; IR3, IR4

**Files:**
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:126-141`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:183-197`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:234-236`
- Modify: `docs/review-scopes.md:27`
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
- T9.5: `[TEST_COMMAND]` é exigido quando a task carrega critério `behavioral` cujo verification instrument é um teste — instrumento na matriz
- T9.6: task só `structural` ou `negative` não recebe test command e não tem nenhum inventado para ela — instrumento na matriz
- T9.7: `docs/review-scopes.md` acompanha o rename de seção que **esta** task provoca, e `scripts/check-links.sh` continua verde — instrumento na matriz
- T9.8: a linha de propósito do prompt deixa de declarar que o reviewer re-roda os testes da task incondicionalmente — instrumento na matriz

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
`skills/subagent-driven-development/task-reviewer-prompt.md:183-197`, vira:

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

**A seção é nomeada duas vezes no arquivo, e renomear só uma deixa a segunda
apontando para nada.** `skills/subagent-driven-development/task-reviewer-prompt.md:250`
fecha com *"**Reviewer returns:** Spec Compliance verdict (✅/❌/⚠️), Test
Evidence table"*. Troque `Test Evidence table` por `Verification Evidence table`
ali também.

- [ ] **Step 4: Tornar `[TEST_COMMAND]` condicional (T9.5, T9.6)**

`skills/subagent-driven-development/task-reviewer-prompt.md:234-236` hoje diz:

```markdown
- `[TEST_COMMAND]` — REQUIRED: the command that runs this task's tests, taken
  from the plan's Test Coverage Matrix or the repository's runner config. The
  reviewer runs it; do not pass a command you have not confirmed exists
```

**A lista de placeholders é carrier próprio do contrato**, e a Task 10 torna o
campo condicional no arquivo vizinho. Deixar `REQUIRED` aqui faz os dois
arquivos dizerem coisas incompatíveis sobre o mesmo campo. Substitua por:

```markdown
- `[TEST_COMMAND]` — REQUIRED **only when the task carries a `behavioral`
  criterion whose verification instrument is a test**: the command that runs
  those tests, taken from the plan's Verification Matrix or the repository's
  runner config. The reviewer runs it; do not pass a command you have not
  confirmed exists. **A task whose criteria are all `structural` or `negative`
  has no admissible value for this field — leave it out, and never derive one.**
  An invented runner turns a task that asked for no test into a task graded on
  one.
```

E no item de `[BASE_TEST_COUNT]`, logo abaixo, acrescente ao fim da primeira
frase: `— under the same condition as \`[TEST_COMMAND]\`, since a task that runs
no tests has none to lose`.

**As duas metades são critérios separados de propósito.** T9.5 é a exigência que
sobrevive; T9.6 é a proibição que entra. Uma redação que dissesse só "é opcional"
satisfaria T9.5 e deixaria T9.6 sem nada: *opcional* permite ao controller passar
um comando inventado, que é exatamente o que
`skills/subagent-driven-development/SKILL.md:273-274` já proíbe pelo outro lado.

- [ ] **Step 5: Acompanhar o rename em `docs/review-scopes.md` (T9.7)**

**O rename do Step 3 quebra uma referência um arquivo adiante.**
`docs/review-scopes.md:27` carrega a forma canônica — um markdown link para
`task-reviewer-prompt.md` seguido de vírgula e da palavra *section* com o título
`Test Evidence` entre aspas — e `scripts/check-links.sh` resolve o **título da
seção**, não só o caminho. Medido:
depois do rename ele imprime `no heading matching section "Test Evidence"` e sai
1, onde saía 0. Troque o título ali para `Verification Evidence`.

Este é o terceiro portador do mesmo rename, e ele mora fora do arquivo que a
task edita. Os outros dois são `### Test Evidence` e a linha
`**Reviewer returns:**`, ambos no Step 3.

- [ ] **Step 6: A linha de propósito (T9.8)**

`skills/subagent-driven-development/task-reviewer-prompt.md:3-5` abre o arquivo
declarando o que o reviewer faz:

```markdown
Use this template when dispatching a task reviewer subagent. The reviewer
reads the task's diff once, re-runs the task's tests, and returns two
verdicts: spec compliance and code quality.
```

Substitua a frase do meio por:

```markdown
reads the task's diff once, re-runs the verification instrument each criterion
names, and returns two verdicts: spec compliance and code quality.
```

É a primeira frase do arquivo e a única que o controller lê antes de despachar.
Deixá-la universal contradiz o protocolo por classe que o Step 1 instala.

- [ ] **Step 7: Verificar**

```bash
scripts/check-evidence-line.sh
scripts/check-links.sh
grep -c '| BLOCKING |' skills/subagent-driven-development/task-reviewer-prompt.md
grep -c 'REQUIRED: the command that runs' skills/subagent-driven-development/task-reviewer-prompt.md
grep -c 'has no admissible value for this field' skills/subagent-driven-development/task-reviewer-prompt.md
```

**Os dois últimos são T9.5 e T9.6, e é preciso os dois porque cada um pega
metade do defeito.** Expected: `0` no quarto — a declaração universal de
`REQUIRED` saiu — e `1` no quinto — a proibição para task só `structural` ou
`negative` entrou. **Um `0` no quarto com `0` no quinto significa que o campo
virou apenas opcional**, que satisfaz T9.5 e deixa T9.6 sem nada: opcional
permite ao controller inventar um comando. `grep -c` imprime o número e sai com
status 1 quando ele é `0`; leia o número.

Expected para os três primeiros: exit 0 nos dois primeiros, e **`4`** no terceiro — uma por row da
tabela do litmus, medido em 04/09/2026. **Um `grep` pelo título da seção não
serve de instrumento aqui:** a expressão *shallow-test litmus* aparece uma vez
só, e apagar as quatro rows da tabela deixaria a contagem intacta. T9.3 alega que
o litmus fica preservado; o que prova isso é o número de rows, não o título
sobreviver.

- [ ] **Step 8: Conferir e commitar**

```bash
git diff --stat
git add skills/subagent-driven-development/task-reviewer-prompt.md \
        docs/review-scopes.md CHANGELOG.md
git commit -m "feat: o task reviewer reexecuta o instrumento que a classe pede"
```

---

### Task 10: O controller para de derivar comando de teste universal

**Spec criterion:** AC32, AC45

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md:270-276`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: a Verification Matrix da Task 6 e o protocolo por classe da Task 9.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T10.1: o controller entrega ao reviewer os verification instruments da task, exige comando de teste e base test count apenas quando a task tem critério `behavioral`, e nunca inventa runner para satisfazer task `structural` ou `negative` — instrumento na matriz
- T10.2: a instrução de entregar ao reviewer o test command e o base count vira condicional à classe — instrumento na matriz
- T10.3: o fix loop deixa de exigir covering tests de toda fix round, e a condição de despacho do re-review segue a classe — instrumento na matriz

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
  instead of the task. Scope it to the task's tests where the runner allows; the
  full suite is the fallback. **A task with no `behavioral` criterion has no
  admissible value for this field — leave it out.** Deriving one anyway is how a
  `structural` task acquires a test nobody asked for.
- **`[BASE_TEST_COUNT]`:** same condition — it exists to show whether tests
  disappeared, and a task that runs no tests has none to lose. When the task
  does carry `behavioral` criteria and no total is available, pass `unknown` and
  say why: the reviewer falls back to reading the diff for tests deleted,
  renamed away, or newly skipped.
```

**Duas frases do texto atual sobrevivem, e nenhum `AC` pede que saiam:** o
*"Scope it to the task's tests where the runner allows; the full suite is the
fallback"* de `[TEST_COMMAND]`, e o fallback de `[BASE_TEST_COUNT]` para
`unknown`, que está acima. Uma substituição que as apagasse seria perda
silenciosa de conteúdo — a mesma coisa que a `writing-plans` chama de escopo
inventado, do lado da remoção.

**MARCADO na revisão de branch, 04/09/2026 — o Step 1 acima diverge do que foi
entregue.** `[VERIFICATION_INSTRUMENTS]` foi escrito como campo próprio aqui e na
lista de placeholders da Task 13, e nenhuma das duas tasks escreveu o sítio de
substituição no corpo de template nenhum: o token aparecia zero vezes em
`task-reviewer-prompt.md` e, no `re-review-prompt.md`, só depois de
`**Placeholders:**`. Era instrução que o controller não conseguia executar. Na
rodada de correção o campo saiu dos dois carriers e o que ficou escrito é o que
de facto acontece — os instrumentos viajam no brief, que já carrega classe e
instrumento por critério. **O registro do que foi executado não se reescreve; se
marca**, e é o que esta nota faz. AC32 continua entregue: o controller entrega os
instrumentos, pelo brief que ele mesmo passa.

- [ ] **Step 2: A instrução de entregar test command e base count (T10.2)**

`skills/subagent-driven-development/SKILL.md:292-295` diz, sem condição:

```markdown
- The reviewer re-runs the task's tests itself. The implementer's report is
  a claim about a run nobody else watched, written by the author of the
  tests being judged — it is not test evidence. Hand the reviewer the test
  command and the base count, never a "tests already ran" note
```

Substitua por:

```markdown
- The reviewer re-runs the task's verification instruments itself. The
  implementer's report is a claim about a run nobody else watched, written by
  the author of what is being judged — it is not evidence. Hand the reviewer
  the instruments from the plan's Verification Matrix, and, **where the task
  carries a `behavioral` criterion**, the test command and the base count.
  Never a "tests already ran" note, and never a command derived for a task
  that asked for none
```

- [ ] **Step 3: O fix loop e a condição de despacho do re-review (T10.3)**

`skills/subagent-driven-development/SKILL.md:349-355` hoje diz:

```markdown
**Every round, either way:** the implementer fixes, re-runs the tests
covering the amended code, appends its fix report to the same report file,
and returns the short contract. Before re-dispatching the reviewer, confirm
the fix report contains the covering tests, the command run, and the
output; dispatch the re-review once all three are present. Name the
covering test files in the fix message — a one-line fix does not need the
whole suite.
```

**Esta é a linha que trava o loop hoje:** uma task só `structural` ou `negative`
nunca reúne os três campos, então o re-review nunca é despachado. Substitua por:

```markdown
**Every round, either way:** the implementer fixes, re-runs the verification
instrument each amended criterion names, appends its fix report to the same
report file, and returns the short contract. Before re-dispatching the
reviewer, confirm the fix report contains, for every criterion it touched, the
instrument re-run and its result — the covering tests, the command and the
output where the criterion is `behavioral`; the read-only check or the located
range otherwise. Dispatch the re-review once each touched criterion has one.
Name the covering test files in the fix message where there are tests — a
one-line fix does not need the whole suite.
```

- [ ] **Step 4: Verificar o teto**

```bash
scripts/check-skill-size.sh
```

Expected: exit 0. `subagent-driven-development/SKILL.md` estava em 468 linhas,
com 32 de folga. Se disparar, o excedente vai para
`skills/subagent-driven-development/references/`, com o ponteiro no lugar de onde
saiu.

- [ ] **Step 5: Conferir e commitar**

```bash
git diff --stat
git add skills/subagent-driven-development/SKILL.md CHANGELOG.md
git commit -m "feat: o comando de teste so e exigido de task com criterio behavioral"
```

---

### Task 11: O preflight do caminho inline

**Spec criterion:** AC33

**Files:**
- Modify: `skills/executing-plans/SKILL.md:110-114`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o bloco de task da Task 6.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T11.1: o preflight exige evidence class declarada e instrumento admissível capaz de resolver a claim; para `behavioral` isso inclui o covering test, e ausência de teste em `structural` ou `negative` deixa de ser motivo de escalação — instrumento na matriz

- [ ] **Step 1: Substituir o item 7 do preflight**

`skills/executing-plans/SKILL.md:110-114` hoje diz:

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

Os pontos de inserção são estes dois, e eles se correspondem — cada um é a
frase em que o prompt exige `file:line` de **todo** achado:

- `skills/requesting-code-review/code-reviewer.md:147`, o item
  `- Be specific (file:line, not vague)` da lista `**DO:**`. Acrescente o
  parágrafo logo abaixo da lista.
- `skills/subagent-driven-development/re-review-prompt.md:82`, dentro de
  `## Output Format`: *"Every line is a verdict, a finding with file:line, or a
  check you ran"*. Acrescente o parágrafo logo abaixo dele.

As demais ocorrências de `file:line` nos dois arquivos falam de uma citação
concreta que precisa conferir, não da forma exigida de todo achado, e **ficam
como estão**. Em cada um dos dois pontos acima, acrescente:

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

### Task 13: O fix loop e o re-review por evidence class

**Spec criterion:** AC45, AC47; IR3

**Files:**
- Modify: `skills/subagent-driven-development/re-review-prompt.md` — quatro
  regiões, **nomeadas por seção e por texto, nunca por linha**, porque a Task 12
  edita este arquivo antes: o heading `## Tests — Run Them Yourself` e o
  parágrafo abaixo dele; o bloco `### Test Run` dentro de `## Output Format`; os
  itens `[TEST_COMMAND]` e `[BASE_TEST_COUNT]` da lista de placeholders; e a
  linha `**Reviewer returns:**` do fecho
- Modify: `docs/review-scopes.md:14`
- Modify: `docs/review-scopes.md:28`
- Modify: `skills/subagent-driven-development/implementer-prompt.md:161-165`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: a Verification Matrix da Task 6, o protocolo por classe da Task 9 e a
  condição de despacho que a Task 10 instala em
  `subagent-driven-development/SKILL.md`.
- Produces: nada que outra task consuma.

**Task nova, e a razão é uma só.** `implementer-prompt.md` não é editado por
nenhuma outra task deste plano, e `re-review-prompt.md` é editado pela Task 12
para um problema independente — achado transversal carregando command evidence,
que é AC23. Juntar as duas coisas num commit misturaria dois problemas no mesmo
arquivo.

**Nenhum step desta task localiza por número de linha em `re-review-prompt.md`.**
A Task 12 edita o mesmo arquivo e roda antes: ela insere oito linhas dentro de
`## Output Format`, e todo número contado antes dela envelhece por oito no
momento em que esta task executa. **Cada step aqui cita o texto verbatim que
substitui, mais a seção que o contém** — é o que um implementer novo, que nunca
viu a Task 12 rodar, precisa para achar exatamente uma ocorrência. Os ranges no
bloco `**Files:**` são navegação e nada mais, na forma que
`skills/writing-plans/SKILL.md` fixa: a auditoria resolve a evidência contra
`HEAD`, nunca contra o que o plano escreveu.

**O que esta task NÃO toca:** `skills/subagent-driven-development/implementer-prompt.md:51`,
o Iron Law do TDD. A distinção é entre *o implementer deve usar TDD*, que é
decisão fora desta fatia, e *o loop de review consegue verificar uma task
não-`behavioral`*, que é este modelo e hoje não consegue.

**Acceptance criteria:**
- T13.1: a seção de testes e os placeholders de `re-review-prompt.md` exigem test command e base count apenas quando a fix round toca critério `behavioral` — instrumento na matriz
- T13.2: a seção de saída e o contrato de retorno de `re-review-prompt.md` reportam o verification instrument da classe, preservando `Command`/`exit`/`counts` onde há teste — instrumento na matriz
- T13.3: o contrato do fix report em `implementer-prompt.md` exige os instrumentos aplicáveis à task, não covering tests em toda fix round — instrumento na matriz
- T13.4: `scripts/check-evidence-line.sh` continua verde — instrumento na matriz
- T13.5: as duas referências de seção que os renames desta task quebram são ajustadas no mesmo commit, e `scripts/check-links.sh` continua verde — instrumento na matriz

- [ ] **Step 1: Tornar a seção de testes condicional (T13.1)**

Em `skills/subagent-driven-development/re-review-prompt.md`, o heading
`## Tests — Run Them Yourself` e o parágrafo imediatamente abaixo dele, que hoje
manda, sem condição:

```markdown
    The implementer appended its fix test run to the report file. That is a
    claim about a run you did not watch, written by the author of the tests.
    Re-run them: `[TEST_COMMAND]`. Report the command verbatim, its exit
    code, and the counts (passed / failed / skipped).
```

Substitua o título por `## Verify the Fix by Its Instruments` e o parágrafo por:

```markdown
    Each finding under verification belongs to a task criterion with a
    declared evidence class, and you re-run the instrument that class names.

    **When the fix touches a `behavioral` criterion**, the implementer
    appended its test run to the report file. That is a claim about a run you
    did not watch, written by the author of the tests. Re-run them:
    `[TEST_COMMAND]`. Report the command verbatim, its exit code, and the
    counts (passed / failed / skipped), and compare against
    `[BASE_TEST_COUNT]`.

    **When the task carries no `behavioral` criterion**, there is no test
    command and none is derived. Re-run the read-only validator or command the
    criterion names, or reopen the located range, and report what you ran and
    what it returned. **A task verified this way is not a task verified less:**
    inventing a runner to fill the section would report a pass about something
    nobody asked to be built.
```

O parágrafo seguinte, sobre contagem que caiu e teste apagado, ganha a mesma
condição na primeira frase: ele fala de `[BASE_TEST_COUNT]`, que só existe onde
há teste. O parágrafo `Stay read-only` fica intocado — vale para as três classes.

- [ ] **Step 2: Generalizar a seção de saída e o contrato de retorno (T13.2)**

Em `skills/subagent-driven-development/re-review-prompt.md`, **dentro da seção
`## Output Format`**, o bloco que hoje diz:

```markdown
    ### Test Run

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] (previous: [BASE_TEST_COUNT])
```

vira:

```markdown
    ### Verification Run

    **Command:** [verbatim] — **exit:** [code] — **counts:** [passed/failed/
    skipped] (previous: [BASE_TEST_COUNT])

    One line per instrument you re-ran. For a `behavioral` criterion the
    command is the test command and the counts are test counts; for
    `structural` and `negative` it is the read-only validator or command, and
    `counts:` reads `—`. A criterion settled by a located range carries the
    range here instead of a command.
```

**A linha `**Command:** … **exit:** … **counts:** …` fica byte a byte como
está**: `scripts/check-evidence-line.sh:17-19` lê nomes de campo e nunca o
conteúdo — *"It reads field names, never their content"* — então `**counts:** —`
satisfaz o gate. É o instrumento de T13.4.

E a linha que abre com `**Re-reviewer returns:**` — **a única do arquivo**, no
bloco de fecho depois dos placeholders — hoje diz:

```markdown
**Re-reviewer returns:** its own test run (command, exit code, counts),
```

e vira:

```markdown
**Re-reviewer returns:** its own verification run (the instrument re-run for
each criterion, with command, exit code and counts where a test applies),
per-finding verdicts (ADDRESSED / NOT ADDRESSED, or CONFIRMED / WITHDRAWN
for a disputed finding), new breakage in the fix diff, out-of-scope
observations, and a round verdict.
```

- [ ] **Step 3: Ajustar as referências que os renames quebram (T13.5)**

**Os Steps 1 e 2 renomearam duas seções, e `docs/review-scopes.md` aponta para
as duas pelo título.** `scripts/check-links.sh` resolve o título, não só o
caminho: sem este step, o commit desta task sai vermelho. Medido num clone
descartável aplicando só os Steps 1 e 2:

```
docs/review-scopes.md:14: re-review-prompt.md -> no heading matching section "Tests — Run Them Yourself"
docs/review-scopes.md:28: re-review-prompt.md -> no heading matching section "Test Run"
exit=1
```

Em `docs/review-scopes.md` há **exatamente uma** ocorrência de cada uma das duas
referências, e é por elas que se localiza — a Task 8 edita este mesmo arquivo
antes desta, na **outra coluna** das mesmas rows, então número de linha aqui é
localizador que envelhece:

- a referência que aponta para `re-review-prompt.md` e termina em
  `section "Tests — Run Them Yourself"` passa a terminar em
  `section "Verify the Fix by Its Instruments"`;
- a referência que aponta para `re-review-prompt.md` e termina em
  `section "Test Run"` passa a terminar em `section "Verification Run"`.

**As duas precisam do arquivo-alvo para serem únicas, e é por isso que ele está
escrito nas duas.** Cada um dos dois títulos aparece **duas** vezes neste
arquivo: `Tests — Run Them Yourself` também referencia `task-reviewer-prompt.md`,
cuja seção a Task 9 preserva com o mesmo nome; e `Test Run` também referencia
`code-reviewer.md`, cujo revisor continua reportando um test run. **Nenhuma das
duas outras muda** — trocar por título sem olhar o alvo quebraria as duas.

**Este step mora aqui e não na Task 8, que edita o mesmo arquivo.** A Task 8 roda
antes; ajustar a referência lá apontaria para um título que ainda não existe, e o
gate reprovaria o commit dela. **O ajuste e o rename têm de sair no mesmo
commit**, e este é o único ponto do plano em que isso acontece.

- [ ] **Step 4: Tornar os placeholders condicionais (T13.1)**

Na lista de placeholders ao fim de
`skills/subagent-driven-development/re-review-prompt.md`, os dois primeiros itens
hoje dizem:

```markdown
- `[TEST_COMMAND]` — REQUIRED: the same command the task review ran, so the
  two runs compare; the re-reviewer runs it itself
- `[BASE_TEST_COUNT]` — the counts the previous review reported. Pass
  `unknown` when there are none, and expect the delta to come from the diff.
```

Substitua as duas primeiras linhas por:

```markdown
- `[TEST_COMMAND]` — REQUIRED **only when the fix round touches a
  `behavioral` criterion**: the same command the task review ran, so the two
  runs compare; the re-reviewer runs it itself. **A task whose criteria are all
  `structural` or `negative` has no admissible value for this field — leave it
  out.** The task review had none either, and deriving one here would invent a
  runner two faces after the plan declined to ask for one.
- `[VERIFICATION_INSTRUMENTS]` — the instrument each criterion under
  verification names, copied from the plan's Verification Matrix with its
  evidence class. This is what the re-reviewer re-runs when there is no test.
```

E a linha de `[BASE_TEST_COUNT]` ganha, no início, `under the same condition as
`[TEST_COMMAND]`,`.

- [ ] **Step 5: O contrato do fix report (T13.3)**

`skills/subagent-driven-development/implementer-prompt.md:161-165` hoje diz:

```markdown
    Fix the rest, re-run the tests that cover the amended code, and append a
    fix report to your report file: what you changed, every finding you
    DISPUTED with its citation, the covering tests you ran, the command, and
    the output. The re-reviewer runs that same command itself — your report
    exists so the two runs can be compared, not to stand in for theirs.
```

Substitua por:

```markdown
    Fix the rest, re-run the verification instrument each amended criterion
    names — the covering tests for a `behavioral` criterion, the read-only
    validator or command for a `structural` or `negative` one — and append a
    fix report to your report file: what you changed, every finding you
    DISPUTED with its citation, the instruments you re-ran, the command where
    there was one, and the output. The re-reviewer runs the same instruments
    itself — your report exists so the two runs can be compared, not to stand
    in for theirs.
```

**O Iron Law em `skills/subagent-driven-development/implementer-prompt.md:51` não
é tocado por este step nem por nenhum outro deste plano.** Ele governa como o
implementer escreve código; esta linha governa o que o fix report carrega para o
re-reviewer poder verificar.

- [ ] **Step 6: Verificar**

```bash
scripts/check-evidence-line.sh
scripts/check-links.sh
grep -c 'REQUIRED: the same command the task review ran' skills/subagent-driven-development/re-review-prompt.md
grep -c 'has no admissible value for this field' skills/subagent-driven-development/re-review-prompt.md
grep -n 'Step 1 is not conditional' skills/subagent-driven-development/implementer-prompt.md
```

Expected: exit 0 nos dois primeiros; `0` no terceiro — a exigência universal
saiu; `1` no quarto — a proibição entrou; e o quinto continua imprimindo a linha
`51`, provando que o Iron Law não foi tocado. **O par `0`/`0` nos dois greps do
meio significa que o campo virou apenas opcional**, o que não entrega T13.1.

- [ ] **Step 7: Conferir e commitar**

```bash
git diff --stat
```

```bash
git add skills/subagent-driven-development/re-review-prompt.md \
        skills/subagent-driven-development/implementer-prompt.md \
        docs/review-scopes.md CHANGELOG.md
git commit -m "feat: o fix loop e o re-review verificam pelo instrumento da classe"
```

---

### Task 14: A promessa pública

**Spec criterion:** AC24, AC25; IR7

**Files:**
- Modify: `docs/README.pt-BR.md:17`
- Modify: `docs/README.en.md:17`
- Modify: `README.md:5`

**Interfaces:**
- Consumes: o vocabulário do documento da Task 1.
- Produces: nada que outra task consuma.

**Acceptance criteria:**
- T14.1: `docs/README.pt-BR.md`, canônico, descreve a promessa como evidência que casa com a afirmação, e `docs/README.en.md` traduz a mesma mudança no mesmo commit — instrumento na matriz
- T14.2: `README.md` descreve a promessa como evidência inspecionável que casa com a afirmação, e deixa de prometer `file:line` como forma universal — instrumento na matriz
- T14.3: `scripts/check-docs-sync.sh` continua verde — instrumento na matriz

- [ ] **Step 1: A referência canônica (T14.1)**

`docs/README.pt-BR.md:17` hoje promete *"Toda afirmação que o agente faz sobre o
seu código exige uma citação `arquivo:linha`"*. Substitua a frase por:

```markdown
Toda afirmação que o agente faz sobre o seu código exige evidência que case com a afirmação — um trecho localizado quando existe linha que a prove, uma verificação executável quando a afirmação é sobre um conjunto ou sobre uma ausência, uma fonte fundamentada quando o que se afirma é garantia de uma dependência. E quem verifica reexecuta em vez de aceitar a palavra de quem escreveu.
```

Traduza a mesma mudança em `docs/README.en.md:17`, **no mesmo commit**.

- [ ] **Step 2: O showcase (T14.2)**

`README.md:5` hoje diz *"every claim the agent makes about your code carries a
`file:line` citation"*. Substitua por:

```markdown
A development methodology for coding agents, where every claim the agent makes about your code carries inspectable evidence that fits the claim — a located range, an executable check, or a grounded source — and whoever verifies re-runs it instead of taking the writer's word for it.
```

Revise também as linhas 102, 112 e 118, que descrevem o reviewer e a auditoria
abrindo *"every `file:line`"*. **A redação diverge da referência de propósito**,
como já é o caso: `docs/docs-and-links.md` registra que os três arquivos
respondem perguntas diferentes.

- [ ] **Step 3: Verificar os links**

```bash
scripts/check-links.sh
```

Expected: exit 0.

- [ ] **Step 4: Stagear e só então verificar T14.3**

**`scripts/check-docs-sync.sh:17` lê `git diff --cached`**, e sobre um índice
vazio ele acha zero dos dois arquivos, conclui que estão de acordo e sai 0.
Rodá-lo antes do `git add` passa qualquer que seja a verdade — é instrumento
vazio. Stageie primeiro:

```bash
git add README.md docs/README.pt-BR.md docs/README.en.md
git diff --cached --stat
scripts/check-docs-sync.sh
```

Expected: três arquivos no índice e exit 0. **Para provar que o instrumento
discrimina**, tire um dos dois de `docs/` do índice e rode de novo:

```bash
git restore --staged docs/README.en.md
scripts/check-docs-sync.sh
```

Expected: **exit diferente de 0**. Restaure o índice com
`git add docs/README.en.md` antes de commitar.

- [ ] **Step 5: Commit**

Nenhum dos três arquivos está sob os caminhos que `scripts/check-changelog.sh`
cobra, então este commit não precisa de entrada.

```bash
git commit -m "docs: a promessa publica passa a ser evidencia que casa com a afirmacao"
```

---

### Task 15: O item de Open gaps e o fecho da branch

**Spec criterion:** AC26; IR1, IR5, IR6, IR8, IR9

**Files:**
- Modify: `CHANGELOG.md:5873` — o item abre ali, e a frase que o Step 1 substitui está em `CHANGELOG.md:5895-5897`

**Interfaces:**
- Consumes: todas as tasks anteriores — os cinco critérios negativos desta task
  são propriedades da branch inteira, e só há branch inteira depois da Task 14.
- Produces: nada. É a última task.

**Acceptance criteria:**
- T15.1: o item de `## Open gaps` deixa de afirmar que nenhum anchor foi achado podre, e registra os três regimes de frescor — instrumento na matriz
- T15.2: nenhum `SKILL.md` não isento excede 500 linhas — instrumento na matriz
- T15.3: nenhum gate novo passa a exigir fragmento literal em citação — instrumento na matriz
- T15.4: nenhum arquivo novo entra em `scripts/` nesta branch — instrumento na matriz
- T15.5: o anchor-fragment gate não foi construído nesta branch — instrumento na matriz
- T15.6: todo commit que toca `skills/`, `scripts/`, `githooks/`, `.github/` ou `hooks/` tem entrada de changelog — instrumento na matriz

- [ ] **Step 1: Reescrever o item de Open gaps (T15.1)**

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

- [ ] **Step 2: Verificar T15.2**

```bash
scripts/check-skill-size.sh
```

Expected: exit 0.

- [ ] **Step 3: Verificar T15.4 e T15.5**

```bash
git diff --diff-filter=A --name-only main...HEAD
```

Expected: nenhum caminho sob `scripts/`, e nenhum arquivo cujo nome ou conteúdo
implemente checagem de fragmento literal. Os únicos arquivos novos previstos
por este plano são `docs/evidence-model.md` e, se o teto de linhas tiver
disparado, um ou mais arquivos sob `references/`.

- [ ] **Step 4: Verificar T15.3**

```bash
git diff --name-only main...HEAD -- scripts/
```

Expected: nenhuma saída. Se algum arquivo de `scripts/` aparecer, abra o diff e
confirme que ele não passou a exigir fragmento literal em citação — IR5 é sobre
o contrato do gate, não sobre o arquivo existir.

- [ ] **Step 5: Verificar T15.6, commit a commit**

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

---

### Task 16: O modo de compatibilidade resolve-se no boundary

**Spec criterion:** AC48

**Task acrescentada depois da execução das quinze anteriores**, autorizada pelo
parceiro no fecho da branch, a partir de um achado do review de branch inteira
que uma investigação read-only depois localizou. **Nenhuma task histórica é
reescrita para fingir que sempre conteve isto** — as quinze ficam como
executadas, e o boundary novo é esta.

**Files:**
- Modify: `skills/executing-plans/SKILL.md` — o Step 1, entre o item que lê a spec e o preflight
- Modify: `skills/subagent-driven-development/SKILL.md` — a instrução que lê a spec, e a condição de `[TEST_COMMAND]`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md` — a seção de verificação por classe
- Modify: `skills/subagent-driven-development/implementer-prompt.md` — o contrato do fix report
- Modify: `skills/subagent-driven-development/re-review-prompt.md` — a seção de verificação do fix
- Modify: `docs/evidence-model.md` — o conceito ampliado e a tabela de decisão
- Create: `tests/compatibility-mode/run-tests.sh` e `tests/compatibility-mode/fixtures/`
- Modify: `.github/workflows/ci.yml`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o marcador da Task 4, a Verification Matrix da Task 6, o protocolo
  por classe da Task 9 e a condição de despacho da Task 10.
- Produces: nada que outra task consuma. É a última.

**A medição que decidiu o boundary**, e que a redação abaixo pressupõe:
`skills/subagent-driven-development/scripts/task-brief:52-59` extrai **só o bloco
da task** — sem cabeçalho de plano, sem matriz —, e
`skills/subagent-driven-development/SKILL.md:210` proíbe por escrito dar o plano
inteiro ao subagente. Os três prompts **não têm de onde inferir** o modo. Só os
dois controllers e a auditoria final leem a source spec, e os dois controllers já
são obrigados a lê-la. Por isso a decisão mora neles e desce resolvida.

**Acceptance criteria:**
- T16.1: os dois controllers resolvem o modo a partir da source spec antes de executar — `[structural]`, instrumento na matriz
- T16.2: no modo v2 a classe é obrigatória e a ausência bloqueia antes do dispatch — `[structural]`, instrumento na matriz
- T16.3: no modo legacy a classe efetiva é `behavioral`, a derivação pré-v2 de test command é preservada onde existia, e nenhum comando é inventado — `[structural]`, instrumento na matriz
- T16.4: plano sem source spec mantém o entry blocker e só entra em legacy depois de confirmado — `[structural]`, instrumento na matriz
- T16.5: a autoridade é a source spec — v2 com matriz histórica bloqueia, legacy com Verification Matrix não — `[structural]`, instrumento na matriz
- T16.6: os três prompts consomem a decisão com cláusula idêntica, sem abrir spec nem plano e sem quarta classe — `[structural]`, instrumento na matriz
- T16.7: o documento canônico carrega o conceito ampliado e a tabela dos doze casos — `[structural]`, instrumento na matriz
- T16.8: os doze casos têm verificação determinística, e a regra do blocking mismatch está declarada onde os dois controllers apontam — `[structural]`, instrumento na matriz
- T16.9: nenhum plano ou spec histórico é modificado — `[negative]`, instrumento na matriz
- T16.10: a suíte nova tem step de CI — `[structural]`, instrumento na matriz

**T16.8 é `structural`, não `behavioral`, e a distinção é a que AC38 fixa.** Lá a
classe é `behavioral` *"porque o sujeito é um programa determinístico com suíte
automatizada, não um agente"*. Aqui não há programa sob teste: `run-tests.sh`
inspeciona prosa em markdown — fixtures e carriers —, e quem resolve o modo é um
agente lendo `SKILL.md`. A exceção de AC38 não alcança este caso, então vale a
regra geral de `## The model`: *"the protocol defines/requires" é `structural`*.
AC48, o critério de spec que esta task serve, já é `[structural]`. **A classe foi
corrigida na task review, não no fecho**: o instrumento anterior nomeava uma
regra — *blocking mismatch* — que o corpo da asserção não media, o que é o
defeito que este modelo existe para separar.

- [ ] **Step 1: O bloco de resolução no caminho inline**

Em `skills/executing-plans/SKILL.md`, no `### Step 1: Load and Review Plan`,
insira um item novo **entre** o item 5 (que lê a spec) e o item 6, renumerando os
seguintes:

```markdown
6. **Resolve the compatibility mode, once, before anything else reads the
   plan.** The spec you just opened is the authority — never the plan's matrix
   schema:
   - Header carries `**Evidence model:** v2` → **v2 mode.** Every criterion
     declares an evidence class, and one that does not is an error you take
     back to the plan before executing, never a class you assign yourself. A
     plan in this mode still carrying the historical `## Test Coverage Matrix`
     is a blocking mismatch: the spec moved and the plan did not.
   - Header carries no marker → **legacy mode.** The spec predates the model:
     every criterion's effective class is `behavioral` and its verdict is the
     one it would have had before the model existed. **This does not repair the
     plan** — a criterion the old rules could not verify stays unverifiable.
     The mode exists so the model introduces no NEW regression on it. The
     plan's schema does not change this: a plan written today from a legacy
     spec carries the Verification Matrix with `behavioral` in every class
     cell, which superpowersplus:writing-plans requires and which is **not** a
     mismatch.
   - **No spec at all** → the entry blocker above stands. Never conclude legacy
     from silence: get the path from your human partner, and only once they
     confirm no spec exists is the plan treated as legacy.
```

- [ ] **Step 2: O preflight consome o modo**

No mesmo arquivo, o item que hoje começa `7. Check every task carries acceptance
criteria with a declared evidence class` (e que a renumeração torna 8) ganha, ao
fim:

```markdown
   **In legacy mode this check does not apply** — no criterion declares a class,
   and that is the mode you resolved above, not a concern to raise.
```

- [ ] **Step 3: O bloco de resolução no controller SDD**

Em `skills/subagent-driven-development/SKILL.md`, imediatamente depois do
parágrafo que manda ler a spec (*"Read the spec the plan cites in its
`**Source spec:**` header line…"*), insira o mesmo bloco de resolução, na forma
de parágrafo:

```markdown
**Resolve the compatibility mode from that spec, once, before dispatching Task
1.** The spec is the authority — never the plan's matrix schema. Marker
`**Evidence model:** v2` → **v2 mode**: every criterion declares a class, one
that does not is an error you take back to the plan rather than a class you
assign, and a plan still carrying the historical `## Test Coverage Matrix` is a
blocking mismatch. No marker → **legacy mode**: effective class `behavioral` on
every criterion, verdicts as they would have been before the model. **Legacy
mode does not repair the plan** — a criterion the old rules could not verify
stays unverifiable; the mode exists so the model introduces no new regression.
A plan written today from a legacy spec carries the Verification Matrix with
`behavioral` in every class cell, and that is **not** a mismatch. No spec at
all → the entry blocker above stands, and only your partner's confirmation that
none exists makes the plan legacy.
```

- [ ] **Step 4: A regra de `[TEST_COMMAND]` no modo legacy**

No mesmo arquivo, o item `- **`[TEST_COMMAND]`:**` ganha, ao fim:

```markdown
  **In legacy mode, follow the pre-v2 derivation instead of this condition:**
  supply what the old flow would have supplied — the plan's matrix, failing that
  the runner config — and do not withhold it because no criterion declares
  `behavioral`. Equally, never invent one to turn a historical structural
  command into a test: where the old flow had none, this one has none.
```

- [ ] **Step 5: A cláusula de consumo, idêntica nos três prompts**

Em `task-reviewer-prompt.md`, `implementer-prompt.md` e `re-review-prompt.md`,
insira **o mesmo corpo, com a mesma indentação de quatro espaços** — é a forma
que este repositório já usa para conteúdo partilhado entre prompts, e que
`scripts/check-no-dispatch.sh` cobra por identidade em sete carriers:

```markdown
    **A brief that declares no evidence class comes from a plan written before
    this model.** Its criteria take the compatibility fallback: effective class
    `behavioral`, and the instrument is the test the criterion names. Apply it
    without checking anything else, because a task from a v2 plan with a missing
    class never reaches you — the controller resolves the mode from the source
    spec and blocks that case before dispatch. Do not open the source spec, do
    not open the plan, do not decide whether a document could be legacy, and do
    not recognise a fourth class.
```

Os pontos de inserção, um por arquivo: em `task-reviewer-prompt.md` ao fim da
seção `## Verify Each Criterion by Its Class`; em `re-review-prompt.md` ao fim da
seção `## Verify the Fix by Its Instruments`; em `implementer-prompt.md`
imediatamente depois do parágrafo do fix report que nomeia os instrumentos.

- [ ] **Step 6: O documento canônico**

Em `docs/evidence-model.md`, a seção `### Compatibility: legacy behavioral` ganha
o mesmo alcance que a spec passou a declarar — o fallback vale onde um artefato
legacy atravessa o fluxo, a decisão é tomada no boundary que possui a source
spec, os consumidores a jusante consomem —, mais os três esclarecimentos que a
medição forçou (autoridade da spec sobre o schema; `legacy behavioral` não
promove comando histórico a classe nova; plano sem spec mantém o entry blocker).
**Nenhuma seção `###` nova**: os treze conceitos continuam treze.

Acrescente ao fim da seção a tabela de decisão dos doze casos:

```markdown
| # | Source spec | Plan | Mode | What the controller supplies |
|---|---|---|---|---|
| 1 | legacy, cited | Test Coverage Matrix, a test id in the row | legacy | the pre-v2 test command |
| 2 | legacy, cited | Test Coverage Matrix, a read-only command in the `Test` cell | legacy | the pre-v2 test command where the old flow derived one; nothing invented, and the row keeps its historical limitation |
| 3 | legacy, cited | Verification Matrix, every class `behavioral` | legacy | the test command — the schema is not the authority |
| 4 | v2 | Verification Matrix, `behavioral` criteria | v2 | the test command |
| 5 | v2 | Verification Matrix, only `structural` and `negative` | v2 | no test command, and none derived |
| 6 | v2 | a criterion with no class | v2 | nothing — it blocks before dispatch |
| 7 | v2 | Test Coverage Matrix | v2 | nothing — blocking mismatch |
| 8 | none cited | any | undecided | nothing — the entry blocker stands, and silence is never legacy |
| 9 | confirmed not to exist | any | legacy | only the pre-existing fallbacks actually available |
| 10 | any | any | identical on both paths | inline and subagent resolve the same artifacts the same way |
| 11 | legacy, cited | a re-review of a legacy fix round | legacy | the test command the task review had; none invented where there was none |
| 12 | any | any | — | nothing is written: no historical plan or spec is modified while being read |
```

- [ ] **Step 7: As fixtures**

Crie `tests/compatibility-mode/fixtures/` com **duas specs e oito planos** — a
spec é a autoridade, e só o marcador dela importa, então os casos 1–3 partilham
a spec legacy e os casos 4–7 partilham a v2:

```bash
mkdir -p tests/compatibility-mode/fixtures
cat > tests/compatibility-mode/fixtures/spec-legacy.md <<'EOF'
# Legacy spec

**Route:** full process

## Acceptance Criteria

- **AC1** — the thing happens.
EOF
cat > tests/compatibility-mode/fixtures/spec-v2.md <<'EOF'
# V2 spec

**Route:** full process
**Evidence model:** v2

## Acceptance Criteria

- **AC1** `[behavioral]` — the thing happens.
EOF
```

Cada plano é mínimo e difere só na propriedade que o caso discrimina. O caso 8
não cita spec nenhuma; os demais citam uma das duas acima.

- [ ] **Step 8: A suíte**

Crie `tests/compatibility-mode/run-tests.sh`. Ela não despacha agente nenhum: o
que prova é que a tabela de decisão cobre os doze casos, que cada fixture **é** o
caso que diz ser, e que os cinco carriers carregam a cláusula que o resolve.
Carrier que perde a cláusula, fixture que deriva, ou quarta classe que aparece —
os três a deixam vermelha.

```bash
#!/usr/bin/env bash
# The twelve compatibility-mode cases docs/evidence-model.md enumerates,
# asserted against the fixtures that carry them and the carriers that resolve
# them. Deterministic: nothing here dispatches an agent.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FIX="$(dirname "$0")/fixtures"
pass=0; fail=0
ok()  { printf '  [PASS] %s\n' "$1"; pass=$((pass+1)); }
bad() { printf '  [FAIL] %s — %s\n' "$1" "$2"; fail=$((fail+1)); }
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1" "$3"; fi; }

echo "Testing compatibility mode"

# --- the decision table covers every case, and no more
rows=$(awk '/^\| # \| Source spec/{f=1;next} f&&/^\| [0-9]/{n++} f&&!/^\|/{exit} END{print n+0}' \
        "$ROOT/docs/evidence-model.md")
check "the decision table carries exactly twelve cases" \
  "[ \"$rows\" -eq 12 ]" "found $rows"

# --- each fixture is still the case it claims
check "a legacy spec carries no evidence-model marker" \
  "! grep -q 'Evidence model' $FIX/spec-legacy.md" "marker appeared"
check "a v2 spec carries the evidence-model marker" \
  "grep -q '^\*\*Evidence model:\*\* v2' $FIX/spec-v2.md" "marker missing"
check "a legacy plan naming a test id keeps the historical schema" \
  "grep -q '^## Test Coverage Matrix' $FIX/plan-1.md && grep -q '| > ' $FIX/plan-1.md" "shape drifted"
check "a legacy plan whose Test cell holds a read-only command names no test id" \
  "grep -q '^## Test Coverage Matrix' $FIX/plan-2.md && ! grep -qE '\| >|::' $FIX/plan-2.md" "shape drifted"
check "a new plan from a legacy spec carries the Verification Matrix" \
  "grep -q '^## Verification Matrix' $FIX/plan-3.md && grep -q 'behavioral' $FIX/plan-3.md" "shape drifted"
check "a v2 plan with a behavioral criterion names its test" \
  "grep -q 'behavioral' $FIX/plan-4.md" "shape drifted"
check "a v2 structural-only plan declares no behavioral criterion" \
  "! grep -q '| behavioral |' $FIX/plan-5.md" "a behavioral row appeared"
check "a v2 plan with a classless criterion has an empty class cell" \
  "grep -qE '^\| T1\.1 \| AC1 \|  *\|' $FIX/plan-6.md" "shape drifted"
check "a v2 spec with a historical Test Coverage Matrix is a blocking mismatch" \
  "grep -q 'spec-v2' $FIX/plan-7.md && grep -q '^## Test Coverage Matrix' $FIX/plan-7.md" "shape drifted"
check "a plan with no source spec cites none" \
  "! grep -q '^\*\*Source spec:\*\*' $FIX/plan-8.md" "a source spec appeared"

# --- the two controllers resolve all three outcomes
for c in skills/executing-plans/SKILL.md skills/subagent-driven-development/SKILL.md; do
  check "$c resolves the v2 mode" "grep -q 'v2 mode' $ROOT/$c" "clause missing"
  check "$c resolves the legacy mode" "grep -q 'legacy mode' $ROOT/$c" "clause missing"
  check "$c keeps the entry blocker for a plan with no spec" \
    "grep -qi 'no spec at all\|no spec exists' $ROOT/$c" "clause missing"
done

# --- the three prompts carry one identical clause
clause() { grep -A6 'A brief that declares no evidence class' "$ROOT/$1" | tr -s ' \n' ' '; }
a=$(clause skills/subagent-driven-development/task-reviewer-prompt.md)
b=$(clause skills/subagent-driven-development/implementer-prompt.md)
c=$(clause skills/subagent-driven-development/re-review-prompt.md)
check "the three prompts carry the consumption clause" "[ -n \"$a\" ]" "missing"
check "the three prompts agree on one body" \
  "[ \"$a\" = \"$b\" ] && [ \"$b\" = \"$c\" ]" "the three bodies diverged"

# --- no fourth class, anywhere
check "legacy behavioral is never a value in an Evidence class cell" \
  "! git -C $ROOT grep -qE '\\| *legacy behavioral *\\|'" "a fourth class appeared"

echo
if [ "$fail" -ne 0 ]; then echo "$fail case(s) failed"; exit 1; fi
echo "All compatibility-mode cases passed"
```

- [ ] **Step 9: O step de CI**

Em `.github/workflows/ci.yml`, acrescente o step, ao lado dos outros de `tests/`:

```yaml
      - name: Compatibility mode
        run: tests/compatibility-mode/run-tests.sh
```

- [ ] **Step 10: Verificar**

```bash
tests/compatibility-mode/run-tests.sh
scripts/check-skill-size.sh
scripts/check-links.sh
scripts/check-no-dispatch.sh
git diff --name-only main...HEAD -- docs/superpowers/
```

Expected: exit 0 nos quatro primeiros, e no último **apenas** os dois artefatos
desta linha de trabalho — nenhum plano ou spec histórico.

- [ ] **Step 11: Conferir e commitar**

```bash
git diff --stat
git add skills/ docs/evidence-model.md tests/compatibility-mode/ \
        .github/workflows/ci.yml CHANGELOG.md
git commit -m "feat: o modo de compatibilidade resolve-se no boundary do controller"
```
