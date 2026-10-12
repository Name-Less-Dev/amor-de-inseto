# CLAUDE.md

Guia para o Claude trabalhar neste projeto: **Amor de Inseto**, um date sim (visual novel de romance).

## Stack

- **Godot 4.7.2 stable** — use sempre sintaxe do Godot 4 (nunca a do Godot 3). Na dúvida, confira `config/features` em `project.godot`.
- **GDScript** apenas. **Não usar C#** (não exporta para web no Godot 4).
- Renderer: **Compatibility** (`gl_compatibility`) — obrigatório para web. Não trocar para Forward+/Mobile.
- Alvo: **WEB** (itch.io ou GitHub Pages). Evite recursos que não funcionam no export HTML5 (threads, C#, acesso a arquivos do sistema, etc.).
- Janela base 1280x720, stretch `canvas_items`, aspect `keep`.
- Executável do Godot: caminho local de cada pessoa (o desta máquina fica no `CLAUDE.local.md`, que não é versionado).

## Estrutura de pastas

```
assets/characters/   sprites dos personagens
assets/backgrounds/  cenários
assets/ui/           elementos de interface
assets/audio/        músicas e efeitos
addons/dialogue_manager/  addon Dialogue Manager v4.1.0 (não editar)
dialogue/            roteiros .dialogue
scenes/ui/           menus e telas de interface
scenes/game/         cenas do jogo
scripts/             scripts .gd (espelhando scenes/)
scripts/autoload/    singletons globais
build/web/           saída do export web (ignorada pelo git)
```

## Convenções de nome

- Arquivos em minúsculo, sem espaços, sem acentos, em snake_case. Ex: `personagem_expressao.png`.
- Assets de imagem em PNG com transparência.
- Cena e script com o mesmo nome quando forem par (`main_menu.tscn` / `main_menu.gd`).

## Input map

- `avancar_dialogo`: Espaço, Enter e clique esquerdo.
- `pausa`: Esc.

## Diálogos: Dialogue Manager v4.1.0

- Addon de Nathan Hoad (github.com/nathanhoad/godot_dialogue_manager), versão **4.1.0** (requer Godot 4.6+). Plugin ativo e autoload `DialogueManager` registrado.
- Não editar arquivos dentro de `addons/dialogue_manager/`. Para customizar o balão, gerar uma cópia (Projeto > Ferramentas > Dialogue > Create Balloon) fora de `addons/`.
- Roteiros em `dialogue/*.dialogue`, escritos em português, indentados com Tab.
- Estado: autoload `EstadoJogo` (`scripts/autoload/estado_jogo.gd`) com `paciencia`, `afeto`, `turnos` e `argumentos_usados` (Dictionary). Nos roteiros, sempre acessar como `EstadoJogo.variavel`.
- Sintaxe da v4 (diferente da v3): títulos agora se chamam *cues* (`~ nome`), e condições em opções usam `[if ... /]` (com a barra).
  - Fala: `Fêmea: texto`
  - Escolha: linhas com `- texto`, com o conteúdo do ramo indentado abaixo
  - Mutation: `$> EstadoJogo.afeto += 1`
  - Condição: `if EstadoJogo.afeto >= 3` / `elif` / `else`
  - Pulo: `=> cue`, fim: `=> END`
- Cena atual: `scenes/game/cena_cama.tscn` chama `DialogueManager.show_example_dialogue_balloon(...)`.
- `--check-only` acusa "Identifier not found: DialogueManager/EstadoJogo" porque não carrega autoloads (falso positivo). Validar rodando a cena/um script headless.
- Para validar um `.dialogue`, rode `--headless --import` (compila os roteiros) e percorra o roteiro com `DialogueManager.get_next_dialogue_line`.
- O Godot remove do `project.godot` valores iguais ao padrão (ex: `stretch/aspect="keep"`). Isso é normal.

## Regras de trabalho

- Mudanças pequenas e **um commit por etapa**, com mensagem clara em português.
- Não editar à mão cenas `.tscn` complexas; só cenas simples. O layout de UI é ajustado no editor.
- Addon de diálogo escolhido: **Dialogue Manager**. Não instalar outros addons sem pedir.
- Antes de qualquer decisão de design que não foi pedida, **perguntar**.
- Depois de cada etapa, validar com o Godot em linha de comando e relatar o resultado:
  - `--headless --import` (reimporta e checa o projeto)
  - `--headless --check-only --script <arquivo.gd>` (checa a sintaxe de um script)
- Arquivos `*.import` são versionados; só `.godot/` é cache.
