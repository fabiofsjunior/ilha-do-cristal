extends Control
## Startup screen for optional/required GitHub content updates.

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const GAME_LOGO = preload("res://assets/ui/app_icon.png")
const GAME_SCENE := "res://game/scenes/main.tscn"

var _content: VBoxContainer
var _updater: Node
var _mandatory := false
var _progress: ProgressBar
var _progress_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_shell()
	if OS.has_feature("web"):
		_continue_to_game()
		return
	_updater = get_node("/root/ContentUpdater")
	_updater.check_completed.connect(_on_check_completed)
	_updater.download_progress.connect(_on_download_progress)
	_updater.operation_failed.connect(_on_operation_failed)
	_updater.content_installed.connect(_on_content_installed)
	_show_checking()
	_updater.check_for_updates()


func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = Color("101b26")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	margin.add_child(layout)

	var header := VBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 10)
	layout.add_child(header)
	var logo := TextureRect.new()
	logo.name = "GameLogo"
	logo.texture = GAME_LOGO
	logo.custom_minimum_size = Vector2(0, 224)
	logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(logo)
	var subtitle := Label.new()
	subtitle.text = "Exploração · sobrevivência · cooperação"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(subtitle, 13, UI_STYLE.MUTED)
	header.add_child(subtitle)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 540)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color("172630"), Color("428c83")))
	center.add_child(panel)
	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left", 28)
	inner.add_theme_constant_override("margin_top", 24)
	inner.add_theme_constant_override("margin_right", 28)
	inner.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(inner)
	_content = VBoxContainer.new()
	_content.alignment = BoxContainer.ALIGNMENT_CENTER
	_content.add_theme_constant_override("separation", 14)
	inner.add_child(_content)

	var footer := Label.new()
	footer.text = "VERIFICAÇÃO DE CONTEÚDO AO INICIAR"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(footer, 11, Color("8da5ad"))
	layout.add_child(footer)


func _clear_content() -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_progress = null
	_progress_label = null


func _add_kicker(text: String) -> void:
	var label := Label.new()
	label.text = text.to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(label, 13, Color("8de0d0"))
	_content.add_child(label)


func _add_title(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(label, 30, UI_STYLE.CREAM)
	_content.add_child(label)


func _add_body(text: String, color := UI_STYLE.MUTED, font_size := 16) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(label, font_size, color)
	_content.add_child(label)
	return label


func _add_button(text: String, action: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 60)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_button(button, primary)
	button.pressed.connect(action)
	_content.add_child(button)
	return button


func _show_checking() -> void:
	_clear_content()
	_add_kicker("Inicialização")
	_add_title("Verificando atualizações")
	_add_body("Consultando as versões de conteúdo publicadas no GitHub…")
	_add_body("A conexão é usada apenas para procurar uma versão nova.", Color("91a8b1"), 13)


func _on_check_completed(result: Dictionary) -> void:
	var status := str(result.get("status", "error"))
	_mandatory = bool(result.get("mandatory", false))
	match status:
		"available":
			_show_available(result)
		"current":
			_show_current(str(result.get("content_version", _updater.get_active_content_version())))
		"app_update_required":
			_show_app_update_required(result)
		_:
			_show_error("A resposta de atualização não foi reconhecida.")


func _show_available(result: Dictionary) -> void:
	_clear_content()
	_add_kicker("Atualização disponível")
	_add_title("Novidades na ilha")
	_add_body("Conteúdo %s · %.1f MB" % [
		str(result.get("content_version", "")),
		float(result.get("size", 0)) / 1048576.0
	])
	var notes := str(result.get("release_notes", "")).replace("\n", " · ")
	if notes.is_empty():
		notes = "Novo conteúdo e correções para a ilha."
	_add_body(notes, Color("d6e3df"), 14)
	_add_body("O jogo verifica a integridade do pacote e preserva seu progresso salvo.", Color("91a8b1"), 13)
	_add_button("Atualizar agora", Callable(self, "_begin_update"), true)
	if not _mandatory:
		_add_button("Agora não", Callable(self, "_continue_to_game"))
	else:
		_add_body("Esta atualização é necessária para continuar.", Color("f4c875"), 13)


func _show_current(version: String) -> void:
	_clear_content()
	_add_kicker("Tudo atualizado")
	_add_title("Bem-vindo à ilha")
	_add_body("Conteúdo %s · sem novos arquivos para baixar." % version)
	_add_body("Seus arquivos de progresso ficam separados dos pacotes de atualização.", Color("91a8b1"), 13)
	_add_button("Entrar no jogo", Callable(self, "_continue_to_game"), true)


func _show_app_update_required(result: Dictionary) -> void:
	_clear_content()
	_add_kicker("Atualização do aplicativo necessária")
	_add_title("Seu APK precisa ser atualizado")
	_add_body("Este pacote de conteúdo requer o app %s ou superior." % str(result.get("min_app_version", "")))
	_add_body("O jogo abre os Releases do projeto para baixar o APK. O Android solicitará confirmação da instalação.", Color("91a8b1"), 13)
	_add_button("Abrir atualizações do APK", Callable(self, "_open_release_page"), true)
	_add_button("Tentar novamente", Callable(_updater, "check_for_updates"))


func _on_download_progress(downloaded: int, total: int) -> void:
	if _progress == null:
		return
	if total > 0:
		_progress.value = clampf(float(downloaded) / float(total) * 100.0, 0.0, 100.0)
		_progress_label.text = "%s / %s" % [_format_size(downloaded), _format_size(total)]


func _format_size(bytes: int) -> String:
	return "%.1f MB" % (float(bytes) / 1048576.0)


func _show_downloading() -> void:
	_clear_content()
	_add_kicker("Baixando do GitHub")
	_add_title("Preparando a atualização")
	_add_body("Baixando o pacote de conteúdo…")
	_progress = ProgressBar.new()
	_progress.min_value = 0
	_progress.max_value = 100
	_progress.custom_minimum_size = Vector2(0, 22)
	_content.add_child(_progress)
	_progress_label = _add_body("Aguardando dados…", Color("a8c0c4"), 13)


func _begin_update() -> void:
	_show_downloading()
	_updater.download_available_update()


func _on_operation_failed(message: String) -> void:
	_show_error(message)


func _show_error(message: String) -> void:
	_clear_content()
	_add_kicker("Atualização indisponível")
	_add_title("Não foi possível atualizar")
	_add_body(message)
	_add_button("Tentar novamente", Callable(_updater, "check_for_updates"), true)
	if not _mandatory:
		_add_button("Continuar com a versão atual", Callable(self, "_continue_to_game"))


func _on_content_installed(version: String) -> void:
	_clear_content()
	_add_kicker("Pacote verificado")
	_add_title("Reiniciando o jogo")
	_add_body("Conteúdo %s instalado. Recarregando a tela inicial…" % version)
	_add_body("Seu progresso salvo foi mantido.", Color("8de0d0"), 13)
	await get_tree().create_timer(0.9).timeout
	_continue_to_game()


func _continue_to_game() -> void:
	var err := get_tree().change_scene_to_file(GAME_SCENE)
	if err != OK:
		_show_error("Não foi possível abrir o jogo (%s)." % error_string(err))


func _open_release_page() -> void:
	OS.shell_open(_updater.get_release_page_url())
