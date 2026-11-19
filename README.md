# My Neovim Configuration

A modular Neovim setup built on [kickstart.nvim](https://github.com/nvim-kickstart/kickstart.nvim).
Each concern lives in its own file so it's easy to find, change, or disable anything.

---

## Directory structure

```
~/.config/nvim/
├── init.lua                    # Entry point: leader keys, loads config.*, then each plugin file
├── lua/
│   ├── config/
│   │   ├── options.lua         # Editor settings (line numbers, tabs, etc.)
│   │   ├── keymaps.lua         # Key bindings + diagnostic configuration
│   │   ├── autocmds.lua        # Automatic actions on events (e.g. highlight on yank)
│   │   └── pack.lua            # vim.pack build hooks (make, :TSUpdate) + gh() helper
│   ├── plugins/                # One file per plugin
│   │   ├── guess-indent.lua
│   │   ├── which-key.lua
│   │   ├── telescope.lua
│   │   ├── lsp.lua
│   │   ├── conform.lua
│   │   ├── blink-cmp.lua
│   │   ├── catppuccin.lua
│   │   ├── todo-comments.lua
│   │   ├── mini.lua
│   │   ├── gitsigns.lua
│   │   ├── git-worktree.lua
│   │   ├── diffview.lua
│   │   ├── neogit.lua
│   │   ├── neo-tree.lua
│   │   ├── fugitive.lua
│   │   ├── debug.lua           # JS/TS debugging (nvim-dap + js-debug)
│   │   └── treesitter.lua
│   └── kickstart/              # Upstream kickstart files, kept unedited so syncs stay clean
│       ├── health.lua          # :checkhealth kickstart
│       └── plugins/            # Optional extras, all disabled (enable in init.lua)
│           ├── autopairs.lua
│           ├── debug.lua       # Go example
│           ├── indent_line.lua
│           └── lint.lua
└── nvim-pack-lock.json         # Exact plugin revisions (like package-lock.json)
```

---

## init.lua — Entry point

The entry point does three things then hands off to the plugin manager:

1. **Sets leader keys** — `<Space>` is the leader. Every `<leader>x` keymap starts with Space.
   The leader must be set *before* any plugin loads.
2. **Requires** `config.options`, `config.keymaps`, and `config.autocmds`.
3. **Loads plugins** — requires `config.pack` (build hooks), then each `lua/plugins/*.lua` file in
   dependency order. Each file installs its plugin with `vim.pack.add` and calls its `setup()`.

---

## lua/config/options.lua — Editor settings

| Setting | What it does |
|---|---|
| `vim.o.number = true` | Show line numbers in the left gutter |
| `vim.o.relativenumber = true` | Also show numbers *relative* to the cursor line. Lets you jump with e.g. `5j` to move 5 lines down |
| `vim.o.mouse = 'a'` | Enable mouse in all modes. Useful for resizing splits or clicking |
| `vim.o.showmode = false` | Hide the `-- INSERT --` message (the statusline already shows the mode) |
| `vim.o.clipboard = 'unnamedplus'` | Use the system clipboard for yank/paste. Everything you copy in Neovim is available in other apps and vice-versa |
| `vim.o.breakindent = true` | When a long line wraps, the continuation is indented to match the original line |
| `vim.o.undofile = true` | Persist undo history to disk. After closing and reopening a file you can still undo changes |
| `vim.o.ignorecase = true` | Searches are case-insensitive… |
| `vim.o.smartcase = true` | …unless the search term contains a capital letter, then it's case-sensitive |
| `vim.o.signcolumn = 'yes'` | Always show the thin column to the left of line numbers where diagnostics/git signs appear. Prevents the text shifting left/right |
| `vim.o.updatetime = 250` | How many ms of no typing before `CursorHold` events fire. LSP uses this to highlight references under the cursor |
| `vim.o.timeoutlen = 300` | How long (ms) Neovim waits for the next key in a mapped sequence before giving up |
| `vim.o.splitright / splitbelow` | New vertical splits open to the right, horizontal splits open below |
| `vim.o.list = true` + `listchars` | Render invisible characters: `»` for tabs, `·` for trailing spaces, `␣` for non-breaking spaces |
| `vim.o.inccommand = 'split'` | Show a live preview of `:substitute` replacements in a small split as you type |
| `vim.o.cursorline = true` | Highlight the entire line the cursor is on |
| `vim.o.scrolloff = 10` | Always keep at least 10 lines visible above and below the cursor when scrolling |
| `vim.o.confirm = true` | Instead of failing with `E37: No write since last change`, pop up a dialog asking whether to save |
| `vim.o.shell = "zsh"` | Shell used by `:terminal` and shell commands |
| `vim.o.expandtab = true` | Press `<Tab>` to insert spaces, not a real tab character |
| `vim.o.tabstop / softtabstop / shiftwidth = 2` | Indentation width is 2 spaces |
| `vim.o.colorcolumn = '150'` | Draw a vertical line at column 150 as a soft line-length guide |
| `vim.o.wrap = true` | Visually wrap long lines (no horizontal scrolling needed) |
| `vim.o.autowriteall = true` | Automatically save all modified buffers when switching files, closing windows, etc. |
| `vim.g.neovide_*` | Disable Neovide GUI animations for a snappier feel |

---

## lua/config/keymaps.lua — Key bindings

Neovim keymaps follow the pattern `vim.keymap.set(mode, keys, action, opts)`.

- **mode**: `'n'` = normal, `'i'` = insert, `'v'` = visual, `'t'` = terminal, `''` = all
- **`<leader>`** = `<Space>` (set in `init.lua`)

| Keys | Mode | What it does |
|---|---|---|
| `<Esc>` | Normal | Clear search highlights (the orange/yellow highlighted matches after `/search`) |
| `<leader>q` | Normal | Open the quickfix list with all LSP diagnostics for the current buffer |
| `<Esc><Esc>` | Terminal | Exit the built-in terminal and return to normal mode |
| `<C-h/j/k/l>` | Normal | Move focus to the left/lower/upper/right window split |
| `<leader>w` | Normal | Save the file *without* triggering autoformat or other autocommands |
| `j` / `k` | Normal | Move down/up by *visual* (wrapped) lines instead of actual file lines. Makes reading soft-wrapped prose feel natural |

### Diagnostic configuration

Diagnostics are messages from the LSP about errors, warnings, hints, and suggestions.

| Setting | Effect |
|---|---|
| `update_in_insert = false` | Don't show new diagnostics while you're typing — less distracting |
| `severity_sort = true` | Errors appear above warnings in lists |
| `float = { border = 'rounded' }` | Diagnostic hover popups have rounded corners |
| `underline = { min = WARN }` | Only underline warnings and errors (not hints/info) |
| `virtual_text = true` | Show the message at the end of the line in the editor |
| `virtual_lines = false` | Disabled alternative that puts the message on its own line below |
| `jump = { float = true }` | When you jump to a diagnostic (`[d` / `]d`), the floating popup opens automatically |
| `signs.text` | Gutter icons: error=󰅚, warn=󰀦, info=󰋽, hint=󰌵 (or letters if no Nerd Font) |

---

## lua/config/autocmds.lua — Automatic actions

Autocommands (`autocmd`) are callbacks that run when specific events happen in Neovim.

| Autocmd | Trigger | Effect |
|---|---|---|
| `kickstart-highlight-yank` | `TextYankPost` | Briefly flashes the text you just yanked (copied) so you can see what was selected |

---

## Plugins

Plugins are managed by `vim.pack`, Neovim's built-in plugin manager (`:help vim.pack`).
Run `:lua vim.pack.update(nil, { offline = true })` to see their state, and
`:lua vim.pack.update()` to update them.

---

### guess-indent.nvim · `lua/plugins/guess-indent.lua`

Automatically detects whether a file uses tabs or spaces for indentation, and what width,
then applies those settings so your edits match the existing style.

No keymaps — it just works silently on every file you open.

---

### which-key.nvim · `lua/plugins/which-key.lua`

Shows a popup listing available keybindings when you pause mid-sequence.

**How to use:** Press `<Space>` and wait. A panel appears showing every `<leader>` mapping.
Press `s` and see all search commands. Works for any key sequence, not just `<leader>`.

This is the best way to discover what's possible in this config.

---

### telescope.nvim · `lua/plugins/telescope.lua`

A fuzzy finder for almost anything: files, text, help pages, keymaps, LSP symbols, etc.
Results are shown in a floating window with a live-search prompt.

**While inside Telescope:** `<c-/>` (insert mode) or `?` (normal mode) shows all available actions.

| Keymap | What it does |
|---|---|
| `<leader>sf` | Search files in the project (including hidden dot-files) |
| `<leader>sg` | Live grep — search for text across all files |
| `<leader>sw` | Search for the word under the cursor |
| `<leader>sh` | Search Neovim help documentation |
| `<leader>sk` | Search all keymaps |
| `<leader>sd` | Search LSP diagnostics (errors, warnings) |
| `<leader>sr` | Resume the last Telescope search |
| `<leader>s.` | Search recently opened files |
| `<leader>sc` | Search Neovim commands |
| `<leader>ss` | Search/select which Telescope picker to open |
| `<leader><leader>` | List and switch between open buffers (open files) |
| `<leader>/` | Fuzzy search inside the current buffer |
| `<leader>s/` | Live grep across only the open buffers |
| `<leader>sn` | Search files in your Neovim config |
| `grr` | (LSP) Find all references to the symbol under cursor |
| `gri` | (LSP) Go to implementation |
| `grd` | (LSP) Go to definition |
| `gO` | (LSP) List all symbols in the current document |
| `gW` | (LSP) Search all symbols in the whole workspace |
| `grt` | (LSP) Go to type definition |

---

### nvim-lspconfig · `lua/plugins/lsp.lua`

Configures Language Server Protocol (LSP) support. LSP servers are separate programs that
understand a specific language and communicate with Neovim to provide:

- **Go to definition** — jump to where a function/variable is defined
- **Find references** — find every place a symbol is used
- **Rename** — rename a symbol across the whole project
- **Code actions** — automated fixes, imports, refactors suggested by the server
- **Diagnostics** — errors and warnings inline in the editor
- **Hover documentation** — press `K` to see docs for the symbol under the cursor

**Mason** (a dependency) handles downloading and installing the servers for you.
Run `:Mason` to see installed tools and install new ones interactively.

#### Installed servers

| Server | Language |
|---|---|
| `vtsls` | TypeScript and JavaScript |
| `jsonls` | JSON (with schema validation) |
| `eslint` | ESLint linting as LSP diagnostics; auto-fixes on save |
| `cssls` | CSS, SCSS, Less |
| `cssmodules_ls` | CSS Modules class name completion |
| `lua_ls` | Lua (pre-configured to understand the Neovim API) |

To add a language, add an entry to the `servers` table in `lua/plugins/lsp.lua`.

#### LSP keymaps (active only when an LSP is attached)

| Keymap | What it does |
|---|---|
| `grn` | **Rename** — rename the symbol under cursor across all files |
| `gra` | **Code action** — show available fixes/refactors at the cursor |
| `grD` | Go to **declaration** (e.g. the `.h` header in C) |
| `<leader>th` | Toggle **inlay hints** (e.g. parameter names, inferred types shown in code) |
| `K` | (Built-in) Show hover documentation |
| `[d` / `]d` | (Built-in) Jump to previous/next diagnostic |

---

### conform.nvim · `lua/plugins/conform.lua`

Runs code formatters automatically on save, and on demand with `<leader>f`.

Falls back to the LSP formatter if no dedicated formatter is configured for the filetype.

| Keymap | What it does |
|---|---|
| `<leader>f` | Format the current buffer immediately |

| Filetype | Formatter |
|---|---|
| Lua | `stylua` (installed via Mason) |

To add more formatters, add entries to `formatters_by_ft` in `lua/plugins/conform.lua`.

---

### blink.cmp · `lua/plugins/blink-cmp.lua`

The autocompletion engine. Shows a popup menu of suggestions as you type.
Sources: LSP completions, file paths, and code snippets (via LuaSnip).

| Key | What it does |
|---|---|
| `<c-y>` | Accept the selected completion |
| `<c-e>` | Close the completion menu |
| `<c-n>` / `<c-p>` | Select next / previous item |
| `<c-space>` | Open the menu, or show documentation for the selected item |
| `<c-k>` | Toggle signature help (show parameter info for the function you're calling) |
| `<Tab>` / `<S-Tab>` | Move forward/backward through a snippet's placeholders |

LuaSnip is the snippet engine. Snippets are short triggers that expand into larger code
templates. The `friendly-snippets` collection (commented out in the config) adds hundreds
of ready-made snippets for many languages — uncomment it in `blink-cmp.lua` to enable.

---

### catppuccin · `lua/plugins/catppuccin.lua`

The colour scheme. Catppuccin "Mocha" is a warm, dark theme.

To change flavour, edit `flavour = 'mocha'` in the config. Options: `latte` (light),
`frappe`, `macchiato`, `mocha`.

To switch to a completely different theme, install a new colorscheme plugin and change the
`vim.cmd.colorscheme` call.

---

### todo-comments.nvim · `lua/plugins/todo-comments.lua`

Highlights special comment keywords with distinct colours so they stand out:

| Keyword | Meaning |
|---|---|
| `TODO` | Something still to be done |
| `FIXME` | A known bug or broken thing |
| `NOTE` | An informational comment |
| `HACK` | A temporary workaround |
| `WARN` | A warning for future readers |
| `PERF` | A performance concern |
| `TEST` | Test-related comment |

Usage: just type `-- TODO: do this thing` anywhere in your code.

---

### mini.nvim · `lua/plugins/mini.lua`

A library of small, independent modules. Three are active:

#### mini.ai — Extended text objects

Extends the built-in `a` (around) and `i` (inside) motions to work with more targets.

| Example | What it does |
|---|---|
| `va)` | Visually select **a**round **)**paren |
| `yiiq` | **Y**ank **i**nside next (**i**) **q**uote — `in`/`an` are taken by 0.12's incremental selection |
| `ci'` | **C**hange **i**nside **'** quote |
| `da,` | **D**elete **a** function **a**rgument (including the comma) |

#### mini.surround — Add/remove/replace surrounding pairs

| Example | What it does |
|---|---|
| `saiw)` | **S**urround **a**dd **i**nner **w**ord with **)** |
| `sd'` | **S**urround **d**elete **'** quotes |
| `sr)'` | **S**urround **r**eplace **)** with **'** |

