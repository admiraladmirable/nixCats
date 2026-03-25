require('lze').load {
  {
    'neotest',
    for_cat = { cat = 'debug', default = false },
    keys = {
      { '<leader>tt', desc = 'Neotest: Run nearest test' },
      { '<leader>tf', desc = 'Neotest: Run file' },
      { '<leader>ts', desc = 'Neotest: Toggle summary' },
      { '<leader>to', desc = 'Neotest: Show output' },
      { '<leader>tp', desc = 'Neotest: Toggle output panel' },
      { '<leader>tl', desc = 'Neotest: Run last test' },
      { '<leader>tw', desc = 'Neotest: Toggle watch' },
    },
    load = function(name)
      vim.cmd.packadd(name)
      if nixCats('debug.go') then
        vim.cmd.packadd('neotest-go')
      end
      if nixCats('debug.rust') then
        vim.cmd.packadd('neotest-rust')
      end
    end,
    after = function(_)
      local neotest = require('neotest')

      local adapters = {}
      if nixCats('debug.go') then
        table.insert(adapters, require('neotest-go'))
      end
      if nixCats('debug.rust') then
        table.insert(adapters, require('neotest-rust'))
      end

      neotest.setup {
        adapters = adapters,
      }

      vim.keymap.set('n', '<leader>tt', function() neotest.run.run() end, { desc = 'Neotest: Run nearest test' })
      vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end, { desc = 'Neotest: Run file' })
      vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = 'Neotest: Toggle summary' })
      vim.keymap.set('n', '<leader>to', function() neotest.output.open({ enter = true }) end, { desc = 'Neotest: Show output' })
      vim.keymap.set('n', '<leader>tp', function() neotest.output_panel.toggle() end, { desc = 'Neotest: Toggle output panel' })
      vim.keymap.set('n', '<leader>tl', function() neotest.run.run_last() end, { desc = 'Neotest: Run last test' })
      vim.keymap.set('n', '<leader>tw', function() neotest.watch.toggle(vim.fn.expand('%')) end, { desc = 'Neotest: Toggle watch' })
    end,
  },
}
