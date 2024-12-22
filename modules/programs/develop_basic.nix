{ pkgs, nur, ... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    gcc
    gdb
    gnumake
    lazygit

    # coursier

    gtkwave
    surfer # better wave
    clang-tools
    # clang
    # rocmPackages_5.llvm.clang-tools-extra #clangd
  ];
}
