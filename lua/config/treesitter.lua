-- Treesitter: highlight, folds e indentação. O nvim-treesitter (branch main) só instala parsers e queries;
-- quem liga tudo em cada buffer é o FileType abaixo.

-- Precisa existir antes do vim.pack.add, que dispara o PackChanged ao instalar/atualizar
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "nvim-treesitter" and d.kind == "update" then
      if not d.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } }, { confirm = false })

-- lua, markdown, vim, vimdoc, query e c já vêm com o Neovim. install() é no-op se já instalado.
-- Ele considera instalada qualquer entrada em site/queries, até link quebrado (ex.: depois de mudar o
-- $HOME). Se o highlight sumir, :TSReinstall refaz parsers e queries de tudo que está instalado.
vim.schedule(function()
  require("nvim-treesitter").install({
    "bash",
    "css",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "luadoc",
    "php",
    "phpdoc",
    "python",
    "regex",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vue",
    "yaml",
  })
end)

vim.api.nvim_create_user_command("TSReinstall", function()
  local ts = require("nvim-treesitter")
  ts.install(require("nvim-treesitter.config").get_installed(), { force = true, summary = true })
end, { desc = "Reinstala parsers e queries do treesitter" })

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    -- Sem query de highlight o start() desliga a syntax regex e o buffer fica sem cor nenhuma:
    -- nesse caso não liga o treesitter e a syntax do Vim continua.
    local lang = vim.treesitter.language.get_lang(ev.match)
    local ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
    if not (ok and query and pcall(vim.treesitter.start, ev.buf, lang)) then
      return
    end
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    if vim.treesitter.query.get(lang, "indents") then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
