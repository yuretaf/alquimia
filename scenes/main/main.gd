extends Node
# res://scenes/main/main.gd
# Atua como controlador da cena principal, gerenciando a abertura de painéis.

@onready var inventory_ui: Control = $UI_Layer/InventoryUI
@onready var toggle_inventory_button: Button = $UI_Layer/HUD/ToggleInventoryButton
@onready var test_add_herb_button: Button = $UI_Layer/HUD/TestAddHerbButton


const TEST_ITEM_ID: String = "ingredient_moon_herb"

func _ready() -> void:
	# 1. Configuração inicial da UI
	inventory_ui.hide() # Garante que o inventário comece fechado
	toggle_inventory_button.text = "Abrir Inventário"
	test_add_herb_button.text = "Coletar Erva Lunar"
	
	# 2. Conectando os sinais dos botões usando o padrão Observer
	toggle_inventory_button.pressed.connect(_on_toggle_inventory_pressed)
	test_add_herb_button.pressed.connect(_on_test_add_herb_pressed)

# --- CALLBACKS DOS BOTÕES ---

func _on_toggle_inventory_pressed() -> void:
	# Alterna a visibilidade do painel de inventário
	inventory_ui.visible = not inventory_ui.visible
	
	# Atualiza o texto do botão para dar feedback visual
	if inventory_ui.visible:
		toggle_inventory_button.text = "Fechar Inventário"
	else:
		toggle_inventory_button.text = "Abrir Inventário"

func _on_test_add_herb_pressed() -> void:
	# O botão não altera os dados! Ele APENAS solicita a ação ao InventoryManager.
	# O InventoryManager emitirá o sinal "inventory_changed", e a InventoryUI se atualizará automaticamente.
	var success: bool = InventoryManager.add_item(TEST_ITEM_ID, 1)
	
	if success:
		print("Erva Lunar adicionada com sucesso!")
	else:
		print("Falha ao adicionar: Inventário cheio.")
