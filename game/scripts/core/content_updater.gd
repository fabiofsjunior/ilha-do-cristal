extends Node
## Checks GitHub content releases, downloads a PCK, validates GitHub's SHA-256
## asset digest, mounts it, and keeps the active pack pointer under user://.

signal check_completed(result: Dictionary)
signal download_progress(downloaded_bytes: int, total_bytes: int)
signal operation_failed(message: String)
signal content_installed(version: String)

const RELEASES_API_URL := "https://api.github.com/repos/fabiofsjunior/ilha-do-cristal/releases?per_page=100"
const RELEASE_PAGE_URL := "https://github.com/fabiofsjunior/ilha-do-cristal/releases"
const RELEASE_TAG_PREFIX := "content-v"
const ASSET_PREFIX := "ilha-do-cristal-content-v"
const MAX_CONTENT_PACK_BYTES := 536870912
const ACTIVE_RECORD_PATH := "user://updates/active.json"
const DEFAULT_CONTENT_VERSION := "1.0.0"
const CHECK_TIMEOUT_SECONDS := 15.0
const DOWNLOAD_TIMEOUT_SECONDS := 300.0

enum RequestState { IDLE, CHECKING, DOWNLOADING }

var _request: HTTPRequest
var _state := RequestState.IDLE
var _selected_release: Dictionary = {}
var _active_content_version := DEFAULT_CONTENT_VERSION
var _progress_tick_ms := 0


func _init() -> void:
	if OS.has_feature("web"):
		return
	# Autoload _init runs before the first scene. Mount the last verified pack
	# before any game resources are loaded.
	_active_content_version = str(ProjectSettings.get_setting("application/config/content_version", DEFAULT_CONTENT_VERSION))
	_restore_active_pack()


func _ready() -> void:
	_request = HTTPRequest.new()
	_request.name = "GitHubContentRequest"
	_request.timeout = CHECK_TIMEOUT_SECONDS
	_request.max_redirects = 8
	_request.download_chunk_size = 65536
	_request.request_completed.connect(_on_request_completed)
	add_child(_request)


func _process(_delta: float) -> void:
	if _state != RequestState.DOWNLOADING or _request == null:
		return
	var now := Time.get_ticks_msec()
	if now - _progress_tick_ms < 150:
		return
	_progress_tick_ms = now
	download_progress.emit(_request.get_downloaded_bytes(), int(_selected_release.get("size", 0)))


func get_active_content_version() -> String:
	return _active_content_version


func get_release_page_url() -> String:
	return RELEASE_PAGE_URL


