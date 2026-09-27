-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Substituir o texto selecionado visualmente em todo o arquivo
vim.keymap.set(
  "x",
  "<leader>r",
  '"zy:<C-u>%s/<C-r>z//g<Left><Left>',
  { desc = "Substituir seleção visual no arquivo" }
)
