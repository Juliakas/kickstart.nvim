-- nvim-treesitter provides fast, accurate syntax highlighting and code understanding
-- by parsing your code into a syntax tree using language-specific grammars.
-- It also powers smarter indentation and can enable fold-by-syntax.
-- https://github.com/nvim-treesitter/nvim-treesitter

---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    -- Pre-install parsers for these languages on first launch
    local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
    require('nvim-treesitter').install(parsers)

    -- Enable Treesitter features for every filetype that has a parser available
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match

        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end

        -- Load the parser; returns false if not installed
        if not vim.treesitter.language.add(language) then return end

        -- Enable syntax highlighting and other Treesitter features for this buffer
        vim.treesitter.start(buf, language)

        -- Enable Treesitter-based indentation (smarter than default)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- Optional: enable Treesitter-based code folding (uncomment to activate)
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'
      end,
    })
  end,
}
