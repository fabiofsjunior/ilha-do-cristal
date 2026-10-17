# Build Android — Ilha do Cristal

## Preset e limites do APK

`export_presets.cfg` mantém o preset Web e acrescenta `Android Debug`. O Android exporta para `build/android/ilha-do-cristal-debug.apk`, usa o identificador estável `com.fabiofsjunior.ilhadocristal`, inclui ARMv7 e ARM64 e desativa x86. A orientação é retrato (`display/window/handheld/orientation=1`). O nome no launcher é **A Ilha do Cristal**; ícones clássico, adaptativo e monocromático usam o cristal pixel art do projeto. A build atual é 0.1.6/versionCode 7, para que o Android reconheça o pacote como atualização da 0.1.5. O HUD usa o viewport inteiro e posiciona os controles de movimento e spells nos cantos inferiores; safe areas malformadas pelo sistema são descartadas para manter os controles visíveis. O preset não habilita permissões Android: a fatia atual é local e não usa rede, localização, microfone ou armazenamento compartilhado.

Este é um APK de desenvolvimento assinado com uma chave debug local. Ele pode ser instalado por sideload para teste, mas não é uma chave de publicação nem um artefato pronto para a Play Store.

## Ferramentas e versões

O Android exige import ETC2/ASTC antes da exportação; `project.godot` ativa `rendering/textures/vram_compression/import_etc2_astc=true`. Ao mudar isso num checkout que já foi importado, remova `.godot/imported/` uma vez e reimporte, como pede a [documentação da configuração](https://docs.godotengine.org/en/4.5/classes/class_projectsettings.html#class-projectsettings-property-rendering-textures-vram-compression-import-etc2-astc).

Versões fixadas para reprodutibilidade:

| Componente | Versão/localização usada nesta sessão |
|---|---|
| Godot editor | `4.5.1.stable.official.f62fdbde1` |
| Java | OpenJDK 17; `JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64` |
| Android SDK | `/opt/android-sdk`; Platform 35, Build Tools 35.0.0, Platform Tools, Command-line Tools latest |
| NDK / CMake | Não usados pelo preset atual, que exporta com o APK template pré-compilado e `gradle_build/use_gradle_build=false` |
| Templates Godot | `~/.local/share/godot/export_templates/4.5.1.stable/`; `android_debug.apk`, `web_nothreads_debug.zip`, `web_nothreads_release.zip` |
| Keystore debug | `~/.local/share/godot/keystores/debug.keystore`, criado localmente se ausente; alias `androiddebugkey` |

O executável Godot, SDK, templates e keystore ficam fora do Git. Para outro computador Linux, instale os pacotes indicados pela [documentação Android do Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html), configure **Editor > Editor Settings > Export > Android** com os caminhos do JDK e SDK, e instale os templates correspondentes ao Godot 4.5.1. A Godot recomenda OpenJDK 17; a lista de pacotes Android inclui Platform Tools, Build Tools 35.0.0, Platform 35, NDK 28.1.13356709 e CMake 3.10.2.4988404. Baixe Android Command-line Tools somente de [Android Developers](https://developer.android.com/studio#command-tools) e os templates da [release oficial Godot 4.5.1](https://github.com/godotengine/godot/releases/tag/4.5.1-stable).

Com o `sdkmanager` oficial instalado no SDK, os pacotes desta configuração podem ser instalados assim:

```sh
sdkmanager --sdk_root=/opt/android-sdk \
  "platform-tools" "platforms;android-35" "build-tools;35.0.0" \
  "ndk;28.1.13356709" "cmake;3.10.2.4988404"
sdkmanager --sdk_root=/opt/android-sdk --licenses
```

## Gerar e validar

No Linux, rode na raiz do projeto:

```sh
python3 tools/build/export_android.py
```

O script usa `Godot_v4.5.1-stable_linux.x86_64` na raiz quando presente; `--godot` ou `GODOT_BIN` apontam para outra localização. `--sdk` ou `ANDROID_SDK_ROOT` selecionam o Android SDK. Ele configura os caminhos de SDK/Java nas preferências locais do editor, cria a chave debug se necessário, cria `build/.gdignore`, importa recursos, exporta com `--export-debug` e valida package ID, nome do app, orientação, ícones do launcher, permissões, CRC do APK, assinatura e ausência dos caminhos de ferramentas/documentação/referências no payload.

Os logs são gravados em `build/logs/android-import.log` e `build/logs/android-export.log`. O script falha se o Godot emitir `SCRIPT ERROR:` ou `ERROR:`, ainda que retorne código zero. Depois da validação, grava `build/android/BUILD_INFO.json` com engine, commit-fonte, data UTC, package ID, SHA-256 do APK, arquivos JSON runtime incluídos e os status de dados/arte candidata.

Exemplo com caminhos explícitos:

```sh
GODOT_BIN=/caminho/Godot_v4.5.1-stable_linux.x86_64 \
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
ANDROID_SDK_ROOT=/opt/android-sdk \
python3 tools/build/export_android.py --output build/android/ilha-do-cristal-debug.apk
```

Para revisar o resultado manualmente:

```sh
/opt/android-sdk/build-tools/35.0.0/aapt dump xmltree build/android/ilha-do-cristal-debug.apk AndroidManifest.xml
/opt/android-sdk/cmdline-tools/latest/bin/apkanalyzer manifest print build/android/ilha-do-cristal-debug.apk
/opt/android-sdk/build-tools/35.0.0/apksigner verify --verbose --print-certs build/android/ilha-do-cristal-debug.apk
```

Neste Build Tools 35.0.0, `aapt dump badging` retorna código 1 ao ler `android:required` como inteiro, embora o APK seja válido. Por isso o script verifica manifesto com `aapt dump xmltree` e `apkanalyzer manifest print`, além da assinatura com `apksigner`; não use `badging` como gate de export neste SDK.

Com um Android conectado e autorizado para depuração USB, `adb devices` lista o aparelho; depois instale e abra o APK:

```sh
/opt/android-sdk/platform-tools/adb install -r build/android/ilha-do-cristal-debug.apk
/opt/android-sdk/platform-tools/adb shell monkey -p com.fabiofsjunior.ilhadocristal 1
```

## Evidência e gate de aparelho

O export baseline deste worktree (commit `e7eb0e0`) produziu um APK de 59.450.686 bytes. O verificador encontrou `com.fabiofsjunior.ilhadocristal`, API mínima 24, alvo 35, orientação Android landscape (`screenOrientation=0`), nenhuma permissão `uses-permission`, assinatura APK v2/v3 válida, CRC válido e JSONs de runtime presentes. `apkanalyzer files list` confirmou que `tools/`, `docs/`, `Docs/`, `assets/references/`, `build/` e `dist/` não foram empacotados. Esta validação do baseline não substitui uma reexportação após integração do loop S2. `build/`, logs, sidecar e APKs são ignorados pelo Git. Essas verificações demonstram integridade estrutural, assinatura debug e manifesto; não demonstram que a UI abriu ou que o controle funciona num aparelho.

A integração S2 foi reexportada a partir de `bbba04f8d278f141cef7cb431dbecd22d1c02c49`, com os mesmos gates de pacote aprovados. O APK final tem 59.550.750 bytes; hashes e testes estão em [MVP_BUILD_VALIDATION.md](../gameplay/MVP_BUILD_VALIDATION.md). O preset Web sem threads precisa dos templates `web_nothreads_*.zip`; os templates `web_debug.zip`/`web_release.zip` servem para a variante com threads.

O teste headless de layout simula recortes e áreas seguras Android em três proporções, confirma que o HUD mantém o viewport completo, verifica o joystick no canto inferior esquerdo e as spells no direito, valida os limites de toque e envia toque virtual ao joystick. Isso não substitui instalação/abertura em aparelho real; S0/S1 permanecem pendentes até validar safe area do fabricante, legibilidade, multitouch e estabilidade no dispositivo.

## Referências oficiais

- [Exporting for Android — Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html)
- [EditorExportPlatformAndroid — Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_editorexportplatformandroid.html)
- [ProjectSettings orientation — Godot 4.5](https://docs.godotengine.org/en/4.5/classes/class_projectsettings.html)
- [Android SDK Command-line Tools](https://developer.android.com/studio#command-tools)
- [sdkmanager](https://developer.android.com/tools/sdkmanager)
- [Godot 4.5.1 official release](https://github.com/godotengine/godot/releases/tag/4.5.1-stable)
