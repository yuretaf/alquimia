extends Node
# Autoload: DebugConsole
# Responsável por fornecer uma interface de comandos para testes sistêmicos.

@onready var console_window: Window = $ConsoleWindow
@onready var log_text: RichTextLabel = %LogText
@onready var input_field: LineEdit = %InputField

# Dicionário que mapeia a string do comando para uma função
var _commands: Dictionary = {}

func _ready() -> void:
	console_window.hide()
	input_field.text_submitted.connect(_on_text_submitted)
	# Conecta o botão "X" (fechar) da própria janela nativa
	console_window.close_requested.connect(_on_close_requested)
	_register_commands()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		console_window.visible = !console_window.visible
		if console_window.visible:
			input_field.grab_focus()
			input_field.clear()

func _on_close_requested() -> void:
	console_window.hide()
	
# --- SISTEMA DE COMANDOS ---

func _register_commands() -> void:
	# Mapeia comandos simples para funções internas
	_commands["give"] = _cmd_give
	_commands["time"] = _cmd_time
	_commands["help"] = _cmd_help
	_commands["save"] = _cmd_save
	_commands["load"] = _cmd_load

func _on_text_submitted(text: String) -> void:
	input_field.clear()
	if text.strip_edges() == "": return
	
	_print_to_log("> " + text, Color.GRAY)
	_parse_command(text)

func _parse_command(input: String) -> void:
	var parts = input.split(" ", false) # Quebra o texto por espaços
	var cmd = parts[0].to_lower()
	parts.remove_at(0) # Sobram apenas os argumentos
	
	if _commands.has(cmd):
		_commands[cmd].call(parts)
	else:
		_print_to_log("Comando não reconhecido. Digite 'help' para a lista.", Color.RED)

func _print_to_log(msg: String, color: Color = Color.WHITE) -> void:
	# Usa BBCode para colorir as saídas no painel
	log_text.text += "[color=#%s]%s[/color]\n" % [color.to_html(false), msg]

# --- IMPLEMENTAÇÃO DOS COMANDOS ---

# Uso: give [item_id] [quantidade]
func _cmd_give(args: Array) -> void:
	if args.size() < 2:
		_print_to_log("Uso correto: give <item_id> <quantidade>", Color.YELLOW)
		return
		
	var item_id = args[0]
	var quantity = args[1].to_int()
	
	# 1. VALIDAÇÃO: O item existe no banco de dados?
	if not DatabaseManager.has_item(item_id):
		_print_to_log("Erro: O item '%s' não existe no banco de dados." % item_id, Color.RED)
		return
	
	# 2. Se existe, adiciona ao inventário
	if InventoryManager.add_item(item_id, quantity):
		# Pega o nome real do item para um print mais bonito
		var item_data = DatabaseManager.get_item(item_id)
		var display_name = item_data.display_name if item_data else item_id
		
		_print_to_log("Adicionado %d de %s." % [quantity, display_name], Color.GREEN)
	else:
		_print_to_log("Falha ao adicionar o item (Inventário cheio?).", Color.RED)

# Uso: time [segundos]
func _cmd_time(args: Array) -> void:
	if args.size() < 1:
		_print_to_log("Uso correto: time <segundos>", Color.YELLOW)
		return
		
	var seconds = args[0].to_float()
	TimeManager.simulate_offline_time(seconds)
	_print_to_log("Simulado avanço de %f segundos." % seconds, Color.AQUA)

func _cmd_help(_args: Array) -> void:
	_print_to_log("Comandos disponíveis: give, time, help", Color.LIGHT_BLUE)

func _cmd_save(_args: Array) -> void:
	SaveManager.save_game("world_01", "Meu Laboratório")
	_print_to_log("Jogo salvo com sucesso em world_01!", Color.GREEN)

func _cmd_load(_args: Array) -> void:
	if SaveManager.load_game("world_01"):
		_print_to_log("Jogo carregado com sucesso!", Color.GREEN)
	else:
		_print_to_log("Falha ao carregar o save.", Color.RED)
