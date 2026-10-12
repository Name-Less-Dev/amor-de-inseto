# CLAUDE.md

Guia para o Claude trabalhar neste projeto: **Amor de Inseto**, um date sim (visual novel de romance).

## Stack

- **Godot 4.7.2 stable** — use sempre sintaxe do Godot 4 (nunca a do Godot 3). Na dúvida, confira `config/features` em `project.godot`.
- **GDScript** apenas. **Não usar C#** (não exporta para web no Godot 4).
- Renderer: **Compatibility** (`gl_compatibility`) — obrigatório para web. Não trocar para Forward+/Mobile.
- Alvo: **WEB** (itch.io ou GitHub Pages). Evite recursos que não funcionam no export HTML5 (threads, C#, acesso a arquivos do sistema, etc.).
- Janela base 1920x1080, stretch `canvas_items`, aspect `keep`.
- Executável do Godot: caminho local de cada pessoa (o desta máquina fica no `CLAUDE.local.md`, que não é versionado).
- Ambiente: Windows + PowerShell. Chamar o Godot com `& "C:\...\Godot_v4.7.2-stable_win64.exe" ...` (caminho Windows). Usar `python`, não `python3`.
- Export templates 4.7.2 instalados. Export: `& $godot --headless --path . --export-release "Web" build/web/index.html`; testar com `python -m http.server 8000 --directory build/web`.
- `build/.gdignore` (versionado) impede o editor de importar o build. O preset Web tem `exclude_filter` para os `.cs` e as cenas C# do addon (o Godot sem .NET não carrega e gera erros).

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
- Estado: autoload `EstadoJogo` (`scripts/autoload/estado_jogo.gd`). Nos roteiros, sempre acessar como `EstadoJogo.variavel`.
  - Variáveis `paciencia` (5), `afeto` (2) e `turnos` (8), com setters que emitem `paciencia_mudou`, `afeto_mudou` e `turnos_mudou`.
  - `argumentos_usados` (Dictionary): alterar só via `usar_argumento(nome)` (emite `argumento_usado`) e consultar com `ja_usou(nome)`.
  - `resetar()` volta aos valores iniciais e emite `estado_resetado`.
  - Regras de fim: constantes `PACIENCIA_LIMITE` (0), `AFETO_FINAL_BOM` (6), `AFETO_MINIMO_SOBREVIVER` (4) e `final_por_regras()`, que retorna "comido"/"sobrevive"/"" nessa ordem: paciência esgotada → comido; afeto >= 6 → sobrevive; turnos 0 → sobrevive se afeto >= 4, senão comido. O roteiro chama depois de cada argumento (`match EstadoJogo.final_por_regras()`). O final "absurdo" não é regra: fica no roteiro.
- Autoload `Finais` (`scripts/autoload/finais.gd`): dicionário `FINAIS` (id → título/frase) e `ir_para_final(id)`, que registra no save, guarda a cena de origem e abre `scenes/ui/tela_final.tscn`. Nos roteiros: `$> Finais.ir_para_final("comido")` antes do `=> END`. Final novo = entrada nova em `FINAIS`.
- Autoload `Progresso` (`scripts/autoload/progresso.gd`): ConfigFile em `user://progresso.cfg` com os finais vistos (na web fica no IndexedDB `/userfs`; persistência testada).
- Balão do projeto: `scenes/ui/balao.tscn` + `scripts/ui/balao.gd` (cópia do exemplo, registrada em `dialogue_manager/runtime/balloon_path`). Fonte 30, escolhas em coluna à esquerda, `hide_failed_responses = true`. As cenas usam `DialogueManager.show_dialogue_balloon(...)`.
  - Balão tem `ColunaEscolhas` (VBox) com `BarraTempo` (ProgressBar) acima do `ResponsesMenu`.
- Timer de escolha (em `scripts/ui/balao.gd`, região "Timer de escolha"):
  - Tempo vem de `EstadoJogo.tempo_escolha` (segundos; 0 = sem timer). Vale até o roteiro mudar; `resetar()` zera.
  - Fórmula: `EstadoJogo.tempo_pela_paciencia()` = max(`TEMPO_ESCOLHA_MINIMO` 5s, `TEMPO_ESCOLHA_BASE` 10s × paciência/inicial). É avaliada no momento do `$>`.
  - Começa só quando o menu aparece (depois da digitação). Contagem no `_process` com delta limitado (`DELTA_MAXIMO`), então congela com o jogo pausado, sem foco (`NOTIFICATION_APPLICATION_FOCUS_OUT`) e em aba de fundo, sem pular ao voltar.
  - Tempo esgotado → `next("silencio")` se `dialogue_resource.cues.has("silencio")`. Senão: fallback com `push_warning`, `EstadoJogo.aplicar_silencio()` (−`SILENCIO_CUSTO_TURNOS`, −`SILENCIO_CUSTO_PACIENCIA`), `final_por_regras()` e repete a pergunta (`next(dialogue_line.id)`).
  - Multiplicado por `Configuracoes.multiplicador_timer()` (autoload `scripts/autoload/configuracoes.gd`, `user://configuracoes.cfg`; DESLIGADO ×0, NORMAL ×1, LENTO ×`MULTIPLICADOR_LENTO` 2). UI de opções pendente.
- Pausa simples: autoload `Pausa` (`scenes/ui/pausa.tscn` + `scripts/autoload/pausa.gd`, `PROCESS_MODE_ALWAYS`). A ação `pausa` alterna `get_tree().paused` no `_input` (o balão consome o `_unhandled_input`).
- Roteiros com timer devem ter `~ silencio`. No `teste_mecanicas`, as regras de fim ficam no cue `~ checar`, usado pelas escolhas e pelo silêncio.
- Ao rodar o jogo, Progresso e Configuracoes gravam em `%APPDATA%\Godot\app_userdata\Amor de Inseto\` (`progresso.cfg`, `configuracoes.cfg`); apague depois de testes headless.
- Em testes headless: o `start` do `teste_mecanicas` chama `resetar()` (zera `tempo_escolha`); defina o tempo depois que a cena carregou. Use `--quit-after N` para o teste não travar.
- Sintaxe da v4 (diferente da v3): títulos agora se chamam *cues* (`~ nome`), e condições em opções usam `[if ... /]` (com a barra).
  - Fala: `Fêmea: texto`
  - Escolha: linhas com `- texto`, com o conteúdo do ramo indentado abaixo
  - Mutation: `$> EstadoJogo.afeto += 1`
  - Condição: `if EstadoJogo.afeto >= 3` / `elif` / `else`
  - Pulo: `=> cue`, fim: `=> END`
  - Opção de uso único: `- texto [if not EstadoJogo.ja_usou("x") /]` + `$> EstadoJogo.usar_argumento("x")`
  - Variável na fala: `{{EstadoJogo.afeto}}`
- Roteiros: `dialogue/teste_mecanicas.dialogue` (teste de mecânicas, iniciado pela `scenes/game/teste_cena.tscn`, que é para onde o Jogar leva) e `dialogue/cena_cama.dialogue` (primeiro teste, iniciado pela `scenes/game/cena_cama.tscn`; não apagar).
- Commits pelo PowerShell 5.1 quebram mensagens com aspas duplas: use o Bash com `git commit -F - <<'EOF'`.
- `--check-only` acusa "Identifier not found: DialogueManager/EstadoJogo" porque não carrega autoloads (falso positivo). Validar rodando a cena/um script headless (com `extends SceneTree`, esperar `await process_frame` antes de carregar cenas que usam autoloads).
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
