extends Node
## Estado global da partida. Lido e alterado pelos roteiros em dialogue/.

## Paciência da fêmea. Se acabar, ela perde a vontade de ouvir.
var paciencia: int = 5
## Afeto da fêmea pelo macho.
var afeto: int = 2
## Turnos de conversa que ainda restam.
var turnos: int = 8
## Argumentos que o macho já usou (nome do argumento -> true).
var argumentos_usados: Dictionary = {}
