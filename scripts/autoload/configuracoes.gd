extends Node
## Configurações do jogador, salvas em user:// (na web, no IndexedDB do navegador).
## A tela de opções ainda não existe; por enquanto só a variável e o save.

enum ModoTimer { DESLIGADO, NORMAL, LENTO }

const CAMINHO := "user://configuracoes.cfg"
const SECAO := "acessibilidade"
## No modo lento, o tempo das escolhas é multiplicado por isso.
const MULTIPLICADOR_LENTO := 2.0

## Timer das escolhas: desligado, normal ou lento. Salva ao mudar.
var modo_timer: ModoTimer = ModoTimer.NORMAL:
	set(valor):
		modo_timer = valor
		_salvar()


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(CAMINHO) == OK:
		modo_timer = config.get_value(SECAO, "modo_timer", ModoTimer.NORMAL)


## Multiplicador aplicado ao tempo das escolhas (0 = timer desligado).
func multiplicador_timer() -> float:
	match modo_timer:
		ModoTimer.DESLIGADO:
			return 0.0
		ModoTimer.LENTO:
			return MULTIPLICADOR_LENTO
		_:
			return 1.0


func _salvar() -> void:
	var config := ConfigFile.new()
	config.set_value(SECAO, "modo_timer", modo_timer)
	config.save(CAMINHO)
