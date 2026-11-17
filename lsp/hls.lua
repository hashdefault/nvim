-- Haskell. O pacote do Arch instala só o haskell-language-server (casado com o ghc do sistema);
-- o ghcup instala o wrapper, que escolhe o binário pela versão do ghc do projeto.
local exe = vim.fn.executable("haskell-language-server-wrapper") == 1 and "haskell-language-server-wrapper"
  or "haskell-language-server"

return {
  cmd = { exe, "--lsp" },
  filetypes = { "haskell", "lhaskell" },
  -- root_markers não aceita glob, e um projeto cabal simples só tem o <nome>.cabal
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(bufnr, {
      { "hie.yaml", "stack.yaml", "cabal.project" },
      function(name)
        return name:match("%.cabal$") ~= nil or name == "package.yaml"
      end,
      ".git",
    }) or vim.fs.dirname(file))
  end,
  settings = {
    haskell = { formattingProvider = "ormolu", cabalFormattingProvider = "cabal-fmt" },
  },
}
