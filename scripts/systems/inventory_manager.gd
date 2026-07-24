extends Node
# Autoload: InventoryManager
# Responsável por controlar adições, remoções e consultas de itens.

# --- SINAIS ---
# Emitido sempre que a quantidade de um item muda. A UI deve escutar este sinal.
signal inventory_changed(item_id: String, new_quantity: int, difference: int)
signal inventory_full() # Pode ser útil para feedback visual futuro

# --- ESTADO ---
# No futuro, este dicionário será referenciado/carregado do GameState pelo SaveManager[cite: 3].
# Formato: { "item_id_string": quantidade_int }[cite: 3]
var _items: Dictionary = {}

# Capacidade global temporária para o MVP (pode ser substituída por upgrades depois)[cite: 3]
var global_capacity_limit: int = 9999 

# --- MÉTODOS PÚBLICOS ---

# Adiciona uma quantidade de um item pelo seu ID[cite: 3].
func add_item(item_id: String, quantity: int) -> bool:
	if quantity <= 0:
		push_warning("Tentativa de adicionar quantidade nula ou negativa do item: ", item_id)
		return false
		
	var current_qty = get_quantity(item_id)
	var new_qty = current_qty + quantity
	
	# Validação de Capacidade[cite: 3]
	if new_qty > global_capacity_limit:
		# Adiciona apenas até o limite
		var allowed_to_add = global_capacity_limit - current_qty
		if allowed_to_add > 0:
			_items[item_id] = global_capacity_limit
			inventory_changed.emit(item_id, global_capacity_limit, allowed_to_add)
		inventory_full.emit()
		return false # Não conseguiu adicionar tudo
		
	_items[item_id] = new_qty
	inventory_changed.emit(item_id, new_qty, quantity)
	return true

# Remove uma quantidade de um item pelo seu ID[cite: 3].
func remove_item(item_id: String, quantity: int) -> bool:
	if quantity <= 0:
		return false
		
	if not has_item(item_id, quantity):
		push_warning("Tentativa de remover mais itens do que o disponível: ", item_id)
		return false
		
	_items[item_id] -= quantity
	inventory_changed.emit(item_id, _items[item_id], -quantity)
	
	# Limpeza de memória: remove a chave se a quantidade chegar a zero
	if _items[item_id] == 0:
		_items.erase(item_id)
		
	return true

# Verifica se o jogador possui a quantidade necessária de um item[cite: 3].
func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_quantity(item_id) >= quantity

# Retorna a quantidade atual de um item[cite: 3].
func get_quantity(item_id: String) -> int:
	return _items.get(item_id, 0)
	
# Retorna o inventário inteiro (útil para o SaveManager no futuro)[cite: 3].
func get_all_items() -> Dictionary:
	return _items.duplicate()
