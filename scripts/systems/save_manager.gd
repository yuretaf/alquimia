extends Node
# Autoload: SaveManager
# Responsável por salvar, carregar, validar dados e gerenciar versões do save.

signal save_started
signal save_completed(success: bool)
signal load_completed(success: bool)

const SAVE_DIR: String = "user://saves/"
const SECRET_KEY: String = "chave_mestra_alquimia_2026" # Senha de criptografia. Futuramente guardar isso de forma mais segura.

func _ready() -> void:
	# Garante que a pasta raiz de saves exista assim que o jogo abrir
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# --- MÉTODOS PÚBLICOS DE SAVE / LOAD ---

# Coleta os dados de todos os sistemas e salva no disco.
func save_game(world_id: String, world_display_name: String = "Novo Mundo") -> void:
	save_started.emit()
	var world_path = SAVE_DIR + world_id + "/"
	
	# Cria a pasta específica do mundo (Ex: user://saves/world_01/)
	if not DirAccess.dir_exists_absolute(world_path):
		DirAccess.make_dir_recursive_absolute(world_path)

	# 1. Monta o Estado Persistente (O que vai ser criptografado)
	var current_time = Time.get_unix_time_from_system()
	var state_data: Dictionary = {
		"version": 1, # Versionamento de save para migrações futuras
		"timestamp": current_time,
		# O SaveManager delega a criação dos dados para os sistemas especialistas
		"inventory": InventoryManager.get_save_data(),
		# "production": ProductionManager.get_save_data()
	}

	# 2. Monta os Metadados (Público, para a tela de Seleção de Mundos ler rápido)
	var meta_data: Dictionary = {
		"world_id": world_id,
		"world_name": world_display_name,
		"last_played": current_time,
		"version": 1
	}

	# 3. Salva os arquivos com extensões personalizadas
	var success_meta = _write_file(world_path + "meta.data", meta_data, false)
	var success_state = _write_file(world_path + "state.world", state_data, true) # Criptografado!

	if success_meta and success_state:
		print("SaveManager: Progresso salvo com sucesso no mundo: ", world_id)
		save_completed.emit(true)
	else:
		push_error("SaveManager: Falha ao salvar o jogo.")
		save_completed.emit(false)

# Carrega o save de um mundo e distribui os dados para os sistemas.
func load_game(world_id: String) -> bool:
	var world_path = SAVE_DIR + world_id + "/"
	var state_path = world_path + "state.world"
	
	if not FileAccess.file_exists(state_path):
		push_warning("SaveManager: Save não encontrado para ", world_id)
		return false
		
	var state_data = _read_file(state_path, true) # Lê descriptografando
	
	if state_data.is_empty():
		return false
		
	# 1. Extrai o timestamp para cálculo offline progress (Tempo Ausente)
	if state_data.has("timestamp"):
		var last_time = state_data["timestamp"]
		var time_away = Time.get_unix_time_from_system() - last_time
		# TimeManager.simulate_offline_time(time_away)
		
	# 2. Distribui os dados de volta aos sistemas
	if state_data.has("inventory"):
		InventoryManager.load_save_data(state_data["inventory"])

	print("SaveManager: Jogo carregado com sucesso! Mundo: ", world_id)
	load_completed.emit(true)
	return true

# --- MÉTODOS PRIVADOS DE DISCO ---

# Escreve um dicionário em disco, opcionalmente aplicando criptografia nativa.
func _write_file(path: String, data: Dictionary, encrypt: bool) -> bool:
	var json_string = JSON.stringify(data)
	var file: FileAccess
	
	if encrypt:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECRET_KEY)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
		
	if file:
		file.store_string(json_string)
		file.close()
		return true
	return false

# Lê um arquivo do disco e converte de volta para Dicionário.
func _read_file(path: String, encrypted: bool) -> Dictionary:
	var file: FileAccess
	
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECRET_KEY)
	else:
		file = FileAccess.open(path, FileAccess.READ)
		
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(content) == OK:
			return json.data as Dictionary
			
	push_error("SaveManager: Falha ao ler ou descriptografar arquivo: ", path)
	return {}
