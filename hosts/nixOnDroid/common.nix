{ inputs, pkgs, ... }:
{
  system.stateVersion = "24.05";
  user.userName = "seeker";
  user.shell = "${pkgs.fish}/bin/fish";

  # Nix-on-Droid does not provide a system OpenSSH daemon. Install the client
  # explicitly; the remaining CLI tools come from the Home Manager profile.
  environment.packages = [ pkgs.openssh ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    config = import ../../users/seeker/nix-on-droid.nix;
  };
}
