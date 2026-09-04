# Validação de range em check-cross-references — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowersplus:subagent-driven-development or superpowersplus:executing-plans to implement this plan task-by-task — the `**Execution:**` field below names which of the two this plan was handed to, and that is the one to follow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Source spec:** `docs/superpowers/specs/2026-09-04-cross-reference-range-validation-design.md`

**Goal:** Fazer `check-cross-references` reprovar citação de range malformada e
nomear a citação inteira na mensagem de erro.

**Architecture:** Duas mudanças na mesma região do laço de citações de
`skills/writing-plans/scripts/check-cross-references`. A primeira valida o
número inicial antes de abrir o arquivo, porque `0`, `0-N` e `N-M` invertido são
malformados independentemente do conteúdo do arquivo e a comparação de fim de
arquivo não alcança nenhum dos três. A segunda troca as quatro mensagens de
irresolvido por uma citação montada uma vez, que preserva o número final. Cada
uma vem com seus casos em `tests/hooks/test-check-cross-references.sh`, na forma
de par que a suíte já pratica: um documento limpo que passa e o mesmo documento
com uma citação quebrada que falha.

**Tech Stack:** `bash` na suíte (`tests/hooks/test-check-cross-references.sh:1`)
e `python3` dentro do script, que **é um script bash** — a linha 1 é
`#!/usr/bin/env bash` e o python vive num heredoc que abre em
`skills/writing-plans/scripts/check-cross-references:104`
(`python3 - "$doc" "$root" "$script_dir" <<'PY'`). A correção deste plano é
inteiramente dentro desse heredoc. Nenhuma entrada nova: a spec declara
`## External Dependencies` como `None`.

**Execution:** _(em branco até seu parceiro escolher o caminho ao fim de writing-plans)_

**Escalation shape** (detail and a worked example: `../../../skills/using-superpowers/references/escalation-format.md`):
1. **What breaks or costs** if nothing is decided — one sentence, the consequence and not the mechanism.
2. **2–4 options with the cost of each**, always including doing nothing now.
3. **A recommendation naming which source backs it** — a project pattern at `file:line`, the dependency's official docs, or general practice declared as such.
4. **Before sending, reread the whole message once**, looking for terms someone outside this project would not know. Rewrite each in plain language, or define it in the sentence that uses it.

## Global Constraints

Copiadas da `## Implicit Requirements` da spec. Vinculam toda task.

- **IR1** — Nenhuma citação hoje presente em `docs/`, `skills/`, `CLAUDE.md`,
  `AGENTS.md` ou `CHANGELOG.md` passa a ser reprovada pela regra nova. A
  contagem é verificada por execução do script corrigido sobre o corpus, não
  estimada.
- **IR2** — A mudança não introduz dependência externa.
- **IR3** — O caso de baseline pinado em
  `tests/hooks/test-check-cross-references.sh:34` continua verde: nenhum
  documento já commitado muda de veredito por esta correção. Se algum mudar, é
  violação de IR1 e a causa se investiga antes de ajustar o teste.
- **IR4** — `CHANGELOG.md` recebe entrada em `[Unreleased]`, exigida por
  `scripts/check-changelog.sh` para mudança sob `skills/`.
- **IR5** — Os casos de AC7 e AC8 rodam contra o repositório descartável que
  `tests/hooks/test-check-cross-references.sh:47-54` constrói, com seu
  `src/verify.ts` de 20 linhas conhecidas, e nunca contra arquivo do
  repositório, cujo tamanho muda sem aviso.

**Baseline medida em 04/09/2026, antes da primeira task:**
`tests/hooks/test-check-cross-references.sh` sai com código 0 e imprime 33
linhas `[PASS]`; o caso de corpus passa com zero documentos movidos. **O total
de documentos comparados não é baseline**: ele sobe a cada spec ou plano
commitado, e por isso nenhum step deste plano o afirma. `CHANGELOG.md` não tem seção
`[Unreleased]` — a 1.25.0 foi cortada — então a Task 1 a cria.

## Test Coverage Matrix

