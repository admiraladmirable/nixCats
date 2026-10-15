return {
  {
    'edgy',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    keys = {
      {
        '<leader>ue',
        function()
          require('edgy').toggle()
        end,
        desc = 'Edgy Toggle',
      },
      {
        '<leader>uE',
        function()
          require('edgy').select()
        end,
        desc = 'Edgy Select Window',
      },
    },
    after = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = 'screen'

      local opts = {
        bottom = {
          {
            ft = 'noice',
            size = { height = 0.4 },
            filter = function(_, win)
              return vim.api.nvim_win_get_config(win).relative == ''
            end,
          },
          { ft = 'qf', title = 'QuickFix' },
          {
            ft = 'help',
            size = { height = 20 },
            filter = function(buf)
              return vim.bo[buf].buftype == 'help'
            end,
          },
          { title = 'Neotest Output', ft = 'neotest-output-panel', size = { height = 15 } },
        },
        left = {
          { title = 'Neotest Summary', ft = 'neotest-summary' },
        },
        right = {
          { title = 'Grug Far', ft = 'grug-far', size = { width = 0.4 } },
        },
        keys = {
          ['<C-Right>'] = function(win)
            win:resize('width', 2)
          end,
          ['<C-Left>'] = function(win)
            win:resize('width', -2)
          end,
          ['<C-Up>'] = function(win)
            win:resize('height', 2)
          end,
          ['<C-Down>'] = function(win)
            win:resize('height', -2)
          end,
        },
      }

      -- Let Snacks manage terminal splits so mouse-dragged sizes are preserved.
      -- Edgy restores managed windows to their configured size on WinResized.
      for _, pos in ipairs { 'top', 'bottom', 'left', 'right' } do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = 'trouble',
          filter = function(_, win)
            local trouble = vim.w[win].trouble
            return trouble
              and trouble.position == pos
              and trouble.type == 'split'
              and trouble.relative == 'editor'
              and not vim.w[win].trouble_preview
          end,
        })
      end

      require('edgy').setup(opts)
    end,
  },
}
