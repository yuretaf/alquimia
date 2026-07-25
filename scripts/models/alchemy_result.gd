class_name AlchemyResult
extends RefCounted
# res://scripts/models/alchemy_result.gd

# Utilizamos RefCounted em vez de Resource porque este objeto é temporário
# Ele nasce apenas para carregar os dados do fim da produção até os outros sistemas, sendo descartado da memória automaticamente logo depois.

@export var success: bool = false
@export var product_id: String = ""
@export var quantity: int = 0
@export var quality: int = 0
@export var purity: int = 0
@export var stability: int = 0
@export var efficiency: float = 0.0

# Campos focados no sistema de descobertas e falhas
@export var is_discovery: bool = false
@export var failure_type: String = ""
