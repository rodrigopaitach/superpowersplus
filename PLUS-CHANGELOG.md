# PLUS Changelog

Mudanças deste fork ([rodrigopaitach/superpowersplus](https://github.com/rodrigopaitach/superpowersplus))
sobre o upstream [obra/superpowers](https://github.com/obra/superpowers).
Entradas `plus.N` são numeradas na ordem em que entraram no fork.
O campo `version` em `.claude-plugin/plugin.json` e `package.json` espelha o
upstream e não é alterado aqui — a numeração `plus.N` é independente dele.

Fio condutor das entradas: **evidence-or-zero** — toda afirmação sobre o
código exige citação `caminho/arquivo:linha`, e quem verifica reexecuta a
busca em vez de aceitar a palavra de quem escreveu.

## plus.9 — requisito implícito entra na matriz de cobertura

O `brainstorming` é bom em levantar requisito implícito — concorrência,
tratamento de erro, observabilidade, caso de borda, limite —, mas nada
obrigava esses achados a virarem linha da Test Coverage Matrix. Eles morriam
na spec: sem id, não entram na rastreabilidade; sem linha na matriz, ninguém
planeja o teste; e nenhum verificador consegue notar a falta do que nunca
foi nomeado.

- **`## Implicit Requirements`** — nova seção obrigatória da spec, numerada
  `IR1`, `IR2`, …, escrita na mesma forma de um critério de aceite: um
  comportamento observável, resolvível por citação `arquivo:linha`. Sem
  nenhum, escreve-se "None".
- **Um só espaço de ids** — `AC` e `IR` são cobrados de forma idêntica
  daí em diante: a tarefa do plano nomeia qualquer um dos dois no
  `**Spec criterion:**`, a matriz dá uma linha a cada um, e a tabela de
  rastreabilidade da auditoria trata `IR` sem tarefa como `LOST IN
  TRANSLATION`, igual a um `AC`.
- **Primeira classe na matriz** — `IR` recebe tipo de teste nomeado, camada
  real e id exato de teste, nas mesmas condições de um `AC`. `IR` sem linha
  é omissão, não escolha; e o que não puder ser testado nas camadas
  existentes vai declarado na linha e levado ao parceiro humano, nunca
  descartado em silêncio.
- **Regra do par nas duas pontas** — o revisor de spec bloqueia seção
  ausente e requisito implícito discutido na prosa sem id `IR` ("é
  não-funcional" não vale como bar mais baixa); o revisor de plano cobra a
  cobertura e a linha da matriz para `AC` e `IR` igualmente.
- **Exemplos atualizados** — todos os que enumeram critério: matriz do
  cabeçalho do plano, as duas tabelas da auditoria, a tabela `Test Evidence`
  do task reviewer e a transcrição em
  `subagent-driven-development/references/example-workflow.md`, que depois do
  plus.8 já não vive no SKILL.md.

## plus.8 — progressive disclosure no skill do controlador

`subagent-driven-development/SKILL.md` estava com 577 linhas, acima das 500
recomendadas pela documentação oficial de Agent Skills, e fica no contexto do
controlador durante a execução inteira. Reorganização de carregamento, não
corte: nenhuma regra saiu, encolheu ou foi fundida.

- **`references/final-review.md`** — o protocolo das duas portas finais e da
  fix wave, necessário em UMA fase (depois da última tarefa). No SKILL.md
  ficou o link e a linha dizendo quando abrir. O texto foi movido verbatim;
  as duas únicas diferenças são os caminhos relativos dos links, que ganham
  um nível (`../re-review-prompt.md`, `../../requesting-code-review/`).
- **`references/example-workflow.md`** — a transcrição de sessão inteira,
  ilustração lida no máximo uma vez. Movida byte a byte.
- **O que NÃO saiu** — digrafo do processo, Setup, Model Selection, o loop de
  tarefa completo com a fix loop e o breaker, e a tabela de racionalizações:
  ou são decididos no início do fluxo, ou consultados em mais de uma fase.
  Na dúvida, o trecho ficou.
- **Contagem** — pasta inteira: 1092 → 1112 linhas (as duas referências
  custam cabeçalho e ponteiro). `SKILL.md`: 577 → 461. Nenhum arquivo de
  referência passa de 100 linhas, então nenhum precisou de índice, e a
  referência é de um nível só.

## plus.7 — obrigação de teste alinhada ao Iron Law do TDD

`implementer-prompt.md` mandava "Write tests (following TDD **if task says
to**)" — condicional que contradizia o Iron Law de `test-driven-development`
("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST"). Duas regras opostas no
mesmo repositório: o modelo escolhe a mais barata, e a mais barata era não
testar quando a task esquecesse de pedir. O prompt é o que o subagente
implementador realmente lê.

- **Teste deixa de ser condicional** — o passo virou obrigação, com o Iron
  Law citado literalmente. As exceções são as três já declaradas na skill
  (protótipo descartável, código gerado, arquivo de configuração) e nenhuma
  nova; todas exigem permissão do parceiro humano, então o implementador
  pede via `NEEDS_CONTEXT` em vez de se autoconceder uma.
- **Ordem da lista corrigida** — "1. Implement … 2. Write tests" descrevia
  código antes do teste no próprio texto. Agora o teste que falha vem
  primeiro, e a implementação é o código mínimo que o faz passar.
- **Autorreview e relatório** — "Did I follow TDD **if required**?" virou
  "vi cada teste falhar antes de escrever o código que o faz passar", e a
  seção `TDD Evidence`, que era `(if TDD was required for this task)`, passa
  a ser exigida em toda tarefa: havendo exceção, o relatório nomeia qual e
  quem autorizou.

## plus.6 — contrato do plano cobrado por subagente revisor

O plus.5 armou o `plan-document-reviewer-prompt.md` com o contrato do plano,
mas o arquivo continuava órfão: `writing-plans` declarava a revisão como
"a checklist you run yourself — not a subagent dispatch". Autor revisando o
próprio plano tem o mesmo defeito de autor revisando a própria spec, que o
plus.1 já tinha resolvido despachando subagente.

- **`## Self-Review` → `## Plan Review`** — os 6 itens de autorrevisão saíram
  e no lugar entra o despacho do `plan-document-reviewer-prompt.md`, mesmo
  padrão do `spec-document-reviewer`: salvar primeiro (o revisor lê o
  arquivo, não o contexto), corrigir todo bloqueante, redespachar,
  recomendação é advisory. Requisito da spec sem tarefa se resolve
  acrescentando a tarefa, nunca estreitando o escopo declarado do plano.
- **Origem amarrada** — o despacho passa só o caminho do plano. O caminho da
  spec sai do cabeçalho do próprio plano, porque conferir isso é parte da
  revisão.
- **Nada de checagem perdida na troca** — os itens 1, 4, 5 e 6 do antigo
  Self-Review já eram cobrados pelo `The Plan Contract`; o item 3
  (consistência de tipos e assinaturas entre tarefas) virou a categoria
  `Internal Consistency`, e o item 2 virou a lista explícita de placeholders
  na categoria `Completeness` — o revisor é standalone e não lê a skill.
- **Handoff** — as opções de execução são apresentadas depois que a revisão
  passa, não logo após salvar.

## plus.5 — varredura de consistência do fork

Varredura por REGRA, não por arquivo: regra introduzida aqui pode ter eco em
arquivo nunca tocado — foi o que aconteceu com a reexecução de testes
(plus.3), que vivia em três lugares, dois deles intocados. Cinco
bloqueantes; os cosméticos ficaram registrados sem correção.

- **`subagent-driven-development` não lia a spec** — `executing-plans` trata
  plano sem spec citada como bloqueio de entrada, mas o executor
  RECOMENDADO, que é quem despacha a auditoria no fim, nunca abria a spec. A
  branch inteira rodava para morrer em `LOST IN TRANSLATION`. Setup e
  digraph do Process Flow agora exigem a leitura da spec citada antes da
  Task 1.
- **Revisor de plano não cobrava o cabeçalho** — `plan-document-reviewer-prompt.md`
  ignorava tudo que virou obrigatório (caminho da spec, Test Coverage
  Matrix, `**Spec criterion:**` por tarefa, critério auditável) e mandava
  aprovar salvo "major scope creep" / "serious gaps": o que a auditoria
  bloqueia, ele aprovava. Nova tabela `The Plan Contract (blocking)` com
  seis linhas, carve-out da calibração, e o caminho da spec passa a vir do
  cabeçalho do plano em vez de ser injetado no despacho.
- **A spec não tinha critérios endereçáveis** — a auditoria cobra "uma linha
  por critério da spec" e o plano nomeia o critério de cada tarefa, mas
  `brainstorming` só exigia `Codebase Findings` e `Assumptions to Confirm`:
  a origem das linhas ficava no julgamento do auditor, e dois auditores
  enumeram conjuntos diferentes. Nova seção obrigatória `## Acceptance
  Criteria` (numerada, um comportamento observável por item), cobrada como
  bloqueante pelo revisor de spec (`Traceability`) e citada por id (`AC1`)
  na tabela de rastreabilidade. Spec sem a seção é achado bloqueante, mas a
  auditoria segue traçando pelos títulos numerados — o baseline existe e foi
  aprovado, só não está indexado.
- **Exemplo que contradizia formato obrigatório** — o Example Workflow do
  SDD fechava task review sem a tabela `### Test Evidence` (sem a qual "a
  tarefa não fecha") e mostrava PASS da auditoria sem linha de
  rastreabilidade. Exemplo é a regra mais barata de imitar.
- **Face de produtor inalcançável** — o litmus anti-teste-raso estava em
  `test-driven-development` e no revisor, mas quem escreve o teste é o
  subagente que roda com `implementer-prompt.md`, e lá o autorreview só
  perguntava "Are tests comprehensive?". As três checagens bloqueantes mais
  o mapeamento para o brief entraram no prompt; a pergunta não quantificada
  saiu.

## plus.4 — rastreabilidade spec → tasks na auditoria

A auditoria comparava o plano consigo mesmo. Requisito que se perdeu na
tradução da spec para o plano não deixa rastro NO plano — e tarefa que ninguém
pediu passa por toda revisão de task, porque cada revisão vê um diff só.

- **Tabela de rastreabilidade, antes da de tarefas** — `Critério da spec |
  Tarefa(s) que cobrem | veredito`, nos dois sentidos: critério sem tarefa é
  `LOST IN TRANSLATION`, tarefa sem critério de origem é `INVENTED SCOPE`. As
  duas bloqueiam o PASS igual a uma linha `NOT DELIVERED`.
- **Origem amarrada** — o caminho da spec vem do próprio plano, que é artefato
  sob auditoria; então o auditor confirma que o arquivo existe e está
  commitado (`git log -1 -- <spec>`). Plano sem spec citada é bloqueante, e
  inferir qual documento em `docs/` era o certo está proibido: seria auditar
  contra baseline que ninguém aprovou.
- **Roteamento próprio** — falha de rastreabilidade não entra na fix wave como
  lacuna de entrega: `LOST IN TRANSLATION` é mudança de plano e `INVENTED
  SCOPE` é decisão de emendar a spec ou remover o trabalho. Ambas vão para o
  parceiro humano, não para o fixer.
- **`writing-plans`** — o cabeçalho do plano cita o caminho exato e commitado
  da spec, e cada tarefa nomeia o critério que a motivou. Novo item 5 do
  Self-Review lê nas duas direções.
- **`executing-plans`** — o Step 1 lia só o plano e chegava na auditoria sem
  nunca ter aberto a spec. Passa a exigir a leitura da spec citada, e plano sem
  spec citada vira bloqueio de entrada: pede-se o caminho antes de começar, não
  se resolve depois.

## plus.3 — matriz de cobertura e revisor de task que reexecuta a suíte

Nada garantia que o teste prometido na spec virasse teste real no código. Pior:
o `task-reviewer-prompt.md` mandava NÃO reexecutar a suíte, confiando no
relatório de quem escreveu os testes — o autor avaliando o próprio trabalho de
teste.

- **`## Test Coverage Matrix`** — nova seção obrigatória no cabeçalho do plano
  (`writing-plans`): uma linha por critério de aceite, com tipo de teste e
  camada. Antes de montá-la o agente lê as convenções do repositório
  (`CLAUDE.md`/`AGENTS.md`, config do runner, CI, testes existentes) e cita
  `arquivo:linha` — registra o padrão em uso em vez de importar um de fora.
- **Revisor reexecuta** — a instrução "do not re-run the suite" saiu. O revisor
  roda o comando de teste da tarefa, reporta comando/exit code/contagens,
  confere que a contagem não caiu e lê o diff atrás de teste apagado, renomeado
  ou recém-marcado como `skip`/`xfail`/`.only`. Continua read-only: roda os
  testes, nunca faz checkout nem reset.
- **Tabela `Critério | teste arquivo:linha | asserção`** — uma linha por
  critério do brief, inclusive os sem teste. Sem a tabela a tarefa não fecha, e
  relatório que a omite é ele próprio o achado.
- **Litmus anti-teste-raso (bloqueante)** — asserção que não pode falhar
  (`expect(true)`, teste sem asserção), asserção só em mock (contagem de
  chamada/existência) e happy path só quando há casos de borda listados. Mais a
  checagem inversa: teste que não mapeia para requisito da matriz é escopo
  inventado, reportado como Extra.
- **`test-driven-development`** — as mesmas exigências declaradas onde o teste é
  produzido, com o litmus, o mapeamento para a matriz e 4 itens novos no
  checklist de verificação.
- **Regra apodrecida removida em três lugares** — a mesma instrução vivia
  espalhada e teria deixado a mudança inerte: `subagent-driven-development`
  proibia o controlador de pedir reexecução, e o `re-review-prompt` dispensava
  a suíte depois do fix loop. Os dois agora declaram que o revisor reexecuta e
  que relato do implementador não é evidência. O re-review também reporta
  comando, exit code e contagens, e trata achado "corrigido" apagando o teste
  que o pegou como NOT ADDRESSED.
- **Face de produtor alinhada** — `implementer-prompt.md` dizia ao implementador
  que o relatório dele ERA a evidência de teste. Agora diz o contrário: o
  re-revisor roda o mesmo comando, e o relatório existe para as duas execuções
  serem comparadas — daí a exigência de registrar comando e contagens.
- **Code reviewer final** — "All tests passing?" era pergunta sem método
  declarado, respondível pela leitura do diff. Passa a exigir execução da
  suíte, com comando, exit code e contagens na seção `### Test Run`, mais a
  checagem de teste apagado/renomeado/marcado `skip` no range. Sem comando no
  despacho, o revisor deriva da config do runner e declara qual usou.
- **Placeholders documentados no despacho** — o controlador aprende onde obter
  `[TEST_COMMAND]` (matriz do plano ou config do runner, confirmado antes de
  passar) e `[BASE_TEST_COUNT]` (contagem da review anterior; `unknown` quando
  não houver, nunca preenchido a partir do relatório do implementador, que é
  justamente o número sob auditoria).

## plus.2 — auditoria de conformidade tarefa a tarefa na revisão final da branch

A revisão final era só revisão de qualidade do diff da branch. Nada obrigava
a percorrer TODAS as tarefas do plano e provar, uma a uma, que os critérios
foram atendidos — e revisor nenhum sinaliza tarefa que ninguém implementou,
porque código ausente não gera diff.

- **Nova skill `final-branch-audit`** — percorre todas as tarefas do plano e
  produz tabela obrigatória `Tarefa | Critério | implementação arquivo:linha |
  teste arquivo:linha | veredito`. Sem citação localizada, a tarefa conta como
  NÃO entregue; implementação sem teste também. É read-only e o auditor
  reexecuta as buscas — plano, ledger e report do implementador são
  alegações sob auditoria, não evidência.
- **`FALSE COMPLETION`** — tarefa marcada como concluída (checkbox do plano ou
  linha `complete` no ledger) sem evidência é achado de severidade máxima, e o
  único que nunca pode ser parkado.
- **`subagent-driven-development`** — a auditoria é despachada ANTES do
  code-reviewer, no modelo mais capaz; as lacunas entram na mesma onda de
  correção dos achados de review.
- **Fix wave com loop** — a regra de onda única ("there is no second fix
  wave") virou até 3 iterações corrigir/reverificar; estacionamento com
  justificativa só depois da terceira.
- **`finishing-a-development-branch`** — novo Step 2 exige auditoria rodada e
  com veredito PASS antes de apresentar as opções de merge. Cobre também quem
  chegou por `executing-plans`, caminho que não tinha revisão final nenhuma.
- **`writing-plans`** — cada tarefa registra critérios de aceite verificáveis
  por evidência localizada, no formato que a auditoria vai cobrar (um
  comportamento observável por critério, com o teste que o cobre nomeado).
- **Alinhamento** — `README.md` lista a skill nova no fluxo;
  `requesting-code-review` declara que a auditoria roda antes do code review;
  `executing-plans` passa a exigir critérios auditáveis na leitura do plano e
  a auditoria como Step 3 obrigatório.

## plus.1 — spec fundamentada em evidência do código

A spec era escrita com base no que o agente supunha sobre o código. O
levantamento da realidade era uma linha solta no checklist ("Explore project
context"), sem obrigação de evidência.

- **`brainstorming`** — o item 1 do checklist virou investigação obrigatória
  do código real (arquivos, testes, configs, commits) ANTES de qualquer
  pergunta ao usuário.
- **`## Codebase Findings`** — seção obrigatória na spec: toda afirmação sobre
  o sistema existente exige citação `arquivo:linha` mais o trecho citado.
- **`## Assumptions to Confirm`** — seção obrigatória para o que não foi
  possível verificar, com o registro da busca feita e o motivo. Fato
  verificável no código não pode ser declarado como suposição.
- **Revisor de spec** — a autorrevisão inline de 4 checagens foi substituída
  por despacho do subagente `spec-document-reviewer-prompt.md` (até então
  órfão no repo), com categoria `Groundedness`: o revisor abre cada
  `arquivo:linha` citado e confirma que existe e faz o que a spec afirma.

## Pendências conhecidas

Buracos identificados e deliberadamente não fechados. Ficam aqui porque
lacuna sem registro volta como descoberta.

- **Iron Law do TDD sem face verificadora** — o `implementer-prompt.md` exige
  teste antes do código (plus.7), mas nenhum verificador consegue provar a
  ordem: o único registro de que o teste veio antes é a seção `TDD Evidence`
  do relatório, produzida por quem está sendo auditado. Gate baseado nela
  seria decorativo. Opção avaliada e não implementada: exigir teste e
  implementação em commits separados, teste primeiro, o que o revisor
  verificaria pela ordem dos commits no review package. Adiada porque muda a
  granularidade de commit de todo trabalho feito com o fork — custo que não
  se justifica antes de haver medição de quanto o teste-depois escapa na
  prática.
- **Sensor de mutação** — nenhuma checagem atual mata o teste que passa por
  acidente: o litmus anti-teste-raso pega padrão sintático (`expect(true)`,
  asserção só em mock), não asserção que simplesmente não alcança o
  comportamento. O verificador injetaria uma falha comportamental em estado
  descartável e confirmaria que a suíte a mata; teste que sobrevive à
  mutação não testa o mecanismo. Adiado até haver uso real do fork — sem
  execuções para calibrar quais mutações valem o custo, a checagem entraria
  como ritual.
