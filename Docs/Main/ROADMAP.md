# Roadmap mobile-first

Sem datas arbitrárias. Cada etapa fecha com demonstração no aparelho e critérios verificáveis. Trabalho em PRs pequenos por sprint; a fase seguinte começa após validação da anterior. A ordem vem do processo mecânica → escala/visão → arte técnica → loop → persistência → rede → nuvem. GDD e catálogo permanecem em `Docs/Main/`; Journal e Handoff em `Docs/Context/` registram continuidade.

| Sprint | Entrega | Aceite |
|---|---|---|
| S0 — Preparação | Fixar versão Godot 4, projeto importável, preset Android, orientação horizontal, tela base e CI leve de importação/export debug; criar script opcional Pillow para asset geométrico de teste | Projeto abre sem erros e APK inicial instala em aparelho |
| S1 — Movimento | Tilemap pequeno, câmera 50–125%, joystick 8 direções, colisão, toque em objeto | Jogar em paisagem por 10 min sem travar; botões legíveis em dois tamanhos de tela |
| S2 — Loop vertical | Melissa, uma vocação, raposa, madeira/erva, ataque, drop, curativo, fogueira/baú | Coletar → enfrentar → curar → retornar → salvar/reabrir no Android |
| S3 — Mundo e conteúdo | Seed/chunks, praia/floresta/interior, Helena, três vocações/nove skills, raposa/lobo/urso, crafting, acampamento I–III, XP/árvore parcial | Meta do MVP concluída solo, progressão e construção persistem |
| S4 — LAN | Host autoritativo, entrada por IP/código local ou descoberta testada, sincronização de combate/itens, reanimação | Dois Androids na mesma rede sem duplicar drops; desconexão salva mundo |
| S5 — Contas | Prova Firebase Auth, vínculo de visitante, progressão na nuvem, fila offline e resolução de conflitos | Troca de aparelho recupera personagem; mundo continua no host; internet ausente não bloqueia LAN |
| S6 — Beta | UX, acessibilidade, áudio, otimização, save interrompido, tutorial, correção e build distribuível | Bateria de testes em aparelhos reais e sessão 30 min sem perda de progresso |

Gate de cada PR: objetivo e antes/depois, teste específico, nenhum arquivo privado, importação Godot, evidência APK quando aplicável. Documentar resultado de FPS/memória sem prometer valor antes de medir. Conteúdo além do nível 10, NPCs coletores, outros monstros, castelo/Vael jogável e desktop ficam para atualizações posteriores.

Checklist vivo:

- [x] GDD minimalista, balanceamento inicial, arquitetura e arte conceitual.
- [x] Pastas `Docs/Main/` e `Docs/Context/`, Journal, Handoff e regras `AGENTS.md`.
- [ ] S0: Godot importável, orientação e APK Android instalado.
- [ ] S1: movimento, escala e câmera em aparelhos reais.
- [ ] S2: loop vertical coleta → combate → curativo → save.
- [ ] S3: conteúdo, geração em chunks, progressão e meta solo.
- [ ] S4: LAN entre dois Androids.
- [ ] S5: conta/progressão e modo visitante/offline.
- [ ] S6: beta e testes de resiliência.

Após GDD, produzir em sequência: contratos JSON em `data/`, protótipo de controles, sprites técnicos com pivôs, teste de cache/chunks, save resiliente, rede LAN. O tamanho 1000×1000 é limite de mundo, não requisito de preencher toda área com conteúdo no primeiro APK.
