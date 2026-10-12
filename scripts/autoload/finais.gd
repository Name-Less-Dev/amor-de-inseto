extends Node
## Lista de finais do jogo e troca para a tela final.

const TELA_FINAL := "res://scenes/ui/tela_final.tscn"

## id do final -> título e frase mostrados na tela final.
const FINAIS: Dictionary = {
	"sobrevive": {
		"titulo": "Sobreviveu!",
		"frase": "Ela decidiu que você vale mais vivo do que como lanche. Por enquanto.",
	},
	"comido": {
		"titulo": "Virou jantar",
		"frase": "Pelo menos você foi uma refeição muito nutritiva.",
	},
	"absurdo": {
		"titulo": "Virou decoração",
		"frase": "Agora você é o graveto mais charmoso da parede da sala.",
	},
}

## id do último final alcançado.
var final_atual: String = ""
## Cena de onde o final foi chamado (para o "Jogar de novo").
var cena_origem: String = ""


## Vai para a tela final. Nos roteiros: $> Finais.ir_para_final("comido")
func ir_para_final(id: String) -> void:
	assert(FINAIS.has(id), "Final desconhecido: %s" % id)
	final_atual = id
	var cena_atual := get_tree().current_scene.scene_file_path
	if cena_atual != TELA_FINAL:
		cena_origem = cena_atual
	get_tree().change_scene_to_file.call_deferred(TELA_FINAL)
