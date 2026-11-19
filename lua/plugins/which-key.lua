-- which-key shows a popup with available keybindings when you pause mid-sequence.
-- For example, press <Space> and wait — it lists all <leader> mappings.
-- https://github.com/folke/which-key.nvim

local gh = require('config.pack').gh

vim.pack.add { gh 'folke/which-key.nvim' }

---@diagnostic disable-next-line: missing-fields
require('which-key').setup {
  -- How long (ms) to wait after a keypress before the popup appears
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },

  -- Label key groups so which-key shows a friendly name instead of raw keys
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>g', group = '[G]it Worktree' },
    { '<leader>d', group = '[D]ebug' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
