local catUtils = require 'nixCatsUtils'
local on_attach = require 'myLuaConf.LSPs.on_attach'

-- Ensure buffers get our LSP defaults even when servers bypass lspconfig.
local lsp_attach_group = vim.api.nvim_create_augroup('myLuaConfLspAttach', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach_group,
  callback = function(event)
    local client = event.data and event.data.client_id and vim.lsp.get_client_by_id(event.data.client_id) or nil
    if not client then
      return
    end

    local buf = event.buf

    local ok = pcall(vim.api.nvim_buf_get_var, buf, 'myLuaConf_lsp_attached')
    if not ok then
      on_attach(client, buf)
      vim.api.nvim_buf_set_var(buf, 'myLuaConf_lsp_attached', true)
    end

    if client.name == 'rust_analyzer' then
      local rust_ok = pcall(vim.api.nvim_buf_get_var, buf, 'myLuaConf_rust_keymaps')
      if not rust_ok then
        vim.keymap.set('n', '<leader>rr', function()
          vim.cmd.RustLsp 'runnables'
        end, { buffer = buf, desc = 'Rust: Runnables' })
        vim.keymap.set('n', '<leader>rh', function()
          vim.cmd.RustLsp { 'hover', 'actions' }
        end, { buffer = buf, desc = 'Rust: Hover Actions' })
        vim.api.nvim_buf_set_var(buf, 'myLuaConf_rust_keymaps', true)
      end
    end
  end,
})
if catUtils.isNixCats and nixCats 'lspDebugMode' then
  vim.lsp.set_log_level 'debug'
end

-- NOTE: This file uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- This is a slightly more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- nixCats gives us the paths, which is faster than searching the rtp!
local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
require('lze').h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixCats.pawsible { 'allPlugins', 'opt', 'nvim-lspconfig' } or nixCats.pawsible { 'allPlugins', 'start', 'nvim-lspconfig' }
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. '/lsp/' .. name .. '.lua')
    if not ok then
      ok, cfg = pcall(dofile, lspcfg .. '/lua/lspconfig/configs/' .. name .. '.lua')
    end
    return (ok and cfg or {}).filetypes or {}
  else
    return old_ft_fallback(name)
  end
