-- [[ Basic Autocommands ]]
-- Autocommands run Lua callbacks automatically when certain events happen.
-- See `:help lua-guide-autocommands`

-- Briefly highlight yanked (copied) text to give visual feedback
-- Try it: press `yap` in normal mode to yank a paragraph
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
