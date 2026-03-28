-- Highlights TODO, FIXME, NOTE, HACK, WARN, PERF, and TEST comments
-- with distinct colours so they stand out in code.
-- https://github.com/folke/todo-comments.nvim

---@module 'lazy'
---@type LazySpec
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ---@module 'todo-comments'
  ---@type TodoOptions
  ---@diagnostic disable-next-line: missing-fields
  opts = { signs = false }, -- Don't show signs in the gutter, only inline highlight
}
