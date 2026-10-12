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

- Os roteiros ficam em `dialogue/` com extensão `.dialogue` (ex: `dialogue/cena_cama.dialogue`).
- Para editar, use a aba **Dialogue** no topo do editor (ao lado de 2D/3D/Script).
- O estado do jogo (paciência, afeto, turnos, argumentos usados) fica no autoload `EstadoJogo` (`scripts/autoload/estado_jogo.gd`), e os roteiros leem e alteram ele direto.
- Indentação é com **Tab**.

### Linha de diálogo

```
Fêmea: Foi ótimo, querido. De verdade.
```

`Nome: texto`. O nome antes dos dois-pontos é quem fala.

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

`~ nome` marca um ponto do roteiro (cue), `=> nome` pula para ele e `=> END` encerra a conversa. Uma opção também pode ter condição: `- Opção secreta [if EstadoJogo.afeto > 4 /]`.

Documentação completa: <https://github.com/nathanhoad/godot_dialogue_manager/tree/main/docs>.

## Convenções de nome

- Tudo em **minúsculo**, **sem espaços** e **sem acentos**, em **snake_case**.
- Exemplos: `personagem_expressao.png`, `joaninha_feliz.png`, `fundo_jardim_noite.png`, `main_menu.tscn`.
- Cenas (`.tscn`) e scripts (`.gd`) com o mesmo nome quando forem par: `main_menu.tscn` + `main_menu.gd`.

## Formato dos assets

- Imagens em **PNG com transparência** (canal alfa).
- Resolução base do jogo: **1280x720**. Faça fundos nesse tamanho (ou maior, na mesma proporção 16:9).

## Time

| Pessoa | Papel |
| --- | --- |
| [nome] | Roteiro, produção e setup do projeto |
| [nome] | Programação (dev) |
| [nome] | Arte |
