class_name MarketData
extends Resource
# res://scripts/models/market_data.gd

@export var id: String = ""
@export var display_name: String = ""
@export var base_modifier: float = 1.0 # Ex: Mercado da Capital = 1.0, Arcano = 1.2
@export var volatility: float = 0.0 # Define o quanto os preços flutuam

# Categorias de itens que este mercado paga mais caro (demanda elevada)
# Ex: O Mercado da Fronteira tem alta demanda por Poções de Cura
@export var preferred_categories: Array[String] = [] 
@export var preferred_tags: Array[String] = []

# Modificador extra aplicado caso o item seja o preferido do mercado
@export var preference_bonus: float = 1.5
