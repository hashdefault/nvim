-- Formatação (substitui o conform)
-- O buffer passa pela stdin de cada comando, em ordem; "%f" vira o caminho do arquivo.
-- Filetype fora da lista ou sem binário instalado cai no LSP: o intelephense formata PHP e o
-- rust-analyzer chama o rustfmt com a edition do Cargo.toml.
local prettier = { { "prettier", "--stdin-filepath", "%f" } }
local shfmt = { { "shfmt", "--filename", "%f" } }
local formatters = {
  lua = { { "stylua", "--search-parent-directories", "--stdin-filepath", "%f", "-" } },
  python = { { "isort", "--stdout", "--filename", "%f", "-" }, { "black", "--quiet", "--stdin-filename", "%f", "-" } },
  sh = shfmt,
  bash = shfmt,
  javascript = prettier,
  javascriptreact = prettier,
  typescript = prettier,
  typescriptreact = prettier,
  vue = prettier,
  html = prettier,
  css = prettier,
  json = prettier,
  yaml = prettier,
  markdown = prettier,
}

local function format()
  local buf = vim.api.nvim_get_current_buf()
  local cmds = vim.tbl_filter(function(c)
    return vim.fn.executable(c[1]) == 1
  end, formatters[vim.bo.filetype] or {})
  -- Seleção visual sempre vai pro LSP (os formatadores externos só formatam o arquivo inteiro)
  if #cmds == 0 or vim.fn.mode():find("^[vV\22]") then
    return vim.lsp.buf.format({ timeout_ms = 1000 })
  end

  local file = vim.api.nvim_buf_get_name(buf)
  local old = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  local text = old
  for _, cmd in ipairs(cmds) do
    cmd = vim.tbl_map(function(a)
      return a == "%f" and file or a
    end, cmd)
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

vim.keymap.set({ "n", "v" }, "<leader>fm", format, { desc = "Formatar arquivo/seleção" })
