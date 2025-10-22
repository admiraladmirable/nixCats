return {
  {
    'rustaceanvim',
    version = '^6',
    for_cat = { cat = 'general', default = true },
    ft = { 'rust' },
    before = function()
      local rustacean = vim.tbl_deep_extend('force', {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
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
      }, vim.g.rustaceanvim or {})

      vim.g.rustaceanvim = rustacean
    end,
  },
}
