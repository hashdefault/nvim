-- Pickers (substituem o fzf-lua): a própria linha de comando, com menu fuzzy que abre a cada tecla.
-- :find (arquivos), :b (buffers), :Recent (oldfiles) e :Grep (live grep).
local M = {}

vim.opt.wildmode = "noselect:lastused,full"
vim.opt.wildoptions = "pum,fuzzy"

-- :find usa o rg (respeita .gitignore); a lista é refeita a cada vez que entra na linha de comando.
local files
function M.find_files(arg)
  files = files or vim.fn.systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" })
  return arg == "" and files or vim.fn.matchfuzzy(files, arg)
end
vim.opt.findfunc = "v:lua.require'config.pickers'.find_files"

vim.api.nvim_create_user_command("Recent", function(o)
  vim.cmd.edit(o.args)
end, {
  nargs = 1,
  complete = function(arg)
    local recent = vim.tbl_filter(function(f)
      return vim.fn.filereadable(f) == 1
    end, vim.v.oldfiles)
    recent = vim.tbl_map(function(f)
      return vim.fn.fnamemodify(f, ":~:.")
    end, recent)
    return arg == "" and recent or vim.fn.matchfuzzy(recent, arg)
  end,
})

-- Live grep: o menu mostra as linhas do rg enquanto digita. <CR> com uma linha selecionada pula
-- pra ela; sem seleção joga todos os resultados no quickfix.
local grep_pick
vim.api.nvim_create_user_command("Grep", function(o)
  if grep_pick then
    local item = vim.fn.getqflist({ lines = { grep_pick }, efm = vim.o.grepformat }).items[1]
    grep_pick = nil
    vim.cmd.buffer(item.bufnr)
    vim.bo.buflisted = true
    vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
  else
    vim.cmd("silent grep! " .. vim.fn.shellescape(o.args))
    vim.cmd("botright cwindow")
  end
end, {
  nargs = "+",
  complete = function(_, cmdline)
    local pattern = cmdline:match("^%s*Grep%s+(.*)")
    if not pattern or #pattern < 2 then
      return {}
    end
    return vim.list_slice(vim.fn.systemlist(vim.o.grepprg .. " -- " .. vim.fn.shellescape(pattern)), 1, 300)
  end,
})

local au = vim.api.nvim_create_autocmd
au("CmdlineEnter", {
  pattern = ":",
  callback = function()
    files = nil
  end,
})
au("CmdlineChanged", {
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})
au("CmdlineLeavePre", {
  pattern = ":",
  desc = "<CR> sem seleção no :find/:b/:Recent abre o primeiro item; no :Grep guarda a linha escolhida",
  callback = function()
    local info = vim.fn.cmdcomplete_info()
    if vim.tbl_isempty(info.matches or {}) then
      return
    end
    local line = vim.fn.getcmdline()
    local verb = line:match("^%s*(fin?d?)%s") or line:match("^%s*(b)%s") or line:match("^%s*(Recent)%s")
    if verb and info.selected == -1 then
      vim.fn.setcmdline(verb .. " " .. info.matches[1])
    elseif line:match("^%s*Grep%s") and info.selected ~= -1 then
      grep_pick = info.matches[info.selected + 1]
      vim.fn.setcmdline(info.cmdline_orig)
    end
  end,
})

local map = vim.keymap.set
-- Com o menu da linha de comando aberto, <Up>/<Down> continuam navegando no histórico
map("c", "<Up>", function()
  return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>"
end, { expr = true })
map("c", "<Down>", function()
  return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>"
end, { expr = true })
map("c", "<C-v>", function()
  local line = vim.fn.getcmdline()
  if vim.fn.getcmdtype() ~= ":" or not line:match("^%s*fin?d?%s") then
    return "<C-v>"
  end
  local info = vim.fn.cmdcomplete_info()
  local selected = info.selected and info.selected >= 0 and info.selected + 1 or 1
  local file = (info.matches or {})[selected]
  local command = file and "sfind " .. vim.fn.fnameescape(file) or line:gsub("^(%s*)fin?d?(%s)", "%1sfind%2", 1)
  return "<C-u>vertical " .. command .. "<CR>"
end, { expr = true, desc = "Abrir resultado do :find em split vertical" })

-- Atalhos herdados do LazyVim
map("n", "<leader><space>", ":find ", { desc = "Arquivos" })
map("n", "<leader>ff", ":find ", { desc = "Arquivos" })
map("n", "<leader>/", ":Grep ", { desc = "Grep" })
map("n", "<leader>sg", ":Grep ", { desc = "Grep" })
map("n", "<leader>,", ":b ", { desc = "Buffers" })
map("n", "<leader>fr", ":Recent ", { desc = "Recentes" })

return M
