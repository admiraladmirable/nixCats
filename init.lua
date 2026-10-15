-- Dependencies are packaged by nix-wrapper-modules; plugin setup stays in Lua.
-- The local adapter preserves category checks using the wrapper's info plugin.
require('nixCatsUtils').setup {
  non_nix_value = true,
}

-- Paq installs dependencies only when this directory is loaded without Nix.
-- Keep its URLs/build steps in sync with module.nix.
require 'myLuaConf.non_nix_download'
require 'myLuaConf'
