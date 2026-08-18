{ pkgs, ... }:
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
  };

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
