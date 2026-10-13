require('lze').load {
  {
    'nvim-lint',
    for_cat = 'lint',
    event = 'FileType',
    after = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint-cli2' },
        ghaction = { 'actionlint' },
        ['yaml.github'] = { 'actionlint' },
        ['yaml.gha'] = { 'actionlint' },
        make = { 'checkmake' },
        gitcommit = { 'commitlint' },
        dockerfile = { 'hadolint' },
        terraform = { 'terraform_validate' },
        tf = { 'terraform_validate' },
        yaml = { 'yamllint' },
        sh = { 'bash' },
        bash = { 'bash' },
        lua = { 'luacheck' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        nix = { 'nix' },
      }

      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('myLuaConfLint', { clear = true }),
        callback = function(event)
          vim.api.nvim_buf_call(event.buf, function()
            -- Workflows normally use the plain yaml filetype.
            local path = vim.fs.normalize(vim.api.nvim_buf_get_name(event.buf))            if vim.bo.filetype == 'yaml' and path:match('/%.github/workflows/[^/]+%.ya?ml$') then
              lint.try_lint { 'yamllint', 'actionlint' }
            else
              lint.try_lint()
            end
          end)
        end,
      })
    end,
  },
}
