-- A display-only scrollbar on the right edge of each window. Besides the position it marks
-- the cursor, search matches, diagnostics, git changes (from gitsigns) and marks.
-- https://github.com/lewis6991/satellite.nvim

local gh = require('config.pack').gh

vim.pack.add { gh 'lewis6991/satellite.nvim' }

require('satellite').setup {
  -- Transparency, 0 (solid) to 100 (invisible); the default 50 blends in too much
  winblend = 20,
  -- Sidebars and panels where a scrollbar only adds noise
  excluded_filetypes = {
    'neo-tree',
    'NeogitStatus',
    'dapui_scopes',
    'dapui_breakpoints',
    'dapui_stacks',
    'dapui_watches',
    'dapui_console',
    'dap-repl',
  },
}
