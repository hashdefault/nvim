-- Atalhos gerais. Os de cada assunto ficam no módulo dele (lsp, completion, format, pickers, git, wiki,
-- explorer).
local map = vim.keymap.set

-- Edição
map("n", "dw", 'vb"_d', { desc = "Apagar palavra para trás" })
map("n", "<C-a>", "gg<S-v>G", { desc = "Selecionar tudo" })
map("n", "<leader>o", "o<Esc>^Da", { desc = "Linha abaixo sem continuar comentário" })
map("n", "<leader>O", "O<Esc>^Da", { desc = "Linha acima sem continuar comentário" })
-- Só n/x/s: no insert o <C-s> fica com o padrão nativo (assinatura do LSP)
map({ "n", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar" })

-- Janelas, abas e buffers
map("n", "ss", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "sv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<C-h>", "<C-w>h", { desc = "Janela à esquerda" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela à direita" })
map("n", "<Tab>", "gt", { desc = "Próxima aba" })
map("n", "<S-Tab>", "gT", { desc = "Aba anterior" })
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "Novo arquivo" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Fechar buffer" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Sair" })
map("n", "<leader>:", "q:", { desc = "Histórico de comandos" })
