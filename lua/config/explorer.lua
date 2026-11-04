-- Explorer: netrw nativo (substitui o oil). <C-t> abre e, dentro dele, volta pro arquivo.
vim.g.netrw_banner = 0

vim.keymap.set("n", "<C-t>", function()
  vim.cmd(vim.bo.filetype == "netrw" and "silent! Rexplore" or "Explore")
end, { desc = "Explorer (netrw)" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  desc = "O netrw toma <C-h>/<C-l>: devolve a navegação entre janelas",
  callback = function(ev)
    local map = vim.keymap.set
    map("n", "<C-h>", "<C-w>h", { buffer = ev.buf })
    map("n", "<C-l>", "<C-w>l", { buffer = ev.buf })
    map("n", "<C-v>", function()
      local explorer = vim.api.nvim_get_current_win()
      local source = vim.w.netrw_rexfile
      local buf = source and source ~= "" and vim.fn.bufnr(source) or -1
      vim.cmd.normal("v")
      if
        vim.api.nvim_get_current_win() ~= explorer
        and vim.bo.filetype ~= "netrw"
        and vim.api.nvim_buf_is_valid(buf)
      then
        vim.api.nvim_win_set_buf(explorer, buf)
      end
    end, { buffer = ev.buf, desc = "Abrir arquivo em split vertical" })
  end,
})