Toda linha desta matriz vive em `tests/hooks/test-check-cross-references.sh`, a
suíte que `.github/workflows/ci.yml:90` já roda. O nome do caso aparece na
coluna `Test` sem o caminho da suíte porque a célula que nomeia o arquivo **e** o
caso é cobrada contra aquele arquivo antes de a task rodar
(`skills/writing-plans/scripts/check-cross-references:285-289`), o que reprovaria
um caso que este plano ainda vai criar; é a mesma forma que a fixture
`CLEAN_PLAN` da própria suíte usa em
`tests/hooks/test-check-cross-references.sh:130`. O tipo `static` e a camada
`tests/` são o vocabulário deste repositório: `docs/testing.md:6-8` descreve
`tests/` como *"Bash + node + python checks for manifests, plugin loading, hooks,
sync scripts, and skill behavior"*.

**As crases escapadas nos blocos `bash` deste plano não são erro de escrita e não
se "corrigem".** Dentro de uma string bash com aspas duplas, a crase precisa da
contrabarra para não abrir substituição de comando; é assim que o texto tem de
chegar ao arquivo de teste. O efeito colateral é que
`skills/writing-plans/scripts/check-cross-references` não lê essas citações de
fixture como citações deste repositório — a crase de fechamento vem precedida de
contrabarra e o padrão não casa. Remover as contrabarras quebraria o teste **e**
faria o gate reprovar o plano por citar `src/verify.ts`, que existe só dentro do
repositório descartável.

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.1 Uma citação com número inicial `0` e sem range é irresolvida | AC1 | static | `tests/` | > spec citing line zero fails |
| T1.2 Uma citação `0-N` é irresolvida | AC2 | static | `tests/` | > spec citing a zero-based range fails |
| T1.3 Uma citação `N-M` cujo início é maior que o fim é irresolvida | AC3 | static | `tests/` | > spec citing an inverted range fails |
| T1.4 Uma citação cujo fim excede o total de linhas continua irresolvida | AC4 | static | `tests/` | > spec citing a range past the end of the file fails |
| T1.5 Uma citação com `1 <= início <= fim <= total` resolve, e `N-N` é aceita | AC5 | static | `tests/` | > spec with valid ranges passes |
| T1.6 Os quatro casos quebrados derivam do documento limpo por uma única substituição de citação | AC7, IR5 | static | `tests/` | > the four broken range cases differ from the clean one by one citation |
| T1.7 Nenhum documento commitado muda de veredito | IR1, IR3 | static | `tests/` | > the committed corpus keeps its verdicts |
| T2.1 A mensagem de irresolvido nomeia a citação como foi escrita, com o número final | AC6 | static | `tests/` | > an invalid range is reported with its end number |
| T2.2 O caso acima falha se a mensagem omitir o número final | AC8, IR5 | static | `tests/` | > an invalid range is reported with its end number |

**Duas linhas que este repositório não sabe testar, trazidas ao humano conforme
`skills/writing-plans/SKILL.md:257`:**

| Criterion | Spec criterion | Test type | Layer | Test |
|-----------|----------------|-----------|-------|------|
| T1.8 A mudança não acrescenta dependência externa | IR2 | — | — | **NENHUM** — não há camada aqui que asserte ausência de dependência; o instrumento admissível é ler o diff, que é uma propriedade do artefato e não um teste |
| T1.9 `CHANGELOG.md` recebe entrada em `[Unreleased]` | IR4 | — | — | **NENHUM** — `scripts/check-changelog.sh` roda no pre-commit e cobra a entrada no commit, não numa suíte |

T2.1 e T2.2 compartilham um caso porque são as duas metades da mesma asserção: o
caso existe (T2.1) e ele distingue a mensagem certa da errada (T2.2). A
prova de que distingue é a mutação registrada no Step 4 da Task 2, não uma
segunda linha da tabela.

---

### Task 1: Rejeitar range malformado antes de abrir o arquivo

