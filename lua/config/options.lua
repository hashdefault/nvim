-- Opções gerais. As da completion ficam em completion.lua; as da linha de comando (wildmenu, findfunc)
-- em pickers.lua.
local opt = vim.opt

opt.title = true
opt.shell = "fish"
opt.mouse = ""
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undolevels = 10000
opt.confirm = true
opt.updatetime = 200
opt.timeoutlen = 300

-- Interface
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.scrolloff = 10
opt.list = true
opt.pumheight = 10
opt.winborder = "bold"
opt.pumborder = "bold"
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.foldlevel = 99
opt.foldtext = ""

-- Texto e indentação
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.textwidth = 150
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.shiftround = true
opt.smartindent = true
opt.virtualedit = "block"

-- Busca
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.path:append("**")
-- O padrão do 0.12 é "rg --vimgrep -uu", que inclui arquivos ignorados pelo git
opt.grepprg = "rg --vimgrep --smart-case"

-- Cmdline mínima: com cmdheight=0 a linha de baixo é a statusline global e a cmdline só aparece enquanto
-- se digita. Showmode/ruler/showcmd vivem na cmdline, então ficam ocultos fora dela.
opt.cmdheight = 0
opt.laststatus = 3
-- ui2 (experimental no 0.12): substitui o hit-enter por mensagens em janela flutuante efêmera.
-- Mensagens comuns vão pra janela "msg" (somem em 4 s); saídas longas (:ls, :set, :!cmd) vão pro pager;
-- "g<" reabre as últimas mensagens e "q" fecha o pager. Prompts (confirm) usam o dialog sozinho.
require("vim._core.ui2").enable({
  msg = {
    target = "msg",
    targets = { list_cmd = "pager", shell_out = "pager", shell_err = "pager" },
    msg = { timeout = 4000 },
  },
})