func check_for_updates() -> void:
	if _state != RequestState.IDLE:
		return
	_state = RequestState.CHECKING
	_request.timeout = CHECK_TIMEOUT_SECONDS
	_request.download_file = ""
	var headers := PackedStringArray([
		"Accept: application/vnd.github+json",
		"X-GitHub-Api-Version: 2022-11-28",
		"User-Agent: IlhaDoCristal-ContentUpdater"
	])
	var err := _request.request(RELEASES_API_URL, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_fail("Não foi possível iniciar a consulta ao GitHub (%s)." % error_string(err))


func download_available_update() -> void:
	if _state != RequestState.IDLE or _selected_release.is_empty():
		return
	var update_url := str(_selected_release.get("download_url", ""))
	if not _is_allowed_asset_url(update_url):
		_fail("O endereço do pacote não pertence aos Releases oficiais do projeto.")
		return
	var directory := ProjectSettings.globalize_path("user://updates")
	var dir_err := DirAccess.make_dir_recursive_absolute(directory)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		_fail("Não foi possível preparar o armazenamento da atualização (%s)." % error_string(dir_err))
		return
	var version := str(_selected_release.get("content_version", ""))
	var candidate := "user://updates/content_%s.pck" % version.replace(".", "_")
	var absolute_candidate := ProjectSettings.globalize_path(candidate)
	if not _remove_file(absolute_candidate):
		_fail("Não foi possível substituir um arquivo temporário de atualização.")
		return
	_request.download_file = absolute_candidate
	_request.timeout = DOWNLOAD_TIMEOUT_SECONDS
	_state = RequestState.DOWNLOADING
	_progress_tick_ms = 0
	var err := _request.request(update_url, PackedStringArray([
		"User-Agent: IlhaDoCristal-ContentUpdater"
	]), HTTPClient.METHOD_GET)
	if err != OK:
		_request.timeout = CHECK_TIMEOUT_SECONDS
		_fail("Não foi possível iniciar o download (%s)." % error_string(err))


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _state == RequestState.CHECKING:
		_handle_release_list(result, response_code, body)
	elif _state == RequestState.DOWNLOADING:
		_handle_download(result, response_code)
	_request.timeout = CHECK_TIMEOUT_SECONDS


func _handle_release_list(result: int, response_code: int, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_fail(_http_error_message(result, response_code, "consultar as versões"))
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_ARRAY:
		_fail("O GitHub respondeu com uma lista de versões inválida.")
		return
	var selected := select_latest_content_release(parsed, _get_app_version(), _get_current_content_version())
	if str(selected.get("status", "error")) == "error":
		_fail(str(selected.get("message", "A versão publicada contém dados inválidos.")))
		return
	_state = RequestState.IDLE
	if str(selected.get("status", "")) == "available":
		_selected_release = selected
	else:
		_selected_release.clear()
	check_completed.emit(selected)


func _handle_download(result: int, response_code: int) -> void:
	var candidate := _candidate_path_for(str(_selected_release.get("content_version", "")))
	var absolute_candidate := ProjectSettings.globalize_path(candidate)
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		_remove_file(absolute_candidate)
		_fail(_http_error_message(result, response_code, "baixar o pacote"))
		return
	var expected_size := int(_selected_release.get("size", 0))
	if not FileAccess.file_exists(absolute_candidate):
		_fail("O download terminou, mas o arquivo PCK não foi criado.")
		return
	var downloaded_file := FileAccess.open(absolute_candidate, FileAccess.READ)
	if downloaded_file == null:
		_fail("Não foi possível abrir o pacote baixado: %s" % error_string(FileAccess.get_open_error()))
		return
	var actual_size := downloaded_file.get_length()
	downloaded_file.close()
	if actual_size != expected_size:
		_remove_file(absolute_candidate)
		_fail("O tamanho do pacote baixado não confere; a versão atual foi preservada.")
		return
	var expected_digest := str(_selected_release.get("digest", "")).trim_prefix("sha256:").to_lower()
	var actual_digest := FileAccess.get_sha256(absolute_candidate).to_lower()
	if actual_digest.is_empty() or actual_digest != expected_digest:
		_remove_file(absolute_candidate)
		_fail("A integridade do pacote não confere; a versão atual foi preservada.")
		return
	var global_candidate := ProjectSettings.globalize_path(candidate)
	if not ProjectSettings.load_resource_pack(global_candidate, true):
		_remove_file(absolute_candidate)
		_fail("A Godot não conseguiu abrir o pacote. O jogo continuará na versão anterior.")
		return
	if not _save_active_record(candidate, str(_selected_release.content_version), actual_digest):
		_fail("O pacote foi carregado, mas não foi possível registrar a versão ativa.")
		return
	_active_content_version = str(_selected_release.content_version)
	_state = RequestState.IDLE
	_request.download_file = ""
	content_installed.emit(_active_content_version)


func _fail(message: String) -> void:
	_state = RequestState.IDLE
	if _request != null:
		_request.download_file = ""
	push_warning(message)
	operation_failed.emit(message)


func _http_error_message(result: int, response_code: int, action: String) -> String:
	if response_code == 403 or response_code == 429:
		return "O limite de consultas do GitHub foi atingido. Tente novamente mais tarde."
	if result != HTTPRequest.RESULT_SUCCESS:
		return "Não foi possível %s. Verifique sua conexão." % action
	return "O GitHub retornou HTTP %d ao %s." % [response_code, action]


func _get_app_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.1.10"))


func _get_current_content_version() -> String:
	return _active_content_version


func _candidate_path_for(version: String) -> String:
	return "user://updates/content_%s.pck" % version.replace(".", "_")


func _is_allowed_asset_url(url: String) -> bool:
	return url.begins_with("https://github.com/fabiofsjunior/ilha-do-cristal/releases/download/")


func _restore_active_pack() -> void:
	var absolute_record := ProjectSettings.globalize_path(ACTIVE_RECORD_PATH)
	var absolute_backup := absolute_record + ".bak"
	var primary_exists := FileAccess.file_exists(absolute_record)
	var backup_exists := FileAccess.file_exists(absolute_backup)
	if not primary_exists and not backup_exists:
		return
	if primary_exists and _try_restore_pack_record(absolute_record):
		return
	if backup_exists:
		push_warning("O registro principal de atualização não pôde ser usado; tentando a cópia anterior.")
		if _try_restore_pack_record(absolute_backup):
			return
	push_error("O pacote de conteúdo salvo não pôde ser restaurado; usando o conteúdo base.")


func _try_restore_pack_record(record_path: String) -> bool:
	var file := FileAccess.open(record_path, FileAccess.READ)
	if file == null:
		push_error("Não foi possível ler o registro da atualização %s: %s" % [record_path, error_string(FileAccess.get_open_error())])
		return false
	var record: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(record) != TYPE_DICTIONARY or int(record.get("schema_version", 0)) != 1:
		push_error("O registro da atualização está corrompido ou usa uma versão não suportada: %s" % record_path)
		return false
	var pack_path := str(record.get("pack_path", ""))
	var version := str(record.get("content_version", ""))
	var expected_digest := str(record.get("sha256", "")).to_lower()
	if not pack_path.begins_with("user://updates/") or not pack_path.ends_with(".pck") or not _is_valid_version(version) or expected_digest.length() != 64:
		push_error("O registro da atualização contém um caminho, versão ou digest inválidos: %s" % record_path)
		return false
	var absolute_pack := ProjectSettings.globalize_path(pack_path)
	if not FileAccess.file_exists(absolute_pack) or FileAccess.get_sha256(absolute_pack).to_lower() != expected_digest:
		push_error("O pacote ativo está ausente ou teve sua integridade alterada: %s" % absolute_pack)
		return false
	if not ProjectSettings.load_resource_pack(absolute_pack, true):
		push_error("Não foi possível carregar o pacote ativo: %s" % pack_path)
		return false
	_active_content_version = version
	return true


func _remove_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var err := DirAccess.remove_absolute(path)
	if err != OK:
		push_error("Não foi possível remover o arquivo temporário %s: %s" % [path, error_string(err)])
		return false
	return true


func _save_active_record(pack_path: String, version: String, digest: String) -> bool:
	var absolute_record := ProjectSettings.globalize_path(ACTIVE_RECORD_PATH)
	var absolute_tmp := absolute_record + ".tmp"
	var absolute_backup := absolute_record + ".bak"
	var dir_err := DirAccess.make_dir_recursive_absolute(absolute_record.get_base_dir())
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		push_error("Não foi possível criar o diretório de atualização: %s" % error_string(dir_err))
		return false
	var file := FileAccess.open(absolute_tmp, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível gravar o registro temporário: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify({
		"schema_version": 1,
		"content_version": version,
		"pack_path": pack_path,
		"sha256": digest
	}))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		_remove_file(absolute_tmp)
		push_error("Falha ao gravar o registro da atualização: %s" % error_string(write_error))
		return false
	if not _remove_file(absolute_backup):
		return false
	if FileAccess.file_exists(absolute_record):
		var backup_err := DirAccess.rename_absolute(absolute_record, absolute_backup)
		if backup_err != OK:
			push_error("Não foi possível preservar o registro anterior: %s" % error_string(backup_err))
			return false
	var replace_err := DirAccess.rename_absolute(absolute_tmp, absolute_record)
	if replace_err != OK:
		if FileAccess.file_exists(absolute_backup):
			var restore_err := DirAccess.rename_absolute(absolute_backup, absolute_record)
			if restore_err != OK:
				push_error("Falha ao restaurar o registro anterior (%s): %s" % [absolute_backup, error_string(restore_err)])
		push_error("Não foi possível ativar o novo registro: %s" % error_string(replace_err))
		return false
	_remove_file(absolute_backup)
	return true


static func select_latest_content_release(releases: Variant, app_version: String, current_content_version: String) -> Dictionary:
	if typeof(releases) != TYPE_ARRAY or not _is_valid_version(app_version) or not _is_valid_version(current_content_version):
		return {"status": "error", "message": "A lista de versões ou o número de versão é inválido."}
	var newest_release: Dictionary = {}
	var newest_version := ""
	for release_value in releases:
		if typeof(release_value) != TYPE_DICTIONARY:
			continue
		var release: Dictionary = release_value
		var tag := str(release.get("tag_name", ""))
		if not tag.begins_with(RELEASE_TAG_PREFIX) or bool(release.get("draft", false)) or bool(release.get("prerelease", false)):
			continue
		var content_version := tag.trim_prefix(RELEASE_TAG_PREFIX)
		if not _is_valid_version(content_version):
			return {"status": "error", "message": "A versão do pacote publicada no GitHub é inválida."}
		if compare_versions(content_version, current_content_version) > 0 and (newest_release.is_empty() or compare_versions(content_version, newest_version) > 0):
			newest_release = release
			newest_version = content_version
	if newest_release.is_empty():
		return {"status": "current", "content_version": current_content_version}
	var release_url := str(newest_release.get("html_url", ""))
	if not release_url.begins_with("https://github.com/fabiofsjunior/ilha-do-cristal/releases/tag/"):
		return {"status": "error", "message": "A página da versão não pertence ao projeto esperado."}
	var body := str(newest_release.get("body", ""))
	var min_app_version := _metadata_value(body, "min_app_version", app_version)
	if not _is_valid_version(min_app_version):
		return {"status": "error", "message": "A versão mínima do APK nesta publicação é inválida."}
	if compare_versions(app_version, min_app_version) < 0:
		return {
			"status": "app_update_required",
			"content_version": newest_version,
			"min_app_version": min_app_version,
			"release_url": RELEASE_PAGE_URL
		}
	var asset_name := "%s%s.pck" % [ASSET_PREFIX, newest_version]
	var asset: Dictionary = {}
	for asset_value in newest_release.get("assets", []):
		if typeof(asset_value) == TYPE_DICTIONARY and str(asset_value.get("name", "")) == asset_name:
			asset = asset_value
			break
	if asset.is_empty():
		return {"status": "error", "message": "A publicação não inclui o pacote %s." % asset_name}
	var download_url := str(asset.get("browser_download_url", ""))
	var digest := str(asset.get("digest", "")).to_lower()
	var size := int(asset.get("size", 0))
	if not download_url.begins_with("https://github.com/fabiofsjunior/ilha-do-cristal/releases/download/"):
		return {"status": "error", "message": "O link do pacote não é um GitHub Release do projeto."}
	if not digest.begins_with("sha256:") or digest.length() != 71 or size <= 0 or size > MAX_CONTENT_PACK_BYTES:
		return {"status": "error", "message": "O pacote publicado não possui digest SHA-256 ou tamanho válido."}
	return {
		"status": "available",
		"content_version": newest_version,
		"app_version": app_version,
		"min_app_version": min_app_version,
		"mandatory": _metadata_value(body, "mandatory", "false").to_lower() == "true",
		"release_name": str(newest_release.get("name", "content-v%s" % newest_version)),
		"release_notes": _release_notes(body),
		"release_url": release_url,
		"download_url": download_url,
		"digest": digest,
		"size": size,
		"asset_name": asset_name
	}


static func compare_versions(left: String, right: String) -> int:
	var a := _version_parts(left)
	var b := _version_parts(right)
	if a.is_empty() or b.is_empty():
		return 0
	for index in range(3):
		if a[index] > b[index]:
			return 1
		if a[index] < b[index]:
			return -1
	return 0


static func _metadata_value(body: String, key: String, fallback: String) -> String:
	for line_value in body.split("\n"):
		var line := str(line_value).strip_edges()
		var parts := line.split("=", false, 1)
		if parts.size() == 2 and str(parts[0]).strip_edges() == key:
			return str(parts[1]).strip_edges()
	return fallback


static func _release_notes(body: String) -> String:
	var notes := PackedStringArray()
	for line_value in body.split("\n"):
		var line := str(line_value)
		var trimmed := line.strip_edges()
		if trimmed.begins_with("min_app_version=") or trimmed.begins_with("mandatory="):
			continue
		if not trimmed.is_empty():
			notes.append(trimmed)
	return "\n".join(notes)


static func _is_valid_version(version: String) -> bool:
	return not _version_parts(version).is_empty()


static func _version_parts(version: String) -> PackedInt32Array:
	var parts := version.split(".", false)
	if parts.size() != 3:
		return PackedInt32Array()
	var parsed := PackedInt32Array()
	for part in parts:
		if not str(part).is_valid_int() or int(part) < 0:
			return PackedInt32Array()
		parsed.append(int(part))
	return parsed
