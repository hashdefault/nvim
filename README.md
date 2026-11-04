# nvim

Repositório pessoal com a minha configuração mínima de [Neovim](https://neovim.io).

Não é uma distribuição nem um projeto para ser reaproveitado. É só o meu `~/.config/nvim` versionado.

## Requisitos

- Neovim 0.12+ (usa `vim.pack` e `vim.lsp.enable()` nativos)
- `rg` (ripgrep): usado pelo `:find`, `:Grep` e `grepprg`
- Formatadores opcionais (stylua, prettier, black, isort, shfmt): sem eles o `<leader>fm` usa o LSP
- Servidores LSP instalados no sistema (ver `lsp/`)

## Estrutura

- `init.lua`: só carrega os módulos de `lua/config/`, na ordem
- `lua/config/`: um módulo por assunto, cada um com as próprias opções, plugins (`vim.pack.add`), autocmds e atalhos
  - `options.lua`: opções gerais, cmdline e ui2
  - `colors.lua`: tema (everforest)
  - `treesitter.lua`: parsers, highlight, folds e indentação (`:TSReinstall` refaz tudo)
  - `git.lua`: gitsigns e lazygit
  - `wiki.lua`: vimwiki, carregado só ao abrir `.md`
  - `lsp.lua`: servidores, diagnósticos e atalhos do LSP
  - `completion.lua`: autocomplete nativo e borda da janela de documentação
  - `format.lua`: formatadores externos com fallback no LSP (`<leader>fm`)
  - `pickers.lua`: `:find`, `:b`, `:Recent` e `:Grep` com menu fuzzy na cmdline
  - `explorer.lua`: netrw
  - `statusline.lua`: statusline padrão + branch e LSPs
  - `keymaps.lua` e `autocmds.lua`: o que não pertence a nenhum assunto
- `lsp/`: configuração de cada servidor LSP
- `nvim-pack-lock.json`: versões fixadas dos plugins
