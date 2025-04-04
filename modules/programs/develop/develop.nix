{ pkgs, nur,  sharedConfig,... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    gcc
    gdb
    gnumake
    lazygit

    # coursier

    clang-tools
    nixfmt-classic
  ] ++ (if builtins.elem "develop_full" sharedConfig.software_package then [
    # jetbrains.idea-ultimate
    # jetbrains.clion
    # jetbrains.pycharm-professional
    vscode

    # pkgs.nur.repos.lschuermann.vivado-2022_2
    # ciscoPacketTracer8

  ] else [ ])
  ++ (if builtins.elem "gui" sharedConfig.software_package then [
    gtkwave
    surfer # better wav
  ] else [ ]);
}
