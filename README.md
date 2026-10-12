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
dialogue/       roteiros / arquivos de diálogo
scenes/
  ui/           menus e telas de interface
  game/         cenas do jogo
scripts/
  autoload/     scripts globais (singletons)
```

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
