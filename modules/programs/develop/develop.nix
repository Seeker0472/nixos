{ pkgs, nur, sharedConfig, nixpkgs-dev, ... }: {
  home.packages = with pkgs;
    [
      # programming/ysyx/learning
      gcc
      gdb
      gnumake
      lazygit
      #neovim & dependences
      neovim
      lua5_1
      luarocks
      ripgrep
      python313Packages.ipython
      # coursier

      clang-tools
      nixfmt-classic
    ] ++ (if builtins.elem "develop_full" sharedConfig.software_package then
      [
        # jetbrains.idea-ultimate
        # jetbrains.clion
        # jetbrains.pycharm-professional
        vscode
        zed-editor

        # pkgs.nur.repos.lschuermann.vivado-2022_2
        # ciscoPacketTracer8

      ]
    else
      [ ]) ++ (if builtins.elem "gui" sharedConfig.software_package then [
        gtkwave
        surfer # better wav
      ] else
        [ ]);
}
