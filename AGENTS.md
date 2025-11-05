# Repository Guidelines

## Project Structure & Module Organization
- Root `init.lua` bootstraps fallback `nixCatsUtils` setup then delegates to `lua/myLuaConf`.
- `lua/myLuaConf` holds domain modules (`plugins/`, `LSPs/`, `format.lua`, `lint.lua`, `debug.lua`) loaded conditionally through `nixCats` categories.
- `lua/nixCatsUtils` provides helper handlers (e.g., `lzUtils.for_cat`) reused by LZE plugin specs.
- `after/plugin/` contains compatibility examples that run after Neovim loads.

## Build, Test, and Development Commands
- `nix develop` drops you into a shell with the default `nixCats` Neovim build on `PATH`.
- `nix build .#nixCats` produces the configured Neovim package; use `result/bin/nixCats` to launch.
- `nix run .#nixCats -- --headless "+q"` validates startup without opening UI.
- `nix flake check` ensures the flake evaluates for all declared systems.

## Coding Style & Naming Conventions
- Lua sources prefer two-space indentation outside plugin specs; respect existing tabs within LZE tables.
- Name modules under the `myLuaConf.*` namespace and keep category-specific logic in matching files (e.g., `lint.lua` for lint setup).
- Keep user commands, keymaps, and plugin specs descriptive; reuse existing `for_cat` handlers instead of ad-hoc checks.
- Use Lua single quotes for strings unless interpolation is needed; tables trail with commas.

## Testing Guidelines
- Functional testing happens inside Neovim: run `:checkhealth` and trigger category-specific loaders via the matching `nixCats` categories.
- When adding formatters or linters, verify `conform`/`nvim-lint` hooks by opening representative files and observing diagnostics.
- Capture regressions by launching `nix run .#nixCats` in headless mode for automated scripts.

## Commit & Pull Request Guidelines
- Without repo history here, follow Conventional Commits (`feat:`, `fix:`, `docs:`) and keep subjects under 72 chars.
- Reference enabled categories or modules touched in the body (e.g., "touches `myLuaConf.plugins.telescope`").
- Pull requests should describe testing (`nix run`, in-editor checks) and link related issues or upstream docs; include before/after screenshots when UI behavior changes.

## Non-Nix Usage Notes
- Honor the fallback path by updating `lua/myLuaConf/non_nix_download.lua` whenever plugins gain non-Nix install steps.
- Keep instructions in `init.lua` accurate so non-Nix users understand how the bootstrap works.
