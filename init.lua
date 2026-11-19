-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Load options, keymaps and autocommands from separate files
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'

-- [[ Plugins via `vim.pack` ]]
-- `vim.pack` is Neovim's built-in plugin manager. See `:help vim.pack`.
-- Build hooks (make, :TSUpdate) live in lua/config/pack.lua and must load first.
--
--  :lua vim.pack.update(nil, { offline = true }) → view plugin state
--  :lua vim.pack.update()                        → update all plugins
--
-- Each plugin lives in its own file under lua/plugins/. Order matters: a file can
-- only `require` plugins that an earlier file already added.
require 'config.pack'

require 'plugins.catppuccin'
require 'plugins.mini' -- mini.icons must come before plugins that want web-devicons
require 'plugins.guess-indent'
require 'plugins.gitsigns'
require 'plugins.which-key'
require 'plugins.todo-comments'
require 'plugins.telescope'
require 'plugins.git-worktree' -- needs telescope
require 'plugins.lsp'
require 'plugins.debug' -- needs mason (set up in plugins.lsp)
require 'plugins.conform'
require 'plugins.blink-cmp'
require 'plugins.treesitter'
require 'plugins.diffview'
require 'plugins.neogit' -- needs diffview and telescope
require 'plugins.neo-tree'
require 'plugins.fugitive'

-- Optional kickstart extras, kept unedited in lua/kickstart/plugins/ (uncomment to enable):
-- require 'kickstart.plugins.autopairs'
-- require 'kickstart.plugins.debug' -- Go example; conflicts with plugins.debug, merge instead
-- require 'kickstart.plugins.indent_line'
-- require 'kickstart.plugins.lint'

-- vim: ts=2 sts=2 sw=2 et
