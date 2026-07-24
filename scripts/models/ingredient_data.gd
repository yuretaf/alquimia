class_name IngredientData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var rarity: String = "Comum"
@export var base_value: int = 0
@export var region_id: String = ""
@export var properties: Dictionary = {} # Ex: {"property_vitality": 80}
@export var base_purity: int = 50
@export var base_stability: int = 50
@export var tags: Array[String] = []
