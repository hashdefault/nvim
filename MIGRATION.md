# Migração: LazyVim → nvim-min

Testar: `NVIM_APPNAME=nvim-min nvim`. A config antiga em `~/.config/nvim` não foi alterada.

## Números

|                          | Antes (LazyVim)   | Depois (nvim-min)       |
|--------------------------|-------------------|-------------------------|
| Linhas de Lua            | 1059 (+ LazyVim)  | 379                     |
| Plugins                  | 42                | 7                       |
| Startup vazio (mediana)  | 18 ms             | 23,5 ms                 |
| Startup abrindo `.php`   | 104 ms            | 98 ms                   |

Com `.php`, o gasto agora é quase todo a compilação da query treesitter do PHP (~56 ms, uma vez por sessão).
Antes era syntax regex (~20 ms por buffer PHP), sem parser treesitter.

## O que mudou

- **Gerenciador**: lazy.nvim → `vim.pack`. Versione o `nvim-pack-lock.json`.
  Atualizar: `:lua vim.pack.update()` (confirma com `:w`). Remover: `:lua vim.pack.del({ "nome" })`.
- **LSP**: nvim-lspconfig + mason → `vim.lsp.enable()` + `lsp/<servidor>.lua`, binários do pacman.
  PHP agora é **phpactor**, que só anexa dentro de um projeto (`composer.json`, `.phpactor.json` ou `.git`).
- **Completion**: blink.cmp → nativo. Em buffers com LSP ela abre a cada tecla (`vim.lsp.completion`);
  nos outros, completa palavras dos buffers (`'autocomplete'`).
  `<C-n>`/`<C-p>` navegam, `<CR>` aceita o item selecionado, `<C-y>` sempre aceita, `<C-Space>` força o LSP.
  Snippets do LSP expandem com `vim.snippet` e `<Tab>`/`<S-Tab>` pulam os campos.
- **Explorer**: neo-tree → oil.nvim. `<C-t>` abre/fecha em float; `g?` lista os atalhos do oil.
  O `<C-t>` padrão do oil ("abrir em nova aba") foi trocado por "fechar".
- **Statusline/tabline**: lualine/bufferline → nativas. A statusline padrão do 0.12 mostra diagnósticos e progresso do LSP;
  foram acrescentados o branch/diff (gitsigns) e os nomes dos LSPs. `<Tab>`/`<S-Tab>` = `gt`/`gT`.
- **Diagnóstico**: `<C-j>`/`<C-k>` e também `]d`/`[d` pulam e abrem o float. `<leader>e` voltou a abrir o float
  (antes o Neo-tree tomava o atalho).
- **Busca**: fzf-lua, que carrega no primeiro uso. `<leader><space>`/`<leader>ff` arquivos, `<leader>/`/`<leader>sg` grep,
  `<leader>,` buffers, `<leader>fr` recentes, `<leader>:` histórico. Também vira o `vim.ui.select` (menu do `gra`).
- **Nativos**: `gc`/`gcc` comentar, `K` hover, `grn` rename, `gra` code action, `grr` referências,
  `gri` implementação, `grt` type definition, `gO` símbolos, `<C-s>` (insert) assinatura, `gd` definição,
  `v_an`/`v_in` seleção incremental, `:Undotree`, `:restart` (reabre com a sessão).
- **Herdados do LazyVim** (agora explícitos): `<C-h>`/`<C-l>` janelas, `<C-s>` salvar (normal/visual),
  `<leader>bd`, `<leader>qq`, `<leader>gg` (lazygit em aba), `]h`/`[h` e `<leader>gh{s,r,p,b}` do gitsigns.
- `<leader>rd` agora usa a data do momento em que você aperta (antes ficava congelada na do startup).
- Dicionário `pt` copiado para `~/.local/share/nvim-min/site/spell/`.

## O que foi removido

LazyVim, lazy.nvim, mason, mason-lspconfig, nvim-lspconfig, lazydev, blink.cmp/compat, friendly-snippets,
telescope, plenary, neo-tree, nui, noice, snacks, which-key, lualine, bufferline, alpha, trouble, flash,
grug-far, todo-comments, persistence, nvim-lint, ts-comments, nvim-ts-autotag, nvim-treesitter-textobjects,
mini.{ai,pairs,icons,animate,hipatterns}, nvim-web-devicons, smear-cursor, catppuccin.

Também saíram:
- `<leader>ll`, que já estava quebrado. O phpactor gera getters/setters via `gra`.
- Os snippets PHP com LuaSnip, que nunca carregavam.
- Autopairs.
- Fechamento automático de tags HTML.
- As ~150 outras teclas `<leader>` do LazyVim.
- `jsonls`, `cssls` e `yamlls`. Para voltar, basta um `lsp/<nome>.lua` e o nome no `vim.lsp.enable`.

## Pendências

Estes pacotes ainda faltam; sem eles, o LSP/formatador correspondente fica inativo (sem erro na tela):

```
sudo pacman -S typescript-language-server vue-language-server vscode-html-languageserver \
  pyright bash-language-server marksman prettier shfmt shellcheck python-isort
```

- **Formatação PHP**: fica com o intelephense (`paru -S nodejs-intelephense`, AUR). Ele sobe junto com o phpactor,
  mas com todas as capacidades cortadas menos formatação (`lsp/intelephense.lua`), e o diagnóstico dele fica desligado.
  Ele ainda indexa o projeto em segundo plano; se pesar, troque por `php-cs-fixer` no conform.
- **lua_ls com duplicatas**: `callSnippet = "Both"` (herdado) mostra cada função duas vezes no menu.
  `"Replace"` deixa só a versão snippet.
- **Versionar**: `~/.config/nvim-min` ainda não é um repositório git.

## Como voltar atrás

Nada da config antiga foi tocado. Basta abrir `nvim` sem `NVIM_APPNAME`.
Para apagar a config nova por completo:

```
rm -rf ~/.config/nvim-min ~/.local/share/nvim-min ~/.local/state/nvim-min ~/.cache/nvim-min
```

Para adotar a nova como padrão, depois de testar: mova `~/.config/nvim` para um backup e renomeie
`~/.config/nvim-min` para `~/.config/nvim`. Os plugins são reinstalados pelo lockfile e os parsers pelo
`install()` no primeiro start.
