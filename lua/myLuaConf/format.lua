require('lze').load {
  {
    'conform.nvim',
    for_cat = 'format',
    -- cmd = { "" },
    event = { 'BufReadPost', 'BufNewFile' },
    -- ft = "",
    keys = {
      { '<leader>FF', desc = '[F]ormat [F]ile' },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require 'conform'

      conform.setup {
        format_on_save = {
          -- These options will be passed to conform.format()
          timeout_ms = 500,
          lsp_format = 'fallback',
        },
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
          ['*'] = { 'codespell' },
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

      vim.keymap.set({ 'n', 'v' }, '<leader>FF', function()
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        }
      end, { desc = '[F]ormat [F]ile' })
    end,
  },
}
