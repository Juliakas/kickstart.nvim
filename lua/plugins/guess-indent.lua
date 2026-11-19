-- Automatically detects and sets the correct indentation (tabs vs spaces, width)
-- for each file you open, based on its existing content.
-- https://github.com/NMAC427/guess-indent.nvim

local gh = require('config.pack').gh

vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}
