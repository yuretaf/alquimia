extends Node
# Autoload: ProductionManager
# Responsável por gerenciar filas de produção, consumir recursos e processar o tempo.

# --- SINAIS ---
signal production_started(job: ProductionJob)
signal production_completed(job: ProductionJob, result: AlchemyResult)
signal queue_updated(station_id: String)

# --- ESTADO ---
# Formato: { "station_id": [ProductionJob, ProductionJob, ...] }
var _station_queues: Dictionary = {}

func _ready() -> void:
	# Inscreve-se no motor de tempo. A produção só avança quando o TimeManager "diz".
	TimeManager.game_tick.connect(_on_game_tick)

# --- MÉTODOS PÚBLICOS ---

# Tenta iniciar uma produção e colocá-la na fila da estação desejada.
func enqueue_production(recipe: RecipeData, station_id: String) -> bool:
	# 1. Validação de Ingredientes e Consumo Prévio
	var ingredients_to_consume = recipe.ingredients
	
	# Verifica se tem tudo antes de remover qualquer coisa
	for item_id in ingredients_to_consume.keys():
		if not InventoryManager.has_item(item_id, ingredients_to_consume[item_id]):
			push_warning("Ingredientes insuficientes para: ", recipe.display_name)
			return false
			
	# Remove os itens do inventário
	for item_id in ingredients_to_consume.keys():
		InventoryManager.remove_item(item_id, ingredients_to_consume[item_id])
		
	# 2. Criação do Job
	var new_job = ProductionJob.new()
	new_job.job_id = str(Time.get_unix_time_from_system()) + "_" + recipe.id # ID único simples
	new_job.recipe_id = recipe.id
	new_job.station_id = station_id
	new_job.duration = recipe.production_time
	new_job.ingredients_provided = ingredients_to_consume.duplicate()
	new_job.status = ProductionJob.Status.QUEUED
	
	# 3. Adiciona à fila da estação
	if not _station_queues.has(station_id):
		_station_queues[station_id] = []
		
	_station_queues[station_id].append(new_job)
	
	production_started.emit(new_job)
	queue_updated.emit(station_id)
	return true

# --- MÉTODOS PRIVADOS (LOOP DE TEMPO) ---

# Chamado a cada pulso de tempo pelo TimeManager
func _on_game_tick(delta: float) -> void:
	for station_id in _station_queues.keys():
		_process_station_queue(station_id, delta)

func _process_station_queue(station_id: String, delta: float) -> void:
	var queue: Array = _station_queues[station_id]
	
	if queue.is_empty():
		return
		
	# O primeiro item da fila é o que é processado ativamente
	var active_job: ProductionJob = queue[0]
	
	if active_job.status == ProductionJob.Status.QUEUED:
		active_job.status = ProductionJob.Status.RUNNING
		
	# Avança o progresso
	active_job.process_tick(delta)
	
	# Verifica conclusão
	if active_job.status == ProductionJob.Status.COMPLETED:
		_finish_job(active_job, station_id)

func _finish_job(job: ProductionJob, station_id: String) -> void:
	# 1. Remove da fila
	var queue: Array = _station_queues[station_id]
	queue.pop_front()
	
	# 2. Busca a Receita Real no Banco de Dados Data-Driven
	var recipe = DatabaseManager.get_recipe(job.recipe_id)
	if not recipe:
		push_error("ProductionManager: Tentou finalizar uma receita que não existe no BD: ", job.recipe_id)
		# Falha de segurança, devolve os itens para o jogador não ser prejudicado
		for item_id in job.ingredients_provided:
			InventoryManager.add_item(item_id, job.ingredients_provided[item_id])
		queue_updated.emit(station_id)
		return
	
	# 3. O AlchemyManager calcula o resultado matemático baseando-se nos dados reais
	var result: AlchemyResult = AlchemyManager.process_known_recipe(recipe, job.ingredients_provided)
	
	# 4. Entrega o item ao jogador se for sucesso
	if result.success:
		InventoryManager.add_item(result.product_id, result.quantity)
		
	production_completed.emit(job, result)
	queue_updated.emit(station_id)
