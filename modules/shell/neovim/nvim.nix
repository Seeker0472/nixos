{
  config,
  lib,
  pkgs,
  ...
}:
###############################################################################
#
#  AstroNvim's configuration and all its dependencies(lsp, formatter, etc.)
#
#  Copied from https://github.com/ryan4yin/nix-config/blob/main/home/base/tui/editors/neovim/default.nix
#
###############################################################################
let
  shellAliases = {
    v = "nvim";
    vdiff = "nvim -d";
  };
in {
  # 这段代码的作用应该是在 home-manager 激活过程中，使用 rsync 将当前配置目录下的 nvim 文件夹同步到用户的 .config/nvim 目录，同时设置特定的文件权限。
  home.activation.installAstroNvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${./anvim}/ ${config.xdg.configHome}/nvim/
  '';

  # home.shellAliases = shellAliases;
  # programs.nushell.shellAliases = shellAliases;

  programs = {
    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;

      # defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      # These environment variables are needed to build and run binaries
      # with external package managers like mason.nvim.
      #
      # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
      # it will be set by nix-ld, so we do not need to set it here again.
      extraWrapperArgs = with pkgs; [
        # LIBRARY_PATH is used by gcc before compilation to search directories
        # containing static and shared libraries that need to be linked to your program.
        "--suffix"
        "LIBRARY_PATH"
        ":"
        "${lib.makeLibraryPath [stdenv.cc.cc zlib]}"

        # PKG_CONFIG_PATH is used by pkg-config before compilation to search directories
        # containing .pc files that describe the libraries that need to be linked to your program.
        "--suffix"
        "PKG_CONFIG_PATH"
        ":"
        "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [stdenv.cc.cc zlib]}"
      ];

      # Currently we use lazy.nvim as neovim's package manager, so comment this one.
      #
      # NOTE: These plugins will not be used by astronvim by default!
      # We should install packages that will compile locally or download FHS binaries via Nix!
      # and use lazy.nvim's `dir` option to specify the package directory in nix store.
      # so that these plugins can work on NixOS.
      #
      # related project:
      #  https://github.com/b-src/lazy-nix-helper.nvim
      plugins = with pkgs.vimPlugins; [
        # search all the plugins using https://search.nixos.org/packages
        telescope-fzf-native-nvim

        nvim-treesitter.withAllGrammars
      ];
    };
  };
}