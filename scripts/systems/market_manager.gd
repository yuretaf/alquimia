extends Node
# Autoload: MarketManager
# Responsável por calcular preços, controlar demanda e volatilidade

# --- MÉTODOS PÚBLICOS ---

# Calcula o preço final de uma unidade de um item em um mercado específico.
func calculate_unit_price(item_id: String, market_id: String, quality_tier: String = "Comum") -> int:
	var item_data = DatabaseManager.get_item(item_id)
	if not item_data:
		return 0
		
	var base_value = item_data.base_value
	var market_modifier: float = 1.0
	var preference_modifier: float = 1.0
	
	# 1. Aplica as regras do Mercado
	var market_data = DatabaseManager.get_market(market_id)
	if market_data:
		market_modifier = market_data.base_modifier
		
		# Verifica se a categoria do item está na lista de alta demanda do mercado
		if item_data.category in market_data.preferred_categories:
			preference_modifier = market_data.preference_bonus
	else:
		push_warning("MarketManager: Mercado não encontrado no BD - ", market_id)
	
	# 2. Aplica o multiplicador de Qualidade
	var quality_modifier = EconomyManager.QUALITY_MULTIPLIERS.get(quality_tier, 1.0)
	
	# 3. Cálculo Final
	var final_price = int(base_value * market_modifier * preference_modifier * quality_modifier)
	
	# Garante que um item nunca valha 0 por causa de penalidades de mercado
	return max(final_price, 1)

# Solicita a venda de um item após calcular seu valor de mercado.
func execute_market_sale(item_id: String, quantity: int, market_id: String, quality_tier: String = "Comum") -> bool:
	var unit_price = calculate_unit_price(item_id, market_id, quality_tier)
	
	if unit_price <= 0:
		return false
		
	var total_profit = unit_price * quantity
	
	# Delega a transação segura ao EconomyManager
	return EconomyManager.process_transaction(item_id, quantity, total_profit)
