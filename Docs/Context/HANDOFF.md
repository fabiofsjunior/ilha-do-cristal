# Handoff — APK 0.1.6 integrado e validado estruturalmente

- Main remota após PR #12: `84a68f891ef63f7d6949832f0a8065dc3d75e600`.
- PR: https://github.com/fabiofsjunior/ilha-do-cristal/pull/12
- Árvore de código conferida integralmente: `fd8dc0ada0301d5efe62e6b1b959ba91ae3f020a`, idêntica ao snapshot local validado. As features empilhadas estão incluídas na main.
- APK debug entregue: 0.1.6/versionCode 7, package `com.fabiofsjunior.ilhadocristal`, portrait, ARMv7/ARM64, 64.680.671 bytes.
- SHA-256: `94a3e75920b3608c870e42af0172aaef3d23e28b465243b1077dfb7cfe153517`.

## Evidências

CRC ZIP sem falhas, manifesto e presença das assinaturas v2/v3 conferidos. Os 89 arquivos fonte diretamente comparáveis dentro do APK coincidem byte a byte com a árvore local; os scripts GDScript estão exportados em bytecode. O sidecar registra a base 8140343; o relatório da exportação documenta o worktree sujo posteriormente consolidado em b0b7b7f.

Passaram nesta sessão: catálogo (10 grupos/54 IDs), validate_playable_slice.py, test_melee_visual_spacing.py e validate_mvp_terrain_tileset.py. O validador da fatia passou após restringir a guarda aos atlas usados em runtime.

## Próxima ação e bloqueios

Instalar a 0.1.6 em Android físico e validar joystick, janela de atributos, restauração de HP/MP ao subir de nível, HUD, combate, save e estabilidade. Esta sessão não tinha Godot, Android SDK, adb ou dispositivo, portanto não houve nova exportação nem playtest físico. Não declarar o gate mobile concluído. A build Web permanece 0.1.5.
