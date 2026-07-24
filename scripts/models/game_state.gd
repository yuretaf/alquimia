class_name GameState extends Resource

# Dicionário orientado a IDs (ex: {"ingredient_moon_herb": 10})
@export var inventory: Dictionary = {}
@export var unlocked_recipes: Array[String] = []
@export var discovered_properties: Array[String] = []

# Moedas do jogo
@export var gold: int = 0
@export var knowledge: int = 0

# Na fase final do MVP, lidaremos com BigInt se o ouro passar do limite de 64-bits.
# Por enquanto, 'int' suporta até 9 quintilhões, o que atende perfeitamente ao MVP.
