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
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = 'never',
                },
                lifetimeElisionHints = {
                  enable = 'never',
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = 'never',
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        },
      }, vim.g.rustaceanvim or {})

      vim.g.rustaceanvim = rustacean
    end,
  },
}
