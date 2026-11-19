-- Highlights TODO, FIXME, NOTE, HACK, WARN, PERF, and TEST comments
-- with distinct colours so they stand out in code.
-- https://github.com/folke/todo-comments.nvim

local gh = require('config.pack').gh

vim.pack.add { gh 'nvim-lua/plenary.nvim', gh 'folke/todo-comments.nvim' }

---@diagnostic disable-next-line: missing-fields
require('todo-comments').setup { signs = false } -- Don't show signs in the gutter, only inline highlight
