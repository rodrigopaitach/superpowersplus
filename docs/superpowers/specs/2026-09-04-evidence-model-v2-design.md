# Evidence Model v2

**Route:** full process
**Data:** 2026-09-04
**Evidence model:** v2

## Problem

O projeto trata `path/file.ext:line` como forma universal de prova, e isso
reprova por construção uma classe inteira de critério.

A regra raiz em [`CLAUDE.md`](../../../CLAUDE.md), section "How you work here", diz
*"Every claim about this code carries a `path/file.ext:line`"*, e
[`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), section
"Step 3: Every Task in the Plan", converte isso em veredito: *"a criterion with
no `path/file.ext:line` citation is NOT DELIVERED"*.

**Não existe linha que prove ausência.** "Nenhuma dependência nova foi
introduzida", "o manifest continua JSON válido", "todos os links locais
resolvem" são estruturalmente `NOT DELIVERED`. Este repositório produz
exatamente esses critérios: é zero-dependency por regra e roda
`scripts/check-links.sh`. E o caso mais agudo é um que **nenhum teste deste
repositório verifica**: que `.claude-plugin/plugin.json` continua JSON válido.
Um `grep -ran` por esse caminho em `scripts/`, `tests/` e `.github/`, sobre
`*.sh`, `*.py` e `*.yml`, devolve zero. **Entre as ocorrências medidas para esta
spec, `.version-bump.json` é o único portador não-prosa** — e ali o caminho é
alvo de bump, não validação (`.version-bump.json:4`); as demais ocorrências são
referências em prosa, e nenhuma valida o caminho. O gate mais forte do projeto não sabe registrar a
prova das propriedades que o projeto declara sobre si mesmo.

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
do universo de validação fica para fatia própria, e IR9 é a guarda. Não entra:
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
`file:line`, que apodrece, mas por **markdown link mais título de seção** —
[`CLAUDE.md`](../../../CLAUDE.md), section "Writing a reference". A forma canônica
ganha as duas verificações: o caminho pela passagem de links e o título pela
passagem de seções. **A forma que o gate lê é `<link ou caminho em crase>,
section "Título"`, em inglês e contígua**: `scripts/check-links.sh:102-103`.

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

### A Verification Matrix substitui a Test Coverage Matrix

O plano registra, por critério, o **verification instrument** que a classe
declarada exige. Não é matriz universal de testes:

| Classe | Instrumento |
|---|---|
| `behavioral` | Teste automatizado, sujeito às regras de qualidade de teste já vigentes |
| `structural` | Comando validador read-only, ou located ranges suficientes |
| `negative` | Comando read-only sobre o escopo declarado |

**Nenhum critério fica sem instrumento resolvido, e teste nunca se inventa para
preencher `structural` ou `negative`.**

Como um gate mecânico passa a parsear a tabela, o schema é fixo. Seis colunas
obrigatórias, e **nenhuma coluna `Test` separada** — para `behavioral` o id do
teste vive em `Verification instrument`, sem duplicar o mesmo id em duas
colunas:

| Coluna | `behavioral` | `structural` e `negative` |
|---|---|---|
| `Criterion` | o label da task | idem |
| `Spec criterion` | o `AC`/`IR` que ele refina | idem |
| `Evidence class` | `behavioral` | `structural` ou `negative` |
| `Verification instrument` | id exato do teste | validador read-only, comando read-only, ou evidência localizada conforme a classe |
| `Test type` | preenchido | `—` |
| `Layer` | preenchido | `—` |

**`—` em `Test type` e `Layer` não é achado quando a classe não é
`behavioral`.** A informação de tipo e camada continua preservada onde tem
consumidor; nenhuma linha finge ter teste.

### Compatibilidade: `legacy behavioral`

**Um `AC`/`IR` de spec anterior ao Evidence Model, que não declara evidence
class, recebe o fallback de compatibilidade** — veredito idêntico ao anterior ao
modelo. Vale nas três camadas: ao criar plano novo a partir de spec antiga, na
revisão desse plano, e na auditoria final.

**`legacy behavioral` não é uma quarta evidence class.** As classes continuam
sendo exatamente três — `behavioral`, `structural`, `negative` — e
`legacy behavioral` nomeia o **estado de compatibilidade**, não um valor do
namespace. Sem marcador, a *effective evidence class* é `behavioral`, obtida
pelo fallback.

Consequência operacional: um plano novo escrito a partir de spec histórica
registra na célula `Evidence class` da Verification Matrix o valor
**`behavioral`**, nunca `legacy behavioral`. Que a classe veio do fallback pode
ser anotado à parte para quem lê, mas **nenhum parser, reviewer ou auditor
precisa reconhecer um quarto valor**.

**Não há inferência heurística de classe.** O discriminador é um marcador
explícito no cabeçalho da spec, `**Evidence model:** v2`, e a regra é
**assimétrica de propósito**:

| Quem lê | Regra |
|---|---|
| `brainstorming`, ao escrever spec nova ou ao migrar uma antiga no resume | Escreve o marcador e exige classe em todo `AC`/`IR` |
| Spec reviewer | **Exige o marcador.** Marcador presente com critério sem classe é bloqueante; marcador ausente numa spec que chega ao fluxo atual também é |
| `writing-plans`, plan reviewer, final audit | Com marcador, classe é obrigatória e a ausência é erro. **Sem marcador, documento histórico → fallback de compatibilidade, com classe efetiva `behavioral`** |

**A assimetria é o que fecha a rota de fuga:** o reviewer nunca conclui *"sem
marcador, logo legacy"*, porque isso deixaria uma spec nova defeituosa escapar
pela ausência simultânea do marcador e das classes. O fallback existe só nos
consumidores a jusante, que precisam aceitar artefatos históricos que nunca
passaram pelo fluxo novo.

**Limitação declarada:** um documento criado fora do fluxo e deliberadamente
sem marcador é indistinguível de um documento histórico sem recorrer a
proveniência. O modelo garante a distinção **no fluxo suportado**, e não tenta
inferir intenção a partir do arquivo. Declarar esse limite é preferível a uma
heurística sobre histórico do git.

## Acceptance Criteria

- **AC1** `[structural]` — `docs/evidence-model.md` existe e define os treze
  conceitos que `## The model` desta spec enuncia: a cadeia de três camadas
  (spec declara a classe, plano resolve o instrumento, audit reexecuta), as três
  delivery classes, a source evidence fora delas, o measurement status como
  dimensão ortogonal, o *smallest sufficient range*, a live-document reference,
  os três regimes de frescor, a distinção locator/evidence, a distinção
  current-state/provenance, a adequação do instrumento ao alcance da alegação,
  os dois invariantes da cláusula de contenção, a Verification Matrix e a
  compatibilidade `legacy behavioral`.
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
  do instrumento como regra operacional em
  [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md),
  section "Where a Claim Comes From", ou imediatamente adjacente a ela.
- **AC6** `[structural]` — `spec-document-reviewer-prompt.md` carrega finding
  bloqueante para alegação de completude, cardinalidade, unicidade ou ausência
  sustentada apenas por instrumento parcial.
- **AC7** `[structural]` — `brainstorming/SKILL.md` exige uma evidence class
  declarada por `AC` e por `IR`.
- **AC8** `[structural]` — `brainstorming/references/coverage-map.md` deixa de
  definir a categoria *Completion signals* por `file:line` e passa a defini-la
  por evidência admissível.
- **AC9** `[structural]` — `brainstorming/SKILL.md` pede, em `## Codebase
  Findings`, o menor range suficiente, mantendo o quoted snippet que a regra
  atual já exige sem acrescentar exigência de minimalidade ao fragmento — a
  única minimalidade normativa desta spec é o *smallest sufficient range*.
- **AC10** `[structural]` — `spec-document-reviewer-prompt.md` bloqueia critério
  sem evidence class declarada.
- **AC11** `[structural]` — `spec-document-reviewer-prompt.md` bloqueia critério
  que nenhuma evidência admissível pode resolver, substituindo a formulação atual
  que fala em `file:line`.
- **AC12** `[structural]` — `writing-plans/SKILL.md` substitui a
  `## Test Coverage Matrix` por uma **Verification Matrix** com as seis colunas
  obrigatórias que `## The model` fixa — `Criterion`, `Spec criterion`,
  `Evidence class`, `Verification instrument`, `Test type`, `Layer` — sem coluna
  `Test` separada, com o id do teste vivendo em `Verification instrument` para
  `behavioral`, `—` válido em `Test type` e `Layer` fora de `behavioral`, e
  nenhum critério sem instrumento resolvido.
- **AC13** `[structural]` — `plan-document-reviewer-prompt.md` cobra as seis
  colunas e a semântica da classe: bloqueia critério sem instrumento resolvido,
  deixa de exigir teste de `structural` e `negative`, não trata `—` em
  `Test type` ou `Layer` como achado fora de `behavioral`, e bloqueia
  divergência entre o bloco da task e a matriz.
- **AC14** `[structural]` — `writing-plans/SKILL.md` distingue locator de
  evidence no bloco `**Files:**`, mantendo o range como navegação opcional.
- **AC15** `[structural]` — `writing-plans/SKILL.md` preserva o invariante de
  task eligibility com a redação nova, sem passar a admitir efeito externo.
- **AC16** `[structural]` — `final-branch-audit/SKILL.md` usa as colunas
  `Task | Criterion | Delivery evidence | Verification evidence | Verdict` **nas
  duas ocorrências da tabela** — a de
  [`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md),
  section "The Audit Table", e a de dentro do prompt de dispatch.
- **AC17** `[structural]` — `final-branch-audit/SKILL.md` define
  `EVIDENCE CLASS MISMATCH` como veredito bloqueante para classe declarada que
  não serve ao critério.
- **AC18** `[structural]` — o protocolo do auditor em
  `final-branch-audit/SKILL.md` declara que o auditor pode apontar inadequação
  de classe mas não pode reclassificar o critério para conceder `DELIVERED`.
- **AC19** `[structural]` — o protocolo do auditor declara que ele executa
  verificação read-only específica do critério, e que pode exigir evidência
  adicional.
- **AC20** `[structural]` — `final-branch-audit/SKILL.md` aplica o discriminador
  de compatibilidade: em spec **sem** `**Evidence model:** v2`, critério sem
  classe recebe o fallback, com classe efetiva `behavioral` e o veredito idêntico
  ao do modelo anterior; em spec **com** o marcador, ausência de classe é erro e
  nunca recebe fallback. Sem heurística.
- **AC21** `[structural]` — `docs/review-scopes.md` declara que o final audit
  executa verificação read-only específica do critério, sem assumir o papel do
  reviewer da suíte do projeto.
- **AC22** `[structural]` — `task-reviewer-prompt.md` define o protocolo de
  verificação por critério: o reviewer lê do brief cada critério com sua
  evidence class e seu instrumento, e reexecuta o instrumento que a classe pede
  — teste para `behavioral`, evidência localizada ou validador read-only para
  `structural`, comando read-only sobre o escopo declarado para `negative`. Uma
  task pode misturar classes.
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
- **AC27** `[negative]` — `docs/evidence-model.md` não define nenhum conceito
  que `## The model` desta spec não enuncie. A classe é `negative` e não
  `structural` porque a entrega é uma proibição: não há range que prove
  ausência, exatamente como em AC2, que é a mesma forma sobre o mesmo arquivo.
- **AC28** `[structural]` — `task-reviewer-prompt.md` generaliza `### Test
  Evidence` para **Verification Evidence**, com uma linha por critério
  distinguindo critério, evidence class, instrumento executado, resultado e
  evidência localizada quando aplicável; `—` deixa de ser achado bloqueante para
  critério que não é `behavioral`, e nenhum arquivo de teste é inventado.
- **AC29** `[structural]` — `task-reviewer-prompt.md` preserva integralmente,
  para critérios `behavioral`, a obrigação de executar os testes e o
  shallow-test litmus existente: a generalização para Verification Evidence não
  remove nem enfraquece essas regras. **A classe é `structural` porque a
  propriedade entregue é o texto preservado no prompt.** Afirmar que o reviewer
  se comporta assim em execução seria `behavioral` e exigiria medição que esta
  spec não tem — e o próprio litmus está registrado como *"Reasoned, not
  measured"* em `CHANGELOG.md:1704`, no item que o introduziu.
- **AC30** `[structural]` — `writing-plans/SKILL.md` faz o bloco de cada task
  carregar spec criterion, evidence class, task criterion e verification
  instrument, de modo que o brief extraído por `scripts/task-brief` baste ao
  implementer e ao reviewer sem reler a spec nem a matriz do plano.
- **AC31** `[structural]` — `writing-plans/SKILL.md` substitui as regras que
  universalizam teste: a que exige que todo critério nomeie um covering test, a
  de *one row, one test*, a que cobra `AC` e `IR` nos mesmos termos com tipo,
  layer e id de teste, e a que manda escalar ao humano quando algo não é
  testável. No lugar delas fica a classe declarada.
- **AC32** `[structural]` — `subagent-driven-development/SKILL.md` deixa de
  derivar `[TEST_COMMAND]` universalmente: entrega ao reviewer os verification
  instruments da task, exige comando de teste e base test count apenas quando a
  task tem critério `behavioral`, e nunca inventa runner para satisfazer task
  `structural` ou `negative`.
- **AC33** `[structural]` — `executing-plans/SKILL.md` troca o preflight que
  exige `file:line` mais covering test de todo critério por um que exige
  evidence class declarada e instrumento admissível capaz de resolver a claim;
  para `behavioral` isso inclui o covering test, e ausência de teste em
  `structural` ou `negative` deixa de ser motivo de escalação.
- **AC34** `[structural]` — `writing-plans/SKILL.md` e
  `plan-document-reviewer-prompt.md` decidem pelo marcador: spec com
  `**Evidence model:** v2` exige classe em todo critério e a ausência é erro;
  spec sem marcador é documento histórico e seus critérios recebem o fallback,
  com classe efetiva `behavioral` registrada assim na Verification Matrix — nunca
  um quarto valor. Sem inferência heurística de classe.
- **AC35** `[structural]` — `spec-document-reviewer-prompt.md` exige o marcador
  `**Evidence model:** v2` na spec que revisa, e bloqueia tanto o critério sem
  classe sob marcador presente quanto a spec sem marcador. **Não conclui
  `legacy behavioral` a partir da ausência do marcador** — esse fallback existe
  apenas nos consumidores a jusante, e concluí-lo aqui deixaria uma spec nova
  defeituosa escapar pela ausência simultânea do marcador e das classes.
- **AC36** `[structural]` — `brainstorming/SKILL.md` escreve o marcador
  `**Evidence model:** v2` no cabeçalho de toda spec que cria, e o acrescenta,
  junto das classes, ao migrar uma spec anterior pelo caminho de resume.
- **AC37** `[structural]` — `skills/writing-plans/scripts/check-cross-references`
  parseia a Verification Matrix pelo cabeçalho e pela evidence class, não por
  posição: localiza as colunas pelos títulos, lê `Evidence class` e
  `Verification instrument`, e **interpreta o instrumento como id de teste
  apenas na row `behavioral`**. Em `structural` e `negative` o instrumento é
  dado opaco para esse check — nem `>` nem `::` são lidos como nome de teste. A
  correspondência entre task criterion e row, e a unicidade da row, continuam
  cobradas para todas as classes. O script não valida a semântica do comando,
  que pertence ao plan reviewer e ao audit.
- **AC38** `[behavioral]` — `tests/hooks/test-check-cross-references.sh` cobre,
  com casos determinísticos, os sete comportamentos de AC37: row `behavioral`
  cujo id de teste um step cria passa; row `behavioral` cujo id não existe
  falha; instrumento `structural` ou `negative` contendo `>` não vira nome de
  teste; o mesmo contendo `::` não vira nome de teste; task criterion sem row
  continua falhando; row sem task criterion continua falhando; row duplicada
  continua falhando. **A classe é `behavioral` porque o sujeito é um programa
  determinístico com suíte automatizada, não um agente** — a distinção que
  `## The model` faz entre protocolo entregue e comportamento medido não se
  aplica a um script cujo comportamento é o próprio teste.
- **AC39** `[structural]` — `skills/writing-plans/scripts/check-cross-references`
  reconhece os dois schemas e não migra plano histórico durante a leitura. Na
  **Verification Matrix** de seis colunas, aplica AC37. Na antiga
  **Test Coverage Matrix** de cinco colunas, preserva o comportamento anterior:
  continua reconhecendo os test ids pela forma histórica, não exige
  `Evidence class`, e não tenta converter comandos, que aquele schema não
  suporta. Um plano histórico mantém exatamente o veredito que tinha antes da
  mudança.
- **AC40** `[behavioral]` — `tests/hooks/test-check-cross-references.sh` cobre os
  dois schemas de AC39: uma `## Test Coverage Matrix` histórica de cinco colunas,
  válida, continua passando; a mesma com id de teste inexistente continua
  falhando; e o corpus de planos já commitados em `docs/superpowers/plans/`
  produz o mesmo veredito antes e depois da mudança. **Este último é IR10
  medido durante a implementação, não descoberto no fim dela.**
- **AC41** `[structural]` — a regra de abertura de `final-branch-audit/SKILL.md`
  deixa de declarar universalmente que critério sem located citation é
  `NOT DELIVERED`, e passa a exigir delivery evidence e verification evidence
  admissíveis para a evidence class declarada, preservando located evidence onde
  a classe a exige. **É carrier próprio, não a tabela de AC16 nem o protocolo do
  auditor de AC18 e AC19:** a regra mora no corpo de abertura do arquivo, antes
  de qualquer seção, e é ela que decide todo veredito. Deixada como está, o topo
  da skill contradiz AC16–AC20 no mesmo arquivo, e um critério `negative` — que
  por definição não tem citação localizada — é reprovado pela primeira regra que
  o auditor lê.
- **AC42** `[structural]` — `task-reviewer-prompt.md` deixa de declarar
  `[TEST_COMMAND]` universalmente `REQUIRED`: ele é exigido apenas quando a task
  carrega critério `behavioral` cujo verification instrument é um teste. Task só
  `structural` ou `negative` não recebe test command e não tem nenhum inventado
  para ela. **A lista de placeholders é carrier próprio do contrato**, e não é
  alcançada por AC22, AC28 nem AC29, que tratam do protocolo e da tabela de
  evidência do mesmo arquivo, nem por AC32, que nomeia apenas
  `subagent-driven-development/SKILL.md`. Sem este critério, os dois arquivos
  passam a dizer coisas incompatíveis sobre o mesmo campo.

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
- **IR6** `[negative]` — nenhum arquivo novo entra em `scripts/` nesta branch.
  A motivação de um gate não é auditável; a ausência do arquivo é. Se um gate se
  tornar necessário, ele sai desta branch e leva consigo o defeito medido que o
  paga, registrado em `CHANGELOG.md`.
- **IR7** `[negative]` — `scripts/check-docs-sync.sh` continua verde:
  `docs/README.pt-BR.md` e `docs/README.en.md` mudam no mesmo commit.
- **IR8** `[structural]` — a classe é `structural` e não `negative` porque a
  entrega é positiva e localizável: as linhas acrescentadas ao `CHANGELOG.md`.
  `CHANGELOG.md` recebe entrada em `[Unreleased]` para
  cada commit que toque `skills/`, `scripts/`, `githooks/`, `.github/` ou
  `hooks/`, que são os caminhos que `scripts/check-changelog.sh` cobra.
- **IR9** `[negative]` — o anchor-fragment gate não é construído nesta branch.
- **IR10** `[negative]` — nenhum plano já commitado em `docs/superpowers/plans/`
  muda de veredito por causa da mudança em `check-cross-references`. Verificado
  por execução do script antes e depois sobre o corpus, não estimado.

## Codebase Findings

- **A regra raiz trata `path:line` como universal, em dois arquivos idênticos.**
  [`CLAUDE.md`](../../../CLAUDE.md), section "How you work here", e
  [`AGENTS.md`](../../../AGENTS.md), section "How you work here": *"Every claim about this code carries a
  `path/file.ext:line`."*
- **A regra de medir existe e não cobre o defeito do instrumento.**
  `CLAUDE.md:9`: *"**Measure, don't estimate.** Counts, file lists, "this is used
  in N places" — run the command."* O comando foi executado; o alcance é que não
  batia.
- **O projeto já separa regra fundamentada de regra medida.** `CLAUDE.md:13`:
  *"**Most rules here are reasoned, not measured.** When you add one, say which
  it is."* É a fonte da decisão de não criar classe `normative`.
- **O audit converte evidence-or-zero em veredito.**
  [`final-branch-audit/SKILL.md`](../../../skills/final-branch-audit/SKILL.md), section
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
  quando a forma voltou ao ponto de uso. É a fonte de AC2. **Não é fonte de IR6**,
  que depois da reescrita fala de arquivo novo em `scripts/` e não de forma atrás
  de link.
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
- **A passagem de seções só lê a forma inglesa e contígua.**
  `scripts/check-links.sh:102-103` define
  `SECTION_REF = re.compile(r'(?:`([^`\n]+\.md)`|\[[^\]]*\]\(([^)\s]+\.md)\)),\s*section\s+"([^"]+)"')`
  — o nome do arquivo precisa vir imediatamente antes de `, section "…"`, e
  qualquer palavra entre a vírgula e `section` faz a referência deixar de ser
  lida. Medido nesta spec durante a autoria: quatro âncoras escritas em português
  eram invisíveis ao gate, e uma delas nomeava seção inexistente.
