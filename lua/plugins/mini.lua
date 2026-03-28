-- mini.nvim is a collection of small, independent Neovim plugins in one repo.
-- Only the modules configured below are active.
-- https://github.com/nvim-mini/mini.nvim

---@module 'lazy'
---@type LazySpec
return {
  'nvim-mini/mini.nvim',
  config = function()
    -- mini.ai: Extends the built-in `a`/`i` text objects with more targets.
    -- Examples:
    --   va)  → visually select Around )paren
    --   yinq → yank Inside Next Quote
    --   ci'  → change Inside 'quote'
    require('mini.ai').setup { n_lines = 500 }

    -- mini.surround: Add, delete, or replace surrounding pairs (brackets, quotes, tags).
    -- Examples:
    --   saiw)  → Surround Add Inner Word with )
    --   sd'    → Surround Delete ' quotes
    --   sr)'   → Surround Replace ) with '
    require('mini.surround').setup()

    -- mini.statusline: A minimal statusline shown at the bottom of the screen.
    -- Displays mode, file name, git branch (if gitsigns is active), diagnostics, etc.
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- Override the cursor position section to show LINE:COLUMN
    statusline.section_location = function() return '%2l:%-2v' end
  end,
}
