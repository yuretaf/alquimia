class_name ItemData
extends Resource
# res://scripts/models/item_data.gd

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var category: String = "Material" # Pode ser "Herbal", "Poção", "Mineral", etc.
@export var rarity: String = "Comum"
@export var base_value: int = 0
@export var properties: Dictionary = {} # Usado na alquimia
@export var base_purity: int = 50
@export var base_stability: int = 50
@export var tags: Array[String] = []
