-- conform.nvim is an autoformatter that runs on save (and via <Space>f).
-- It supports many formatters and falls back to the LSP formatter if none is configured.
-- https://github.com/stevearc/conform.nvim

---@module 'lazy'
---@type LazySpec
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true, lsp_format = 'fallback' } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable format-on-save for C/C++ which lack a universal style standard
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    -- Map filetypes to the formatter(s) to use
    -- Add more entries here to format additional languages
    formatters_by_ft = {
      lua = { 'stylua' },
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