**Spec criterion:** AC1, AC2, AC3, AC4, AC5, AC7; IR1, IR2, IR3, IR4, IR5

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:386-414`
- Test: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: nada de tasks anteriores — esta é a primeira.
- Produces: o laço de citações passa a computar `end` **antes** de `resolve(rel)`
  e a variável `end` já existe quando a comparação de fim de arquivo roda. A
  Task 2 edita as mensagens do mesmo laço e depende de `end` estar computado
  no topo.

**Acceptance criteria:**
- T1.1: Uma citação cujo número inicial é `0`, sem range, é reportada como irresolvida e o script sai com 1 — test: `> spec citing line zero fails`
- T1.2: Uma citação `0-N` é reportada como irresolvida e o script sai com 1 — test: `> spec citing a zero-based range fails`
- T1.3: Uma citação `N-M` cujo início é maior que o fim é reportada como irresolvida e o script sai com 1 — test: `> spec citing an inverted range fails`
- T1.4: Uma citação cujo número final excede o total de linhas continua irresolvida, com saída 1 — test: `> spec citing a range past the end of the file fails`
- T1.5: Uma citação com `1 <= início <= fim <= total de linhas` resolve e o script sai com 0; `N-N` é aceita — test: `> spec with valid ranges passes`
- T1.6: Os quatro casos que falham derivam do documento limpo por uma única substituição de citação, e rodam contra o repositório descartável — test: `> the four broken range cases differ from the clean one by one citation`
- T1.7: Nenhum documento já commitado muda de veredito — test: `> the committed corpus keeps its verdicts`
- T1.8: A mudança não acrescenta dependência externa — sem teste; ver a matriz
- T1.9: `CHANGELOG.md` recebe entrada em `[Unreleased]` — sem teste; ver a matriz

- [ ] **Step 1: Escrever os casos que falham**

Insira o bloco abaixo em `tests/hooks/test-check-cross-references.sh`
imediatamente depois de `run_case "spec citing a file that does not exist fails"`,
que termina na linha 109. `RANGE_SPEC` estende `CLEAN_SPEC`, já definido acima
naquele arquivo, e `break_range` produz cada caso quebrado por **uma**
substituição — é o que torna os cinco casos um par, e não cinco documentos
diferentes.

```bash
# --- range validation -----------------------------------------------------
# The clean side of every pair below. `4-6` is a real range inside the
# 20-line src/verify.ts that make_repo builds, and `7-7` is the N-N form the
# spec accepts without canonicalising it to `7`.
RANGE_SPEC="${CLEAN_SPEC}

A range finding at \`src/verify.ts:4-6\`, and a single-line range at
\`src/verify.ts:7-7\`."

# Each broken case is RANGE_SPEC with ONE citation replaced. A case written
# from scratch would differ from the clean side in ways nobody listed, and a
# pair is only a pair when the difference is the thing under test.
break_range() { printf '%s' "$RANGE_SPEC" | sed "s|src/verify.ts:4-6|$1|"; }

run_case "spec with valid ranges passes" 0 "$RANGE_SPEC"
run_case "spec citing line zero fails" 1 "$(break_range 'src/verify.ts:0')"
run_case "spec citing a zero-based range fails" 1 "$(break_range 'src/verify.ts:0-5')"
run_case "spec citing an inverted range fails" 1 "$(break_range 'src/verify.ts:10-5')"
run_case "spec citing a range past the end of the file fails" 1 "$(break_range 'src/verify.ts:5-99')"

# T1.6: the four broken cases are the clean document minus one citation. If
# break_range ever stops substituting — a renamed path, a changed delimiter —
# every broken case silently becomes RANGE_SPEC itself and passes, and the four
# cases above go green for the opposite of their names.
if [[ "$(break_range 'src/verify.ts:0')" == "$RANGE_SPEC" ]]; then
    fail "the four broken range cases differ from the clean one by one citation"
else
    pass "the four broken range cases differ from the clean one by one citation"
fi
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL — três casos vermelhos com `expected exit 1, got 0`:
`spec citing line zero fails`, `spec citing a zero-based range fails` e
`spec citing an inverted range fails`. Os outros três casos novos já passam:
`spec with valid ranges passes` e
`spec citing a range past the end of the file fails` exercitam o caminho que já
funciona (é a razão de AC4 ser guarda de regressão), e a asserção de T1.6 não
depende do script.

**Se os três não ficarem vermelhos, pare.** Um caso que nasce verde não mediu
nada, e a correção abaixo não teria como provar que entrou.

- [ ] **Step 3: Escrever a correção mínima**

Em `skills/writing-plans/scripts/check-cross-references`, dentro do laço
`for m in CITATION.finditer(text):`, insira a validação logo depois do `continue`
do placeholder e **remova** a linha `end = int(last) if last else first` que hoje
fica pouco antes de `if end > n:`, porque `end` passa a estar computado no topo.
O laço fica assim:

```python
for m in CITATION.finditer(text):
    rel, first, last = m.group(1), int(m.group(2)), m.group(3)
    key = (rel, first, last)
    if key in seen_citations:
        continue
    seen_citations.add(key)
    if "<" in rel:
        continue  # placeholder, unresolvable on purpose
    # The range is judged before the file is opened. `0`, `0-N` and an
    # inverted `N-M` are malformed whatever the file holds, and the
    # end-of-file comparison below sees none of the three: it compares only
    # the END against the line count, so `10-5` in a 20-line file is a
    # citation this check called resolved.
    end = int(last) if last else first
    if first < 1 or end < first:
        unresolved.append(f"`{rel}:{first}` — malformed line range")
        continue
    path, note = resolve(rel)
    if path is None:
        unresolved.append(f"`{rel}:{first}` — {note}")
        continue
    if note:
        shortened += 1
    try:
        n = sum(1 for _ in path.open(encoding="utf-8", errors="replace"))
    except OSError as exc:
        unresolved.append(f"`{rel}:{first}` — cannot read: {exc}")
        continue
    if end > n:
        unresolved.append(
            f"`{rel}:{first}` — {path.name} has {n} line(s)"
            + (f" ({note})" if note else "")
        )
