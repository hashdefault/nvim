return {
  cmd = { "phpactor", "language-server" },
  filetypes = { "php" },
  root_markers = { "composer.json", ".phpactor.json", ".phpactor.yml", ".git" },
  -- O phpactor precisa de um projeto; arquivo solto não anexa
  workspace_required = true,
  -- A completion fica com o intelephense para evitar sugestões duplicadas.
  on_init = function(client)
    client.server_capabilities.completionProvider = nil
  end,
}
