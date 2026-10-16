-- Config minimalista para Neovim 0.12+. Testar com: NVIM_APPNAME=nvim-min nvim
vim.g.mapleader = " "

-- Opções -------------------------------------------------------------------
local opt = vim.opt
opt.title = true
opt.shell = "fish"
opt.mouse = ""
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 10
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.textwidth = 150
opt.list = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.path:append("**")
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undolevels = 10000
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.confirm = true
opt.updatetime = 200
opt.timeoutlen = 300
opt.virtualedit = "block"
opt.foldlevel = 99
opt.foldtext = ""
opt.pumheight = 10
opt.winborder = "rounded"
opt.pumborder = "rounded"
-- O padrão do 0.12 é "rg --vimgrep -uu", que inclui arquivos ignorados pelo git
opt.grepprg = "rg --vimgrep --smart-case"
-- Autocomplete nativo: "F" pede ao LSP (lsp_complete, na seção LSP) e soma as palavras dos buffers
opt.autocomplete = true
opt.complete = "F,.^5,w^5,b^5"
opt.completefunc = "v:lua.lsp_complete"
opt.completeopt = "menuone,noselect,popup,fuzzy"
-- Autocomplete na linha de comando (:find, :b, :Grep...). Ver "Pickers" abaixo.
opt.wildmode = "noselect:lastused,full"
opt.wildoptions = "pum,fuzzy"

-- Plugins ------------------------------------------------------------------
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "nvim-treesitter" and d.kind == "update" then
      if not d.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

-- Lidas pelo plugin/vimwiki.vim, que só é carregado depois do init.lua
vim.g.vimwiki_list = { { path = "~/Docs/Notes", syntax = "markdown", ext = "md" } }
vim.g.vimwiki_ext2syntax = { [".md"] = "markdown", [".markdown"] = "markdown", [".mdown"] = "markdown" }
vim.g.vimwiki_global_ext = 0

local gh = function(repo) return "https://github.com/" .. repo end
vim.pack.add({
  gh("sainnhe/everforest"),
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("lewis6991/gitsigns.nvim"),
}, { confirm = false })
-- vimwiki custa ~5 ms no startup: fica no lockfile, mas só carrega ao abrir .md ou pelos atalhos
vim.pack.add({ gh("vimwiki/vimwiki") }, { confirm = false, load = function() end })
local function vimwiki()
  if vim.g.loaded_vimwiki == nil then vim.cmd.packadd("vimwiki") end
end
vim.api.nvim_create_autocmd("BufReadPre", { pattern = "*.md", once = true, callback = vimwiki })

-- Lidas pelo colors/everforest.vim: precisam vir antes do :colorscheme
vim.g.everforest_background = "hard"
vim.g.everforest_transparent_background = 1
vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_float_style = "dim"
-- Tema que não define PmenuBorder deixa o padrão (link pro Pmenu): a borda sai na cor do texto.
-- Deriva do próprio tema ativo: cor da FloatBorder sobre o fundo do Pmenu.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local function get(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
    if vim.api.nvim_get_hl(0, { name = "PmenuBorder" }).link ~= "Pmenu" then return end
    vim.api.nvim_set_hl(0, "PmenuBorder", { fg = get("FloatBorder").fg, bg = get("Pmenu").bg })
  end,
})
vim.cmd.colorscheme("everforest")