- **A regra da forma canônica é do próprio projeto.**
  [`CLAUDE.md`](../../../CLAUDE.md), section "Writing a reference": ancorar por
  `file:line` o que não se move, e por markdown link mais título de seção o
  arquivo deste repositório editado a cada release, porque *"the canonical form
  earns both checks"*.
- **Quatro regras de `writing-plans` universalizam teste, e uma coluna nova não
  as alcança.** `skills/writing-plans/SKILL.md:213` — *"Names the covering test |
  The audit fails any criterion whose implementation exists untested"*;
  `:242` — *"**One row, one test**"*; `:255` — `IR` *"tested on the same terms as
  every `AC`: a named test type, a real layer, an exact test id"*; e `:257`, a
  válvula: *"If one genuinely cannot be tested at the layers this repository
  has, say so in a row of its own and take it to your human partner."* **Hoje
  todo critério estrutural ou negativo para o fluxo e vai ao humano.** É a fonte
  de AC12 e AC31.
- **O plan reviewer cobra as cinco colunas e um teste por linha.**
  `skills/writing-plans/plan-document-reviewer-prompt.md:89` bloqueia matriz sem
  `Criterion`, `Spec criterion`, `Test type`, `Layer`, `Test`, *"one test each"*,
  cobrando `IR` *"on the same terms as an `AC`"*. É a fonte de AC13.
