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
dialogue/            roteiros / arquivos de diálogo
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

## Regras de trabalho

- Mudanças pequenas e **um commit por etapa**, com mensagem clara em português.
- Não editar à mão cenas `.tscn` complexas; só cenas simples. O layout de UI é ajustado no editor.
- **Não instalar addon de diálogo** (Dialogic ou Dialogue Manager) — decisão pendente.
- Antes de qualquer decisão de design que não foi pedida, **perguntar**.
- Depois de cada etapa, validar com o Godot em linha de comando e relatar o resultado:
  - `--headless --import` (reimporta e checa o projeto)
  - `--headless --check-only --script <arquivo.gd>` (checa a sintaxe de um script)
- Arquivos `*.import` são versionados; só `.godot/` é cache.
