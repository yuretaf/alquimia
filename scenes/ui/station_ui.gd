extends PanelContainer
class_name StationUI
# res://scenes/ui/station_ui.gd

@onready var station_name_label: Label = %StationNameLabel
@onready var production_progress: ProgressBar = %ProductionProgress
@onready var status_label: Label = %StatusLabel
@onready var produce_button: Button = %ProduceButton

var _current_station_id: String = "station_alchemy_table"
var _active_job: ProductionJob = null

func _ready() -> void:
	station_name_label.text = "Mesa Alquímica"
	_reset_visuals()
	
	# Inscrição nos sinais globais
	ProductionManager.production_started.connect(_on_production_started)
	ProductionManager.production_completed.connect(_on_production_completed)
	TimeManager.game_tick.connect(_on_game_tick)
	
	produce_button.pressed.connect(_on_produce_pressed)

func _reset_visuals() -> void:
	production_progress.value = 0
	production_progress.max_value = 1
	status_label.text = "Status: Ocioso"
	produce_button.disabled = false
	_active_job = null

# --- EVENTOS DA INTERFACE ---

func _on_produce_pressed() -> void:
	# Isso virá de uma lista de botões que o jogador escolheu na UI.
	# Por enquanto, testa chamando a receita real do BD.
	var target_recipe_id = "recipe_health_potion"
	var recipe = DatabaseManager.get_recipe(target_recipe_id)
	
	if recipe:
		var success = ProductionManager.enqueue_production(recipe, _current_station_id)
		if not success:
			status_label.text = "Sem Ingredientes!"
	else:
		status_label.text = "Receita não encontrada no BD!"
		push_warning("StationUI: Crie o arquivo .tres para ", target_recipe_id)

# --- OBSERVERS DOS SISTEMAS ---

func _on_production_started(job: ProductionJob) -> void:
	if job.station_id == _current_station_id:
		_active_job = job
		production_progress.max_value = job.duration
		production_progress.value = 0
		status_label.text = "Produzindo..."
		produce_button.disabled = true

func _on_game_tick(_delta: float) -> void:
	# A UI apenas reflete o tempo que o TimeManager processou
	if _active_job != null and _active_job.status == ProductionJob.Status.RUNNING:
		production_progress.value = _active_job.time_elapsed

func _on_production_completed(job: ProductionJob, result: AlchemyResult) -> void:
	if job.station_id == _current_station_id:
		_reset_visuals()
		# O AlchemyResult contém a qualidade final calculada
		status_label.text = "Pronto: " + result.product_id
