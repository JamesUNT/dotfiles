return {
  -- 1. Install your preferred monochrome scheme
  {
    "wnkz/monoglow.nvim",
    lazy = false,
    priority = 1000,
    opts = {}
  },

  -- 2. Configure LazyVim to load it on startup
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monoglow",
    },
  }
}
