extends CanvasLayer
## Pausa simples: a ação "pausa" (Esc) liga e desliga get_tree().paused.
## Com o jogo pausado, o diálogo e o timer das escolhas param.
## (Menu de pausa de verdade fica para depois.)


func _ready() -> void:
	# Precisa rodar mesmo com a árvore pausada, senão não despausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


# _input (e não _unhandled_input): o balão consome toda entrada não tratada.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		get_viewport().set_input_as_handled()
		alternar()


func alternar() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
