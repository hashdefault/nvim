return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    { ".luarc.json", ".luarc.jsonc", ".emmyrc.json" },
    { "stylua.toml", ".stylua.toml", "selene.toml", ".luacheckrc" },
    ".git",
  },
  -- Substitui o lazydev: dá a API do Neovim ao lua_ls, só em configs/plugins do Neovim
  on_init = function(client)
    local root = client.workspace_folders and client.workspace_folders[1].name
    if root and not root:match("nvim") then return end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      completion = { workspaceWord = true, callSnippet = "Both" },
      hint = { enable = true, setType = false, paramType = true, paramName = "Disable", semicolon = "Disable", arrayIndex = "Disable" },
      doc = { privateName = { "^_" } },
      type = { castNumberToInteger = true },
      diagnostics = {
        disable = { "incomplete-signature-doc", "trailing-space" },
        groupSeverity = { strong = "Warning", strict = "Warning" },
        groupFileStatus = {
          ambiguity = "Opened", await = "Opened", codestyle = "None", duplicate = "Opened",
          global = "Opened", luadoc = "Opened", redefined = "Opened", strict = "Opened",
          strong = "Opened", ["type-check"] = "Opened", unbalanced = "Opened", unused = "Opened",
        },
        unusedLocalExclude = { "_*" },
      },
      format = { enable = false },
    },
  },
}
