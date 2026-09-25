return {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  -- Cargo.lock primeiro: ele só existe na raiz do workspace, então membros não sobem clientes extras
  root_markers = { "Cargo.lock", "rust-project.json", "Cargo.toml", ".git" },
}
