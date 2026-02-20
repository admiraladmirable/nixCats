local colorschemeName = nixCats 'colorscheme'
if not require('nixCatsUtils').isNixCats then
  colorschemeName = 'catppuccin-frappe'
end
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
vim.cmd.colorscheme(colorschemeName)

local ok, notify = pcall(require, 'notify')
if ok then
  notify.setup {
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  }
  vim.notify = notify
  vim.keymap.set('n', '<Esc>', function()
    notify.dismiss { silent = true }
  end, { desc = 'dismiss notify popup and clear hlsearch' })
end

-- NOTE: you can check if you included the category with the thing wherever you want.
if nixCats 'general.extra' then
  -- I didn't want to bother with lazy loading this.
  -- I could put it in opt and put it in a spec anyway
  -- and then not set any handlers and it would load at startup,
  -- but why... I guess I could make it load
  -- after the other lze definitions in the next call using priority value?
  -- didn't seem necessary.
  vim.g.loaded_netrwPlugin = 1
  require('oil').setup {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    columns = {
      'icon',
      'permissions',
      'size',
      -- "mtime",
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-s>'] = 'actions.select_vsplit',
      ['<C-h>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-l>'] = 'actions.refresh',
      ['-'] = 'actions.parent',
      ['_'] = 'actions.open_cwd',
      ['`'] = 'actions.cd',
      ['~'] = 'actions.tcd',
      ['gs'] = 'actions.change_sort',
      ['gx'] = 'actions.open_external',
      ['g.'] = 'actions.toggle_hidden',
      ['g\\'] = 'actions.toggle_trash',
    },
  }
  vim.keymap.set('n', '-', '<cmd>Oil<CR>', { noremap = true, desc = 'Open Parent Directory' })
  vim.keymap.set('n', '<leader>-', '<cmd>Oil .<CR>', { noremap = true, desc = 'Open nvim root directory' })
end

