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
      local function diff_two_files(left)
        local snacks = require 'snacks'
        snacks.picker.files {
          title = left and 'Right diff file' or 'Left diff file',
          confirm = function(picker, item)
            picker:close()
            local path = snacks.picker.util.path(item)
            if not path then
              return
            end

            if left then
              vim.cmd(
                'DiffviewDiffFiles '
                  .. vim.fn.fnameescape(left)
                  .. ' '
                  .. vim.fn.fnameescape(path)
              )
            else
              vim.schedule(function()
                diff_two_files(path)
              end)
            end
          end,
        }
      end

      -- git-backed views
      map('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open (working tree)' })
      map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })
      map('n', '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
      map('n', '<leader>dH', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (repo)' })
      -- arbitrary on-disk diffs (no VCS needed)
      if nixCats('general.extra') then
        map('n', '<leader>df', function()
          diff_two_files()
        end, { desc = 'Diff two files' })
      else
        map('n', '<leader>df', ':DiffviewDiffFiles ', { desc = 'Diff two files' })
      end
      map('n', '<leader>dD', ':DiffviewDiffDirs ', { desc = 'Diff two directories' })
    end,
  },
}
