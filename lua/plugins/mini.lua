-- mini.nvim is a collection of small, independent Neovim plugins in one repo.
-- Only the modules configured below are active.
-- https://github.com/nvim-mini/mini.nvim

local gh = require('config.pack').gh

vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- mini.icons: file and filetype icons. Also stands in for nvim-web-devicons, which
-- telescope and neo-tree look for, so that plugin is no longer installed.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

-- mini.ai: Extends the built-in `a`/`i` text objects with more targets.
-- Examples:
--   va)  → visually select Around )paren
--   yiiq → yank Inside Next Quote
--   ci'  → change Inside 'quote'
require('mini.ai').setup {
  -- `an`/`in` are Neovim 0.12's built-in incremental selection in visual mode
  -- (see `:help treesitter-incremental-selection`), so "next" moves to `aa`/`ii`
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

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

-- Override the cursor position section to show LINE:COLUMN  TOTAL  PERCENTAGE
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v T:%L %p%%' end