-- lua, markdown, vim, vimdoc, query e c já vêm com o Neovim. install() é no-op se já instalado.
vim.schedule(function()
  require("nvim-treesitter").install({
    "bash", "css", "diff", "html", "javascript", "jsdoc", "json", "luadoc", "php", "phpdoc",
    "python", "regex", "rust", "toml", "tsx", "typescript", "vue", "yaml",
  })
end)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then return end
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    local lang = vim.treesitter.language.get_lang(ev.match)
    if lang and vim.treesitter.query.get(lang, "indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Formatação (substitui o conform) -------------------------------------------
-- O buffer passa pela stdin de cada comando, em ordem; "%f" vira o caminho do arquivo.
-- Filetype fora da lista ou sem binário instalado cai no LSP: o intelephense formata PHP e o
-- rust-analyzer chama o rustfmt com a edition do Cargo.toml.
local prettier = { { "prettier", "--stdin-filepath", "%f" } }
local shfmt = { { "shfmt", "--filename", "%f" } }
local formatters = {
  lua = { { "stylua", "--search-parent-directories", "--stdin-filepath", "%f", "-" } },
  python = { { "isort", "--stdout", "--filename", "%f", "-" }, { "black", "--quiet", "--stdin-filename", "%f", "-" } },
  sh = shfmt, bash = shfmt,
  javascript = prettier, javascriptreact = prettier, typescript = prettier, typescriptreact = prettier,
  vue = prettier, html = prettier, css = prettier, json = prettier, yaml = prettier, markdown = prettier,
}

local function format()
  local buf = vim.api.nvim_get_current_buf()
  local cmds = vim.tbl_filter(function(c) return vim.fn.executable(c[1]) == 1 end, formatters[vim.bo.filetype] or {})
  -- Seleção visual sempre vai pro LSP (os formatadores externos só formatam o arquivo inteiro)
  if #cmds == 0 or vim.fn.mode():find("^[vV\22]") then return vim.lsp.buf.format({ timeout_ms = 1000 }) end

  local file = vim.api.nvim_buf_get_name(buf)
  local old = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  local text = old
  for _, cmd in ipairs(cmds) do
    cmd = vim.tbl_map(function(a) return a == "%f" and file or a end, cmd)
    local res = vim.system(cmd, { stdin = text, cwd = file ~= "" and vim.fs.dirname(file) or nil }):wait(2000)
    if res.code ~= 0 then
      return vim.notify(cmd[1] .. ": " .. vim.trim(res.stderr or "timeout"), vim.log.levels.ERROR)
    end
    text = res.stdout
  end

  -- Aplica só os trechos que mudaram: cursor, marks e folds ficam onde estavam
  local new = vim.split(text, "\n")
  table.remove(new)
  local hunks = vim.text.diff(old, text, { result_type = "indices" }) --[[@as integer[][] ]]
  for i = #hunks, 1, -1 do
    local sa, ca, sb, cb = unpack(hunks[i])
    local start = ca == 0 and sa or sa - 1
    vim.api.nvim_buf_set_lines(buf, start, start + ca, false, vim.list_slice(new, sb, sb + cb - 1))
  end
end

-- Pickers (substituem o fzf-lua) ----------------------------------------------
-- A linha de comando abre o menu sozinha a cada tecla (wildtrigger) e filtra com fuzzy.
-- :find usa o rg (respeita .gitignore); a lista é refeita a cada vez que entra na linha de comando.
local files
function _G.find_files(arg)
  files = files or vim.fn.systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" })
  return arg == "" and files or vim.fn.matchfuzzy(files, arg)
end
opt.findfunc = "v:lua.find_files"

vim.api.nvim_create_user_command("Recent", function(o) vim.cmd.edit(o.args) end, {
  nargs = 1,
  complete = function(arg)
    local recent = vim.tbl_filter(function(f) return vim.fn.filereadable(f) == 1 end, vim.v.oldfiles)
    recent = vim.tbl_map(function(f) return vim.fn.fnamemodify(f, ":~:.") end, recent)
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
    if not pattern or #pattern < 2 then return {} end
    return vim.list_slice(vim.fn.systemlist(vim.o.grepprg .. " -- " .. vim.fn.shellescape(pattern)), 1, 300)
  end,
})

require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
    m("]h", function() gs.nav_hunk("next") end, "Próximo hunk")
    m("[h", function() gs.nav_hunk("prev") end, "Hunk anterior")
    m("<leader>ghs", gs.stage_hunk, "Stage hunk")
    m("<leader>ghr", gs.reset_hunk, "Reset hunk")
    m("<leader>ghp", gs.preview_hunk_inline, "Preview hunk")
    m("<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame da linha")
  end,
})

