-- Create, switch and delete git worktrees without leaving Neovim.
-- <leader>gw lists/switches existing worktrees (<M-c> to create, <M-d> to delete from the picker).
-- <leader>gW jumps straight to the create picker.
--
-- The create picker replaces the one shipped by the plugin. It makes no distinction
-- between local and remote branches: every branch shows up once, without an "origin/"
-- prefix, the worktree folder defaults to the branch name with slashes flattened to
-- dashes, and the same-named remote branch is always tracked without asking.
-- https://github.com/polarmutex/git-worktree.nvim

local gh = require('config.pack').gh

-- plenary and telescope are added earlier in init.lua
vim.pack.add { { src = gh 'polarmutex/git-worktree.nvim', version = vim.version.range '2.*' } }

require('telescope').load_extension 'git_worktree'

-- After switching worktree, re-open the same relative file path inside the new one
local Hooks = require 'git-worktree.hooks'
Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)

local git_worktree = require 'git-worktree'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values

-- Run git in the cwd and return its stdout lines, or {} if it failed
local function git_lines(args)
  local out = vim.fn.systemlist(vim.list_extend({ 'git' }, args))
  if vim.v.shell_error ~= 0 then return {} end
  return out
end

-- Remote names with origin first, so origin wins when several remotes carry a branch
local function remotes()
  local ordered, others = {}, {}
  for _, remote in ipairs(git_lines { 'remote' }) do
    table.insert(remote == 'origin' and ordered or others, remote)
  end
  return vim.list_extend(ordered, others)
end

-- Every branch in the repo as a single list, keyed on the name with any "<remote>/"
-- prefix stripped, so a branch that exists locally, on a remote, or both appears
-- exactly once. Most recently committed first.
local function branches()
  local remote_names = remotes()
  local order, by_name = {}, {}

  local function record(name, remote)
    local entry = by_name[name]
    if not entry then
      entry = { name = name, has_local = false, remotes = {} }
      by_name[name] = entry
      table.insert(order, entry)
    end
    if remote then
      table.insert(entry.remotes, remote)
    else
      entry.has_local = true
    end
  end

  local refs = git_lines {
    'for-each-ref',
    '--sort=-committerdate',
    '--format=%(refname)',
    'refs/heads',
    'refs/remotes',
  }

  for _, refname in ipairs(refs) do
    local head = refname:match '^refs/heads/(.+)$'
    local remote_ref = refname:match '^refs/remotes/(.+)$'
    if head then
      record(head, nil)
    elseif remote_ref then
      for _, remote in ipairs(remote_names) do
        local name = remote_ref:match('^' .. vim.pesc(remote) .. '/(.+)$')
        -- <remote>/HEAD is a symref to the default branch, not a branch of its own
        if name and name ~= 'HEAD' then
          record(name, remote)
          break
        end
      end
    end
  end

  return order
end

-- The same-named branch on a remote, or nil when no remote has it yet
local function same_name_upstream(name)
  for _, remote in ipairs(remotes()) do
    vim.fn.system { 'git', 'show-ref', '--verify', '--quiet', 'refs/remotes/' .. remote .. '/' .. name }
    if vim.v.shell_error == 0 then return remote .. '/' .. name end
  end
  return nil
end

-- Worktree folder for a branch: the branch name with slashes flattened, so every
-- worktree is one directory alongside the others instead of a nested tree
local function default_path(name) return (name:gsub('/', '-')) end

-- Confirm the folder, then create the worktree tracking the same-named remote branch
local function create_worktree(name)
  if name == nil or name == '' then
    vim.notify('git-worktree: no branch given', vim.log.levels.ERROR)
    return
  end

  local path = vim.fn.input('Path to worktree > ', default_path(name))
  if path == '' then
    vim.notify('git-worktree: no worktree path given', vim.log.levels.ERROR)
    return
  end

  -- When no remote carries the branch there is nothing to track, but a nil upstream
  -- must not be passed on: the plugin asks plenary whether the upstream exists, and
  -- plenary calls on_stdout with nil at EOF, so its `data == branch` test reports a
  -- nil upstream as found. It then emits a bare `git worktree add ... --track`, which
  -- git resolves against HEAD and quietly sets the upstream to the local main branch.
  -- Passing the branch as its own upstream trips the plugin's `branch ~= upstream`
  -- guard instead, which skips tracking altogether.
  git_worktree.create_worktree(path, name, same_name_upstream(name) or name)
end

local function create_picker(opts)
  opts = opts or {}

  -- cd to the repo's common dir first, so the folder typed at the prompt is
  -- relative to it rather than to whichever worktree we happen to be in
  git_worktree.switch_worktree(nil)

  local entries = branches()
  local name_width = 0
  for _, entry in ipairs(entries) do
    name_width = math.max(name_width, vim.fn.strdisplaywidth(entry.name))
  end

  -- Where the branch currently lives, e.g. "local", "origin", "local+origin"
  local function location(entry)
    local parts = {}
    if entry.has_local then table.insert(parts, 'local') end
    return table.concat(vim.list_extend(parts, entry.remotes), '+')
  end

  -- <CR> takes the highlighted branch, falling back to the typed text when the
  -- filter matches nothing. <Tab> always takes the typed text, for a new branch
  -- whose name is a prefix of an existing one.
  local function use_selection(prompt_bufnr)
    local selected = action_state.get_selected_entry()
    local typed = action_state.get_current_line()
    actions.close(prompt_bufnr)
    create_worktree(selected and selected.value or typed)
  end

  local function use_prompt(prompt_bufnr)
    local typed = action_state.get_current_line()
    actions.close(prompt_bufnr)
    create_worktree(typed)
  end

  pickers
    .new(opts, {
      prompt_title = 'Git Worktree Create (branch, or a new name)',
      finder = finders.new_table {
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry.name,
            ordinal = entry.name,
            -- Built by hand rather than with telescope's entry_display, whose
            -- column widths are resolved from live picker window state
            display = function()
              local padding = name_width - vim.fn.strdisplaywidth(entry.name) + 2
              local label = entry.name .. string.rep(' ', padding)
              local tag = location(entry)
              return label .. tag, { { { #label, #label + #tag }, 'TelescopeResultsComment' } }
            end,
          }
        end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
        actions.select_default:replace(use_selection)
        map({ 'i', 'n' }, '<tab>', use_prompt)
        return true
      end,
    })
    :find()
end

local wt_ext = require('telescope').extensions.git_worktree

vim.keymap.set('n', '<leader>gw', function()
  -- Telescope applies the extension's own mappings first and ours second, so
  -- this <M-c> replaces the extension's create picker with the one above
  wt_ext.git_worktree {
    attach_mappings = function(_, map)
      map({ 'i', 'n' }, '<m-c>', function(prompt_bufnr)
        actions.close(prompt_bufnr)
        create_picker {}
      end)
      return true
    end,
  }
end, { desc = '[G]it [W]orktree list/switch' })

vim.keymap.set('n', '<leader>gW', function() create_picker {} end, { desc = '[G]it [W]orktree create' })
