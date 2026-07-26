extends PanelContainer
class_name MarketSlot
# res://scenes/ui/market_slot.gd

@onready var name_label: Label = %NameLabel
@onready var stock_label: Label = %StockLabel
@onready var price_label: Label = %PriceLabel
@onready var sell_button: Button = %SellButton

var _item_id: String = ""
var _market_id: String = ""
var _sell_price: int = 0

func _ready() -> void:
	sell_button.pressed.connect(_on_sell_pressed)

# Configura visualmente o slot com os dados do item
func setup(item_id: String, stock_amount: int, market_id: String) -> void:
	_item_id = item_id
	_market_id = market_id
	
	# Busca os dados no banco oficial
	var item_data = DatabaseManager.get_item(item_id)
	if not item_data: return
	
	# Calcula o valor usando o EconomyManager
	if item_data:
		_sell_price = MarketManager.calculate_unit_price(item_id, _market_id)
		name_label.text = item_data.display_name
	else:
		# Fallback de segurança caso o item não exista no banco ainda
		_sell_price = 0
		name_label.text = item_id 
		push_warning("MarketSlot: Item não encontrado no BD: ", item_id)
		
	stock_label.text = "Em estoque: " + str(stock_amount)
	price_label.text = "+ " + str(_sell_price) + " Ouro"
	
	# Desabilita o botão se não tiver estoque
	sell_button.disabled = (stock_amount <= 0 or not item_data)

func _on_sell_pressed() -> void:
	# A UI apenas solicita a venda ao sistema responsável
	MarketManager.execute_market_sale(_item_id, 1, _market_id)
