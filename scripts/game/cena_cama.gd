extends Control

const ROTEIRO: DialogueResource = preload("res://dialogue/cena_cama.dialogue")


func _ready() -> void:
	DialogueManager.show_dialogue_balloon(ROTEIRO, "start")
