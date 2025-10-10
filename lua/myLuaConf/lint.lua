require('lze').load {
  {
    "nvim-lint",
    for_cat = 'lint',
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)
      require('lint').linters_by_ft = {
        -- NOTE: download some linters in lspsAndRuntimeDeps
        -- and configure them here
        -- General
        markdown = {'markdownlint-cli2',},
        actionlint = {'actionlint'},
        checkmate = {'checkmate'},
        commitlint = {'commitlint'},

        -- DevOps
        dockerfile = {'hadolint'},
        hcl = { 'packer_fmt' },
        terraform = { 'terraform_validate' },
        tf = { 'terraform_validate' },

        bash = {'bash'},
        lua = { 'stylua' },
        rust = { 'rustfmt', lsp_format = 'fallback' },
        json = { 'fixjson' },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        scss = { 'prettierd', 'prettier', stop_after_first = true },
        less = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        nix = { 'nixfmt-rfc-style' },
        ['_'] = { 'trim_whitespace' },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
