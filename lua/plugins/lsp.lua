-- nvim-lspconfig wires up Language Server Protocol (LSP) servers to Neovim.
-- LSP provides: go-to-definition, find references, rename, code actions, diagnostics, etc.
-- Mason auto-installs the servers so you don't have to manage them manually.
-- https://github.com/neovim/nvim-lspconfig

---@module 'lazy'
---@type LazySpec
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Mason installs LSP servers, formatters and linters into a local directory
    {
      'mason-org/mason.nvim',
      ---@module 'mason.settings'
      ---@type MasonSettings
      ---@diagnostic disable-next-line: missing-fields
      opts = {},
    },
    -- Bridges mason package names to nvim-lspconfig server names
    'mason-org/mason-lspconfig.nvim',
    -- Ensures specific tools are always installed via Mason
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- Shows a small spinner in the corner while LSP is loading/indexing
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    -- This autocmd fires every time an LSP server attaches to a buffer.
    -- All LSP keymaps are set here so they only exist in buffers with an active LSP.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Rename the symbol under the cursor across the whole project
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Run a code action (fix, refactor, import, etc.) at the cursor position
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

        -- Go to the declaration (e.g. C header). Different from definition (grd).
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight all references to the word under the cursor when it's held still
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/documentHighlight', event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Toggle inlay hints (e.g. parameter names, inferred types) if the server supports them
        if client and client:supports_method('textDocument/inlayHint', event.buf) then
          map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- List of language servers to install and enable.
    -- Add or remove entries here to change which languages get LSP support.
    -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md for all options.
    ---@type table<string, vim.lsp.Config>
    local servers = {
      vtsls = {},          -- TypeScript / JavaScript
      jsonls = {},         -- JSON with schema support
      eslint = {},         -- ESLint linting as LSP diagnostics
      cssls = {},          -- CSS / SCSS / Less
      cssmodules_ls = {},  -- CSS Modules class name completion
      stylua = {},         -- Lua formatter (used via conform, not really an LSP)

      -- Special Lua configuration that teaches lua_ls about the Neovim API
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                '${3rd}/luv/library',
                '${3rd}/busted/library',
              }),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      },
    }

    -- Configure eslint to auto-fix all fixable issues on every save
    local base_on_attach = vim.lsp.config.eslint.on_attach
    vim.lsp.config('eslint', {
      on_attach = function(client, bufnr)
        if not base_on_attach then return end
        base_on_attach(client, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          command = 'LspEslintFixAll',
        })
      end,
    })

    -- Tell Mason to install all servers listed above, then enable them
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {})
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
