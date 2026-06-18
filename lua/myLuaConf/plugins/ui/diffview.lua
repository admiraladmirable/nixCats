return {
  {
    'diffview',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    after = function(plugin, opts)
      require('diffview').setup {
        enhanced_diff_hl = true,
        diffopt = { algorithm = 'histogram' },
      }

      local map = vim.keymap.set
      -- git-backed views
      map('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open (working tree)' })
      map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })
      map('n', '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
      map('n', '<leader>dH', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (repo)' })
      -- arbitrary on-disk diffs (no VCS needed) -- cmdline stays open for paths
      map('n', '<leader>df', ':DiffviewDiffFiles ', { desc = 'Diff two files' })
      map('n', '<leader>dD', ':DiffviewDiffDirs ', { desc = 'Diff two directories' })
    end,
  },
}
