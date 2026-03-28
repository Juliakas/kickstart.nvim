-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear search highlights when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- [[ Diagnostic configuration ]]
-- Diagnostics are messages from the LSP about errors, warnings, hints, etc.
-- See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  -- Don't update diagnostics while typing in insert mode (less distracting)
  update_in_insert = false,
  -- Show most severe diagnostics first
  severity_sort = true,
  -- Use rounded borders and only show source when there are multiple sources
  float = { border = 'rounded', source = 'if_many' },
  -- Only underline warnings and above (not hints/info)
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Virtual text: show diagnostic message at end of the line
  virtual_text = true,
  -- Virtual lines: show diagnostic underneath the line (alternative to virtual_text)
  virtual_lines = false,

  -- Automatically open the float when jumping to a diagnostic with `[d` / `]d`
  jump = { float = true },

  -- Icons in the sign column (left gutter); uses Nerd Font icons if available
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = vim.g.have_nerd_font and '󰅚' or 'E',
      [vim.diagnostic.severity.WARN] = vim.g.have_nerd_font and '󰀦' or 'W',
      [vim.diagnostic.severity.INFO] = vim.g.have_nerd_font and '󰋽' or 'I',
      [vim.diagnostic.severity.HINT] = vim.g.have_nerd_font and '󰌵' or 'H',
    },
  },
}

-- Open the quickfix list populated with all diagnostics in the current buffer
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit the built-in terminal emulator with <Esc><Esc> (the default <C-\><C-n> is hard to remember)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Navigate between windows (splits) with CTRL + hjkl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Save without triggering formatters/autocommands (useful when you want to save as-is)
vim.keymap.set('n', '<leader>w', ':noautocmd w<CR>', { desc = 'Save without formatting' })

-- Make j/k move by visual (wrapped) lines rather than actual lines
-- This makes navigating soft-wrapped text feel natural
vim.keymap.set('n', 'j', 'gj', { desc = 'Move down soft wrapped line' })
vim.keymap.set('n', 'k', 'gk', { desc = 'Move up soft wrapped line' })
