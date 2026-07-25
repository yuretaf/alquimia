extends Node
# Autoload: TimeManager
# Responsável por controlar o tempo do jogo e emitir ciclos (ticks) para os sistemas

# Sinal emitido a cada 'tick' do jogo. Outros sistemas escutam isso para progredir.
signal game_tick(delta: float)

# Configuração do ciclo. 1.0 = 1 segundo real por tick.
const TICK_RATE: float = 1.0 
var _accumulator: float = 0.0

func _process(delta: float) -> void:
	_accumulator += delta
	
	# Quando o tempo acumulado atingir o TICK_RATE, emiti um pulso.
	if _accumulator >= TICK_RATE:
		# Emiti o tempo exato que passou para os sistemas calcularem o progresso.
		game_tick.emit(_accumulator)
		_accumulator = 0.0

# Função preparada para no futuro calcular tempo offline
func simulate_offline_time(seconds_away: float) -> void:
	print("Simulando ", seconds_away, " segundos de progresso offline...")
	# No futuro, passar esse delta gigante para o ProductionManager processar toda a fila de uma vez
	game_tick.emit(seconds_away)
