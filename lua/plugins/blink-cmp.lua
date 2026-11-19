-- blink.cmp is the autocompletion engine. It shows a menu of suggestions as you type.
-- Suggestions come from the LSP, file paths, and snippets (via LuaSnip).
-- https://github.com/saghen/blink.cmp

local gh = require('config.pack').gh

-- LuaSnip is the snippet engine — expands short triggers into full code templates.
-- Its regex support is built by config/pack.lua (skipped without `make`).
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }

---@module 'blink.cmp'
---@type blink.cmp.Config
require('blink.cmp').setup {
  keymap = {
    -- 'default' preset: <c-y> to accept, <c-e> to close, <c-n>/<c-p> to navigate
    -- Read `:help ins-completion` to understand why these defaults were chosen
    preset = 'default',
  },

  appearance = {
    -- 'mono' for Nerd Font Mono; 'normal' for regular Nerd Font (affects icon spacing)
    nerd_font_variant = 'mono',
  },

  completion = {
    accept = {
      -- Don't automatically add brackets after accepting a function completion
      auto_brackets = { enabled = false },
    },
    -- Documentation popup is shown on demand (<c-space>), not automatically
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    -- Active completion sources: LSP, file paths, and snippets
    default = { 'lsp', 'path', 'snippets' },
  },

  snippets = { preset = 'luasnip' },

  -- Use the pure-Lua fuzzy matcher (alternative: 'prefer_rust_with_warning' for a faster Rust binary)
  fuzzy = { implementation = 'lua' },

  -- Show a floating signature-help window while typing function arguments
  signature = { enabled = true },
}
