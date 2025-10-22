local on_attach = require 'myLuaConf.LSPs.on_attach'

return {
  {
    'rustaceanvim',
    version = '^6',
    for_cat = { cat = 'general', default = true },
    ft = { 'rust' },
    before = function()
      local rustacean = vim.g.rustaceanvim or {}

      rustacean.tools = vim.tbl_deep_extend('force', rustacean.tools or {}, {
        hover_actions = { auto_focus = true },
      })

      local existing_on_attach = rustacean.server and rustacean.server.on_attach

      local function rust_on_attach(client, bufnr)
        on_attach(client, bufnr)

        if existing_on_attach then
          existing_on_attach(client, bufnr)
        end

        vim.keymap.set('n', '<leader>rr', function()
          vim.cmd.RustLsp 'runnables'
        end, { buffer = bufnr, desc = 'Rust: Runnables' })

        vim.keymap.set('n', '<leader>rh', function()
          vim.cmd.RustLsp { 'hover', 'actions' }
        end, { buffer = bufnr, desc = 'Rust: Hover Actions' })
      end

      rustacean.server = vim.tbl_deep_extend('force', rustacean.server or {}, {
        on_attach = rust_on_attach,
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
      })

      vim.g.rustaceanvim = rustacean
    end,
  },
}
