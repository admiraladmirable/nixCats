local on_attach = require 'myLuaConf.LSPs.on_attach'

return {
  {
    'rustaceanvim',
    version = '^6',
    for_cat = { cat = 'general', default = true },
    ft = { 'rust' },
    after = function()
      vim.g.rustaceanvim = vim.tbl_deep_extend('force', vim.g.rustaceanvim or {}, {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)

            local function nmap(lhs, rhs, desc)
              vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
            end

            nmap('<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, 'Rust Code Action')

            nmap('<leader>rr', function()
              vim.cmd.RustLsp 'runnables'
            end, 'Rust Runnables')

            nmap('K', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, 'Rust Hover Actions')
          end,
          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
              check = {
                command = 'clippy',
              },
            },
          },
        },
      })
    end,
  },
}
