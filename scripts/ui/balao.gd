extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.


## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given cue when using balloon as a [Node] in a scene.
@export var start_from_cue: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Polygon2D = %Progress

#region Timer de escolha

## Maior delta contado por frame. Evita que o tempo "pule" quando o jogo
## volta de uma aba em segundo plano (onde o navegador congela os frames).
const DELTA_MAXIMO := 0.25

## Trecho do roteiro disparado quando o tempo de uma escolha acaba.
const CUE_SILENCIO := "silencio"

## Cores da barra de tempo: cheia -> metade -> acabando.
const COR_TEMPO_CHEIO := Color(0.3, 0.8, 0.3)
const COR_TEMPO_METADE := Color(0.95, 0.8, 0.2)
const COR_TEMPO_ACABANDO := Color(0.9, 0.15, 0.15)

## Barra que mostra o tempo restante, em cima do menu de escolhas.
@onready var barra_tempo: ProgressBar = %BarraTempo

## Emitido quando o timer de uma escolha começa e acaba (por escolha ou por tempo).
signal timer_escolha_iniciado(segundos: float)
signal timer_escolha_parado

var _tempo_total: float = 0.0
var _tempo_restante: float = 0.0
var _timer_ativo: bool = false
var _sem_foco: bool = false

#endregion


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()



func _process(delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice")

	# Com o jogo pausado o _process não roda, então o timer também para.
	if _timer_ativo and not _sem_foco:
		_tempo_restante -= minf(delta, DELTA_MAXIMO)
		_atualizar_barra()
		if _tempo_restante <= 0.0:
			_on_tempo_esgotado()


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Sem foco (outra aba/janela), o timer de escolha congela.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_sem_foco = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_sem_foco = false

	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()
	_parar_timer()
	var linha_aplicada: DialogueLine = dialogue_line

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
		# Só aqui, depois de a fala terminar de ser digitada (e se ela ainda é a atual).
		if dialogue_line == linha_aplicada:
			_iniciar_timer()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	_parar_timer()
	next(response.next_id)


#endregion

#region Timer de escolha


func _iniciar_timer() -> void:
	var segundos: float = EstadoJogo.tempo_escolha
	if segundos <= 0.0:
		return
	_tempo_total = segundos
	_tempo_restante = segundos
	_timer_ativo = true
	_atualizar_barra()
	barra_tempo.show()
	timer_escolha_iniciado.emit(segundos)


func _parar_timer() -> void:
	barra_tempo.hide()
	if not _timer_ativo:
		return
	_timer_ativo = false
	timer_escolha_parado.emit()


## Atualiza o tamanho e a cor da barra: verde -> amarelo -> vermelho.
func _atualizar_barra() -> void:
	var fracao: float = clampf(_tempo_restante / _tempo_total, 0.0, 1.0)
	barra_tempo.value = fracao
	var cor: Color
	if fracao > 0.5:
		cor = COR_TEMPO_METADE.lerp(COR_TEMPO_CHEIO, (fracao - 0.5) * 2.0)
	else:
		cor = COR_TEMPO_ACABANDO.lerp(COR_TEMPO_METADE, fracao * 2.0)
	(barra_tempo.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = cor


## Tempo acabou: nada de opção aleatória. Vai para o ~silencio do roteiro atual.
func _on_tempo_esgotado() -> void:
	_parar_timer()
	responses_menu.hide()
	if dialogue_resource.cues.has(CUE_SILENCIO):
		next(CUE_SILENCIO)
		return

	# Fallback seguro: o roteiro não tem ~silencio.
	push_warning("Roteiro %s não tem ~%s; aplicando a penalidade padrão." % [dialogue_resource.resource_path, CUE_SILENCIO])
	EstadoJogo.aplicar_silencio()
	var final: String = EstadoJogo.final_por_regras()
	if final != "":
		Finais.ir_para_final(final)
	else:
		# Mostra a mesma pergunta de novo (relida, para atualizar textos e condições).
		next(dialogue_line.id)


#endregion
