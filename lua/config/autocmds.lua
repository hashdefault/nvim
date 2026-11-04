-- Autocmds gerais. Os de cada assunto ficam no módulo dele.
local au = vim.api.nvim_create_autocmd

au("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

au("BufReadPost", {
  desc = "Volta para a última posição do cursor",
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

au({ "FocusGained", "TermLeave" }, {
  desc = "Recarrega arquivos alterados fora do Neovim",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd.checktime()
    end
  end,
})

au({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "pt_br", "en" }
  end,
})
