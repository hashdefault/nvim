-- Notas: vimwiki em ~/Docs/Notes (markdown)

-- Lidas pelo plugin/vimwiki.vim, que só é carregado no packadd abaixo
vim.g.vimwiki_list = { { path = "~/Docs/Notes", syntax = "markdown", ext = "md" } }
vim.g.vimwiki_ext2syntax = { [".md"] = "markdown", [".markdown"] = "markdown", [".mdown"] = "markdown" }
vim.g.vimwiki_global_ext = 0

-- vimwiki custa ~5 ms no startup: fica no lockfile, mas só carrega ao abrir .md ou pelos atalhos
vim.pack.add({ "https://github.com/vimwiki/vimwiki" }, { confirm = false, load = function() end })
local function load()
  if vim.g.loaded_vimwiki == nil then
    vim.cmd.packadd("vimwiki")
  end
end
vim.api.nvim_create_autocmd("BufReadPre", { pattern = "*.md", once = true, callback = load })

local map = vim.keymap.set
map("n", "<leader>ww", function()
  load()
  vim.cmd("VimwikiIndex")
end, { desc = "Wiki" })
map("n", "<leader>wt", function()
  load()
  vim.cmd("VimwikiTabIndex")
end, { desc = "Wiki em nova aba" })
map("n", "<leader>rd", function()
  vim.cmd("VimwikiRenameFile " .. os.date("%Y-%m-%d"))
end, { desc = "Renomear nota com a data" })
