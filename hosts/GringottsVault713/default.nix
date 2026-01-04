{ pkgs, ... }:
{
  imports = [
    ./options.nix
    ./samba.nix
  ];

  networking.hostName = "GringottsVault713";
  system.stateVersion = "25.11";

  boot.isContainer = true;

  services.openssh.enable = true;
}
