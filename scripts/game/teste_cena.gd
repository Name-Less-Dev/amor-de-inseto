extends Control

const ROTEIRO: DialogueResource = preload("res://dialogue/teste_mecanicas.dialogue")


func _ready() -> void:
	DialogueManager.show_example_dialogue_balloon(ROTEIRO, "start")
