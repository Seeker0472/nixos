{ ... }:
let
  host = import ./home.nix;
in
{
  imports = [
    ./options.nix
    ./samba.nix
  ];

  networking.hostName = host.hostName;
  system.stateVersion = host.stateVersion;

  boot.isContainer = true;

  services.openssh.enable = true;
}
