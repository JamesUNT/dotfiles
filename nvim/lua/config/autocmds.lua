-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Remove background colors for absolute terminal transparency
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local groups = {
      "Normal", "NormalNC", "Comment", "Constant", "Special",
      "Identifier", "Statement", "PreProc", "Type", "Underlined",
      "Todo", "String", "Function", "Conditional", "Repeat", "Operator",
      "Structure", "LineNr", "NonText", "SignColumn", "CursorLine",
      "CursorLineNr", "StatusLine", "StatusLineNC", "EndOfBuffer",
      "NormalFloat", "FloatBorder", "NeoTreeNormal", "NeoTreeNormalNC"
    }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
  end,
})
