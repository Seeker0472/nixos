{ pkgs, nur, sharedConfig, ... }: {
  home.packages = with pkgs;[
    # programming/ysyx/learning
    gcc
    gdb
    gnumake
    lazygit

    # coursier

    clang-tools
    # clang
    # rocmPackages_5.llvm.clang-tools-extra #clangd
  ] ++ (if sharedConfig.software_package == "cli" then [ ] else [
  gtkwave
  surfer # better wave

  ]);
  }
