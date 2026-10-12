extends Control

const CENA_MENU := "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	var final: Dictionary = Finais.FINAIS.get(Finais.final_atual, {})
	%Titulo.text = final.get("titulo", "")
	%Frase.text = final.get("frase", "")
	%BotaoJogarDeNovo.pressed.connect(_on_botao_jogar_de_novo_pressed)
	%BotaoMenu.pressed.connect(_on_botao_menu_pressed)
	%BotaoJogarDeNovo.grab_focus()


func _on_botao_jogar_de_novo_pressed() -> void:
	EstadoJogo.resetar()
	get_tree().change_scene_to_file(Finais.cena_origem)


func _on_botao_menu_pressed() -> void:
	get_tree().change_scene_to_file(CENA_MENU)
