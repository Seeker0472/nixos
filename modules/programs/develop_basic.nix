{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    gcc
    gdb
    gnumake
    lazygit

    gtkwave
    surfer # better wave
    clang-tools
    # rocmPackages_5.llvm.clang-tools-extra #clangd
  ];
}