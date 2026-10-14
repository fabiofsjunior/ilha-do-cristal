# Metodologia de prototipagem e validação do MVP

**Versão 1.0 · 2026-10-14.** Esta metodologia vale para cada fase S0–S6, para mudanças materiais de UX e para produção visual em lote. O objetivo é descobrir problemas de fluxo, hierarquia e escala antes de investir na implementação final.

## Regra central

Antes de implementar uma fase, prototipar as telas, estados e transições afetados e apresentar o resultado ao usuário. A implementação dependente só começa após validação explícita. Se o usuário pedir mudanças, atualizar o protótipo, versioná-lo e reapresentá-lo. Enquanto a validação estiver pendente, fazer somente trabalho independente dela.

Um protótipo pode ser rascunho em papel, wireframe, tela navegável HTML/Figma ou cena Godot com dados falsos. Deve ser rápido, reversível, claramente identificado como protótipo e suficiente para avaliar a decisão em questão. Não conectar saves, contas, rede, compras ou regras reais para validar uma tela.

## Ciclo por fase

1. **Recortar a fase:** citar objetivo, público, plataforma, telas afetadas, itens fora de escopo e critérios do GDD/roadmap.
2. **Mapear o fluxo:** desenhar caminho principal e alternativas; incluir estados relevantes de carregamento, vazio, indisponibilidade, erro recuperável, offline e confirmação.
3. **Prototipar:** criar somente os artefatos necessários para revisar conteúdo, ordem, legibilidade, feedback e navegação. Usar placeholders quando sprites, dados ou serviços ainda não estiverem aprovados.
4. **Apresentar e validar:** fornecer versão navegável ou pranchas, explicar o que está simulado e perguntar decisões concretas. Estados do registro são `rascunho`, `em validação`, `corrigir`, `aprovado` ou `substituído`.
5. **Fechar o gate:** só marcar `aprovado` quando houver retorno explícito do usuário. Registrar a decisão e a versão aprovada. Silêncio, conclusão técnica do arquivo ou aprovação de um protótipo anterior não equivalem a aceite.
6. **Implementar e comparar:** codificar a versão aprovada; comparar a cena real com o protótipo em Godot e registrar desvios intencionais. Fazer os testes do roadmap em aparelho Android; mockups e screenshots de editor não substituem esse teste.

## O que revisar

- **Fluxo e hierarquia:** objetivo de cada tela visível, ordem das ações, retorno/cancelamento, estados que levam à próxima tela e possibilidade de recuperação.
- **Uso em Android paisagem:** proporção horizontal, notch/áreas seguras, orientação, densidade, tamanho de fonte e alvos de toque; controles usados com os polegares sem cobrir combate ou informação crítica.
- **Legibilidade:** HP/MP, objetivo, minimapa, mochila, habilidades, cooldown/erro e feedback de dano em mapas claros e escuros; zoom de 50% a 125% quando houver campo de jogo.
- **Acessibilidade e estados:** contraste, sinais além de cor, texto ampliável dentro do layout, áudio por categoria, indisponível/pressionado/carregando/sem conexão e confirmação de ações relevantes.
- **Consistência:** termos e IDs do catálogo, identidade visual, vocação permanente, equipamento sem trocar a aparência e estilo aprovado de RPG Clássico.

Não inventar regra ou conteúdo para deixar uma tela mais completa. Identificar dados ilustrativos, campos em aberto e decisões que dependem do usuário. O protótipo não é a especificação final do sistema.

## Aplicação por sprint

