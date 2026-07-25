class_name ProductionJob
extends RefCounted
# res://scripts/models/production_job.gd

# Enumeração dos estados possíveis da produção
enum Status {
	QUEUED,     # Na fila, aguardando espaço
	RUNNING,    # Sendo processado
	COMPLETED,  # Finalizado com sucesso
	FAILED,     # Falhou (recursos podem ser perdidos)
	CANCELLED   # Cancelado pelo jogador (recursos devolvidos)
}

var job_id: String = ""
var recipe_id: String = ""
var station_id: String = ""

var duration: float = 0.0
var time_elapsed: float = 0.0
var status: Status = Status.QUEUED

# Armazena os ingredientes fornecidos para que o AlchemyManager possa avaliá-los no final
var ingredients_provided: Dictionary = {}

# Avança o progresso da produção com base no tempo (delta) fornecido pelo TimeManager.
func process_tick(delta: float) -> void:
	if status != Status.RUNNING:
		return
		
	time_elapsed += delta
	if time_elapsed >= duration:
		status = Status.COMPLETED
