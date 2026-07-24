extends PanelContainer
class_name InventorySlot
# res://scripts/ui/inventory_slot.gd

@onready var icon_rect: TextureRect = $VBoxContainer/IconRect
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var amount_label: Label = $VBoxContainer/AmountLabel

# Função chamada pelo painel principal para atualizar os dados visuais
func update_slot(item_id: String, amount: int) -> void:
	# Busca os dados estáticos do item para pegar o nome real e o ícone.
	# Ex: var data = Database.get_item(item_id)
	# icon_rect.texture = data.icon
	# name_label.text = data.display_name
	
	# VISUAL PROVISÓRIO (Tratando a string para ficar legível):
	# Transforma "ingredient_moon_herb" em "Moon Herb"
	var display_name = item_id.replace("ingredient_", "").replace("_", " ").capitalize()
	name_label.text = display_name
	
	# Atualiza a quantidade
	amount_label.text = "x" + str(amount)
