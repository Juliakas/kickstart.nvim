-- Catppuccin is the colorscheme (theme) for Neovim.
-- The 'mocha' flavour is a dark, warm theme. Other flavours: latte, frappe, macchiato.
-- https://github.com/catppuccin/nvim

---@module 'lazy'
---@type LazySpec
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  -- priority = 1000 ensures this loads before all other start plugins so colours are
  -- correct from the very first frame
  priority = 1000,
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('catppuccin').setup {
      flavour = 'mocha',
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}
