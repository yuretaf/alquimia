extends Node

# Emitido sempre que a quantidade de um item específico muda.
# A UI (Camada de Apresentação) vai escutar esse sinal para atualizar os textos na tela.
signal inventory_changed(item_id: String, new_quantity: int)

# Referência em cache para o inventário salvo no GameState.
var _inventory_state: Dictionary = {}

func _ready() -> void:
	# Aguardamos o GameManager avisar que o estado está pronto.
	# Isso previne erros de inicialização onde o inventário tenta acessar um estado nulo.
	GameManager.game_initialized.connect(_on_game_initialized)

func _on_game_initialized() -> void:
	# Pegamos a referência do dicionário de inventário que vive no GameState
	_inventory_state = GameManager.get_state().inventory
	print("InventoryManager: Conectado ao GameState com sucesso.")

# Retorna a quantidade atual de um item.
func get_quantity(item_id: String) -> int:
	# Usamos o método get() do Dicionário, que retorna 0 se a chave não existir,
	# evitando erros de "Key Not Found".
	return _inventory_state.get(item_id, 0)

# Verifica se o jogador possui pelo menos a quantidade solicitada.
func has_item(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return true # Sempre temos 0 ou menos de alguma coisa
	return get_quantity(item_id) >= amount

# Adiciona itens ao inventário.
func add_item(item_id: String, amount: int) -> void:
	if amount <= 0:
		return
		
	var current_amount = get_quantity(item_id)
	var new_amount = current_amount + amount
	
	# No futuro, aqui também poderemos adicionar a lógica de "Verificar Capacidade" 
	# ligada aos Upgrades de Armazém Expandido[cite: 3].
	
	_inventory_state[item_id] = new_amount
	
	# Notificamos o resto do jogo (especialmente a UI) que este item mudou.
	inventory_changed.emit(item_id, new_amount)

# Remove itens do inventário.
# Retorna um booleano indicando se a operação foi um sucesso.
func remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return true
		
	if not has_item(item_id, amount):
		push_warning("InventoryManager: Tentativa de remover %d de '%s', mas há apenas %d." % [amount, item_id, get_quantity(item_id)])
		return false
		
	var new_amount = get_quantity(item_id) - amount
	_inventory_state[item_id] = new_amount
	
	inventory_changed.emit(item_id, new_amount)
	return true
