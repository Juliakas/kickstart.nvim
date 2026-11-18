-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear search highlights when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- [[ Diagnostic configuration ]]
-- Diagnostics are messages from the LSP about errors, warnings, hints, etc.
-- See `:help vim.diagnostic.Opts`
vim.diagnostic.config({
	-- Don't update diagnostics while typing in insert mode (less distracting)
	update_in_insert = false,
	-- Show most severe diagnostics first
	severity_sort = true,
	-- Use rounded borders and only show source when there are multiple sources
	float = { border = "rounded", source = "if_many" },
	-- Only underline warnings and above (not hints/info)
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	-- Virtual text: show diagnostic message at end of the line
	virtual_text = true,
	-- Virtual lines: show diagnostic underneath the line (alternative to virtual_text)
	virtual_lines = false,

	-- Automatically open the float when jumping to a diagnostic with `[d` / `]d`
	jump = { float = true },

	-- Icons in the sign column (left gutter); uses Nerd Font icons if available
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = vim.g.have_nerd_font and "󰅚" or "E",
			[vim.diagnostic.severity.WARN] = vim.g.have_nerd_font and "󰀦" or "W",
			[vim.diagnostic.severity.INFO] = vim.g.have_nerd_font and "󰋽" or "I",
			[vim.diagnostic.severity.HINT] = vim.g.have_nerd_font and "󰌵" or "H",
		},
	},
})

-- Open the quickfix list populated with all diagnostics in the current buffer
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit the built-in terminal emulator with <Esc><Esc> (the default <C-\><C-n> is hard to remember)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate between windows (splits) with CTRL + hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Save without triggering formatters/autocommands (useful when you want to save as-is)
vim.keymap.set("n", "<leader>w", ":noautocmd w<CR>", { desc = "Save without formatting" })

-- Make j/k move by visual (wrapped) lines rather than actual lines
-- This makes navigating soft-wrapped text feel natural
vim.keymap.set("n", "j", "gj", { desc = "Move down soft wrapped line" })
vim.keymap.set("n", "k", "gk", { desc = "Move up soft wrapped line" })

-- [[ Lazygit ]]
-- One lazygit process in an ordinary terminal buffer. The buffer handle is the
-- identity: terminal buffers are renamed to `term://{cwd}//{pid}:{cmd}` the moment
-- the job starts (`:help terminal`), so any name we set is thrown away and matching
-- on one would also match an unrelated terminal opened in a path containing "lazygit".
local lazygit_buf = nil
local lazygit_prev_buf = nil

vim.api.nvim_create_user_command("LazyGit", function()
	-- 1. Already showing it: toggle back to wherever we came from
	if lazygit_buf and vim.api.nvim_get_current_buf() == lazygit_buf then
		if lazygit_prev_buf and vim.api.nvim_buf_is_valid(lazygit_prev_buf) then
			vim.cmd("buffer " .. lazygit_prev_buf)
		elseif vim.fn.bufnr("#") ~= -1 then
			vim.cmd("buffer #")
		end
		return
	end

	-- 2. Still running: reuse the existing instance
	if lazygit_buf and vim.api.nvim_buf_is_valid(lazygit_buf) then
		lazygit_prev_buf = vim.api.nvim_get_current_buf()
		vim.cmd("buffer " .. lazygit_buf)
		return
	end

	if vim.fn.executable("lazygit") == 0 then
		vim.notify("lazygit is not on $PATH", vim.log.levels.ERROR)
		return
	end

	-- 3. Create a new buffer
	lazygit_prev_buf = vim.api.nvim_get_current_buf()
	vim.cmd("enew")
	local bufnr = vim.api.nvim_get_current_buf()

	-- 4. Start the terminal job
	local job = vim.fn.jobstart("lazygit", {
		term = true,
		on_exit = function()
			vim.schedule(function()
				lazygit_buf = nil
				if vim.api.nvim_buf_is_valid(bufnr) then
					-- Send any window showing it back to the previous buffer, so deleting
					-- it does not drop those windows on an arbitrary alternate buffer
					if lazygit_prev_buf and vim.api.nvim_buf_is_valid(lazygit_prev_buf) then
						for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
							vim.api.nvim_win_set_buf(win, lazygit_prev_buf)
						end
					end
					vim.api.nvim_buf_delete(bufnr, { force = true })
				end
				-- lazygit changes files on disk (checkout, stash, rebase); reload them
				vim.cmd("checktime")
			end)
		end,
	})

	-- A failed start would otherwise strand an empty buffer that every later
	-- invocation happily "reopens"
	if job <= 0 then
		vim.api.nvim_buf_delete(bufnr, { force = true })
		vim.notify("Failed to start lazygit", vim.log.levels.ERROR)
		return
	end
	lazygit_buf = bufnr

	-- 6. Force insert mode EVERY time you switch to this buffer
	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = bufnr,
		callback = function()
			vim.cmd("startinsert")
		end,
	})

	-- 7. Block the keys that would kill or suspend the process by accident.
	-- <Esc><Esc> and <C-\><C-n> stay free: the global <Esc><Esc> mapping is
	-- noremap, so its <C-\><C-n> right-hand side is unaffected by buffer maps
	vim.keymap.set("t", "<C-c>", "<Nop>", { buffer = bufnr, desc = "Lazygit: ignore SIGINT" })
	vim.keymap.set("t", "<C-z>", "<Nop>", { buffer = bufnr, desc = "Lazygit: ignore suspend" })

	-- Start insert immediately on first launch
	vim.cmd("startinsert")
end, { desc = "Toggle the lazygit terminal buffer" })

vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Toggle Lazygit" })
