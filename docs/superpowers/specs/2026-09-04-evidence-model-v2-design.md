# Evidence Model v2

**Route:** full process
**Data:** 2026-09-04

## Problem

O projeto trata `path/file.ext:line` como forma universal de prova, e isso
reprova por construção uma classe inteira de critério.

A regra raiz em [`CLAUDE.md`](../../../CLAUDE.md), section "How you work here", diz
*"Every claim about this code carries a `path/file.ext:line`"*, e
[`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), seção
"Step 3: Every Task in the Plan", converte isso em veredito: *"a criterion with
no `path/file.ext:line` citation is NOT DELIVERED"*.

**Não existe linha que prove ausência.** "Nenhuma dependência nova foi
introduzida", "o manifest continua JSON válido", "todos os links locais
resolvem" são estruturalmente `NOT DELIVERED`. Este repositório produz
exatamente esses critérios: é zero-dependency por regra, valida
`.claude-plugin/plugin.json` por `tests/kimi/test-plugin-manifest.sh` e
`tests/codex/test-marketplace-manifest.sh`, e roda `scripts/check-links.sh`. O gate mais forte
do projeto não sabe registrar a prova das propriedades que o projeto declara
sobre si mesmo.

**A promessa pública é tecnicamente falsa.** [`README.md`](../../../README.md),
[`docs/README.en.md`](../../README.en.md) e, traduzida como `arquivo:linha`,
[`docs/README.pt-BR.md`](../../README.pt-BR.md) prometem que toda afirmação
carrega citação `file:line`.

**E o instrumento de medição tem o mesmo defeito um nível abaixo.** A spec que
originou esta registrou uma listagem truncada (`ls | tail -5`) como se fosse o
conjunto: afirmou 5 arquivos onde `ls docs/superpowers/specs/ | wc -l` devolvia
23 naquele momento, e devolve 24 hoje, 04/09/2026, com esta spec somada. **O
número é medição datada; a condição durável é que uma vista truncada não
fundamenta cardinalidade.** O comando foi executado; o que falhou
foi o alcance do instrumento contra o alcance da alegação. `CLAUDE.md:9` já
manda medir em vez de estimar, e não cobre este caso, porque medir foi
exatamente o que aconteceu.

**Fora de escopo.** O gate de anchor fragment não é construído aqui — a decisão
do universo de validação fica para fatia própria, e IR5 é a guarda. Não entra:
adicionar citação a `systematic-debugging` ou `verification-before-completion`;
harmonizar as quatro faces de review; alterar `README.kimi.md` ou
`README.opencode.md`, que não carregam a promessa; e a correção do parser de
range, que é spec e plano próprios
([`2026-09-04-cross-reference-range-validation-design.md`](2026-09-04-cross-reference-range-validation-design.md)).
**Bump, tag, release e publicação também ficam fora**: acontecem depois do audit
e da integração, pelo fluxo de release, e não são critério nem task.

## The model

Três camadas, e a separação entre elas é o desenho:

| Camada | Responsabilidade |
|---|---|
| Spec | Define o *requirement* e declara a **evidence class** |
| Plan | Resolve o **verification instrument** daquela classe |
| Audit | **Reexecuta** o instrumento e verifica |

### Delivery evidence classes

Três, e nenhuma classe nova sem um caso real que estas não representem.

| Classe | Delivery evidence | Verification evidence |
|---|---|---|
| `behavioral` | Located range da implementação | Teste automatizado cobrindo, citado por range |
| `structural` | Located range do artefato versionado | Comando validador read-only, ou located ranges suficientes |
| `negative` | O escopo do artefato — onde olhar, não prova | Comando read-only sobre o diff ou o repo |

### Source evidence não é classe de entrega

Dependência travada no lockfile mais a linha lida, ou a doc oficial da versão
travada, fundamenta *decisão de design*. Nunca concede `DELIVERED`.

### Measurement status é outra dimensão

Ortogonal à classe: uma regra pode estar estruturalmente entregue no artefato e
ainda não ter sido medida em execução. `CLAUDE.md:13` já registra que a maioria
das regras aqui é *reasoned, not measured*. **"O protocolo define/exige" é
`structural`; "o agente efetivamente faz" é `behavioral` e exige medição.**
Nenhuma regra nova passa a exigir `RESULT-*` por ser normativa.

### Smallest sufficient range

**O menor range suficiente é o menor intervalo contíguo de linhas que, lido sem
depender de linhas vizinhas não citadas, sustenta sozinho a afirmação feita.**

- Uma linha basta → `arquivo:10`.
- Duas ou mais formam a unidade mínima de prova → `arquivo:10-14`.
- Range escolhido por proximidade não serve.
- Range que precisa de linhas externas não é suficiente.
- Range enorme que contém a prova é materialmente válido e mesmo assim não
  atende à regra.

### Live-document reference

Arquivo deste repositório que é editado a cada release não se ancora por
`file:line`, que apodrece, mas por **markdown link mais título de seção**. A
forma canônica ganha as duas verificações: o caminho pela passagem de links e o
título pela passagem de seções. `section "…"` em inglês é a forma que o gate lê.

### Os três regimes de frescor

Ortogonais à classe, e determinam o que precisa de guarda contra
envelhecimento:

| Regime | O que é | Guarda |
|---|---|---|
| *ephemeral* | Citação que o auditor ou reviewer acabou de produzir e o consumidor reabre no mesmo ciclo | Nenhuma; o consumo é imediato |
| *live persistent* | Spec ou plano ainda ativo, relido em ciclos futuros | Onde uma existir; o fragmento-âncora é a candidata, e não é construída aqui |
| *historical* | Registro já executado | Nenhuma contra `HEAD`; se achado podre, se **marca** como stale, nunca se reescreve |

### Locator não é evidence

No plano, um número de linha é navegação e envelhece durante a execução. Na
auditoria, é prova contra `HEAD`. **Plans locate work; audits locate evidence.**

### Current-state evidence não é provenance

Evidência se confere sempre contra o branch corrente. Referência presa a commit
ou tag é proveniência histórica — legítima em changelog, investigação e registro
já executado; nunca prova de entrega.

### Adequação do instrumento ao alcance da alegação

**The instrument must match the scope of the claim.** Uma vista amostrada,
truncada, paginada, filtrada ou parcial não estabelece completude,
cardinalidade, unicidade nem ausência. Alegação sobre o conjunto inteiro exige
instrumento exaustivo sobre esse conjunto.

### Cláusula de contenção — dois invariantes distintos

1. **Task eligibility.** Toda task do plano continua precisando deixar um
   deliverable versionado no branch.
2. **Evidence adequacy.** `command + result` prova propriedade *do deliverable
   ou do estado do branch*, e é **read-only**. Nunca transforma deploy,
   publish, migração em ambiente vivo ou monitoramento em task auditável.

## Acceptance Criteria

- **AC1** `[structural]` — `docs/evidence-model.md` existe e define cada
  conceito da seção `## The model` desta spec, sem acrescentar nenhum: as três
  delivery classes, a source evidence fora delas, o measurement status como
  dimensão ortogonal, o *smallest sufficient range*, a live-document reference,
  os três regimes de frescor, a distinção locator/evidence, a distinção
  current-state/provenance, a adequação do instrumento ao alcance da alegação e
  os dois invariantes da cláusula de contenção.
- **AC2** `[negative]` — `docs/evidence-model.md` não contém nenhum bloco
  `## Output Format`.
- **AC3** `[structural]` — `CLAUDE.md` e `AGENTS.md` afirmam que toda afirmação
  material sobre o código carrega evidência que **casa com a afirmação**, e que
  um caminho sozinho é localização e não prova; os dois textos são idênticos
  entre si e nenhum dos dois continua exigindo `path/file.ext:line` como forma
  universal.
- **AC4** `[structural]` — `CLAUDE.md` e `AGENTS.md` carregam a regra de
  adequação do instrumento ao alcance da alegação, idênticos entre si.
- **AC5** `[structural]` — `brainstorming/SKILL.md` carrega a regra de adequação
  do instrumento como regra operacional, na section "Where a Claim Comes From" ou
  imediatamente adjacente a ela.
- **AC6** `[structural]` — `spec-document-reviewer-prompt.md` carrega finding
  bloqueante para alegação de completude, cardinalidade, unicidade ou ausência
  sustentada apenas por instrumento parcial.
- **AC7** `[structural]` — `brainstorming/SKILL.md` exige uma evidence class
  declarada por `AC` e por `IR`.
- **AC8** `[structural]` — `brainstorming/references/coverage-map.md` deixa de
  definir a categoria *Completion signals* por `file:line` e passa a defini-la
  por evidência admissível.
- **AC9** `[structural]` — `brainstorming/SKILL.md` pede, em `## Codebase
  Findings`, o menor range suficiente e o menor fragmento que identifica o fato.
- **AC10** `[structural]` — `spec-document-reviewer-prompt.md` bloqueia critério
  sem evidence class declarada.
- **AC11** `[structural]` — `spec-document-reviewer-prompt.md` bloqueia critério
  que nenhuma evidência admissível pode resolver, substituindo a formulação atual
  que fala em `file:line`.
- **AC12** `[structural]` — `writing-plans/SKILL.md` exige que o plano resolva o
  verification instrument de cada critério, registrado numa coluna adicional da
  `## Test Coverage Matrix`.
- **AC13** `[structural]` — `plan-document-reviewer-prompt.md` cobra a coluna
  nova e bloqueia critério cujo instrumento o plano não resolveu.
- **AC14** `[structural]` — `writing-plans/SKILL.md` distingue locator de
  evidence no bloco `**Files:**`, mantendo o range como navegação opcional.
- **AC15** `[structural]` — `writing-plans/SKILL.md` preserva o invariante de
  task eligibility com a redação nova, sem passar a admitir efeito externo.
- **AC16** `[structural]` — `final-branch-audit/SKILL.md` usa as colunas
  `Task | Criterion | Delivery evidence | Verification evidence | Verdict` **nas
  duas ocorrências da tabela**, a da section "The Audit Table" e a de dentro do
  prompt de dispatch.
- **AC17** `[structural]` — `final-branch-audit/SKILL.md` define
  `EVIDENCE CLASS MISMATCH` como veredito bloqueante para classe declarada que
  não serve ao critério.
- **AC18** `[structural]` — o protocolo do auditor em
  `final-branch-audit/SKILL.md` declara que o auditor pode apontar inadequação
  de classe mas não pode reclassificar o critério para conceder `DELIVERED`.
- **AC19** `[structural]` — o protocolo do auditor declara que ele executa
  verificação read-only específica do critério, e que pode exigir evidência
  adicional.
- **AC20** `[structural]` — `final-branch-audit/SKILL.md` declara que critério de
  spec sem evidence class é tratado como `legacy behavioral`, com o veredito
  idêntico ao anterior.
- **AC21** `[structural]` — `docs/review-scopes.md` declara que o final audit
  executa verificação read-only específica do critério, sem assumir o papel do
  reviewer da suíte do projeto.
- **AC22** `[structural]` — o bloco `### Test Evidence` de
  `task-reviewer-prompt.md` aceita, na coluna que hoje exige `Test file:line`,
  um comando read-only com seu resultado quando a evidence class do critério não
  é `behavioral`, e continua exigindo teste quando é.
- **AC23** `[structural]` — `code-reviewer.md` e `re-review-prompt.md` admitem
  command evidence para achado transversal, mantendo located range para achado
  local.
- **AC24** `[structural]` — `docs/README.pt-BR.md`, canônico, descreve a promessa
  como evidência que casa com a afirmação, e `docs/README.en.md` traduz a mesma
  mudança no mesmo commit.
- **AC25** `[structural]` — `README.md` descreve a promessa como evidência
  inspecionável que casa com a afirmação — range localizado, verificação
  executável ou fonte fundamentada — e deixa de prometer `file:line` como forma
  universal. A redação diverge da referência de propósito, como já é o caso.
- **AC26** `[structural]` — o item de `## Open gaps` sobre o gate de `file:line`
  deixa de afirmar que nenhum anchor foi achado podre, e registra os três
  regimes: *ephemeral*, *live persistent* e *historical*.

## Implicit Requirements

- **IR1** `[negative]` — nenhum `SKILL.md` **não isento** excede 500 linhas.
  A isenção é declarada em `scripts/check-skill-size.sh:43`
  (`EXEMPT=(skills/writing-skills/SKILL.md)`) e não é alterada por esta
  mudança. O que não couber vai para `references/`, nunca por compressão.
- **IR2** `[negative]` — a mudança não introduz dependência externa.
- **IR3** `[negative]` — `scripts/check-evidence-line.sh` continua verde: a
  forma `Command`/`exit`/`counts` não muda em nenhum carrier.
- **IR4** `[negative]` — `scripts/check-links.sh` continua verde com o
  documento novo e os links acrescentados.
- **IR5** `[negative]` — nenhum gate novo passa a exigir fragmento literal em
  citação.
- **IR5b** `[negative]` — o anchor-fragment gate não é construído nesta branch.
- **IR6** `[negative]` — nenhum arquivo novo entra em `scripts/` nesta branch.
  A motivação de um gate não é auditável; a ausência do arquivo é. Se um gate se
  tornar necessário, ele sai desta branch e leva consigo o defeito medido que o
  paga, registrado em `CHANGELOG.md`.
- **IR7** `[negative]` — `scripts/check-docs-sync.sh` continua verde:
  `docs/README.pt-BR.md` e `docs/README.en.md` mudam no mesmo commit.
- **IR8** `[structural]` — `CHANGELOG.md` recebe entrada em `[Unreleased]` para
  cada commit que toque `skills/`, `scripts/`, `githooks/`, `.github/` ou
  `hooks/`, que são os caminhos que `scripts/check-changelog.sh` cobra.

## Codebase Findings

- **A regra raiz trata `path:line` como universal, em dois arquivos idênticos.**
  [`CLAUDE.md`](../../../CLAUDE.md) e [`AGENTS.md`](../../../AGENTS.md), ambos na seção
  "How you work here": *"Every claim about this code carries a
  `path/file.ext:line`."*
- **A regra de medir existe e não cobre o defeito do instrumento.**
  `CLAUDE.md:9`: *"**Measure, don't estimate.** Counts, file lists, "this is used
  in N places" — run the command."* O comando foi executado; o alcance é que não
  batia.
- **O projeto já separa regra fundamentada de regra medida.** `CLAUDE.md:13`:
  *"**Most rules here are reasoned, not measured.** When you add one, say which
  it is."* É a fonte da decisão de não criar classe `normative`.
- **O audit converte evidence-or-zero em veredito.**
  [`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), seção
  "Step 3: Every Task in the Plan": *"Evidence-or-zero: a criterion with no
  `path/file.ext:line` citation is NOT DELIVERED."*
- **A tabela do audit ocorre duas vezes, e um grep ancorado em início de linha vê
  só uma.** `skills/final-branch-audit/SKILL.md:101` e
  `skills/final-branch-audit/SKILL.md:300` carregam
  `| Task | Criterion | Implementation | Test | Verdict |`; a segunda é indentada
  por estar dentro do prompt de dispatch. É a razão de AC16 nomear as duas.
- **Não há escape de escopo para critério de spec.**
  `skills/final-branch-audit/SKILL.md:79`:
  `| Spec criterion no task covers | **LOST IN TRANSLATION — BLOCKING** |`. O
  escape `OUT OF SCOPE — DECLARED` existe em
  `skills/final-branch-audit/SKILL.md:134` para rows de **task**, e a seção que o
  define reserva-o a *"a plan's last tasks... dispatched before they could have
  run"* — diferença temporal, não partição de escopo. É a fonte da decisão de
  duas specs.
- **O auditor já é declarado não-confiante em relatório alheio.**
  `skills/final-branch-audit/SKILL.md:263-265`: *"The plan, the ledger, the
  implementer reports, and any prior review approval are claims under audit —
  never evidence."* É a fonte do híbrido restrito de AC18.
- **Um caminho de divergência registrada já existe na tabela de vereditos.**
  `skills/final-branch-audit/SKILL.md:132`:
  `| Criterion delivered somewhere other than the plan said | DELIVERED — note the real location in the row |`.
  `EVIDENCE CLASS MISMATCH` segue essa forma, com veredito bloqueante em vez de
  concessivo.
- **O contrato atual do audit exclui execução.**
  [`docs/review-scopes.md`](../../review-scopes.md), section "What each face runs",
  na row do final audit: *"**No tests at all** — re-runs the *searches* against
  the spec"*. AC21 altera essa row.
- **O teto de tamanho tem isenção declarada nove linhas abaixo do limite.**
  `scripts/check-skill-size.sh:34` fixa `MAX=500` e
  `scripts/check-skill-size.sh:43` declara
  `EXEMPT=(skills/writing-skills/SKILL.md)`. Medido em 2026-09-04 sobre todos os
  `skills/*/SKILL.md`: `writing-skills` 690 (isento), `writing-plans` 471,
  `subagent-driven-development` 468, `brainstorming` 403, `final-branch-audit`
  372. **A condição durável é IR1; estes números são a medição datada que a
  motivou.**
- **A forma `command + result` já existe e tem gate de formato, não de
  conteúdo.** `scripts/check-evidence-line.sh:17-19`: *"It reads field names,
  never their content: `**exit:** [code]` and `**exit:** [the moon]` are
  identical to this check."*
- **A forma dentro de `## Output Format` de subagente não pode ficar atrás de
  link.** `scripts/check-evidence-line.sh:6-10` registra a medição 1/3 → 3/3
  quando a forma voltou ao ponto de uso. É a fonte de AC2 e de IR6.
- **Os dois READMEs de documentação são um par gated; o showcase não.**
  [`docs/docs-and-links.md`](../../docs-and-links.md), section "Three README-shaped
  files, three jobs": `docs/README.pt-BR.md` é canônico, `docs/README.en.md` o
  traduz, e `scripts/check-docs-sync.sh:14-15` força os dois no mesmo commit;
  `README.md` está fora do par. É a razão de AC24 e AC25 serem critérios
  separados.
- **As cinco colunas da matriz são cobradas por um prompt, não pelo parser.**
  `skills/writing-plans/plan-document-reviewer-prompt.md:89` bloqueia matriz sem
  as cinco colunas nomeadas; `skills/writing-plans/scripts/check-cross-references:278-288`
  parseia célula por padrão de conteúdo (`> nome`), não por posição de coluna.
  Uma coluna adicional muda o prompt e não o script — é o que AC12 e AC13
  exploram.
- **A testabilidade do coverage map é definida por `file:line`.**
  [`brainstorming/references/coverage-map.md`](../../../skills/brainstorming/references/coverage-map.md),
  section "Categories", na row *Completion signals*: *"A criterion no `file:line`
  can settle cannot be traced by the plan or the final audit"*. AC8 alcança esta
  linha.
- **A regra contra assunção respondível pelo código já existe e disparou.**
  `skills/brainstorming/spec-document-reviewer-prompt.md:89`:
  `| Item in `## Assumptions to Confirm` that IS verifiable in the code | BLOCKING |`.
  Foi ela que pegou a listagem truncada. Não é reescrita: AC6 acrescenta regra
  sobre **alcance do instrumento**, que é afirmação diferente.
- **O item de Open gaps afirma premissa vencida.**
  [`CHANGELOG.md`](../../../CHANGELOG.md), section "Open gaps", item que abre com *"The
  `file:line` form has no gate"*: diz *"Not built, and the condition is the whole
  point of the entry: the first code anchor found drifted turns this from a
  design into a defect"*, e o mesmo item registra que em 2026-08-26 um foi achado
  podre no commit `f4a3444`, admitindo *"Whether they belong inside it is the half
  of this item that is actually open"*. **A condição que AC26 estabelece é que o
  item pare de afirmar ausência de defeito medido — não um número, que envelhece.**

## External Dependencies

None. O projeto é zero-dependency por regra de [`CLAUDE.md`](../../../CLAUDE.md), seção
"What does not belong here". As ferramentas usadas — `python3`, `bash`, `git` —
já são pressupostas pelos gates existentes.

## Assumptions to Confirm

- **Quantas linhas cada edição acrescenta a `writing-plans/SKILL.md` e a
  `subagent-driven-development/SKILL.md`.** Não é respondível pela árvore hoje:
  depende do texto final, que ainda não existe. Instrumento tentado:
  `grep -ac '' skills/*/SKILL.md` sobre o conjunto completo, que dá o estado
  atual mas não o incremento. IR1 é a guarda; o plano mede depois de escrever.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC26, com o escopo enumerado pelo parceiro e não inferido |
| Domain and data model | Clear | Não há dado nem entidade: a mudança é normativa, em arquivos de texto |
| Interaction flow | Resolved | AC1 (o documento canônico define a cadeia) e AC12 (o plano resolve o instrumento, que é o elo do meio) |
| Non-functional attributes | Resolved | IR1 (teto), IR3, IR4, IR7 (gates existentes verdes), IR6 (custo de gate novo) |
| Integrations and external dependencies | Clear | IR2 e `## External Dependencies`: zero-dependency por regra |
| Edge cases and failures | Resolved | AC20 (spec sem classe), AC18 (auditor discorda da classe), AC16 (a ocorrência indentada da tabela) |
| Constraints and tradeoffs | Resolved | IR1 e IR6: o teto de linhas e a recusa de criar gate por conveniência são as duas restrições que moldam onde o texto mora |
| Terminology | Resolved | *evidence class* × *measurement status*; *locator* × *evidence*; *current-state* × *provenance*; *source evidence* fora das classes de entrega |
| Completion signals | Resolved | Cada `AC` e `IR` carrega classe declarada; a spec aplica em si o modelo que define |
| Placeholders and vague adjectives | Resolved | *Smallest sufficient range* foi definido formalmente na seção The model, em vez de ficar como adjetivo |

### Decision record

| Pergunta | Resposta | Recomendação dada | Fonte declarada |
|---|---|---|---|
| Quem declara a evidence class? | Híbrido restrito: spec declara; auditor aponta inadequação com `EVIDENCE CLASS MISMATCH — BLOCKING` e nunca reclassifica para conceder | A spec declara | Padrão do projeto — `skills/final-branch-audit/SKILL.md:263-265`, *"claims under audit — never evidence"* |
| Criar a classe `normative` para prosa de skill? | Não. Classe e status de medição são dimensões separadas | Criar `normative` | **Recomendação recusada pelo parceiro**, com fonte melhor: `CLAUDE.md:13`, *"Most rules here are reasoned, not measured"* |
| Onde mora o modelo? | `docs/evidence-model.md` como documentação conceitual canônica; regra operacional e Output Format inline em cada skill | `docs/review-scopes.md` absorve | **Recomendação recusada pelo parceiro** — `scripts/check-evidence-line.sh:6-10` justifica o inline, não a ausência do documento conceitual |
| Uma spec com dois planos, ou duas specs? | Duas specs e dois planos | Três fatias, sem enunciar que exigia duas specs | Padrão do projeto — `skills/final-branch-audit/SKILL.md:79`, sem escape de escopo para critério |
| Onde mora a regra de adequação do instrumento? | Dois níveis: princípio no repositório, regra operacional em `brainstorming` e finding no spec reviewer | Só no `CLAUDE.md` do projeto | Boa prática geral, declarada como tal — regra de projeto mora no arquivo de instrução do projeto. Nenhum padrão deste repositório foi consultado, e era aí que estava o erro. **Recomendação corrigida pelo parceiro**: o `CLAUDE.md` daqui governa quem desenvolve o superpowersplus e não alcança quem instala o plugin noutro projeto, que é justamente quem a regra protege |
| Bump entra como critério? | Não | *(não perguntada — trazida pelo parceiro)* | Decisão do parceiro |
