# superpowersplus — documentação em português

> **Este é o texto canônico.** A versão em inglês, [`README.en.md`](README.en.md), é a tradução dele — em qualquer divergência, este arquivo é o que vale.
>
> **Editar um exige editar o outro no MESMO commit.** Um commit que altera só um dos dois abre uma divergência que ninguém consegue ver depois: as duas versões continuam plausíveis, e nada indica qual envelheceu.
>
> Para a regra ser cobrada e não só declarada: `git config core.hooksPath githooks`. Os hooks são versionados em `githooks/`; ativá-los é decisão de cada clone, porque `.git/` não é versionável.

## O que é

Uma metodologia de desenvolvimento para agentes de código, **baseada em [Superpowers](https://github.com/obra/superpowers), de Jesse Vincent (Prime Radiant), sob licença MIT**.

O Superpowers é um conjunto de skills que se ativam sozinhas e fazem o agente parar antes de escrever código, entender o que você quer, escrever uma especificação, planejar, e só então implementar — com TDD de verdade.

O superpowersplus é obra derivada: mantém tudo isso e acrescenta um eixo: **evidence-or-zero**. Toda afirmação que o agente faz sobre o seu código exige uma citação `arquivo:linha`, e quem verifica reexecuta a busca em vez de aceitar a palavra de quem escreveu.

## Por que existe

O problema não é o agente escrever código ruim. É o agente escrever código correto para uma especificação inventada.

Um agente que não encontra a resposta no seu código não fica em silêncio. Ele produz a resposta mais plausível — a que vale para software em geral, não para o seu. Escrita na spec, essa frase fica indistinguível de uma que alguém verificou: passa pela revisão, vira tarefa no plano, vira código, e falha na integração, onde consertar custa mais caro.

O mesmo vale para teste. Uma suíte verde prova que os testes passaram, não que testam alguma coisa. Um relatório que diz "todos os testes passam", escrito por quem implementou, é a única evidência que a maioria dos fluxos tem — e é produzida por quem está sendo auditado.

As duas coisas têm a mesma forma: **uma afirmação sem verificação parece exatamente igual a uma verificada.** O superpowersplus existe para separar as duas.

## Para quem

Para quem usa um agente de código com trabalho de verdade em jogo — pessoas desenvolvedoras, entusiastas, e explicitamente **inclusive quem não programa**.

Essa parte é desenho, não acaso. Um parceiro que não programa não consegue julgar se uma decisão técnica está certa, mas consegue julgar de **onde ela veio**: abrir o arquivo na linha citada e ver que existe e diz o que foi afirmado. Então:

- **Toda pergunta sai com uma recomendação.** Sem exceção. Pergunta sem recomendação devolve uma decisão técnica a quem não tem base para tomá-la.
- **A fonte da recomendação é declarada**, em uma de três formas: um padrão que já existe no seu projeto (citado como `arquivo:linha`), a documentação oficial da dependência envolvida, ou boa prática geral — e quando é boa prática, o agente diz isso, para você saber que ali não houve verificação no seu código.
- **As perguntas são escritas em linguagem de consequência prática**: o que quebra, o que fica lento, o que custa caro depois. Não o mecanismo. Termo técnico só aparece se for definido na mesma frase.
- **A tabela de opções traz uma coluna de consequência por opção**, para você reconhecer o que está aceitando sem precisar virar arquiteto.

## Instalação

Requer o [Claude Code](https://claude.com/claude-code).

```bash
/plugin marketplace add rodrigopaitach/superpowersplus
```

```bash
/plugin install superpowers@superpowersplus
```

**Por que o plugin se chama `superpowers` e o marketplace `superpowersplus`:** as skills se referenciam entre si por esse prefixo — `superpowers:brainstorming`, `superpowers:writing-plans`, `superpowers:final-branch-audit` e assim por diante, em dezenas de pontos espalhados pelos arquivos de skill. Renomear o plugin quebraria todas essas referências. O marketplace é que precisa de nome próprio, para não colidir com o do upstream.

## Atualizando

O superpowersplus não está no marketplace oficial, então **nada se atualiza sozinho**. São dois passos, nesta ordem:

1. **Rebasear sobre o upstream**, para trazer as mudanças do `obra/superpowers`. É aqui que as alterações `plus.N` podem conflitar — e é por isso que elas foram escritas para tocar o mínimo possível dos arquivos que o upstream edita com frequência.
2. **Atualizar o plugin instalado:**

   ```
   /plugin marketplace update superpowersplus
   /reload-plugins
   ```

Quem não acompanha o Superpowers faz só o passo 2.

## Como funciona

O fluxo é **spec → plano → tarefas → auditoria**. Você não invoca nada: as skills se ativam sozinhas quando você pede algo que envolva construir.

1. **Spec.** O agente investiga o seu código antes de qualquer pergunta, monta um mapa de cobertura de dez categorias para decidir o que perguntar, pergunta uma coisa de cada vez com recomendação e fonte, e escreve a especificação com critérios de aceite numerados.
2. **Plano.** Cada critério da spec vira uma ou mais tarefas, e cada tarefa declara qual critério ela entrega. Uma matriz de cobertura liga critério a teste.
3. **Tarefas.** Um subagente novo por tarefa, com TDD obrigatório: teste antes do código.
4. **Auditoria.** No fim da branch, cada critério é rastreado até as tarefas que o entregam, nas duas direções, e vereditado contra evidência localizada.

Entre cada etapa há um portão. Nenhum deles é o próprio agente se auto-avaliando — todos são subagentes independentes:

| Portão | O que bloqueia | Onde vive |
|--------|----------------|-----------|
| Revisor da spec | Citação `arquivo:linha` que não confere ao ser aberta; afirmação sobre dependência sem a versão travada no lockfile ou a doc oficial; critério que junta vários comportamentos; requisito que só existe na prosa; seção obrigatória ausente | `skills/brainstorming/spec-document-reviewer-prompt.md` |
| Revisor do plano | Tarefa sem o critério de spec que a motivou; critério de spec que nenhuma tarefa cobre; matriz de cobertura sem as cinco colunas; linha da matriz apontando para um teste que nenhum passo cria | `skills/writing-plans/plan-document-reviewer-prompt.md` |
| Revisor da tarefa | **Reexecuta a suíte da tarefa e reporta a saída literal** — não aceita o relatório de quem implementou | `skills/subagent-driven-development/task-reviewer-prompt.md` |
| Auditoria final da branch | Critério que nenhuma tarefa entregou (*lost in translation*); tarefa que nenhum critério motivou (*invented scope*); critério sem citação (*not delivered*) | `skills/final-branch-audit/SKILL.md` |

## O que é gerado

| Artefato | Onde |
|----------|------|
| Especificação | `docs/superpowers/specs/AAAA-MM-DD-<tópico>-design.md` |
| Plano de implementação | `docs/superpowers/plans/AAAA-MM-DD-<funcionalidade>.md` |
| Mapa de cobertura | Seção `## Coverage Map` dentro da própria spec — uma linha por categoria, com estado e destino, e abaixo o registro de decisão: cada pergunta, a resposta, a recomendação dada e a fonte dela |

Tudo é arquivo versionado em git, legível sem ferramenta nenhuma. O registro de decisão é o que permite auditar depois **no que** você concordou e **com base em quê** — inclusive quando a conversa já não existe mais.

## O que acrescenta ao Superpowers

Cinco eixos. O detalhe de cada mudança, entrada por entrada, está em [`PLUS-CHANGELOG.md`](../PLUS-CHANGELOG.md).

- **Spec fundamentada em evidência** — critérios ancorados no código real e nas dependências externas já presentes no projeto, não no que o modelo supõe.
- **Contrato do plano cobrado por revisor** — um subagente lê a spec contra o plano e bloqueia critério sem tarefa, tarefa sem origem e critério sem teste.
- **Matriz de cobertura de testes** — cada critério mapeado por chave ao teste que o cobre, em vez de cobertura afirmada em prosa.
- **Revisor de tarefa que reexecuta a suíte** — o revisor roda os testes, em vez de aceitar o relatório de quem implementou.
- **Auditoria de conformidade tarefa a tarefa** — no fim da branch, cada critério é rastreado até as tarefas que o entregam e vereditado contra evidência localizada.

## Telemetria do companheiro visual

O companheiro visual do brainstorming carrega o logo da Prime Radiant do site deles, com a versão do Superpowers embutida na URL. Não vai nada do seu projeto, do seu prompt nem do seu agente — é uma contagem aproximada de uso, e o crédito é do upstream.

**A orientação deste projeto é desligar:**

```bash
export SUPERPOWERS_DISABLE_TELEMETRY=1
```

`DISABLE_TELEMETRY` e `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` também são respeitados — o superpowersplus não altera esse código.

**O padrão do código continua ligado.** O superpowersplus não vem desligado e não modifica `skills/brainstorming/scripts/server.cjs`. Desligar é ação sua, no seu ambiente. Inverter o padrão no núcleo foi avaliado e recusado: dois testes do upstream (`tests/brainstorm-server/branding.test.js:245` e `:261`) afirmam o logo presente por padrão, e reescrevê-los para dizer o contrário faria com que parassem de detectar mudanças do próprio upstream.

## Pendências conhecidas

Buracos identificados e deliberadamente não fechados estão registrados em [Pendências conhecidas](../PLUS-CHANGELOG.md#pendências-conhecidas), com o motivo de cada um não ter sido fechado. Lacuna sem registro volta como descoberta.

## Licença e crédito

MIT — ver [`LICENSE`](../LICENSE).

O superpowersplus é **obra derivada do [Superpowers](https://github.com/obra/superpowers)**, criação de [Jesse Vincent](https://blog.fsck.com) e do pessoal da [Prime Radiant](https://primeradiant.com). A metodologia, as skills e o fluxo são deles; a camada de verificação descrita acima é deste projeto. O copyright permanece com Jesse Vincent, e a obra derivada é distribuída sob os mesmos termos.

Este projeto **não tem vínculo com o autor, com a Prime Radiant ou com a Anthropic**, e não fala por nenhum deles. Problemas causados pelo superpowersplus não são problema deles: relate aqui, não no repositório original.