-- Explorer: netrw nativo (substitui o oil). <C-t> abre e, dentro dele, volta pro arquivo.
vim.g.netrw_banner = 0

-- LSP ----------------------------------------------------------------------
-- Configs em lsp/<nome>.lua. Servidor sem binário instalado é ignorado (só vai pro lsp.log).
vim.lsp.enable({
  "bashls", "html", "intelephense", "lua_ls", "marksman", "pyright", "rust_analyzer", "ts_ls", "vue_ls",
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  signs = { text = {
    [vim.diagnostic.severity.ERROR] = "✘",
    [vim.diagnostic.severity.WARN] = "▲",
    [vim.diagnostic.severity.INFO] = "●",
    [vim.diagnostic.severity.HINT] = "◆",
  } },
  float = { prefix = "" },
  -- ]d, [d, <C-j> e <C-k> abrem o float, como o antigo goto_next/goto_prev
  jump = {
    on_jump = function(_, bufnr) vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false }) end,
  },
})

-- Fonte do LSP para o 'complete'. Uma fonte função é chamada a cada tecla, até depois de espaço,
-- "(" ou "."; -3 cancela em silêncio, então o menu só abre com uma letra antes do cursor.
function _G.lsp_complete(findstart, base)
  if findstart == 1 and vim.fn.match(vim.api.nvim_get_current_line():sub(1, vim.fn.col(".") - 1), [[\k$]]) < 0 then
    return -3
  end
  return vim.lsp.omnifunc(findstart, base)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method("textDocument/completion") then return end
    -- Quem abre o menu é o 'autocomplete' (pelo lsp_complete). Sem autotrigger: os triggerCharacters do
    -- lua_ls incluem espaço, "(", "=", ",". O enable() fica para aplicar snippets e imports no <C-y>.
    vim.lsp.completion.enable(true, client.id, ev.buf)
  end,
})

-- O core cria a janela de documentação da completion sem borda (ignora 'pumborder') e sem disparar
-- eventos, e a recria a cada menu. Aplicamos a borda do menu quando ela nasce: pelo nvim__complete_set
-- (doc que o LSP resolve depois) ou no CompleteChanged (doc que já vem no item).
local function style_info_win(winid)
  if not (winid and winid > 0 and vim.api.nvim_win_is_valid(winid)) then return end
  vim.api.nvim_win_set_config(winid, { border = vim.o.pumborder })
  local hl = vim.wo[winid].winhighlight
  if not hl:find("FloatBorder") then
    vim.wo[winid].winhighlight = (hl == "" and "" or hl .. ",") .. "FloatBorder:PmenuBorder"
  end
end
local complete_set = vim.api.nvim__complete_set
vim.api.nvim__complete_set = function(...)
  local windata = complete_set(...)
  style_info_win(windata.winid)
  return windata
end
vim.api.nvim_create_autocmd("CompleteChanged", {
  callback = function()
    vim.schedule(function() style_info_win(vim.fn.complete_info({ "selected" }).preview_winid) end)
  end,
})

-- Statusline: a padrão do 0.12 (diagnósticos, progresso LSP, ruler) + branch/diff e nomes dos LSPs
function _G.stl_git()
  local head = vim.b.gitsigns_head
  if not head or head == "" then return "" end
  return " " .. head .. " " .. (vim.b.gitsigns_status or "")
end
function _G.stl_lsp()
  local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
  return #names > 0 and "[" .. table.concat(names, ",") .. "] " or ""
end
vim.o.statusline = vim.o.statusline:gsub("%%=", "%%{v:lua.stl_git()}%%=%%{v:lua.stl_lsp()}", 1)

-- Keymaps ------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<C-t>", function() vim.cmd(vim.bo.filetype == "netrw" and "silent! Rexplore" or "Explore") end, { desc = "Explorer (netrw)" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnóstico da linha" })
map("n", "<C-j>", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Próximo diagnóstico" })
map("n", "<C-k>", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Diagnóstico anterior" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Definição" })
map({ "n", "v" }, "<leader>fm", format, { desc = "Formatar arquivo/seleção" })

