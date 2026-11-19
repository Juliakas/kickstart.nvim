local gh = require('config.pack').gh

vim.pack.add { gh 'sindrets/diffview.nvim' }
require('diffview').setup {}