```

A mensagem ainda diz `{rel}:{first}` e portanto ainda descarta o número final —
esse é o defeito da Task 2, deliberadamente fora desta.

- [ ] **Step 4: Rodar para ver passar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — exit 0, e a contagem de `[PASS]` sobe **em 6**: os cinco
`run_case` novos mais a asserção de T1.6. O delta é o que se confere; o total
absoluto muda toda vez que alguém acrescenta um caso a esta suíte.

- [ ] **Step 5: Medir IR1 sobre o corpus inteiro**

O caso `the committed corpus keeps its verdicts` compara vereditos apenas dos
documentos que o commit pinado carrega, e nunca de todos os que a árvore tem,
por isso não responde sozinho a IR1, que fala de todas as citações presentes na
árvore. **O número comparado não se afirma aqui:** ele sobe a cada spec ou plano
commitado, e é o mesmo alvo móvel que o Step 6 se recusa a fixar. Rode o script abaixo, que lê **todos** os arquivos rastreados, sem
filtro de extensão:

```bash
python3 - <<'PY'
import re, subprocess, pathlib
CIT = re.compile(r"`([^`\s]+\.[A-Za-z0-9_]+):(\d+)(?:-(\d+))?`")
files = subprocess.run(["git", "ls-files"], capture_output=True, text=True).stdout.split()
bad, total, scanned = [], 0, 0
for f in files:
    try:
        t = pathlib.Path(f).read_text(encoding="utf-8", errors="replace")
    except OSError:
        continue
    scanned += 1
    for m in CIT.finditer(t):
        total += 1
        first, last = int(m.group(2)), m.group(3)
        if first < 1 or (last and int(last) < first):
            bad.append((f, m.group(0)))
print(f"tracked files read: {scanned} of {len(files)}")
print(f"citations: {total} | newly rejected: {len(bad)}")
for f, c in bad:
    print("  ", f, c)
PY
```

Expected: `newly rejected: 0` — **é essa a parte que carrega peso, e ela não
envelhece.** Os dois números acima dela crescem com a árvore: medidos em
04/09/2026, com os dois planos desta linha de trabalho já commitados, eram 257
de 257 arquivos lidos e 575 citações. **Um número diferente de
zero é violação de IR1 e a causa se investiga antes de tocar em qualquer
teste** — a citação real pode ser o defeito, e nesse caso ela se corrige e o
resultado se registra aqui.

- [ ] **Step 6: Confirmar IR3 pelo caso pinado, nomeando-o**

O caso de baseline de `tests/hooks/test-check-cross-references.sh:34` compara o
veredito de cada documento commitado antes e depois. Rode-o por nome, para que
um verde geral não esconda um caso que deixou de rodar:

```bash
tests/hooks/test-check-cross-references.sh | grep 'the committed corpus keeps its verdicts'
```

Expected: uma linha `[PASS]`, **e nunca um total específico**. O número de
comparados sobe a cada spec ou plano commitado — era 42 documentos quando este
plano começou a ser escrito e 44 depois de os dois planos entrarem — então um
Expected literal é a classe de valor que o implementer ajusta em silêncio no
único step cuja razão de existir é confirmar IR3. **O que se confirma é o
invariante**: `[PASS]`, zero documentos com veredito movido, e um número de
comparados maior que zero. O caso já asserta os três em
`tests/hooks/test-check-cross-references.sh:517-531` — a guarda de "não deu para
rodar", a de zero comparados, o `pass` e a falha por documento movido, nessa
ordem — e a razão de a contagem decair está em
`tests/hooks/test-check-cross-references.sh:27-32`.

- [ ] **Step 7: Rodar a suíte inteira de hooks**

```bash
for t in tests/hooks/test-*.sh; do "$t" >/dev/null 2>&1 || echo "FALHOU: $t"; done
```

Expected: nenhuma linha `FALHOU`.

- [ ] **Step 8: Escrever a entrada de CHANGELOG**

`CHANGELOG.md` não tem seção `[Unreleased]`: a 1.25.0 foi cortada. Crie-a
imediatamente acima de `## [1.25.0] - 2026-09-04`, que está na linha 12:

