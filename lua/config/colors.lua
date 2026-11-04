-- Tema: eldritch
vim.pack.add({ "https://github.com/eldritch-theme/eldritch.nvim" }, { confirm = false })

require("eldritch").setup({
  transparent = false,
  styles = {
    comments = { italic = false },
  },
})

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

vim.cmd.colorscheme("eldritch")
