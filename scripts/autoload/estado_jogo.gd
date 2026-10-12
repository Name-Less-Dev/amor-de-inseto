extends Node
## Estado global da partida. Lido e alterado pelos roteiros em dialogue/.

signal paciencia_mudou(valor: int)
signal afeto_mudou(valor: int)
signal turnos_mudou(valor: int)
signal argumento_usado(nome: String)
signal estado_resetado

const PACIENCIA_INICIAL := 5
const AFETO_INICIAL := 2
const TURNOS_INICIAIS := 8

## Paciência da fêmea. Se acabar, ela perde a vontade de ouvir.
var paciencia: int = PACIENCIA_INICIAL:
	set(valor):
		paciencia = valor
		paciencia_mudou.emit(paciencia)

## Afeto da fêmea pelo macho.
var afeto: int = AFETO_INICIAL:
	set(valor):
		afeto = valor
		afeto_mudou.emit(afeto)

## Turnos de conversa que ainda restam.
var turnos: int = TURNOS_INICIAIS:
	set(valor):
		turnos = valor
		turnos_mudou.emit(turnos)

## Argumentos que o macho já usou (nome do argumento -> true).
var argumentos_usados: Dictionary = {}


## Volta tudo para os valores iniciais (nova partida).
func resetar() -> void:
	paciencia = PACIENCIA_INICIAL
	afeto = AFETO_INICIAL
	turnos = TURNOS_INICIAIS
	argumentos_usados.clear()
	estado_resetado.emit()


## Marca um argumento como usado. Nos roteiros: $> EstadoJogo.usar_argumento("nome")
func usar_argumento(nome: String) -> void:
	argumentos_usados[nome] = true
	argumento_usado.emit(nome)


## Diz se o argumento já foi usado. Nos roteiros: [if not EstadoJogo.ja_usou("nome") /]
func ja_usou(nome: String) -> bool:
	return argumentos_usados.has(nome)