- **A classe chega ao task reviewer pelo brief, se o plano a escrever.**
  `skills/subagent-driven-development/task-reviewer-prompt.md:24` manda *"Read
  the task brief: [BRIEF_FILE]"*, e `skills/subagent-driven-development/scripts/task-brief`
  extrai *"one task's full text from an implementation plan"* — o caminho não
  tem extensão, e a regex de citação do gate exige nome com ponto
  (`skills/writing-plans/scripts/check-cross-references:386`), então esta
  referência vale pela citação literal e não por número de linha que nada
  verifica. **Nenhum placeholder dedicado carrega classe ou instrumento** — a
  lista está em
  `skills/subagent-driven-development/task-reviewer-prompt.md:226-249`. É a fonte de AC30, e a razão de
  `scripts/task-brief` não precisar mudar.
- **O `TEST_COMMAND` é obrigatório e o controller é proibido de inventá-lo.**
  `skills/subagent-driven-development/task-reviewer-prompt.md:234` o declara
  `REQUIRED`, *"taken from the plan's Test Coverage Matrix or the repository's
  runner config"*, e `skills/subagent-driven-development/SKILL.md:272` acrescenta
  *"Confirm it exists before passing it — an invented command sends the reviewer
  chasing a runner error"*. **Uma task só estrutural ou negativa não tem valor
  admissível para esse campo.** É a fonte de AC32.
