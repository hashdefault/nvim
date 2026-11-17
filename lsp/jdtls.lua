-- Java (AUR: jdtls). Cada projeto precisa do próprio diretório -data, então o cmd é montado na hora a
-- partir do root_dir. Sem o binário, o cmd fica em tabela para o vim.lsp ignorar o servidor como os outros.
local cache = vim.fn.stdpath("cache") .. "/jdtls"

return {
  cmd = vim.fn.executable("jdtls") == 0 and { "jdtls" } or function(dispatchers, config)
    local root = config.root_dir or vim.fn.getcwd()
    return vim.lsp.rpc.start({
      "jdtls",
      "-configuration",
      cache .. "/config",
      "-data",
      cache .. "/workspace/" .. (root:gsub("/", "%%")),
    }, dispatchers, { cwd = config.cmd_cwd, env = config.cmd_env, detached = config.detached })
  end,
  filetypes = { "java" },
  root_markers = {
    -- Raiz de projeto multi-módulo primeiro, para os submódulos não subirem clientes extras
    { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
    { "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" },
    ".git",
  },
}
