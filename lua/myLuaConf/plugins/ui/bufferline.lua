local diag_icons = {
  Error = ' ',
  Warn = ' ',
  Info = ' ',
  Hint = ' ',
}

local devicons = nil
do
  local ok, mod = pcall(require, 'nvim-web-devicons')
  if ok then
    devicons = mod
  end
end

local function diagnostics_indicator(_, _, diag)
  local parts = {}
  if diag.error and diag.error > 0 then
    table.insert(parts, diag_icons.Error .. diag.error)
  end
  if diag.warning and diag.warning > 0 then
    table.insert(parts, diag_icons.Warn .. diag.warning)
  end
  if diag.info and diag.info > 0 then
    table.insert(parts, diag_icons.Info .. diag.info)
  end
  if diag.hint and diag.hint > 0 then
    table.insert(parts, diag_icons.Hint .. diag.hint)
  end
  return table.concat(parts, ' ')
end

local function filetype_icon(ft)
  if devicons and ft then
    local icon = devicons.get_icon_by_filetype(ft, { default = true })
    if icon then
      return icon
    end
  end
  return ''
end

return {
  {
    'nvim-web-devicons',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    dep_of = { 'bufferline-nvim' },
    after = function()
      require('nvim-web-devicons').setup {}
    end,
  },
  {
    'bufferline-nvim',
    for_cat = { cat = 'general', default = true },
    event = 'DeferredUIEnter',
    keys = {
      { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
      { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
      { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
      { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
      { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
      { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
      { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
    },
    after = function()
      require('bufferline').setup {
        options = {
          close_command = function(bufnr)
            Snacks.bufdelete(bufnr)
          end,
          right_mouse_command = function(bufnr)
            Snacks.bufdelete(bufnr)
          end,
          diagnostics = 'nvim_lsp',
          always_show_bufferline = false,
          separator_style = 'slant',
          diagnostics_indicator = diagnostics_indicator,
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Neo-tree',
              highlight = 'Directory',
              text_align = 'left',
            },
            {
              filetype = 'snacks_layout_box',
            },
          },
          ---@param opts bufferline.IconFetcherOpts
          get_element_icon = function(opts)
            return filetype_icon(opts.filetype)
          end,
        },
      }

      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
}
