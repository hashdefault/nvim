-- Tema: everforest
vim.pack.add({ "https://github.com/sainnhe/everforest" }, { confirm = false })

-- Lidas pelo colors/everforest.vim: precisam vir antes do :colorscheme
vim.g.everforest_background = "hard"
vim.g.everforest_transparent_background = 0
vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_float_style = "bright"

-- Tema que não define PmenuBorder deixa o padrão (link pro Pmenu): a borda sai na cor do texto.
-- Deriva do próprio tema ativo: cor da FloatBorder sobre o fundo do Pmenu.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local function get(name)
      return vim.api.nvim_get_hl(0, { name = name, link = false })
    end
    if vim.api.nvim_get_hl(0, { name = "PmenuBorder" }).link ~= "Pmenu" then
      return
    end
    vim.api.nvim_set_hl(0, "PmenuBorder", { fg = get("FloatBorder").fg, bg = get("Pmenu").bg })
  end,
})

vim.cmd.colorscheme("everforest")
