# Handoff — protótipos MVP e teste de sprites

**Branch deste incremento:** `docs/mvp-prototyping-gates`, baseada em `feature/s00-melissa-sprite-test`. Consultar o PR rascunho e seu HEAD para o SHA atual; ainda não fazer merge.

## Próxima ação

Apresentar `docs/prototypes/mvp_ui_v0_1.html` ao usuário e coletar validação/correções de fluxo, hierarquia, controles e telas. Registrar as respostas em `Docs/Context/PROTOTYPE_LOG.md`, atualizar a versão do protótipo se necessário e **não implementar as telas de produção antes dessa validação**.

## Estado do protótipo de interface

`Docs/Main/PROTOTYPING_METHODOLOGY.md` define o gate pré-implementação em cada fase S0–S6; `AGENTS.md` torna esse fluxo obrigatório. O HTML v0.1 cobre abertura, conta/visitante, personagens/vocações, LAN, HUD, mochila/craft, talentos, acampamento, pausa/salvamento, aliado caído, resultado, erro recuperável, configurações e divergência de sincronização. Interações e valores são ilustrativos; todas as telas aguardam validação. Nenhum gameplay foi implementado.

## Teste de sprites em andamento

A outra branch, `feature/s00-melissa-sprite-test`, mantém o [PR #2](https://github.com/fabiofsjunior/ilha-do-cristal/pull/2) em rascunho. A V2 segue como base de correção para Melissa Warrior N/S, `idle` 4 e `walk` 6. Faltam pixels opacos/nítidos, S cardinal inequívoco e passada alternada legível. Godot 4.5.1 importou/renderizou os atlas; Android não foi testado.

**Bloqueio atual:** Pixelorama não está instalado no workspace e não há display gráfico local; o editor web oficial ficou numa tela preta nesta sessão. A revisão Luna confirma que não há projeto `.pxo`; o fluxo manual precisa ser retomado em ambiente com Pixelorama aberto. Não declarar o teste artístico aprovado e não ampliar o lote.

## Limites

Não há APK, gameplay, nem S0 concluído. O conceito não é atlas. Não incluir fotos privadas. Vael/exército e conteúdo fora do MVP permanecem excluídos.
