extends Control

const CENA_JOGO := "res://scenes/game/cena_cama.tscn"


func _ready() -> void:
	%BotaoJogar.pressed.connect(_on_botao_jogar_pressed)
	%BotaoSair.pressed.connect(_on_botao_sair_pressed)
	%BotaoJogar.grab_focus()


func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file(CENA_JOGO)


func _on_botao_sair_pressed() -> void:
	# Na web, quit() não fecha a aba do navegador.
	get_tree().quit()
