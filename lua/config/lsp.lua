-- LSP: configs em lsp/<nome>.lua. Servidor sem binário instalado é ignorado (só vai pro lsp.log).
-- A completion do LSP fica em completion.lua e a formatação em format.lua.
vim.lsp.enable({
  "bashls",
  "html",
  "intelephense",
  "lua_ls",
  "marksman",
  "pyright",
  "rust_analyzer",
  "ts_ls",
  "vue_ls",
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "◆",
    },
  },
  float = { prefix = "" },
  -- ]d, [d, <C-j> e <C-k> abrem o float, como o antigo goto_next/goto_prev
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
})

local map = vim.keymap.set
map("n", "gd", vim.lsp.buf.definition, { desc = "Definição" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnóstico da linha" })
map("n", "<C-j>", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Próximo diagnóstico" })
map("n", "<C-k>", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Diagnóstico anterior" })
