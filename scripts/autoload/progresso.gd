extends Node
## Progresso salvo entre partidas (finais já vistos), em user://.
## Na web, user:// fica no IndexedDB do navegador.

const CAMINHO := "user://progresso.cfg"
const SECAO_FINAIS := "finais_vistos"

var _config := ConfigFile.new()


func _ready() -> void:
	# Se o arquivo ainda não existe, começa vazio.
	_config.load(CAMINHO)


## Marca um final como visto e salva.
func registrar_final(id: String) -> void:
	_config.set_value(SECAO_FINAIS, id, true)
	_config.save(CAMINHO)


func ja_viu_final(id: String) -> bool:
	return _config.get_value(SECAO_FINAIS, id, false)


func quantidade_finais_vistos() -> int:
	if not _config.has_section(SECAO_FINAIS):
		return 0
	return _config.get_section_keys(SECAO_FINAIS).size()
