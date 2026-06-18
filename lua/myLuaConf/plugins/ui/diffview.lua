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
        require('telescope.builtin').find_files {
          prompt_title = left and 'Right diff file' or 'Left diff file',
          attach_mappings = function(prompt_bufnr)
            local actions = require 'telescope.actions'
            local state = require 'telescope.actions.state'

            actions.select_default:replace(function()
              local entry = state.get_selected_entry()
              actions.close(prompt_bufnr)

              local path = entry.path or entry.filename or entry[1]
              if left then
                vim.cmd(
                  'DiffviewDiffFiles '
                    .. vim.fn.fnameescape(left)
                    .. ' '
                    .. vim.fn.fnameescape(path)
                )
              else
                diff_two_files(path)
              end
            end)

            return true
          end,
        }
      end

      -- git-backed views
      map('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open (working tree)' })
      map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })
      map('n', '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
      map('n', '<leader>dH', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (repo)' })
      -- arbitrary on-disk diffs (no VCS needed)
      if nixCats('general.telescope') then
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
