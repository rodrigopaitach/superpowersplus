# PLUS Changelog

Mudanças deste fork ([rodrigopaitach/superpowersplus](https://github.com/rodrigopaitach/superpowersplus))
sobre o upstream [obra/superpowers](https://github.com/obra/superpowers).
Entradas `plus.N` são numeradas na ordem em que entraram no fork.
O campo `version` em `.claude-plugin/plugin.json` e `package.json` espelha o
upstream e não é alterado aqui — a numeração `plus.N` é independente dele.

Fio condutor das entradas: **evidence-or-zero** — toda afirmação sobre o
código exige citação `caminho/arquivo:linha`, e quem verifica reexecuta a
busca em vez de aceitar a palavra de quem escreveu.

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