#### mini.statusline — Statusline

The bar at the very bottom of the window. Shows: mode, file name, git branch,
diagnostics count, filetype, and cursor position.

---

### nvim-treesitter · `lua/plugins/treesitter.lua`

Parses your code into a syntax tree using language-specific grammars. This powers:

- **Accurate syntax highlighting** — highlights are based on the real structure of the code,
  not just regex patterns. Comments inside strings are highlighted correctly, etc.
- **Smarter indentation** — `indentexpr` uses the tree to decide the right indent level
- **Better text objects** — mini.ai and other plugins use the tree for smarter selections

Pre-installed parsers: bash, C, diff, HTML, Lua, Markdown, Vim, and more.
Additional parsers are downloaded on demand when you open a file of that type
(if the grammar exists on the Treesitter registry).

Run `:TSInstallInfo` to see all available parsers.

---

### gitsigns.nvim · `lua/plugins/gitsigns.lua`

Shows git status in the sign column (added/changed/deleted lines) and provides
keymaps for working with individual hunks (chunks of changed lines).

| Keymap | What it does |
|---|---|
| `]c` | Jump to the next changed hunk |
| `[c` | Jump to the previous changed hunk |
| `<leader>hs` | Stage the current hunk, or unstage it if already staged |
| `<leader>hr` | Reset the hunk (discard the change) |
| `<leader>hS` | Stage the entire buffer |
| `<leader>hR` | Reset the entire buffer |
| `<leader>hp` | Preview the hunk in a floating window |
| `<leader>hi` | Preview the hunk inline |
| `<leader>hb` | Show full git blame for the current line |
| `<leader>hd` | Diff the buffer against the git index |
| `<leader>hD` | Diff the buffer against the last commit |
| `<leader>hq` / `<leader>hQ` | Hunks of this file / the whole repo in the quickfix list |
| `<leader>tb` | Toggle inline git blame on the current line |
| `<leader>tw` | Toggle intra-line word diff |
| `<leader>tD` | Toggle showing deleted lines inline |
| `ih` | Text object: inside hunk (e.g. `vih`, `dih`) |

