-- Run inside the packaged editor after its normal init.lua.
local ok, err = pcall(function()
  assert(vim.v.errmsg == '', vim.v.errmsg)
  assert(vim.g.nix_info_plugin_name, 'wrapper info plugin missing')
  assert(require('nixCatsUtils').isNixCats, 'Nix detection failed')
  assert(package.loaded.paq == nil, 'non-Nix downloader ran under Nix')
  assert(nixCats('general.telescope') == true)
  assert(nixCats({ 'debug', 'go' }) == true)
  assert(nixCats('missing') == false)
  assert(nixCats('lspDebugMode') == false)
  assert(nixCats('colorscheme') == 'catppuccin-frappe')
  assert(vim.env.NVIM_APPNAME == 'nixCats-nvim')
  assert(nixCats.extra('nixdExtras.nixpkgs'):match('^import /nix/store/'))
  assert(vim.fn.isdirectory(nixCats.pawsible({ 'allPlugins', 'opt', 'nvim-lspconfig' })) == 1)
  assert(vim.fn.executable(nixCats.packageBinPath) == 1)
  for _, tool in ipairs({ 'nixd', 'gopls', 'rust-analyzer', 'stylua', 'codelldb', 'gh' }) do
    assert(vim.fn.executable(tool) == 1, tool .. ' is missing')
  end

  -- Exercise LZE loaders instead of merely checking that plugin files exist.
  for _, plugin in ipairs({ 'conform.nvim', 'nvim-lint', 'telescope.nvim', 'nvim-dap' }) do
    require('lze').trigger_load(plugin)
  end
  assert(type(require('conform').format) == 'function')
  assert(type(require('lint').try_lint) == 'function')
  assert(type(require('telescope.builtin').find_files) == 'function')
  assert(type(require('dap').continue) == 'function')
  assert(vim.v.errmsg == '', vim.v.errmsg)

  -- Edgy must not undo manual resizing of Snacks terminal splits.
  require('lze').trigger_load('edgy')
  local terminal = Snacks.win({ style = 'terminal', position = 'bottom', height = 0.4 })
  vim.wait(300)
  local height = vim.api.nvim_win_get_height(terminal.win)
  vim.api.nvim_win_set_height(terminal.win, height + 3)
  local resized_height = vim.api.nvim_win_get_height(terminal.win)
  assert(resized_height ~= height, 'terminal split did not resize')
  vim.api.nvim_exec_autocmds('WinResized', {})
  vim.wait(500)
  local final_height = vim.api.nvim_win_get_height(terminal.win)
  terminal:close()
  assert(final_height == resized_height, 'terminal split snapped back after resizing')

  -- Exercise a formatter using a real buffer and the packaged executable.
  vim.cmd.enew()
  vim.bo.filetype = 'lua'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'local value={answer=42}' })
  require('conform').format({ formatters = { 'stylua' }, timeout_ms = 10000 })
  local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  assert(line:match('answer = 42'), 'stylua did not format the buffer: ' .. line)
end)
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd.cquit(1)
else
  print('Wrapper startup, categories, tools, lazy loading, terminal resizing, and formatting passed')
  vim.cmd('qa!')
end