```markdown
## [Unreleased]

### Fixed

- **`check-cross-references` aprovava range malformado.** A validação comparava
  só o número final contra o total de linhas do arquivo
  (`skills/writing-plans/scripts/check-cross-references:409-410` antes desta
  mudança), então `arquivo:0`, `arquivo:0-5` e `arquivo:10-5` eram reportados
  como resolvidos. Medido por execução com controle em 04/09/2026: os três
  saíam com código 0, e o caso de controle — um fim além do arquivo — saía com
  1, provando que o instrumento funcionava e que os três passavam de verdade.
  O script roda entre o conserto de uma spec ou plano e o re-despacho do
  reviewer, para poupar uma rodada; uma citação malformada aprovada custava
  exatamente a rodada que ele existe para economizar.
```

- [ ] **Step 9: Conferir a preparação antes de commitar**

Nunca encadeie a edição e o `git commit`. Rode primeiro:

```bash
git diff --stat
grep -n '^## \[Unreleased\]' CHANGELOG.md
```

Expected: três arquivos no diff — o script, a suíte e o `CHANGELOG.md` — e a
seção `[Unreleased]` na linha 12.

- [ ] **Step 10: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references \
        tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix: check-cross-references aprovava linha zero e range invertido"
```

---

### Task 2: A mensagem de irresolvido nomeia a citação inteira

**Spec criterion:** AC6, AC8; IR4, IR5

**Files:**
- Modify: `skills/writing-plans/scripts/check-cross-references:386-414`
- Test: `tests/hooks/test-check-cross-references.sh`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: o laço de citações como a Task 1 o deixou — `end` computado antes de
  `resolve(rel)`, e **quatro** chamadas a `unresolved.append` formatando
  `` f"`{rel}:{first}` — …" ``. **A spec fala em três** (AC6 nomeia `:400`, `:407`
  e `:411-412`) porque foi escrita contra o arquivo original; a quarta é a que a
  Task 1 acrescentou, e ela cai sob a mesma regra. Quatro é o número correto
  depois da Task 1, e é o que a auditoria vai encontrar.
- Produces: uma variável `cite` no topo do laço, com o texto da citação como foi
  escrita. Nenhuma task posterior a consome; este plano tem duas tasks.

**Acceptance criteria:**
- T2.1: A mensagem de cada citação irresolvida nomeia a citação completa como foi escrita, incluindo o número final quando há range — test: `> an invalid range is reported with its end number`
- T2.2: O caso acima falha se a mensagem omitir o número final, e roda contra o repositório descartável — test: `> an invalid range is reported with its end number`

- [ ] **Step 1: Escrever o caso que falha**

`run_case` compara apenas o código de saída, e a Task 1 já deixou
`spec citing an inverted range fails` verde — um caso que só olha o exit code
não distingue mensagem certa de errada. Este caso lê a saída. Insira-o em
`tests/hooks/test-check-cross-references.sh` logo depois do bloco que a Task 1
acrescentou:

```bash
# AC8: the message names the citation as it was written. Before this fix all
# four unresolved paths formatted `{rel}:{first}` — the three the script always
# had, plus the one Task 1 added — so an invalid `10-5` was
# reported as line 10 — a line that exists in the file, sending the reader to
# the wrong place. run_case cannot see this: the exit code was already 1.
msg_dir="$TEST_ROOT/range_message"
make_repo "$msg_dir"
printf '%s\n' "$(break_range 'src/verify.ts:10-5')" >"$msg_dir/docs/doc.md"
msg_out="$("$SCRIPT_UNDER_TEST" "$msg_dir/docs/doc.md" "$msg_dir" 2>&1 || true)"
if printf '%s' "$msg_out" | grep -q 'verify\.ts:10-5'; then
    pass "an invalid range is reported with its end number"
