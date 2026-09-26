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
opt.wrap = false
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
-- Sem LSP: autocomplete nativo com palavras dos buffers. Com LSP: ver LspAttach abaixo.
opt.autocomplete = true
opt.complete = ".^5,w^5,b^5"
opt.completeopt = "menuone,noselect,popup,fuzzy"

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
  gh("folke/tokyonight.nvim"),
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  gh("ibhagwan/fzf-lua"),
  gh("stevearc/conform.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("stevearc/oil.nvim"),
}, { confirm = false })
-- vimwiki custa ~5 ms no startup: fica no lockfile, mas só carrega ao abrir .md ou pelos atalhos
vim.pack.add({ gh("vimwiki/vimwiki") }, { confirm = false, load = function() end })
local function vimwiki()
  if vim.g.loaded_vimwiki == nil then vim.cmd.packadd("vimwiki") end
end
vim.api.nvim_create_autocmd("BufReadPre", { pattern = "*.md", once = true, callback = vimwiki })

require("tokyonight").setup({
  style = "night",
  transparent = true,
  styles = { comments = { italic = false }, keywords = { italic = false }, functions = { italic = false } },
})
vim.cmd.colorscheme("tokyonight")

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

-- fzf-lua custa ~7 ms para carregar: só sobe no primeiro uso (atalho ou vim.ui.select)
local function fzf()
  local f = require("fzf-lua")
  if not vim.g.fzf_ready then
    f.setup({ defaults = { file_icons = false } })
    f.register_ui_select()
    vim.g.fzf_ready = true
  end
  return f
end
vim.ui.select = function(...) return fzf() and vim.ui.select(...) end

local prettier = { "prettier" }
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    -- Sem formatador externo: cai no LSP, e só o intelephense formata PHP
    php = { lsp_format = "prefer" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    javascript = prettier, javascriptreact = prettier, typescript = prettier, typescriptreact = prettier,
    vue = prettier, html = prettier, css = prettier, json = prettier, yaml = prettier, markdown = prettier,
  },
  default_format_opts = { lsp_format = "fallback", timeout_ms = 1000 },
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

-- Sem plugin de ícones a coluna "icon" não existe. <C-t> dentro do oil fecha (toggle).
require("oil").setup({ columns = {}, keymaps = { ["<C-t>"] = "actions.close" } })

-- LSP ----------------------------------------------------------------------
-- Configs em lsp/<nome>.lua. Servidor sem binário instalado é ignorado (só vai pro lsp.log).
vim.lsp.enable({
  "bashls", "html", "intelephense", "lua_ls", "marksman", "phpactor", "pyright", "rust_analyzer", "ts_ls", "vue_ls",
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

local word_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method("textDocument/completion") then return end
    -- O autotrigger só dispara nos triggerCharacters do servidor; somar letras faz abrir a cada tecla
    local provider = client.server_capabilities.completionProvider
    provider.triggerCharacters = provider.triggerCharacters or {}
    if not vim.tbl_contains(provider.triggerCharacters, "a") then
      vim.list_extend(provider.triggerCharacters, vim.split(word_chars, ""))
    end
    vim.bo[ev.buf].autocomplete = false
    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
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
map("n", "<C-t>", function() require("oil").toggle_float() end, { desc = "Explorer (oil)" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnóstico da linha" })
map("n", "<C-j>", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Próximo diagnóstico" })
map("n", "<C-k>", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Diagnóstico anterior" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Definição" })
map({ "n", "v" }, "<leader>fm", function() require("conform").format() end, { desc = "Formatar arquivo/seleção" })

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
map("n", "<leader><space>", function() fzf().files() end, { desc = "Arquivos" })
map("n", "<leader>ff", function() fzf().files() end, { desc = "Arquivos" })
map("n", "<leader>/", function() fzf().live_grep() end, { desc = "Grep" })
map("n", "<leader>sg", function() fzf().live_grep() end, { desc = "Grep" })
map("n", "<leader>,", function() fzf().buffers() end, { desc = "Buffers" })
map("n", "<leader>fr", function() fzf().oldfiles() end, { desc = "Recentes" })
map("n", "<leader>:", function() fzf().command_history() end, { desc = "Histórico de comandos" })
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
