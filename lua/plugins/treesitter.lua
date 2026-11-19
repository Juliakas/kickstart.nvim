-- nvim-treesitter provides fast, accurate syntax highlighting and code understanding
-- by parsing your code into a syntax tree using language-specific grammars.
-- It also powers smarter indentation and can enable fold-by-syntax.
-- https://github.com/nvim-treesitter/nvim-treesitter

local gh = require('config.pack').gh

-- :TSUpdate runs after install/update via config/pack.lua
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

-- Pre-install parsers for these languages on first launch
local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- The buffer may be gone by the time an async parser install finishes
  if not vim.api.nvim_buf_is_valid(buf) then return end

  -- Load the parser; returns false if not installed
  if not vim.treesitter.language.add(language) then return end

  -- Enable syntax highlighting and other Treesitter features for this buffer
  vim.treesitter.start(buf, language)

  -- Optional: enable Treesitter-based code folding (uncomment to activate)
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  -- Treesitter-based indentation, only where the language has an indent query;
  -- otherwise keep Vim's built-in indentexpr
  if vim.treesitter.query.get(language, 'indents') ~= nil then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- Auto-install a missing parser, then attach once it is ready
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- The parser may exist without coming from nvim-treesitter
      treesitter_try_attach(buf, language)
    end
  end,
})