else
    fail "an invalid range is reported with its end number"
    printf '%s\n' "$msg_out" | sed 's/^/        /'
fi
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: FAIL — `[FAIL] an invalid range is reported with its end number`,
seguido da saída do script, em que a citação aparece truncada na linha inicial,
sem o `-5` que o documento escreveu.

- [ ] **Step 3: Escrever a correção mínima**

Monte a citação uma vez, logo depois do desempacotamento, e use-a nas quatro
chamadas. `cite` é montado antes do `continue` do placeholder porque é texto e
não depende de o caminho resolver:

```python
for m in CITATION.finditer(text):
    rel, first, last = m.group(1), int(m.group(2)), m.group(3)
    key = (rel, first, last)
    if key in seen_citations:
        continue
    seen_citations.add(key)
    # The citation as it was written. Every unresolved message below names
    # this, never `{rel}:{first}`: dropping the end number reports a line that
    # exists in the file, and the reader looks for the defect there.
    cite = f"{rel}:{first}-{last}" if last else f"{rel}:{first}"
    if "<" in rel:
        continue  # placeholder, unresolvable on purpose
    end = int(last) if last else first
    if first < 1 or end < first:
        unresolved.append(f"`{cite}` — malformed line range")
        continue
    path, note = resolve(rel)
    if path is None:
        unresolved.append(f"`{cite}` — {note}")
        continue
    if note:
        shortened += 1
    try:
        n = sum(1 for _ in path.open(encoding="utf-8", errors="replace"))
    except OSError as exc:
        unresolved.append(f"`{cite}` — cannot read: {exc}")
        continue
    if end > n:
        unresolved.append(
            f"`{cite}` — {path.name} has {n} line(s)"
            + (f" ({note})" if note else "")
        )
```

- [ ] **Step 4: Rodar para ver passar, e provar que a mutação entra**

Run: `tests/hooks/test-check-cross-references.sh`
Expected: PASS — exit 0, e a contagem de `[PASS]` sobe **em 1** em relação ao
fim da Task 1: o caso que lê a mensagem. Confira o delta, não o total.

Depois, prove que o caso mede o mecanismo e não um vizinho. Troque
`cite = f"{rel}:{first}-{last}" if last else f"{rel}:{first}"` por
`cite = f"{rel}:{first}"`, rode de novo e confirme
`[FAIL] an invalid range is reported with its end number`. **Restaure a linha
antes de seguir** e rode a suíte mais uma vez para confirmar exit 0.

- [ ] **Step 5: Rodar a suíte inteira de hooks**

Run: `for t in tests/hooks/test-*.sh; do echo "== $t"; "$t" >/dev/null || echo "FALHOU: $t"; done`
Expected: nenhuma linha `FALHOU`. Interessa em especial
`tests/hooks/test-check-links.sh`, que lê mensagens de gate, e o caso pinado de
baseline dentro da própria suíte deste script.

- [ ] **Step 6: Acrescentar a entrada de CHANGELOG**

Sob a mesma seção `### Fixed` que a Task 1 criou em `[Unreleased]`:

```markdown
- **A mensagem de citação irresolvida descartava o número final.** As três
  chamadas que o script tinha antes desta versão — a quarta é a que a validação
  de range acrescentou, e cai sob a mesma regra — formatavam
  `` `{rel}:{first}` ``, então um range inválido `5-200` era reportado como a
  linha `5` — que existe no arquivo. Quem lia o erro procurava o defeito no
  lugar errado. A citação passa a ser montada uma vez, como foi escrita.
```

- [ ] **Step 7: Conferir a preparação antes de commitar**

```bash
git diff --stat
tests/hooks/test-check-cross-references.sh | tail -3
```

Expected: três arquivos no diff e `All check-cross-references tests passed`.

- [ ] **Step 8: Commit**

```bash
git add skills/writing-plans/scripts/check-cross-references \
        tests/hooks/test-check-cross-references.sh CHANGELOG.md
git commit -m "fix: a mensagem de citação irresolvida perdia o numero final do range"
```
