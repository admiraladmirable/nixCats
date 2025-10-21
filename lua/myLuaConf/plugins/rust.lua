local on_attach = require 'myLuaConf.LSPs.on_attach'

return {
  {
    'rustaceanvim',
    version = '^6',
    for_cat = { cat = 'general', default = true },
    ft = { 'rust' },
    keys = {
      {
        '<leader>ca',
        function()
          vim.cmd.RustLsp 'codeAction'
        end,
        desc = 'Rust code action',
      },
      {
        '<leader>rr',
        function()
          vim.cmd.RustLsp 'runables'
        end,
        desc = 'Rust runnables',
      },
      {
        'K',
        function()
          vim.cmd.RustLsp { 'hover', 'actions' }
        end,
        desc = 'Rust Hover Actions',
      },
    },
    after = function()
      vim.g.rustaceanvim = vim.tbl_deep_extend('force', vim.g.rustaceanvim or {}, {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          on_attach = function(client, bufnr)
            on_attach(client, bufnr)
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
