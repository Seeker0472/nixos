{ pkgs, ... }:
let
  sshKeys = import ../../users/seeker/ssh-public-keys.nix;
in
{
  networking.hostName = "nixos-wsl";
  system.stateVersion = "26.05";

  wsl = {
    enable = true;
    defaultUser = "seeker";
  };

  programs.fish.enable = true;
  users.users.seeker = {
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = sshKeys.authorizedKeys;
  };

  machine = {
    secrets = {
      deploy = true;
      nixConfig.enable = true;
      ageKeyPath = "/home/seeker/.config/sops/age/keys.txt";
    };
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = true;
    };
  };

  # The shared CLI profile supplies GC, store optimisation and flakes.
  nix.channel.enable = false;
}
