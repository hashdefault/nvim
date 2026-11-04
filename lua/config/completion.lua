-- Completion nativa (sem blink/cmp): o 'autocomplete' abre o menu a cada tecla.
-- "F" pede ao LSP (M.lsp, abaixo) e soma as palavras dos buffers.
local M = {}

local opt = vim.opt
opt.autocomplete = true
opt.complete = "F,.^5,w^5,b^5"
opt.completefunc = "v:lua.require'config.completion'.lsp"
opt.completeopt = "menuone,noselect,popup,fuzzy"

-- Fonte do LSP para o 'complete'. Uma fonte função é chamada a cada tecla, até depois de espaço,
-- "(" ou "."; -3 cancela em silêncio, então o menu só abre com uma letra antes do cursor.
function M.lsp(findstart, base)
  if findstart == 1 and vim.fn.match(vim.api.nvim_get_current_line():sub(1, vim.fn.col(".") - 1), [[\k$]]) < 0 then
    return -3
  end
  return vim.lsp.omnifunc(findstart, base)
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method("textDocument/completion") then
      return
    end
    -- Quem abre o menu é o 'autocomplete' (pelo M.lsp). Sem autotrigger: os triggerCharacters do
    -- lua_ls incluem espaço, "(", "=", ",". O enable() fica para aplicar snippets e imports no <C-y>.
    vim.lsp.completion.enable(true, client.id, ev.buf)
  end,
})

-- O core cria a janela de documentação da completion sem borda (ignora 'pumborder') e sem disparar
-- eventos, e a recria a cada menu. Aplicamos a borda do menu quando ela nasce: pelo nvim__complete_set
-- (doc que o LSP resolve depois) ou no CompleteChanged (doc que já vem no item).
local function style_info_win(winid)
  if not (winid and winid > 0 and vim.api.nvim_win_is_valid(winid)) then
    return
  end
  vim.api.nvim_win_set_config(winid, { border = vim.o.pumborder })
  local menu = vim.fn.pum_getpos()
  local config = vim.api.nvim_win_get_config(winid)
  local col = vim.api.nvim_win_get_position(winid)[2]
  if menu.col and config.relative == "editor" and col >= menu.col then
    -- A borda ocupa uma coluna de cada lado; deixa mais uma livre entre as janelas.
    local right = menu.col + menu.width + (menu.scrollbar and 1 or 0) + 2
    local width = math.min(config.width, vim.o.columns - right - 3)
    if width > 0 then
      vim.api.nvim_win_set_config(winid, { relative = "editor", row = config.row, col = right, width = width })
    end
  end
  local hl = vim.wo[winid].winhighlight
  if not hl:find("FloatBorder") then
    vim.wo[winid].winhighlight = (hl == "" and "" or hl .. ",") .. "FloatBorder:PmenuBorder"
  end
end
local complete_set = vim.api.nvim__complete_set
vim.api.nvim__complete_set = function(...)
  local windata = complete_set(...)
  style_info_win(windata.winid)
  return windata
end
vim.api.nvim_create_autocmd("CompleteChanged", {
  callback = function()
    vim.schedule(function()
      style_info_win(vim.fn.complete_info({ "selected" }).preview_winid)
    end)
  end,
})

-- <CR> aceita só com item selecionado; <C-y> sempre aceita
vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<CR>"
end, { expr = true })
vim.keymap.set("i", "<C-Space>", function()
  vim.lsp.completion.get()
end, { desc = "Completion do LSP" })

return M
