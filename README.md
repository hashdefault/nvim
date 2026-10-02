# nvim

Repositório pessoal com a minha configuração mínima de [Neovim](https://neovim.io).

Não é uma distribuição nem um projeto para ser reaproveitado. É só o meu `~/.config/nvim` versionado.

## Requisitos

- Neovim 0.12+ (usa `vim.pack` e `vim.lsp.enable()` nativos)
- `rg` (ripgrep) e `fzf`
- Servidores LSP instalados no sistema (ver `lsp/`)

## Estrutura

- `init.lua`: opções, plugins e atalhos
- `lsp/`: configuração de cada servidor LSP
- `nvim-pack-lock.json`: versões fixadas dos plugins