- **A tabela de evidência já acomoda a forma, e a trata como bloqueante.**
  `skills/subagent-driven-development/task-reviewer-prompt.md:191` tem a linha
  `| [criterion nothing covers] | — | NONE |` e `:193` diz *"One row per
  criterion in the brief, including those with no test"* — mas `:195` sentencia
  *"A `—` row is a blocking finding"*. É a fonte de AC28.
- **O preflight do caminho inline escala toda task não-behavioral.**
  `skills/executing-plans/SKILL.md:111-113` manda conferir critérios *"settled by
  a `file:line` citation, naming its covering test"*, e declara *"A task whose
  criteria no citation could settle is a concern"*; `:114` fecha com *"If
  concerns: Raise them with your human partner before starting"*. **Não é
  rejeição: é escalação, e a escalação para a execução antes do Step 2.** É a
  fonte de AC33.
- **Existe precedente de regra de compatibilidade para spec anterior a uma
  exigência, e ele não alcança `writing-plans`.**
  [`brainstorming/SKILL.md`](../../../skills/brainstorming/SKILL.md), section
  "Checklist", e a mesma skill em section "After the Design", ambas abrem com
  *"Resuming a spec written before …"*. Nada equivalente existe em
  `writing-plans`, e é por isso que AC34 e AC35 são necessários além de AC20.
