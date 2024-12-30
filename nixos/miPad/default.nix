{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./common.nix
    ../common/develop.nix
    ../common/fonts.nix
  ];
}
