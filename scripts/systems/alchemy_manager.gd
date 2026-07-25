extends Node
# Autoload: AlchemyManager
# Responsável exclusivo por validar receitas, calcular estabilidade, pureza e qualidade

# --- SINAIS ---
# Emite um sinal quando uma operação lógica termina (útil para o DiscoveryManager futuramente)
signal alchemy_completed(result: AlchemyResult)

# --- DADOS ESTÁTICOS (Matriz de Compatibilidade) ---
# Valores positivos representam Compatibilidade (bônus), negativos representam Conflito (penalidade).
# Combinações não listadas são consideradas Neutras (0)
const COMPATIBILITY_MATRIX: Dictionary = {
	"property_vitality": {
		"property_purity": 20,   # Alta compatibilidade
		"property_shadow": -20   # Possível conflito
	},
	"property_mana": {
		"property_purity": 10,   # Compatibilidade média
		"property_fire": 15
	}
}

# --- MÉTODOS PÚBLICOS ---

# Processa uma tentativa de alquimia baseada em uma receita e nos ingredientes fornecidos.
# Retorna um AlchemyResult determinístico.
func process_known_recipe(recipe: RecipeData, ingredients_provided: Dictionary) -> AlchemyResult:
	var result = AlchemyResult.new()
	
	# 1. Validação Básica: O jogador tem os ingredientes exatos da receita?
	if not _validate_ingredients(recipe.ingredients, ingredients_provided):
		result.success = false
		result.failure_type = "ingredientes_incompativeis"
		return result
		
	# 2. Cálculos Alquímicos Iniciais (MVP Base)
	# Uma receita conhecida tem resultado previsível.
	result.success = true
	result.product_id = recipe.output_product_id
	result.quantity = 1 # Altera com base na eficiência futuramente
	
	# 1. Analisa as propriedades dos ingredientes fornecidos para achar a compatibilidade
	var compatibility_modifier = _calculate_compatibility(ingredients_provided)
	
	# 2. Aplica a compatibilidade na Estabilidade Base (evitando que passe de 100 ou caia abaixo de 0)
	result.stability = clampi(recipe.base_stability + compatibility_modifier, 0, 100)
	result.purity = recipe.base_purity
	result.efficiency = 1.0 
	
	# 3. Calcula a Qualidade injetando o modificador real
	result.quality = _calculate_quality_score(result.purity, result.stability, result.efficiency, compatibility_modifier)
	
	# Emite o sinal para que o DiscoveryManager (quando existir) possa avaliar o resultado
	alchemy_completed.emit(result)
	
	return result

# --- MÉTODOS PRIVADOS ---

# Calcula a compatibilidade total cruzando as propriedades de todos os ingredientes fornecidos.
func _calculate_compatibility(ingredients_provided: Dictionary) -> int:
	var total_compatibility: int = 0
	var present_properties: Array[String] = []
	
	# Passo A: Extrai todas as propriedades únicas da mistura
	for item_id in ingredients_provided.keys():
		var ingredient_data = DatabaseManager.get_ingredient(item_id)
		
		if ingredient_data:
			# Pega as chaves do dicionário de propriedades do Resource
			for prop_id in ingredient_data.properties.keys():
				if not present_properties.has(prop_id):
					present_properties.append(prop_id)
		else:
			push_warning("AlchemyManager: Ingrediente não encontrado no banco - ", item_id)
	
	# Passo B: Analisa todos os pares únicos possíveis na mistura
	var num_props = present_properties.size()
	for i in range(num_props):
		for j in range(i + 1, num_props):
			var prop_a = present_properties[i]
			var prop_b = present_properties[j]
			total_compatibility += _get_pair_compatibility(prop_a, prop_b)
	
	return total_compatibility

# Consulta a matriz para descobrir a relação entre duas propriedades específicas.
func _get_pair_compatibility(prop_a: String, prop_b: String) -> int:
	# Checa a matriz na ordem A -> B
	if COMPATIBILITY_MATRIX.has(prop_a) and COMPATIBILITY_MATRIX[prop_a].has(prop_b):
		return COMPATIBILITY_MATRIX[prop_a][prop_b]
	# Checa a matriz na ordem B -> A
	elif COMPATIBILITY_MATRIX.has(prop_b) and COMPATIBILITY_MATRIX[prop_b].has(prop_a):
		return COMPATIBILITY_MATRIX[prop_b][prop_a]
	
	# Se não existe na matriz, o estado é Neutro
	return 0


# Calcula o valor numérico da Qualidade
func _calculate_quality_score(purity: int, stability: int, efficiency: float, compatibility: int) -> int:
	# A fórmula conceitual soma os fatores principais
	var base_score = purity + stability + compatibility
	# Aplica a eficiência do processo como um multiplicador.
	var final_score = int(base_score * efficiency)
	return final_score # Retorna a classificação em texto da qualidade baseada no Score

# Útil para a UI exibir "Poção de Cura (Excelente)" em vez de "Score 150".
func get_quality_tier_name(quality_score: int) -> String:
	# Como Pureza e Estabilidade vão até 100 cada, o score base máximo é 200.
	if quality_score <= 40:
		return "Comum"
	elif quality_score <= 80:
		return "Incomum"
	elif quality_score <= 120:
		return "Raro"
	elif quality_score <= 160:
		return "Excelente"
	else:
		return "Perfeito"

# Verifica se os ingredientes fornecidos atendem aos requisitos da receita.
func _validate_ingredients(required: Dictionary, provided: Dictionary) -> bool:
	for item_id in required:
		# Se o ingrediente não foi fornecido ou a quantidade é insuficiente, falha.
		if not provided.has(item_id) or provided[item_id] < required[item_id]:
			return false
	return true
