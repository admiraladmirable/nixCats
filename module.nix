# Adapted from nix-community/nix-wrapper-modules/templates/neovim/module.nix.
inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  options,
  ...
}:
let
  plugins = pkgs.vimPlugins;
  lazy = data: {
    inherit data;
    lazy = true;
  };
  generalEnabled = lib.mkDefault config.specs.general.enable;
  debugEnabled = lib.mkDefault config.specs.debug.enable;
in
{
  imports = [ wlib.wrapperModules.neovim ];

  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "catppuccin-frappe";
    description = "Colorscheme selected by the Lua configuration.";
  };
  options.settings.lspDebugMode = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable verbose LSP logging.";
  };
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: spec: spec.enable) config.specs;
    description = "Enabled specs, exposed to the Lua category adapter.";
  };

  config = {
    binName = "nixCats";
    settings = {
      config_directory = ./.;
      aliases = [
        "vim"
        "vimcat"
      ];
      dont_link = true;
    };
    hosts.python3.nvim-host.enable = true;
    hosts.node.nvim-host.enable = true;

    info.nixdExtras.nixpkgs = "import ${pkgs.path} {}";

    # The template extends specs with runtime packages so disabling a feature
    # removes its tools as well as its plugins.
    specMods = { ... }: {
      options.runtimePkgs = options.runtimePkgs // {
        description = "Runtime tools included only when this spec is enabled.";
      };
    };
    runtimePkgs = config.specCollect (acc: spec: acc ++ (spec.runtimePkgs or [ ])) [ ];

    specs = {
      general = {
        data = null;
        runtimePkgs = with pkgs; [
          lazygit
          gh
          jujutsu
          jjui
          universal-ctags
          ripgrep
          fd
          fixjson
          tree-sitter
        ];
      };
      "general.always" = {
        enable = generalEnabled;
        data = with plugins; [
          lze
          lzextras
          vim-repeat
          plenary-nvim
          snacks-nvim
          edgy-nvim
          smear-cursor-nvim
          mini-pairs
          mini-ai
          mini-align
          mini-icons
          mini-cursorword
          (config.nvim-lib.mkPlugin "vim-highlighter" inputs.plugins-vim-highlighter)
          todo-comments-nvim
          grug-far-nvim
          rustaceanvim
          nvim-web-devicons
          bufferline-nvim
          noice-nvim
          nui-nvim
          flash-nvim
          diffview-plus-nvim
          (nvim-notify.overrideAttrs { doCheck = false; })
          (lazy nvim-lspconfig)
          (lazy lualine-nvim)
          (lazy gitsigns-nvim)
          (lazy vim-sleuth)
          (lazy vim-fugitive)
          (lazy vim-rhubarb)
          (lazy nvim-surround)
        ];
      };
      "general.extra" = {
        enable = generalEnabled;
        data = with plugins; [
          oil-nvim
          nvim-web-devicons
          (lazy fidget-nvim)
          (lazy lualine-lsp-progress)
          (lazy which-key-nvim)
          (lazy comment-nvim)
          (lazy undotree)
          (lazy indent-blankline-nvim)
          (lazy vim-startuptime)
          (lazy trouble-nvim)
          (lazy hunk-nvim)
        ];
      };
      "general.blink" = {
        enable = generalEnabled;
        lazy = true;
        data = with plugins; [
          luasnip
          friendly-snippets
          cmp-cmdline
          blink-cmp
          blink-compat
          colorful-menu-nvim
        ];
      };
      "general.treesitter" = {
        enable = generalEnabled;
        lazy = true;
        data = with plugins; [
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
        ];
      };
      "general.telescope" = {
        enable = generalEnabled;
        lazy = true;
        data = with plugins; [
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          telescope-nvim
        ];
      };
      themer.data = builtins.getAttr config.settings.colorscheme {
        onedark = plugins.onedark-nvim;
        catppuccin = plugins.catppuccin-nvim;
        catppuccin-frappe = plugins.catppuccin-nvim;
        catppuccin-mocha = plugins.catppuccin-nvim;
        tokyonight = plugins.tokyonight-nvim;
        tokyonight-day = plugins.tokyonight-nvim;
      };
      lint = {
        lazy = true;
        data = with plugins; [
          nvim-lint
          checkmate-nvim
        ];
        runtimePkgs = with pkgs; [
          markdownlint-cli2
          checkmake
          actionlint
          bash
          terraform
          commitlint
          hadolint
          stylua
          lua54Packages.luacheck
          yamllint
          helm
          nixfmt
          eslint
        ];
      };
      format = {
        lazy = true;
        data = [ plugins.conform-nvim ];
        runtimePkgs = with pkgs; [
          stylua
          shfmt
          jq
          yq-go
          prettier
          prettierd
          rustfmt
          rust-analyzer
          go
          ruff
          codespell
          gofumpt
        ];
      };
      markdown = {
        lazy = true;
        data = with plugins; [
          markdown-preview-nvim
          markdown-nvim
          render-markdown-nvim
        ];
      };
      neonixdev = {
        lazy = true;
        data = [ plugins.lazydev-nvim ];
        runtimePkgs = with pkgs; [
          nix-doc
          lua-language-server
          nixd
        ];
      };
      devops = {
        lazy = true;
        data = [ plugins.helm-ls-nvim ];
        runtimePkgs = with pkgs; [
          action-validator
          bash-language-server
          docker-language-server
          docker-compose-language-service
          helm-ls
          terraform-ls
          tofu-ls
          yaml-language-server
          kdePackages.qtdeclarative
        ];
      };
      typescript = {
        data = null;
        runtimePkgs = with pkgs; [
          typescript-language-server
          eslint
          prettier
        ];
      };
      go = {
        data = null;
        runtimePkgs = with pkgs; [
          gopls
          gotools
          go-tools
        ];
      };
      rust.data = null;
      debug.data = [ plugins.nvim-nio ];
      "debug.default" = {
        enable = debugEnabled;
        lazy = true;
        data = with plugins; [
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
          neotest
        ];
      };
      "debug.go" = {
        enable = lib.mkDefault (config.specs.debug.enable && config.specs.go.enable);
        lazy = true;
        data = with plugins; [
          nvim-dap-go
          neotest-go
        ];
        runtimePkgs = [ pkgs.delve ];
      };
      "debug.rust" = {
        enable = lib.mkDefault (config.specs.debug.enable && config.specs.rust.enable);
        lazy = true;
        data = with plugins; [
          nvim-dap-lldb
          nvim-bacon
          neotest-rust
        ];
        runtimePkgs = with pkgs; [
          cargo-nextest
          (writeShellScriptBin "codelldb" ''
            exec ${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
          '')
        ];
      };
      test.data = null;
      "test.subtest1" = {
        data = null;
      };
      "test.subtest2" = {
        data = null;
        enable = lib.mkDefault false;
      };
    };

    env = lib.mkMerge [
      { NVIM_APPNAME = "nixCats-nvim"; }
      (lib.mkIf config.specs.test.enable {
        CATTESTVARDEFAULT = "It worked!";
        CATTESTVAR2 = "It worked again!";
      })
      (lib.mkIf config.specs."test.subtest1".enable { CATTESTVAR = "It worked!"; })
      (lib.mkIf config.specs."test.subtest2".enable { CATTESTVAR3 = "It didn't work!"; })
    ];
  };
}
