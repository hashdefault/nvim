return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  root_markers = { { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lock", "bun.lockb" }, "package.json", ".git" },
  init_options = {
    hostInfo = "neovim",
    -- Dá ao ts_ls o suporte a .vue; o plugin vem dentro do pacote vue-language-server do Arch
    plugins = {
      { name = "@vue/typescript-plugin", location = "/usr/lib/node_modules/@vue/language-server", languages = { "vue" } },
    },
  },
}
