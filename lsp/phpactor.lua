return {
  cmd = { "phpactor", "language-server" },
  filetypes = { "php" },
  root_markers = { "composer.json", ".phpactor.json", ".phpactor.yml", ".git" },
  -- O phpactor precisa de um projeto; arquivo solto não anexa
  workspace_required = true,
}
