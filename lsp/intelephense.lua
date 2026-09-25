-- Só formatação. Completion, diagnóstico, definição etc. ficam com o phpactor, sem duplicar.
local keep = { documentFormattingProvider = true, documentRangeFormattingProvider = true, textDocumentSync = true }

return {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_markers = { "composer.json", ".git" },
  settings = { intelephense = { diagnostics = { enable = false } } },
  on_init = function(client)
    for cap in pairs(client.server_capabilities) do
      if not keep[cap] then client.server_capabilities[cap] = nil end
    end
  end,
}
