# Amor de Inseto

Um date sim (visual novel de romance) feito em Godot, para jogar no navegador.

## Versão do Godot

**Godot 4.7.2 stable** (versão padrão, *não* a .NET/Mono). Linguagem: **GDScript**.

Use exatamente essa versão para evitar diferenças nos arquivos `.tscn`/`project.godot`.

## Como abrir e rodar

1. Baixe o Godot 4.7.2 stable em <https://godotengine.org/download/archive/>.
2. Clone o repositório.
3. Abra o Godot, clique em **Importar** e selecione o arquivo `project.godot` desta pasta.
4. Aperte **F5** (ou o botão ▶) para rodar a cena principal (`scenes/ui/main_menu.tscn`).

### Exportar para web

1. Instale os modelos de exportação: **Editor > Gerenciar Modelos de Exportação > Baixar e Instalar**.
2. **Projeto > Exportar...**, escolha o preset **Web** e exporte. A saída vai para `build/web/index.html`.
3. Para testar localmente, sirva a pasta com um servidor HTTP (abrir o `index.html` direto não funciona):

   ```bash
   python -m http.server 8000 --directory build/web
   ```

   e acesse <http://localhost:8000>.

   Pela linha de comando (PowerShell), o export é:

   ```powershell
   & "C:\caminho\para\Godot_v4.7.2-stable_win64.exe" --headless --path . --export-release "Web" build/web/index.html
   ```

O arquivo `build/.gdignore` impede o Godot de importar os arquivos exportados. O preset Web exclui os arquivos C# do addon, que não são usados.

## Estrutura de pastas

```
assets/
  characters/   sprites dos personagens
  backgrounds/  cenários
  ui/           elementos de interface
  audio/        músicas e efeitos
addons/         addons de terceiros (Dialogue Manager)
dialogue/       roteiros .dialogue
scenes/
  ui/           menus e telas de interface
  game/         cenas do jogo
scripts/
  autoload/     scripts globais (singletons)
```

## Diálogos (Dialogue Manager)

Usamos o addon **[Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) v4.1.0** (Nathan Hoad), instalado em `addons/dialogue_manager/`. Ele já vem ativado no projeto.

- Os roteiros ficam em `dialogue/` com extensão `.dialogue`. O `dialogue/teste_mecanicas.dialogue` é o exemplo com todas as mecânicas e é o que roda ao clicar em **Jogar**.
- Para editar, use a aba **Dialogue** no topo do editor (ao lado de 2D/3D/Script).
- O estado do jogo fica no autoload `EstadoJogo` (`scripts/autoload/estado_jogo.gd`), e os roteiros leem e alteram ele direto:
  - `EstadoJogo.paciencia` (começa em 5), `EstadoJogo.afeto` (2) e `EstadoJogo.turnos` (8);
  - `EstadoJogo.usar_argumento("nome")` marca um argumento como usado, e `EstadoJogo.ja_usou("nome")` diz se ele já foi usado;
  - `EstadoJogo.resetar()` volta tudo ao início (o `teste_mecanicas` chama isso na primeira linha).
- Regras automáticas de fim (os limites ficam como constantes no topo do `estado_jogo.gd`):
  - paciência chega a 0 → **comido** na hora;
  - afeto chega a 6 → **sobrevive** antes do tempo;
  - turnos chegam a 0 → **sobrevive** se afeto >= 4, senão **comido**.
- Os finais (título e frase da tela final) ficam em `scripts/autoload/finais.gd`. Para encerrar o roteiro num final, use `$> Finais.ir_para_final("comido")`.
- Os finais já vistos ficam salvos no computador/navegador do jogador (`user://progresso.cfg`).
- O balão de diálogo do jogo é `scenes/ui/balao.tscn`. Visual (fontes, cores, posição das escolhas) se ajusta nele pelo editor.
- Indentação é com **Tab**.

### Linha de diálogo

```
Fêmea: Foi ótimo, querido. De verdade.
```

`Nome: texto`. O nome antes dos dois-pontos é quem fala. Para mostrar o valor de uma variável na fala, use `{{EstadoJogo.afeto}}`.

### Escolha

Cada opção começa com `- `. O que acontece depois dela vai indentado embaixo:

```
Macho: Espera! Me escuta.
- Elogiar os olhos dela
	$> EstadoJogo.afeto += 1
	Fêmea: Hmm. Continua.
- Dizer que ela não teria coragem
	$> EstadoJogo.paciencia -= 3
	Fêmea: Ah, é?
```

Linhas com `$>` são **mutations**: alteram variáveis do jogo.

### Condição

```
if EstadoJogo.afeto >= 3 and EstadoJogo.paciencia > 0
	=> sobrevive
else
	=> comido
```

`~ nome` marca um ponto do roteiro (cue), `=> nome` pula para ele e `=> END` encerra a conversa.

### Opção com condição (ex: uso único)

Coloque `[if ... /]` no fim da opção. Se a condição for falsa, a opção não aparece (o nosso balão esconde opções bloqueadas):

```
- Fingir que é um graveto [if not EstadoJogo.ja_usou("graveto") /]
	$> EstadoJogo.usar_argumento("graveto")
	Macho: (Eu sou um graveto.)
```

Documentação completa: <https://github.com/nathanhoad/godot_dialogue_manager/tree/main/docs>.

## Convenções de nome

- Tudo em **minúsculo**, **sem espaços** e **sem acentos**, em **snake_case**.
- Exemplos: `personagem_expressao.png`, `joaninha_feliz.png`, `fundo_jardim_noite.png`, `main_menu.tscn`.
- Cenas (`.tscn`) e scripts (`.gd`) com o mesmo nome quando forem par: `main_menu.tscn` + `main_menu.gd`.

## Formato dos assets

- Imagens em **PNG com transparência** (canal alfa).
- Resolução base do jogo: **1920x1080**. Faça fundos nesse tamanho (ou maior, na mesma proporção 16:9).

## Time

| Pessoa | Papel |
| --- | --- |
| [nome] | Roteiro, produção e setup do projeto |
| [nome] | Programação (dev) |
| [nome] | Arte |
