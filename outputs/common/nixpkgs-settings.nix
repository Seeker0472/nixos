# modules/nixpkgs-settings.nix
{inputs, ...}: {
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [inputs.nur.overlays.default];
  };
}