require('lze').load {
  { import = 'myLuaConf.plugins.telescope' },
  { import = 'myLuaConf.plugins.treesitter' },
  { import = 'myLuaConf.plugins.completion' },
  { import = 'myLuaConf.plugins.rust' },
  { import = 'myLuaConf.plugins.ui.edgy' },
  { import = 'myLuaConf.plugins.ui.smear-cursor' },
  { import = 'myLuaConf.plugins.ui.bufferline' },
  { import = 'myLuaConf.plugins.ui.noice' },
  {
    'markdown-preview.nvim',
    -- NOTE: for_cat is a custom handler that just sets enabled value for us,
    -- based on result of nixCats('cat.name') and allows us to set a different default if we wish
    -- it is defined in luaUtils template in lua/nixCatsUtils/lzUtils.lua
    -- you could replace this with enabled = nixCats('cat.name') == true
    -- if you didn't care to set a different default for when not using nix than the default you already set
    for_cat = 'markdown',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    ft = 'markdown',
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview <CR>', mode = { 'n' }, noremap = true, desc = 'markdown preview' },
      {
        '<leader>ms',
        '<cmd>MarkdownPreviewStop <CR>',
        mode = { 'n' },
        noremap = true,
        desc = 'markdown preview stop',
      },
      {
        '<leader>mt',
        '<cmd>MarkdownPreviewToggle <CR>',
        mode = { 'n' },
        noremap = true,
        desc = 'markdown preview toggle',
      },
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    'undotree',
    for_cat = 'general.extra',
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus', 'UndotreePersistUndo' },
    keys = { { '<leader>U', '<cmd>UndotreeToggle<CR>', mode = { 'n' }, desc = 'Undo Tree' } },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    'comment.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    'indent-blankline.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('ibl').setup()
    end,
  },
  {
    'nvim-surround',
    for_cat = 'general.always',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    'vim-startuptime',
    for_cat = 'general.extra',
    cmd = { 'StartupTime' },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    'fidget.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('fidget').setup {}
    end,
  },
  {
    'snacks.nvim',
    for_cat = 'general.extra',
    priority = 1000,
    lazy = false,
    after = function(_)
      local snacks = require 'snacks'
      snacks.setup {
        bigfile = { enabled = true },
        terminal = { enabled = true },
        debug = { enabled = true },
        dashboard = {
          preset = {
            keys = {
              {
                icon = ' ',
                key = 'f',
                desc = 'Find File',
                action = ":lua Snacks.dashboard.pick('files')",
              },
              { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
              {
                icon = ' ',
                key = 'g',
                desc = 'Find Text',
                action = ":lua Snacks.dashboard.pick('live_grep')",
              },
              {
                icon = ' ',
                key = 'r',
                desc = 'Recent Files',
                action = ":lua Snacks.dashboard.pick('oldfiles')",
              },
              { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
              { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
            },
          },
          sections = {
            { section = 'header' },
            { section = 'keys', gap = 1, padding = 1 },
          },
        },
        dim = { enabled = true },
        explorer = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        picker = {
          enabled = true,
          actions = {
            explorer_paste = function(picker)
              local reg = vim.v.register or '+'
              local paths = vim.split(vim.fn.getreg(reg) or '', '\n', { plain = true })
              local uv = vim.uv or vim.loop
              paths = vim.tbl_filter(function(path)
                return path ~= '' and uv.fs_stat(path) ~= nil
              end, paths)

              if #paths == 0 then
                return snacks.notify.warn(('The `%s` register does not contain any files'):format(reg))
              end

              local dir = picker:dir()
              local tree = require 'snacks.explorer.tree'
              local util = snacks.picker.util
              local copied = 0
              local skipped = 0

              local function finalize()
                tree:refresh(dir)
                tree:open(dir)
                picker:find()
                local msg = ('Copied %d path(s)'):format(copied)
                if skipped > 0 then
                  msg = msg .. (', skipped %d'):format(skipped)
                end
                snacks.notify.info(msg)
              end

              local function is_valid_name(name)
                return name ~= '' and name ~= '.' and name ~= '..' and not name:find('/', 1, true)
              end

              local copy_one
              local copy_with_name

              copy_with_name = function(src, name, next_fn)
                local to = dir .. '/' .. name
                if uv.fs_stat(to) == nil then
                  util.copy_path(src, to)
                  copied = copied + 1
                  return next_fn()
                end

                snacks.input({
                  prompt = ('%s already exists. Rename copy to (empty to skip):'):format(name),
                }, function(value)
                  if value == nil or vim.trim(value) == '' then
                    skipped = skipped + 1
                    return next_fn()
                  end
                  value = vim.trim(value)
                  if not is_valid_name(value) then
                    snacks.notify.warn 'Please provide a file/folder name without `/`'
                    return copy_with_name(src, name, next_fn)
                  end
                  return copy_with_name(src, value, next_fn)
                end)
              end

              copy_one = function(i)
                local src = paths[i]
                if not src then
                  return finalize()
                end
                local name = vim.fn.fnamemodify(src, ':t')
                copy_with_name(src, name, function()
                  copy_one(i + 1)
                end)
              end

              copy_one(1)
            end,
          },
        },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = {
          enabled = true,
          animate = {
            duration = { step = 5, total = 50 },
            easing = 'linear',
          },
          -- faster animation when repeating scroll after delay
          animate_repeat = {
            delay = 100, -- delay in ms before using the repeat animation
            duration = { step = 5, total = 5 },
            easing = 'linear',
          },
          -- what buffers to animate
          filter = function(buf)
            return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= 'terminal'
          end,
        },
        statuscolumn = { enabled = true },
        toggle = { enabled = true },
        words = { enabled = true },
      }

      _G.dd = function(...)
        snacks.debug.inspect(...)
      end
      _G.bt = function()
        snacks.debug.backtrace()
      end

      if vim.fn.has 'nvim-0.11' == 1 then
        vim._print = function(_, ...)
          dd(...)
        end
      else
        vim.print = _G.dd
      end

      snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
      snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
      snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
      snacks.toggle.diagnostics():map '<leader>ud'
      snacks.toggle.line_number():map '<leader>ul'
      snacks.toggle
        .option('conceallevel', {
          off = 0,
          on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
        })
        :map '<leader>uc'
      snacks.toggle.treesitter():map '<leader>uT'
      snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
      snacks.toggle.inlay_hints():map '<leader>uh'
      snacks.toggle.indent():map '<leader>ug'
      snacks.toggle.dim():map '<leader>uD'
    end,
    keys = {
      -- Top Pickers & Explorer
      {
        '<leader><space>',
        function()
          Snacks.picker.smart()
        end,
        desc = 'Smart Find Files',
      },
      {
        '<leader>,',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.grep()
        end,
        desc = 'Grep',
      },
      {
        '<leader>:',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'Command History',
      },
      {
        '<leader>n',
        function()
          Snacks.picker.notifications()
        end,
        desc = 'Notification History',
      },
      {
        '<leader>e',
        function()
          Snacks.explorer()
        end,
        desc = 'File Explorer',
      },
      -- find
      {
        '<leader>fb',
        function()
          Snacks.picker.buffers()
        end,
        desc = 'Buffers',
      },
      {
        '<leader>fc',
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = 'Find Config File',
      },
      {
        '<leader>ff',
        function()
          Snacks.picker.files()
        end,
        desc = 'Find Files',
      },
      {
        '<leader>fg',
        function()
          Snacks.picker.git_files()
        end,
        desc = 'Find Git Files',
      },
      {
        '<leader>fp',
        function()
          Snacks.picker.projects()
        end,
        desc = 'Projects',
      },
      {
        '<leader>fr',
        function()
          Snacks.picker.recent()
        end,
        desc = 'Recent',
      },
      -- git
      {
        '<leader>gb',
        function()
          Snacks.picker.git_branches()
        end,
        desc = 'Git Branches',
      },
      {
        '<leader>gl',
        function()
          Snacks.picker.git_log()
        end,
        desc = 'Git Log',
      },
      {
        '<leader>gL',
        function()
          Snacks.picker.git_log_line()
        end,
        desc = 'Git Log Line',
      },
      {
        '<leader>gs',
        function()
          Snacks.picker.git_status()
        end,
        desc = 'Git Status',
      },
      {
        '<leader>gS',
        function()
          Snacks.picker.git_stash()
        end,
        desc = 'Git Stash',
      },
      {
        '<leader>gd',
        function()
          Snacks.picker.git_diff()
        end,
        desc = 'Git Diff (Hunks)',
      },
      {
        '<leader>gf',
        function()
          Snacks.picker.git_log_file()
        end,
        desc = 'Git Log File',
      },
      -- Grep
      {
        '<leader>sb',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>sB',
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = 'Grep Open Buffers',
      },
      {
        '<leader>sg',
        function()
          Snacks.picker.grep()
        end,
        desc = 'Grep',
      },
      {
        '<leader>sw',
        function()
          Snacks.picker.grep_word()
        end,
        desc = 'Visual selection or word',
        mode = { 'n', 'x' },
      },
      -- search
      {
        '<leader>s"',
        function()
          Snacks.picker.registers()
        end,
        desc = 'Registers',
      },
      {
        '<leader>s/',
        function()
          Snacks.picker.search_history()
        end,
        desc = 'Search History',
      },
      {
        '<leader>sa',
        function()
          Snacks.picker.autocmds()
        end,
        desc = 'Autocmds',
      },
      {
        '<leader>sb',
        function()
          Snacks.picker.lines()
        end,
        desc = 'Buffer Lines',
      },
      {
        '<leader>sc',
        function()
          Snacks.picker.command_history()
        end,
        desc = 'Command History',
      },
      {
        '<leader>sC',
        function()
          Snacks.picker.commands()
        end,
        desc = 'Commands',
      },
      {
        '<leader>sd',
        function()
          Snacks.picker.diagnostics()
        end,
        desc = 'Diagnostics',
      },
      {
        '<leader>sD',
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = 'Buffer Diagnostics',
      },
      {
        '<leader>sh',
        function()
          Snacks.picker.help()
        end,
        desc = 'Help Pages',
      },
      {
        '<leader>sH',
        function()
          Snacks.picker.highlights()
        end,
        desc = 'Highlights',
      },
      {
        '<leader>si',
        function()
          Snacks.picker.icons()
        end,
        desc = 'Icons',
      },
      {
        '<leader>sj',
        function()
          Snacks.picker.jumps()
        end,
        desc = 'Jumps',
      },
      {
        '<leader>sk',
        function()
          Snacks.picker.keymaps()
        end,
        desc = 'Keymaps',
      },
      {
        '<leader>sl',
        function()
          Snacks.picker.loclist()
        end,
        desc = 'Location List',
      },
      {
        '<leader>sm',
        function()
          Snacks.picker.marks()
        end,
        desc = 'Marks',
      },
      {
        '<leader>sM',
        function()
          Snacks.picker.man()
        end,
        desc = 'Man Pages',
      },
      {
        '<leader>sp',
        function()
          Snacks.picker.lazy()
        end,
        desc = 'Search for Plugin Spec',
      },
      {
        '<leader>sq',
        function()
          Snacks.picker.qflist()
        end,
        desc = 'Quickfix List',
      },
      {
        '<leader>sR',
        function()
          Snacks.picker.resume()
        end,
        desc = 'Resume',
      },
      {
        '<leader>su',
        function()
          Snacks.picker.undo()
        end,
        desc = 'Undo History',
      },
      {
        '<leader>uC',
        function()
          Snacks.picker.colorschemes()
        end,
        desc = 'Colorschemes',
      },
      -- LSP
      {
        'gd',
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = 'Goto Definition',
      },
      {
        'gD',
        function()
          Snacks.picker.lsp_declarations()
        end,
        desc = 'Goto Declaration',
      },
      {
        'gr',
        function()
          Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = 'References',
      },
      {
        'gI',
        function()
          Snacks.picker.lsp_implementations()
        end,
        desc = 'Goto Implementation',
      },
      {
        'gy',
        function()
          Snacks.picker.lsp_type_definitions()
        end,
        desc = 'Goto T[y]pe Definition',
      },
      {
        '<leader>ss',
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = 'LSP Symbols',
      },
      {
        '<leader>sS',
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = 'LSP Workspace Symbols',
      },
      -- Other
      {
        '<leader>z',
        function()
          Snacks.zen()
        end,
        desc = 'Toggle Zen Mode',
      },
      {
        '<leader>Z',
        function()
          Snacks.zen.zoom()
        end,
        desc = 'Toggle Zoom',
      },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>n',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Notification History',
      },
      {
        '<leader>bd',
        function()
          Snacks.bufdelete()
        end,
        desc = 'Delete Buffer',
      },
      {
        '<leader>cR',
        function()
          Snacks.rename.rename_file()
        end,
        desc = 'Rename File',
      },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Git Browse',
        mode = { 'n', 'v' },
      },
      {
        '<leader>gg',
        function()
          Snacks.lazygit()
        end,
        desc = 'Lazygit',
      },
      {
        '<leader>un',
        function()
          Snacks.notifier.hide()
        end,
        desc = 'Dismiss All Notifications',
      },
      {
        '<c-/>',
        mode = { 'n', 't' },
        function()
          Snacks.terminal()
        end,
        desc = 'Toggle Terminal',
      },
      {
        '<c-_>',
        function()
          Snacks.terminal()
        end,
        desc = 'which_key_ignore',
      },
      {
        ']]',
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = 'Next Reference',
        mode = { 'n', 't' },
      },
      {
        '[[',
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = 'Prev Reference',
        mode = { 'n', 't' },
      },
      {
        '<leader>N',
        desc = 'Neovim News',
        function()
          Snacks.win {
            file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = 'yes',
              statuscolumn = ' ',
              conceallevel = 3,
            },
          }
        end,
      },
    },
  },
  {
    'todo-comments.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next Todo Comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous Todo Comment',
      },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
      { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
    },
    after = function(plugin)
      require('todo-comments').setup()
    end,
  },
  {
    'mini.align',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('mini.align').setup()
    end,
  },
  {
    'mini.cursorword',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('mini.cursorword').setup()
    end,
  },
  {
    'vim-highlighter',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    before = function(_)
      vim.g.HiMapKeys = 0
    end,
    after = function(_)
      local map = vim.keymap.set
      map('n', '<leader>hs', '<Cmd>Hi +<CR>', { desc = 'Highlighter Set' })
      map('x', '<leader>hs', '<Cmd>Hi +x<CR>', { desc = 'Highlighter Set' })
      map('n', '<leader>he', '<Cmd>Hi -<CR>', { desc = 'Highlighter Erase' })
      map('x', '<leader>he', '<Cmd>Hi -x<CR>', { desc = 'Highlighter Erase' })
      map('n', '<leader>hc', '<Cmd>Hi clear<CR>', { desc = 'Highlighter Clear' })
      map('n', '<leader>h/', '<Cmd>Hi /<CR>', { desc = 'Highlighter Find' })
      map('x', '<leader>h/', '<Cmd>Hi /x<CR>', { desc = 'Highlighter Find' })
      map('n', '<leader>hS', '<Cmd>Hi +%<CR>', { desc = 'Highlighter Set Line' })
      map('x', '<leader>hS', '<Cmd>Hi +x%<CR>', { desc = 'Highlighter Set Line' })
    end,
  },
  {
    'mini.icons',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      local icons = require 'mini.icons'
      icons.setup()
      if icons.mock_nvim_web_devicons then
        icons.mock_nvim_web_devicons()
      end
    end,
  },
  {
    'mini.ai',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('mini.ai').setup()
    end,
  },
  {
    'mini.pairs',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('mini.pairs').setup()
    end,
  },
  {
    'flash.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('flash').setup()
    end,
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
  {
    'render-markdown.nvim',
    for_cat = 'markdown',
    event = 'DeferredUIEnter',
    after = function(_)
      require('render-markdown').setup()
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    keys = {
      {
        '<leader>sr',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },

    -- after = function(_)
    --         require('grug-far').setup();
    -- end,
  },

  -- {
  --   "hlargs",
  --   for_cat = 'general.extra',
  --   event = "DeferredUIEnter",
  --   -- keys = "",
  --   dep_of = { "nvim-lspconfig" },
  --   after = function(plugin)
  --     require('hlargs').setup {
  --       color = '#32a88f',
  --     }
  --     vim.cmd([[hi clear @lsp.type.parameter]])
  --     vim.cmd([[hi link @lsp.type.parameter Hlargs]])
  --   end,
  -- },
  {
    'lualine.nvim',
    for_cat = 'general.always',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = colorschemeName,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,
              status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename',
              path = 3,
              status = true,
            },
          },
          lualine_x = { 'filetype' },
        },
        -- tabline = {
        --   lualine_a = { 'buffers' },
        --   -- if you use lualine-lsp-progress, I have mine here instead of fidget
        --   -- lualine_b = { 'lsp_progress', },
        --   lualine_z = { 'tabs' },
        -- },
      }
    end,
  },
  {
    'gitsigns.nvim',
    for_cat = 'general.always',
    event = 'DeferredUIEnter',
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('gitsigns').setup {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
        signs_staged = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      }
      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
  {
    'which-key.nvim',
    for_cat = 'general.extra',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('which-key').setup {}
      require('which-key').add {
        { '<leader><leader>', group = 'buffer commands' },
        { '<leader><leader>_', hidden = true },
        { '<leader>c', group = '[c]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[d]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>g', group = '[g]it' },
        { '<leader>g_', hidden = true },
        { '<leader>h', group = '[h]ighlighter', icon = '󰛨' },
        { '<leader>h_', hidden = true },
        { '<leader>hs', desc = 'Set highlight', mode = { 'n', 'x' } },
        { '<leader>he', desc = 'Erase highlight', mode = { 'n', 'x' } },
        { '<leader>hc', desc = 'Clear highlights', mode = 'n' },
        { '<leader>h/', desc = 'Find in files', mode = { 'n', 'x' } },
        { '<leader>hS', desc = 'Set line highlight', mode = { 'n', 'x' } },
        { '<leader>m', group = '[m]arkdown' },
        { '<leader>m_', hidden = true },
        { '<leader>r', group = '[r]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[s]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[t]oggles' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>w_', hidden = true },
      }
    end,
  },
  {
    'crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
  {
    'trouble.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(_, opts)
      require('trouble').setup {}
      local actions = require 'telescope.actions'
      local open_with_trouble = require('trouble.sources.telescope').open

      -- Use this to add more results without clearing the trouble list
      local add_to_trouble = require('trouble.sources.telescope').add

      local telescope = require 'telescope'

      telescope.setup {
        defaults = {
          mappings = {
            i = { ['<c-t>'] = open_with_trouble },
            n = { ['<c-t>'] = open_with_trouble },
          },
        },
      }
    end,
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
}
