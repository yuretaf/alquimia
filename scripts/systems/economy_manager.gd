extends Node
# Autoload: EconomyManager
# Responsável por precificar itens, calcular multiplicadores de qualidade e processar vendas.

signal item_sold(item_id: String, quantity: int, total_profit: int)

# Multiplicadores de preço baseados na qualidade do item
const QUALITY_MULTIPLIERS: Dictionary = {
	"Comum": 1.0,
	"Incomum": 1.5,
	"Raro": 2.5,
	"Excelente": 5.0,
	"Perfeito": 10.0
}

# Vende uma quantidade de um item do inventário.
# Chamado exclusivamente pelo MarketManager após calcular o preço.
func process_transaction(item_id: String, quantity: int, total_profit: int) -> bool:
	if quantity <= 0 or total_profit < 0:
		return false
		
	if not InventoryManager.has_item(item_id, quantity):
		return false
		
	# Efetua a troca
	if InventoryManager.remove_item(item_id, quantity):
		InventoryManager.add_item("currency_gold", total_profit)
		item_sold.emit(item_id, quantity, total_profit)
		return true
		
	return false