- **O parser da matriz confunde comando read-only com nome de teste, e isso foi
  medido por execução.** `skills/writing-plans/scripts/check-cross-references:212-214`
  seleciona como row da matriz qualquer linha de tabela que contenha `T<n>.<n>`
  — **o nome da seção é irrelevante**, então renomear para *Verification Matrix*
  não afeta o parser. Sobre **cada célula** da row, `:283-286` aplica
  `re.search(r">\s*(.+?)\s*$", cell)` e `:292` aplica
  `re.search(r"::(\w+)\s*$", cell)`; o resultado entra em `named_in_matrix` e
  `:298` exige que apareça num bloco de código. **Quatro fixtures rodadas em
  2026-09-04 contra este checkout:** row `behavioral` com id de teste normal →
  exit 0; row `negative` com `` `git diff --name-only BASE..HEAD` `` → exit 0;
  row `negative` com `` `grep -q pattern file >/dev/null` `` → **exit 1**,
  *"tests named in the coverage matrix that no step creates: `/dev/null`"*; row
  `structural` com `::` no comando → **exit 1**, nomeando `validate`. **Não é
  nomenclatura envelhecida: é comportamento quebrado**, e é a fonte de AC37 e
  AC38.
- **Nenhum campo de cabeçalho é universal nas specs, e nenhum gate os lê.**
  Medido em 2026-09-04 sobre os 24 arquivos de `docs/superpowers/specs/`: só o
  `# Título` aparece em todos; `**Date:**` em 10, `**Status:**` em 12,
  `**Route:**` em 5, e **12 specs não têm campo de data nenhum**. Não existe
  campo de schema, versão ou formato em nenhuma. `check-cross-references` lê
  headings, ids e citações; `scripts/check-links.sh` lê links e títulos de
  seção — **nenhum dos dois lê o cabeçalho**, então acrescentar
  `**Evidence model:** v2` é ignorado com segurança por ambos. É a fonte de
  AC36 e do discriminador em `## The model`.
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

