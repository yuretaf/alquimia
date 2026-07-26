extends Control
# res://scenes/ui/market_ui.gd

@export var market_slot_scene: PackedScene

@onready var item_list: VBoxContainer = %ItemList
@onready var player_gold_label: Label = %PlayerGoldLabel
@onready var close_button: Button = %CloseButton
@onready var title_label: Label = %TitleLabel

# Rastreia os slots instanciados para atualizações rápidas
var _slots: Dictionary = {}
var _current_market_id: String = "market_capital" # Mercado padrão

func _ready() -> void:
	close_button.pressed.connect(func(): hide())
	
	# Limpa o placeholder do editor
	for child in item_list.get_children():
		child.queue_free()
		
	# Inscreve-se no Padrão Observer para atualizar a loja quando o inventário mudar
	InventoryManager.inventory_changed.connect(_on_inventory_changed)

# Chamado sempre que o jogador abrir a loja
func open_market(market_id: String = "market_capital") -> void:
	_current_market_id = market_id
	
	# Atualiza o título da janela dinamicamente
	var market_data = DatabaseManager.get_market(market_id)
	if market_data:
		pass # title_label.text = market_data.display_name
		
	show()
	_refresh_all_items()

func _refresh_all_items() -> void:
	var all_items = InventoryManager.get_all_items()
	
	# Atualiza o ouro no cabeçalho
	var current_gold = InventoryManager.get_quantity("currency_gold")
	player_gold_label.text = str(current_gold) + " Ouro"
	
	for item_id in all_items.keys():
		# Não tenta vender o próprio ouro!
		if item_id == "currency_gold": continue
		
		_update_slot(item_id, all_items[item_id])

func _on_inventory_changed(item_id: String, new_quantity: int, _difference: int) -> void:
	if not visible: return # Só atualiza a tela se a loja estiver aberta
	
	if item_id == "currency_gold":
		player_gold_label.text = str(new_quantity) + " Ouro"
	else:
		_update_slot(item_id, new_quantity)

func _update_slot(item_id: String, quantity: int) -> void:
	# Se a quantidade zerou, remove da vitrine
	if quantity <= 0:
		if _slots.has(item_id):
			_slots[item_id].queue_free()
			_slots.erase(item_id)
		return
		
	# Atualiza ou cria o slot
	if _slots.has(item_id):
		_slots[item_id].setup(item_id, quantity, _current_market_id)
	else:
		var new_slot = market_slot_scene.instantiate() as MarketSlot
		item_list.add_child(new_slot)
		# Passa o ID do mercado na criação
		new_slot.setup(item_id, quantity, _current_market_id)
		_slots[item_id] = new_slot
