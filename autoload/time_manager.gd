extends Node

# Emitido a cada ciclo lógico do jogo.
# Sistemas como ProductionManager vão escutar esse sinal.
signal on_tick(delta_time: float)

# Configuração do "Tick". Em jogos idle, geralmente processamos a economia a cada 1 segundo
# ou 0.1 segundos para manter a interface responsiva sem sobrecarregar a CPU.
@export var tick_rate: float = 1.0 

# Acumulador para separar a simulação (economia) da renderização (FPS)
var _accumulator: float = 0.0

# Controle para pausar a simulação do jogo sem pausar a engine (útil para menus e diálogos)
var is_simulation_paused: bool = false

func _process(delta: float) -> void:
	if is_simulation_paused:
		return
		
	_accumulator += delta
	
	# Processa os ticks se o acumulador ultrapassar a taxa definida
	# Usamos um 'while' pois, se houver um lag (queda de FPS), o jogo processará 
	# múltiplos ticks no mesmo frame para alcançar o tempo real perdido.
	while _accumulator >= tick_rate:
		on_tick.emit(tick_rate)
		_accumulator -= tick_rate

# Preparamos a fundação para o Progresso Offline, uma exigência da arquitetura
# que deve ser suportada desde o MVP.
func process_offline_time(seconds_elapsed: float) -> void:
	print("TimeManager: Processando %f segundos de tempo offline..." % seconds_elapsed)
	
	# Aqui, não emitimos milhares de ticks para não travar o jogo.
	# Em vez disso, emitimos um único evento com o tempo total,
	# ou dividimos em grandes 'chunks' lógicos.
	# Por enquanto, enviamos um sinal especial ou tratamos via lógica de big numbers futuramente.
	on_tick.emit(seconds_elapsed)