None. O projeto é zero-dependency por regra de [`CLAUDE.md`](../../../CLAUDE.md), section
"What does not belong here". As ferramentas usadas — `python3`, `bash`, `git` —
já são pressupostas pelos gates existentes.

## Assumptions to Confirm

None. A única pendência que esta seção carregava — quantas linhas as edições
acrescentam aos carriers perto do teto — foi decidida pelo parceiro e está
registrada no `### Decision record` abaixo. Não era assunção sobre o sistema:
era escolha de estratégia diante de um número que só existe depois do texto.

## Coverage Map

| Category | State | Where it landed |
|---|---|---|
| Functional scope and behavior | Resolved | AC1–AC42, com o escopo enumerado pelo parceiro e ampliado por duas investigações dirigidas — a primeira achou dois carriers esquecidos, a segunda um terceiro, o parser da matriz — e depois por AC41 e AC42, emendados no gate humano quando o plan reviewer achou mais dois carriers omitidos **em arquivos que a spec já editava** |
| Domain and data model | Clear | Não há dado nem entidade: a mudança é normativa, em arquivos de texto |
| Interaction flow | Resolved | AC1 (o documento canônico define a cadeia), AC12 (o plano resolve o instrumento), AC30 (a task carrega o contrato até o brief) e AC22 (o reviewer reexecuta por classe) |
| Non-functional attributes | Resolved | IR1 (teto), IR3, IR4, IR7 (gates existentes verdes), IR6 (custo de gate novo), IR8 (disciplina de changelog) |
| Integrations and external dependencies | Clear | IR2 e `## External Dependencies`: zero-dependency por regra |
| Edge cases and failures | Resolved | AC20, AC34, AC35 e AC36 (marcador, migração e a assimetria contra rota de fuga); AC18 (auditor discorda da classe); AC16, AC41 e AC42 — as três ocorrências da mesma falha: a regra escrita em mais de um portador do mesmo arquivo, e a enumeração alcançando um só; AC28 (`—` deixa de ser bloqueante fora de `behavioral`); AC37 e AC38 (comando com `>` ou `::` confundido com teste); AC39 e AC40 (o schema histórico de cinco colunas preservado) |
| Constraints and tradeoffs | Resolved | IR1 e IR6 (teto de linhas e nenhum arquivo novo em `scripts/`); IR5 e IR9, que mantêm o anchor fragment fora desta fatia; IR10, que proíbe a mudança do parser de mover veredito de plano commitado; e o Iron Law do TDD, deliberadamente fora — ver `### Decision record` |
| Terminology | Resolved | *evidence class* × *measurement status*; *locator* × *evidence*; *current-state* × *provenance*; *source evidence* fora das classes de entrega; *Verification Matrix* × *Test Coverage Matrix*; *legacy behavioral* como estado de compatibilidade × as três evidence classes, que continuam três; e `behavioral` de agente × `behavioral` de script determinístico, distinguidos em AC38 |
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
| Coluna adicional resolve a matriz? | Não. A `## Test Coverage Matrix` é substituída por uma Verification Matrix com semântica por classe | Acrescentar coluna | **Recomendação refutada por medição**: `skills/writing-plans/SKILL.md:213`, `:242`, `:255` e `:257` continuariam exigindo teste de todo critério, deixando duas regras contraditórias sobre a mesma linha |
| Criar conceito para *smallest fragment*? | Não. AC9 mantém o quoted snippet existente; a única minimalidade normativa é o *smallest sufficient range* | *(não perguntada — trazida pelo parceiro)* | Decisão do parceiro, evitando um décimo-quarto conceito só para justificar um adjetivo |
| O Iron Law do TDD entra nesta fatia? | Não. Contradição entre task `structural`/`negative` e a regra se escala como problema separado | Deixar fora | Padrão do projeto — `skills/subagent-driven-development/implementer-prompt.md:51`, *"Step 1 is not conditional on the task asking for it"*, é decisão de TDD anterior a esta spec |
| Extrair preventivamente de `writing-plans` e `subagent-driven-development`, que estão perto do teto? | Não. IR1 é a guarda: escreve-se a mudança certa, roda-se o gate, e o excedente vai para `references/` se ele disparar | Guarda em vez de task preventiva | Padrão do projeto — `CLAUDE.md`, section "Where the obvious move is wrong": *"A `SKILL.md` over the line ceiling is fixed by progressive disclosure, never by compression"*. Baseline datada 04/09/2026: `writing-plans` 471, `subagent-driven-development` 468, `executing-plans` 242, `final-branch-audit` 372, `brainstorming` 403 |
| Como distinguir spec anterior ao modelo de spec nova defeituosa? | Marcador `**Evidence model:** v2`, com regra assimétrica: reviewer exige o marcador; só os consumidores a jusante tratam a ausência como histórico | Marcador, com o reviewer sempre exigindo classe | Medição própria, 04/09/2026 — nenhum campo de cabeçalho é universal nas 24 specs e nenhum gate os lê, então o marcador é seguro de acrescentar. **Correção do parceiro**: sem a assimetria, uma spec nova sem marcador *e* sem classes escaparia como legacy |
| Basta parsear a coluna do instrumento no checker? | Não. O parser precisa ser header-aware **e** evidence-class-aware | Parsear a coluna | **Recomendação refutada pelo parceiro**: a coluna do instrumento é justamente onde moram os comandos com `>` e `::`, então parseá-la sem olhar a classe mantém a confusão |
| A classe de AC38 é `behavioral` sem medição de agente? | Sim. O sujeito é um script determinístico com suíte automatizada | *(não perguntada — trazida pelo parceiro)* | Decisão do parceiro, distinguindo comportamento de programa de comportamento de agente |
| AC29 afirma comportamento medido? | Não. Vira `structural`: a entrega é o texto preservado no prompt | Manter `[behavioral]` | **Recomendação refutada por medição**: o item que introduziu o litmus fecha com *"Reasoned, not measured."* em `CHANGELOG.md:1704`, e nenhum `RESULT-*` mede essa regra |
| A spec estava completa quando o plan reviewer achou dois carriers omitidos? | Não. Vira emenda no gate humano: AC41 (a regra de abertura do audit) e AC42 (o placeholder `[TEST_COMMAND]`), **um critério por propriedade, nunca um AC genérico do tipo "todo portador é alcançado"** | Emendar a spec em vez de consertar como step dentro da task | Padrão do projeto — `skills/writing-plans/SKILL.md:235-237`, *"If the work genuinely needs a task the spec does not cover, the spec is incomplete: take it back to your human partner rather than smuggling the task in. Amending the spec is cheap now and blocking later."* **Sem quinta rodada de spec review**: os dois carriers foram achados e verificados por outro gate |
