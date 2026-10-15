# Neovim with nix-wrapper-modules

This flake packages the Lua configuration in this repository using the
[nix-wrapper-modules Neovim template](https://github.com/nix-community/nix-wrapper-modules/tree/main/templates/neovim).
Nix installs plugins and runtime tools; Lua configures them and LZE controls lazy loading.

## Build and run

```sh
nix build .#nixCats
./result/bin/nixCats
nix run .#nixCats -- --headless '+q'
nix develop
nix flake check
```

`nix flake check` runs startup, category/tool availability, lazy-loading, formatting,
and non-Nix adapter regression checks on the current system.

The default package and `packages.<system>.nixCats` remain compatible with existing
consumers. The executable is still `nixCats`, with `vim` and `vimcat` aliases.
`NVIM_APPNAME=nixCats-nvim` preserves the existing data, cache, and state locations.

## Configuration

- `flake.nix`: inputs, packages, development shells, overlays, and install modules.
- `module.nix`: plugin/tool specs, colorscheme, hosts, and Nix-to-Lua metadata.
- `lua/myLuaConf/`: plugin setup, keymaps, language servers, formatting, linting, and debugging.
- `lua/nixCatsUtils/`: local compatibility adapter for existing Lua category checks.
  It reads the wrapper's generated info plugin; the nixCats framework is no longer a dependency.

Feature names such as `general.telescope` are literal spec names. Disable one with
`specs."general.telescope" = { ... }: { enable = false; };`. General subfeatures inherit
`specs.general.enable` by default; Go/Rust debugger specs also follow their
language and debug switches. Lua's `for_cat` handler reads the resulting enabled
specs. Select a theme with `settings.colorscheme`, and supply nixd expressions with
`info.nixdExtras`.

The non-Nix Paq/Mason bootstrap remains available through
`lua/myLuaConf/non_nix_download.lua`. Keep its plugin URLs/build steps synchronized
when adding dependencies; external tools must be installed separately outside Nix.

## Consumption from a NixOS or Home Manager flake

Existing package consumers need no change:

```nix
inputs.nixCats.url = "github:admiraladmirable/nixCats";
# In a Home Manager module receiving inputs:
home.packages = [ inputs.nixCats.packages.${pkgs.system}.default ];
```

For host-specific overrides, use the exported wrapper directly instead:

```nix
home.packages = [
  (inputs.nixCats.wrappers.neovim.wrap {
    inherit pkgs;
    specs."debug.rust" = { ... }: { enable = false; };
    settings.colorscheme = "catppuccin-mocha";
  })
];
```

Alternatively import `inputs.nixCats.homeModules.default` (or
`nixosModules.default`) and set `wrappers.neovim.enable = true;`.
Configure specs/settings under `wrappers.neovim`. Choose one installation method.
The old nixCats-specific module/override API is replaced by these wrapper options.

The exported `wrapperModules.neovim` can be imported into another wrapper module.
The overlay exports `pkgs.nixCats`.
