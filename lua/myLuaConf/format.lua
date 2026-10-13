require('lze').load {
  {
    'conform.nvim',
    for_cat = 'format',
    cmd = { 'Format', 'FormatToggle', 'FormatToggleBuffer', 'FormatSpelling', 'YamlSortKeys' },
    event = { 'BufReadPost', 'BufNewFile' },
    -- ft = "",
    keys = {
      { '<leader>FF', mode = { 'n', 'x' }, desc = '[F]ormat [F]ile' },
      { '<leader>uf', '<cmd>FormatToggle<CR>', desc = 'Toggle Format on Save (Global)' },
      { '<leader>uF', '<cmd>FormatToggleBuffer<CR>', desc = 'Toggle Format on Save (Buffer)' },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require 'conform'

      conform.setup {
        default_format_opts = {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        },
        format_on_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 1000, lsp_format = 'fallback' }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          rust = { 'rustfmt', lsp_format = 'fallback' },
          json = { 'fixjson' },
          jsonl = { 'jq_jsonl' },
          jsonc = { 'prettierd', 'prettier', stop_after_first = true },
          yaml = { 'prettier' },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          scss = { 'prettierd', 'prettier', stop_after_first = true },
          less = { 'prettierd', 'prettier', stop_after_first = true },
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          terraform = { 'terraform_fmt' },
          ['terraform-vars'] = { 'terraform_fmt' },
          nix = { 'nixfmt' },
          go = { 'gofumpt' },
          ['_'] = { 'trim_whitespace' },
        },
        formatters = {
          jq_jsonl = {
            command = 'jq',
            args = { '-c' },
          },
        },
      }

      vim.api.nvim_create_user_command('YamlSortKeys', function()
        if vim.bo.filetype == 'helm' then
          vim.notify('YamlSortKeys expects valid YAML; Helm templates should be rendered first.', vim.log.levels.WARN)
          return
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local input = table.concat(lines, '\n')
        if input ~= '' then
          input = input .. '\n'
        end

        local result = vim.system({ 'yq', 'eval', 'sort_keys(..)', '-' }, {
          stdin = input,
          text = true,
        }):wait()

        if result.code ~= 0 then
          vim.notify(result.stderr ~= '' and result.stderr or 'Failed to sort YAML keys', vim.log.levels.ERROR)
          return
        end

        local output = result.stdout:gsub('\n$', '')
        local sorted = output == '' and {} or vim.split(output, '\n', { plain = true })
        vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted)
      end, { desc = 'Sort YAML mapping keys with yq' })

      vim.api.nvim_create_user_command('Format', function()
        conform.format()
      end, { desc = 'Format current buffer with Conform' })

      vim.api.nvim_create_user_command('FormatSpelling', function()
        conform.format { formatters = { 'codespell' }, lsp_format = 'never' }
      end, { desc = 'Explicitly apply spelling corrections with codespell' })

      local function toggle_format(scope, label)
        scope.disable_autoformat = not scope.disable_autoformat
        vim.notify(('Format on save (%s): %s'):format(label, scope.disable_autoformat and 'disabled' or 'enabled'))
      end
      vim.api.nvim_create_user_command('FormatToggle', function()
        toggle_format(vim.g, 'global')
      end, { desc = 'Toggle global format on save' })
      vim.api.nvim_create_user_command('FormatToggleBuffer', function()
        toggle_format(vim.b, 'buffer')
      end, { desc = 'Toggle buffer format on save' })

      vim.keymap.set({ 'n', 'x' }, '<leader>FF', function()
        conform.format()
      end, { desc = '[F]ormat [F]ile' })
    end,
  },
}
