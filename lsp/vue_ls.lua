-- O vue_ls 3 delega a parte TypeScript ao ts_ls: repassamos os pedidos "tsserver/request" para ele.
return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  root_markers = { "package.json" },
  on_init = function(client)
    local function forward(err, result, ctx, retries)
      local ts = vim.lsp.get_clients({ bufnr = ctx.bufnr, name = "ts_ls" })[1]
      if not ts then
        -- o ts_ls pode ainda estar subindo
        if (retries or 0) < 10 then
          return vim.defer_fn(function() forward(err, result, ctx, (retries or 0) + 1) end, 100)
        end
        return vim.notify("vue_ls: ts_ls não encontrado", vim.log.levels.ERROR)
      end
      local id, command, payload = unpack(result[1])
      ts:exec_cmd({ title = "vue_request_forward", command = "typescript.tsserverRequest", arguments = { command, payload } },
        { bufnr = ctx.bufnr },
        function(_, r) client:notify("tsserver/response", { { id, r and r.body } }) end)
    end
    client.handlers["tsserver/request"] = function(err, result, ctx) forward(err, result, ctx) end
  end,
}
