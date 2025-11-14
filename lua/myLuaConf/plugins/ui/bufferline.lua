local diag_icons = {
  Error = ' ',
  Warn = ' ',
  Info = ' ',
  Hint = ' ',
}

local function safe_require(modname)
  local ok, mod = pcall(require, modname)
  if ok then
    return mod
  end
end

local devicons = safe_require('nvim-web-devicons')
local mini_icons = safe_require('mini.icons')

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

local function icon_from_snacks(opts)
  local snacks = rawget(_G, 'Snacks')
  local util = snacks and snacks.util
  local icon_fn = util and util.icon
  if not icon_fn or not opts then
    return nil
  end

  local lookups = {}
  local path = opts.path or opts.absolute_path or opts.filename
  if path and path ~= '' then
    table.insert(lookups, { path, 'file' })
  end
  if opts.filetype and opts.filetype ~= '' then
    table.insert(lookups, { opts.filetype, 'filetype' })
  end

  for _, lookup in ipairs(lookups) do
    local ok, icon = pcall(icon_fn, lookup[1], lookup[2])
    if ok and type(icon) == 'string' and icon ~= '' then
      return icon
    end
  end
end

local function icon_from_mini(opts)
  if not mini_icons then
    return nil
  end

  local sources = {}
  if opts.filetype and opts.filetype ~= '' then
    table.insert(sources, { 'filetype', opts.filetype })
  end
  local path = opts.path or opts.absolute_path or opts.filename
  if path and path ~= '' then
    table.insert(sources, { 'file', path })
  elseif opts.extension and opts.extension ~= '' then
    table.insert(sources, { 'extension', opts.extension })
  end

  for _, source in ipairs(sources) do
    local ok, glyph = pcall(mini_icons.get, source[1], source[2])
    if ok then
      local icon = glyph
      if type(glyph) == 'table' then
        icon = glyph[1] or glyph.icon or glyph.glyph
      end
      if type(icon) == 'string' and icon ~= '' then
        return icon
      end
    end
  end
end

local function icon_from_devicons(ft)
  if not devicons or not ft then
    return nil
  end
  local ok, icon = pcall(devicons.get_icon_by_filetype, ft, { default = true })
  if ok and icon then
    return icon
  end
end

local function filetype_icon(opts)
  return icon_from_snacks(opts) or icon_from_mini(opts) or icon_from_devicons(opts.filetype) or ''
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
            return filetype_icon(opts)
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
