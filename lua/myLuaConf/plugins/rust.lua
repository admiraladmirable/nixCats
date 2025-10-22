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
            -- on_attach(client, bufnr)
            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, { buffer = bufnr, desc = 'Rust: Code Action' })
            vim.keymap.set('n', '<leader>rr', function()
              vim.cmd.RustLsp 'runnables'
            end, { buffer = bufnr, desc = 'Rust: Runnables' })
            vim.keymap.set('n', '<leader>rh', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, { buffer = bufnr, desc = 'Rust: Hover Actions' })
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
