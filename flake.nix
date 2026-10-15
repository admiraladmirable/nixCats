{
  description = "Lua Neovim configuration packaged with nix-wrapper-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    wrappers.url = "github:nix-community/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    plugins-vim-highlighter = {
      url = "github:azabiong/vim-highlighter";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      ...
    }@inputs:
    let
      # Based on nix-wrapper-modules/templates/neovim.
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
      module = nixpkgs.lib.modules.importApply ./module.nix inputs;
      wrapper = wrappers.lib.evalModule module;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      wrapperModules = {
        neovim = module;
        default = module;
      };
      wrappers = {
        neovim = wrapper.config;
        default = wrapper.config;
      };
      packages = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        rec {
          nixCats = self.wrappers.neovim.wrap { inherit pkgs; };
          neovim = nixCats;
          default = nixCats;
        }
      );
      checks = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          editor = self.packages.${system}.nixCats;
        in
        {
          startup = pkgs.runCommand "neovim-wrapper-smoke" { } ''
            export XDG_CONFIG_HOME="$TMPDIR/config"
            export XDG_DATA_HOME="$TMPDIR/data"
            export XDG_STATE_HOME="$TMPDIR/state"
            export XDG_CACHE_HOME="$TMPDIR/cache"
            ${editor}/bin/nixCats --headless -i NONE '+luafile ${./tests/smoke.lua}'
            export EDITOR_CONFIG_SOURCE=${./.}
            ${pkgs.neovim-unwrapped}/bin/nvim -u NONE -i NONE -l ${./tests/fallback.lua}
            touch "$out"
          '';
        }
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.default ];
          };
        }
      );
      overlays = {
        default = self.overlays.neovim;
        neovim = final: prev: {
          nixCats = self.wrappers.neovim.wrap { pkgs = final; };
        };
      };
      nixosModules = {
        default = self.nixosModules.neovim;
        neovim = wrappers.lib.getInstallModule {
          name = "neovim";
          value = module;
        };
      };
      homeModules = self.nixosModules;
    };
}
