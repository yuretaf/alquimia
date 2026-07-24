class_name RecipeData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var ingredients: Dictionary = {} # Ex: {"ingredient_moon_herb": 2}
@export var required_process: String = ""
@export var required_station: String = ""
@export var production_time: float = 0.0 # Em segundos/ticks
@export var base_stability: int = 50
@export var base_purity: int = 50
@export var output_product_id: String = ""
@export var knowledge_requirement: int = 0
