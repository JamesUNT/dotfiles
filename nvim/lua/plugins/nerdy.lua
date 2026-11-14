return {
  '2kabhishek/nerdy.nvim',
  dependencies = {
    'stevearc/dressing.nvim',        -- Optional: improves the UI of vim.ui.select
    'nvim-telescope/telescope.nvim', -- Optional: enables Telescope integration
  },
  cmd = 'Nerdy',
  keys = {
    -- Press <leader>in in Normal mode to open the picker
    { '<leader>in', '<cmd>Nerdy<cr>',         desc = 'Browse Nerd Icons' },
    -- Press <leader>iN to browse recently used icons
    { '<leader>iN', '<cmd>Nerdy recents<cr>', desc = 'Recent Nerd Icons' },
  },
  opts = {
    max_recents = 30,          -- Number of recent icons to remember
    add_default_keybindings = true,
    copy_to_clipboard = false, -- Set to true if you also want it copied to system clipboard
  },
}
