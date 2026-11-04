-- Statusline: a padrão do 0.12 (diagnósticos, progresso LSP, ruler) + branch/diff e nomes dos LSPs
local M = {}

function M.git()
  local head = vim.b.gitsigns_head
  if not head or head == "" then
    return ""
  end
  return " " .. head .. " " .. (vim.b.gitsigns_status or "")
end

function M.lsp()
  local names = vim.tbl_map(function(c)
    return c.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  return #names > 0 and "[" .. table.concat(names, ",") .. "] " or ""
end

local mod = "v:lua.require'config.statusline'"
vim.o.statusline = vim.o.statusline:gsub("%%=", "%%{" .. mod .. ".git()}%%=%%{" .. mod .. ".lsp()}", 1)

return M
