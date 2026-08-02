# PLUS Changelog

Mudanças deste fork ([rodrigopaitach/superpowersplus](https://github.com/rodrigopaitach/superpowersplus))
sobre o upstream [obra/superpowers](https://github.com/obra/superpowers).
Entradas `plus.N` são numeradas na ordem em que entraram no fork.
O campo `version` em `.claude-plugin/plugin.json` e `package.json` espelha o
upstream e não é alterado aqui — a numeração `plus.N` é independente dele.

Fio condutor das entradas: **evidence-or-zero** — toda afirmação sobre o
código exige citação `caminho/arquivo:linha`, e quem verifica reexecuta a
busca em vez de aceitar a palavra de quem escreveu.

## plus.18 — face verificadora do caminho realmente entregue pelo pacote

O plus.17 pôs no produtor da spec a regra que o próprio defeito produziu —
abrir o caminho antes de citá-lo, porque diretório que existe no repositório
do fornecedor não é sempre um que o pacote publicado entrega. Ela ficou sem
quem cobrasse.

- **Linha bloqueante nos dois revisores** — citação em forma pinned source
  cujo caminho não existe no pacote instalado é achado bloqueante, não
  aproximação aceitável. O revisor abre o caminho; plausibilidade não é
  verificação. `stripe` é o caso que gerou a regra: `src/*.ts` no GitHub,
  `cjs/*.js` no `node_modules`.
- **Procedimento distingue os dois fracassos** — pacote instalado e caminho
  ausente é a linha bloqueante; dependência não instalada neste checkout é
  `Unverified External Claims` / `Unverified External Calls`. Antes os dois
  caíam no mesmo "say so", e o primeiro é erro de citação enquanto o segundo
  é limite do ambiente.
- **A face produtora do plano também estava faltando** — `writing-plans`
  dizia que o passo carrega "the same forms" e nunca mandava abrir o
  caminho. Acrescentar a linha só ao revisor teria criado a pegadinha que a
  regra do par existe para evitar, então a regra entrou nas quatro faces:
  produtor e revisor da spec, produtor e revisor do plano.

## plus.17 — dependência única nos exemplos de grounding

O plus.16 corrigiu os exemplos do plano e deixou os do brainstorming para
trás: o fork ficou com `stripe@14.21.0` numa skill e `stripe@19.1.0` em
outra, e os caminhos antigos apontavam para `node_modules/stripe/src/*.js`.
No `stripe-node`, `src/` é TypeScript (`src/lib.ts`, `src/resources/*.ts`) e
o pacote publicado entrega `cjs/` — aquele caminho não existe em instalação
alguma. Citação inverificável num exemplo de citação, o mesmo defeito do
plus.16.

- **Caminho verificado, não deduzido** — `cjs/resources/PaymentIntents.js`
  foi confirmado no pacote publicado `stripe@19.1.0` antes de entrar: o
  arquivo existe e define `create` como `POST /v1/payment_intents`. As duas
  URLs de doc também foram abertas e conferidas
  (`/api/payment_intents/create` e `/api/idempotent_requests`).
- **Regra que o próprio defeito produziu** — a linha da forma "pinned
  source" agora manda abrir o caminho antes de citá-lo, porque *"a directory
  that exists in the vendor's repository is not always one the published
  package ships"*. Era exatamente o buraco: `src/` existe no repositório do
  fornecedor e não no tarball.
- **Forma de citação por seção** — o exemplo de `## External Dependencies`
  passou à forma doc oficial, idêntica à que o plus.16 deixou no plano. A
  tabela de `### Claims about a dependency` **manteve** as duas formas, uma
  por linha: ela é a definição das formas, e trocar a linha "pinned source"
  por uma URL apagaria do fork uma das duas em que plus.12 e plus.13 se
  apoiam.
- **Uma versão em todo o fork** — `stripe@19.1.0` nos quatro pontos que
  citam dependência. Efeito colateral bem-vindo: o exemplo abstrato de
  divergência de versão ("holds at v14 and not at the pinned v9") deixou de
  colidir com a versão do exemplo concreto, que antes era 14.21.0.

## plus.16 — o exemplo de grounding citava fonte de outra linguagem

Achados da varredura de exemplos duplicados do plus.15, corrigidos em vez de
adiados.

- **Fonte JavaScript fundamentando código Python** — o exemplo de
  `## Code That Calls a Dependency` mostrava
  `intent = stripe.PaymentIntent.create(...)` citando
  `node_modules/stripe/src/resources/PaymentIntents.js:41`. O único exemplo
  do fork cuja função é ensinar grounding correto ensinava o erro que a
  seção existe para proibir: citação que não pode fundamentar o código
  exibido. Agora é JavaScript com fonte JavaScript, e as duas cópias
  (`writing-plans/SKILL.md` e `plan-document-reviewer-prompt.md`) são
  idênticas caractere a caractere.
- **Regra nova, nas duas faces** — "a citação e o código têm que ser a mesma
  linguagem: uma fonte JavaScript não fundamenta uma chamada Python, por
  mais real que seja a linha apontada". No revisor a linha fecha com
  "descasamento de linguagem entre o comentário e o código abaixo dele é
  citação que ninguém leu".
- **Divergência sobre o idempotency key resolvida na fonte** — uma cópia
  dizia "goes in options, never in params", a outra perdia o "never in
  params", e o código passava `idempotency_key=key` como keyword argument,
  que não é nem um nem outro. Verificado em `stripe-node`: `create(params,
  options)`, e `idempotencyKey` é campo de `RequestOptions`, o segundo
  argumento. A doc oficial (`https://docs.stripe.com/api/idempotent_requests`)
  confirma: *"provide an additional `IdempotencyKey` element to the request
  options"*. O exemplo passou a usar a forma de citação por doc oficial —
  não a forma lockfile+linha — porque este repositório é zero-dependency e
  não existe lockfile contra o qual confirmar um número de linha. Citação
  que eu não pudesse verificar seria o próprio defeito sendo reintroduzido.
- **Tabela obrigatória exibida no exemplo consumido** —
  `references/example-workflow.md` resumia a Test Evidence em contagem de
  prosa ("3/3 brief criteria … cited to a test file:line"), sem a coluna
  `Assertion`, justamente a que existe para pegar teste que não afirma nada.
  Os dois retornos de revisor do exemplo agora exibem a tabela de três
  colunas, um deles com a linha `—`/`NONE` que dispara a rodada de correção.

## plus.15 — exemplos e faces divergentes

Varredura de consistência achou quatro pontos onde a regra existe e a cópia
dela não acompanhou.

- **Exemplo de retorno do code review sem evidência de teste** — o exemplo
  de despacho em `requesting-code-review/SKILL.md` mostrava o revisor
  devolvendo Strengths / Issues / Assessment. O template que ele despacha
  exige `### Test Run` como primeira seção e `### Recommendations`, e proíbe
  responder "tests pass" sem ter rodado. O único exemplo que o chamador
  tinha de um retorno normal não tinha teste nenhum — a mesma correção dos
  commits `bdf655e` e `0c79b24`, num exemplo que escapou delas.
- **Autoverificação mais estreita que o litmus** — o implementador só
  checava casos de borda listados "no brief ou no `IR` que ele nomeia"; o
  revisor bloqueia quando o brief, **o critério de spec nomeado ou as global
  constraints** listam casos, e conta `limits` entre os que o `IR` abriga. O
  implementador passava na própria revisão e levava Critical no review. As
  duas listas agora são a mesma lista.
- **Seção ausente e seção vazia tinham a mesma aparência** — brainstorming
  exige cinco seções, cada uma com instrução de escrever `"None"` quando
  vazia, mas o revisor de spec só bloqueava a ausência de duas.
  `## Codebase Findings`, `## External Dependencies` e
  `## Assumptions to Confirm` podiam simplesmente não existir. Sem a linha,
  "não checamos nada externo" e "não havia nada externo" são indistinguíveis
  — que é exatamente o que o plus.12 existe para separar.
- **Matriz de cobertura sem as cinco colunas** — o Plan Contract cobrava a
  chave das linhas e a coluna `Spec criterion`, não que `Test type` e
  `Layer` existissem. Matriz de três colunas passava. Sem elas a linha
  declara intenção, não plano.

Varredura nova, que nunca tinha sido feita: **todo exemplo que aparece em
mais de um arquivo, comparado cópia contra cópia.** Divergência entre cópias
é achado mesmo quando nenhuma delas menciona a regra divergente — foi assim
que o exemplo do code review apareceu, porque ele não contradizia a regra,
apenas a omitia, e nenhum grep pela regra o alcançava. Registro do que ficou
em aberto na seção "Pendências conhecidas".

## plus.14 — compressão dos exemplos nos prompts carregados por tarefa

`implementer-prompt.md`, `task-reviewer-prompt.md` e `re-review-prompt.md`
são lidos uma vez por tarefa para montar o dispatch: cada linha custa vezes
N. Compressão de **exemplo**, não de regra — nenhuma seção, coluna, veredito
ou verificação saiu.

- **Células e texto ilustrativo encolhem, colunas ficam** — a linha de
  exemplo da Test Evidence perdeu o caminho longo (`tests/auth/test_verify.py:41`
  → `test_verify.py:41`) e a redundância na célula do critério, mantendo as
  três regras que ela carrega: verbatim do brief, rótulo `T3.1`, proibição
  de `AC`/`IR`. Três colunas antes, três depois.
- **Checklists de pergunta única viram linha única** — `Completeness`,
  `Quality`, `Discipline` (implementer) e `Code quality`, `Structure`
  (revisor) tinham uma linha de bullet por pergunta; as mesmas perguntas,
  todas elas, cabem em duas linhas de prosa por grupo. O litmus de teste
  raso e os seis checks de Testing continuam como bullets: cada um é um
  achado bloqueante, e bullet separado é o que faz cada um ser tickado.
- **Definição junto do valor** — os quatro status do implementador eram
  enumerados numa linha e definidos três parágrafos abaixo; agora a
  definição está entre parênteses ao lado de cada um.
- **Redundância removida** — o `**Purpose:**` do re-review repetia a frase
  anterior; a rationale "a tight report that cites lines gives the
  controller everything it needs" repetia a regra que a precede.

Redução: 519 → 490 linhas (−5,6%), 3423 → 3216 palavras (−6,0%). O teto é
esse porque o volume desses arquivos é regra, não exemplo — Iron Law, litmus
bloqueante, procedimento de teste, contrato de saída. Comprimir além disso
exigiria cortar regra.

Mesma compressão aplicada ao `## What to Check` de
`requesting-code-review/code-reviewer.md` (193 → 184 linhas): os quatro
blocos de pergunta única — `Plan alignment` (3), `Code quality` (5),
`Architecture` (4) e `Production readiness` (4) — passam de um bullet por
pergunta para prosa, com as dezesseis perguntas intactas. O bloco `Testing`
do mesmo arquivo continua em bullets: não é lista de perguntas, é
procedimento com regras multi-linha, o mesmo caso do `Testing` do
implementer.

## plus.13 — grounding de dependências atravessa a fronteira spec → plano

O plus.12 parou na spec. O plano continuava livre para escrever de memória o
código que chama a dependência — e é pior lá do que na spec: `task-brief`
extrai a tarefa verbatim e o controlador a entrega como "your requirements,
with the exact values to use verbatim". Assinatura meio lembrada chega ao
implementador com rótulo de fato.

- **Passo que chama dependência cita fonte** — nova seção `## Code That
  Calls a Dependency`, nas mesmas duas formas do plus.12. Código que a spec
  já fundamentou copia a citação da spec; assinatura, nome de campo, código
  de erro, cabeçalho ou default que a spec nunca declarou exige fonte
  própria, porque a spec resolveu o design, não cada símbolo a digitar.
- **Fonte inalcançável não vira aprovação** — sobe para o parceiro humano,
  mesmo roteamento do plus.12. Escrever a chamada assim mesmo inverte o
  custo: chega como valor exato, parece deliberada para o revisor e a
  divergência aparece na integração.
- **Tech Stack é derivada, não citada** — nomear `stripe` não afirma nada
  sobre `stripe`, então não há doc a citar. O risco dela é outro: biblioteca
  que aparece PELA PRIMEIRA VEZ no plano é decisão de design que ninguém
  aprovou. Cada entrada passa a rastrear para a spec ou para um manifesto já
  no repo, nomeado (`package.json:31`).
- **Regra do par** — duas linhas bloqueantes novas no `The Plan Contract`
  (fonte no passo, rastreio da Tech Stack), mais o procedimento de
  verificação e a lista `Unverified External Calls` no relatório do revisor
  de plano.

## plus.12 — grounding estendido a dependências externas

`## Codebase Findings` exigia `arquivo:linha` para afirmação sobre o código
do repositório desde o plus.1. Afirmação sobre biblioteca, API externa ou
serviço de terceiro não tinha exigência nenhuma — era escrita de memória do
modelo, passava na revisão idêntica a uma afirmação citada, virava tarefa no
plano e falhava na integração, onde custa mais caro.

- **Ordem de consulta declarada** — nova seção `## Where a Claim Comes From`:
  código do repositório → docs do próprio projeto → documentação oficial da
  biblioteca/API na versão fixada → web. Para-se na primeira fonte que
  responde. O que nenhuma das quatro confirmar não é afirmação: vai para
  `## Assumptions to Confirm` com a busca feita.
- **Duas formas de citação, e só elas** — fonte fixada (versão do lockfile +
  linha lida dentro da dependência) ou documentação oficial do fornecedor
  para aquela versão. Post de blog, resposta de fórum e lembrança não são
  fonte. Versão importa tanto quanto o fato: garantia que vale na v14 e não
  na v9 fixada é afirmação errada com citação real.
- **`## External Dependencies`** — nova seção obrigatória da spec, com "None"
  quando o design não toca nenhuma.
- **Regra do par** — a categoria `Groundedness` do revisor de spec passa a
  cobrir dependência externa com a mesma severidade: quatro novas linhas
  bloqueantes (sem fonte, versão que não bate com o lockfile, fonte que não
  diz o que a spec afirma, fonte que não é oficial) e um procedimento de
  quatro passos para verificar. Fonte inalcançável no ambiente vira
  **Unverified External Claims** no relatório — nunca aprovação silenciosa,
  porque fonte inalcançável e fonte confirmada são indistinguíveis na spec
  pronta.
- **Fluxograma** — os dois nós de investigação do Process Flow passam a
  dizer `Investigate code + deps (cite file:line / pinned source)`.

## plus.11 — chave da matriz de cobertura alinhada ao critério de tarefa

Varredura de consistência sobre o plus.10. O plus.9 tinha trocado a chave da
Test Coverage Matrix para id de spec sem ajustar as colunas: a linha nomeava
UMA tarefa e UM teste, mas um `AC` refinado em `T3.1` e `T3.2` tem dois
testes, e a rastreabilidade admite critério coberto por mais de uma tarefa.
Não cabia na linha, e cada plano ia improvisar diferente.

- **Uma linha por critério de tarefa, um teste por linha** — a coluna `Task`
  saiu (o rótulo `T3.1` já carrega o número) e entrou `Spec criterion`, com
  o `AC`/`IR` que a linha refina. Critério cujo comportamento exige dois
  testes são dois critérios: divide-se na tarefa e cada metade ganha sua
  linha.
- **A leitura inversa continua valendo** — `AC` ou `IR` que não aparece na
  coluna `Spec criterion` de nenhuma linha é achado, do mesmo jeito que
  antes. `IR` segue de primeira classe: refinado em critério de tarefa e
  testado nos mesmos termos de um `AC`.
- **Três tabelas do fluxo com a mesma chave** — a matriz do plano, a tabela
  `Test Evidence` do task reviewer e a tabela de entrega da auditoria agora
  são todas por critério de tarefa. `test-driven-development` diz qual linha
  cada teste mapeia, em vez de "uma linha da matriz".
- **Revisor de plano cobra o rótulo** — nova linha bloqueante no `The Plan
  Contract`: critério de tarefa é `T<tarefa>.<n>`, nunca `AC`/`IR`. A regra
  existia desde o plus.10 mas só era cobrada pela auditoria, no fim da
  branch — tarde, que é o defeito que o plus.6 existiu para fechar.
- **Descrição obsoleta em `brainstorming`** — dizia que o plano "dá uma
  linha da matriz a cada `IR`"; agora descreve o refinamento em critério de
  tarefa carregando o id.

## plus.10 — id de critério de tarefa separado do id de critério da spec

Varredura de consistência sobre o que entrou no plus.5 ao plus.9. Um
bloqueante: `AC1` passou a significar duas coisas. O rótulo de critério
DA TAREFA (`AC1:`, `AC2:`, reiniciando a cada tarefa) é upstream; o id de
critério DA SPEC (`AC1`, único no documento) veio com o plus.5 e se espalhou
no plus.9. As duas tabelas da auditoria — rastreabilidade por id de spec,
entrega por critério de tarefa — passaram a poder carregar a mesma string em
linhas diferentes.

- **Rótulo de tarefa vira `T<tarefa>.<n>`** — `T3.1`, `T3.2`. `AC` e `IR`
  ficam exclusivamente para a spec. A regra entrou também na tabela de
  requisitos de critério em `writing-plans`, não só no template.
- **Auditoria declara os dois espaços** — a tabela de entrega diz que é
  chaveada por rótulo de tarefa e que linha com `AC`/`IR` está citando a
  lista errada; o Step 3 do despacho repete a distinção para o auditor.
- **Exemplos corrigidos** — tabela de entrega da auditoria, linha-modelo do
  `Test Evidence` do task reviewer e as duas contagens de critério na
  transcrição em `references/example-workflow.md`, que usavam id de spec
  para critério de brief.
- **Litmus reconhece `IR`** — "happy path só quando há casos de borda
  listados" agora nomeia o `IR` como a casa dos casos de borda, concorrência,
  modos de falha e limites, nas três faces onde a regra vive: revisor de
  task, autorreview do implementador e `test-driven-development`.
- **Diálogo alinhado à seção obrigatória** — a fase de apresentação do design
  em `brainstorming` lista os mesmos eixos que `## Implicit Requirements`
  cobra, em vez de parar em "error handling, testing".
- **Ponteiro de volta** — `references/final-review.md` dizia "(see Model
  Selection)" sem dizer onde; agora diz `in SKILL.md`.

Limpo na mesma varredura: nenhuma linguagem de opcionalidade nas mudanças do
plus.5 ao plus.9, nenhum gate novo apoiado em artefato do auditado, nenhuma
referência pendente às seções movidas no plus.8.

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
- **Grounding de dependência para no plano** — `lockfile`, `pinned`,
  `official doc` e `vendor` aparecem em quatro arquivos: os dois da spec
  (plus.12) e os dois do plano (plus.13). Não aparecem no
  `implementer-prompt.md`, no `task-reviewer-prompt.md` nem na
  `final-branch-audit`. A chamada planejada é verificada na revisão do
  plano; a chamada entregue não é verificada por ninguém. É a fronteira
  plano → código, um degrau adiante da que o plus.13 fechou, e tem o tamanho
  de um pacote próprio.
- **Número de linha em lockfile permanece ilustrativo** — `package-lock.json:1188`
  em `brainstorming/SKILL.md:94` não corresponde a lockfile nenhum: este
  repositório é zero-dependency e a linha varia por projeto de qualquer
  forma. É o único componente inverificável que sobrou nos exemplos de
  citação, e é inerente a ilustrar a forma em vez de um caso real. Fechar
  isso exigiria um projeto de exemplo com lockfile versionado dentro do
  repo — custo alto para o que ensina.
