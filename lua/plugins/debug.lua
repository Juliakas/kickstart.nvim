-- Debugging via the Debug Adapter Protocol (DAP), set up for JavaScript and TypeScript.
-- Uses js-debug (the debugger VS Code ships), installed by Mason in lua/plugins/lsp.lua.
-- A project's .vscode/launch.json is picked up too: <leader>dc lists its configurations.
-- https://github.com/mfussenegger/nvim-dap

local gh = require('config.pack').gh

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'nvim-neotest/nvim-nio',
  gh 'rcarriga/nvim-dap-ui',
}

local dap = require 'dap'
local dapui = require 'dapui'

-- All debug keymaps live under <leader>d
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[D]ebug: Start/[C]ontinue' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = '[D]ebug: Step [I]nto' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = '[D]ebug: Step [O]ver' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = '[D]ebug: Step [O]ut' })
vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = '[D]ebug: [T]erminate' })
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug: Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = '[D]ebug: Conditional [B]reakpoint' })
-- The UI closes when a session ends; this brings it back to read the last session's output
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[D]ebug: Toggle [U]I / last session result' })
vim.keymap.set({ 'n', 'v' }, '<leader>de', dapui.eval, { desc = '[D]ebug: [E]valuate expression' })

---@diagnostic disable-next-line: missing-fields
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
local breakpoint_icons = vim.g.have_nerd_font
    and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
  or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
for type, icon in pairs(breakpoint_icons) do
  local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
  vim.fn.sign_define('Dap' .. type, { text = icon, texthl = hl, numhl = hl })
end

-- [[ JavaScript / TypeScript ]]
-- js-debug runs as a local server; Mason puts `js-debug-adapter` on Neovim's PATH
dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = { command = 'js-debug-adapter', args = { '${port}' } },
}

-- launch.json files written for VS Code say `"type": "node"`; js-debug only answers to pwa-node
dap.adapters.node = function(callback, config)
  if config.type == 'node' then config.type = 'pwa-node' end
  callback(dap.adapters['pwa-node'])
end

local skip_files = { '<node_internals>/**', '${workspaceFolder}/node_modules/**' }

-- [[ package.json scripts ]]
-- Debug any script the way VS Code's "runtimeExecutable": "npm" does: js-debug attaches to
-- every Node process the script starts (tsx included), so no --inspect flag is needed.

local function project_root() return vim.fs.root(vim.fn.getcwd(), 'package.json') end

local function package_manager(root)
  for lockfile, pm in pairs { ['pnpm-lock.yaml'] = 'pnpm', ['yarn.lock'] = 'yarn', ['bun.lock'] = 'bun' } do
    if vim.uv.fs_stat(vim.fs.joinpath(root, lockfile)) then return pm end
  end
  return 'npm'
end

local function script_names(root)
  local ok, pkg = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(vim.fs.joinpath(root, 'package.json')), '\n')) end)
  if not ok or type(pkg.scripts) ~= 'table' then return {} end
  local names = vim.tbl_keys(pkg.scripts)
  table.sort(names)
  return names
end

---@param root string
---@param script string
---@param args? string[] passed to the script
---@param env? table<string, string> overrides for the script's environment
---@return dap.Configuration
local function script_config(root, script, args, env)
  local pm = package_manager(root)
  local run_args = { 'run', script }
  -- npm needs `--` to forward arguments; pnpm, yarn and bun forward everything after the name
  if args and #args > 0 then
    if pm == 'npm' then table.insert(run_args, '--') end
    vim.list_extend(run_args, args)
  end
  return {
    name = ('%s run %s'):format(pm, script),
    type = 'pwa-node',
    request = 'launch',
    runtimeExecutable = pm,
    runtimeArgs = run_args,
    env = env,
    cwd = root,
    autoAttachChildProcesses = true,
    sourceMaps = true,
    skipFiles = skip_files,
    console = 'integratedTerminal',
  }
end

-- Every script in the project's package.json, listed under <leader>dc alongside .vscode/launch.json
dap.providers.configs['package-json-scripts'] = function()
  local root = project_root()
  if not root then return {} end
  return vim.tbl_map(function(script) return script_config(root, script) end, script_names(root))
end

-- Pick a script, then give parameters: leading KEY=value words become environment
-- variables, the rest are passed to the script, e.g. `LOG_LEVEL=debug --offset 42`
vim.keymap.set('n', '<leader>dn', function()
  local root = project_root()
  if not root then return vim.notify('No package.json above ' .. vim.fn.getcwd(), vim.log.levels.WARN) end

  vim.ui.select(script_names(root), { prompt = 'Debug script' }, function(script)
    if not script then return end
    vim.ui.input({ prompt = 'Env / args for ' .. script .. ': ' }, function(input)
      if input == nil then return end
      local env, args = {}, {}
      for _, word in ipairs(vim.split(input, '%s+', { trimempty = true })) do
        local key, value = word:match '^([%a_][%w_]*)=(.*)$'
        if key and #args == 0 then
          env[key] = value
        else
          table.insert(args, word)
        end
      end
      dap.run(script_config(root, script, args, env))
    end)
  end)
end, { desc = '[D]ebug: run package.json script with e[n]v/args' })

vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = '[D]ebug: run [L]ast again' })
