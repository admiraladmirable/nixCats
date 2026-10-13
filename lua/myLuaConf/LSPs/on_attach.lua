return function(_, bufnr)
  local already_attached = pcall(vim.api.nvim_buf_get_var, bufnr, 'myLuaConf_lsp_attached')
  if already_attached then
    return
  end

  vim.api.nvim_buf_set_var(bufnr, 'myLuaConf_lsp_attached', true)

  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  -- Keep navigation buffer-local so LspAttach cannot shadow a different picker.
  local function picker(source, fallback)
    return function()
      if nixCats 'general.extra' then
        require('snacks').picker[source]()
      else
        fallback()
      end
    end
  end

  -- Neovim defaults (:help lsp-defaults), with Snacks for result lists.
  nmap('grn', vim.lsp.buf.rename, 'Rename')
  vim.keymap.set({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, {
    buffer = bufnr,
    desc = 'LSP: Code Action',
  })
  nmap('grr', picker('lsp_references', vim.lsp.buf.references), 'References')
  nmap('gri', picker('lsp_implementations', vim.lsp.buf.implementation), 'Goto Implementation')
  nmap('grt', picker('lsp_type_definitions', vim.lsp.buf.type_definition), 'Goto Type Definition')
  nmap('gO', picker('lsp_symbols', vim.lsp.buf.document_symbol), 'Document Symbols')

  -- Additional navigation shortcuts; Neovim also provides CTRL-] via tagfunc.
  nmap('gd', picker('lsp_definitions', vim.lsp.buf.definition), 'Goto Definition')
  nmap('gD', picker('lsp_declarations', vim.lsp.buf.declaration), 'Goto Declaration')
  nmap('<leader>ss', picker('lsp_symbols', vim.lsp.buf.document_symbol), 'Document Symbols')
  nmap('<leader>sS', picker('lsp_workspace_symbols', vim.lsp.buf.workspace_symbol), 'Workspace Symbols')
  nmap('<leader>ws', picker('lsp_workspace_symbols', vim.lsp.buf.workspace_symbol), 'Workspace Symbols')

  -- Keep the native K hover and insert-mode CTRL-S signature-help defaults.
  -- Lesser used LSP functionality
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Conform owns :Format when enabled, including buffers without an LSP.
  if not nixCats 'format' then
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end
end
