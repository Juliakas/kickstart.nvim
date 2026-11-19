local gh = require('config.pack').gh

-- diffview and telescope are added earlier in init.lua
vim.pack.add { gh 'NeogitOrg/neogit' }
require('neogit').setup {}

vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'Show Neogit UI' })
