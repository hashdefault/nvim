-- Git: sinais e hunks no buffer (gitsigns), lazygit numa aba. Branch e diff na statusline (statusline.lua).
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { confirm = false })

require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function m(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
    end
    m("]h", function()
      gs.nav_hunk("next")
    end, "Próximo hunk")
    m("[h", function()
      gs.nav_hunk("prev")
    end, "Hunk anterior")
    m("<leader>ghs", gs.stage_hunk, "Stage hunk")
    m("<leader>ghr", gs.reset_hunk, "Reset hunk")
    m("<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
    m("<leader>ghb", function()
      gs.blame_line({ full = true })
    end, "Blame da linha")
  end,
})

vim.keymap.set("n", "<leader>gg", function()
  vim.cmd("tab terminal lazygit")
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = 0,
    once = true,
    callback = function(ev)
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
      end)
    end,
  })
  vim.cmd.startinsert()
end, { desc = "Lazygit" })