map("n", "dw", 'vb"_d', { desc = "Apagar palavra para trás" })
map("n", "<C-a>", "gg<S-v>G", { desc = "Selecionar tudo" })
map("n", "<leader>o", "o<Esc>^Da", { desc = "Linha abaixo sem continuar comentário" })
map("n", "<leader>O", "O<Esc>^Da", { desc = "Linha acima sem continuar comentário" })
map("n", "ss", "<cmd>split<cr>")
map("n", "sv", "<cmd>vsplit<cr>")
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "Novo arquivo" })
map("n", "<leader>rd", function() vim.cmd("VimwikiRenameFile " .. os.date("%Y-%m-%d")) end, { desc = "Renomear nota com a data" })
map("n", "<Tab>", "gt", { desc = "Próxima aba" })
map("n", "<S-Tab>", "gT", { desc = "Aba anterior" })

-- Herdados do LazyVim
map("n", "<leader>ww", function() vimwiki(); vim.cmd("VimwikiIndex") end, { desc = "Wiki" })
map("n", "<leader>wt", function() vimwiki(); vim.cmd("VimwikiTabIndex") end, { desc = "Wiki em nova aba" })
map("n", "<leader><space>", ":find ", { desc = "Arquivos" })
map("n", "<leader>ff", ":find ", { desc = "Arquivos" })
map("n", "<leader>/", ":Grep ", { desc = "Grep" })
map("n", "<leader>sg", ":Grep ", { desc = "Grep" })
map("n", "<leader>,", ":b ", { desc = "Buffers" })
map("n", "<leader>fr", ":Recent ", { desc = "Recentes" })
map("n", "<leader>:", "q:", { desc = "Histórico de comandos" })
-- Com o menu da linha de comando aberto, <Up>/<Down> continuam navegando no histórico
map("c", "<Up>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>" end, { expr = true })
map("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })
map("n", "<C-h>", "<C-w>h", { desc = "Janela à esquerda" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela à direita" })
-- Só n/x/s: no insert o <C-s> fica com o padrão nativo (assinatura do LSP)
map({ "n", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Fechar buffer" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Sair" })
map("n", "<leader>gg", function()
  vim.cmd("tab terminal lazygit")
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = 0,
    once = true,
    callback = function(ev) vim.schedule(function() pcall(vim.api.nvim_buf_delete, ev.buf, { force = true }) end) end,
  })
  vim.cmd.startinsert()
end, { desc = "Lazygit" })

-- Completion: <CR> aceita só com item selecionado; <C-y> sempre aceita
map("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<CR>"
end, { expr = true })
map("i", "<C-Space>", function() vim.lsp.completion.get() end, { desc = "Completion do LSP" })

-- Autocmds -----------------------------------------------------------------
local au = vim.api.nvim_create_autocmd
au("TextYankPost", { callback = function() vim.hl.on_yank() end })
au("CmdlineEnter", { pattern = ":", callback = function() files = nil end })
au("CmdlineChanged", { pattern = ":", callback = function() vim.fn.wildtrigger() end })
au("CmdlineLeavePre", {
  pattern = ":",
  desc = "<CR> sem seleção no :find/:b/:Recent abre o primeiro item; no :Grep guarda a linha escolhida",
  callback = function()
    local info = vim.fn.cmdcomplete_info()
    if vim.tbl_isempty(info.matches or {}) then return end
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
au("FileType", {
  pattern = "netrw",
  desc = "O netrw toma <C-h>/<C-l>: devolve a navegação entre janelas",
  callback = function(ev)
    map("n", "<C-h>", "<C-w>h", { buffer = ev.buf })
    map("n", "<C-l>", "<C-w>l", { buffer = ev.buf })
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
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd.checktime() end
  end,
})
au({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "pt_br", "en" }
  end,
})