| Fase | Prototipagem mínima anterior à implementação |
|---|---|
| S0 — Preparação | Abertura, paisagem, margens seguras, tamanho base de texto e primeiro fluxo de entrada |
| S1 — Movimento | HUD sobre mapa/SQM, joystick, ações, interação, enquadramento e zoom |
| S2 — Loop vertical | Estados de coleta, combate, cura, mochila/craft, retorno ao refúgio, pausa e salvamento |
| S3 — Mundo e conteúdo | Escolha de aparência/vocação, árvore parcial, feedback das skills, regiões, bestiário e níveis do acampamento |
| S4 — LAN | Criar/entrar, espera, desconexão/reconexão, aliado caído e reanimação |
| S5 — Contas | Visitante, vínculo, offline/online, conflito e recuperação de progresso |
| S6 — Beta | Tutorial, configurações, acessibilidade, áudio, mensagens de erro e ajustes de usabilidade |

O mapa da fase no [roadmap](ROADMAP.md) pode ampliar essa lista de acordo com as telas realmente afetadas. Cada alteração visual material depois do gate reabre a validação daquela tela.

## Liberação do MVP final

Não chamar um build de MVP final enquanto houver fase ou tela dependente sem protótipo revisado e aprovado. Antes da entrega final, conferir que:

- os protótipos de todas as fases implementadas foram validados explicitamente e as decisões estão no registro;
- cada fase cumpriu os critérios técnicos e funcionais do roadmap, com diferenças entre protótipo aprovado e implementação explicadas;
- o fluxo ponta a ponta foi testado em dois aparelhos Android em paisagem, incluindo estados offline/erro/salvamento previstos;
- arte, áudio, conteúdo e acessibilidade não foram tratados como aprovados apenas por constarem no protótipo.

Prototipagem reduz retrabalho, mas não substitui testes de aceitação, teste de aparelho nem revisão final do usuário.

## Protótipo de arte e sprites

Para personagens, monstros ou VFX, tratar a primeira peça representativa como protótipo. Validar silhueta/identidade, escala na SQM, célula, pivô, transparência, leitura nos zooms e renderização no Godot antes de ampliar direções, vocações, espécies ou efeitos. Para a arte técnica do MVP, preservar os critérios em [`docs/art/ART_DIRECTION_AND_SPRITES.md`](../../docs/art/ART_DIRECTION_AND_SPRITES.md) e o gate da etapa 1 em [`docs/art/MELISSA_TECHNICAL_QA.md`](../../docs/art/MELISSA_TECHNICAL_QA.md). Pixelorama, nearest-neighbor ou uma importação válida não corrigem anatomia, antialias embutido ou identidade por si sós; registrar defeitos e corrigi-los na fonte.

Não marcar uma prancha conceitual como atlas. A aprovação da arte não aprova a UI, e a validação de telas não aprova sprites. São gates separados, ambos documentados.

## Registro por protótipo

Manter em [`Docs/Context/PROTOTYPE_LOG.md`](../Context/PROTOTYPE_LOG.md): ID/versão, fase, objetivo, artefato/link, tamanho de viewport/dispositivo, itens simulados, perguntas de validação, feedback, alterações, estado do gate e evidência posterior à implementação. Arquivos-fonte devem ficar no repositório em `docs/prototypes/` ou em localização durável equivalente. Não gravar fotos privadas, credenciais, saves pessoais ou segredos nos protótipos.

### Modelo de revisão

```text
Protótipo: <id e versão>
Fase e objetivo: <S0–S6 / resultado pretendido>
Telas/estados: <lista>
Artefato: <caminho ou URL>
Viewport e plataforma: <dimensões / aparelho, se aplicável>
Simulado: <dados e ações sem implementação real>
Decisões a validar: <perguntas curtas>
Feedback do usuário: <data e resumo fiel>
Estado: <rascunho | em validação | corrigir | aprovado | substituído>
Implementação comparada: <caminho, teste, dispositivo ou pendente>
``` 

## Primeiro protótipo de interface

[`docs/prototypes/mvp_ui_v0_1.html`](../../docs/prototypes/mvp_ui_v0_1.html) reúne as telas e estados conhecidos do GDD do MVP em um protótipo navegável. Foi criado para revisão de fluxo e composição; os desenhos de personagem são placeholders, os botões simulam transições e nenhum dado é persistido. O registro está em **em validação** até o usuário revisar.
