extends Control
# res://scripts/ui/inventory_ui.gd

# Arraste a cena "inventory_slot.tscn" do FileSystem para esta variável no Inspector!
@export var slot_scene: PackedScene

# Caminho para o Grid onde os itens aparecerão
@onready var grid_container: GridContainer = %GridContainer

# Dicionário interno para rastrear rapidamente qual slot na tela representa qual item
var _slots: Dictionary = {} 

func _ready() -> void:
	# 1. Limpa qualquer slot placeholder deixado no editor por engano
	for child in grid_container.get_children():
		child.queue_free()
		
	# 2. Inscreve-se no Padrão Observer para escutar atualizações globais
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	
	# 3. Faz a carga inicial lendo o estado atual do inventário
	_full_update()

func _full_update() -> void:
	var all_items = InventoryManager.get_all_items()
	for item_id in all_items:
		_update_slot(item_id, all_items[item_id])

# Callback chamado sempre que o InventoryManager emitir o sinal[cite: 3]
func _on_inventory_changed(item_id: String, new_quantity: int, _difference: int) -> void:
	_update_slot(item_id, new_quantity)

func _update_slot(item_id: String, quantity: int) -> void:
	# Regra de Limpeza: Se a quantidade zerou, o item some da interface
	if quantity <= 0:
		if _slots.has(item_id):
			_slots[item_id].queue_free() # Destrói o nó visual
			_slots.erase(item_id) # Remove da nossa lista de rastreio
		return
		
	# Se o slot já existe na tela, apenas atualizamos o texto
	if _slots.has(item_id):
		_slots[item_id].update_slot(item_id, quantity)
	else:
		# Princípio de Instanciação Dinâmica: Cria o slot apenas se o item for novo
		var new_slot = slot_scene.instantiate() as InventorySlot
		grid_container.add_child(new_slot) # Adiciona no Grid
		new_slot.update_slot(item_id, quantity)
		_slots[item_id] = new_slot # Salva a referência
