-- Compatibility for this configuration's category-based Lua and non-Nix loader.
-- Nix data now comes from nix-wrapper-modules' generated info plugin.
local M = {}
M.isNixCats = vim.g.nix_info_plugin_name ~= nil

local function path_parts(path)
  return type(path) == 'table' and path or vim.split(path, '.', { plain = true })
end

local function callable_table(values)
  return setmetatable(values, {
    __call = function(self, path)
      return vim.tbl_get(self, unpack(path_parts(path)))
    end,
  })
end

function M.setup(opts)
  local default = not opts or opts.non_nix_value ~= false
  local info = M.isNixCats and require(vim.g.nix_info_plugin_name) or nil
  local settings = info and info.settings or {}
  local cats = settings.cats or {}

  local function get(path)
    if not info then
      return default
    end
    local key = table.concat(path_parts(path), '.')
    if key == 'colorscheme' or key == 'lspDebugMode' then
      return settings[key]
    end
    if cats[key] ~= nil then
      return cats[key]
    end
    -- Preserve nixCats' parent-boolean semantics for nested category queries.
    local parts = path_parts(path)
    while #parts > 1 do
      table.remove(parts)
      local parent = cats[table.concat(parts, '.')]
      if parent ~= nil then
        return parent
      end
    end
    return false
  end

  local config_dir = info and settings.config_directory or vim.fn.stdpath('config')
  local nc = {
    get = get,
    cats = callable_table(vim.deepcopy(cats)),
    settings = callable_table({
      nixCats_config_location = config_dir,
      configDirName = vim.env.NVIM_APPNAME or 'nvim',
      wrapRc = info ~= nil and config_dir:sub(1, 11) == '/nix/store/',
    }),
    extra = callable_table(info and info.info or {}),
    configDir = config_dir,
    packageBinPath = info and info.progpath or vim.v.progpath,
    nixCatsPath = config_dir,
    pawsible = callable_table({
      allPlugins = {
        start = info and info.plugins.start or {},
        opt = info and info.plugins.lazy or {},
      },
    }),
  }
  _G.nixCats = setmetatable(nc, { __call = function(_, path) return get(path) end })
  package.loaded.nixCats = _G.nixCats
end

function M.enableForCategory(path, default)
  if not M.isNixCats and default ~= nil then
    return default
  end
  return not not nixCats(path)
end

function M.getCatOrDefault(path, default)
  if M.isNixCats then
    return nixCats(path)
  end
  return default
end

function M.lazyAdd(non_nix, nix)
  if M.isNixCats then
    return nix
  end
  return non_nix
end

return M
