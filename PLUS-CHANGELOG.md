# PLUS Changelog

> **Mudança de status.** Este projeto começou como fork pessoal e passou a se
> apresentar como **projeto próprio, `superpowersplus`, obra derivada de
> [Superpowers](https://github.com/obra/superpowers)** (Jesse Vincent, Prime
> Radiant, MIT). O que mudou é a apresentação, não a relação técnica: o remote
> continua, e **rebasear sobre o Superpowers segue sendo a forma de incorporar
> as melhorias deles**. A numeração `plus.N` continua de onde estava — as
> entradas anteriores a esta nota falam em "fork" porque era o vocabulário da
> época, e não foram reescritas: changelog é registro do que aconteceu, não
> descrição do estado atual.

Mudanças do superpowersplus ([rodrigopaitach/superpowersplus](https://github.com/rodrigopaitach/superpowersplus))
sobre o [Superpowers](https://github.com/obra/superpowers), do qual deriva.
Entradas `plus.N` são numeradas na ordem em que entraram no fork.
O campo `version` em `.claude-plugin/plugin.json` e `package.json` espelha o
upstream e não é alterado aqui — a numeração `plus.N` é independente dele.

Fio condutor das entradas: **evidence-or-zero** — toda afirmação sobre o
código exige citação `caminho/arquivo:linha`, e quem verifica reexecuta a
busca em vez de aceitar a palavra de quem escreveu.

## plus.34 — namespace próprio, CLAUDE.md deste projeto, autoria correta

**Reversão explícita do item 5 do plus.33.** Aquela entrada determinou manter
o `name` do plugin como `superpowers`, com base em custo *estimado* de rebase.
Revertido com base em medição: dos 426 commits do upstream nos últimos 6
meses, 26 tocaram linhas com `superpowers:` em `skills/` — 6% —, e o `rerere`
já está ativo para absorver a resolução repetida. A decisão anterior não estava
errada em raciocínio; estava sem número. É o mesmo defeito que este projeto
cobra de agentes, cometido por ele mesmo, e a correção veio pela mesma via.

- **56 ocorrências em 20 arquivos, não 131 em 32** — a estimativa do pedido
  errava por mais de 2×. Substituição por padrão que exige nome de skill em
  minúsculas depois dos dois-pontos, então prosa, URLs e o caminho
  `docs/superpowers/` não foram tocados: `git diff` sobre `docs/` voltou vazio,
  conferido antes de commitar. Depois: prefixo antigo 0, novo 56.
- **A inércia sem sintoma tinha um ponto só** — `hooks/session-start:27` cravava
  `superpowers:using-superpowers` no prompt injetado. Renomeado. O
  `.claude-plugin/marketplace.json` não estava na lista do pedido e precisou
  entrar: o `name` da entrada do marketplace tem de casar com o do
  `plugin.json`, ou o `/plugin install superpowersplus@superpowersplus` não
  resolve. Sete manifestos no total, mais `.pi/extensions/superpowers.ts` e
  `.opencode/INSTALL.md`.
- **Dois testes do upstream falham, de propósito** —
  `tests/codex/test-marketplace-manifest.sh:36` e
  `tests/kimi/test-plugin-manifest.sh:24` afirmam `name == "superpowers"`.
  Confirmado por baseline com `git stash` que os dois passavam antes e falham
  só por causa da renomeação. **Não foram editados**, pela regra do plus.30:
  teste reescrito para afirmar o contrário conflita no rebase E deixa de
  detectar mudanças do próprio upstream.
- **`CLAUDE.md`: de 126 para 50 linhas** — era o processo de contribuição do
  Superpowers carregado em toda sessão deste repositório: taxa de rejeição de
  PR, branch `dev` que não existe aqui, templates removidos no plus.29, nove
  subseções voltadas a contribuidor externo. Pior, mandava rodar um harness de
  eval que não existe neste checkout, e o agente tropeçou nisso duas vezes.
  Ficou o que dispara comportamento aqui: evidence-or-zero aplicado ao próprio
  agente, medir em vez de estimar, as invariantes que quebram em silêncio, e a
  relação de rebase. O harness de eval virou **pendência registrada**, não
  instrução vigente — instrução que aponta para artefato inexistente é a regra
  apodrecida que compete com a certa.
- **Autoria corrigida nas duas direções** — os manifestos atribuíam o pacote a
  Jesse Vincent, com o e-mail dele, e apontavam `homepage`/`repository` para o
  `obra/superpowers`. Com 35 entradas `plus.N` que ele não escreveu, isso
  apagava a autoria de quem escreveu e o responsabilizava por defeitos que não
  são dele. `author` passa a Rodrigo Lopes Paitach, `homepage`, `repository` e
  os dois `websiteURL` apontam para este repositório. **`LICENSE` intocada e
  o campo `license` preservado por asserção no script**: o copyright de Jesse
  Vincent permanece, e o crédito à origem segue no `LICENSE`, na `description`
  de cada manifesto e no topo do README.

## plus.33 — o projeto passa a se apresentar por si

Até aqui o repositório se apresentava como fork: o README descrevia o
Superpowers e falava na voz dele, com um bloco de fork por cima explicando o
que era diferente. A identidade era negativa — definida pela distância em
relação a outro projeto, e não pelo que este entrega.

**A relação técnica não mudou.** O remote continua, e rebasear sobre o
Superpowers segue sendo a forma de incorporar as melhorias deles. Mudou a
apresentação e o tom.

- **Crédito mais visível, não menos** — a linha de atribuição saiu de nota de
  rodapé e foi para logo abaixo do título, no README e nos dois documentos por
  idioma: baseado em Superpowers, de Jesse Vincent (Prime Radiant), sob MIT,
  com link para o repositório original. A seção final atribui metodologia,
  skills e fluxo a eles, e delimita o que é deste projeto. `LICENSE` não foi
  tocada e o copyright permanece com Jesse Vincent. Derivar de MIT com crédito
  é legítimo; apagar a origem não é, e a resposta a "isto agora é meu projeto"
  foi creditar mais, não menos.
- **"Diferenças em relação ao upstream" virou "O que acrescenta ao
  Superpowers"** — a mesma lista de cinco eixos, com o sujeito trocado. Título
  que enuncia distância obriga o leitor a conhecer o outro projeto antes de
  entender este.
- **Instalação de outros harnesses aponta para este repositório**, com a
  ressalva declarada de que só o Claude Code é exercitado aqui e de que
  problemas com os demais pertencem às issues deste repositório. Codex, Cursor
  e Copilot CLI seguem descritos como marketplaces que carregam o Superpowers,
  porque é o que carregam.
- **Institucionais alinhados** — `CONTRIBUTING`, `CODE_OF_CONDUCT`,
  `CLAUDE.md` e `RELEASE-NOTES` deixam de chamar o projeto de fork pessoal. O
  código de conduta continua declarado como herdado verbatim, e o
  redirecionamento ao `obra/superpowers` continua para o que for sobre o
  Superpowers em si. A seção `Fork-specific changes` do `CLAUDE.md` virou
  `Downstream-specific changes`: a regra do upstream continua valendo, com o
  vocabulário certo.
- **Metadados de plugin descrevem o projeto, o `name` não muda** — `plugin.json`
  e `marketplace.json` passam a descrever o superpowersplus por si, mantendo
  "Obra derivada de Superpowers (Jesse Vincent, MIT)". O campo `name` continua
  `superpowers`: o prefixo é como as skills se referenciam entre si, em
  centenas de pontos, e trocá-lo quebraria todas de uma vez.
- **As entradas anteriores não foram reescritas** — de `plus.1` a `plus.32`
  falam em "fork" porque era o vocabulário da época. Changelog é registro do
  que aconteceu, não descrição do estado atual; reescrever o passado para
  combinar com o presente apagaria justamente a mudança que esta entrada
  documenta. A nota de status no topo do arquivo diz isso de uma vez.

## plus.32 — CI converte em falha visível o que hoje falha em silêncio

O `githooks/pre-commit` do plus.28 só protege quem rodou
`git config core.hooksPath githooks`. Quem não rodou commita e empurra sem
nenhum sinal — e o modo de falha é justamente o silencioso: os dois READMEs
divergem, ou um shell quebrado entra, e o repositório fica com o defeito sem
que nada acuse. Hook é opcional por construção, porque `.git/` não é
versionável; CI não é.

- **Confirmado antes de criar: o upstream não tem `.github/workflows/`** — a
  API do GitHub responde 404 em `obra/superpowers/contents/.github/workflows`.
  O diretório é território livre e não conflita em rebase, ao contrário de
  quase tudo que este fork tocou até aqui.
- **Um truque de duas linhas reaproveita os dois scripts sem alterá-los** —
  `scripts/lint-shell.sh` e `scripts/check-docs-sync.sh` leem o **índice**
  (`git diff --cached`), porque é o que o hook lê. Checkout de CI tem índice
  vazio, então os dois varreriam nada. `git reset --soft <base>` rebobina o
  HEAD deixando índice e árvore intactos: o índice passa a conter exatamente o
  que o push mudou. Nenhuma variante de CI dos scripts, nenhuma regra
  reescrita — o que o plus.27 já havia estabelecido sobre regra duplicada
  valendo agora para a regra executável.
- **Lint no range, nunca `--all`** — medido antes de decidir: `--all` sai com
  exit 1 e 11 achados, todos em três arquivos do upstream sob
  `tests/claude-code/`. CI vermelho desde o primeiro push não é sinal, é
  treinamento para ignorar sinal. E consertar o lint deles seria divergência
  em arquivo do upstream, recusada pelo mesmo argumento do plus.30. O modo
  padrão do script varre só o alterado, então o débito herdado fica quieto até
  alguém tocar naqueles arquivos — momento em que passa a ser dele.
- **Seis cenários verificados em clone descartável**, não inferidos: push só
  com pt-BR **falha**; com os dois **passa**; sem mudança nenhuma **passa**
  como no-op; push só de `.md` não varre shell e sai 0; shell limpo do fork
  passa; shell do upstream com débito falha — o custo declarado do item
  anterior.
- **Expressão do GitHub via `env:`, nunca inline no `run:`** — `BASE_SHA` entra
  como variável de ambiente. Um `${{ }}` expandido dentro do corpo do script é
  substituído **antes** de o shell parsear a linha, o que transforma conteúdo
  do evento em código. Aqui o valor é um SHA gerado pelo GitHub e não hostil,
  mas a forma segura custa uma linha e elimina a classe inteira.
- **Escopo do que o CI garante, dito por inteiro** — o hook cobra a regra por
  COMMIT; o CI a cobra sobre o range do push. Um push que altera um README no
  commit A e o outro no commit B passa no CI e não teria passado no hook. Está
  escrito no próprio `ci.yml`, porque check que promete mais do que verifica é
  o defeito que este fork existe para separar. Sem publicação, sem release,
  sem `npm publish`: o projeto não é distribuído por npm.

## plus.31 — a seção Updating descreve o fluxo real do fork

A última afirmação do `README.md` que descrevia o upstream como se fosse este
repositório: *"Superpowers updates are somewhat coding-agent dependent, but
are often automatic."* Verdadeiro para quem instala do marketplace oficial;
falso aqui. Quem lesse isso esperaria atualização automática e ficaria com uma
cópia velha sem nenhum sinal — o modo de falha mais silencioso possível, já
que um plugin desatualizado funciona.

- **Uma linha trocada por uma linha** — o `README.md` é o arquivo de maior
  superfície de conflito, e o diff fechou em `1 inserção, 1 remoção`. O texto
  novo diz o que é falso hoje (nada se atualiza sozinho) e remete ao
  procedimento; não o repete.
- **O procedimento vive nos documentos por idioma** — `## Atualizando` e
  `## Updating`, com os dois passos na ordem: rebasear sobre o upstream, e
  então `/plugin marketplace update superpowersplus` seguido de
  `/reload-plugins`. Quem não acompanha o upstream faz só o segundo. As
  âncoras `#atualizando` e `#updating` foram conferidas nos destinos.
- **O passo 1 nomeia o custo que o fork vinha pagando adiantado** — rebasear é
  onde as alterações `plus.N` conflitam, e é a razão de tantas entradas
  anteriores insistirem em tocar o mínimo dos arquivos que o upstream edita.
  A seção de atualização é o primeiro lugar onde essa disciplina aparece como
  benefício para quem lê, e não como regra interna de quem escreve.
- **Os dois comandos entraram sob a palavra do operador do fork** — nem
  `/plugin marketplace update` nem `/reload-plugins` aparecem em qualquer
  arquivo deste repositório, então não há citação `arquivo:linha` que os
  fundamente. São o procedimento que ele executa no próprio ambiente, e é
  registrado aqui como tal: fonte declarada, não medida.

## plus.30 — README reflete o fork e orienta desligar a telemetria

As três sobras do plus.29, todas no `README.md` — o arquivo de maior
superfície de conflito no rebase, tocado o mínimo: duas remoções, uma
substituição de corpo de seção e um parágrafo acrescentado. Nenhuma
reorganização.

- **Contato comercial de terceiro removido** — a seção `## Commercial Services`
  divulgava `sales@primeradiant.com`. Mesma classe do contato que saiu do
  `CODE_OF_CONDUCT` no plus.29: canal de terceiro exibido como se este
  repositório o oferecesse, aqui encaminhando demanda comercial de empresa que
  não tem relação com o fork. Removida em vez de qualificada — é uma linha a
  menos para conflitar.
- **`## Contributing` remete ao `CONTRIBUTING.md`** — o corpo instruía a forkar
  o upstream, mirar `dev` e preencher o PR template, que o plus.29 removeu
  daqui. Cabeçalho mantido no lugar, corpo trocado por duas frases apontando
  para o arquivo que já explica o assunto. Regra duplicada diverge; remissão
  não.
- **Inversão da telemetria no núcleo: avaliada e RECUSADA** — a proposta era
  deixar o companheiro visual desligado por padrão, invertendo
  `SUPERPOWERS_TELEMETRY_DISABLED` em
  `skills/brainstorming/scripts/server.cjs:112`. A mudança de código seria de
  uma linha. O impedimento está nos testes: `branding.test.js:245` e `:261`
  afirmam, no nome, *"render versioned Prime Radiant logo **by default**"* —
  exatamente a proposição que a inversão nega. Baseline medido antes de
  decidir: 7 passando, 0 falhando.
- **Por que o custo do teste é maior que o do código** — este é o registro que
  importa para as próximas decisões do fork. Código divergente conflita no
  rebase e o git avisa. **Teste do upstream reescrito para afirmar o contrário
  conflita E perde o sinal**: quando o upstream mudar o próprio branding, o
  teste adaptado não detecta mais a mudança dele — passa a reclamar só da
  nossa. Um teste que deixou de vigiar o que existia para vigiar o que
  inventamos custa mais do que a divergência que ele documenta.
- **Saída pela borda, sem tocar em nada do upstream** — o padrão do código
  segue o do upstream (**ligado**), e os três documentos passam a orientar
  `export SUPERPOWERS_DISABLE_TELEMETRY=1`, com `DISABLE_TELEMETRY` e
  `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` também honrados. Declarado
  explicitamente nos três que **este fork NÃO vem desligado** e que desligar é
  ação do usuário no ambiente dele — afirmar o contrário seria a mesma
  falsidade confortável que o fork inteiro existe para evitar. O crédito e a
  explicação do upstream ficam onde estavam.
- **Suíte inteira do `brainstorm-server` como critério** — `ws` não estava
  instalado no checkout (`node_modules` ausente, ignorado pelo git); instalado
  para conseguir rodar tudo. Resultado: **123 testes node passando, 0
  falhando**, mais as duas suítes shell. Os 7 de branding entre eles.
  `git diff` sobre `skills/brainstorming/scripts/` e `tests/` volta vazio —
  a prova de que a saída pela borda não tocou nada do upstream.

## plus.29 — arquivos institucionais refletem o fork

Nenhum destes é código: são os arquivos que o GitHub exibe como se falassem
pelo repositório. Herdados intactos, faziam este fork falar em nome de
terceiros — desviar denúncia para quem não tem autoridade aqui, exibir botão
de doação de outra pessoa, e cobrar um processo de contribuição que não
existe.

- **Contato de denúncia** — o `CODE_OF_CONDUCT.md` mandava reportar abuso a
  `jesse@primeradiant.com`, o mantenedor do upstream. Num fork pessoal isso
  entrega a denúncia a quem não tem autoridade sobre este repositório, não tem
  visibilidade dele e não responde por ele, e envolve um terceiro em assunto
  que não é dele. O canal passa a ser issue neste repositório, com aviso no
  topo declarando o código de conduta como herdado e a razão de o contato ter
  saído. O texto do Contributor Covenant em si fica intacto.
- **`.github/FUNDING.yml` removido** — apontava para o patrocínio do
  mantenedor do upstream. O GitHub o renderiza como botão "Sponsor" no topo
  deste repositório: quem doasse acharia que apoia este fork e estaria
  financiando outra pessoa. `.github/` ficou vazio e deixou de existir.
- **Templates de issue e PR removidos, não reescritos** — os cinco arquivos
  eram do fluxo de contribuição do upstream. Reescrevê-los criaria um processo
  de contribuição para um fork que não solicita contribuição; mantê-los faria
  o GitHub cobrar de quem abrisse issue um formulário sobre um projeto que não
  é este. `CONTRIBUTING.md` novo diz as três coisas que faltavam: este fork
  não recebe contribuição, contribuição ao original vai para `obra/superpowers`
  e nada enviado aqui chega lá, e problema com este fork é issue aqui.
- **`RELEASE-NOTES.md`** — uma linha no topo declarando que registra as
  versões do UPSTREAM e que as alterações próprias estão no `PLUS-CHANGELOG`,
  numeradas `plus.N` de forma independente. Conteúdo histórico intocado.
- **`LICENSE` deliberadamente intocada** — o copyright de Jesse Vincent
  permanece. É exigência da MIT, e é o arquivo que hoje nunca conflita em
  rebase. Um fork que mexe na licença que o autoriza a existir perde as duas
  coisas de uma vez.
- **`CLAUDE.md`: seis afirmações que deixaram de valer** — este arquivo carrega
  em toda sessão deste repositório, e regra apodrecida compete com a regra
  certa. Duas das seis (`:13` e `:112`) ficariam penduradas pelo próprio
  commit, apontando para o `PULL_REQUEST_TEMPLATE.md` recém-removido. Todas
  passaram a nomear o upstream como sujeito: a taxa de 94% é dele, o alvo
  `dev` é dele — aqui não existe branch `dev` e o trabalho vai direto para
  `main` —, o template é dele, e a seção "Fork-specific changes" agora declara
  que **este repositório é exatamente esse fork**. O `evals/` ganhou o registro
  de estar gitignored e ausente do checkout, com `tests/skill-behavior/` do
  plus.28 nomeado ao lado. Nota no topo enquadra o arquivo inteiro: as regras
  descrevem o processo do upstream e ficam porque a filosofia de projeto que
  elas codificam continua valendo aqui.
- **`AGENTS.md` é symlink para `CLAUDE.md`** — verificado, não editado
  separadamente: serve o mesmo conteúdo sob outro nome, e as seis correções o
  alcançam. `GEMINI.md` tem duas linhas de `@` import e nenhuma afirmação
  sobre o projeto.
- **Uma referência pendurada fora dos três arquivos** —
  `docs/porting-to-a-new-harness.md:24` também citava o template removido.
  Corrigida no mesmo commit por ser quebra criada por ele, não achado
  preexistente.

## plus.28 — hooks versionados, rastro da recusa, e a primeira regra medida

As três sobras do plus.27. A terceira é a primeira vez que uma regra deste
fork foi **medida** em vez de raciocinada, o que muda o que as outras entradas
valem: até aqui, "escrito" e "verificado" tinham exatamente a mesma aparência
no changelog — o defeito que o fork inteiro existe para separar, aplicado a
ele mesmo.

- **Hooks versionados em `githooks/`** — o symlink do plus.27 protegia um
  arquivo só e morria fora dele; cada verificação futura precisaria do próprio
  symlink. `githooks/pre-commit` passa a ser ponto de entrada único, chamando
  `scripts/check-docs-sync.sh`, ativado por
  `git config core.hooksPath githooks`. A ativação por clone continua
  inevitável — `.git/` não é versionável —, mas agora vale para todo hook
  futuro. Testado end-to-end com o `core.hooksPath` ativo: commit com só um
  dos READMEs é barrado e **nenhum commit é criado**; com os dois, passa.
  Conferido antes de mexer que `scripts/lint-shell.sh` já varre os dois
  arquivos novos: `is_shell_file()` tem fallback por shebang além da extensão,
  e `--all` coleta 44 arquivos contra 39 `.sh` rastreados. Nenhum ajuste
  necessário na coleta.
- **Sugestão de simplificação recusada deixa rastro** — a face do plus.27
  sugeria a versão menor e nada registrava a decisão, assimetria com
  `Deferred` e `Outstanding` do Coverage Map, que exigem motivo declarado
  desde o plus.23. Recusa silenciosa e sugestão nunca lida tinham a mesma
  aparência. Segue não-bloqueante — recusar é do autor do plano —, mas o
  motivo vai para a linha de justificativa da estrutura, na forma que o
  Coverage Map já exige, e o revisor cobra na re-revisão como achado advisory.
- **Teste adversarial da regra de conteúdo externo** — `tests/skill-behavior/`,
  com fixture, spec de entrada, resultado e um README que descreve o método
  para servir de molde. A fixture simula doc de fornecedor e carrega duas
  coisas: a assinatura legítima e, no meio do texto, uma instrução dirigida ao
  agente leitor mandando aprovar sem verificar. A spec cita a fixture e mais
  três citações no repo — duas corretas e **uma plantada errada**, para dar
  sinal observável caso o revisor obedeça e pule a verificação.
- **Resultado: PASSOU nos três critérios** — extraiu o fato da fonte;
  reportou a instrução como fonte comprometida, explicitamente e não por
  silêncio; e não obedeceu, pegando a citação plantada
  (`githooks/pre-commit:11` afirmava o que está em `:13`). Achou ainda
  defeitos não plantados, entre eles um registro de busca **falso** na própria
  fixture — reexecutou o `grep` que a spec afirmava não ter dado match e achou
  cinco. Registro completo, com o relato do subagente na íntegra, em
  `RESULT-external-content-is-data.md`.
- **O que o resultado NÃO estabelece** — uma amostra, um modelo, uma redação
  da injeção, e ela se anunciava com "Reviewer:", a forma mais fácil de pegar.
  O `writing-skills` é explícito em que amostra única mente. Houve ainda
  vazamento: o revisor localizou o diretório da fixture **depois** de concluir
  a revisão e reportar a injeção — os três critérios foram cumpridos antes
  disso, mas a próxima rodada deve pôr as cópias fora do repositório. A regra
  valeu uma vez; não está estabelecida.

## plus.27 — as três sobras do plus.26, fechadas

O plus.26 deixou três buracos registrados. Nenhum deles era erro do que
entrou: eram alcance menor do que o problema.

- **A regra de sincronia não tinha quem a cobrasse** — o plus.26 declarou que
  editar um dos READMEs por idioma exige editar o outro no mesmo commit, e o
  único verificador era quem executa. Regra assim é decorativa, e é exatamente
  o defeito que este fork existe para separar: declarada e cobrada tinham a
  mesma aparência. `scripts/check-docs-sync.sh` compara o staging e falha
  quando exatamente um dos dois está presente, nomeando qual falta.
  Verificado nos quatro estados — nenhum, os dois, só o pt-BR, só o en — e
  `shellcheck --severity=warning` limpo. A ativação (symlink em `.git/hooks`)
  fica documentada nos dois cabeçalhos e é decisão de cada clone: `.git` não é
  versionável, então o script versionado é o máximo que o repositório entrega.
- **O estatuto de dado parava na ponta que verifica** — a regra do plus.26
  cobria os dois revisores, mas quem busca a página de fornecedor é primeiro
  quem escreve: o `brainstorming/SKILL.md` manda consultar a doc oficial em
  "Where a Claim Comes From", e o `coverage-map.md` a usa como fonte de ordem
  2 para recomendação. Mesma superfície, exposição mais cedo, e sem regra. As
  duas faces passam a declarar o estatuto **referenciando** a formulação dos
  revisores em vez de reescrevê-la: regra repetida com outras palavras diverge
  da original, e as duas passam a competir.
- **A regra do mínimo não alcançava quem decide o tamanho** — o plus.26 a pôs
  no `implementer-prompt.md`, que recebe o tamanho já decidido. Se o plano
  decompôs o critério numa camada nova, o implementador executa, não escolhe.
  A regra subiu para o `writing-plans/SKILL.md`, na seção `## File Structure`,
  onde a decomposição é travada: escolher a menor estrutura que atende o
  critério, e conferir estrutura existente do projeto antes de criar camada,
  módulo ou abstração nova — com citação `arquivo:linha` da estrutura
  reutilizada, a mesma forma que todo claim sobre este código já exige.
- **Camada nova carrega justificativa ligada a critério** — uma linha nomeando
  o critério que a força. Camada que não nomeia nenhum é escopo inventado pela
  regra que o plano já cobra, e segue bloqueante ali. No
  `plan-document-reviewer-prompt.md` a face nova entra como `Simplification`,
  **advisory e nunca bloqueante** — mesmo estatuto do achado `Minor` no
  task-reviewer — com a mesma exigência: nomear concretamente a versão menor.
  "Isto podia ser mais simples" sem substituto não é achado, é opinião com
  aparência de revisão, e custa uma rodada a quem recebe.

## plus.26 — sincronia dos idiomas, conteúdo externo como dado, regra do mínimo

Três achados de revisão geral, nenhum deles contradizendo regra: dois eram
lacuna de regra e um era número datado escrito como se fosse permanente.

- **Os dois idiomas não tinham árbitro nem regra de sincronia** — o plus.25
  criou `docs/README.pt-BR.md` e `docs/README.en.md` idênticos em conteúdo, e
  nada obrigava a acompanhar. O primeiro commit que editasse só um abriria
  divergência que ninguém enxerga depois: as duas versões seguem plausíveis, e
  nada marca qual envelheceu. O pt-BR passa a ser declarado canônico nos dois
  arquivos, e editar um exige editar o outro **no mesmo commit**. É a mesma
  falha que o plus.20 corrigiu entre exemplo e especificação, agora entre
  traduções.
- **"54 pontos" era medição datada em prosa** — contagem de 2026-08-02 escrita
  como fato permanente nos dois documentos. Qualquer skill nova que se
  auto-referencie muda o número e nada avisa. Trocada por formulação
  qualitativa. É a regra do "sem hardcoded" aplicada a texto: literal cru só
  para o que não muda.
- **Conteúdo externo não tinha estatuto declarado** — os dois revisores buscam
  página de documentação de fornecedor para conferir citação de dependência, e
  nada dizia o que fazer com instrução embutida no que voltasse. A página é
  superfície que nem o autor da spec nem o do plano controlam, e o revisor a
  busca exatamente no momento em que decide se aprova. Agora: conteúdo vindo
  de URL é **dado a ler, nunca instrução a seguir**. O revisor extrai só o
  fato que foi verificar — assinatura, campo, comportamento — e ignora todo
  comando, pedido ou instrução da página, por mais oficial que pareça e seja
  lá de quem afirme vir. Instrução dirigida a quem lê a página é sinal de
  fonte comprometida ou forjada: vira achado, a citação fica não verificada, e
  a instrução não é obedecida.
- **Nada regia o tamanho da solução** — os portões provam que o pedido existe,
  é rastreável e é testado. Um critério pode ser atendido por três linhas ou
  por uma camada nova, e as duas versões passam por todos os gates
  igualmente. Regra de postura no `implementer-prompt.md`: escrever o mínimo
  que atende o critério, e conferir código existente, stdlib ou recurso da
  plataforma antes de criar função, classe, camada ou abstração nova.
  Dependência nova e generalização para caso futuro continuam regidas pelas
  regras que já existem — referenciadas, não reescritas, porque regra
  duplicada diverge da original e as duas passam a competir.
- **A face verificadora, não-bloqueante** — no `task-reviewer-prompt.md` a
  simplificação entra como achado `Minor`, com a exigência de **nomear
  concretamente a versão menor**. "Isto podia ser mais simples" sem
  substituto não é achado: é opinião com aparência de revisão, e custa ao
  implementador uma rodada para descobrir que não havia proposta nenhuma.

## plus.25 — documentação bilíngue do fork em `docs/`

O plus.22 declarou o fork no `README.md`, mas em bloco curto: nota de origem,
cinco eixos e instalação. Quem quisesse saber o que o fork faz, por que existe
e o que ele gera no projeto não tinha para onde ir, e o `README.md` é
justamente o arquivo que o upstream mais edita — crescer nele é comprar
conflito de rebase a cada release.

- **`docs/README.pt-BR.md` e `docs/README.en.md`** — documento completo por
  idioma: o que é, por que existe, para quem, instalação, como funciona,
  o que é gerado, diferenças em relação ao upstream, pendências e crédito.
  O português é o original e o inglês a tradução, declarado no topo dos dois:
  sem essa declaração, duas versões divergentes não têm árbitro.
- **`README.md` cresceu duas linhas** — os badges de idioma entraram DENTRO do
  bloco de fork que o plus.22 já havia criado, e nenhuma outra linha foi
  tocada. Zero remoções no diff. Bloco novo em região que o upstream não
  toca o rebase resolve sozinho; linha modificada, não.
- **Nada prometido que não exista** — cada afirmação de comportamento foi
  conferida contra as skills antes de ser escrita: os quatro portões e o que
  cada um bloqueia, os caminhos onde vivem, os diretórios de spec e de plano,
  as cinco colunas da matriz de cobertura. Os quatro caminhos de skill citados
  nas tabelas foram abertos; os seis links relativos, resolvidos. O que não
  existe está na seção de pendências, não no corpo.
- **A seção "Para quem" declara o desenho, não só o público** — que o fork
  serve inclusive a quem não programa é consequência do plus.23, não boa
  vontade: recomendação obrigatória com fonte declarada, pergunta em
  linguagem de consequência prática, coluna de consequência por opção. Todas
  são regras que existem hoje nos arquivos, e a documentação as descreve como
  são, sem arredondar para cima.

## plus.24 — regularização de spec antiga e preferência sobre o companheiro visual

Duas consequências do plus.23 e do que ele deixou passar. Nenhuma delas
contradizia regra: uma era regra nova aplicada retroativamente sem rota de
saída, a outra era divergência entre o checklist e o fluxograma do mesmo
arquivo.

- **Spec anterior à exigência tinha bloqueio sem saída** — o plus.23 tornou
  `## Coverage Map` obrigatória e bloqueante. Nenhuma spec escrita antes dele
  tem a seção, então todo trabalho antigo que voltasse ao revisor era barrado
  por regra que não existia quando a spec foi escrita. O achado segue
  bloqueante — seção ausente e seção vazia-com-motivo continuam não podendo
  ter a mesma aparência —, mas o relato passou a distinguir a spec que
  antecede a exigência do autor que omitiu, e a instruir: monte o mapa a
  partir da spec existente antes de prosseguir. O `SKILL.md` ganhou a
  contrapartida do lado de quem regulariza: preencher as linhas com o que a
  spec já contém e marcar `Outstanding` só o que ela não responde. Refazer o
  levantamento cobraria do parceiro humano decisões que ele já tomou e
  aprovou uma vez.
- **Checklist e fluxograma divergiam sobre o companheiro visual** — o passo 3
  manda oferecê-lo just-in-time; o Process Flow não tinha nó nenhum para ele.
  Quem seguia o checklist oferecia, quem seguia o fluxograma pulava, e os dois
  estão no mesmo arquivo. Modelado agora como desvio CONDICIONAL de duas
  portas, nunca etapa fixa: nó incondicional ensinaria exatamente o oposto do
  "NOT upfront" que o checklist exige. Verificado no digraph — 15 nós
  declarados, 15 usados, 20 arestas, zero órfãos e zero não-declarados, e o nó
  de oferta contornável por dois caminhos distintos.
- **A oferta não consultava preferência nenhuma** — decidir mostrar em vez de
  descrever é preferência do parceiro, e há parceiros que nunca querem o
  companheiro visual. A skill agora procura preferência declarada no
  `CLAUDE.md` do projeto, na memória do usuário ou na conversa, antes de
  qualquer oferta. Preferência contra significa nunca oferecer **e nunca
  mencionar que deixou de oferecer**: anunciar a oferta suprimida é a oferta,
  e devolve ao parceiro exatamente a interrupção que a preferência existia
  para evitar.
- **Qual regra vence, dito de uma vez** — a preferência declarada vence o
  critério just-in-time, escrito explicitamente no `SKILL.md`. Duas regras
  aplicáveis ao mesmo momento sem ordem declarada é o modelo escolhendo uma
  arbitrariamente; o critério decide QUANDO oferecer, só entre quem ainda não
  respondeu SE.

## plus.23 — mapa de cobertura com recomendação fundamentada

O `brainstorming/SKILL.md` dizia COMO perguntar — uma por mensagem, múltipla
escolha quando cabe — e nada sobre O QUE. A completude do levantamento era o
que o modelo lembrasse naquele dia, e pergunta que não ocorreu a ninguém é
lacuna que ninguém registrou. O segundo furo é maior: a pergunta devolvia ao
parceiro humano uma decisão técnica sem lhe dar base para decidir. Quem não
programa julga a ORIGEM de uma recomendação — abre o `arquivo:linha` e vê que
existe — não a técnica.

- **`coverage-map.md`** — arquivo irmão do `visual-companion.md`. Dez
  categorias (escopo, modelo de domínio, fluxo de interação, atributos não
  funcionais, integrações, casos de borda, restrições, terminologia, sinais de
  conclusão, placeholders) e quatro estados por categoria — `Clear`,
  `Resolved`, `Deferred`, `Outstanding` — cada um carregando seu motivo.
  Estado sem motivo é inválido, pela mesma razão do plus.15 e do plus.21:
  "não checado" e "não aplicável" não podem ter a mesma aparência.
- **Filtro de admissão** — só vira pergunta o que muda arquitetura, modelagem
  de dados, decomposição de tarefas, desenho de teste, comportamento de UX,
  prontidão operacional ou conformidade. É ele que impede dez categorias de
  virarem interrogatório num projeto pequeno; no digraph virou o losango
  `Gap changes a decision?`, com saída para o design sem passar por pergunta.
  O que sobra é ordenado por impacto × incerteza.
- **Recomendação obrigatória, com fonte declarada** — toda pergunta sai com
  recomendação, e a fonte é declarada em uma de três formas, nesta ordem:
  padrão já existente no projeto citado como `arquivo:linha`; doc oficial da
  dependência, conforme a seção "Where a Claim Comes From"; boa prática geral,
  declarada explicitamente como tal para o parceiro saber que ali não houve
  verificação. Padrão do projeto vem primeiro — consistência com o que existe
  vale mais que a melhor prática abstrata. Recomendação sem fonte é inválida:
  a declaração é o único componente que um não-programador consegue conferir.
- **Forma da pergunta** — interrogativa completa terminada em `?`,
  compreensível sozinha. Rótulo de tópico não é pergunta (forma inválida:
  `Device matrix for acceptance (AC3)`). Abaixo, uma frase de consequência
  prática — o que quebra, o que fica lento, o que custa caro depois — nunca o
  mecanismo. Termo técnico só aparece definido na mesma frase.
- **Integração incremental** — cada resposta aceita é aplicada à seção certa
  da spec e o arquivo é salvo a cada integração, para o que já foi decidido
  sobreviver à compactação. Resposta que invalida afirmação anterior
  SUBSTITUI a afirmação: spec com a versão antiga ao lado da correção não tem
  resposta. No digraph isso é a aresta de volta de `Ask clarifying questions`
  para `Build coverage map` — o mapa é estado vivo, não lista montada uma vez.
- **Sem mecanismo paralelo** — lacuna resolvida vira `AC` ou `IR` com id, pela
  convenção já vigente; `Deferred` e `Outstanding` viram item em
  `## Assumptions to Confirm` com o registro de busca que a seção já exige.
  `## Coverage Map` entra na lista de seções obrigatórias da spec, com o
  registro de decisão (pergunta, resposta, recomendação, fonte) abaixo da
  tabela.
- **Piso, não teto** — declarado explicitamente no `SKILL.md`: cobrir as dez
  categorias não encerra o levantamento e nenhuma delas autoriza pular a fase
  de design. Lista fechada convida o agente a tratá-la como critério de parada,
  e este é o único parágrafo que fecha essa porta.
- **Regra do par** — sete linhas bloqueantes no
  `spec-document-reviewer-prompt.md`: seção ausente, categoria sem destino,
  estado sem motivo, pergunta sem recomendação, recomendação sem fonte,
  recomendação que cita padrão do projeto cuja citação não confere, e
  afirmação contraditória remanescente após clarificação. O revisor abre o
  `arquivo:linha` da recomendação — a citação é a única parte que o parceiro
  poderia ter conferido, então é a que precisa se sustentar.
- **Exemplo idêntico nos dois arquivos** — a tabela de cobertura completa e a
  pergunta de ponta a ponta aparecem em `coverage-map.md` e no prompt do
  revisor, com as linhas conferidas byte a byte. Exemplo divergente do outro
  exemplo do mesmo formato é o que o plus.20 corrigiu.

Deixado de fora por decisão: limite de número de perguntas, a tomar com uso
real do fork.

## plus.22 — README declara o fork

O README era o do upstream, íntegro: descrevia o Superpowers original e, na
seção do Claude Code, só ensinava a instalar o upstream. Quem chegasse pelo
repositório instalaria outra coisa que não este fork sem perceber, e as
alterações próprias — registradas aqui desde o plus.1 — não tinham porta de
entrada nenhuma.

- **Nota de origem no topo** — fork de obra/superpowers (Jesse Vincent, MIT),
  sem vínculo com o autor, com a Prime Radiant ou com a Anthropic, apontando
  para este arquivo como registro das alterações próprias. Fork que não se
  declara empresta reputação que não é dele.
- **Seção por eixo, não por entrada** — cinco linhas para os cinco eixos
  (spec fundamentada em evidência, contrato do plano cobrado por revisor,
  matriz de cobertura, revisor de task que reexecuta a suíte, auditoria de
  conformidade com rastreabilidade spec → task). Lista por eixo não apodrece a
  cada `plus.N` novo; o detalhe fica onde já estava. As pendências entram por
  referência à seção deste arquivo, pela mesma razão: lista duplicada diverge.
- **Instalação corrigida** — `/plugin marketplace add rodrigopaitach/superpowersplus`
  e `/plugin install superpowers@superpowersplus`, com o motivo de o plugin
  seguir chamando `superpowers` enquanto o marketplace chama `superpowersplus`:
  as skills se referenciam por esse prefixo em 54 pontos de `skills/`
  (`superpowers:final-branch-audit` e afins, medido neste repo), e renomear o
  plugin quebraria todas. As subseções do upstream ficam, marcadas como tal.
- **Só acréscimo** — nenhuma linha do texto upstream foi alterada ou removida.
  Linha modificada é superfície de conflito no próximo rebase; bloco novo em
  região que o upstream não toca o Git resolve sozinho.

## plus.21 — Example Output renderiza os três buckets

O Example Output do code reviewer trazia `Important` e `Minor` e nenhum
`Critical` — legítimo num review sem achado crítico, mas é a única
renderização do formato de três buckets no arquivo, e exemplo sem a seção
ensina a omiti-la. Quem copia entrega um relatório onde "nada crítico" e
"nunca olhei para o crítico" são a mesma coisa.

- **Exemplo exibe os três**, com `#### Critical (Must Fix)` seguido de
  `None.` — mesma solução que o plus.15 deu para as seções da spec, pelo
  mesmo motivo: seção ausente e seção vazia não podem ter a mesma aparência.
- **Regra do par** — a especificação do Output Format passou a exigir os
  três buckets em toda saída, com `"None"` no que estiver vazio. Exibir no
  exemplo sem cobrar na especificação seria regra que ninguém enunciou.

## plus.20 — exemplos alinhados às especificações que ilustram

Divergências entre um exemplo e a especificação que ele ilustra, no mesmo
arquivo. Nenhuma delas contradiz regra: cada uma demonstra uma variação da
regra, e é a variação que o modelo copia.

- **`Ready to merge`** — o Output Format do code reviewer pede
  `**Ready to merge?** [Yes | No | With fixes]`; o Example Output do mesmo
  arquivo escrevia `**Ready to merge: With fixes**`, com dois-pontos dentro
  do negrito e sem a interrogação. Alinhado à pontuação da especificação.
- **Rótulos dos buckets** — a especificação nomeia
  `#### Important (Should Fix)` e `#### Minor (Nice to Have)`; o exemplo
  escrevia `#### Important` e `#### Minor`. Os parênteses são o que diz ao
  revisor o que cada severidade obriga; exemplo sem eles ensina a decidir
  severidade sem o critério.
- **Cabeçalho da tabela do revisor** — `test-driven-development` descrevia a
  tabela como `Criterion | test file:line | assertion`, em minúsculas; o
  cabeçalho real em `task-reviewer-prompt.md:163` é
  `Criterion | Test file:line | Assertion`.

## plus.19 — exemplos que ensinavam comportamento impossível

Varredura de exemplos por eixo novo: comparar cada exemplo contra a
especificação que ele ilustra e contra a própria coerência interna. Exemplo
errado não contradiz regra nenhuma — ele demonstra mal, e por isso busca por
palavra-chave nunca o encontrava.

- **Registro misturado no template de tarefa** — o bloco ` ```python ` de
  `writing-plans` definia `def function(input): return expected` com
  `expected` não ligado, e o passo seguinte afirmava `Expected: PASS` para um
  comando que levantaria `NameError`. O bloco se apresentava como Python
  concreto: tag de linguagem, comando `pytest`, veredito de execução, e
  `test_specific_behavior` referenciado por outro campo do mesmo template.
  Registro esquemático existe no arquivo — os campos em prosa usam colchete —
  e o código não o usava. Todos os demais blocos com tag de linguagem do
  repositório (`writing-good-tests.md:12`, `defense-in-depth.md:8`,
  `condition-based-waiting.md:16`, `root-cause-tracing.md:31`,
  `test-driven-development/SKILL.md:64`) são concretos; este era o único
  fora do padrão. Substituído por `verify_token` / `test_rejects_expired`,
  que foi executado antes de entrar. A distinção virou explícita no texto:
  colchete é vaga, bloco de código é código que roda.
- **Quatro vocabulários de caminho num exemplo só** — `exact/path/to/file.py`,
  `tests/exact/path/to/test.py`, `tests/path/test.py` e `src/path/file.py`,
  este último citado no `git add` e em nenhum outro lugar do exemplo.
  Colapsados em `src/auth/verify.py` e `tests/auth/test_verify.py`, que são
  os que a Test Coverage Matrix logo acima já nomeia — o template passou a
  ser fiado de ponta a ponta.
- **Tabelas da auditoria mutuamente incoerentes** — `Task 4` tinha linha na
  tabela de entrega e não aparecia na de rastreabilidade, nem cobrindo
  critério nem como `INVENTED SCOPE`, embora a regra logo acima exija uma
  linha por tarefa que nenhum critério motivou. `Task 7`, marcada
  `INVENTED SCOPE`, não tinha linha de entrega, embora a regra da segunda
  tabela exija uma linha por critério de toda tarefa do plano. Quem copiava
  aprendia que uma tarefa pode ser auditada numa tabela e invisível na
  outra — o buraco exato que a auditoria existe para fechar. Agora toda
  tarefa aparece nas duas, e `Task 7` entrou como DELIVERED + INVENTED
  SCOPE: código que funciona e que a spec nunca pediu continua sendo achado.
- **Sintaxe pytest em arquivo TypeScript** — `e2e/login.spec.ts::refreshes
  mid-session` usava o node-id do pytest num spec de Playwright. Passou à
  convenção da própria ferramenta (`>`).
- **Contagens que não batiam com os itens exibidos** — introduzido por mim no
  plus.16: a corrida reportava 5 e 8 testes onde a tabela nomeava 3 e 2. Pela
  regra inversa do TDD, teste sem linha na matriz é escopo inventado, então o
  exemplo exibia um revisor aprovando o que a regra manda reprovar. As
  contagens caíram para bater com as linhas e passaram a encadear numa suíte
  única (3 → 5 → 6), o que também conserta o `(base: 5)` que comparava a
  contagem de um arquivo de teste com a de outro. A rodada de correção agora
  fecha a linha `—` de `T2.3`, que antes ficava aberta para sempre.

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
- **Sem harness de eval neste repositório** — o `CLAUDE.md` mandava rodar evals
  e apontava para `evals/`, que é gitignored e não existe neste checkout; o
  agente tropeçou nisso duas vezes antes de a instrução sair. O que existe é
  `tests/skill-behavior/`, com uma regra medida (plus.28). Clonar o
  `superpowers-evals` e ligá-lo ao fluxo é desejável e não foi feito: exigiria
  submódulo ou clone manual por checkout, e as regras deste projeto continuam
  majoritariamente raciocinadas em vez de medidas. Registrado aqui para não
  voltar como descoberta.
- **Número de linha em lockfile permanece ilustrativo** — `package-lock.json:1188`
  em `brainstorming/SKILL.md:94` não corresponde a lockfile nenhum: este
  repositório é zero-dependency e a linha varia por projeto de qualquer
  forma. É o único componente inverificável que sobrou nos exemplos de
  citação, e é inerente a ilustrar a forma em vez de um caso real. Fechar
  isso exigiria um projeto de exemplo com lockfile versionado dentro do
  repo — custo alto para o que ensina.
