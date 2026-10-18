# Atualizações de conteúdo pelo GitHub Releases

O APK 0.1.10 verifica atualizações de conteúdo ao abrir o jogo. Ele consulta Releases públicos do repositório, oferece a versão mais nova `content-vX.Y.Z` e baixa um pacote PCK quando o jogador escolhe **Atualizar agora**. O APK e o conteúdo têm versões independentes. A build Web ignora essa etapa e abre o jogo normalmente.

## O que o pacote pode atualizar

O preset **Android Content Pack** empacota dados JSON do jogo e recursos de imagem indicados no preset. Cenas (`.tscn`) e scripts (`.gd`) ficam fora do pacote. Uma atualização de regras ou código que exija scripts novos precisa de outro APK; o campo `min_app_version` avisa o jogo quando esse APK é necessário.

O pacote fica separado em `user://updates/`; saves permanecem nos diretórios próprios do jogo. Antes da ativação, o cliente confere o tamanho e o digest SHA-256 publicado pela API do GitHub. O arquivo ativo e sua versão são registrados para montagem no próximo início. Isso detecta corrupção de download; uma assinatura assimétrica deve ser adicionada antes de distribuir pacotes fora do fluxo privado do projeto, pois o digest da API não protege contra comprometimento da conta/release.

## Criar e publicar um pacote

1. Edite apenas dados e recursos já aceitos pelo APK compatível.
2. Gere o pacote com Godot 4.5.1:

   ```sh
   python3 tools/build/export_content_pack.py --version 1.0.1
   ```

   Para indicar um binário Godot específico, acrescente `--godot /caminho/para/godot`. O comando cria `build/android/ilha-do-cristal-content-v1.0.1.pck` e imprime nome, tamanho e SHA-256.
3. No GitHub, crie um Release público com a tag `content-v1.0.1` e anexe exatamente `ilha-do-cristal-content-v1.0.1.pck`.
4. Comece a descrição do Release com estas duas linhas; depois deixe uma linha em branco e escreva as notas mostradas no jogo:

   ```text
   min_app_version=0.1.10
   mandatory=false

   - Ajustes de conteúdo da ilha
   ```

   Use `mandatory=true` apenas quando a versão anterior não puder continuar compatível. Se `min_app_version` for maior que o app instalado, o jogo abre a página de Releases para a instalação do APK pelo Android.
5. Confirme que o asset publicado mostra um digest `sha256:` na API pública de Releases; sem digest ou tamanho válido, o cliente rejeita o pacote.

Cada nova versão deve incrementar o semver de conteúdo. Não substitua um asset de Release já publicado; publique outra tag/versão.

## Testes locais

```sh
godot --headless --editor --path . --import
godot --headless --path . --script tools/updater/test_content_updater.gd
godot --headless --path . --script tools/updater/test_update_boot_ui.gd
python3 tools/build/export_content_pack.py --version 1.0.1
godot --headless --path . --script tools/updater/test_content_pack.gd -- build/android/ilha-do-cristal-content-v1.0.1.pck
```

O último teste monta o PCK e lê dados JSON e uma textura. Também faça o smoke test do início do app e, antes de liberar, teste download real, checksum incorreto, modo offline, saves preservados e instalação num Android físico. A consulta ao GitHub depende de rede.
