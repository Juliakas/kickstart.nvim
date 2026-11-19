-- Catppuccin is the colorscheme (theme) for Neovim.
-- The 'mocha' flavour is a dark, warm theme. Other flavours: latte, frappe, macchiato.
-- https://github.com/catppuccin/nvim

local gh = require('config.pack').gh

-- Loaded first in init.lua so colours are correct from the very first frame
vim.pack.add { { src = gh 'catppuccin/nvim', name = 'catppuccin' } }

---@diagnostic disable-next-line: missing-fields
require('catppuccin').setup {
  flavour = 'mocha',
}
vim.cmd.colorscheme 'catppuccin'
