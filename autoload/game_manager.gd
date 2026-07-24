extends Node

# Emitido quando o jogo termina de carregar e está pronto para iniciar.
signal game_initialized

var current_state: GameState

func _ready() -> void:
	# No futuro, aqui chamaremos o SaveManager para tentar carregar um save existente.
	# Como estamos na fundação, vamos inicializar um estado zerado.
	_initialize_new_game()

func _initialize_new_game() -> void:
	current_state = GameState.new()
	
	# Valores de teste iniciais para o MVP
	current_state.gold = 0
	current_state.knowledge = 0
	
	print("GameManager: Novo GameState criado com sucesso.")
	game_initialized.emit()

# Função auxiliar para garantir que outros sistemas acessem o estado com segurança
func get_state() -> GameState:
	return current_state
