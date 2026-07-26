extends Node
# Autoload: DatabaseManager
# Responsável por carregar e fornecer acesso a todos os dados estáticos do jogo

var _items: Dictionary = {}
var _recipes: Dictionary = {}
var _markets: Dictionary = {}

func _ready() -> void:
	_load_all_data()

# --- CARREGAMENTO DE DADOS ---

func _load_all_data() -> void:
	# Carrega todos os recursos estáticos das pastas definidas na arquitetura
	_load_directory("res://data/items/", _items)
	_load_directory("res://data/recipes/", _recipes)
	_load_directory("res://data/markets/", _markets)
	print("DatabaseManager: Carregados %d ingredientes, %d receitas e %d mercados." % [_items.size(), _recipes.size(), _markets.size()])

# Função genérica para varrer uma pasta e carregar arquivos .tres
func _load_directory(path: String, target_dict: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource_path = path + file_name
				var resource = ResourceLoader.load(resource_path)
				
				# Valida se o recurso tem a propriedade 'id' (presente nos Models)
				if resource and "id" in resource and resource.id != "":
					target_dict[resource.id] = resource
				else:
					push_warning("Recurso inválido ou sem ID: ", resource_path)
					
			file_name = dir.get_next()
	else:
		push_warning("DatabaseManager: Pasta não encontrada - ", path)

# --- MÉTODOS PÚBLICOS DE CONSULTA ---

# Verifica se um item genérico (ingrediente, produto, etc.) existe no banco.
func has_item(item_id: String) -> bool:
	# No futuro, expandir essa checagem para produtos, equipamentos, etc.
	return _items.has(item_id)

func get_item(item_id: String) -> ItemData:
	return _items.get(item_id, null)

func has_recipe(recipe_id: String) -> bool:
	return _recipes.has(recipe_id)

func get_recipe(recipe_id: String) -> RecipeData:
	return _recipes.get(recipe_id, null)

func get_market(market_id: String) -> MarketData:
	return _markets.get(market_id, null)
