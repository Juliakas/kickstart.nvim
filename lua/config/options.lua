-- [[ Setting options ]]
-- See `:help vim.o` for the full list of options
-- NOTE: You can change these options as you wish!

-- Show line numbers in the gutter
vim.o.number = true
-- Also show numbers relative to cursor line (helps with jumping with e.g. `5j`)
vim.o.relativenumber = true

-- Enable mouse support (useful for resizing splits, clicking, scrolling)
vim.o.mouse = 'a'

-- Don't show --INSERT-- / --NORMAL-- in the command line (statusline shows it)
vim.o.showmode = false

-- Sync clipboard between OS and Neovim so yank/paste work with the system clipboard.
-- Scheduled after UiEnter to avoid slowing down startup.
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Indent wrapped lines to match the start of the line
vim.o.breakindent = true

-- Persist undo history across file closes (stored in ~/.local/share/nvim/undo/)
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Always show the sign column so the editor doesn't shift when diagnostics appear
vim.o.signcolumn = 'yes'

-- Reduce the time before CursorHold events fire (used by LSP for highlights, etc.)
vim.o.updatetime = 250

-- Time (ms) to wait for a mapped key sequence to complete
vim.o.timeoutlen = 300

-- New vertical splits open to the right, horizontal splits open below
vim.o.splitright = true
vim.o.splitbelow = true

-- Render special whitespace characters visually
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show a live preview of :substitute replacements as you type
vim.o.inccommand = 'split'

-- Highlight the line the cursor is currently on
vim.o.cursorline = true

-- Always keep at least 10 lines visible above/below the cursor when scrolling
vim.o.scrolloff = 10

-- [[ Neovide GUI settings ]]
-- Neovide is a GUI frontend for Neovim. These disable animations for a snappier feel.
vim.g.neovide_position_animation_length = 0
vim.g.neovide_cursor_animation_length = 0.00
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_scroll_animation_length = 0.00

-- Ask to save instead of failing when closing a modified buffer
vim.o.confirm = true

-- Use fish shell on Linux, PowerShell on Windows (for :terminal and shell commands)
if vim.fn.has 'linux' then
  vim.o.shell = 'fish'
else
  vim.o.shell = vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell'
end

-- Use spaces instead of tabs, with a width of 2
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- Draw a vertical ruler at column 150 as a line-length guide
vim.o.colorcolumn = '150'

-- Wrap long lines visually (doesn't insert line breaks, just wraps display)
vim.o.wrap = true

-- Automatically write all buffers when navigating away (e.g. switching files)
vim.o.autowriteall = true