---

### neo-tree.nvim · `lua/plugins/neo-tree.lua`

A file explorer sidebar. Press `\` to open it, press `\` again inside it to close it.

The explorer shows the project's file tree. You can navigate with `j`/`k`, open files with
`<Enter>`, create/rename/delete files, etc. Press `?` inside neo-tree for a full keymap list.

---

### vim-fugitive · `lua/plugins/fugitive.lua`

A full Git client inside Neovim. Run `:Git` to open the status window, which shows staged
and unstaged changes. From there you can stage, commit, push, pull, and more.

Common commands:

| Command | What it does |
|---|---|
| `:Git` | Open the interactive git status window |
| `:Git commit` | Write a commit message |
| `:Git push` | Push to remote |
| `:Git blame` | Open a line-by-line blame view |
| `:GdiffSplit` | Diff the current file against HEAD in a split |

---

### nvim-dap — debugging · `lua/plugins/debug.lua`

Debugs JavaScript and TypeScript with js-debug, the debugger VS Code uses (Mason installs it).
`<leader>dc` lists what you can run: the project's `.vscode/launch.json` configurations, plus
every `package.json` script run through the project's package manager. `<leader>dn` picks a script
and asks for parameters: leading `KEY=value` words become environment variables, the rest are
passed to the script (e.g. `LOG_LEVEL=debug --offset 42`).

| Keymap | What it does |
|---|---|
| `<leader>dc` | Start, or continue |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>dt` | Terminate the session |
| `<leader>db` / `<leader>dB` | Toggle a breakpoint / set a conditional one |
| `<leader>du` | Toggle the debug UI (reopens the last session's output) |
| `<leader>de` | Evaluate the expression under the cursor or the selection |
| `<leader>dn` | Debug a `package.json` script with env / args |
| `<leader>dl` | Run the last configuration again |

---

## Kickstart extras · `lua/kickstart/plugins/`

These are opt-in plugins. To enable one, uncomment the relevant line in `init.lua`.

### autopairs (disabled)

Automatically closes brackets, quotes, and parentheses as you type them.
Enable by uncommenting `require 'kickstart.plugins.autopairs'` in `init.lua`.

---

### indent-blankline (disabled)

Draws subtle vertical lines at each indentation level to make nested code easier to read.
Enable by uncommenting `require 'kickstart.plugins.indent_line'` in `init.lua`.

---

### nvim-lint (disabled)

Runs linters (separate from LSP) on save. Configured with `markdownlint` for Markdown files.
Enable by uncommenting `require 'kickstart.plugins.lint'` in `init.lua`.

---

### nvim-dap for Go (disabled)

Kickstart's Go debugging example. Its keymaps differ from `lua/plugins/debug.lua`, which already
sets up nvim-dap, so merge the Go parts into that file rather than enabling both.

---

## Adding your own plugins

Create a new `.lua` file in `lua/plugins/` that installs and sets up the plugin:

```lua
-- lua/plugins/my-plugin.lua
local gh = require('config.pack').gh

vim.pack.add { gh 'author/my-plugin' }
require('my-plugin').setup {
  -- plugin settings here
}
```

Then add `require 'plugins.my-plugin'` to `init.lua`, after any plugin it depends on.

---

## Useful built-in commands

| Command | What it does |
|---|---|
| `:lua vim.pack.update()` | Update plugins (review the diff, then `:write` to apply) |
| `:Mason` | Install/manage LSP servers, formatters, linters |
| `:checkhealth` | Diagnose issues with Neovim and plugins |
| `:help <topic>` | Open the built-in documentation |
| `:Telescope help_tags` or `<leader>sh` | Fuzzy-search the help docs |
| `:TSInstallInfo` | List available Treesitter parsers |
| `:ConformInfo` | Show which formatters are active for the current file |
| `:LspInfo` | Show which LSP servers are active for the current buffer |
