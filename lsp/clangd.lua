-- C e C++. Em projeto com build próprio o clangd lê o compile_commands.json
-- (cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ou bear -- make); arquivo solto usa o compile_flags.txt, se houver.
return {
  -- --log=error: o clangd loga tudo no stderr, que o Neovim grava no lsp.log como ERROR
  cmd = { "clangd", "--background-index", "--header-insertion=never", "--log=error" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac" },
    ".git",
  },
  capabilities = { textDocument = { completion = { editsNearCursor = true } } },
}
