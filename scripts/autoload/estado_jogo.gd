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

## Paciência igual ou abaixo disso: ela come o macho na hora.
const PACIENCIA_LIMITE := 0
## Afeto igual ou acima disso: final bom antecipado.
const AFETO_FINAL_BOM := 6
## Quando os turnos acabam, afeto mínimo para sobreviver.
const AFETO_MINIMO_SOBREVIVER := 4

## Timer de escolha: tempo com a paciência cheia (segundos).
const TEMPO_ESCOLHA_BASE := 10.0
## Timer de escolha: o tempo nunca fica abaixo disso (segundos).
const TEMPO_ESCOLHA_MINIMO := 5.0

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

## Segundos para escolher nas próximas escolhas (0 = sem timer).
## Vale até o roteiro mudar: $> EstadoJogo.tempo_escolha = 0
var tempo_escolha: float = 0.0


## Volta tudo para os valores iniciais (nova partida).
func resetar() -> void:
	paciencia = PACIENCIA_INICIAL
	afeto = AFETO_INICIAL
	turnos = TURNOS_INICIAIS
	argumentos_usados.clear()
	tempo_escolha = 0.0
	estado_resetado.emit()


## Aplica as regras de fim de jogo. Retorna o id do final ou "" se o jogo continua.
## Ordem: paciência esgotada, afeto alto, turnos esgotados.
func final_por_regras() -> String:
	if paciencia <= PACIENCIA_LIMITE:
		return "comido"
	if afeto >= AFETO_FINAL_BOM:
		return "sobrevive"
	if turnos <= 0:
		return "sobrevive" if afeto >= AFETO_MINIMO_SOBREVIVER else "comido"
	return ""


## Tempo de escolha proporcional à paciência atual: cai junto com ela, sem passar do mínimo.
## Com os valores padrão: paciência 5 -> 10s, 4 -> 8s, 3 -> 6s, 2 ou menos -> 5s.
## Nos roteiros: $> EstadoJogo.tempo_escolha = EstadoJogo.tempo_pela_paciencia()
func tempo_pela_paciencia() -> float:
	var proporcao := float(paciencia) / PACIENCIA_INICIAL
	return maxf(TEMPO_ESCOLHA_MINIMO, TEMPO_ESCOLHA_BASE * proporcao)


## Marca um argumento como usado. Nos roteiros: $> EstadoJogo.usar_argumento("nome")
func usar_argumento(nome: String) -> void:
	argumentos_usados[nome] = true
	argumento_usado.emit(nome)


## Diz se o argumento já foi usado. Nos roteiros: [if not EstadoJogo.ja_usou("nome") /]
func ja_usou(nome: String) -> bool:
	return argumentos_usados.has(nome)