end)
require('lze').load {
  {
    'nvim-lspconfig',
    for_cat = 'general.always',
    on_require = { 'lspconfig' },
    -- NOTE: define a function for lsp,
    -- and it will run for all specs with type(plugin.lsp) == table
    -- when their filetype trigger loads them
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = require 'myLuaConf.LSPs.on_attach',
      })
    end,
  },
  {
    'mason.nvim',
    -- only run it when not on nix
    enabled = not catUtils.isNixCats,
    on_plugin = { 'nvim-lspconfig' },
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd 'mason-lspconfig.nvim'
      require('mason').setup()
      -- auto install will make it install servers when lspconfig is called on them.
      require('mason-lspconfig').setup { automatic_installation = true }
    end,
  },
  {
    -- lazydev makes your lsp way better in your config without needing extra lsp configuration.
    'lazydev.nvim',
    for_cat = 'neonixdev',
    cmd = { 'LazyDev' },
    ft = 'lua',
    after = function(_)
      require('lazydev').setup {
        library = {
          { words = { 'nixCats' }, path = (nixCats.nixCatsPath or '') .. '/lua' },
        },
      }
    end,
  },
  {
    enabled = nixCats 'lua' or nixCats 'neonixdev' or false,
    -- provide a table containing filetypes,
    -- and then whatever your functions defined in the function type specs expect.
    -- in our case, it just expects the normal lspconfig setup options,
    -- but with a default on_attach and capabilities
    lsp = {
      -- if you provide the filetypes it doesn't ask lspconfig for the filetypes
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { 'nixCats', 'vim' },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
    -- also these are regular specs and you can use before and after and all the other normal fields
  },
  {
    'gopls',
    for_cat = 'go',
    -- if you don't provide the filetypes it asks lspconfig for them
    lsp = {
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    },
  },
  {
    'rnix',
    -- mason doesn't have nixd
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { 'nix' },
    },
  },
  {
    'ts_ls',
    for_cat = 'typescript',
    lsp = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
    },
  },
  {
    'templ',
    for_cat = 'web.templ',
    lsp = {
      filetypes = { 'templ' },
    },
  },
  {
    'tailwindcss',
    for_cat = 'web.tailwindcss',
    lsp = {
      filetypes = {
        'aspnetcorerazor',
        'astro',
        'astro-markdown',
        'blade',
        'clojure',
        'django-html',
        'htmldjango',
        'edge',
        'eelixir',
        'elixir',
        'ejs',
        'erb',
        'eruby',
        'gohtml',
        'gohtmltmpl',
        'haml',
        'handlebars',
        'hbs',
        'html',
        'htmlangular',
        'html-eex',
        'heex',
        'jade',
        'leaf',
        'liquid',
        'markdown',
        'mdx',
        'mustache',
        'njk',
        'nunjucks',
        'php',
        'razor',
        'slim',
        'twig',
        'css',
        'less',
        'postcss',
        'sass',
        'scss',
        'stylus',
        'sugarss',
        'javascript',
        'javascriptreact',
        'reason',
        'rescript',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
        'templ',
      },
    },
  },
  {
    'ts_ls',
    for_cat = 'web.JS',
    lsp = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
    },
  },
  {
    'htmx',
    for_cat = 'web.HTMX',
    lsp = {
      filetypes = {
        'aspnetcorerazor',
        'astro',
        'astro-markdown',
        'blade',
        'clojure',
        'django-html',
        'htmldjango',
        'edge',
        'eelixir',
        'elixir',
        'ejs',
        'erb',
        'eruby',
        'gohtml',
        'gohtmltmpl',
        'haml',
        'handlebars',
        'hbs',
        'html',
        'htmlangular',
        'html-eex',
        'heex',
        'jade',
        'leaf',
        'liquid',
        'mdx',
        'mustache',
        'njk',
        'nunjucks',
        'php',
        'razor',
        'slim',
        'twig',
        'javascript',
        'javascriptreact',
        'reason',
        'rescript',
        'typescript',
        'typescriptreact',
        'vue',
        'svelte',
        'templ',
      },
    },
  },
  {
    'cssls',
    for_cat = 'web.HTML',
    lsp = {
      filetypes = { 'css', 'scss', 'less' },
    },
  },
  {
    'eslint',
    for_cat = 'web.HTML',
    lsp = {
      filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue', 'svelte', 'astro' },
    },
  },
  {
    'jsonls',
    for_cat = 'web.HTML',
    lsp = {
      filetypes = { 'json', 'jsonc' },
    },
  },
  {
    'html',
    for_cat = 'web.HTML',
    lsp = {
      filetypes = { 'html', 'twig', 'hbs', 'templ' },
      settings = {
        html = {
          format = {
            templating = true,
            wrapLineLength = 120,
            wrapAttributes = 'auto',
          },
          hover = {
            documentation = true,
            references = true,
          },
        },
      },
    },
  },
  {
    'nil_ls',
    -- mason doesn't have nixd
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { 'nix' },
    },
  },
  {
    'github_actions_ls',
    for_cat = 'devops',
    lsp = {
      cmd = { 'github-actions-language-server', '--stdio' },
      filetypes = { 'yaml', 'yaml.github', 'yaml.gha', 'ghaction' },
    },
  },
  {
    'terraform_ls',
    for_cat = 'devops',
    lsp = {
      -- cmd = { 'terraform_ls', '--stdio' },
      -- filetypes = { 'terraform', 'tf' },
    },
  },
  {
    'nixd',
    enabled = catUtils.isNixCats and (nixCats 'nix' or nixCats 'neonixdev') or false,
    lsp = {
      filetypes = { 'nix' },
      settings = {
        nixd = {
          -- nixd requires some configuration.
          -- luckily, the nixCats plugin is here to pass whatever we need!
          -- we passed this in via the `extra` table in our packageDefinitions
          -- for additional configuration options, refer to:
          -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          nixpkgs = {
            -- in the extras set of your package definition:
            -- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
            expr = nixCats.extra 'nixdExtras.nixpkgs' or [[import <nixpkgs> {}]],
          },
          options = {
            -- If you integrated with your system flake,
            -- you should use inputs.self as the path to your system flake
            -- that way it will ALWAYS work, regardless
            -- of where your config actually was.
            nixos = {
              -- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
              expr = nixCats.extra 'nixdExtras.nixos_options',
            },
            -- If you have your config as a separate flake, inputs.self would be referring to the wrong flake.
            -- You can override the correct one into your package definition on import in your main configuration,
            -- or just put an absolute path to where it usually is and accept the impurity.
            ['home-manager'] = {
              -- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
              expr = nixCats.extra 'nixdExtras.home_manager_options',
            },
          },
          formatting = {
            command = { 'nixfmt' },
          },
          diagnostic = {
            suppress = {
              'sema-escaping-with',
            },
          },
        },
      },
    },
  },
}
